function event_enter_zone(e)
    eq.set_timer("daylight", 60000); -- every 60 seconds
    eq.set_time(9, 0);
end

function event_timer(e)
    if e.timer == "daylight" then
        eq.set_time(9, 0);
    end
end