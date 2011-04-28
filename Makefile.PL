use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'CCCP::ConfigXML',
    VERSION_FROM      => 'lib/CCCP/ConfigXML.pm',
    PREREQ_PM         => {
        'XML::Bare' => 0,
        'Carp'      => 0
    },
    ($] >= 5.005 ? (ABSTRACT_FROM  => 'lib/CCCP/ConfigXML.pm') : ()),
);
