package Cart::Checkout;
use JSON;
use Data::Dumper;

# prices as specified
my $prices = {
    A => { unit_price => 50, special_price => [3, 140] },
    B => { unit_price => 35, special_price => [2, 60] },
    C => { unit_price => 25 },
    D => { unit_price => 12 },
};

=pod

=head1  total_price

    takes one unnamed arg, $scanned_items, a hashref containing quantity scanned so far for each product code

=cut

sub total_price {
    my $scanned_items = shift;

    my $total = 0;
    for my $code ( keys %$scanned_items ) {
        my $quantity = $scanned_items->{$code};
        if ( exists $prices->{$code}{special_price} ) {
            my ($multiple,$special_price) = @{ $prices->{$code}{special_price} };
            $total += int($quantity/$multiple) * $special_price;
            $quantity = $quantity % $multiple;  # treat any left over as normal units
        }
        $total += $quantity * $prices->{$code}{unit_price};
    }

    return $total;
}

=head1  scan_data_file

  takes args:
    filename => example.json,
    show_subtotals => 1|0,   # if true, show each scanned item, quantity, charge, subtotal
  returns:
    total price

  data file is JSON encoding of an array of hashes, eg.
   '[{"code":"A","quantity":3},{"code":"B","quantity":3},{"code":"C","quantity":1},{"code":"D","quantity":2}]'

=cut

sub scan_data_file {
    my %args = @_;
    open( FH, $args{filename} )  or die "couldn't open $args{filename}: $!";
    my $json_str = join "", <FH>;
    # print "$json_str\n";

    my $items = JSON::decode_json( $json_str );
    # print Dumper( $items );
    my $scanned_items = {};   # keep track, as we might get same code twice
    my $previous_subtotal = 0;

    for my $item ( @$items ) {
        my ($code,$quantity) = ( $item->{code}, $item->{quantity} );
        if ( not exists $prices->{$code} ) {
            warn "WARNING: no price for code '$code'\n";
        } 
        elsif ( ($quantity || 0) < 1 ) {
            warn "WARNING: invalid quantity\n";
        }
        else {
            $scanned_items->{$code} //= 0;   # to avoid undefined warnings
            $scanned_items->{$code} += $quantity;
        }
        my $subtotal = total_price( $scanned_items );
        my $charge = $subtotal - $previous_subtotal;
        $previous_subtotal = $subtotal;
        if ( $args{show_subtotals} ) {
            print "code: $code  quantity: $quantity  charge: $charge \t subtotal: $subtotal\n";
        }
    }

    return $previous_subtotal;
}

1;    
