#!/usr/bin/env perl

use strict;
use warnings;
use Carp qw(croak);
use English qw(-no_match_vars);
use File::Slurper qw(read_text write_text);
use FindBin;
use Getopt::Long;
use JSON::MaybeXS;
use lib "$FindBin::Bin/../lib";
use List::Util qw(any);

use Perceptio::Engine::Translator;

our $VERSION = '0.0.1';

sub new_task {
    my ( $type, $translator, $overwrite, @languages ) = @_;
    return sub {
        my $resource_dir    = "$FindBin::Bin/../resources/$type";
        my $source_path     = "$resource_dir/en.json";
        my $translation_sub = 'translate_' . $type;
        $translation_sub =~ s/s\z//msx;

        if ( !-f $source_path ) {
            croak "Source file not found at $source_path";
        }

        my $source_data = decode_json( read_text($source_path) );

        for my $lang (@languages) {
            my $output_path = "$resource_dir/$lang.json";
            if ( -e $output_path && !$overwrite ) {
                print "Skipping $lang $type: Exists at $output_path. Use --overwrite to replace.\n"
                  or croak "print failed: $OS_ERROR";
                next;
            }

            print "Translating $type to $lang...\n" or croak "print failed: $OS_ERROR";
            my $translated_data = $translator->$translation_sub( $source_data, $lang );

            if ($translated_data) {
                my $json_text = JSON::MaybeXS->new( pretty => 1, canonical => 1 )->encode($translated_data);
                write_text( $output_path, $json_text );
                print "Wrote $lang $type to $output_path\n" or croak "print failed: $OS_ERROR";
            }
            else {
                warn "Translation of $type to $lang resulted in empty data. Skipping write.\n";
            }
        }
    };
}

sub main {
    my $overwrite = 0;
    my $type      = 'all';
    GetOptions( 'overwrite' => \$overwrite, 'type=s' => \$type );

    if ( !any { $_ eq $type } qw(lexicons abbreviations all) ) {
        croak "Invalid type: '$type'. Must be 'lexicons', 'abbreviations', or 'all'.";
    }

    my @target_languages = qw(pt es);
    my $translator       = Perceptio::Engine::Translator->new;
    my @task_types;
    if ( $type eq 'lexicons' or $type eq 'all' ) {
        push @task_types, 'lexicons';
    }
    if ( $type eq 'abbreviations' or $type eq 'all' ) {
        push @task_types, 'abbreviations';
    }

    for my $task_type (@task_types) {
        my $task = new_task( $task_type, $translator, $overwrite, @target_languages );
        $task->();
    }

    print "Resource generation complete.\n" or croak "print failed: $OS_ERROR";
    return;
}

main();

1;
