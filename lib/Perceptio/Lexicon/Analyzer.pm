package Perceptio::Lexicon::Analyzer;

use strict;
use warnings;

our $VERSION = '0.0.1';

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub analyze_sentiment {
    my ($self, $text, $lexicon) = @_;

    my @words = split qr/\s+/smx, lc $text;
    my $score = 0;
    my @found_words;

    for my $word (@words) {
        $word =~ s/[.,!?;"]+$//smx;
        $word =~ s/^[.,!?;"]+//smx;

        if (exists $lexicon->{$word}) {
            my $word_emotions = $lexicon->{$word};

            # calculate score as positive minus negative.
            my $positive_val = $word_emotions->{positive} || 0;
            my $negative_val = $word_emotions->{negative} || 0;
            $score += ( $positive_val - $negative_val );

            push @found_words, {
                word     => $word,
                emotions => $word_emotions,
            };
        }
    }

    return {
        score => $score,
        words => \@found_words,
    };
}

1;
