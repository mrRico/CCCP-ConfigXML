package CCCP::ConfigXML::Attributes;

use strict;
use warnings;

use Carp;
use overload '""' => sub {shift->{value}}, fallback => 1;

our $VERSION = '0.01';
our $AUTOLOAD;

sub new {
    my $class = shift;
    my $hash_attr = shift || {};
    
    bless $hash_attr, $class;
}

sub DESTROY {}

sub AUTOLOAD {
    my $self = shift;
    my $class = ref $self or croak "$self is not an object";

    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    
    return exists $self->{$name} ? $self->{$name} : undef; 
}

1;
__END__
