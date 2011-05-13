use strict;
use lib '../lib';

use Test::More;

    pass('*' x 10);
    
    use_ok('XML::Bare');
    use_ok('CCCP::ConfigXML');

    my $foo_xml = '
        <foo>
            <name>TestApp</name>
            <component name="Controller::Foo">
                <foo>bar</foo>
            </component>
            <model name="Baz">
                <qux>xyzzy</qux>
            </model>
        </foo>';
        
    my $bar_xml = '    
        <bar>
            <val>x1</val>
            <val>x2</val>
            <val>x3</val>
            <val>x4</val>
        </bar>';
    
    my $baz_xml = ' 
         <foo>
            <model name="Baz">
                <qux>Go!</qux>
            </model>
        </foo>';
    
    can_ok('CCCP::ConfigXML', 'new');
    my $cnf = CCCP::ConfigXML->new(texts => [$foo_xml, $bar_xml, $baz_xml]);
    isa_ok($cnf, 'CCCP::ConfigXML');
    
    ok($cnf->{foo}->{name}->{value} eq 'TestApp', 't1');
    ok($cnf->{foo}->{component}->{foo}->{value} eq 'bar', 't2');
    ok($cnf->{foo}->{model}->{qux}->{value} eq 'Go!', 't3');
    
    pass('*' x 10);
    print "\n";
    done_testing;
    