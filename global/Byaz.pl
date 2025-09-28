sub EVENT_SAY {    
    if ($text=~/Hail/i) {
        #plugin::Whisper("Hello $name, would you like some " . quest::saylink("buffs", 1) . "? Keep in mind, the " . quest::saylink("price", 1) . " of these buffs increases as you level.");
        plugin::Whisper("Hello $name, I can provide a teleport to " . quest::saylink("East Commonlands", 1) . " for free.")
    } elsif ($text=~/East Commonlands/i) {
        quest::movepc(22, -202.0, -1561.0, 5.99); # Example coordinates
    }
}

sub EVENT_ITEM {
    #:: Return unused items
    plugin::returnUnusedItems();
}