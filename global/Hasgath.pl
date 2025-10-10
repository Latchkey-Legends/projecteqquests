sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::say("Greetings, $name. I am Hasgath, a humble servant of the Lenders Guild. If you find yourself in need of financial assistance, do not hesitate to seek my aid. Remember, all loans must be repaid in due time.");
        quest::taskselector(550001, 550002, 550003, 550004, 550005); # Example task IDs
    }
}

sub EVENT_TASK_COMPLETE {
    quest::debug("Yar, completed then eh?");
    #quest::debug("Player completed a task! Task ID: $task_id, Activity ID: $activity_id, Done Count: $donecount");
    # Add your reward or completion logic here
}