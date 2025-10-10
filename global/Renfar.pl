# Hash mapping EQ classes to item IDs
my %epic_weapons_quests = (
    Warrior      => 550022,
    Paladin      => 550017,
    Shadowknight => 550020,
    Cleric       => 550011,
    Druid        => 550012,
    Shaman       => 550021,
    Ranger       => 550018,
    Bard         => 550008,
    Rogue        => 550019,
    Monk         => 550015,
    Beastlord    => 550009,
    Berserker    => 550010,
    Wizard       => 550023,
    Magician     => 550014,
    Enchanter    => 550013,
    Necromancer  => 550016,
);

my $plate_itemid = 502001; # Replace with your item ID
my $caster_itemid = 502023; # Replace with your item ID

sub show_swapable_items {
    my ($client) = @_;
    my $plate_count = $client->CountItem($plate_itemid);
    my $caster_count = $client->CountItem($caster_itemid);

    if ($plate_count > 0) {
        $client->Message(0, "I see you have a ".quest::varlink($plate_itemid)." in your inventory. Would you like to ".quest::saylink('exchange', 0, 'exchange')." it for the ".quest::varlink($caster_itemid)."?");
    } elsif ($caster_count > 0) {
        $client->Message(0, "I see you have a ".quest::varlink($caster_itemid)." in your inventory. Would you like to ".quest::saylink('exchange', 0, 'exchange')." it for the ".quest::varlink($plate_itemid)."?");
    } else {
        $client->Message(0, "You do not have either the ".quest::varlink($plate_itemid)." or the ".quest::varlink($caster_itemid)." in your inventory to exchange.");
    }
}

sub process_exchange {
    my ($client) = @_;
    my $plate_count = $client->CountItem($plate_itemid);
    my $caster_count = $client->CountItem($caster_itemid);

    if ($plate_count > 0) {
        $client->Message(0, "Exchanging your ".quest::varlink($plate_itemid)." for a ".quest::varlink($caster_itemid).".");
        $client->RemoveItem($plate_itemid, 1);
        $client->SummonItem($caster_itemid, 1);
    } elsif ($caster_count > 0) {
        $client->Message(0, "Exchanging your ".quest::varlink($caster_itemid)." for a ".quest::varlink($plate_itemid).".");
        $client->RemoveItem($caster_itemid, 1);
        $client->SummonItem($plate_itemid, 1);
    } else {
        $client->Message(0, "You do not have either the ".quest::varlink($plate_itemid)." or the ".quest::varlink($caster_itemid)." in your inventory to exchange.");
    }
}

sub process_epic_weapon_quest {
    my ($client) = @_;
    my $class = $client->GetClassName();
    quest::debug("Player class: $class");
    if (exists $epic_weapons_quests{$class}) {
        my $quest_id = $epic_weapons_quests{$class};
        quest::taskselector($quest_id);
    } else {
        $client->Message(0, "Your class does not have an Epic Weapon quest available.");
    }
}

sub EVENT_SAY {
    if ($text=~/hail/i) {
        $client->Message(0, "Renfar says, 'Greetings, $name. I am Renfar, I can provide you with Quests for Rank 0.5 ".quest::saylink('Armor', 0, 'Armor')." and ".quest::saylink('Weapons', 0, 'Weapons').".");
        show_swapable_items($client);
    } elsif ($text=~/armor/i) {
        $client->Message(0, "Ah yes, the Latchkey Armor.");
        quest::taskselector(550007);
    } elsif ($text=~/weapons/i) {   
        $client->Message(0, "Ah yes, the Latchkey Weapons.");
        process_epic_weapon_quest($client);
        #quest::taskselector(550008);
    } elsif ($text=~/exchange/i) {
        process_exchange($client);
    }
}