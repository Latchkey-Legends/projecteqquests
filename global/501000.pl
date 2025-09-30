use lib '.';
my $config_loans = plugin::loan_config();

# EVENT_SPAWN: Set depop timer using config
sub EVENT_SPAWN {
    my $depop_ms = ($config_loans->{SUPER_MOB_DEPOP_MINUTES} // 3) * 60 * 1000;
    quest::settimer('depop', $depop_ms);
}

# EVENT_TIMER: Depop all supermobs when timer fires
sub EVENT_TIMER {
    my ($timer_name) = @_;
    if ($timer_name eq 'depop') {
        quest::stoptimer('depop');
        quest::debug("Depop timer fired. Attempting to depop all supermobs with ID: $config_loans->{SUPER_MOB_NPC_ID}");
        quest::depopall($config_loans->{SUPER_MOB_NPC_ID});
    }
}

# EVENT_KILLED: Depop all supermobs if this NPC kills a player
sub EVENT_KILLED {
    my ($killed_entity) = @_;
    if ($killed_entity && $killed_entity->IsClient()) {
        quest::debug("Supermob killed a player. Attempting to depop all supermobs with ID: $config_loans->{SUPER_MOB_NPC_ID}");
        quest::depopall($config_loans->{SUPER_MOB_NPC_ID});
    }
}