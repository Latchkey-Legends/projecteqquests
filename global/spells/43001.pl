sub EVENT_SPELL_EFFECT_CLIENT {
	my $hubx = $client->GetBucket("hub_x");
	my $huby = $client->GetBucket("hub_y");
	my $hubz = $client->GetBucket("hub_z");
	my $hubzone = $client->GetBucket("hub_zone");
	quest::movepc($hubzone, $hubx, $huby, $hubz, 0);
}