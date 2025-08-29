package Perceptio::Lexicon::Loader;

use strict;
use warnings;

use Carp 'croak';
use JSON::MaybeXS;
use File::Slurper 'read_text';
use File::Spec;
use FindBin;
use Try::Tiny;

our $VERSION = '0.0.1';

sub new {
    my ($class) = @_;

    my $self = {
        cache => {},
    };

    return bless $self, $class;
}

sub load_resource {
    my ( $self, $type, $lang ) = @_;

    my $cache_key = "$type:$lang";
    return $self->{cache}{$cache_key} if exists $self->{cache}{$cache_key};

    my $dir_path = File::Spec->catfile( $FindBin::Bin, 'resources', $type );
    my $file_path = File::Spec->catfile( $dir_path, "$lang.json" );

    if ( not -e $file_path ) {
        croak "Resource for type '$type' and language '$lang' not found at $file_path";
    }

    my $json_text;
    my $data;
    try {
        $json_text = read_text($file_path);
        $data      = decode_json($json_text);
    }
    catch {
        croak "Error decoding JSON from $file_path: $_";
    };

    $self->{cache}{$cache_key} = $data;

    return $data;
}

sub load_lexicon {
    my ( $self, $lang ) = @_;
    return $self->load_resource( 'lexicons', $lang );
}

sub load_abbreviations {
    my ( $self, $lang ) = @_;
    return $self->load_resource( 'abbreviations', $lang );
}

1;
