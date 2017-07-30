# NAME

Riemann::Client - A Perl client for the Riemann event system

<div>
    <a href="https://travis-ci.org/miquelruiz/Riemann-Client"><img src="https://travis-ci.org/miquelruiz/Riemann-Client.svg?branch=master"></a>
</div>

# SYNOPSIS

    use Riemann::Client;

    # host and port are optional
    my $r = Riemann::Client->new(
        host => 'localhost',
        port => 5555,
    );

    # send a simple event
    $r->send({service => 'testing', metric => 2.5});

    # Or a more complex one
    $r->send({
        host    => 'web3', # defaults to Net::Domain::hostfqdn()
        service => 'api latency',
        state   => 'warn',
        tags    => ['api', 'backend'],
        metric  => 63.5,
        time    => time() - 10, # defaults to time()
        description => '63.5 milliseconds per request',
    });

    # send several events at once
    my @events = (
        { service => 'service1', ... },
        { service => 'service2', ... },
    );
    $r->send(@events);

    # Get all the states from the server
    my $res = $r->query('true');

    # Or specific states matching a query
    $res = $r->query('host =~ "%.dc1" and state = "critical"');

# DESCRIPTION

Riemann::Client sends events and/or queries to a Riemann server.

# METHODS

## new

Returns an instance of the Riemann::Client. These are the optional arguments
accepted:

### host

The Riemann server. Defaults to `localhost`

### port

Port where the Riemann server is listening. Defaults to `5555`

### proto

By default Riemann::Client will use TCP to communicate over the network. You
can force the usage of UDP setting this argument to 'udp'.
UDP datagrams have a maximum size of 16384 bytes by Riemann's default. If you
force the usage of UDP and try to send a larger message, an exception will be
raised.
In TCP mode, the client will try to reconnect to the server in case the
connection is lost.

## send

Accepts a list of events (as hashrefs) and sends them over the wire to the
server. In TCP mode, it will die if there are errors while communicating with
the server. In case the connection is lost, it will try to reconnect.

## query

Accepts a string and returns a message.

# MESSAGE SPECS

The specification of the messages in [Google::ProtocolBuffers](https://metacpan.org/pod/Google::ProtocolBuffers) format is at:
[https://github.com/riemann/riemann-java-client/blob/master/riemann-java-client/src/main/proto/riemann/proto.proto](https://github.com/riemann/riemann-java-client/blob/master/riemann-java-client/src/main/proto/riemann/proto.proto)

# SEE ALSO

- All About Riemann [http://riemann.io/](http://riemann.io/)
- Ruby client [https://github.com/riemann/riemann-ruby-client](https://github.com/riemann/riemann-ruby-client)

# AUTHOR

- Miquel Ruiz <mruiz@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Miquel Ruiz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
