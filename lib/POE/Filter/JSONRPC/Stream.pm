#!/usr/bin/perl

package POE::Filter::JSONRPC::Stream;
use Moose;

use JSON::RPC::Common::Message;
use JSON::RPC::Common::Procedure::Call;
use JSON::RPC::Common::Procedure::Return;

use namespace::clean -except => [qw(meta)];

extends our @ISA, qw(POE::Filter);

with qw(MooseX::Clone);

has buffer => (
	traits => [qw(NoClone)],
	isa => "ArrayRef",
	is  => "rw",
	lazy_build => 1,
);

sub _build_buffer { [] }

sub get_one_start {
	my ( $self, $chunks ) = @_;
	$chunks = [ $chunks ] unless ref $chunks;
	push @{ $self->buffer }, $self->_inflate($chunks);
}

sub get_one {
	my $self = shift;

	return [ splice @{ $self->buffer }, 0, 1 ]; # shift returns undef, this returns empty list
}

sub get {
	my ( $self, $chunks ) = @_;

	return [
		splice(@{ $self->buffer }),
		$self->_inflate($chunks),
	];
}

sub _inflate {
	my ( $self, $chunks ) = @_;

	local $@;
	map { ( blessed($_) ? $_->error : ( eval { JSON::RPC::Common::Message->inflate($_) } || $@ ) ) } @$chunks;
}

sub put {
	my ( $self, $msgs ) = @_;
	return [ map { $_->deflate } @$msgs ];
}


sub get_pending {
	my $self = shift;

	if ( my @contents = @{ $self->buffer } ) {
		return \@contents;
	} else {
		return undef;
	}
}

__PACKAGE__

__END__

=pod

=head1 NAME

POE::Filter::JSONRPC::Stream - 

=head1 SYNOPSIS

	use POE::Filter::JSONRPC::Stream;

=head1 DESCRIPTION

=cut


