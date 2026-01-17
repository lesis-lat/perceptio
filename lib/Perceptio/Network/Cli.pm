package Perceptio::Network::Cli;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Component::GenerateResources ();
use Perceptio::Component::GetOps ();
use Perceptio::Component::InterfaceInfo ();
use Perceptio::Component::ListLanguages ();
use Perceptio::Component::OutputWriter ();
use Perceptio::Network::Analysis ();

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my $ops = Perceptio::Component::GetOps::run();

    if ( $ops -> {help} ) {
        my $info = Perceptio::Component::InterfaceInfo::run();
        Perceptio::Component::OutputWriter::run($info);
        return 0;
    }

    if ( defined $ops -> {generate_resources} ) {
        Perceptio::Component::GenerateResources::run($ops);
        return 0;
    }

    if ( $ops -> {list_languages} ) {
        Perceptio::Component::ListLanguages::run();
        return 0;
    }

    if ( $ops -> {analyze} ) {
        Perceptio::Network::Analysis::run($ops);
        return 0;
    }

    my $info = Perceptio::Component::InterfaceInfo::run();
    Perceptio::Component::OutputWriter::run($info);

    return 0;
}

1;
