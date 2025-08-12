#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Readonly;

use lib '../lib/';

use Perceptio::Lexicon::Analyzer qw(
    tokenize_text
    calculate_polarity_analysis
    calculate_emotion_analysis
);

our $VERSION = '0.0.1';

Readonly my $POLARITY_LEXICON => {
    good      => { positive => 1,   negative => 0 },
    excellent => { positive => 1.5, negative => 0 },
    bad       => { positive => 0,   negative => 1 },
    terrible  => { positive => 0,   negative => 1.5 },
    'so-so'   => { positive => 0.5, negative => 0.5 },
};

Readonly my $EMOTION_LEXICON => {
    happy   => { joy => 1,   positive => 0.8 },
    love    => { joy => 1.5, positive => 1.2, anticipation => 0.5 },
    sad     => { sadness => 1,   negative => 0.8 },
    furious => { anger => 1.5, negative => 1.2 },
    scared  => { fear => 1,    negative => 0.9 },
};

Readonly my $EXPECTED_POSITIVE_SCORE => 2.5;
Readonly my $EXPECTED_NEGATIVE_SCORE => -2.5;

subtest 'tokenize_text Function' => sub {
    is_deeply(tokenize_text('This is a test'), ['this', 'is', 'a', 'test'], 'Correctly tokenizes a simple sentence');
    is_deeply(tokenize_text('This IS a TeSt'), ['this', 'is', 'a', 'test'], 'Correctly handles case normalization');
    is_deeply(tokenize_text('Hello, world! How are you?'), ['hello', 'world', 'how', 'are', 'you'], 'Correctly removes punctuation');
    is_deeply(tokenize_text('Item 1 and Item 2'), ['item', 'and', 'item'], 'Correctly removes digits');
    is_deeply(tokenize_text("  leading and\ttrailing spaces  "), ['leading', 'and', 'trailing', 'spaces'], 'Correctly handles various whitespace');
    is_deeply(tokenize_text(q//), [], 'Returns an empty list for an empty string');
    is_deeply(tokenize_text(undef), [], 'Returns an empty list for undef input');
};

subtest 'calculate_polarity_analysis Function' => sub {
    my $tokens_pos = tokenize_text('This is a good and excellent test');
    my $result_pos = calculate_polarity_analysis($tokens_pos, $POLARITY_LEXICON);
    is($result_pos->{score}, $EXPECTED_POSITIVE_SCORE, 'Correctly calculates a purely positive score');
    is_deeply(
        $result_pos->{words},
        [
            { word => 'good',      sentiment => 'positive', score => 1 },
            { word => 'excellent', sentiment => 'positive', score => 1.5 },
        ],
        'Correctly identifies all positive words and their polarity'
    );

    my $tokens_neg = tokenize_text('This is a bad and terrible test');
    my $result_neg = calculate_polarity_analysis($tokens_neg, $POLARITY_LEXICON);
    is($result_neg->{score}, $EXPECTED_NEGATIVE_SCORE, 'Correctly calculates a purely negative score');
    is_deeply(
        $result_neg->{words},
        [
            { word => 'bad',      sentiment => 'negative', score => -1 },
            { word => 'terrible', sentiment => 'negative', score => -1.5 },
        ],
        'Correctly identifies all negative words and their polarity'
    );

    my $tokens_mixed = tokenize_text('This test is good, but also bad.');
    my $result_mixed = calculate_polarity_analysis($tokens_mixed, $POLARITY_LEXICON);
    is($result_mixed->{score}, 0, 'Correctly calculates a mixed score that results in zero');

    my $tokens_neutral_word = tokenize_text('The movie was so-so');
    my $result_neutral_word = calculate_polarity_analysis($tokens_neutral_word, $POLARITY_LEXICON);
    is($result_neutral_word->{score}, 0, 'Returns score of 0 for neutral words');
    is_deeply($result_neutral_word->{words}, [], 'Neutral words are not included in the final word list');

    my $tokens_none = tokenize_text('A sentence with no keywords.');
    my $result_none = calculate_polarity_analysis($tokens_none, $POLARITY_LEXICON);
    is($result_none->{score}, 0, 'Returns a score of 0 for text with no matching words');
    is_deeply($result_none->{words}, [], 'Returns an empty word list for text with no matching words');

    my $result_empty = calculate_polarity_analysis([], $POLARITY_LEXICON);
    is($result_empty->{score}, 0, 'Returns a score of 0 for an empty token list');
    is_deeply($result_empty->{words}, [], 'Returns an empty word list for an empty token list');
};

subtest 'calculate_emotion_analysis Function' => sub {
    my $tokens_pos = tokenize_text('Feeling happy and full of love');
    my $result_pos = calculate_emotion_analysis($tokens_pos, $EMOTION_LEXICON);

    is_deeply(
        $result_pos->{words},
        [
            { word => 'happy', emotions => { joy => 1,   positive => 0.8 } },
            { word => 'love',  emotions => { joy => 1.5, positive => 1.2, anticipation => 0.5 } },
        ],
        'Correctly identifies all emotion words in order'
    );
    is_deeply(
        $result_pos->{emotions},
        {
            joy          => 2.5,
            positive     => 2.0,
            anticipation => 0.5,
        },
        'Correctly aggregates positive emotion scores'
    );

    my $tokens_neg = tokenize_text('He was sad and scared');
    my $result_neg = calculate_emotion_analysis($tokens_neg, $EMOTION_LEXICON);
    is_deeply(
        $result_neg->{emotions},
        {
            sadness  => 1,
            negative => 1.7,
            fear     => 1,
        },
        'Correctly aggregates negative emotion scores'
    );
    my $tokens_none = tokenize_text('A neutral sentence');
    my $result_none = calculate_emotion_analysis($tokens_none, $EMOTION_LEXICON);
    is_deeply($result_none->{emotions}, {}, 'Returns an empty emotions hash for text with no matching words');
    is_deeply($result_none->{words}, [], 'Returns an empty word list for text with no matching words');

    my $result_empty = calculate_emotion_analysis([], $EMOTION_LEXICON);
    is_deeply($result_empty->{emotions}, {}, 'Returns an empty emotions hash for an empty token list');
    is_deeply($result_empty->{words}, [], 'Returns an empty word list for an empty token list');
};

done_testing();
