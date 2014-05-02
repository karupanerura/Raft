package Raft::Web::Response::JSON;
use strict;
use warnings;
use utf8;

use parent qw/Raft::Web::Response/;

use Data::Recursive::Encode;

use JSON 2;
my $_JSON = JSON->new()->ascii(1);

my %_ESCAPE = (
    '+' => '\\u002b', # do not eval as UTF-7
    '<' => '\\u003c', # do not eval as HTML
    '>' => '\\u003e', # ditto.
);

sub default_content_type { 'application/json; charset=utf-8' }

sub format :method {
    my ($self, $req) = @_;

    # defense from JSON hijacking
    my $user_agent = $req->user_agent || '';
    if ((!$req->header('X-Requested-With')) && $user_agent =~ /android/i && defined $req->header('Cookie') && ($req->method||'GET') eq 'GET') {
        $self->status(403);
        $self->content_type('text/html; charset=utf-8');
        $self->content("Your request may be JSON hijacking.\nIf you are not an attacker, please add 'X-Requested-With' header to each request.");
        return;
    }

    # response
    my $content = Data::Recursive::Encode->encode_utf8($self->content);

    # for IE7 JSON venularity.
    # see http://www.atmarkit.co.jp/fcoding/articles/webapp/05/webapp05a.html
    my $output = $_JSON->encode($content);
    $output =~ s!([+<>])!$_ESCAPE{$1}!og;
    $self->content($output);
}

1;
__END__

=encoding utf-8

=head1 NAME

Raft::Web::Response::JSON - JSON response class

=head1 SYNOPSIS


=head1 DESCRIPTION

This is a JSON response class.

=head1 FAQ

=over 4

=item How can I use JSONP?

You can use JSONP by using L<Plack::Middleware::JSONP>.

=back

=head1 JSON and security

=over 4

=item Browse the JSON files directly.

This module escapes '<', '>', and '+' characters by "\uXXXX" form. Browser don't detects the JSON as HTML.

And also this module outputs C<< X-Content-Type-Options: nosniff >> header for IEs.

It's good enough, I hope.

=item JSON Hijacking

Latest browsers doesn't have a JSON hijacking issue(I hope). __defineSetter__ or UTF-7 attack was resolved by browsers.

But Firefox<=3.0.x and Android phones have issue on Array constructor, see L<http://d.hatena.ne.jp/ockeghem/20110907/p1>.

Firefox<=3.0.x was outdated. Web application developers doesn't need to add work-around for it, see L<http://en.wikipedia.org/wiki/Firefox#Version_release_table>.

L<Raft::Web::Response::JSON> have a JSON hijacking detection feature. Raft::Web::Response::JSON returns "403 Forbidden" response if following pattern request.

=over 4

=item The request have 'Cookie' header.

=item The request doesn't have 'X-Requested-With' header.

=item The request contains /android/i string in 'User-Agent' header.

=item Request method is 'GET'

=back

=back

See also the L<hasegawayosuke's article(Japanese)|http://www.atmarkit.co.jp/fcoding/articles/webapp/05/webapp05a.html>.

=head1 FAQ

=over 4

=item HOW DO YOU CHANGE THE HTTP STATUS CODE FOR JSON?

render_json method returns instance of Plack::Response. You can modify the response object.

Here is a example code:

    get '/' => sub {
        my $c = shift;
        if (-f '/tmp/maintenance') {
            my $res = $c->render_json({err => 'Under maintenance'});
            $res->status(503);
            return $res;
        }
        return $c->render_json({err => undef});
    };

=back

=head1 THANKS TO

hasegawayosuke
tokuhirom
