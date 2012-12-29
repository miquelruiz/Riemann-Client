package Riemann::Client;

use Moo;
use Net::Domain qw/hostfqdn/;

use Riemann::Client::Transport::TCP;
use Riemann::Client::Transport::UDP;

has host  => (is => 'ro',  default => sub { 'localhost' });
has port  => (is => 'ro',  default => sub { 5555 }       );
has proto => (is => 'rwp', default => sub { 'tcp' }      );

has transport => (is => 'rwp', lazy => 1, builder => 1);

sub send {
    my ($self, @opts) = @_;

    # Set default stuff
    map {
        $_->{host} = hostfqdn() unless defined $_->{host};
        $_->{time} = time()     unless defined $_->{time};
        $_->{metric_d} = delete $_->{metric} if $_->{metric};
    } @opts;

    return $self->transport->send({events => \@opts});
}

sub query {
    my ($self, $query) = @_;

    if (ref $self->transport eq 'Riemann::Client::Transport::UDP') {
        $self->_set_proto('tcp');
        $self->_set_transport($self->_build_transport);
    }

    return $self->transport->send({
        query => { string => $query }
    });
}

sub _build_transport {
    my $self  = shift;
    my $class = 'Riemann::Client::Transport::' . uc $self->proto;
    return $class->new(
        host    => $self->host,
        port    => $self->port,
    );
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
