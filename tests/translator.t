#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::MockObject;
use Test::MockModule;
use JSON::MaybeXS;

use FindBin;
use lib '../lib/';

use Perceptio::Engine::Translator;

our $VERSION = '0.0.1';

my $translator = Perceptio::Engine::Translator->new;
isa_ok($translator, 'Perceptio::Engine::Translator', 'new() creates a valid Translator object');

subtest 'Lexicon Translation' => sub {
    my $mock_http = Test::MockObject->new();
    $mock_http->mock('get', sub {
        my ($self, $url) = @_;
        my ($word_to_translate) = $url =~ /q=([^&]+)/smx;
        my $translated_word = 'unknown';
        if ( $word_to_translate eq 'happy' ) { $translated_word = 'feliz'; }
        if ( $word_to_translate eq 'sad' )   { $translated_word = 'triste'; }
        my $response_data = [
            [
                [
                    $translated_word,
                    $word_to_translate,
                    undef,
                    undef,
                    1
                ]
            ],
            undef,
            'en',
        ];
        return {
            success => 1,
            status  => 200,
            content => encode_json($response_data),
        };
    });

    my $mock_module = Test::MockModule->new('HTTP::Tiny');
    $mock_module->mock('new', sub {$mock_http});

    my $en_lexicon = {
        happy => { sentiment => 'positive', weight => 1 },
        sad   => { sentiment => 'negative', weight => -1 },
    };

    my $translated = $translator->translate_lexicon($en_lexicon, 'pt');

    is_deeply($translated, {
        feliz  => { sentiment => 'positive', weight => 1 },
        triste => { sentiment => 'negative', weight => -1 },
    }, 'translate_lexicon correctly translates words and preserves weights');
};

done_testing();
