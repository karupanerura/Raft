package Raft::Web::Request;
use strict;
use warnings;
use utf8;

use parent qw/Plack::Request::WithEncoding/;

use constant KEY_NAME_BASE => 'raft';

use Scalar::Util ();
use Raft::Web::Request::Resource;

use Class::Accessor::Lite::Lazy
    rw      => [qw/args/],
    ro_lazy => [qw/resource/];

sub new {
    my ($class, $env) = @_;
    my $self = $env->{KEY_NAME_BASE . '.request'} ||= $class->SUPER::new($env);
    Scalar::Util::weaken($self->{env});
    return $self;
}

# override it!!
sub create_resource { Raft::Web::Request::Resource->new(shift) }
sub _build_resource { shift->create_resource() }

# shortcut
sub session { shift->resource->session }

1;
