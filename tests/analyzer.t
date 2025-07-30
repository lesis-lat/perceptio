#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Readonly;

use lib '../lib/';

use Perceptio::Lexicon::Analyzer;

our $VERSION = '0.0.1';

Readonly my $EXPECTED_POSITIVE_SCORE => 2.5;
Readonly my $EXPECTED_NEGATIVE_SCORE => -2.5;
Readonly my $TERRIBLE_SCORE          => -1.5;

my $mock_lexicon = {
    good      => { positive => 1,   negative => 0 },
    excellent => { positive => 1.5, negative => 0 },
    bad       => { positive => 0,   negative => 1 },
    terrible  => { positive => 0,   negative => 1.5 },
};

my $analyzer = Perceptio::Lexicon::Analyzer->new;
isa_ok($analyzer, 'Perceptio::Lexicon::Analyzer', 'new() creates a valid Analyzer object');

subtest 'Core Sentiment Scoring Logic' => sub {
    my $result_pos = $analyzer->analyze_sentiment('This is a good and excellent test', $mock_lexicon);
    is($result_pos->{score}, $EXPECTED_POSITIVE_SCORE, 'Correctly calculates a purely positive score');

    is_deeply(
        $result_pos->{words},
        [
            { word => 'good',      emotions => { positive => 1,   negative => 0 } },
            { word => 'excellent', emotions => { positive => 1.5, negative => 0 } },
        ],
        'Correctly identifies all positive words and their emotions in order'
    );

    my $result_neg = $analyzer->analyze_sentiment('This is a bad and terrible test', $mock_lexicon);
    is($result_neg->{score}, $EXPECTED_NEGATIVE_SCORE, 'Correctly calculates a purely negative score');

    my $result_mixed = $analyzer->analyze_sentiment('This test is good, but also bad.', $mock_lexicon);
    is($result_mixed->{score}, 0, 'Correctly calculates a mixed score that results in zero');

    is_deeply(
        $result_mixed->{words},
        [
            { word => 'good', emotions => { positive => 1, negative => 0 } },
            { word => 'bad',  emotions => { positive => 0, negative => 1 } },
        ],
        'Correctly identifies all words and emotions in a mixed-sentiment text'
    );
};

subtest 'Input Normalization and Cleaning' => sub {
    my $result_case = $analyzer->analyze_sentiment('This test is GOOD!', $mock_lexicon);
    is($result_case->{score}, 1, 'Analysis is case-insensitive');

    is_deeply(
        $result_case->{words},
        [ { word => 'good', emotions => { positive => 1, negative => 0 } } ],
        'Identifies case-insensitive word and normalizes it'
    );

    my $result_punct = $analyzer->analyze_sentiment('This is terrible.', $mock_lexicon);
    is($result_punct->{score}, $TERRIBLE_SCORE, 'Correctly handles trailing punctuation');

    is_deeply(
        $result_punct->{words},
        [ { word => 'terrible', emotions => { positive => 0, negative => 1.5 } } ],
        'Identifies word correctly when followed by a period'
    );

    my $result_quotes = $analyzer->analyze_sentiment('"good"', $mock_lexicon);
    is($result_quotes->{score}, 1, 'Correctly handles surrounding punctuation (quotes)');
};

subtest 'Edge Cases' => sub {
    my $result_none = $analyzer->analyze_sentiment('This is a neutral sentence with no keywords.', $mock_lexicon);
    is($result_none->{score}, 0, 'Returns a score of 0 for text with no matching words');
    is_deeply($result_none->{words}, [], 'Returns an empty word list for text with no matching words');

    my $result_empty = $analyzer->analyze_sentiment(q//, $mock_lexicon);
    is($result_empty->{score}, 0, 'Returns a score of 0 for an empty input string');
    is_deeply($result_empty->{words}, [], 'Returns an empty word list for an empty input string');

    my $result_undef = $analyzer->analyze_sentiment(undef, $mock_lexicon);
    is($result_undef->{score}, 0, 'Returns a score of 0 for undefined input');
    is_deeply($result_undef->{words}, [], 'Returns an empty word list for undefined input');
};

done_testing();
