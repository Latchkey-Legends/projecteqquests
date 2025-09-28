# Abraxxus the Watcher - Buff NPC with Custom Currency System
# Based on popular server implementation by main EQEmu developer
# Modified to use Mark of Age currency system
# Teleport Locations Array
my @teleport_locations = (
    {
        name => 'Plane of Knowledge', zoneid => 202, x => 0, y => 0, z => 0, heading => 0, min_level => 1, required_flag => 0, price => 100000
    },
    {
        name => 'Bazaar', zoneid => 151, x => -75, y => 0, z => 0, heading => 0, min_level => 1, required_flag => 0, price => 1
    },
    {
        name => 'Anguish', zoneid => 317, x => 0, y => 0, z => 0, heading => 0, min_level => 1, required_flag => 5, price => 1
    },
    {
        name => 'The Buried Sea', zoneid => 423, x => 0, y => 0, z => 0, heading => 0, min_level => 1, required_flag => 7, price => 1
    },
    # Add more locations as needed
);

# Currency Configuration
my $currency_id = 40;           # Mark of Age currency ID
my $item_id = quest::getcurrencyitemid($currency_id);  # Get item ID from currency ID
my $currency_name = quest::getitemname($item_id);      # Get currency name from item ID

# Check currency from alternate currency system only
sub CheckCustomCurrency {
    my ($client) = @_;
    my $alt_currency = $client->GetAlternateCurrencyValue($currency_id) || 0;
    return $alt_currency;
}

# Remove currency from alternate currency system only
sub RemoveCustomCurrency {
    my ($client, $amount) = @_;
    my $alt_currency = $client->GetAlternateCurrencyValue($currency_id) || 0;
    
    return 0 if ($alt_currency < $amount); # Not enough currency
    
    # Remove from alternate currency
    $client->RemoveAlternateCurrencyValue($currency_id, $amount);
    
    return 1; # Successfully removed
}

sub BuffsHash {
    my %hash = (
        1 => [1, 10, [219, 279, 269, 266, 40, 39, 697, 278, 46, 129, 13], 0],
        2 => [11, 20, [89, 283, 148, 2512, 147, 170, 174, 278, 46, 432, 13], 10],
        3 => [21, 30, [244, 149, 148, 349, 151, 10, 1693, 4054, 356, 13], 20],
        4 => [31, 40, [312, 161, 160, 152, 153, 171, 1694, 169, 1727, 13], 40],
        5 => [41, 50, [4053, 158, 154, 157, 159, 172, 1695, 2517, 1560, 13], 80],
        6 => [51, 60, [1447, 1580, 1579, 1596, 1581, 1729, 2570, 2517, 1561, 13], 150],
        7 => [61, 65, [3467, 3397, 4883, 3234, 1710, 3350, 2519, 2517, 3448, 13], 300],
        8 => [66, 70, [27032, 14284, 3472, 3479, 5415, 5355, 5352, 3178, 5513, 3444, 3185, 27032, 25230, 26317, 25443, 25470, 13, 432], 500],
        9 => [71, 125, [27032, 14284, 3472, 3479, 5415, 5355, 5352, 3178, 5513, 3444, 3185, 27032, 25230, 26317, 25443, 25470, 13, 432], 1000]
    );
    return %hash;
}

sub ListBuffPrices {
    my %h = BuffsHash();
    my @a;
    foreach my $key (sort {$a <=> $b} keys %h) {
        push @a, "$h{$key}[0] to $h{$key}[1]: $h{$key}[3] $currency_name";
    }
    quest::popup("Buff Prices", join("<br>", @a));
}

sub GetBuffCost {
    my %h = BuffsHash();
    foreach my $key (sort {$a <=> $b} keys %h) {
        if ($ulevel >= $h{$key}[0] && $ulevel <= $h{$key}[1]) {
            return $h{$key}[3];
        }
    }
}

sub HandleBuffBot {
    my %buffsHash = BuffsHash();
    my $duration_ticks = 600; # 1 hour = 600 ticks
    
    if (!$client->GetGroup()) {
        # Solo player
        foreach my $k (keys %buffsHash) {
            if ($ulevel >= $buffsHash{$k}[0] && $ulevel <= $buffsHash{$k}[1]) {
                my $cost = $buffsHash{$k}[3];
                if ($cost == 0 || RemoveCustomCurrency($client, $cost)) {
                    # Cast buffs with custom duration
                    foreach my $spell_id (@{$buffsHash{$k}[2]}) {
                        quest::selfcast($spell_id);
                        $client->SetBuffDuration($spell_id, $duration_ticks);
                    }
                } else {
                    my $current = CheckCustomCurrency($client);
                    $client->Message(15, "You cannot afford buffs, they cost $cost $currency_name for your level! You have $current.");
                    return;
                }
            }
        }
    } else {
        # Group player
        foreach my $k (keys %buffsHash) {
            if ($ulevel >= $buffsHash{$k}[0] && $ulevel <= $buffsHash{$k}[1]) {
                my $cost = $buffsHash{$k}[3];
                if ($cost == 0 || RemoveCustomCurrency($client, $cost)) {
                    # Cast buffs on group with custom duration
                    foreach my $spell_id (@{$buffsHash{$k}[2]}) {
                        for (my $i = 0; $i < 6; $i++) {
                            if ($client->GetGroup()->GetMember($i) && $client->GetGroup()->GetMember($i)->IsClient()) {
                                $client->GetGroup()->GetMember($i)->SpellFinished($spell_id, $client, 0);
                            }
                        }
                        $client->SetSpellDurationGroup($spell_id, $duration_ticks);
                    }
                } else {
                    my $current = CheckCustomCurrency($client);
                    $client->Message(15, "You cannot afford buffs, they cost $cost $currency_name for your level! You have $current.");
                    return;
                }
            }
        }
    }
    
    $client->Message(2, "Enjoy your buffs!");
}

sub EVENT_SAY {    
    if ($text=~/teleport_(\d+)/i) {
        HandleTeleportByIndex($client, $1);
    } elsif ($text=~/Hail/i) {
        my $current = CheckCustomCurrency($client);
        my $teleport_link = quest::saylink("teleport", 1);
        if ($current < 1) {
            $client->Message(0, "Abraxxus tells you: Hello $name. I cannot sense any resilience within you, you must prove your worth. Speak with Zork to find out how. However, I can offer you some free " . quest::saylink("buffs", 1) . ".");
        } else {
            $client->Message(0, "Abraxxus tells you: Greetings $name. I can provide some basic services such as " . quest::saylink("Buffs", 1) . " and " . quest::saylink("Teleportation", 1) . ". However, they will cost you.");

        }
    } elsif ($text=~/Buffs/i) {
        ShowBuffMenu($client);
    } elsif ($text=~/bufftier_(\d+)/i) {
        HandleBuffTier($client, $1);
# Show all buff tiers as clickable links in chat
sub ShowBuffMenu {
    my ($client) = @_;
    my %buffsHash = BuffsHash();
    $client->Message(0, "Abraxxus tells you: Buff Tiers Available:");
    my $ulevel = $client->GetLevel();
    foreach my $tier (sort {$a <=> $b} keys %buffsHash) {
        next if $ulevel < $buffsHash{$tier}[0];
        my $range = "$buffsHash{$tier}[0] to $buffsHash{$tier}[1]";
        my $price = $buffsHash{$tier}[3];
        my $link = quest::saylink("bufftier_$tier", 1, "Level $range");
        $client->Message(0, "Abraxxus tells you: $link (Cost: $price $currency_name)");
    }
}

# Handle buff tier selection
sub HandleBuffTier {
    my ($client, $tier) = @_;
    my %buffsHash = BuffsHash();
    my $price = $buffsHash{$tier}[3];
    my $current = CheckCustomCurrency($client);
    if ($current < $price) {
        $client->Message(0, "Abraxxus tells you: You do not have enough $currency_name for these buffs.");
        return;
    }
    RemoveCustomCurrency($client, $price);
    my $duration_ticks = 600;
    foreach my $spell_id (@{$buffsHash{$tier}[2]}) {
        quest::selfcast($spell_id);
        $client->SetBuffDuration($spell_id, $duration_ticks);
    }
    $client->Message(0, "Abraxxus tells you: Enjoy your buffs!");
}
    } elsif ($text=~/Price/i) {
        ListBuffPrices();
    } elsif ($text=~/teleport/i) {
        ShowTeleportMenu($client);
    }
# Handle teleport selection by index from saylink
sub HandleTeleportByIndex {
    my ($client, $idx) = @_;
    my $clientid = $client->CharacterID();
    my $level = $client->GetLevel();
    my $flag = quest::get_data($clientid . "_expansionflag") || 0;
    my $currency = CheckCustomCurrency($client);
    my @eligible;
    foreach my $loc (@teleport_locations) {
        next if $level < $loc->{min_level};
        next if $flag < $loc->{required_flag};
        next if $currency < $loc->{price};
        push @eligible, $loc;
    }
    my $loc = $eligible[$idx];
    if (!$loc) {
        $client->Message(13, "Invalid teleport selection.");
        return;
    }
    if ($currency < $loc->{price}) {
        $client->Message(15, "You do not have enough $currency_name for this teleport.");
        return;
    }
    RemoveCustomCurrency($client, $loc->{price});
    $client->Message(15, "Teleporting you to $loc->{name}!");
    $client->MovePC($loc->{zoneid}, $loc->{x}, $loc->{y}, $loc->{z}, $loc->{heading});
}
}

sub EVENT_POPUPRESPONSE {
    if ($popupid == 998) {
        HandleBuffBot();
    } elsif ($popupid >= 2000 && $popupid < 3000) {
        # Teleport selection
        HandleTeleport($client, $popupid);
    }
# Show teleport menu filtered by level and flag
sub ShowTeleportMenu {
    my ($client) = @_;
    my $clientid = $client->CharacterID();
    my $level = $client->GetLevel();
    my $flag = quest::get_data($clientid . "_expansionflag") || 0;
    my $currency = CheckCustomCurrency($client);
    my @eligible;
    my $popupid = 2000;
    foreach my $loc (@teleport_locations) {
        next if $level < $loc->{min_level};
        next if $flag < $loc->{required_flag};
        next if $currency < $loc->{price};
        push @eligible, $loc;
    }
    if (!@eligible) {
        $client->Message(0, "Abraxxus tells you: You do not meet the requirements for any teleport destinations.");
        return;
    }
    my @links;
    my $idx = 0;
    foreach my $loc (@eligible) {
        my $link = quest::saylink("teleport_$idx", 1, $loc->{name});
        my $cost_text = " (" . $loc->{price} . " $currency_name)";
        push @links, $link . $cost_text;
        $idx++;
    }
    $client->Message(0, "Abraxxus tells you: Teleport Destinations:");
    foreach my $link (@links) {
        $client->Message(0, "Abraxxus tells you: " . $link);
    }
}

# Handle teleport selection
sub HandleTeleport {
    my ($client, $popupid) = @_;
    my $index = $popupid - 2000;
    my $loc = $teleport_locations[$index];
    if (!$loc) {
        $client->Message(13, "Invalid teleport selection.");
        return;
    }
    my $currency = CheckCustomCurrency($client);
    if ($currency < $loc->{price}) {
        $client->Message(15, "You do not have enough $currency_name for this teleport.");
        return;
    }
    RemoveCustomCurrency($client, $loc->{price});
    $client->Message(15, "Teleporting you to $loc->{name}!");
    $client->movepc($loc->{zoneid}, $loc->{x}, $loc->{y}, $loc->{z}, $loc->{heading});
}
}