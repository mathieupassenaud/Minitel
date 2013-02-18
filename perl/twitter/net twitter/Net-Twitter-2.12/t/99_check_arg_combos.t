#!perl
use Carp;
use strict;
use Test::More;
use Test::Exception;

BEGIN {
    eval "use Data::PowerSet 'powerset'";
    if ( $@ ) {
        plan skip_all => 'Data::PowerSet required for these tests';
    }
    else {
        plan 'no_plan';
    }
}

use lib qw(t/lib);

use Net::Twitter;

my $nt = Net::Twitter->new(
    username          => 'homer',
    password          => 'doh!',
    useragent_class   => 'TestUA',
    die_on_validation => 0,
);

BAIL_OUT "useragent is not a TestUA!" unless UNIVERSAL::isa( $nt->{ua}, 'TestUA' );

my $apicalls = $nt->_get_apicalls();
ok defined $apicalls->{update}, "get %apicalls from Net::Twitter";

my %tests;
my @methods = sort( keys(%$apicalls) );

foreach my $method (@methods) {
    my @req;
    my @opt;
    $tests{$method} = ();

    my @keys = keys( %{ $apicalls->{$method}->{args} } );
    if ( my $count = scalar(@keys) ) {
        foreach my $key (@keys) {
            if ( ( $method eq "show_user" ) and ( $key =~ m/id|email/ ) ) {
                next;
            }
            if ( $apicalls->{$method}->{args}->{$key} ) {
                push( @req, $key );
            } else {
                push( @opt, $key );
            }
        }
    } else {
        push( @{ $tests{$method} }, ["NONE"] );
        next;
    }
    
    my $powerset = powerset(@opt);
    
    foreach my $p (@$powerset) {
        my @testargs;
        if ( $method eq "show_user" ) {
            push( @{$tests{$method}}, [("id", @$p)]);
            push( @{$tests{$method}}, [("email", @$p)]);
        } else {
            if ( scalar(@req) ) {
                push( @testargs, @req );
            }
            if ( scalar(@$p) ) {
                push( @testargs, @$p );
            }
            push( @{ $tests{$method} }, \@testargs ) unless ( !scalar(@testargs) );
        }
    }
    if ( $apicalls->{$method}->{blankargs} ) {
        push( @{ $tests{$method} }, ["ZERO"] );
    }
}

foreach my $testmethod ( sort keys %tests ) {
    if ( $tests{$testmethod}->[0]->[0] eq 'NONE' ) {
        ok $nt->$testmethod(), "No Args to $testmethod";
        next;
    }
    foreach my $combolist ( @{ $tests{$testmethod} } ) {
        if ( $combolist->[0] eq 'ZERO' ) {
            ok $nt->$testmethod(), "Zero Args to $testmethod";
            last;
        }
        foreach my $combo ($combolist) {
            if ( ( scalar @$combo == 1 ) and $combo->[0] eq "id" ) {
                ok $nt->$testmethod( $combo->[0] ), "Single string " . $combo->[0] . " passed to $testmethod";
            }
            my $arghash = {};
            foreach my $passarg (@$combo) {
                $arghash->{$passarg} = 1;
            }

            ok $nt->$testmethod($arghash), join( ", ", @$combo ) . " passed to $testmethod";
        }

    }
}
