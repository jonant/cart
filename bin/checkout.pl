#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';

# most code is in module for tests 
use Cart::Checkout  qw/ scan_data_file /;

my $data_file = shift;

if ( $data_file =~ /^[\w\/\-]+\.json$/ ) {
    my $total = scan_data_file( filename => $data_file, show_subtotals => 1 );
    print "Total: $total\n";
}
else {
    die "Usage: ./checkout.pl items_to_scan.json ";
}

