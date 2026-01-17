package Perceptio::Component::InputText;

use strict;
use warnings;

use Carp qw(croak);
use Exporter qw(import);
use File::Slurper 'read_text';
use Perceptio::Component::InterfaceInfo ();

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($ops) = @_;
    my $input = $ops -> {input};

    if ( !$input ) {
        my $info = Perceptio::Component::InterfaceInfo::run();
        croak "Error: --input <text_or_path> is required for analysis.\n" . $info;
    }

    if ( -f $input ) {
        return read_text($input);
    }

    return $input;
}

1;
