--[[
================================================================================
 EQEmu Loan System - Zork the Broker
--------------------------------------------------------------------------------
 Implements a modular alternate currency loan system for EQEmu servers.
 Features:
   - Dynamic loan configuration via loan_config.lua
   - Persistent loan state using data buckets
   - Interest, extensions, overdue penalties, and faction consequences
   - Repayment, extension, and favor regain logic
   - Integration with alternate currency and item redemption
   - Robust messaging and user feedback
   - Designed for maintainability and extensibility
--------------------------------------------------------------------------------
 Key Functions:
   - event_say: Main NPC chat handler
   - process_loan: Issue new loan
   - process_payback: Handle loan repayment
   - process_extend: Extend loan duration
   - show_loan_menu: Display loan status/options
   - regain_favor: Restore faction to neutral
   - Utility functions for bucket keys and state management
================================================================================
]]--
-- CONFIGURATION (now loaded from config_loans.lua)
local config_loans = dofile("/home/eqemu/server/quests/global/loan_config.lua")
local currency_id = config_loans.CURRENCY_ID
local currency_item_id = config_loans.CURRENCY_ITEM_ID
local BASE_LOAN_DURATION_MINUTES = config_loans.BASE_LOAN_DURATION_MINUTES
local BASE_INTEREST_RATE = config_loans.BASE_INTEREST_RATE
local EXTENSION_INTEREST_RATE = config_loans.EXTENSION_INTEREST_RATE
local MAX_EXTENSIONS = config_loans.MAX_EXTENSIONS
local LOAN_OPTIONS = config_loans.LOAN_OPTIONS
local SICKNESS_SPELL_ID = config_loans.SICKNESS_SPELL_ID
local FACTION_ID = config_loans.FACTION_ID

-- Loads the current loan state for a client from data buckets
-- @param client_id: string (player's CharacterID)
-- @return table {amount, duration, extensions, interest}
local function get_loan_state(client_id)
    local keys = get_loan_bucket_keys(client_id)
    local state = {}
    state.amount = tonumber(eq.get_data(keys.loan)) or 0
    state.duration = tonumber(eq.get_data(keys.duration)) or 0
    state.extensions = tonumber(eq.get_data(keys.extensions)) or 0
    state.interest = tonumber(eq.get_data(keys.interest)) or 0
    return state
end

-- Utility: Get loan bucket keys for a client
local function get_loan_bucket_keys(client_id)
    return {
        loan = string.format(config_loans.BUCKET_KEYS.loan, client_id),
        duration = string.format(config_loans.BUCKET_KEYS.duration, client_id),
        extensions = string.format(config_loans.BUCKET_KEYS.extensions, client_id),
        interest = string.format(config_loans.BUCKET_KEYS.interest, client_id)
    }
end

-- Saves the loan state for a client to data buckets
-- @param client_id: string
-- @param amount: number
-- @param duration: number (timestamp)
-- @param extensions: number
-- @param interest: number
local function set_loan_state(client_id, amount, duration, extensions, interest)
    local keys = get_loan_bucket_keys(client_id)
    eq.set_data(keys.loan, tostring(amount))
    eq.set_data(keys.duration, tostring(duration))
    eq.set_data(keys.extensions, tostring(extensions))
    eq.set_data(keys.interest, tostring(interest))
end

-- Clears all loan data for a client from data buckets
-- @param client_id: string
local function clear_loan_state(client_id)
    local keys = get_loan_bucket_keys(client_id)
    eq.delete_data(keys.loan)
    eq.delete_data(keys.duration)
    eq.delete_data(keys.extensions)
    eq.delete_data(keys.interest)
end



-- Loads the current loan state for a client from data buckets
-- @param client_id: string (player's CharacterID)
-- @return table {amount, duration, extensions, interest}
local function get_loan_state(client_id)
    local keys = get_loan_bucket_keys(client_id)
    local state = {}
    state.amount = tonumber(eq.get_data(keys.loan)) or 0
    state.duration = tonumber(eq.get_data(keys.duration)) or 0
    state.extensions = tonumber(eq.get_data(keys.extensions)) or 0
    state.interest = tonumber(eq.get_data(keys.interest)) or 0
    return state
end

-- Displays the loan menu or current loan status for the client
-- Shows outstanding loan details if present, otherwise presents loan options
-- @param e: event object
-- @param client_id: string
local function show_loan_menu(e, client_id)
    local state = get_loan_state(client_id)
    local FACTION_ID = 500000
    local faction_level = e.other:GetCharacterFactionLevel(FACTION_ID)
    local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
    if state.amount > 0 then
        local payback_link = eq.say_link('payback_loan', false, 'Payback Loan')
        local extend_link = eq.say_link('extend_loan', false, 'Extend Loan')
        local regain_link = eq.say_link('regain_favor', false, 'Regain Favor')
        local total_due = math.ceil(state.amount * (1 + state.interest))
        local now = os.time()
        local overdue_msg = ""
        local loan_duration = BASE_LOAN_DURATION_MINUTES * 60
        if now > state.duration then
            local overdue_seconds = now - state.duration
            local overdue_periods = math.floor(overdue_seconds / loan_duration)
            local overdue_str = string.format("%02dh %02dm %02ds", math.floor(overdue_seconds / 3600), math.floor((overdue_seconds % 3600) / 60), overdue_seconds % 60)
            overdue_msg = "Your loan is OVERDUE by " .. overdue_str .. " (" .. overdue_periods .. " full periods past due)."
        end
        e.other:Message(0, "You currently have an outstanding loan of " .. state.amount .. " " .. currency_name .. ".")
        e.other:Message(0, "Total owed (with interest): " .. total_due .. " " .. currency_name)
        e.other:Message(0, "Interest rate: " .. string.format("%.2f%%", state.interest * 100) .. ". Extensions: " .. state.extensions .. "/" .. MAX_EXTENSIONS)
        if overdue_msg ~= "" then
            e.other:Message(0, overdue_msg)
        else
            e.other:Message(0, "Time remaining: " .. os.date("!%X", state.duration - now) .. " (HH:MM:SS)")
        end
        if faction_level < -500 then
            e.other:Message(0, "Your reputation with the Lenders Guild is ruined! Only repayment or regaining favor will restore your standing.")
            e.other:Message(0, "Click here to pay back your loan: " .. payback_link)
            e.other:Message(0, "Click here to regain favor: " .. regain_link)
        else
            e.other:Message(0, "Click here to pay back your loan: " .. payback_link)
            if state.extensions < MAX_EXTENSIONS then
                e.other:Message(0, "Need more time? Click here to extend your loan: " .. extend_link)
            end
        end
    else
        local hours = math.floor(BASE_LOAN_DURATION_MINUTES / 60)
        e.other:Message(0, "Zork chuckles. Very well my friend. Here are my terms. You may borrow " .. currency_name .. " for " .. hours .. " hours at a base interest rate of " .. string.format("%.2f%%%%", BASE_INTEREST_RATE * 100) .. ". If you need more time, you may extend your loan up to " .. MAX_EXTENSIONS .. " times, with interest increasing by " .. string.format("%.2f%%%%", EXTENSION_INTEREST_RATE * 100) .. " for each extension. You must repay the full amount plus interest before the deadline, or pay partially and the remaining balance will continue to accrue interest. Speak to me again about a [loan] and I will give you details about our current loan. Failure WILL have dire [consequences]. And I won't loan to you again for a good while!")
        e.other:Message(0, "So, how much do you want?")
        for _, amount in ipairs(LOAN_OPTIONS) do
            local link = eq.say_link('loan_' .. amount, false, 'Borrow ' .. amount .. ' ' .. currency_name)
            e.other:Message(0, link)
        end
    end
end




-- Processes a new loan for the client
-- Validates no existing loan, sets up loan state, and gives currency items
-- @param e: event object
-- @param client_id: string
-- @param amount: number
local function process_loan(e, client_id, amount)
    local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
    local state = get_loan_state(client_id)
    if state.amount > 0 then
        e.other:Message(0, "You already have an outstanding loan.")
        return
    end
    -- Issue new loan
    local duration = os.time() + BASE_LOAN_DURATION_MINUTES * 60
    local interest = BASE_INTEREST_RATE
    set_loan_state(client_id, amount, duration, 0, interest)
    e.other:SummonItem(currency_item_id, amount)
    e.other:Message(0, "You have borrowed " .. amount .. " " .. currency_name .. ". You have " .. math.floor(BASE_LOAN_DURATION_MINUTES / 60) .. " hours to repay at " .. string.format("%.2f%%%%", interest * 100) .. " interest.")
end

-- Processes loan payback for the client
-- Handles partial/full repayment, item removal, loan state update, buff removal, and faction adjustment
-- @param e: event object
-- @param client_id: string
function process_payback(e, client_id)
    local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
    local state = get_loan_state(client_id)
    local FACTION_ID = 500000
    if state.amount == 0 then
        e.other:Message(0, "You do not have an outstanding loan to pay back.")
        return
    end
    local inv_count = e.other:CountItem(currency_item_id)
    local total_due = math.ceil(state.amount * (1 + state.interest))
    if inv_count == 0 then
        e.other:Message(0, "You do not have any " .. currency_name .. " in your inventory to pay back your loan. You owe " .. total_due .. " " .. currency_name .. " (including interest).")
        return
    end
    if inv_count < total_due then
        -- Partial payback: remove all, update loan
        e.other:RemoveItem(currency_item_id, inv_count)
        local paid_ratio = inv_count / total_due
        local new_amount = math.ceil(state.amount * (1 - paid_ratio))
        if new_amount < 1 then
            clear_loan_state(client_id)
            e.other:Message(0, "You have paid off your loan in full. Thank you!")
            -- Remove sickness spell buff
            e.other:BuffFadeBySpellID(SICKNESS_SPELL_ID)
            -- Set faction to exactly -500 when loan is repaid
            local delta = -500 - e.other:GetCharacterFactionLevel(FACTION_ID)
            e.other:Faction(FACTION_ID, delta)
        else
            -- Keep same interest and duration
            set_loan_state(client_id, new_amount, state.duration, state.extensions, state.interest)
            local new_due = math.ceil(new_amount * (1 + state.interest))
            e.other:Message(0, "You paid " .. inv_count .. " " .. currency_name .. ". Remaining loan: " .. new_amount .. " " .. currency_name .. ". Total owed (with interest): " .. new_due .. " " .. currency_name)
        end
    else
        -- Full payback
        e.other:RemoveItem(currency_item_id, total_due)
        clear_loan_state(client_id)
        e.other:Message(0, "Your loan of " .. state.amount .. " " .. currency_name .. " has been paid back. Total paid: " .. total_due .. " (including interest). Thank you!")
        -- Remove sickness spell buff
        e.other:BuffFadeBySpellID(SICKNESS_SPELL_ID)
    -- Set faction to exactly -500 when loan is repaid
    local delta = -500 - e.other:GetCharacterFactionLevel(FACTION_ID)
    e.other:Faction(FACTION_ID, delta)
    end
end

-- Processes loan extension for the client
-- Validates extension limit, increases interest, and resets duration
-- @param e: event object
-- @param client_id: string
local function process_extend(e, client_id)
    local state = get_loan_state(client_id)
    if state.amount == 0 then
        e.other:Message(0, "You do not have an outstanding loan to extend.")
        return
    end
    if state.extensions >= MAX_EXTENSIONS then
        e.other:Message(0, "You have reached the maximum number of extensions.")
        return
    end
    local new_extensions = state.extensions + 1
    local new_interest = BASE_INTEREST_RATE * (new_extensions + 1)
    local new_duration = os.time() + BASE_LOAN_DURATION_MINUTES * 60
    set_loan_state(client_id, state.amount, new_duration, new_extensions, new_interest)
    -- Set faction to exactly 0 when extending the loan
    local delta = 0 - e.other:GetCharacterFactionLevel(FACTION_ID)
    e.other:Faction(FACTION_ID, delta)
    e.other:Message(0, "Your loan has been extended. New interest rate: " .. string.format("%.2f%%", tonumber(new_interest) * 100) .. ". You now have 24 more hours to pay back your loan. Your standing with the Lenders Guild is now neutral.")
end


--[[
====================================
 MAIN QUEST LOGIC
====================================
]]


-- Main event handler for Zork the Broker
-- Handles all player chat interactions and routes to appropriate logic
-- @param e: event object
function event_say(e)
    local item_link = eq.item_link(currency_item_id)
    local client_id = tostring(e.other:CharacterID())
    local FACTION_ID = 500000
    local faction_level = e.other:GetCharacterFactionLevel(FACTION_ID)
    e.other:Message(0, "DEBUG: Your current faction with the Lenders Guild is: " .. tostring(faction_level))
    if e.message:find('Hail') then
        local state = get_loan_state(client_id)
        local payback_link = eq.say_link('payback_loan', false, 'Payback Loan')
        local regain_link = eq.say_link('regain_favor', false, 'Regain Favor')
        if faction_level <= -500 then
            e.other:Message(0, "You expect me to do business with you? No way. You can " .. payback_link .. ", or attempt to " .. regain_link .. " with the Lenders Guild.")
            return
        end
        local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
        local redeem_link = eq.say_link('redeem', false, 'Redeem')
        local balance_link = eq.say_link('show balance', false, 'Balance')
        local loan_link = eq.say_link('loan', false, 'Loan')
        e.other:Message(0, "Zork says, Zork! I am the Master of Resilience. The broker of this worlds alternate currency system. Would you like some " .. eq.say_link('information', false, 'information') .. " about the currency system? Or you can say " .. redeem_link .. " to change all currency in your inventory to " .. item_link .. ". Or I can show you your " .. balance_link .. ".")
        if state.amount > 0 then
            show_loan_menu(e, client_id)
        else
            e.other:Message(0, "Psst. I can " .. loan_link .." you some " .. currency_name .. ".")
        end
    elseif e.message:find('redeem') then
        redeem_inventory(e)
    elseif e.message:find('show balance') then
        show_balance(e)
    elseif e.message:find('information') then
        local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
        e.other:Message(0, "You earn " .. item_link .. " by defeating monsters throughout Norrath. The amount you receive is based on the difficulty of the monsters. You can accumulate " .. currency_name .. " in your inventory as items, which can be redeemed with me to add them to your alternate currency tab. Happy hunting!")
    elseif e.message:find('payback_loan') then
        process_payback(e, client_id)
    elseif e.message:find('extend_loan') then
        process_extend(e, client_id)
    elseif e.message:find('regain_favor') then
        e.other:Message(0, "To regain favor with the Lenders Guild, you must [pay] me 300 " .. eq.get_item_name(config_loans.CURRENCY_ITEM_ID) .. ".")
    elseif e.message:find('pay') then
        local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
        local tab_count = e.other:GetAlternateCurrencyValue(config_loans.CURRENCY_ID)
        if tab_count >= 300 then
            e.other:SetAlternateCurrencyValue(config_loans.CURRENCY_ID, tab_count - 300)
            e.other:Message(0, "You have paid 300 " .. currency_name .. " to regain favor with the Lenders Guild.")
            e.other:Faction(config_loans.FACTION_ID, 500)
        else
            e.other:Message(0, "You do not have enough " .. currency_name .. " to pay.")
        end
    else
        -- Check for loan amount selection first, so it doesn't fall through to menu
        for _, amount in ipairs(LOAN_OPTIONS) do
            if e.message:find('loan_' .. amount) then
                process_loan(e, client_id, amount)
                return -- Do not show menu again
            end
        end
        -- If not a specific loan amount, check for 'loan' to show menu
        if e.message:find('loan') then
            show_loan_menu(e, client_id)
        end
    end
end

-- Displays the player's current alt currency balance
-- @param e: event object
function show_balance(e)
    local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
    local tab_count = e.other:GetAlternateCurrencyValue(currency_id)
    e.other:Message(0, "You currently have " .. tab_count .. " " .. currency_name .. " in your alt currency tab.")
end

-- Redeems all currency items in inventory and adds to alt currency tab
-- @param e: event object
function redeem_inventory(e)
    local currency_name = eq.get_item_name(config_loans.CURRENCY_ITEM_ID)
    local tab_count = e.other:GetAlternateCurrencyValue(currency_id)
    local inventory_count = e.other:CountItem(currency_item_id)
    if inventory_count > 0 then
        -- Remove all currency items from inventory in one call
        e.other:RemoveItem(currency_item_id, inventory_count)
    end
    local total = tab_count + inventory_count
    e.other:SetAlternateCurrencyValue(currency_id, total)
    if inventory_count > 0 then
        e.other:Message(0, "You redeemed " .. inventory_count .. " " .. currency_name .. " from your inventory. Your total is now " .. total .. ".")
    else
        e.other:Message(0, "You have no " .. currency_name .. " in your inventory to redeem. Your total remains " .. tab_count .. ".")
    end
end
-- [[ END LOAN SYSTEM ================================================================================= ]]--

