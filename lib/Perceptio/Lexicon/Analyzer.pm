package Perceptio::Lexicon::Analyzer;

use strict;
use warnings;

use List::Util qw(sum);
use Exporter qw(import);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(
    tokenize_text
    calculate_polarity_analysis
    calculate_emotion_analysis
    calculate_sentence_analyses
);

sub tokenize_text {
    my ($text) = @_;
    my $normalized = lc( $text // q// );
    $normalized =~ s/[[:punct:]\d]+//gmsx;
    return [ grep { length } split /\s+/smx, $normalized ];
}

sub calculate_polarity_analysis {
    my ( $tokens, $lexicon ) = @_;
    my @found_words;

    for my $word ( @{$tokens} ) {
        if ( !exists $lexicon -> {$word} ) {
            next;
        }

        my $emotions     = $lexicon -> {$word};
        my $positive_val = $emotions -> {positive} // 0;
        my $negative_val = $emotions -> {negative} // 0;
        my $word_score   = $positive_val - $negative_val;

        if ( $word_score == 0 ) {
            next;
        }

        my $sentiment;
        if ( $word_score > 0 ) {
            $sentiment = 'positive';
        }
        if ( $word_score < 0 ) {
            $sentiment = 'negative';
        }

        push @found_words, {
            word      => $word,
            sentiment => $sentiment,
            score     => $word_score,
        };
    }

    my $total_score = sum( 0, map { $_ -> {score} } @found_words );

    return {
        score => $total_score,
        words => \@found_words,
    };
}

sub calculate_emotion_analysis {
    my ( $tokens, $lexicon ) = @_;
    my @found_words;

    for my $word ( @{$tokens} ) {
        if ( !exists $lexicon -> {$word} ) {
            next;
        }

        my $word_emotions = $lexicon -> {$word};
        if ( !%{$word_emotions} ) {
            next;
        }

        push @found_words, {
            word     => $word,
            emotions => $word_emotions,
        };
    }

    return { words => \@found_words };
}

sub calculate_sentence_analyses {
    my ( $sentences, $lexicon ) = @_;
    my @results;

    for my $sentence ( @{$sentences} ) {
        my $tokens          = tokenize_text($sentence);
        my $polarity_result = calculate_polarity_analysis( $tokens, $lexicon );
        my $emotion_result  = calculate_emotion_analysis( $tokens, $lexicon );

        push @results, {
            sentence       => $sentence,
            score          => $polarity_result -> {score},
            polarity_words => $polarity_result -> {words},
            emotion_words  => $emotion_result -> {words},
        };
    }
    return \@results;
}

1;
