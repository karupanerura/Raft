package Raft::Web::Middleware;
use strict;
use warnings;
use utf8;

use Class::Accessor::Lite::Lazy new => 1;

sub wrap {
    my ($self, $route) = @_;
    # override it!!
    if ($self->can('on_req')) {
        $route->{on_req} = $self->_wrap_action($route->{on_req});
    }
    if ($self->can('data_filter')) {
        $route->{action} = $self->_wrap_action($route->{action});
    }
    if ($self->can('on_res')) {
        $route->{on_res} = $self->_wrap_on_res($route->{on_res});
    }
    return $route;
}

sub _wrap_on_req {
    my ($self, $on_req) = @_;
    return sub {
        my ($app, $req, $res) = @_;
        $on_req->($app, $req, $res) if $on_req;
        $self->on_req($req);
    };
}

sub _wrap_action {
    my ($self, $action) = @_;
    return sub {
        my ($app, $req, $res) = @_;
        my $data = $action->($app, $req, $res);
        return $self->data_filter($data);
    };
}

sub _wrap_on_res {
    my ($self, $on_res) = @_;
    return sub {
        my ($app, $req, $res) = @_;
        $on_res->($app, $req, $res) if $on_res;
        $self->on_res($res);
    };
}

1;
__END__
