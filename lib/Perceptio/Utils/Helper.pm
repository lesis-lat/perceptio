package Perceptio::Utils::Helper;

use strict;
use warnings;

use Const::Fast;
use Exporter qw(import);

our $VERSION   = '0.0.1';
our @EXPORT_OK = qw(get_interface_info);

const my $INTERFACE_INFO => <<'END_INFO';

Perceptio v0.0.1
A multilingual sentiment analysis framework.
============================================
    Command                       Description
    -------                       -----------
    --analyze                     Analyze sentiment of the given input (string or file).
    --auto                        Automatically identify the language of the given input.
    --lang <en|pt|es>             Language code of the input (default: en).
    --input <text_or_path>        Input text string or path to a file containing text.
    --output <file>               Optional output file path (default: STDOUT).
    --format <plain|json>         Output format for sentiment result (default: plain).
    --by-sentence                 Analyze sentiment for each sentence individually.
    --generate-resources [type]   Generate translated resource files. Type can be 'lexicons',
                                  'abbreviations', or 'all' (default).
    --overwrite                   Overwrite existing resource files during generation.
    --list-languages              List currently available lexicon language files.
    -h, --help                    Display this help menu.

END_INFO

sub get_interface_info {
    return $INTERFACE_INFO;
}

1;
