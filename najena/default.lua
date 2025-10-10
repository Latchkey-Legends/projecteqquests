-- Compatibility for unpack across Lua versions
local unpack = table.unpack or unpack

-- List of item IDs to potentially drop
--local drop_items = { 502011, 502012, 502013, 502014, 502015, 502016, 502017, 502018, 502019, 502020, 502021}
local drop_items = { 502022}

-- List of NPC name patterns to match (case-insensitive)
local drop_npcs = { "skeleton" }
local drop_chance = 0.7 -- 70% chance to drop
local min_drop_count = 1    -- minimum per stack
local max_drop_count = 2    -- maximum per stack
local min_items = 1        -- minimum different items to drop
local max_items = 3        -- maximum different items to drop

-- Helper function to check if corpse name matches any pattern
local function check_npc(corpse_name)
    local name = corpse_name:lower()
    for _, npc in ipairs(drop_npcs) do
        if string.find(name, npc) then
            return true
        end
    end
    return false
end

-- Get random items from table
local function pick_random_items(tbl, count)
    local copy = { unpack(tbl) }
    for i = #copy, 2, -1 do
        local j = math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    local result = {}
    for i = 1, math.min(count, #copy) do
        table.insert(result, copy[i])
    end
    return result
end


function event_killed_merit(e)
    local corpse_name = e.corpse:GetName()
    local max_items = math.random(min_items, max_items)
    local item_list = pick_random_items(drop_items, max_items)
    if check_npc(corpse_name) then
        if math.random() < drop_chance then
            for _, itemid in ipairs(item_list) do
                local count = math.random(min_drop_count, max_drop_count)
                e.corpse:AddItem(itemid, count)
            end
        end
    end
end
