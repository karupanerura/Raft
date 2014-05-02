package Raft::Web::Middleware::Lint;
use strict;
use warnings;
use utf8;

use parent qw/Raft::Web::Middleware/;

sub wrap {
    my ($self, $route) = @_;
    $self->lint($route);
    return $route;
}

sub lint {
    my ($self, $route) = @_;
    unless (exists $route->{response} and ref $route->{response} eq 'HASH') {
        die '"$route->{response}" is required. ant it must "HashRef". @@@ DUMP : ' ._dump($route). ' @@@';
    }
    unless (exists $route->{response}->{class} and $route->{response}->{class}->isa('Raft::Web::Response')) {
        die '$route->{response}->{class} is required. and it must inherit "Raft::Web::Response". @@@ DUMP : ' ._dump($route). ' @@@';
    }
    unless (exists $route->{action} and ref $route->{action} eq 'CODE') {
        die '"$route->{action}" is required. ant it must "CodeRef". @@@ DUMP : ' ._dump($route). ' @@@';
    }
}

sub _dump {
    my $route = shift;
    require Data::Dumper;
    no warnings 'once';
    local $Data::Dumper::Terse    = 1;
    local $Data::Dumper::Indent   = 0;
    local $Data::Dumper::Sortkeys = 1;
    use warnings 'once';
    return Data::Dumper->Dump([$route]);
}

1;
__END__
