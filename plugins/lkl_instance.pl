# Latchkey Legends Instance Utility Plugin
# Provides standard instance/expedition offering for NPCs

use POSIX qw(ceil);

sub OfferInstance {
    my $client = plugin::val('$client');
    my $npc = plugin::val('$npc');
    my $text = plugin::val('$text');
    my $zonesn = plugin::val('$zonesn');
    my $dz_version = 0;
    my $instance_duration = 12 * 60 * 60; # 12 hours
    my $dz_lifetime = 7 * 24 * 60 * 60; # 7 days
    my ($expedition_name, $min_players, $max_players, $dz_zone, $x, $y, $z, $heading) = @_;

    if ($text =~ /hail/i) {
        my $dz = $client->GetExpedition();
        if ($dz && $dz->GetName() eq $expedition_name) {
            my $ready_link = quest::silent_saylink("ready");
            plugin::NPCTell("When you are [$ready_link], proceed into the portal.");
        } else {
            plugin::NPCTell("I offer you an instance: $expedition_name. Do you accept the challenge?");
            my $accept_link = quest::silent_saylink("accept");
            plugin::YellowText("Click [$accept_link] to begin your instance.");
        }
    } elsif ($text eq "accept") {
        quest::debug("Creating instance: $expedition_name, Zone: $dz_zone, Version: $dz_version, DZ_lifetime: $dz_lifetime");
        my $dz = $client->CreateExpedition($dz_zone, $dz_version, $dz_lifetime, $expedition_name, $min_players, $max_players);
        if ($dz) {
            my $ready_link = quest::silent_saylink("ready");
            $dz->SetCompass($zonesn, $npc->GetX(), $npc->GetY(), $npc->GetZ());
			$dz->SetSafeReturn($zonesn, $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());

            plugin::NPCTell("Instance created! When you are [$ready_link], proceed into the portal.");
        } else {
            plugin::NPCTell("Failed to create instance. Please try again later.");
        }
    } elsif ($text eq "ready") {
        my $dz = $client->GetExpedition();
        quest::debug("DZ Name: $expedition_name, Zone: $dz_zone, Version: $dz_version, DZ: $dz");

        # Fallback to safe zone coordinates if x, y, z, or heading are not defined
        my $final_x = defined $x ? $x : quest::GetZoneSafeX($dz->GetZoneID());
        my $final_y = defined $y ? $y : quest::GetZoneSafeY($dz->GetZoneID());
        my $final_z = defined $z ? $z : quest::GetZoneSafeZ($dz->GetZoneID());
        my $final_heading = defined $heading ? $heading : quest::GetZoneSafeHeading($dz->GetZoneID());

        
        #$client->MovePC($dz_zone, $x, $y, $z, $heading);
        quest::debug("Teleporting to instance $dz_zone, version $dz_version, instance " . $dz->GetInstanceID() . " at $final_x, $final_y, $final_z, $final_heading");

        $client->MovePCInstance($dz->GetZoneID(), $dz->GetInstanceID(), $final_x, $final_y, $final_z, $final_heading);

    }
}

1;
