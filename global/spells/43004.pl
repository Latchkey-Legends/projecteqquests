sub handle_warrior {
    my %warrior_map = (
        # Rusty
        500200 => [500201, 500202], # Bent
        500203 => [500204, 500205], # Rusty
        500206 => [500207, 500208], # Dirty
        500209 => [500210, 500211], # Worn
        500212 => [500213, 500214], # Tarnished
        500215 => [500216, 500217], # Weathered
        500221 => [500222, 500223], # Sharpened
        500224 => [500225, 500226], # Forged
        500227 => [500228, 500229], # Runed
        500230 => [500231, 500232], # Imbued
        500233 => [500234, 500235], # Empowered
        500290 => [500291, 500292], # Superb
        500236 => [500237, 500238], # Mythic
        500293 => [500294, 500295], # Epic
        500239 => [500240, 500241], # Legendary
        '1H_PAIR' => [
            {items => [500201, 500202], result => [500200] }, # Bent
            {items => [500204, 500205], result => [500203] }, # Rusty
            {items => [500207, 500208], result => [500206] }, # Dirty
            {items => [500210, 500211], result => [500209] }, # Worn
            {items => [500213, 500214], result => [500212] }, # Tarnished
            {items => [500216, 500217], result => [500215] }, # Weathered
            {items => [500222, 500223], result => [500221] }, # Sharpened
            {items => [500225, 500226], result => [500224] }, # Forged
            {items => [500228, 500229], result => [500227] }, # Runed
            {items => [500231, 500232], result => [500230] }, # Imbued 
            {items => [500234, 500235], result => [500233] }, # Empowered
            {items => [500291, 500292], result => [500290] }, # Superb
            {items => [500237, 500238], result => [500236] }, # Mythic
            {items => [500294, 500295], result => [500293] }, # Epic
            {items => [500240, 500241], result => [500239] }, # Legendary
        ],
    );
    quest::debug("Warrior transformation invoked.");
    swap_three($client, \%warrior_map);
}

sub handle_paladin {
    my %paladin_map = (
        # Rusty
        500243 => [500242, 500244], # Bent

        500246 => [500245, 500247], # Rusty
        500249 => [500248, 500250], # Dirty
        500252 => [500251, 500253], # Worn
        500255 => [500256, 500256], # Tarnished
        500258 => [500257, 500259], # Weathered
        500264 => [500263, 500265], # Sharpened
        500267 => [500266, 500268], # Forged
        500270 => [500269, 500271], # Runed
        500273 => [500272, 500274], # Imbued
        500276 => [500275, 500277], # Empowered
        500285 => [500284, 500286], # Superb
        500279 => [500278, 500280], # Mythic
        500288 => [500287, 500289], # Epic
        500282 => [500281, 500283], # Legendary
        '1H_PAIR' => [
            {items => [500242, 500244], result => [500243] }, # Bent

            {items => [500245, 500247], result => [500246] }, # Rusty
            {items => [500248, 500250], result => [500249] }, # Dirty
            {items => [500251, 500253], result => [500252] }, # Worn
            {items => [500256, 500256], result => [500255] }, # Tarnished
            {items => [500257, 500259], result => [500258] }, # Weathered
            {items => [500263, 500265], result => [500264] }, # Sharpened
            {items => [500266, 500268], result => [500267] }, # Forged
            {items => [500269, 500271], result => [500270] }, # Runed
            {items => [500272, 500274], result => [500273] }, # Imbued
            {items => [500275, 500277], result => [500276] }, # Empowered
            {items => [500284, 500286], result => [500285] }, # Superb
            {items => [500278, 500280], result => [500279] }, # Mythic
            {items => [500287, 500289], result => [500288] }, # Epic
            {items => [500281, 500283], result => [500282] }, # Legendary
        ],
    );
    quest::debug("Paladin transformation invoked.");
    swap_three($client, \%paladin_map);
}

sub handle_shadowknight {
    my %shadowknight_map = (
        # Rusty
        500296 => [500297, 500298], # Bent
        500299 => [500230, 500231], # Rusty
        500302 => [500303, 500304], # Dirty
        500305 => [500306, 500307], # Worn
        500308 => [500309, 500310], # Tarnished
        500311 => [500312, 500313], # Weathered
        500314 => [500315, 500316], # Sharpened
        500317 => [500318, 500319], # Forged
        500320 => [500321, 500322], # Runed
        500323 => [500324, 500325], # Imbued
        500326 => [500327, 500328], # Empowered
        500329 => [500330, 500331], # Superb
        500332 => [500333, 500334], # Mythic
        500335 => [500336, 500337], # Epic
        500338 => [500339, 500340], # Legendary
        '1H_PAIR' => [
            {items => [500297, 500298], result => [500296] }, # Bent
            {items => [500230, 500231], result => [500299] }, # Rusty
            {items => [500303, 500304], result => [500302] }, # Dirty
            {items => [500306, 500307], result => [500305] }, # Worn
            {items => [500309, 500310], result => [500308] }, # Tarnished
            {items => [500312, 500313], result => [500311] }, # Weathered
            {items => [500315, 500316], result => [500314] }, # Sharpened
            {items => [500318, 500319], result => [500317] }, # Forged
            {items => [500321, 500322], result => [500320] }, # Runed
            {items => [500324, 500325], result => [500323] }, # Imbued
            {items => [500327, 500328], result => [500326] }, # Empowered
            {items => [500330, 500331], result => [500329] }, # Superb
            {items => [500333, 500334], result => [500332] }, # Mythic
            {items => [500336, 500337], result => [500335] }, # Epic
            {items => [500339, 500340], result => [500338] }, # Legendary
        ],
    );
    quest::debug("Shadowknight transformation invoked.");
    swap_three($client, \%shadowknight_map);
}

# #############################################################################
# swap_three($client, \%transform_map)
sub swap_three {
    my ($client, $transform_map) = @_;
    # 2H to 1H
    foreach my $from_item (keys %$transform_map) {
        next if $from_item eq '1H_PAIR';
        my $count = $client->CountItem($from_item);
        if ($count > 0) {
            $client->RemoveItem($from_item, 1);
            foreach my $to_item (@{$transform_map->{$from_item}}) {
                $client->SummonItem($to_item, 1);
            }
            $client->Message(15, "2H weapon transformed into two 1H weapons!");
            return 1;
        }
    }
    # 1H to 2H
    foreach my $pair (@{$transform_map->{'1H_PAIR'}}) {
        my ($item1, $item2) = @{$pair->{items}};
        if ($client->CountItem($item1) > 0 && $client->CountItem($item2) > 0) {
            $client->RemoveItem($item1, 1);
            $client->RemoveItem($item2, 1);
            foreach my $to_item (@{$pair->{result}}) {
                $client->SummonItem($to_item, 1);
            }
            $client->Message(15, "Two 1H weapons transformed into a 2H weapon!");
            return 1;
        }
    }
    $client->Message(15, "No valid item(s) found for transformation.");
    return 0;
}

sub EVENT_SPELL_EFFECT_CLIENT
{
    quest::debug("Player Class: " . $client->GetClassName());
    my $class = $client->GetClassName();
    if ($class eq 'Warrior') {
        handle_warrior();
    } elsif ($class eq 'Paladin') {
        handle_paladin();
    } elsif ($class eq 'Shadowknight') {
        handle_shadowknight();
    } elsif ($class eq 'Cleric') {
        handle_cleric();
    } elsif ($class eq 'Druid') {
        handle_druid();
    } elsif ($class eq 'Shaman') {
        handle_shaman();
    } elsif ($class eq 'Ranger') {
        handle_ranger();
    } elsif ($class eq 'Bard') {
        handle_bard();
    } elsif ($class eq 'Rogue') {
        handle_rogue();
    } elsif ($class eq 'Monk') {
        handle_monk();
    } elsif ($class eq 'Beastlord') {
        handle_beastlord();
    } elsif ($class eq 'Berserker') {
        handle_berserker();
    } else {
        $client->Message(15, "Your class does not have a weapon transformation.");
    }

}