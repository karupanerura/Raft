package Raft::Web::Middleware;
use strict;
use warnings;
use utf8;

use Class::Accessor::Lite::Lazy new => 1;

sub wrap {
    my ($self, $controller) = @_;
    # override it!!
    return $controller;
}

1;
__END__
