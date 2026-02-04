package Perceptio::Component::SentenceFormatter;

use strict;
use warnings;

use Exporter qw(import);
use JSON::MaybeXS;

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($results, $format) = @_;
    my $output_str = q{};

    if ($format eq 'json') {
        my @json_results;
        for my $entry (@{$results}) {
            push @json_results, {
                sentence => $entry -> {sentence},
                score    => $entry -> {score},
                words    => $entry -> {emotion_words},
            };
        }
        my $json = JSON::MaybeXS -> new(pretty => 1, canonical => 1);
        $output_str = $json -> encode(\@json_results);
        return $output_str;
    }

    my @lines;
    my $index = 0;
    for my $entry (@{$results}) {
        my $sentence_num = $index + 1;
        my $line = 'Sentence '
            . $sentence_num
            . ': "'
            . $entry -> {sentence}
            . "\"\n";
        $line .= '  Sentiment Score: ' . $entry -> {score} . "\n";

        my $polarity_words = $entry -> {polarity_words};
        if (@{$polarity_words}) {
            $line .= "  Matched Words:\n";
            for my $word_entry (@{$polarity_words}) {
                $line .= '    - Word: \''
                    . $word_entry -> {word}
                    . '\', Sentiment: '
                    . $word_entry -> {sentiment}
                    . ', Score: '
                    . $word_entry -> {score}
                    . "\n";
            }
        }

        push @lines, $line;
        $index = $index + 1;
    }

    $output_str = join "---\n", @lines;

    return $output_str;
}

1;
