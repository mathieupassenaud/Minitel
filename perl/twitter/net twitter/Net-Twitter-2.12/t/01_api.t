#!perl
use Carp;
use strict;
use Test::More tests => 44;
use Test::Exception;

use lib qw(t/lib);

use Net::Twitter;

my $nt = Net::Twitter->new(
    username => 'homer',
    password => 'doh!',
    useragent_class => 'TestUA',
    die_on_validation => 1,
);

BAIL_OUT "useragent is not a TestUA!" unless UNIVERSAL::isa($nt->{ua}, 'TestUA');

$nt->{ua}->print_diags(1);

ok      $nt->friends_timeline({ since_id => undef }), 'undef args dropped';
ok      $nt->friends_timeline,                        'friends_timeline no args';

TODO: {
    local $TODO = 'Validation errors should throw with die_on_validation';
    eval { $nt->friends_timeline({ bogus_arg => 1 }) };
    ok  $@ && $@ =~ /bogus_arg/,                     'unexpected args';
}

ok      $nt->create_friend('flanders'),               'create_friend scalar arg';
ok      $nt->create_friend({ id => 'flanders' }),     'create_friend hashref';
ok      $nt->destroy_friend('flanders'),              'destroy_friend scalar arg';

$nt->{ua}->success_content('true');
my $r;

# back compat: 1.23 accepts scalar args
lives_ok { $r = $nt->relationship_exists('homer', 'marge') } 'relationship_exists scalar args';

ok       $r = $nt->relationship_exists({ user_a => 'homer', user_b => 'marge' }),
            'relationship_exists hashref';

# back compat: 1.23 returns bool
cmp_ok   $r, '==', 1, 'relationship_exists returns bool';
$nt->{ua}->clear_success_content;


# new API methods added Feb 09

ok      $nt->friends_ids();
ok      $nt->friends_ids("bob");
ok      $nt->friends_ids(id=>"bob");
ok      $nt->friends_ids({id=>"bob"});

ok      $nt->followers_ids();
ok      $nt->followers_ids("bob");
ok      $nt->followers_ids(id=>"bob");
ok      $nt->followers_ids({id=>"bob"});

# Net::Twitter calls used by POE::Component::Server::Twirc
$nt->{die_on_validation} = 0;
ok      $nt->new_direct_message({ user => 'marge', text => 'hello, world' }), 'new_direct_message';
ok      $nt->friends({page => 2}), 'friends';
ok      exists $nt->{ua}->input_args->{page} && $nt->{ua}->input_args->{page} == 2, 'page argument passed';
ok      $nt->followers({page => 2}), 'followers';
ok      $nt->direct_messages, 'direct_messages';
ok      $nt->direct_messages({ since_id => 1 }), 'direct_messages since_id';
ok      $nt->friends_timeline({ since_id => 1 }), 'friends_timeline since_id';
ok      $nt->replies({ since_id => 1 }), 'replies since_id';
ok      $nt->user_timeline, 'user_timeline';
ok      $nt->update('hello, world'), 'update';
ok      $nt->create_friend('flanders'), 'create_friend';
ok      $nt->relationship_exists('homer', 'flanders'), 'relationship exists scalar args';
ok      $nt->relationship_exists({ user_a => 'homer', user_b => 'flanders' }), 'relationship exists hashref';
ok      $nt->destroy_friend('flanders'), 'destroy_friend';
ok      $nt->create_block('flanders'), 'create_block';
ok      $nt->destroy_block('flanders'), 'destroy_block';
ok      $nt->create_favorite({ id => 12345678 }), 'create_favorite hashref';
ok      $nt->rate_limit_status, 'rate_limit_status';
ok      $nt->update_profile({name=> "Flerb"}), 'update_profile';

### Regression: broken in 2.03
ok      $nt->show_status('flanders'),           'show_status string arg';
my $id = $nt->{ua}->input_args->{id};
ok      $id && $id eq 'flanders',               'show_status ID set';

ok      $nt->show_user('marge'),     'show_user string arg';
        $id = $nt->{ua}->input_args->{id};
ok      $id && $id eq 'marge',       'show_user ID set';

ok      $nt->show_user({ id => 'homer' }),     'show_user hashref';
        $id = $nt->{ua}->input_args->{id};
ok      $id && $id eq 'homer',                  'show_user ID set 2';

ok      $nt->show_user({ email => 'fred@bedrock.com' }), 'show_user by email';
        $id = $nt->{ua}->input_args->{email};
is      $id, 'fred@bedrock.com',                'passed email';

exit 0;
