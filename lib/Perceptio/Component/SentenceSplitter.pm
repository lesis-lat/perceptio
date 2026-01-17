package Perceptio::Component::SentenceSplitter;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Engine::Splitter qw(split_text_into_sentences);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ( $text, $abbreviations ) = @_;
    return split_text_into_sentences( $text, $abbreviations );
}

1;
