#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Cart::Checkout  qw/scan_data_file/;

my $data_file = shift;

if ( $data_file =~ /^[\w\/\-]+\.json$/ ) {
    scan_data_file( $data_file );
}
else {
    die "Usage: ./checkout.pl items_to_scan.json ";
}

