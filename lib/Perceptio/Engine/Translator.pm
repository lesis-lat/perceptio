package Perceptio::Engine::Translator;

use strict;
use warnings;

use Carp 'croak';
use HTTP::Tiny;
use JSON::MaybeXS;
use Readonly;
use Try::Tiny;

our $VERSION = '0.0.1';

Readonly my $API_BASE_URL => 'https://translation.googleapis.com/language/translate/v3';

sub new {
    my ($class) = @_;

    my $api_key = $ENV{GOOGLE_API_KEY};
    if (!$api_key) {
        croak 'GOOGLE_API_KEY environment variable not set';
    }

    return bless {api_key => $api_key, http => HTTP::Tiny -> new}, $class;
}

sub translate_strings {
    my ($self, $texts, $target_lang, $source_lang) = @_;
    $source_lang //= 'en';

    if (!@{$texts}) {
        return [];
    }

    my $url = $API_BASE_URL . '?key=' . $self -> {api_key};
    my $json_body = JSON::MaybeXS -> new -> encode(
        {
            q      => $texts,
            source => $source_lang,
            target => $target_lang,
            format => 'text',
        }
    );

    my $response = $self -> {http} -> post(
        $url,
        {
            headers => {'Content-Type' => 'application/json'},
            content => $json_body,
        }
    );

    if (!$response -> {success}) {
        croak 'API request failed: '
            . $response -> {status}
            . q{ }
            . $response -> {reason};
    }

    my $decoded_response;
    try {
        $decoded_response = decode_json($response -> {content});
    }
    catch {
        croak "Failed to decode API response JSON: $_";
    };

    my $translations = $decoded_response -> {data}{translations}
        or croak 'Unexpected API response structure';

    return [map { $_ -> {translatedText} } @{$translations}];
}

sub translate_lexicon {
    my ($self, $lexicon, $target_lang) = @_;

    my @words = keys %{$lexicon};
    my $translated_words_ref = $self -> translate_strings(\@words, $target_lang);

    if (scalar @words != scalar @{$translated_words_ref}) {
        croak 'Translation returned a different number of words';
    }

    my %translated_lexicon;
    for my $i (0 .. $#words) {
        $translated_lexicon{$translated_words_ref -> [$i]} =
            $lexicon -> {$words[$i]};
    }

    return \%translated_lexicon;
}

sub translate_abbreviations {
    my ($self, $abbreviations_data, $target_lang) = @_;

    my $abbreviations_ref = $abbreviations_data -> {abbreviations} // [];
    my $translated_abbreviations_ref =
        $self -> translate_strings($abbreviations_ref, $target_lang);

    return {abbreviations => $translated_abbreviations_ref};
}

1;
