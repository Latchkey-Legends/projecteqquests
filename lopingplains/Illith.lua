local CURRENCY_ID = 500000 -- Replace with your currency item ID
local REQUIRED_CURRENCY = 500 -- Amount of currency required

function event_say(e)
    if e.message:find('Hail') then
        local currency_name = eq.get_item_name(CURRENCY_ID)
        e.other:Message(0, "Hi " .. e.other:GetName() .. ", if you hand me any attuned item, and 500 " .. currency_name .. " I will release its bond to you and give it back.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    local attuned_item_id = nil
    local attuned_found = false
    local currency_count = 0

    -- Check all trade slots for attuned item and currency
    for slot = 1, 4 do
        local id = e.trade["item" .. slot]
        if id ~= nil then
            local id_num = tonumber(id)
            if id_num and id_num > 0 then
                local iteminst = e.other:GetItemByID(id_num)
                if iteminst and iteminst:IsAttuned() and not attuned_found then
                    attuned_item_id = id_num
                    attuned_found = true
                elseif id_num == CURRENCY_ID then
                    if iteminst then
                        currency_count = currency_count + iteminst:GetCharges()
                    else
                        currency_count = currency_count + 1 -- fallback if GetCharges not available
                    end
                end
            end
        end
    end

    if attuned_found and currency_count >= REQUIRED_CURRENCY then
        -- Extract augments and return them to the player
        local iteminst = e.other:GetItemByID(attuned_item_id)
        if iteminst then
            for aug_slot = 0, 4 do -- Adjust slot range if needed
                local aug_id = iteminst:GetAugmentItemID(aug_slot)
                if aug_id and aug_id > 0 then
                    e.other:SummonItem(aug_id, 1)
                end
            end
        end
        -- Give fresh unattuned item
        e.other:SummonItem(attuned_item_id, 1)
        e.other:Message(0, "Your item has been unattuned and augments returned!")
    else
        e.other:Message(0, "You must hand in any attuned item and at least 500 currency.")
        item_lib.return_items(e.self, e.other, e.trade)
    end
end
