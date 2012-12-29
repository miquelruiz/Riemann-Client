package # hide from CPAN
    Riemann::Client::Transport;

use Moo;
use IO::Socket::INET;

has host   => (is => 'ro', required => 1);
has port   => (is => 'ro', required => 1);
has socket => (is => 'lazy');

sub send {
    die 'Not implemented';
}

sub _build_socket {
    my $self  = shift;

    my @elems = split /::/, __PACKAGE__;
    my $proto = $elems[-1];

    my $sock = IO::Socket::INET->new(
        PeerAddr => $self->host,
        PeerPort => $self->port,
        Proto    => shift,
    ) or die $!;

    return $sock;
}

1;
