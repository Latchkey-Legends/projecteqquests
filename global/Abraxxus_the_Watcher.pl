# Abraxxus the Watcher - Buff NPC with Custom Currency System
# Based on popular server implementation by main EQEmu developer
# Modified to use Mark of Age currency system
# Teleport Locations Array
my @teleport_locations = (
    { name => 'Toxxulia Forest', zoneid => 38, x => -921, y => -1523, z => -39.13, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'North Karana', zoneid => 13, x => 1209, y => -3685, z => -9.18, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'Greater Faydark', zoneid => 54, x => -441, y => -2023, z => -0.90, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'East Commonlands', zoneid => 22, x => -210, y => -1590, z => 2.50, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'Nektulos Forest', zoneid => 25, x => -715, y => -57, z => 41.02, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'North Ro', zoneid => 34, x => 820, y => 1374, z => 9.08, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'West Karana', zoneid => 12, x => -14815, y => -3569, z => 35.38, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    { name => 'Surefall Glade', zoneid => 3, x => 215, y => -316, z => 1.50, heading => 0, min_level => 1, required_flag => 0, price => 10 },


    # { name => 'Grobb', zoneid => 46, x => -332.24, y => -2594.79, z => -11.57, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    
    # { name => 'Qeynos', zoneid => 2, x => 162.58, y => 478.56, z => 3.85, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Freeport', zoneid => 9, x => 143.17, y => 3.73, z => -24.15, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Surfall', zoneid => 4, x => 225.29, y => 5044.50, z => -3.71, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Kelethin', zoneid => 54, x => 184.38, y => 157.30, z => 3.62, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Halas', zoneid => 30, x => 670.34, y => 3629.16, z => 3.85, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Erudin', zoneid => 38, x => 249.97, y => 2325.90, z => -44.79, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Paineel', zoneid => 75, x => 189.59, y => 777.19, z => 2.77, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Felwithe', zoneid => 54, x => -2326.97, y => -2030.23, z => 29.43, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Nektulos', zoneid => 25, x => -912.41, y => 1759.92, z => 26.76, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Kelethin', zoneid => 68, x => -209.97, y => 2802.55, z => 2.75, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => "Ak'Anon", zoneid => 56, x => 504.85, y => -1757.54, z => -108.05, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Rivervale', zoneid => 33, x => -2318.06, y => 541.91, z => -4.43, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Oggok', zoneid => 47, x => 917.83, y => 1385.55, z => 51.68, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Cabalis', zoneid => 78, x => 3210.64, y => -2506.42, z => 7.95, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Rathe Mountains', zoneid => 50, x => 386.21, y => -1125.46, z => 1.13, heading => 0, min_level => 1, required_flag => 0, price => 10 },
    # { name => 'Shadeweavers Thicket', zoneid => 165, x => -3323.58, y => -2110.32, z => -108.48, heading => 0, min_level => 1, required_flag => 0, price => 10 },
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

# Buffs Hash
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

# List Buff Prices
sub ListBuffPrices {
    my %h = BuffsHash();
    my @a;
    foreach my $key (sort {$a <=> $b} keys %h) {
        push @a, "$h{$key}[0] to $h{$key}[1]: $h{$key}[3] $currency_name";
    }
    quest::popup("Buff Prices", join("<br>", @a));
}

# Get Buff Cost for Player Level
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

# Returns the number of players in the group or raid
sub getGroupRaidCount {
    my ($client) = @_;
    if ($client->GetRaid()) {
        return $client->GetRaid()->RaidCount();
    } elsif ($client->GetGroup()) {
        return $client->GetGroup()->GroupCount();
    } else {
        return 1;
    }
}

# Teleports all members of the group or raid
sub HandleGroupTeleport {
    my ($client, $popupid) = @_;
    my $index = $popupid - 2000;
    my $loc = $teleport_locations[$index];
    if (!$loc) {
        $client->Message(13, "Invalid teleport selection.");
        return;
    }
    my $currency = CheckCustomCurrency($client);
    my $count = getGroupRaidCount($client);
    my $total_cost = $loc->{price} * $count;
    if ($currency < $total_cost) {
        $client->Message(15, "You do not have enough $currency_name for this group teleport. Cost: $total_cost");
        return;
    }
    RemoveCustomCurrency($client, $total_cost);
    $client->Message(15, "Teleporting your group/raid to $loc->{name}!");
    if ($client->GetRaid()) {
        my $raid = $client->GetRaid();
        for (my $i = 0; $i < $raid->RaidCount(); $i++) {
            my $member = $raid->GetMember($i);
            if ($member && $member->IsClient()) {
                $member->MovePC($loc->{zoneid}, $loc->{x}, $loc->{y}, $loc->{z}, $loc->{heading});
            }
        }
    } elsif ($client->GetGroup()) {
        my $group = $client->GetGroup();
        for (my $i = 0; $i < $group->GroupCount(); $i++) {
            my $member = $group->GetMember($i);
            if ($member && $member->IsClient()) {
                $member->MovePC($loc->{zoneid}, $loc->{x}, $loc->{y}, $loc->{z}, $loc->{heading});
            }
        }
    } else {
        $client->MovePC($loc->{zoneid}, $loc->{x}, $loc->{y}, $loc->{z}, $loc->{heading});
    }
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

sub EVENT_SAY {    
    if ($text=~/teleport_group_(\d+)/i) {
        HandleGroupTeleport($client, 2000 + $1);
    } elsif ($text=~/teleport_(\d+)/i) {
        HandleTeleportByIndex($client, $1);
    } elsif ($text=~/Hail/i) {
        quest::debug("Currency ID: $currency_id, Item ID: $item_id, Currency Name: $currency_name");
        my $plate_count = $client->CountItem($plate_itemid);
        my $hubtp_count = $client->CountItem(500005);
        my $hub_tp_name = quest::getitemname(500005);
        my $current = CheckCustomCurrency($client);
        my $teleport_link = quest::saylink("teleport", 1);
        if ($current < 1) {
            $client->Message(0, "Abraxxus tells you: Hello $name. I cannot sense any resilience within you, you must prove your worth. Speak with Zork to find out how. However, I can offer you some free " . quest::saylink("buffs", 1) . ".");
        } else {
            $client->Message(0, "Abraxxus tells you: Greetings $name. I can provide some basic services such as " . quest::saylink("Buffs", 1) . ", " . quest::saylink("teleport", 1, "Teleportation") . " and " . quest::saylink("group", 1, "Group Teleportation") . ". However, they will cost you.");
        }

        if($hubtp_count > 0) {
            $client->Message(0, "Abraxxus tells you: I see you have a $hub_tp_name !. Would you like me to ".quest::saylink('attune', 0, 'attune')." it to my location?");
        }
    } elsif ($text =~ /attune/i) {
        $client->SetBucket("hub_x", $client->GetX());
        $client->SetBucket("hub_y", $client->GetY()); 
        $client->SetBucket("hub_z", $client->GetZ());
        $client->SetBucket("hub_zone", $client->GetZoneID());
        $client->Message(0, "Abraxxus tells you, Very well. You are now attuned");
    } elsif ($text=~/Buffs/i) {
        ShowBuffMenu($client);
    } elsif ($text=~/bufftier_(\d+)/i) {
        HandleBuffTier($client, $1);
    } elsif ($text=~/Price/i) {
        ListBuffPrices();
    } elsif ($text=~/teleport/i) {
        ShowTeleportMenu($client);
    } elsif ($text=~/group/i) {
        ShowTeleportMenu($client, 1)
    }
}

# Show teleport menu filtered by level and flag
sub ShowTeleportMenu {
    my ($client, $is_group) = @_;
    $is_group ||= 0;
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
    my $group_count = $is_group ? getGroupRaidCount($client) : 1;
    my $link = "";
    foreach my $loc (@eligible) {
        if ($is_group && $group_count > 1) {
            $link = quest::saylink("teleport_group_$idx", 1, $loc->{name});
        } else {
            $link = quest::saylink("teleport_$idx", 1, $loc->{name});
        }
        my $cost_text = " (" . ($loc->{price} * $group_count) . " $currency_name)";
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

sub EVENT_POPUPRESPONSE {
    if ($popupid == 998) {
        HandleBuffBot();
    } elsif ($popupid >= 2000 && $popupid < 3000) {
        # Teleport selection
        if (defined $client->{is_group_teleport} && $client->{is_group_teleport}) {
            HandleGroupTeleport($client, $popupid);
            $client->{is_group_teleport} = 0;
        } else {
            HandleTeleport($client, $popupid);
        }
    }

}