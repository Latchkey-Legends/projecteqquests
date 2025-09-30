sub format_time {
    my ($seconds) = @_;
    $seconds = int($seconds);
    my $hours = int($seconds / 3600);
    my $minutes = int(($seconds % 3600) / 60);
    my $secs = $seconds % 60;
    return sprintf("%02dh %02dm %02ds", $hours, $minutes, $secs);
}
1;
