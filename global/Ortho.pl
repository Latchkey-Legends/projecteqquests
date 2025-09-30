# Ortho.pl - Perl conversion of Ortho.lua

my %aa_tokens = (
    500020 => { name => "AA Token: 25", cost => 25 },
    500021 => { name => "AA Token: 50", cost => 50 },
    500022 => { name => "AA Token: 75", cost => 75 },
    500023 => { name => "AA Token: 100", cost => 100 },
    500024 => { name => "AA Token: 250", cost => 250 },
    500025 => { name => "AA Token: 500", cost => 500 },
    500026 => { name => "AA Token: 750", cost => 750 },
    500027 => { name => "AA Token: 1000", cost => 1000 },
    500028 => { name => "AA Token: 2000", cost => 2000 },
    500029 => { name => "AA Token: 5000", cost => 5000 },
);

sub EVENT_SAY {
    my $text = $text;
    if ($text =~ /Hail/i) {
        my $buy_link = quest::saylink('buy AA Tokens', 0, 'buy AA Tokens');
        my $balance_link = quest::saylink('AA balance', 0, 'AA balance');
        $client->Message(0, "Ortho says, 'Greetings! I can exchange your AA points for AA tokens. Would you like to [" . $buy_link . "]? Or I can show you your [" . $balance_link . "].'");
    } elsif ($text =~ /buy AA Tokens/i) {
        show_aa_token_options($client);
    } elsif ($text =~ /AA balance/i) {
        show_aa_balance($client);
    } else {
        foreach my $itemid (keys %aa_tokens) {
            if ($text =~ /buy_$itemid/i) {
                buy_aa_token($client, $itemid);
                return;
            }
        }
    }
}

sub show_aa_balance {
    my ($client) = @_;
    my $aa_points = $client->GetAAPoints();
    $client->Message(0, "Ortho says, 'You currently have $aa_points AA points.'");
}

sub show_aa_token_options {
    my ($client) = @_;
    $client->Message(0, "Ortho says, 'Select the AA token you wish to purchase:'");
    # Sort tokens by cost
    foreach my $itemid (sort { $aa_tokens{$a}->{cost} <=> $aa_tokens{$b}->{cost} } keys %aa_tokens) {
        my $info = $aa_tokens{$itemid};
        my $link = quest::saylink("buy_$itemid", 0, "$info->{name} ($info->{cost} AA points)");
        $client->Message(0, $link);
    }
}

sub buy_aa_token {
    my ($client, $itemid) = @_;
    my $info = $aa_tokens{$itemid};
    return unless $info;
    my $aa_points = $client->GetAAPoints();
    if ($aa_points < $info->{cost}) {
        $client->Message(0, "Ortho says, 'You do not have enough AA points for this token.'");
        return;
    }
    my $remaining = $aa_points - $info->{cost};
    $client->SetAAPoints($remaining);
    $client->Message(0, "Ortho says, 'You have purchased $info->{name}, and have $remaining remaining AA points.'");
    $client->SummonItem($itemid, 1);
}

1;
