#!/usr/bin/perl
#
# to be run form parent directory, e.g.
# > t/01_totals.t
# or, just
# > prove
#
use strict;
use warnings;
use lib './lib';
use Cart::Checkout  qw/scan_data_file/;
use Test::More tests => 3;

ok( scan_data_file( filename => 'data/data-set-1.json' ) == 284 );
ok( scan_data_file( filename => 'data/data-set-2.json' ) == 384 );
ok( scan_data_file( filename => 'data/data-set-3.json' ) == 409 );

done_testing;
