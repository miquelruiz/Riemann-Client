use strict;
use warnings;

use Test::More;
use Net::Domain qw/ hostfqdn /;
use String::Random;

BEGIN { use_ok 'Riemann::Client'; }

SKIP: {
    skip '$ENV{RIEMANN_SERVER} not defined', 3
        unless defined $ENV{RIEMANN_SERVER};

    my $rand = String::Random->new;

    my $r = Riemann::Client->new(
        host => $ENV{RIEMANN_SERVER},
        port => $ENV{RIEMANN_SERVER_PORT} || 5555,
    );

    my $svc = $rand->randpattern('cCcnCnc');
    my $mt  = rand(10);
    ok (
        $r->send(
            service => $svc,
            metric => $mt,
            state => 'ok',
            description => 'a' x 100000
        ),
        "Message sent -> metric: $mt",
    );

    my $res = $r->query('host = "' . hostfqdn() . '"');
    is(ref $res, 'ARRAY', "Got an array as query response");
    is(ref $res->[0], 'Event', "Array of events");
}

done_testing();
