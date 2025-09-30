
sub EVENT_ITEM_CLICK {
    quest::emote("You have clicked on the item!".$itemid);
    # AA Point Tokens
    if ($itemid == 500020) {
        $client->AddAAPoints(25);
        quest::emote("You gain 25 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500021) {
        $client->AddAAPoints(50);
        quest::emote("You gain 50 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500022) {
        $client->AddAAPoints(75);
        quest::emote("You gain 75 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500023) {
        $client->AddAAPoints(100);
        quest::emote("You gain 100 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500024) {
        $client->AddAAPoints(250);
        quest::emote("You gain 250 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500025) {
        $client->AddAAPoints(500);
        quest::emote("You gain 500 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500026) {
        $client->AddAAPoints(750);
        quest::emote("You gain 750 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500027) {
        $client->AddAAPoints(1000);
        quest::emote("You gain 1000 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500028) {
        $client->AddAAPoints(2000);
        quest::emote("You gain 2000 AA points!");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500029) {
        $client->AddAAPoints(5000);
        quest::emote("You gain 5000 AA points!");
        $client->RemoveItem($itemid, 1);
    }

    # EXP Tokens (percentage of current level)
    elsif ($itemid == 500030) {
        my $level = $client->GetLevel();
        my $exp_needed = $client->GetEXPForLevel($level + 1) - $client->GetEXPForLevel($level);
        my $exp_award = int($exp_needed * (1 / 100));
        $client->AddEXP($exp_award);
        quest::emote("You gain 1% of a level's experience! (" . $exp_award . " EXP)");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500031) {
        my $level = $client->GetLevel();
        my $exp_needed = $client->GetEXPForLevel($level + 1) - $client->GetEXPForLevel($level);
        my $exp_award = int($exp_needed * (5 / 100));
        $client->AddEXP($exp_award);
        quest::emote("You gain 5% of a level's experience! (" . $exp_award . " EXP)");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500032) {
        my $level = $client->GetLevel();
        my $exp_needed = $client->GetEXPForLevel($level + 1) - $client->GetEXPForLevel($level);
        my $exp_award = int($exp_needed * (10 / 100));
        $client->AddEXP($exp_award);
        quest::emote("You gain 10% of a level's experience! (" . $exp_award . " EXP)");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500033) {
        my $level = $client->GetLevel();
        my $exp_needed = $client->GetEXPForLevel($level + 1) - $client->GetEXPForLevel($level);
        my $exp_award = int($exp_needed * (15 / 100));
        $client->AddEXP($exp_award);
        quest::emote("You gain 15% of a level's experience! (" . $exp_award . " EXP)");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500034) {
        my $level = $client->GetLevel();
        my $exp_needed = $client->GetEXPForLevel($level + 1) - $client->GetEXPForLevel($level);
        my $exp_award = int($exp_needed * (20 / 100));
        $client->AddEXP($exp_award);
        quest::emote("You gain 20% of a level's experience! (" . $exp_award . " EXP)");
        $client->RemoveItem($itemid, 1);
    } elsif ($itemid == 500035) {
        my $level = $client->GetLevel();
        my $exp_needed = $client->GetEXPForLevel($level + 1) - $client->GetEXPForLevel($level);
        my $exp_award = int($exp_needed * (25 / 100));
        $client->AddEXP($exp_award);
        quest::emote("You gain 25% of a level's experience! (" . $exp_award . " EXP)");
        $client->RemoveItem($itemid, 1);
    } else {
        quest::emote("does not know what to do with this item.");
    }
}