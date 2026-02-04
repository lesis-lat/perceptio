package Perceptio::Component::SentenceAnalysis;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Lexicon::Analyzer qw(calculate_sentence_analyses);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($sentences, $lexicon) = @_;
    return calculate_sentence_analyses($sentences, $lexicon);
}

1;
