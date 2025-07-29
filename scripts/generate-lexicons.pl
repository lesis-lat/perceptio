#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use JSON::MaybeXS;
use File::Slurper qw(read_text write_text);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Carp;
use English '-no_match_vars';

use Perceptio::Engine::Translator;

our $VERSION = '0.0.1';

my $overwrite = 0;
GetOptions( 'overwrite' => \$overwrite );

my $lexicons_dir    = "$FindBin::Bin/../resources/lexicons";
my $en_lexicon_path = "$lexicons_dir/en.json";

if ( !-f $en_lexicon_path ) {
    croak "English lexicon not found at $en_lexicon_path";
}

my $en_lexicon = decode_json( read_text($en_lexicon_path) );
my $translator = Perceptio::Engine::Translator->new;

for my $lang ( 'pt', 'es' ) {
    my $output_path = "$lexicons_dir/$lang.json";
    if ( -e $output_path && !$overwrite ) {
        print "Skipping $lang: Lexicon already exists at $output_path. Use --overwrite to replace it.\n"
          or croak 'print failed: ', $OS_ERROR;
        next;
    }

    print "Translating to $lang...\n" or croak 'print failed: ', $OS_ERROR;
    my $translated_lexicon = $translator->translate_lexicon( $en_lexicon, $lang );

    if ( keys %{$translated_lexicon} ) {
        my $json_text = JSON::MaybeXS->new( pretty => 1, canonical => 1 )->encode($translated_lexicon);
        write_text( $output_path, $json_text );
        print "Wrote $lang lexicon to $output_path\n" or croak 'print failed: ', $OS_ERROR;
    }
    else {
        warn "Translation to $lang resulted in an empty lexicon. Skipping write.\n";
    }
}

print "Lexicon generation complete.\n" or croak 'print failed: ', $OS_ERROR;
