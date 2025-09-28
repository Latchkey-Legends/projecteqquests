-- Configurable Debug Settings
local DEBUG_CURRENCY = true; -- Set to false to disable currency debug messages

local function debug_print(message)
    if DEBUG_CURRENCY then
        eq.debug(message);
    end
end

local function calculate_group_bonus(player)
    if not player:IsGrouped() then return 1.0 end
    
    local group = player:GetGroup()
    local group_size = group:GroupCount()
    local level_spread = group:GetHighestLevel() - group:GetLowestLevel()
    
    local base_bonus = 1.0 + (group_size - 1) * 0.15  -- 15% per member
    local balance_bonus = (level_spread <= 5) and 1.1 or 1.0  -- Reward balanced groups
    
    return base_bonus * balance_bonus
end

function add_custom_currency(e)
-- Custom Currency -------------------------------------------------
    local player = e.other;
    local corpse = e.corpse;
    local mob = e.self;
    local currency_id = 500000;

    local npc_level;

    if type(e) == "number" then
        npc_level = e
    else
        npc_level = mob:GetLevel();
    end
    
    -- Configurable Parameters for drop chance and amount
    local group_bonus               = true;     -- Enable group bonus
    local base_chance               = 50;       -- Base 50% chance at level 1 (45-55% range)
    local max_chance                = 70;       -- Max 70% chance at level 100 (65-75% range)
    local min_currency              = 0;        -- Minimum currency amount on drop
    local max_currency_level_1      = 2;        -- Max currency at level 1
    local max_currency_level_100    = 50;       -- Max currency at level 100
    -- End Configurable Parameters

    if type(e) == "number" then
        npc_level = e
    else
        npc_level = e.self:GetLevel();
    end

    -- Calculate drop chance (40-50% at level 1, 65-75% at level 100)
    local chance_increase_per_level = (max_chance - base_chance) / 99; -- Spread over levels 1-100
    local drop_chance = base_chance + (npc_level - 1) * chance_increase_per_level;
    
    -- Add some randomness to the drop chance (±5%)
    drop_chance = drop_chance + math.random(-5, 5);
    
    -- Roll for drop
    local probability = math.random(100);
    
    -- Calculate max currency for this level (0-2 at level 1, 0-50 at level 100)
    local max_currency = max_currency_level_1 + (npc_level - 1) * ((max_currency_level_100 - max_currency_level_1) / 99);
    
    -- Check if drop occurs
    if probability <= drop_chance then
        -- Random amount between min and calculated max
        local currency_amount = math.random(min_currency, math.floor(max_currency));
        local original_amount = currency_amount;
        local bonus_multiplier = 1.0;

        -- Group Bonus
        if player and (player:IsGrouped() or player:IsRaidGrouped()) then
            bonus_multiplier = calculate_group_bonus(player);
            currency_amount = math.floor(currency_amount * bonus_multiplier);
        end

        -- Single comprehensive debug line for DROP
        debug_print(string.format("DROP: Lvl: (%d) Chance: (%.1f%%) Roll: (%d) MaxCurr: (%.1f) OrigAmt: (%d) Bonus: (%.2fx) FinalAmt: (%d)", 
            npc_level, drop_chance, probability, max_currency, original_amount, bonus_multiplier, currency_amount));

        if currency_amount > 0 then
            if type(e) == "number" then 
                return currency_amount;
            else
                corpse:SetDecayTimer(450000); -- Extend corpse time by 30 seconds to ensure currency is added
                corpse:AddItem(currency_id, currency_amount); -- Use the calculated amount instead of hardcoded 10;
            end
        end
        
        -- Always return the amount (including 0) when a drop occurs
        return currency_amount;
    else
        -- Single comprehensive debug line for NO DROP
        debug_print(string.format("NO DROP: Lvl: (%d) Chance: (%.1f%%) Roll: (%d) MaxCurr: (%.1f)", 
            npc_level, drop_chance, probability, max_currency));
    end
    return -1; -- Return -1 to indicate no drop occurred (different from 0 drop amount)
end

function debug_api_test(e)
    debug_print("Killer: " .. tostring(e.killer_id));
    local player = e.other;
    local player = eq.get_entity_list():GetClientByID(e.killer_id);
    debug_print("Player: " .. tostring(player:GetName()));

    if player:IsRaidGrouped() then
        debug_print("Player is in a raid.");
    else
        debug_print("Player is not in a raid.");
    end

    -- Find groups
     if player:IsGrouped() then 
        debug_print("Player is in a group.");
     else
        debug_print("Player is not in a group.");
     end
end

function event_killed_merit(e)
    -- debug_print("Firing event_killed_merit ================");
    -- local player = e.other;
    -- local corpse = e.corpse;

    -- debug_print("Player: " .. player:GetName());
    -- debug_print("Corpse: " .. corpse:GetNPCTypeID());
    -- e.corpse:AddItem(500000, 5); -- Add 5 of item 1001 to corpse
    add_custom_currency(e);
end

--function event_death(e)
    --eq.debug("Fired event_death");
    -- local debug_npc_name = e.self and e.self:GetCleanName() or "Unknown NPC";
    -- local debug_npc_id = e.self and e.self:GetID() or "Unknown ID";
    -- eq.debug("event_death triggered for " .. debug_npc_name .. " (ID: " .. debug_npc_id .. ")");
    -- add_custom_currency(e);
--end

function event_spawn(e)
    -- peq_halloween
    if (eq.is_content_flag_enabled("peq_halloween")) then
        -- exclude mounts and pets
        if (e.self:GetCleanName():findi("mount") or e.self:IsPet()) then
            return;
        end

        -- soulbinders
        -- priest of discord
        if (e.self:GetCleanName():findi("soulbinder") or e.self:GetCleanName():findi("priest of discord")) then
            e.self:ChangeRace(eq.ChooseRandom(14,60,82,85));
            e.self:ChangeSize(6);
            e.self:ChangeTexture(1);
            e.self:ChangeGender(2);
        end

        -- Shadow Haven
        -- The Bazaar
        -- The Plane of Knowledge
        -- Guild Lobby
        local halloween_zones = eq.Set { 202, 150, 151, 344 }
        local not_allowed_bodytypes = eq.Set { 11, 60, 66, 67 }
        if (halloween_zones[eq.get_zone_id()] and not_allowed_bodytypes[e.self:GetBodyType()] == nil) then
            e.self:ChangeRace(eq.ChooseRandom(14,60,82,85));
            e.self:ChangeSize(6);
            e.self:ChangeTexture(1);
            e.self:ChangeGender(2);
        end
    end
end

