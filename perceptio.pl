#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

use Perceptio::Network::Cli ();

our $VERSION = '0.0.1';

sub main {
    return Perceptio::Network::Cli::run();
}

main();

1;
