package Raft::Web::Request::Resource;
use strict;
use warnings;
use utf8;

use parent qw/Raft::Resource/;
use Class::Accessor::Lite::Lazy ro => [qw/req/], ro_lazy => [qw/session/];

use Scalar::Util ();
use Plack::Session;

sub new {
    my ($class, $req) = @_;
    my $self = $class->SUPER::new(req => $req);
    Scalar::Util::weaken($self->{req});
    return $self;
}

sub _build_session {
    my $self = shift;
    return Plack::Session->new($self->req->env);
}

1;
