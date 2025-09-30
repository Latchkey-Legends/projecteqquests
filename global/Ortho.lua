local aa_tokens = {
    [500020] = { name = "AA Token: 25", cost = 25 },
    [500021] = { name = "AA Token: 50", cost = 50 },
    [500022] = { name = "AA Token: 75", cost = 75 },
    [500023] = { name = "AA Token: 100", cost = 100 },
    [500024] = { name = "AA Token: 250", cost = 250 },
    [500025] = { name = "AA Token: 500", cost = 500 },
    [500026] = { name = "AA Token: 750", cost = 750 },
    [500027] = { name = "AA Token: 1000", cost = 1000 },
    [500028] = { name = "AA Token: 2000", cost = 2000 },
    [500029] = { name = "AA Token: 5000", cost = 5000 },
}

function event_say(e)
    if e.message:find('Hail') then
        e.other:Message(0, "Current working directory: " .. (os.getenv("PWD") or "unknown"))
        local buy_link = eq.say_link('buy AA Tokens', false, 'buy AA Tokens')
        local balance_link = eq.say_link('AA balance', false, 'AA balance')
        e.other:Message(0, "Ortho says, 'Greetings! I can exchange your AA points for AA tokens. Would you like to [" .. buy_link .. "]? Or I can show you your [" .. balance_link .. "].'" )
    elseif e.message:find('buy AA Tokens') then
        show_aa_token_options(e)
    elseif e.message:find('AA balance') then
        show_aa_balance(e)
    else
        for itemid, info in pairs(aa_tokens) do
            if e.message:find('buy_' .. itemid) then
                buy_aa_token(e, itemid)
                return
            end
        end
    end
function show_aa_balance(e)
    local aa_points = e.other:GetAAPoints()
    e.other:Message(0, "Ortho says, 'You currently have " .. aa_points .. " AA points.'")
end
end

function show_aa_token_options(e)
    e.other:Message(0, "Ortho says, 'Select the AA token you wish to purchase:'")
    -- Collect and sort tokens by cost
    local sorted = {}
    for itemid, info in pairs(aa_tokens) do
        table.insert(sorted, {itemid = itemid, cost = info.cost, name = info.name})
    end
    table.sort(sorted, function(a, b) return a.cost < b.cost end)
    for _, token in ipairs(sorted) do
        local link = eq.say_link('buy_' .. token.itemid, false, token.name .. " (" .. token.cost .. " AA points)")
        e.other:Message(0, link)
    end
end

function buy_aa_token(e, itemid)
    local info = aa_tokens[itemid]
    if not info then return end
    local aa_points = e.other:GetAAPoints()
    if aa_points < info.cost then
        e.other:Message(0, "Ortho says, 'You do not have enough AA points for this token.'")
        return
    end
    local remaining = aa_points - info.cost
    e.other:SetAAPoints(remaining)
    e.other:Message(0, "Ortho says, 'You have purchased " .. info.name .. ", and have " .. remaining .. " remaining AA points.'")
    e.other:SummonItem(itemid, 1)
end
