requires 'JSON::MaybeXS',       '1.004008';
requires 'Getopt::Long',        '2.58';
requires 'File::Slurper',       '0.014';
requires 'List::Util', '1.70';
requires 'Encode', '3.24';
requires 'Const::Fast',         '0.014';
requires 'HTTP::Tiny', '0.096';
requires 'Lingua::Identify',    '0.56';

on 'test' => sub {
requires 'Test::More', '1.302219';
requires 'Test::Exception',     '0.43';
requires 'Test::MockObject',    '1.20200122';
requires 'Test::MockModule', 'v0.185.2';
requires 'Readonly',            '2.05';
requires 'Try::Tiny',           '0.32';

};