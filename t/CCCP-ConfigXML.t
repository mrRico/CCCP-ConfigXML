use strict;
use lib '../lib';

use Test::More;

    pass('*' x 10);
    
    use_ok('XML::Bare');
    use_ok('CCCP::ConfigXML');

    my $xml_str = '    <!-- some_config.xml -->
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
        
        ';

    can_ok('CCCP::ConfigXML', 'new');
    my $cnf = CCCP::ConfigXML->new(text => $xml_str);
    isa_ok($cnf, 'CCCP::ConfigXML');
    
    ok($cnf->name eq 'TestApp', 't1');
    is($cnf->name('NewTestApp'),1,'t2');
    ok($cnf->name eq 'NewTestApp', 't3');
    ok($cnf->component->foo eq 'bar', 't4');
    ok($cnf->component->_attr->name eq 'Controller::Foo', 't5');
    
    is(UNIVERSAL::isa($cnf->foo->bar,'ARRAY'),1,'t6');
    ok($cnf->foo->bar->[1] eq 'x2', 't7');

    pass('*' x 10);
    print "\n";
    done_testing;
    