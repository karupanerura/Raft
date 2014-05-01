package Raft::Resource;
use strict;
use warnings;
use utf8;

use Class::Accessor::Lite::Lazy new => 1;

## override
sub release {}

sub DESTROY {
    my $self = shift;
    $self->release;
}

1;
