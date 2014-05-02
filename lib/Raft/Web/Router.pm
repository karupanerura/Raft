package Raft::Web::Router;
use strict;
use warnings;
use utf8;

use Class::Accessor::Lite::Lazy
    new     => 1,
    ro      => [qw/middlewares default/],
    ro_lazy => [qw/router/];

use Router::Boom::Method;
use Plack::Util;

sub _build_router { Router::Boom::Method->new() }

sub add {
    my ($self, $http_method, $path, $route) = @_;
    $route = { %{ $self->default }, %$route } if $self->default;
    $route->{response}->{class} = Plack::Util::load_class($route->{response}->{class}, 'Raft::Web::Response');
    $route = $_->wrap($route) for reverse @{ $self->middlewares || [] };
    $self->router->add($http_method, $path, $route);
}

sub match {
    my ($self, $req) = @_;

    my ($route, $captured, $is_method_not_allowed)
        = $self->router->match($req->method, $req->path_info);
    $req->args($captured || {});

    return ($route, $is_method_not_allowed);
}

1;
__END__
