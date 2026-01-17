package Perceptio::Component::DocumentAnalysis;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Lexicon::Analyzer qw(
    tokenize_text
    calculate_polarity_analysis
    calculate_emotion_analysis
);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ( $text, $lexicon ) = @_;
    my $tokens = tokenize_text($text);
    my $polarity_result = calculate_polarity_analysis( $tokens, $lexicon );
    my $emotion_result = calculate_emotion_analysis( $tokens, $lexicon );

    return {
        polarity => $polarity_result,
        emotion => $emotion_result,
    };
}

1;
