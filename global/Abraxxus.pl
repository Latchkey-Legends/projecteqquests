sub EVENT_SAY {    
    if ($text=~/Hail/i) {
        plugin::Whisper("Hello $name, would you like some " . quest::saylink("buffs", 1) . "? Keep in mind, the " . quest::saylink("price", 1) . " of these buffs increases as you level.");
    } elsif ($text=~/Buffs/i) {
        quest::popup("Confirmation Window", "Are you sure you would like to purchase buffs?<br><font color ='#00FFFF'>Level $ulevel buffs cost " . plugin::GetBuffCost() . " Platinum.</font>", 998, 1);
    } elsif ($text=~/Price/i) {
        plugin::ListBuffPrices();
    }
}

sub EVENT_POPUPRESPONSE {
    plugin::HandleBuffBot();
}