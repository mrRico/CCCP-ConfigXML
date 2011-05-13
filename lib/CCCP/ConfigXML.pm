package CCCP::ConfigXML;

use strict;
use warnings;

use namespace::autoclean;
use Carp;
use XML::Bare;
use Hash::Merge::Simple qw(merge);

our $VERSION = '0.02';

sub new {
    my ($class, %param) = @_;
    
    my @hashs = ();
    if ($param{files}) {
        croak "files must be arrayref" unless (UNIVERSAL::isa($param{files}, 'ARRAY') and @{$param{files}});
        push @hashs, map {XML::Bare->new(file => $_)->parse()} grep {-e $_ and -f _ and -s _} @{$param{files}};
    };
    if ($param{texts}) {
        croak "texts must be arrayref" unless (UNIVERSAL::isa($param{texts}, 'ARRAY') and @{$param{texts}});
        push @hashs, map {XML::Bare->new(text => $_)->parse()} grep {$_} @{$param{texts}};
    };
    croak "xml not found" unless @hashs;
    
    bless(merge(@hashs), $class);
}

1;
__END__
=encoding utf-8

=head1 NAME

CCCP::ConfigXML - Load XML config

=head1 SYNOPSIS

Load XML file. Example:

    # foo_config.xml
        <foo>
            <name>TestApp</name>
            <component name="Controller::Foo">
                <foo>bar</foo>
            </component>
            <model name="Baz">
                <qux>Waah!</qux>
            </model>
        </foo>
    # bar_config.xml    
        <bar>
            <val>x1</val>
            <val>x2</val>
            <val>x3</val>
            <val>x4</val>
        </bar>
    # baz_config.xml    
        <foo>
            <model name="Baz">
                <qux>Go!</qux>
            </model>
        </foo>
        
In your code:

    use CCCP::ConfigXML;
    
    # like XML::Bare
    my $cnf = CCCP::ConfigXML->new( file => ['foo_config.xml', 'bar_config.xml'] );
    
    # now, you can read
    $cnf->{foo}->{name}->{value};                        # TestApp
    $cnf->{foo}->{component}->{foo}->{value};            # bar
    $cnf->{foo}->{component}->{name}->{value};           # Controller::Foo    
    $cnf->{foo}->{model}->{qux}->{value}                 # Go! # overloading
    
=head1 DESCRIPTION

Simple and usefull wrapper on L<XML::Bare> and L<Hash::Merge::Simple>.

=cut
