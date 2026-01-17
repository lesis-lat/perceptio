package Perceptio::Component::DocumentFormatter;

use strict;
use warnings;

use Exporter qw(import);
use JSON::MaybeXS;

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ( $polarity_result, $emotion_result, $format ) = @_;
    my $output_str = q{};

    if ( $format eq 'json' ) {
        my $combined_result = {
            score => $polarity_result -> {score},
            words => $emotion_result -> {words},
        };
        my $json = JSON::MaybeXS -> new( pretty => 1, canonical => 1 );
        $output_str = $json -> encode($combined_result);
        return $output_str;
    }

    $output_str = "Sentiment Score: $polarity_result -> {score}\n";
    my $words = $polarity_result -> {words};
    if ( @{$words} ) {
        $output_str .= "Matched Words:\n";
        for my $entry ( @{$words} ) {
            $output_str .=
              "  - Word: '$entry -> {word}', Sentiment: $entry -> {sentiment}, Score: $entry -> {score}\n";
        }
    }

    return $output_str;
}

1;
