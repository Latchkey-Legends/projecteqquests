function event_killed_merit(e)
    local corpse = e.corpse;
    -- 90% chance to drop item 500005, between 1 and 4
    if math.random() < 0.9 then
        local count = math.random(1, 4)
        corpse:SetDecayTimer(450000); -- Extend corpse time by 30 seconds to ensure currency is added
        if count == 1 then
            corpse:AddItem(500005, 1)
        elseif count == 2 then
            corpse:AddItem(500005, 1)
            corpse:AddItem(500005, 1)
        elseif count == 3 then
            corpse:AddItem(500005, 1)
            corpse:AddItem(500005, 1)
            corpse:AddItem(500005, 1)
        elseif count == 4 then
            corpse:AddItem(500005, 1)
            corpse:AddItem(500005, 1)
            corpse:AddItem(500005, 1)
            corpse:AddItem(500005, 1)
        end
    end
end
