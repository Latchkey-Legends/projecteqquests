sub EVENT_SCALE_CALC {
    quest::debug("Setting scale of itemid " . $itemid . " to 1.0");
    $questitem->SetScale(1.0);
}