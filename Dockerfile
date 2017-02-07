# Simple reverse-proxy with an authtoken stuck on the front end.
#
# Chris Weyl <chris.weyl@dreamhost.com> 2016

# 3.5 has v5.24.0 (at least)
FROM alpine:3.5
MAINTAINER Chris Weyl <cweyl@alumni.drew.edu>

ADD cpanm /

# install everything we can through the package repos.
RUN apk add --update \
        ca-certificates make \
        perl perl-plack perl-lwp-protocol-https perl-canary-stability \
        perl-extutils-helpers perl-extutils-config perl-extutils-installpaths \
        perl-module-build-tiny perl-path-tiny \
        perl-http-message \
    && rm -rf /var/cache/apk/*

# line 3 of Perl pkgs: Plack::App::Proxy deps

# ...and the rest of our deps from the CPAN
RUN PERL_CPANM_HOME=/cpanm-scratch perl /cpanm -q \
        Plack::App::Proxy \
        Plack::Middleware::Auth::AccessToken \
    && rm -rf /cpanm-scratch

ADD app.psgi /

ENTRYPOINT plackup --listen 0.0.0.0:8080
