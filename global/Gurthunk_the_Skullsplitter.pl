sub EVENT_SAY {
    if($text=~/hail/i) {
        #quest::say("Greetings, $name. I am Gurthunk the Skullsplitter, chieftain of the Bonegrinders. We are a tribe of orcs who have chosen to live apart from the rest of our kind, seeking a more peaceful existence here in the wilds. We value strength and honor above all else, and we welcome those who share our ideals. If you are looking for a place to call home, perhaps you would consider joining us. We are always in need of strong warriors to help defend our tribe and our way of life.");
        $client->Message(0, "Gurthunk Says, Hey der $name, Me Gurthunk. You new here in dis land? I can ". quest::saylink("tell", 0, "tell") . " you about it if you are.");
    } elsif($text=~/tell/i) {
        $client->Message(0, "Gurthunk Says, Dis here be da land of da Latchkey Legends. It still be Norrath, but it be a little different. Dere be new " . quest::saylink("monies", 0, "monies"). " here, and new ways to gain da ". quest::saylink("aa points", 0, "aa points"). " too. Der also be ". quest::saylink("dungeon quests", 0, "dungeon quests"). " dat you can do for da loots.");

    } elsif($text=~/monies/i) {
        $client->Message(0, "Gurthunk Says, Go talk to Zork over der, he be a runty gnome, but he know all about da monies.");

    } elsif($text=~/aa points/i) {
        $client->Message(0, "Gurthunk Says, Ortho be da one you want to talk to about aa points. He be da expert on dem.");

    } elsif($text=~/dungeon quests/i) {
        $client->Message(0, "Gurthunk Says, Deez my favorite, you go, kill some critters, come back and get some lootz and monies and expereince is da best part! Then go back an do again! Go talk to Hasgath. Puny dwarf, but he be da best at giving out deez quests.");
    }
}