package Raft::Lite;
use strict;
use warnings;
use utf8;

use Raft;
use Raft::Web;
use Raft::Web::Router;
use Plack::Util;

sub import {
    my $class  = shift;
    my $caller = caller;

    {
        no strict 'refs';
        @{"${caller}::ISA"} = ('Raft', 'Raft::Web');
    }
    $class->export_to($caller);
}

sub export_to {
    my ($class, $target) = @_;

    my %default_route;
    $class->_export_to($target, 'default' => sub {
        %default_route = (%default_route, @_);
    });

    my @routes;
    $class->_export_to($target, 'any' => sub {
        my $methods = @_ >= 3 && ref $_[0] eq 'ARRAY' ? +shift : undef;
        my ($path, $action, $route) = @_;
        push @routes => +{
            %{ $route || {} },
            path   => $path,
            method => $methods,
            action => $action,
        };
    });
    for my $method (qw/get post put/) {
        $class->_export_to($target, $method => sub {
            my ($path, $action, $route) = @_;
            push @routes => +{
                %{ $route || {} },
                path   => $path,
                method => [uc $method],
                action => $action,
            };
        });
    }

    my @middlewares;
    $class->_export_to($target, 'enable_raft_middleware' => sub {
        my $middleware = shift;
        unless (ref $middleware) {
            $middleware = Plack::Util::load_class($middleware, 'Raft::Web::Middleware');
            $middleware = $middleware->new(@_);
        }
        push @middlewares => $middleware;
    });

    my $router = Raft::Web::Router->new(middlewares => \@middlewares, default => \%default_route);
    my $app    = $target->new(router => $router);
    {
        my $super = $target->can('to_app');
        $class->_export_to($target, 'to_app' => sub {
            $router->add(delete @{$_}{qw/method path/}, $_) for @routes;
            return $app->$super();
        });
    }
}

sub _export_to {
    my ($class, $target, $name, $code) = @_;
    no strict 'refs';
    return *{"${target}::${name}"} = $code;
}

1;
__END__

=pod

=encoding utf-8

=head1 NAME

Raft::Lite - sinatra-ish syntax sugar

=head1 VERSION

This document describes Raft::Lite version 0.01.

=head1 SYNOPSIS

    use Raft::Lite;
    use Data::Section::Simple ();

    sub load_config {
        return +{
            'Text::Xslate' => +{
                path  => Data::Section::Simple->new->get_data_section(),
                cache => 0,
            },
        };
    }

    default response => { class => 'JSON' };

    enable_raft_middleware 'Lint';

    get '/' => sub {
        my ($app, $req, $res) = @_;
        return { msg => "Hello!" };
    } => {
        response => {
            class    => 'Xslate',
            template => 'index.tx',
        },
    };

    get '/sample.json' => sub {
        my ($app, $req, $res) = @_;
        return { msg => "Hello!" };
    }; # default: { response => { class => 'JSON' } }

    __PACKAGE__->to_app;
    __DATA__
    @@ index.tx
    msg: <: $msg :>

=head1 DESCRIPTION

TODO

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>
