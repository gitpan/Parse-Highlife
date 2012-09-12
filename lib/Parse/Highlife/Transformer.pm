package Parse::Highlife::Transformer;

use strict;
use Parse::Highlife::Utils qw(params);
use Data::Dump qw(dump);

sub new
{
	my( $class, @args ) = @_;
	my $self = bless {}, $class;
	return $self -> _init( @args );
}

sub _init
{
	my( $self, @args ) = @_;
	$self->{'transformers'} = {};
	return $self;
}

sub transformer
{
	my( $self, $name, $coderef )
		= params( \@_, 
				-rule => '',
				-fn => sub {},
			);
	$self->{'transformers'}->{$name} = $coderef;
	return 1;
}

sub transform
{
	my( $self, $ast, @params ) = @_;
	
	my $transformer_name = $ast->{'rulename'};
	#print "-- TRANSFORM $transformer_name --\n";
	
	if( exists $self->{'transformers'}->{$transformer_name} ) {
		my $new_ast = $self->{'transformers'}->{$transformer_name}->( $self, $ast, @params );
		return ( defined $new_ast && ref $new_ast eq 'Parse::Highlife::AST' ? $new_ast : $ast );
	}
	else {
		return $self->transform_children( $ast, @params );
	}
}

sub transform_children
{
	my( $self, $ast, @params ) = @_;
	if( $ast->{'category'} eq 'group' ) {
		$ast->{'children'} = 
			[
				map { $self->transform( $_, @params ) } @{$ast->{'children'}}
			];
	}
	# leaf's are not transformed by default
	return $ast;
}

1;

