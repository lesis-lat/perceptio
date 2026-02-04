package Perceptio::Component::ListLanguages;

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_match_vars);
use Exporter qw(import);
use FindBin;
use Readonly;

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

Readonly my $JSON_EXT_LENGTH => -5;

sub run {
    my $lexicons_dir = "$FindBin::Bin/resources/lexicons";
    opendir my $dh, $lexicons_dir
        or croak "Could not open directory '$lexicons_dir': $OS_ERROR";

    my @files = readdir $dh;
    closedir $dh;

    my @languages;
    for my $file (@files) {
        my $is_json = $file =~ /[.]json\z/smx;
        if ($is_json) {
            my $path = "$lexicons_dir/$file";
            if (-f $path) {
                my $language = substr $file, 0, $JSON_EXT_LENGTH;
                push @languages, $language;
            }
        }
    }

    my @sorted = sort @languages;
    my $output = 'Available languages: ' . join(', ', @sorted) . "\n";
    print $output or croak "Could not print languages: $OS_ERROR";

    return;
}

1;
