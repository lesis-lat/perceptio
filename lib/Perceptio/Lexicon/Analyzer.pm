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
);

sub tokenize_text {
    my ($text) = @_;
    my $normalized = lc $text;
    $normalized =~ s/[[:punct:]\d]+//gmsx;
    return [ grep { length } split /\s+/smx, $normalized ];
}

sub calculate_polarity_analysis {
    my ( $tokens, $lexicon ) = @_;
    my @found_words;

    for my $word ( @{$tokens} ) {
        if ( !exists $lexicon->{$word} ) {
            next;
        }

        my $emotions     = $lexicon->{$word};
        my $positive_val = $emotions->{positive} // 0;
        my $negative_val = $emotions->{negative} // 0;
        my $word_score   = $positive_val - $negative_val;

        next if $word_score == 0;

        push @found_words, {
            word      => $word,
            sentiment => $word_score > 0 ? 'positive' : 'negative',
            score     => $word_score,
        };
    }

    my $total_score = sum( map { $_->{score} } @found_words );

    return {
        score => $total_score,
        words => \@found_words,
    };
}

sub calculate_emotion_analysis {
    my ( $tokens, $lexicon ) = @_;
    my @found_words;
    my %aggregate_emotions;

    for my $word ( @{$tokens} ) {
        if ( !exists $lexicon->{$word} ) {
            next;
        }

        my $word_emotions = $lexicon->{$word};
        if ( !%{$word_emotions} ) {
            next;
        }

        push @found_words, {
            word     => $word,
            emotions => $word_emotions,
        };

        for my $emotion ( keys %{$word_emotions} ) {
            $aggregate_emotions{$emotion} += $word_emotions->{$emotion};
        }
    }

    return {
        emotions => \%aggregate_emotions,
        words    => \@found_words,
    };
}

1;
