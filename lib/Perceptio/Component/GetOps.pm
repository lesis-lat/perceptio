package Perceptio::Component::GetOps;

use strict;
use warnings;

use Carp qw(croak);
use Exporter qw(import);
use Getopt::Long;
use Perceptio::Utils::Helper qw(get_interface_info);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my %ops;
    GetOptions(
        'analyze'              => \$ops{analyze},
        'auto'                 => \$ops{auto},
        'lang=s'               => \$ops{lang},
        'input=s'              => \$ops{input},
        'output=s'             => \$ops{output},
        'format=s'             => \$ops{format},
        'by-sentence'          => \$ops{by_sentence},
        'generate-resources:s' => \$ops{generate_resources},
        'overwrite'            => \$ops{overwrite},
        'list-languages'       => \$ops{list_languages},
        'help|h'               => \$ops{help},
    ) or croak get_interface_info();

    return \%ops;
}

1;
