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

my $temp_dir = File::Spec->catdir( $FindBin::Bin, 'temp_test_lexicons' );
make_path($temp_dir);

my $dummy_lexicon_path = File::Spec->catfile( $temp_dir, 'xx.json' );
my $dummy_lexicon_data = { test => { sentiment => 'neutral', weight => 0 } };

open my $fh, '>', $dummy_lexicon_path
  or croak 'Could not create dummy lexicon file: ', $OS_ERROR;
print {$fh} encode_json($dummy_lexicon_data)
  or croak 'Could not write to dummy lexicon file: ', $OS_ERROR;
close $fh or croak 'Could not close dummy lexicon file: ', $OS_ERROR;

my $loader = Perceptio::Lexicon::Loader->new( lexicon_dir => $temp_dir );
isa_ok( $loader, 'Perceptio::Lexicon::Loader',
    'new() with injected path creates a valid object' );

subtest 'Lexicon Loading with Injected Path' => sub {
    my $lexicon = $loader->load_lexicon('xx');
    is_deeply( $lexicon, $dummy_lexicon_data,
        'load_lexicon() correctly loads from the injected directory' );

    my $lexicon_from_cache = $loader->load_lexicon('xx');
    is( $lexicon, $lexicon_from_cache,
        'load_lexicon() returns a cached reference on the second call' );
};

subtest 'Error Handling' => sub {
    my $err_prefix = qr{ Lexicon[ ]for[ ]language[ ]'yy'[ ]not[ ]found[ ]at[ ].*? }smx;
    my $err_suffix = qr{ temp_test_lexicons [\\/] yy [.] json }smx;
    throws_ok { $loader->load_lexicon('yy') } qr/$err_prefix$err_suffix/smx,
      'load_lexicon() dies correctly for a non-existent language';
};

remove_tree($temp_dir);

done_testing();
