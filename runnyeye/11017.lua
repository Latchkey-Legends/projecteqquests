-- function event_spawn(e)
-- 	eq.set_timer("depop",3600000);
-- end

-- function event_timer(e)
-- 	eq.depop_with_timer();
-- end

-- function event_combat(e)
-- 	if(e.joined) then
-- 		if(not eq.is_paused_timer("depop")) then
-- 			eq.pause_timer("depop");
-- 		end
-- 	else
-- 		eq.resume_timer("depop");
-- 	end
-- end

function event_killed_merit(e)
    eq.debug("Fired event_killed_merit");
    local corpse = e.corpse;
    -- 80% chance to drop item 500005, between 1 and 4
    if math.random() < 1 then
        local count = math.random(1, 2)
        corpse:SetDecayTimer(450000); -- Extend corpse time by 30 seconds to ensure currency is added
        if count == 1 then
            corpse:AddItem(502042, 1)
        elseif count == 2 then
            corpse:AddItem(502042, 1)
            corpse:AddItem(502042, 1)
        end
    end
end
