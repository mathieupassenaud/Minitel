package    # hide from PAUSE
  TestUA;

use warnings;
use strict;
use URI;

### Load method data into %apicalls at runtime.

my %twitter_api = (
    "/statuses/public_timeline" => {
        "blankargs" => 0,
        "post"      => 0,
        "args"      => {},
    },
    "/statuses/friends_timeline" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "since"    => 0,
            "since_id" => 0,
            "count"    => 0,
            "page"     => 0,
        },
    },
    "/statuses/user_timeline" => {
        "has_id"    => 1,
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "id"       => 0,
            "since"    => 0,
            "since_id" => 0,
            "count"    => 0,
            "page"     => 0,
        },
    },
    "/statuses/show" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 0,
        "args"      => { "id" => 1, },
    },
    "/statuses/update" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => {
            "status"                => 1,
            "in_reply_to_status_id" => 0,
            "source"                => 0,
        },
    },
    "/statuses/replies" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "page"     => 0,
            "since"    => 0,
            "since_id" => 0,
        },
    },
    "/statuses/destroy" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/statuses/friends" => {
        "has_id"    => 1,
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "id"    => 0,
            "page"  => 0,
            "since" => 0,
        },
    },
    "/statuses/followers" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "id"   => 0,
            "page" => 0,
        },
    },
    "/followers/ids" => {
        "has_id"    => 1,
        "blankargs" => 1,
        "post"      => 0,
        "args"      => { "id" => 0 },
    },
    "/users/show" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 0,
        "args"      => {
            "id"    => 1,
            "email" => 1,
        },
        required => sub {
            my $args = shift;

            # one, but not both
            return ( exists $args->{id} xor exists $args->{email} );
        },
    },
    "/direct_messages" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "since"    => 0,
            "since_id" => 0,
            "page"     => 0,
        },
    },
    "/direct_messages/sent" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "since"    => 0,
            "since_id" => 0,
            "page"     => 0,
        },
    },
    "/direct_messages/new" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => {
            "user" => 1,
            "text" => 1,
        },
    },
    "/direct_messages/destroy" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/friendships/create" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => {
            "id"     => 1,
            "follow" => 0,
        },
    },
    "/friendships/destroy" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/friendships/exists" => {
        "blankargs" => 0,
        "post"      => 0,
        "args"      => {
            "user_a" => 1,
            "user_b" => 1,
        },
    },
    "/friends/ids" => {
        "has_id"    => 1,
        "blankargs" => 1,
        "post"      => 0,
        "args"      => { "id" => 0 },
    },
    "/account/verify_credentials" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {},
    },
    "/account/end_session" => {
        "blankargs" => 1,
        "post"      => 1,
        "args"      => {},
    },
    "/account/update_profile" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => {
            "name"        => 0,
            "email"       => 0,
            "url"         => 0,
            "location"    => 0,
            "description" => 0,
        },
    },
    "/account/update_profile_colors" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => {
            "profile_background_color"     => 0,
            "profile_text_color"           => 0,
            "profile_link_color"           => 0,
            "profile_sidebar_fill_color"   => 0,
            "profile_sidebar_border_color" => 0,
        },
    },
    "/account/update_profile_image" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "image" => 1, },
    },
    "/account/update_profile_background_image" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "image" => 1, },
    },
    "/account/update_delivery_device" => {
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "device" => 1, },
    },
    "/account/rate_limit_status" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {},
    },
    "/favorites" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {
            "id"   => 0,
            "page" => 0,
        },
    },
    "/favorites/create" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/favorites/destroy" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/notifications/follow" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/notifications/leave" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/blocks/create" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/blocks/destroy" => {
        "has_id"    => 1,
        "blankargs" => 0,
        "post"      => 1,
        "args"      => { "id" => 1, },
    },
    "/help/test" => {
        "blankargs" => 1,
        "post"      => 0,
        "args"      => {},
    },
    "/help/downtime_schedule" => {
        "blankargs" => 100,
        "post"      => 0,
        "args"      => {},
    },
);

sub new {
    my $class = shift;
    return bless { _host => 'twitter.com', }, $class;
}

sub credentials { }

sub agent { }

sub default_header { }

sub env_proxy { }

sub get {
    my ( $self, $url ) = @_;

    my $uri = URI->new($url);
    eval { $self->_validate_basic_url($uri) };
    if ( my $error = $@ ) {
        chomp $error;
        return $self->_error_response( 400, $error );
    }

    # strip the args
    my %args = $uri->query_form;
    $uri->query_form( [] );

    return $self->_twitter_rest_api( 'GET', $uri, \%args );
}

sub post {
    my ( $self, $url, $args ) = @_;

    my $uri = URI->new($url);
    eval { $self->_validate_basic_url($uri) };
    return $self->_error_response( 400, chomp $@ ) if $@;

    return $self->_error_response( 400, "POST $url contains parameters" ) if $uri->query_form;
    return $self->_twitter_rest_api( 'POST', $uri, $args );
}

sub _twitter_rest_api {
    my ( $self, $method, $uri, $args ) = @_;

    my ( $path, $id ) = eval { $self->_parse_path_id($uri) };

    return $self->_error_response( 400, chomp $@ ) if $@;

    return $self->_error_response( 400, "Bad URL, /ID.json present." ) if $uri =~ m/ID.json/;

    my $api_entry = $twitter_api{$path}
      || return $self->error_response( 404, "$path is not a twitter api entry" );

    # TODO: What if ID is passed in the URL and args? What if the 2 are different?
    $args->{id} = $id if $api_entry->{has_id} && defined $id && $id;

    $self->{_input_args} = {%$args};    # save a copy of input args for tests

    return $self->_error_response( 400, "expected POST" )
      if $api_entry->{post} && $method ne 'POST';
    return $self->_error_response( 400, "expected GET" )
      if !$api_entry->{post} && $method ne 'GET';

    if ( my $coderef = $api_entry->{required} ) {
        unless ( $coderef->($args) ) {
            return $self->_error_response( 400, "requried args test failed" );
        }
    } else {
        my @required = grep { $api_entry->{args}{$_} } keys %{ $api_entry->{args} };
        if ( my @missing = grep { !exists $args->{$_} } @required ) {
            return $self->_error_response( 400, "requried args missing: @missing" );
        }
    }

    if ( my @undefined = grep { $args->{$_} eq '' } keys %$args ) {
        return $self->_error_response( 400, "args with undefined values: @undefined" );
    }

    my %unexpected_args = map { $_ => 1 } keys %$args;
    delete $unexpected_args{$_} for keys %{ $api_entry->{args} };
    if ( my @unexpected_args = sort keys %unexpected_args ) {

        # twitter seems to ignore unexpected args, so don't fail, just diag
        print "# unexpected args: @unexpected_args\n" if $self->print_diags;
    }

    return $self->_response;
}

sub _validate_basic_url {
    my ( $self, $url ) = @_;

    my $uri = URI->new($url);

    die "scheme: expected http\n" unless $uri->scheme eq 'http';
    die "bad host\n"              unless $uri->host   eq 'twitter.com';
    die "expected .json\n" unless ( my $path = $uri->path ) =~ s/\.json$//;

    $uri->path($path);
}

sub _error_response {
    my ( $self, $rc, $msg ) = @_;

    print "# $msg\n" if $self->print_diags;
    return $self->_response( _rc => $rc, _msg => $msg, _content => $msg );
}

sub _response {
    my ( $self, %args ) = @_;

    my $content = $self->success_content;
    $content = '{"test":"1"}' unless defined $content;
    bless {
        _content => $content,
        _rc      => 200,
        _msg     => 'OK',
        _headers => {},
        %args,
      },
      'HTTP::Response';
}

sub _parse_path_id {
    my ( $self, $uri ) = @_;

    ( my $path = $uri->path ) =~ s/\.json$//;
    return ($path) if $twitter_api{$path};

    ( $path, my $id ) = $path =~ /(.*)\/(.*)$/;

    return ( $path, $id ) if $twitter_api{$path} && $twitter_api{$path}{has_id};

    die "$path is not a twitter_api method\n";
}

sub print_diags {
    my $self = shift;

    return $self->{_print_diags} unless @_;
    $self->{_print_diags} = shift;
}

sub success_content {
    my $self = shift;

    return $self->{_success_content} unless @_;
    $self->{_success_content} = shift;
}

sub clear_success_content {
    my $self = shift;

    delete $self->{_success_content};
}

sub input_args {
    my $self = shift;

    return $self->{_input_args} || {};
}

1;
