package Perceptio::Component::OutputWriter;

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_match_vars);
use Exporter qw(import);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($output_str, $output_path) = @_;

    if ($output_path) {
        open my $fh, '>', $output_path
            or croak "Could not open file '$output_path' for writing: $OS_ERROR";
        print {$fh} $output_str
            or croak "Could not write to file '$output_path': $OS_ERROR";
        close $fh
            or croak "Could not close file '$output_path': $OS_ERROR";
        return;
    }

    print $output_str or croak "Could not print results: $OS_ERROR";

    return;
}

1;
