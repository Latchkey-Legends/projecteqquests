sub EVENT_SAY {
	quest::debug("Zoneln: $zoneln, ZoneSN: $zonesn");
	plugin::OfferInstance($zoneln, 1, 72, $zonesn);
}

sub EVENT_SPAWN {
	quest::debug("Instanceversion: $instanceversion");
	quest::debug("InstanceID: $instanceid");
	if ($instanceid > 0) {
		$npc->Depop();
	}
}