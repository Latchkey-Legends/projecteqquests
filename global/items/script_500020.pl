# Handle Clicking AA Tokens
sub EVENT_ITEM_CLICK {
    quest::emote("You have clicked on the item!".$itemid);
    if($itemid == 500020) {                 # 25 token
        quest::emote("Zork!");
        $client->AddAAPoints(25);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500021) {            # 50 token
        quest::emote("Zork!");
        $client->AddAAPoints(50);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500022) {            # 75 token
        quest::emote("Zork!");
        $client->AddAAPoints(75);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500023) {            # 100 token
        quest::emote("Zork!");
        $client->AddAAPoints(100);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500024) {            # 250 token
        quest::emote("Zork!");      
        $client->AddAAPoints(250);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500025) {            # 500 token
        quest::emote("Zork!");  
        $client->AddAAPoints(500);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500026) {            # 750 token
        quest::emote("Zork!");  
        $client->AddAAPoints(750);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500027) {            # 1000 token
        quest::emote("Zork!");  
        $client->AddAAPoints(1000);
        $client->RemoveItem($itemid, 1);
    }elsif($itemid == 500028) {            # 2000 token
        quest::emote("Zork!");  
        $client->AddAAPoints(2000);
        $client->RemoveItem($itemid, 1);
    } elsif($itemid == 500029) {            # 5000 token
        quest::emote("Zork!");  
        $client->AddAAPoints(5000);
        $client->RemoveItem($itemid, 1);
    } else {
        quest::emote("does not know what to do with this item.");
        return;
    }
}