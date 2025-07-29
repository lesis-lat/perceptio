package Perceptio::Engine::Translator;

use strict;
use warnings;

use JSON::MaybeXS;
use HTTP::Tiny;
use URI::Escape 'uri_escape';

our $VERSION   = '0.0.1';

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub translate_lexicon {
    my ($self, $lexicon, $target_lang) = @_;

    my $translated_lexicon = {};
    my $http = HTTP::Tiny->new;

    for my $word (keys %{$lexicon}) {
        # placeholder
        my $escaped_word = uri_escape($word);
        my $response = $http->get(
            'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl='
            . $target_lang . '&dt=t&q=' . $escaped_word
        );

        if ($response->{success}) {
            my $json_response = decode_json($response->{content});
            # the structure of the free Google Translate API response is nested
            my $translated_word = $json_response->[0][0][0];
            $translated_lexicon->{$translated_word} = $lexicon->{$word};
        }
        else {
            warn "Failed to translate word: $word\n";
        }
    }

    return $translated_lexicon;
}

1;
