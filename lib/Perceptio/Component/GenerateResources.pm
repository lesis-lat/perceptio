package Perceptio::Component::GenerateResources;

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_match_vars);
use Exporter qw(import);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($ops) = @_;
    my @args = ( 'perl', 'scripts/generate-resources.pl' );
    my $type = $ops -> {generate_resources};

    if ( !$type ) {
        $type = 'all';
    }

    push @args, '--type', $type;

    if ( $ops -> {overwrite} ) {
        push @args, '--overwrite';
    }

    my $result = system(@args);
    if ( $result != 0 ) {
        croak "Resource generation script failed with status: $CHILD_ERROR";
    }

    return;
}

1;
