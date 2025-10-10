sub EVENT_SCALE_CALC {
  my $int = $client->GetINT();
    
  if($int < 0) {
    $int = 0;
  }
  quest::debug("Setting scale of itemid " . $itemid . " to " . ($int/300) . " based on INT of $int");

  $questitem->SetScale(1333);
}