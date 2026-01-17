package Perceptio::Component::InterfaceInfo;

use strict;
use warnings;

use Exporter qw(import);
use Perceptio::Utils::Helper qw(get_interface_info);

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(run);

sub run {
    my $info = get_interface_info();
    return $info;
}

1;
