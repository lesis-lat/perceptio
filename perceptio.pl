#!/usr/bin/env perl

use strict;
use warnings;
use Carp qw(croak);
use English qw(-no_match_vars);
use Getopt::Long;
use File::Slurper 'read_text';
use JSON::MaybeXS;
use FindBin;
use lib "$FindBin::Bin/lib";
use Readonly;
use Lingua::Identify qw(langof);

use Perceptio::Lexicon::Loader;
use Perceptio::Lexicon::Analyzer qw(
    tokenize_text
    calculate_polarity_analysis
    calculate_emotion_analysis
    calculate_sentence_analyses
);
use Perceptio::Engine::Splitter qw(split_text_into_sentences);
use Perceptio::Utils::Helper qw(get_interface_info);

our $VERSION = '0.0.1';

Readonly my $JSON_EXT_LENGTH => -5;

sub generate_lexicons {
    my ($opts) = @_;
    my @args = ( 'perl', 'scripts/generate-lexicons.pl' );
    if ( $opts->{overwrite} ) {
        push @args, '--overwrite';
    }
    system(@args) == 0
      or croak "Lexicon generation script failed with status: $CHILD_ERROR";
    return;
}

sub list_languages {
    my $lexicons_dir = "$FindBin::Bin/resources/lexicons";
    opendir my $dh, $lexicons_dir
      or croak "Could not open directory '$lexicons_dir': $OS_ERROR";

    my @files = readdir $dh;
    closedir $dh;

    my @languages =
      map { substr $_, 0, $JSON_EXT_LENGTH }
      grep { /[.]json\z/smx && -f "$lexicons_dir/$_" } @files;

    print 'Available languages: ' . join( ', ', sort @languages ) . "\n"
      or croak "Could not print languages: $OS_ERROR";
    return;
}

sub format_document_output {
    my ( $polarity_result, $emotion_result, $format ) = @_;
    my $output_str;

    if ( $format eq 'json' ) {
        my $combined_result = {
            score => $polarity_result->{score},
            words => $emotion_result->{words},
        };
        $output_str = JSON::MaybeXS->new( pretty => 1, canonical => 1 )->encode($combined_result);
    }
    else {
        $output_str = "Sentiment Score: $polarity_result->{score}\n";
        if ( @{ $polarity_result->{words} } ) {
            $output_str .= "Matched Words:\n";
            for my $entry ( @{ $polarity_result->{words} } ) {
                $output_str .=
                  "  - Word: '$entry->{word}', Sentiment: $entry->{sentiment}, Score: $entry->{score}\n";
            }
        }
    }
    return $output_str;
}

sub format_sentence_output {
    my ( $results, $format ) = @_;
    my $output_str;

    if ( $format eq 'json' ) {
        my @json_results = map {
            {
                sentence => $_->{sentence},
                score    => $_->{score},
                words    => $_->{emotion_words},
            }
        } @{$results};
        $output_str = JSON::MaybeXS->new( pretty => 1, canonical => 1 )->encode( \@json_results );
    }
    else {
        my @lines;
        for my $i ( 0 .. $#{$results} ) {
            my $res          = $results->[$i];
            my $sentence_num = $i + 1;
            my $line         = "Sentence $sentence_num: \"$res->{sentence}\"\n";
            $line .= "  Sentiment Score: $res->{score}\n";

            if ( @{ $res->{polarity_words} } ) {
                $line .= "  Matched Words:\n";
                for my $entry ( @{ $res->{polarity_words} } ) {
                    $line .=
                      "    - Word: '$entry->{word}', Sentiment: $entry->{sentiment}, Score: $entry->{score}\n";
                }
            }
            push @lines, $line;
        }
        $output_str = join "---\n", @lines;
    }
    return $output_str;
}

sub determine_language {
    my ( $opts, $text ) = @_;

    if ( $opts->{auto} ) {
        my %lang_info = langof($text);
        if (%lang_info) {
            my ($detected_lang) =
              sort { $lang_info{$b} <=> $lang_info{$a} } keys %lang_info;
            return $detected_lang;
        }
    }

    return $opts->{lang} || 'en';
}

sub analysis {
    my ($opts) = @_;
    my $format = $opts->{format} || 'plain';
    my $input = $opts->{input}
      or croak "Error: --input <text_or_path> is required for analysis.\n"
      . get_interface_info();

    my $text       = -f $input ? read_text($input) : $input;
    my $lang       = determine_language( $opts, $text );
    my $loader     = Perceptio::Lexicon::Loader->new;
    my $lexicon    = $loader->load_lexicon($lang);
    my $output_str;

    if ( $opts->{by_sentence} ) {
        my $abbreviations = $loader->load_abbreviations($lang);
        my $sentences     = split_text_into_sentences( $text, $abbreviations );
        my $results       = calculate_sentence_analyses( $sentences, $lexicon );
        $output_str = format_sentence_output( $results, $format );
    }
    else {
        my $tokens          = tokenize_text($text);
        my $polarity_result = calculate_polarity_analysis( $tokens, $lexicon );
        my $emotion_result  = calculate_emotion_analysis( $tokens, $lexicon );
        $output_str = format_document_output( $polarity_result, $emotion_result, $format );
    }

    if ( $opts->{output} ) {
        open my $fh, '>', $opts->{output}
          or croak "Could not open file '$opts->{output}' for writing: $OS_ERROR";
        print {$fh} $output_str
          or croak "Could not write to file '$opts->{output}': $OS_ERROR";
        close $fh
          or croak "Could not close file '$opts->{output}': $OS_ERROR";
    }
    else {
        print $output_str or croak "Could not print results: $OS_ERROR";
    }
    return;
}

sub main {
    my %opts;
    GetOptions(
        'analyze'           => \$opts{analyze},
        'auto'              => \$opts{auto},
        'lang=s'            => \$opts{lang},
        'input=s'           => \$opts{input},
        'output=s'          => \$opts{output},
        'format=s'          => \$opts{format},
        'by-sentence'       => \$opts{by_sentence},
        'generate-lexicons' => \$opts{generate_lexicons},
        'overwrite'         => \$opts{overwrite},
        'list-languages'    => \$opts{list_languages},
        'help|h'            => \$opts{help},
    ) or croak get_interface_info();

    if ( $opts{help} ) {
        print get_interface_info()
          or croak "Failed to print help information: $OS_ERROR";
        exit 0;
    }

    if ( $opts{generate_lexicons} ) {
        generate_lexicons( \%opts );
    }
    elsif ( $opts{list_languages} ) {
        list_languages();
    }
    elsif ( $opts{analyze} ) {
        analysis( \%opts );
    }
    else {
        print get_interface_info()
          or croak "Failed to print usage information: $OS_ERROR";
    }

    return;
}

main();

1;
