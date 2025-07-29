package Perceptio::Lexicon::Analyzer;

use strict;
use warnings;

our $VERSION   = '0.0.1';

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
            $score += $lexicon->{$word}{weight};
            push @found_words, {
                word      => $word,
                sentiment => $lexicon->{$word}{sentiment},
                weight    => $lexicon->{$word}{weight}
            };
        }
    }

    return {
        score => $score,
        words => \@found_words,
    };
}

1;
