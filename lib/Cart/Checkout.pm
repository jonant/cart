
use JSON;
use Data::Dumper;

# prices as specified
#| Item Code | Unit Price | Special Price |
#|:---------:|:----------:|:-------------:|
#|     A	    |      50    |    3 for 140  |
#|     B     |      35    |    2 for 60   |
#|     C     |      25    |               |
#|     D     |      12    |               |
my $prices = {
    A => { unit_price => 50, special_price => [3, 140] },
    B => { unit_price => 35, special_price => [2, 60] },
    C => { unit_price => 25 },
    D => { unit_price => 12 },
};

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

sub scan_data_file {
    my $filename = shift;
    open( FH, $filename )  or die "couldn't open $filename: $!";
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
        print "code: $code  quantity: $quantity  charge: $charge \t subtotal: $subtotal\n";
    }
}

1;    
