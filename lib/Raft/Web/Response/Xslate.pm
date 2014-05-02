package Raft::Web::Response::Xslate;
use strict;
use warnings;
use utf8;

use parent qw/Raft::Web::Response/;
use Class::Accessor::Lite::Lazy rw => [qw/xslate template/];

use Text::Xslate 2.0005; ## see also: Module::Advisor
use Encode qw/encode_utf8/;

sub initialize {
    my ($self, $app, $res_info) = @_;
    my $xslate = $app->{+__PACKAGE__}->{xslate}
        ||= Text::Xslate->new(%{ $app->config->{'Text::Xslate'} || +{} });
    $self->xslate($xslate);
    $self->template($res_info->{template});
    $self->SUPER::initialize();
}

sub default_content_type { "text/html; charset=utf-8" }

sub format :method {
    my ($self, $req) = @_;
    my $content = $self->xslate->render($self->template, $self->content);
    encode_utf8($content);
    $self->content($content);
}

1;
__END__

TODO: documentation
