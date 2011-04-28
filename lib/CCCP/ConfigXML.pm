package CCCP::ConfigXML;

use strict;
use warnings;

use Carp;
use XML::Bare;
use CCCP::ConfigXML::Attributes;
use overload '""' => sub {shift->{value}}, fallback => 1;

our $AUTOLOAD;
our $VERSION = '0.01';

$CCCP::ConfigXML::attr_class = 'CCCP::ConfigXML::Attributes';

sub new {
    my $class = shift;    
    return $class->__new(XML::Bare->new(@_)->parse());
}

sub __new {
    my $class = shift;
    my $val = shift;
    
    # если массив элементов
    if (ref $val eq 'ARRAY') {
        return [grep {UNIVERSAL::isa($_,$class)} map {$class->__new($_)} @$val];
    }
    
    # выгребем все вложенные элементы
    my @elemets_key = grep {
        not /^_/ and $_ ne 'value' and
        (
            (ref $val->{$_} eq 'HASH' and not $val->{$_}->{_att}) or ref $val->{$_} eq 'ARRAY'
         )
    } keys %$val;
    
    my $el_child = undef;
    if (@elemets_key) {
        my $tmp = {};
        foreach (@elemets_key) {
            my $ret = $class->__new($val->{$_});
            $tmp->{$_} = $ret if (UNIVERSAL::isa($ret,$class) or UNIVERSAL::isa($ret,'ARRAY'));
        };
        $el_child = bless($tmp, $class) if keys %$tmp;
    }
    
    # выгребем все аттрибуты
    my @attr = grep {
        not /^_/ and $_ ne 'value' and
        (
            (ref $val->{$_} eq 'HASH' and $val->{$_}->{_att}) and ref $val->{$_} ne 'ARRAY'
         )
    } keys %$val;
    
    my $el_attr = undef;
    if (@attr) {
        my $tmp = {};
        foreach (@attr) {
            my $ret = $CCCP::ConfigXML::attr_class->new({value => $val->{$_}->{value}});
            $tmp->{$_} = $ret if UNIVERSAL::isa($ret,$CCCP::ConfigXML::attr_class);
        };
        $el_attr = bless($tmp, $CCCP::ConfigXML::attr_class) if keys %$tmp;
    }
    
    my $ret = {};
    $ret->{value} = $val->{value} if exists $val->{value}; 
    $ret->{_attr}  = $el_attr if keys %$el_attr;
    $ret->{child} = $el_child if UNIVERSAL::isa($el_child,$class);
    
    bless($ret,$class);
}

sub _attr {shift->{_attr}}

sub DESTROY {}

sub AUTOLOAD {
    my $self = shift;
    my $class = ref $self or croak "$self is not an object";

    (my $name = $AUTOLOAD) =~ s/.*://;
        
    return undef unless (exists $self->{child} and exists $self->{child}->{$name});
    
    unless (@_) {
        return (UNIVERSAL::isa($self->{child}->{$name},$class) or UNIVERSAL::isa($self->{child}->{$name},'ARRAY')) ? $self->{child}->{$name} : undef;
    } else {        
        if (ref $self->{child}->{$name} eq 'ARRAY') {
            $self->{child}->{$name} = [map {$class->__new({value => $_})} @_];
        } else {
            $self->{child}->{$name} = $class->__new({value => shift});
        }
        return 1;
    };
}


1;
__END__
=encoding utf-8

=head1 NAME

CCCP::ConfigXML - Load XML config

=head1 SYNOPSIS

Load XML file. Example:

    <!-- some_config.xml -->
        <name>TestApp</name>
        <component name="Controller::Foo">
            <foo>bar</foo>
        </component>
        <model name="Baz">
            <qux>xyzzy</qux>
        </model>
        
        <foo>
            <bar>x1</bar>
            <bar>x2</bar>
            <bar>x3</bar>
            <bar>x4</bar>
        </foo>

In your code:

    use CCCP::ConfigXML;
    
    # like XML::Bare
    my $cnf = CCCP::ConfigXML->new( file => 'some_config.xml' );
    
    # or you can:
    my $cnf = CCCP::ConfigXML->new( text => $xml_string );
    
    # now, you can read
    $cnf->name;                   # TestApp
    $cnf->component->foo;         # bar
    $cnf->component->_attr->name; # Controller::Foo
    
    # and can set
    $cnf->name('NewTestApp');     # 1
    $cnf->name;                   # NewTestApp
    
    # loop element
    print "$_" for @{$cnf->foo->bar};
    
=head1 DESCRIPTION

Using L<XML::Bare> for parsing and B<AUTOLOAD> to access.

=head1 NOTE

Config is the basis of applications and values ​​in it are known in advance.
Config values ​​should not be checked for validity or existence.
Therefore, this module does not contain any verification of the existence of values​​.
Use only read access.

=head1 SEE ALSO

=over 4

=item *

L<XML::Bare>

=item *

test in t/ as example

=back

=head1 AUTHOR

Ivan Sivirinov E<lt>catamoose [at] yandex.ruE<gt>

=cut
