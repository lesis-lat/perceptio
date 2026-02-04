package Perceptio::Network::Analysis;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Component::DocumentAnalysis ();
use Perceptio::Component::DocumentFormatter ();
use Perceptio::Component::InputText ();
use Perceptio::Component::LanguageDetect ();
use Perceptio::Component::LexiconResources ();
use Perceptio::Component::OutputWriter ();
use Perceptio::Component::SentenceAnalysis ();
use Perceptio::Component::SentenceFormatter ();
use Perceptio::Component::SentenceSplitter ();

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($ops) = @_;

    my $format = $ops -> {format};
    if (!$format) {
        $format = 'plain';
    }

    my $text = Perceptio::Component::InputText::run($ops);
    my $lang = Perceptio::Component::LanguageDetect::run($ops, $text);
    my $resources = Perceptio::Component::LexiconResources::run($lang);
    my $lexicon = $resources -> {lexicon};

    if ($ops -> {by_sentence}) {
        my $sentences = Perceptio::Component::SentenceSplitter::run(
            $text,
            $resources -> {abbreviations},
        );
        my $results = Perceptio::Component::SentenceAnalysis::run($sentences, $lexicon);
        my $output_str = Perceptio::Component::SentenceFormatter::run($results, $format);
        Perceptio::Component::OutputWriter::run($output_str, $ops -> {output});
        return;
    }

    my $analysis = Perceptio::Component::DocumentAnalysis::run($text, $lexicon);
    my $output_str = Perceptio::Component::DocumentFormatter::run(
        $analysis -> {polarity},
        $analysis -> {emotion},
        $format,
    );
    Perceptio::Component::OutputWriter::run($output_str, $ops -> {output});

    return;
}

1;
