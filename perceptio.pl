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

use Perceptio::Lexicon::Loader;
use Perceptio::Lexicon::Analyzer;
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

sub format_output {
    my ( $result, $format ) = @_;
    my $output_str;

    if ( $format eq 'json' ) {
        $output_str = encode_json($result);
    }
    else {
        $output_str = "Sentiment Score: $result->{score}\n";
        $output_str .= "Matched Words:\n";

        for my $entry ( @{ $result->{words} } ) {
            my $emotions = $entry->{emotions};

            # calculate word-specific score and sentiment for display
            my $p_val = $emotions->{positive} || 0;
            my $n_val = $emotions->{negative} || 0;
            my $word_score = $p_val - $n_val;

            my $sentiment_label = 'neutral';
            if ( $word_score > 0 ) {
                $sentiment_label = 'positive';
            }
            if ( $word_score < 0 ) {
                $sentiment_label = 'negative';
            }

            $output_str .=
              "  - Word: '$entry->{word}', Sentiment: $sentiment_label, Score: $word_score\n";
        }
    }
    return $output_str;
}

sub analysis {
    my ($opts) = @_;
    my $lang   = $opts->{lang} || 'en';
    my $input =
      $opts->{input}
      or croak "Error: --input <text_or_path> is required for analysis.\n"
      . get_interface_info();
    my $format = $opts->{format} || 'plain';

    my $loader   = Perceptio::Lexicon::Loader->new;
    my $lexicon  = $loader->load_lexicon($lang);
    my $analyzer = Perceptio::Lexicon::Analyzer->new;
    my $text     = -f $input ? read_text($input) : $input;
    my $result   = $analyzer->analyze_sentiment( $text, $lexicon );

    my $output_str = format_output( $result, $format );

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
        'lang=s'            => \$opts{lang},
        'input=s'           => \$opts{input},
        'output=s'          => \$opts{output},
        'format=s'          => \$opts{format},
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
