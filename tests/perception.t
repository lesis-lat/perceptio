#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '../lib/';

use Perceptio::Utils::Helper qw(get_interface_info);

our $VERSION = '0.0.1';

my $info = get_interface_info();

ok( defined $info, 'Returned info is a defined value.' );    # Optional: A good replacement test.
like( $info, qr{^Perceptio \s+ v0[.]0[.]1}xms, 'Help text starts with correct version' );
like( $info, qr{--analyze}xms, 'Help text contains the --analyze option' );
like( $info, qr{--lang \s+ <en[|]pt[|]es>}xms, 'Help text contains the --lang option' );
like( $info, qr{--input \s+ <text_or_path>}xms, 'Help text contains the --input option' );
like( $info, qr{--output \s+ <file>}xms, 'Help text contains the --output option' );
like( $info, qr{--format \s+ <plain[|]json>}xms, 'Help text contains the --format option' );
like( $info, qr{--generate-lexicons}xms, 'Help text contains the --generate-lexicons option' );
like( $info, qr{--overwrite}xms, 'Help text contains the --overwrite option' );
like( $info, qr{--list-languages}xms, 'Help text contains the --list-languages option' );
like( $info, qr{--help}xms, 'Help text contains the --help option' );

done_testing();
