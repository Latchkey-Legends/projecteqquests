sub EVENT_SAY {
    if ($text=~/hail/i) {
        $client->Message(0, "Jusith says, 'Greetings, $name. I am Jusith, I may have some quests available for you.");
        quest::taskselector(550024);
    }
}