# Class-to-items configuration
my %class_init_items = (
    Warrior        => [500100, 500200],
    Paladin        => [500100, 500242, 500244],
    Shadowknight   => [500100, 500296, 500298],
    Cleric         => [500115, 500341, 500342],
    Druid          => [500115, 500371, 500372],
    Shaman         => [500115, 500401, 500402],
    Ranger         => [500115, 500431],
    Bard           => [500115, 500476, 500477],
    Rogue          => [500115, 500506, 500507],
    Monk           => [500115, 500536, 500537],
    Beastlord      => [1101, 1102, 1103],
    Berserker      => [1111, 1112, 1113],
    Wizard         => [1121, 1122, 1123],
    Magician       => [1131, 1132, 1133],
    Enchanter      => [1141, 1142, 1143],
    Necromancer    => [1151, 1152, 1153],
);

%sigil_upgrades = (#  1-5   6-10    11-15   16-20   21-25   26-30   31-35   36-40   41-45   46-50   51-55   56-60   61-65   66-69     70
    tank        => [500100, 500101, 500102, 500103, 500104, 500105, 500106, 500107, 500108, 500109, 500110, 500111, 500112, 500113, 500114],
    dpshealer   => [500115, 500116, 500117, 500118, 500119, 500120, 500121, 500122, 500123, 500124, 500125, 500126, 500127, 500128, 500129],
);
                     # Bent    Rusty   Dirty   Worn    Tarn    Weath   Sharp   Forged  Runed   Imbued  Emp     Supurb  Mythic  Epic    Legendary
%weapon_upgrades = ( # 1-5     6-10    11-15   16-20   21-25   26-30   31-35   36-40   41-45   46-50   51-55   56-60   61-65   66-69     70 
    Warrior        => [500200, 500203, 500206, 500209, 500212, 500215, 500221, 500224, 500227, 500230, 500233, 500290, 500236, 500293, 500239], # Warblade
    Paladin        => [500242, 500245, 500248, 500251, 500254, 500257, 500263, 500266, 500269, 500272, 500275, 500278, 500281, 500013, 500014], # Oathblade
    Shadowknight   => [500296, 500299, 500302, 500305, 500308, 500311, 500314, 500317, 500320, 500323, 500326, 500329, 500332, 500335, 500338], # Nightblade
    Cleric         => [500341, 500343, 500345, 500347, 500349, 500351, 500353, 500355, 500357, 500359, 500361, 500363, 500365, 500367, 500369], # Foestriker
    Druid          => [500371, 500373, 500375, 500377, 500379, 500381, 500383, 500385, 500387, 500389, 500391, 500393, 500395, 500397, 500399], # Leafblade
    Shaman         => [500401, 500403, 500405, 500407, 500409, 500411, 500413, 500415, 500417, 500419, 500421, 500423, 500425, 500427, 500429], # Writhing Spear
    Ranger         => [500431, 500434, 500437, 500440, 500443, 500446, 500449, 500452, 500455, 500458, 500461, 500464, 500467, 500470, 500473],
    Bard           => [500476, 500478, 500480, 500482, 500484, 500486, 500488, 500490, 500492, 500494, 500496, 500498, 500500, 500502, 500504],
    Rogue          => [500506, 500508, 500510, 500512, 500514, 500516, 500518, 500520, 500522, 500524, 500526, 500528, 500530, 500532, 500534],
    Monk           => [500536, 500538, 500540, 500542, 500544, 500546, 500548, 500550, 500552, 500554, 500556, 500558, 500560, 500562, 500564],
    Beastlord      => [500566, 500568, 500570, 500572, 500574, 500576, 500578, 500580, 500582, 500584, 500586, 500588, 500590, 500592, 500594],
    Berserker      => [500716, 500717, 500718, 500719, 500720, 500721, 500722, 500723, 500724, 500725, 500726, 500727, 500728, 500729, 500730],
    Wizard         => [500596, 500598, 500600, 500602, 500604, 500606, 500608, 500610, 500612, 500614, 500616, 500618, 500620, 500622, 500624],
    Magician       => [500626, 500628, 500630, 500632, 500634, 500636, 500638, 500640, 500642, 500644, 500646, 500648, 500650, 500652, 500654],
    Enchanter      => [500656, 500658, 500660, 500662, 500664, 500666, 500668, 500670, 500672, 500674, 500676, 500678, 500680, 500682, 500684],
    Necromancer    => [500686, 500688, 500690, 500692, 500694, 500696, 500698, 500700, 500702, 500704, 500706, 500708, 500710, 500712, 500714],
);
                     # Bent    Rusty   Dirty   Worn    Tarn    Weath   Sharp   Forged  Runed   Imbued  Emp     Supurb  Mythic  Epic    Legendary
%offhand_upgrades = (# 1-5     6-10    11-15   16-20   21-25   26-30   31-35   36-40   41-45   46-50   51-55   56-60   61-65   66-69     70
#    Warrior        => [500202, 500205, 500208, 500211, 500214, 500217, 500220, 500223, 500226, 500229, 500232, 500235, 500238, 500241, 500292, 500295],
    Paladin        => [500244, 500247, 500250, 500253, 500256, 500259, 500265, 500268, 500271, 500274, 500277, 500280, 500283, 500286, 500289], # Shield of the vindicator
    Shadowknight   => [500298, 500301, 500304, 500307, 500310, 500313, 500316, 500319, 500322, 500325, 500328, 500331, 500334, 500337, 500340], 
    Cleric         => [500342, 500344, 500346, 500348, 500350, 500352, 500354, 500356, 500358, 500360, 500362, 500364, 500366, 500368, 500370],
    Druid          => [500372, 500374, 500376, 500378, 500380, 500382, 500384, 500386, 500388, 500390, 500392, 500394, 500396, 500398, 500400], # Gardener
    Shaman         => [500402, 500404, 500406, 500408, 500410, 500412, 500414, 500416, 500418, 500420, 500422, 500424, 500426, 500428, 500430], # Shield of Venom
#    Ranger         => [500000, 500001, 500002, 500003, 500004, 500005, 500006, 500007, 500008, 500009, 500010, 500011, 500012, 500013, 500014],
    Bard           => [500477, 500479, 500481, 500483, 500485, 500487, 500489, 500491, 500493, 500495, 500497, 500499, 500501, 500503, 500505],
    Rogue          => [500507, 500509, 500511, 500513, 500515, 500517, 500519, 500521, 500523, 500525, 500527, 500529, 500531, 500533, 500535],
    Monk           => [500537, 500539, 500541, 500543, 500545, 500547, 500549, 500551, 500553, 500555, 500557, 500559, 500561, 500563, 500565],
    Beastlord      => [500567, 500569, 500571, 500573, 500575, 500577, 500579, 500581, 500583, 500585, 500587, 500589, 500591, 500593, 500595],
#    Berserker      => [500000, 500001, 500002, 500003, 500004, 500005, 500006, 500007, 500008, 500009, 500010, 500011, 500012, 500013, 500014],
    Wizard         => [500597, 500599, 500601, 500603, 500605, 500607, 500609, 500611, 500613, 500615, 500617, 500619, 500621, 500623, 500625],
    Magician       => [500627, 500629, 500631, 500633, 500635, 500637, 500639, 500641, 500643, 500645, 500647, 500649, 500651, 500653, 500655],
    Enchanter      => [500657, 500659, 500661, 500663, 500665, 500667, 500669, 500671, 500673, 500675, 500677, 500679, 500681, 500683, 500685],
    Necromancer    => [500687, 500689, 500691, 500693, 500695, 500697, 500699, 500701, 500703, 500705, 500707, 500709, 500711, 500713, 500715],
);

my %class_hash = (
    Warrior        => 1,
    Paladin        => 1,
    Shadowknight   => 1,
    Beastlord      => 1,
    Magician       => 1,
    Necromancer    => 1,
    Cleric         => 0,
    Druid          => 0,
    Shaman         => 0,
    Ranger         => 0,
    Bard           => 0,
    Rogue          => 0,
    Monk           => 0,
    Berserker      => 0,
    Wizard         => 0,
    Enchanter      => 0,
);

sub get_upgrade_index_for_level {
    my ($level) = @_;
    return 0 if $level >= 1  && $level <= 5;
    return 1 if $level >= 6  && $level <= 10;
    return 2 if $level >= 11 && $level <= 15;
    return 3 if $level >= 16 && $level <= 20;
    return 4 if $level >= 21 && $level <= 25;
    return 5 if $level >= 26 && $level <= 30;
    return 6 if $level >= 31 && $level <= 35;
    return 7 if $level >= 36 && $level <= 40;
    return 8 if $level >= 41 && $level <= 45;
    return 9 if $level >= 46 && $level <= 50;
    return 10 if $level >= 51 && $level <= 55;
    return 11 if $level >= 56 && $level <= 60;
    return 12 if $level >= 61 && $level <= 65;
    return 13 if $level >= 66 && $level <= 69;
    return 14 if $level == 70;
    return -1; # Not in any bracket
}

sub find_upgrade_table_and_class {
    my ($itemid) = @_;

    my @tables = (
        { ref => \%sigil_upgrades, name => 'sigil_upgrades' },
        { ref => \%weapon_upgrades, name => 'weapon_upgrades' },
        { ref => \%offhand_upgrades, name => 'offhand_upgrades' },
    );

    foreach my $table (@tables) {
        my $hash = $table->{ref};
        foreach my $class (keys %$hash) {
            my $items = $hash->{$class};
            # $items is an arrayref
            for my $i (0 .. $#$items) {
                if ($items->[$i] == $itemid) {
                    return ($table->{ref}, $class);
                }
            }
        }
    }
    return (undef, undef); # Not found
}

sub get_item_to_upgrade {
    my ($client, $handin_item_id) = @_;
    my $class = $client->GetClassName();
    my $level = $client->GetLevel();
    my $upgrade_index = get_upgrade_index_for_level($level);
    my $sigil_type = ($class_hash{$class}) ? 'tank' : 'dpshealer';
    my ($upgrade_table, $found_class) = find_upgrade_table_and_class($handin_item_id);
    my $upgrade_item_id = $upgrade_table->{$found_class}->[$upgrade_index];
    quest::debug("====================================================");
    quest::debug("HANDIN ID: $handin_item_id");
    quest::debug("CLASS: $class");
    quest::debug("Sigil Type: $sigil_type");
    quest::debug("LEVEL: $level");
    quest::debug("UPGRADE INDEX: $upgrade_index");
    quest::debug("UPGRADE ITEM: " . $upgrade_item_id);

    if($handin_item_id == $upgrade_item_id) {
        quest::debug("No upgrade available for this item at your current level.");
        return -1; # No upgrade available
    } elsif (!defined $upgrade_item_id) {
        quest::debug("I dont recognize that item for upgrades.");
        return -2; # Not found
    } else {
        return $upgrade_item_id; # Return the upgrade item ID
    }
}

# List of tank classes
my %tank_classes = map { $_ => 1 } qw(Warrior Paladin Shadowknight Necromancer Magician Beastlord);


# Faeryl.pl - Perl conversion of Faeryl.lua

sub EVENT_SAY {
    my $unboxed_flag = $client->GetBucket("unboxed");
    if ($unboxed_flag == "") { $unboxed_flag = "0"; }   # Set unboxed flag to zero if not defined.

    if ($text =~ /hail/i) {
        if ($unboxed_flag eq "0") {
            # Not Flagged as unboxed
            $client->Message(MT.White, "Faeryl says, Greetings, $name. I can offer you a path others may not choose to take. Would you like to hear " . quest::saylink("more", 0, "more") . "?");
        } elsif ($unboxed_flag eq "1") {
            # Already flagged as unboxed.
            $client->Message(MT.White, "Faeryl says, Welcome back $name. Hand me the items one at time that I gave you when we first met, and I will see if they have newer potential.");
        }
    } elsif ($text =~ /more/i) {
        #$client->Message(15, "Faeryl says, This path is not for everyone, the few, the strong, The Unboxed.");
        my $ub_text = plugin::PWColor("Yellow") . "Unboxed</c>";

        # In character Message
        my $popup_message   = "Faeryl says, I can offer you a path others may not choose to take. This path is not for everyone, the few, strong, The " . $ub_text . ".<br> ";
        $popup_message     .= "Becoming " . $ub_text . " will grant you the ability to achieve immense power, but you will not be able to group with others from your location. ";
        $popup_message     .= "You WILL be able to group with other members of the " . $ub_text . ". ";
        $popup_message     .= "Following this path will grant you weapons, armor, spells, items and AA's not available to the boxed.<br> ";
        $popup_message     .= "These items are of extreme power, and will allow you to rival the power of The Boxed ones. These items will be attuned to you, and grow in power as you grow in power. ";
        $popup_message     .= "Come back to me when you have gained some power and we will see if the items I give you have grown along with you.<br>"; 
        $popup_message     .= "But be warned, if you choose this path, you can never return. ";
        $popup_message     .= "Once you are " . $ub_text . ", no god or GM can return you to one of the Boxed.<br>Would you like to become " . $ub_text . "? ";
        $popup_message     .= "<br><br>" . plugin::PWColor("Orange");

        # OOC Message
        $popup_message     .= "OOC: Becoming unboxed means you will get a flag that will not allow you to box with this character. You will be booted out of groups if you are running more than one client. ";
        $popup_message     .= "Once you flag yourself as unboxed, it cannot be undone. This character will be boxed forever. ";
        
        $popup_message     .= "</c>";
        quest::popup("The Unboxed", $popup_message, 666, 1);
        #quest::popup("The Unboxed", "Once you flag yourself as unboxed, it cannot be undone. This character will be boxed forever. </c>", 666, 10);

        #quest::popup("The Unboxed", "Faeryl says, I can offer you a path others may not choose to take. This path is not for everyone, the few, strong, The " . plugin::PWColor("Yellow") . "Unboxed</c>. Becoming " . plugin::PWColor("Yellow") . "Unboxed</c> will grant you the ability to achieve immense power, but you will not be able to group with others from your location. You WILL be able to group with other members of the " . plugin::PWColor("Yellow") . "Unboxed</c>. Following this path will grant you weapons, armor, spells, items and AA's not available to the boxed. These items are of extreme power, and will allow you to rival the power of The Boxed ones. But be warned, if you choose this path, you can never return. Once you are " . plugin::PWColor("Yellow") . "Unboxed</c>, no god or GM can return you to one of the Boxed.<br>Would you like to become " . plugin::PWColor("Yellow") . "Unboxed</c>?<br><br>" . plugin::PWColor("Orange") . "OOC: Becoming unboxed means you will get a flag that will not allow you to box with this character. You will be booted out of groups if you are running more than one client. Once you flag yourself as unboxed, it cannot be undone. This character will be boxed forever. </c>", 666, 10);
    }
}

# sub EVENT_SAY {
#     my $unboxed_flag = $client->GetBucket("unboxed");
#     if ($text =~ /Hail/i) {
#         if (defined $unboxed_flag && $unboxed_flag eq "0") {
#             $client->Message(15, "Faeryl says, Greetings, $name. I can offer you a path others may not choose to take. Would you like to hear " . quest::saylink("more", 0, "more") . "?");
#             #$client->Message(0, "Faeryl says, Greetings, $name. I can offer you a path others may not choose to take. Would you like to hear ".. quest::saylink("more", 0, "more") ."?");
#             #quest::popup("The Unboxed", "Faeryl says, I can offer you a path others may not choose to take. This path is not for everyone, the few, strong, The <c yellow>Unboxed</c>. Becoming <c yellow>Unboxed</c> will grant you the ability to achieve immense power, but you will not be able to group with others from your location. You WILL be able to group with other members of the <c yellow>Unboxed</c>. Following this path will grant you weapons, armor, spells, items and AA's not available to the boxed. These items are of extreme power, and will allow you to rival the power of The Boxed ones. But be warned, if you choose this path, you can never return. Once you are <c yellow>Unboxed</c>, no god or GM can return you to one of the Boxed.<br>Would you like to become <c yellow>Unboxed</c>?<br><br><c orange>OOC: Becoming unboxed means you will get a flag that will not allow you to box with this character. You will be booted out of groups if you are running more than one client. Once you flag yourself as unboxed, it cannot be undone. This character will be boxed forever. </c>", 666, 10);
#         } elsif (defined $unboxed_flag && $unboxed_flag eq "1") {
#             $client->Message(15, "You are already unboxed.");
#         }
#     } elsif ($text =~ /more/i) {
#     $client->Message(15, "Faeryl says, This path is not for everyone, the few, the strong, The Unboxed.");
#     }
# }

sub handle_init_items {
    my $class = $client->GetClassName();
    my $items = $class_init_items{$class};
    $client->Message(MT.White, "Faeryl says, Take these items, and remember to come back after you have grown stronger, I will replace them with more powerfull ones to match your strength.");
    if ($items) {
        foreach my $itemid (@$items) {
            $client->SummonItem($itemid, 1);
            #$client->Message(MT.White, "You are a $class and will get item ID: $itemid");
        }
        
    } else {
        $client->Message(13, "Faeryl says, I do not h5 contact a GM.");
    }
}

# Configuration: Level ranges and item IDs for tank and dps/healer classes

sub handle_upgrade_sigil {
    $lvl_upgrade_index = get_upgrade_index_for_level($client->GetLevel());
    quest::debug("Char Level is " . $client->GetLevel());
    quest::debug("Level upgrade index is $lvl_upgrade_index");
    quest::debug("Class is " . $client->GetClassName());
    if (exists $tank_classes{$client->GetClassName()}) {
        # Tank class
        quest::debug("DEBUG: You are a tank class.");
        my $upgrade_itemid = $sigil_upgrades{tank}->[$lvl_upgrade_index];
        quest::debug("DEBUG: Upgrade item ID is $upgrade_itemid");
    } else {
        # DPS/Healer class
        quest::debug("DEBUG: You are a dps/healer class.");
        my $upgrade_itemid = $sigil_upgrades{dpshealer}->[$lvl_upgrade_index];
        quest::debug("DEBUG: Upgrade item ID is $upgrade_itemid");
    }
    #my $upgrade_itemid = $class_upgrades{$class}->[$index];
}


sub EVENT_ITEM {
    quest::debug("DEBUG: EVENT_ITEM triggered.");
    my $upgrade_item_id = get_item_to_upgrade($client, $item1);
    if ($upgrade_item_id == -1) {
        $client->Message(MT.White, "Faeryl says, I cannot upgrade that item for you at this time. Please come back when you have gained some strength.");
        plugin::return_items();
    } elsif ($upgrade_item_id == -2) {
        $client->Message(MT.White, "Faeryl says, Please make sure you are handing me the item I gave you, not the transformed one.");
        plugin::return_items();
    } else {
        $client->Message(MT.White, "Faeryl says, I see your item has grown in power along with you! Here is its next evolution.");
        my $handin = {
            required_handin => { $item1 => 1 },
            exp => 1000,
            result_item => $upgrade_item_id,
            message => "Nice!"
        };
        if(quest::handin($handin->{required_handin})) {
            $client->Message(MT.White, $handin->{message});
            $client->AddEXP($handin->{exp} * $client->GetLevel());
            quest::summonitem($handin->{result_item});
        }
        quest::handin($handin);
        # $client->SummonItem($upgrade_item_id, 1);
        return;
    }
    # Handle Sigil Upgrades:
    #handle_upgrade_sigil();

    #plugin::return_items();
}

sub EVENT_POPUPRESPONSE {
    if ($popupid == 666) {
        quest::popup("The Unboxed", "Are you absolutely sure you want to flag yourself as unboxed?<br><br> ". plugin::PWColor("Red") . "This cannot be undone!</c>", 667, 1);
    } elsif ($popupid == 667) {
        # $client->SetBucket("unboxed", "1");
        # #$client->SetTitle(398); # Title: The Unboxed
        # $client->Message(15, "Very well then. You are now unboxed. Take these items, they will help you on your journey. Come back when you have gained some strength and we will see about getting you more powerful items.");
        #$client->SummonItem(500100, 1);
        handle_init_items();
    } else {
        $client->Message(MT.White, "Faeryl says, I see you have chosen not to become unboxed at this time. That is your choice, $name. Come back if you change your mind." );
    }
}

# 1;


