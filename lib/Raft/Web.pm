package Raft::Web;
use strict;
use warnings;
use utf8;

use Class::Accessor::Lite::Lazy ro => [qw/router/];
use Raft::Web::Request;

sub to_app {
    my $invocant = shift;

    my $self = ref $invocant ? $invocant : $invocant->new(@_);
    return sub { $self->handle_request(@_) };
}

sub create_request { Raft::Web::Request->new($_[1]) }

sub handle_request {
    my ($self, $env) = @_;
    my $req = $self->create_request($env);
    my ($route, $is_method_not_allowed) = $self->router->match($req);
    if ($route) {
        my $res = $route->{response}->{class}->new;
        $res->initialize($self, $route->{response});

        $route->{on_req}->($self, $req, $res) if exists $route->{on_req};
        $res->content( $route->{action}->($self, $req, $res) );
        $res->format($req);
        $route->{on_res}->($self, $req, $res) if exists $route->{on_res};
        return $res->finalize();
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
