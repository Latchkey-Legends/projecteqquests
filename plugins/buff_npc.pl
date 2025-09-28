sub BuffsHash {
    my %hash = (1 => [1, 10, [219, 279, 269, 266, 40, 39, 697, 278, 46, 129, 13], 0],
    2 => [11, 20, [89, 283, 148, 2512, 147, 170, 174, 278, 46, 432, 13], 5],
    3 => [21, 30, [244, 149, 148, 349, 151, 10, 1693, 4054, 356, 13], 10],
    4 => [31, 40, [312, 161, 160, 152, 153, 171, 1694, 169, 1727, 13], 25],
    5 => [41, 50, [4053, 158, 154, 157, 159, 172, 1695, 2517, 1560, 13], 50],
    6 => [51, 60, [1447, 1580, 1579, 1596, 1581, 1729, 2570, 2517, 1561, 13], 125],
    7 => [61, 65, [3467, 3397, 4883, 3234, 1710, 3350, 2519, 2517, 3448, 13], 250],
    8 => [66, 70, [27032, 14284, 3472, 3479, 5415, 5355, 5352, 3178, 5513, 3444, 3185, 27032, 25230, 26317, 25443, 25470, 13, 432], 500]);
    return %hash;
}

sub ListBuffPrices {
    my %h = plugin::BuffsHash();
    my @a;
    foreach my $key (sort {$a <=> $b} keys %h) {
        push @a, "$h{$key}[0] to $h{$key}[1]: $h{$key}[3] Platinum";
    }
    quest::popup("Buff Prices", join("<br>", @a));
}

sub GetBuffCost {
    my $ulevel = plugin::val('ulevel');
    my %h = plugin::BuffsHash();
    foreach my $key (sort {$a <=> $b} keys %h) {
        if ($ulevel >= $h{$key}[0] && $ulevel <= $h{$key}[1]) {
            return $h{$key}[3];
        }
    }
}

sub HandleBuffBot {
    my $ulevel = plugin::val('ulevel');
    my $npc = plugin::val('npc');
    my $client = plugin::val('client');
    my %buffsHash = plugin::BuffsHash();
    if (!$client->GetGroup()) {
        foreach my $k (keys %buffsHash) {
            if ($ulevel >= $buffsHash{$k}[0] && $ulevel <= $buffsHash{$k}[1]) {
                if ($client->TakeMoneyFromPP($buffsHash{$k}[3] * 1000, 1)) {
                    quest::selfcast($_) for @{$buffsHash{$k}[2]};
                } else {
                    plugin::Whisper("You cannot afford buffs, they cost $buffsHash{$k}[3] Platinum for your level!");
                    return;
                }
            }
        }
    } else {
        foreach my $k (keys %buffsHash) {
            if ($ulevel >= $buffsHash{$k}[0] && $ulevel <= $buffsHash{$k}[1]) {
                if ($client->TakeMoneyFromPP($buffsHash{$k}[3] * 1000, 1)) {
                    for ($i = 0; $i < 6; $i++) {
                        if ($client->GetGroup()->GetMember($i) && $client->GetGroup()->GetMember($i)->IsClient()) {
                            $client->GetGroup()->GetMember($i)->SpellFinished($_, $client, 0) for @{$buffsHash{$k}[2]};
                        }
                    }
                } else {
                    plugin::Whisper("You cannot afford buffs, they cost $buffsHash{$k}[3] Platinum for your level!");
                    return;
                }
            }
        }
    }
    plugin::Whisper("Enjoy your buffs!");
}