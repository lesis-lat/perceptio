package Perceptio::Component::LexiconResources;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Lexicon::Loader;

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($lang) = @_;
    my $loader = Perceptio::Lexicon::Loader -> new;
    my $lexicon = $loader -> load_lexicon($lang);
    my $abbreviations = $loader -> load_abbreviations($lang);

    return {
        lexicon => $lexicon,
        abbreviations => $abbreviations,
    };
}

1;
