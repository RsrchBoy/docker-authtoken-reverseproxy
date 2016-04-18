use v5.10;
use strict;
use warnings;
use utf8;

use Plack::Builder;
use Plack::App::Proxy;
use Path::Tiny;

# first, find our token
my $TOKEN
    = $ENV{TOKEN_FILE} ? path($ENV{TOKEN_FILE})->slurp
    : $ENV{TOKEN}      ? $ENV{TOKEN}
    : die 'Must set (and populate!) TOKEN_FILE or TOKEN'
    ;

# then, where exactly we're proxying to
my $REMOTE
    = $ENV{REMOTE_CMD}  ? `$ENV{REMOTE_CMD}`
    : $ENV{REMOTE_FILE} ? path($ENV{REMOTE_FILE})->slurp
    : $ENV{REMOTE}      ? $ENV{REMOTE}
    : $ARGV[0]          ? $ARGV[0]
    : die 'Must set REMOTE{,_CMD,_FILE} or pass on the command line!'
    ;

say "Proxying to $REMOTE";

builder {
    enable 'AccessLog';
    enable 'Auth::AccessToken' => ( authenticator => sub { shift eq $TOKEN } );

    Plack::App::Proxy->new(remote => $REMOTE)->to_app;
};
