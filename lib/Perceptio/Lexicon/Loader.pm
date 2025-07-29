package Perceptio::Lexicon::Loader;

use strict;
use warnings;

use Carp 'croak';
use JSON::MaybeXS;
use File::Slurper 'read_text';
use File::Spec;
use FindBin;
use Try::Tiny;

our $VERSION   = '0.0.1';

my $DEFAULT_LEXICONS_DIR = File::Spec->catfile($FindBin::Bin, 'resources', 'lexicons');

sub new {
    my ($class, %args) = @_;

    my $self = {
        cache => {},
        lexicon_dir => $args{lexicon_dir} || $DEFAULT_LEXICONS_DIR,
    };

    return bless $self, $class;
}

sub load_lexicon {
    my ($self, $lang) = @_;

    return $self->{cache}{$lang} if exists $self->{cache}{$lang};

    my $file_path = File::Spec->catfile($self->{lexicon_dir}, "$lang.json");

    if (not -e $file_path) {
        croak "Lexicon for language '$lang' not found at $file_path";
    }

    my $json_text = read_text($file_path);
    my $lexicon;
    try {
        $lexicon = decode_json($json_text);
    }
    catch {
        croak "Error decoding JSON from $file_path: $_";
    };

    $self->{cache}{$lang} = $lexicon;

    return $lexicon;
}

1;
