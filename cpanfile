requires 'JSON::MaybeXS',       '1.004008';
requires 'Getopt::Long',        '2.58';
requires 'File::Slurper',       '0.014';
requires 'List::Util',          '1.69';
requires 'Encode',              '3.21';
requires 'Const::Fast',         '0.014';
requires 'HTTP::Tiny',          '0.090';

on 'test' => sub {
requires 'Test::More',          '1.302214';
requires 'Test::Exception',     '0.43';
requires 'Test::MockObject',    '1.20200122';
requires 'Test::MockModule',    '0.180.0';
};
