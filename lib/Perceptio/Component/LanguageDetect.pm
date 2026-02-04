package Perceptio::Component::LanguageDetect;

use strict;
use warnings;

use Exporter qw(import);
use Lingua::Identify qw(langof);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my ($ops, $text) = @_;

    if ($ops -> {auto}) {
        my %lang_info = langof($text);
        if (%lang_info) {
            my ($detected_lang) = reverse sort {
                $lang_info{$a} <=> $lang_info{$b}
            } keys %lang_info;
            return $detected_lang;
        }
    }

    if ($ops -> {lang}) {
        return $ops -> {lang};
    }

    return 'en';
}

1;
