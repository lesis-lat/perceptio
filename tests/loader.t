#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use JSON::MaybeXS;
use File::Spec;
use File::Path qw(make_path remove_tree);
use Carp qw(croak);
use English qw(-no_match_vars);

use FindBin;
use lib "$FindBin::Bin/../lib";

use Perceptio::Lexicon::Loader;

our $VERSION = '0.0.1';

my $base_dir     = $FindBin::Bin;
my $resource_dir = File::Spec->catdir( $base_dir, 'resources' );
my $lexicon_dir  = File::Spec->catdir( $resource_dir, 'lexicons' );
make_path($lexicon_dir);

my $dummy_lexicon_path = File::Spec->catfile( $lexicon_dir, 'en.json' );
my $dummy_lexicon_data = { hello => { sentiment => 'positive', weight => 0.5 } };

open my $fh, '>', $dummy_lexicon_path
  or croak "Could not create dummy lexicon file: $OS_ERROR";
print {$fh} encode_json($dummy_lexicon_data)
  or croak "Could not write to dummy lexicon file: $OS_ERROR";
close $fh or croak "Could not close dummy lexicon file: $OS_ERROR";

my $loader = Perceptio::Lexicon::Loader->new();
isa_ok( $loader, 'Perceptio::Lexicon::Loader', 'new() creates a valid object' );

subtest 'Lexicon Loading' => sub {
    plan tests => 2;

    my $lexicon = $loader->load_lexicon('en');
    is_deeply( $lexicon, $dummy_lexicon_data,
        q{load_lexicon('en') correctly loads from the created resources directory} );

    my $lexicon_from_cache = $loader->load_lexicon('en');
    is( $lexicon, $lexicon_from_cache,
        'load_lexicon() returns a cached reference on the second call' );
};

subtest 'Error Handling' => sub {
    plan tests => 1;

    my $err_intro  = qr{Resource[ ]for[ ]type[ ]'lexicons'}smx;
    my $err_lang   = qr{and[ ]language[ ]'yy'}smx;
    my $err_status = qr{not[ ]found[ ]at[ ].*}smx;
    my $err_file   = qr{yy[.]json}smx;

    throws_ok { $loader->load_lexicon('yy') }
      qr/$err_intro[ ]$err_lang[ ]$err_status$err_file/smx,
      'load_lexicon() dies correctly for a non-existent language';
};

remove_tree($resource_dir);

done_testing();
