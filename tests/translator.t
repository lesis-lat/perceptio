#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::MockModule;
use JSON::MaybeXS;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Perceptio::Engine::Translator;

our $VERSION = '0.0.1';

subtest 'Constructor' => sub {
    local $ENV{GOOGLE_API_KEY} = undef;

    dies_ok { Perceptio::Engine::Translator->new() }
    'new() croaks when GOOGLE_API_KEY is not set';

    local $ENV{GOOGLE_API_KEY} = 'test_key_123';
    my $translator = Perceptio::Engine::Translator->new;
    isa_ok( $translator, 'Perceptio::Engine::Translator',
        'new() creates a valid Translator object when GOOGLE_API_KEY is set' );
};

subtest 'Lexicon Translation' => sub {
    my $mock_http_module = Test::MockModule->new('HTTP::Tiny');
    $mock_http_module->mock(
        'post',
        sub {
            my ( $self, $url, $options ) = @_;

            my $request_body = decode_json( $options->{content} );
            my @words_to_translate = @{ $request_body->{q} };

            my %mock_translations = (
                happy => 'feliz',
                sad   => 'triste',
            );
            my @translated_items;
            for my $word (@words_to_translate) {
                if ( exists $mock_translations{$word} ) {
                    push @translated_items, { translatedText => $mock_translations{$word} };
                }
            }

            my $response_data = {
                data => {
                    translations => \@translated_items
                }
            };
            return {
                success => 1,
                status  => 200,
                content => encode_json($response_data),
            };
        }
    );

    local $ENV{GOOGLE_API_KEY} = 'test_key_123';
    my $translator = Perceptio::Engine::Translator->new;

    my $en_lexicon = {
        happy => { sentiment => 'positive', weight => 1 },
        sad   => { sentiment => 'negative', weight => -1 },
    };

    my $translated = $translator->translate_lexicon( $en_lexicon, 'pt' );

    is_deeply(
        $translated,
        {
            feliz  => { sentiment => 'positive', weight => 1 },
            triste => { sentiment => 'negative', weight => -1 },
        },
        'translate_lexicon correctly translates words in a batch and preserves weights'
    );
};

subtest 'Abbreviations Translation' => sub {
    my $mock_http_module = Test::MockModule->new('HTTP::Tiny');
    $mock_http_module->mock(
        'post',
        sub {
            my $response_data = {
                data => {
                    translations => [
                        { translatedText => 'Rindo Alto' },
                        { translatedText => 'Volto Logo' },
                    ]
                }
            };
            return {
                success => 1,
                status  => 200,
                content => encode_json($response_data),
            };
        }
    );

    local $ENV{GOOGLE_API_KEY} = 'test_key_123';
    my $translator = Perceptio::Engine::Translator->new;

    my $abbreviations_data = {
        abbreviations => [ 'LOL', 'BRB' ]
    };

    my $translated = $translator->translate_abbreviations( $abbreviations_data, 'pt' );

    is_deeply(
        $translated,
        {
            abbreviations => [ 'Rindo Alto', 'Volto Logo' ]
        },
        'translate_abbreviations correctly translates a list of strings'
    );
};

done_testing();
