use lib '.';
my $config_loans = plugin::loan_config();

# EVENT_SPAWN: Set depop timer using config
sub EVENT_SPAWN {
    my $depop_minutes = $config_loans->{SUPER_MOB_DEPOP_MINUTES} // 3;
    #quest::debug("SUPER_MOB_DEPOP_MINUTES: $depop_minutes");
    my $depop_seconds = $depop_minutes * 60;
    quest::shout("I finnaly found you! Your time is up!");
    quest::settimer('depop', $depop_seconds);
}

# EVENT_TIMER: Depop all supermobs when timer fires
sub EVENT_TIMER {
    #quest::debug("EVENT_TIMER fired for: '$timer'");
    if ($timer eq 'depop') {
        quest::stoptimer('depop');
        quest::debug("Depop timer fired. Attempting to depop all supermobs with ID: $config_loans->{SUPER_MOB_NPC_ID}");
        $npc->Depop(0);
    }
}

sub EVENT_SLAY { 
    $npc->Depop(0);
}