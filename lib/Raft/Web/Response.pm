package Raft::Web::Response;
use strict;
use warnings;
use utf8;

use parent qw/Plack::Response/;

sub initialize {
    my ($self, $app, $res_info) = @_;
    $self->status(200);
    $self->header('X-Content-Type-Options' => 'nosniff'); # defense from XSS
    $self->content_type($self->default_content_type);
    $self->content('');
    # override it!!
}

sub default_content_type { 'text/plain' }

sub format :method {
    my ($self, $req) = @_;
    # override it!!
}

sub finalize {
    my $self = shift;
    $self->content_length(length $self->content);
    return $self->SUPER::finalize();
}

1;
__END__
