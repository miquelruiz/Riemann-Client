package Riemann::Client;

use strict;
use warnings;

use Moo;
use Sub::Quote;

use IO::Socket::INET;
use Net::Domain qw/hostfqdn/;
use Riemann::Client::Protocol;

use constant MAX_DTGRM_SIZE => 16384;

has host      => (is => 'ro', default => sub { 'localhost' });
has port      => (is => 'ro', default => sub { 5555 }       );
has transport => (is => 'ro', default => sub { 'tcp' }      );

has udp_sock => (is => 'lazy');
has tcp_sock => (is => 'lazy');

sub send {
    my ($self, %opts) = @_;

    # Set default stuff
    $opts{host} = hostfqdn() unless defined $opts{host};
    $opts{time} = time()     unless defined $opts{time};
    $opts{metric_d} = delete $opts{metric} if $opts{metric};

    # Encode the message
    my $msg = Msg->encode({ events => [\%opts] });
    my $l = length $msg;

    # Select a socket depending on msg size
    my $sock = 'tcp_sock';
    if ($self->transport eq 'udp') {
        if ($l > MAX_DTGRM_SIZE) {
            warn "Msg is $l bytes long, but udp selected."
              . " Falling back to TCP\n";
        } else {
            $sock = 'udp_sock';
        }
    }

    return $self->_send_recv($self->$sock, $msg);
}

sub query {
    my ($self, $query) = @_;
    my $msg = Msg->encode({query => {string => $query}});

    my $res = $self->_send_recv($self->tcp_sock, $msg);
    return $res->{events};
}

sub _send_recv {
    my ($self, $sock, $msg) = @_;

    # Prepend the binary message with its length
    $msg = pack('N', length $msg) . $msg;
    print $sock $msg or die $!;

    # Read 4 bytes of the response to get the length
    my $l;
    my $r = read $sock, $l, 4;
    die $! unless defined $r;
    $l = unpack('N', $l);

    # Read the actual response message
    $r = read $sock, $msg, $l;
    die $! unless defined $r;

    $msg = Msg->decode($msg);
    die $msg->{error} unless $msg->{ok};

    return $msg;
}

sub _build_udp_sock {
    return shift->_build_socket('udp');
}

sub _build_tcp_sock {
    return shift->_build_socket('tcp');
}

sub _build_socket {
    my $self = shift;

    my $sock = IO::Socket::INET->new(
        PeerAddr => $self->host,
        PeerPort => $self->port,
        Proto    => shift,
    ) or die $!;

    return $sock;
}

sub DEMOLISH {
    my $self = shift;

    # Close the socket properly on destruction
    close $self->tcp_sock;
}

1;

__END__

=pod

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

=over 4

=item *
Miquel Ruiz <mruiz@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Miquel Ruiz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
