package Perceptio::Engine::Splitter;

use strict;
use warnings;

use Exporter 'import';
use Readonly;

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(split_text_into_sentences);

Readonly my $PROTECTED_PERIOD => chr 1;
Readonly my $SENTENCE_BREAK   => chr 2;

sub protect_abbreviations {
    my ($text, $abbreviations_data) = @_;
    my $abbreviations = $abbreviations_data -> {abbreviations} // [];
    if (!@{$abbreviations}) {
        return $text;
    }

    my $abbrev_pattern = join q{|}, @{$abbreviations};
    $text =~ s/\b($abbrev_pattern)[.](?=\s|[[:punct:]]|\z)/$1$PROTECTED_PERIOD/gmsx;

    return $text;
}

sub mark_sentence_breaks {
    my ($text) = @_;
    $text =~ s/([.!?])\s+(?=[[:upper:]])/$1$SENTENCE_BREAK/gmsx;
    $text =~ s/(\n\s*){2,}/$SENTENCE_BREAK/gmsx;
    return $text;
}

sub restore_periods {
    my ($text) = @_;
    $text =~ s/$PROTECTED_PERIOD/./gmsx;
    return $text;
}

sub split_text_into_sentences {
    my ($text, $abbreviations) = @_;

    my $protected_text = protect_abbreviations($text, $abbreviations);
    my $marked_text    = mark_sentence_breaks($protected_text);
    my @sentences      = split /$SENTENCE_BREAK/msx, $marked_text;

    my @cleaned_sentences;
    for my $sentence (@sentences) {
        $sentence = restore_periods($sentence);
        $sentence =~ s/\A\s+|\s+\z//gmsx;
        push @cleaned_sentences, $sentence;
    }

    return [grep { /\w/msx } @cleaned_sentences];
}

1;
