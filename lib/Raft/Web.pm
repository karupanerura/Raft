package Raft::Web;
use strict;
use warnings;
use utf8;

use Class::Accessor::Lite::Lazy ro => [qw/router middlewares/];
use Raft::Web::Request;

sub to_app {
    my $class = shift;
    my $self  = $class->new(@_);

    return sub { $self->handle_request(@_) };
}

sub create_request { Raft::Web::Request->new($_[1]) }

sub handle_request {
    my ($self, $env) = @_;
    my ($route, $captured, $is_method_not_allowed) = $self->router->match(@{$env}{qw/REQUEST_METHOD PATH_INFO/});
    if ($route) {
        # middleware
        $route = $_->wrap($route) for reverse @{ $self->middlewares };

        # req
        my $req = $self->create_request($env);
        $req->args($captured);

        # res
        my $res = $route->{response}->{class}->new;
        $res->initialize($self, $route->{response});
        $res->content( $route->{action}->($self, $req, $res) );
        return $res->finalize($req);
    }
    elsif ($is_method_not_allowed) {
        return $self->res_405;
    }
    else {
        return $self->res_404;
    }
}

sub res_404 {
    return [
        404,
        ['Content-Type' => 'application/json', 'Content-Length' => 24],
        ['{"message":"not found."}'],
    ];
}

sub res_405 {
    return [
        405,
        ['Content-Type' => 'application/json', 'Content-Length' => 33],
        ['{"message":"method not allowed."}'],
    ];
}

1;
