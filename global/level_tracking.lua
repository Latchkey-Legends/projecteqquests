-- level_tracking.lua
-- Empirical data collection for kill counts and experience per level
-- Uses databuckets to persistently track leveling data for formula validation

local level_tracking = {}

-- Constants
local BUCKET_PREFIX = "level_track_"
local KILL_SUFFIX = "_kills"
local EXP_SUFFIX = "_exp"
local START_SUFFIX = "_start"
local END_SUFFIX = "_end"

-- Level tracking system (embedded to avoid module loading issues)
local BUCKET_PREFIX = "level_track_"
local KILL_SUFFIX = "_kills"
local EXP_SUFFIX = "_exp"
local START_SUFFIX = "_start"

-- Experience table for calculating XP needed per level
local EXP_TO_LEVEL = {
	function event_command(e)
		-- Level tracking commands
		if e.command == "trackinit" then
			level_tracking.init_tracking(e.self)
			return 1
		elseif e.command == "trackreport" then
			local start_level = tonumber(e.args[1]) or 1
			local end_level = tonumber(e.args[2]) or 10
			level_tracking.generate_report(e.self, start_level, end_level)
			return 1
		elseif e.command == "trackclear" then
			local start_level = tonumber(e.args[1]) or 1
			local end_level = tonumber(e.args[2]) or 65
			level_tracking.clear_data(e.self, start_level, end_level)
			return 1
		elseif e.command == "trackkill" then
			local exp_amount = 0
			if e.args then
				exp_amount = tonumber(e.args) or 0
			end
			if exp_amount <= 0 then
				exp_amount = 1000  -- Default test amount
			end
			level_tracking.track_kill(e.self, exp_amount)
			e.self:Message(MT.Yellow, "[TEST] Manually added kill with " .. exp_amount .. " EXP to tracking")
			return 1
		elseif e.command == "trackevent" then
			local char_id = e.self:CharacterID()
			local debug_key = "track_event_debug_" .. char_id
			local current_debug = eq.get_data(debug_key) or "0"
			if current_debug == "0" then
				eq.set_data(debug_key, "1")
				e.self:Message(MT.Yellow, "[DEBUG] Event tracking ENABLED - you'll see messages when events fire")
			else
				eq.set_data(debug_key, "0")
				e.self:Message(MT.Yellow, "[DEBUG] Event tracking DISABLED")
			end
			return 1
		elseif e.command == "trackhelp" then
			e.self:Message(MT.Yellow, "=== ENHANCED LEVEL TRACKING COMMANDS ===")
			e.self:Message(MT.Yellow, "#trackinit - Initialize enhanced tracking for current level")
			e.self:Message(MT.Yellow, "#trackreport [start] [end] - Show tracking report (default: 1-10)")
			e.self:Message(MT.Yellow, "#trackclear [start] [end] - Clear tracking data (default: 1-65)")
			e.self:Message(MT.Yellow, "#trackstatus - Enhanced status with playtime & modifiers")
			e.self:Message(MT.Yellow, "#trackapi - Show available API methods being used")
			e.self:Message(MT.Yellow, "#trackkill [exp] - Manually add a kill with EXP (for testing)")
			e.self:Message(MT.Yellow, "#trackevent - Toggle event debug messages")
			e.self:Message(MT.Yellow, "==========================================")
			return 1
		elseif e.command == "trackapi" then
			e.self:Message(MT.Yellow, "=== EQEmu API METHODS USED IN ENHANCED TRACKING ===")
			e.self:Message(MT.Yellow, "Experience Methods:")
			e.self:Message(MT.Yellow, "  client:GetEXP() - Current EXP within current level")
			e.self:Message(MT.Yellow, "  client:GetEXPForLevel(level) - Total EXP required for level")
			e.self:Message(MT.Yellow, "  client:GetEXPModifier() - Current EXP bonus multiplier")
			e.self:Message(MT.Yellow, "  client:GetEXPPercentage() - Percentage through current level")
			e.self:Message(MT.Yellow, "Character Methods:")
			e.self:Message(MT.Yellow, "  client:GetLevel() - Current character level")
			e.self:Message(MT.Yellow, "  client:CharacterID() - Unique character identifier")
			e.self:Message(MT.Yellow, "  client:GetTotalSecondsPlayed() - Total playtime in seconds")
			e.self:Message(MT.Yellow, "Group Methods:")
			e.self:Message(MT.Yellow, "  client:IsGrouped() - Check if player is in a group")
			e.self:Message(MT.Yellow, "Events:")
			e.self:Message(MT.Yellow, "  event_exp_gain(e) - Fired when EXP is gained (e.exp_gained)")
			e.self:Message(MT.Yellow, "  event_level_up(e) - Fired when character levels up")
			e.self:Message(MT.Yellow, "Total Available: 589 Client methods, 247 events, 22+ constants")
			e.self:Message(MT.Yellow, "===================================================")
			return 1
		elseif e.command == "trackstatus" then
			-- Enhanced current level tracking status with new API methods
			-- This is a custom status function, you may want to move it to level_tracking.lua for full modularity
			local char_id = e.self:CharacterID()
			local level = e.self:GetLevel()
			local current_exp_in_level = e.self:GetEXP()
			local kill_key = "level_track_" .. char_id .. "_" .. level .. "_kills"
			local exp_key = "level_track_" .. char_id .. "_" .. level .. "_exp"
			local kills = tonumber(eq.get_data(kill_key)) or 0
			local exp_gained = tonumber(eq.get_data(exp_key)) or 0
			local exp_modifier = e.self:GetEXPModifier() or 1.0
			local exp_percentage = e.self:GetEXPPercentage() or 0.0
			local playtime = e.self:GetTotalSecondsPlayed() or 0
			local is_grouped = e.self:IsGrouped() or false
			local group_status = is_grouped and "GROUPED" or "SOLO"
			if exp_percentage > 100 or exp_percentage < 0 then
				exp_percentage = 0.0
			end
			local hours = math.floor(playtime / 3600)
			local minutes = math.floor((playtime % 3600) / 60)
			local playtime_str = string.format("%dh %dm", hours, minutes)
			local exp_required_for_next = e.self:GetEXPForLevel(level + 1) or 0
			local exp_required_for_current = e.self:GetEXPForLevel(level) or 0
			local exp_needed_total = exp_required_for_next - exp_required_for_current
			if exp_needed_total < 0 or exp_needed_total > 2147483647 then
				if level <= 15 then
					exp_needed_total = (level * level * 75 * 35) / 10
				else
					exp_needed_total = 0
				end
			end
			local exp_remaining = exp_needed_total - current_exp_in_level
			if exp_remaining < 0 then
				exp_remaining = 0
			end
			local playtime_key = "level_track_" .. char_id .. "_" .. level .. "_playtime"
			local start_playtime = tonumber(eq.get_data(playtime_key)) or playtime
			local time_spent_this_level = playtime - start_playtime
			local level_hours = math.floor(time_spent_this_level / 3600)
			local level_minutes = math.floor((time_spent_this_level % 3600) / 60)
			local level_time_str = string.format("%dh %dm", level_hours, level_minutes)
			e.self:Message(MT.Yellow, "====================== ENHANCED TRACKING STATUS ======================")
			e.self:Message(MT.Yellow, "Character: " .. e.self:GetName() .. " (ID: " .. char_id .. ")")
			e.self:Message(MT.Yellow, "Level: " .. level .. " (" .. group_status .. ")")
			e.self:Message(MT.Yellow, "Total Playtime: " .. playtime_str)
			e.self:Message(MT.Yellow, "Time This Level: " .. level_time_str)
			e.self:Message(MT.Yellow, "EXP Modifier: " .. string.format("%.1f", exp_modifier) .. "x")
			if exp_percentage >= 0 and exp_percentage <= 100 then
				e.self:Message(MT.Yellow, "Level Progress: " .. string.format("%.1f", exp_percentage) .. "%")
			else
				e.self:Message(MT.Yellow, "Level Progress: Unknown (API overflow)")
			end
			e.self:Message(MT.Yellow, "-------------------------------------------------------------------")
			e.self:Message(MT.Yellow, "Kills This Level: " .. kills)
			e.self:Message(MT.Yellow, "EXP Gained from Kills: " .. exp_gained)
			e.self:Message(MT.Yellow, "Current EXP in Level: " .. current_exp_in_level)
			if exp_needed_total > 0 then
				e.self:Message(MT.Yellow, "Total EXP Needed: " .. exp_needed_total)
				e.self:Message(MT.Yellow, "EXP Remaining: " .. exp_remaining)
			else
				e.self:Message(MT.Yellow, "Total EXP Needed: Unknown (using fallback calculation)")
				e.self:Message(MT.Yellow, "EXP Remaining: Cannot calculate")
			end
			if exp_gained > 0 and exp_needed_total > 0 then
				local efficiency = (exp_gained / exp_needed_total) * 100
				e.self:Message(MT.Yellow, "Kill Efficiency: " .. string.format("%.1f%%", efficiency) .. " (gained/needed)")
			end
			if kills > 0 then
				local avg_exp = exp_gained / kills
				e.self:Message(MT.Yellow, "Avg EXP per Kill: " .. string.format("%.1f", avg_exp))
				if exp_remaining > 0 then
					local estimated_kills_needed = math.ceil(exp_remaining / avg_exp)
					e.self:Message(MT.Yellow, "Est. Kills to Level: " .. estimated_kills_needed)
				end
				if time_spent_this_level > 0 then
					local kills_per_hour = (kills * 3600) / time_spent_this_level
					local exp_per_hour = (exp_gained * 3600) / time_spent_this_level
					e.self:Message(MT.Yellow, "Kills per Hour: " .. string.format("%.1f", kills_per_hour))
					e.self:Message(MT.Yellow, "EXP per Hour: " .. string.format("%.1f", exp_per_hour))
				end
			end
			e.self:Message(MT.Yellow, "===================================================================")
			return 1
		end

-- Initialize tracking for a character
function level_tracking.init_tracking(client)
    local char_id = client:CharacterID()
    local current_level = client:GetLevel()
    local current_exp = client:GetEXP()
    
    -- Store starting data for current level
    eq.set_data(BUCKET_PREFIX .. char_id .. "_" .. current_level .. START_SUFFIX, tostring(current_exp))
    eq.set_data(BUCKET_PREFIX .. char_id .. "_" .. current_level .. KILL_SUFFIX, "0")
    
    client:Message(MT.Yellow, "[LEVEL TRACKER] Initialized tracking at level " .. current_level .. " with " .. current_exp .. " EXP")
end

-- Track a kill (call this from event_killed_merit or similar)
function level_tracking.track_kill(client)
    local char_id = client:CharacterID()
    local current_level = client:GetLevel()
    local kill_key = BUCKET_PREFIX .. char_id .. "_" .. current_level .. KILL_SUFFIX
    
    -- Get current kill count and increment
    local current_kills = tonumber(eq.get_data(kill_key)) or 0
    current_kills = current_kills + 1
    eq.set_data(kill_key, tostring(current_kills))
    
    -- Optional debug message (can be disabled)
    if current_kills % 10 == 0 then -- Show every 10th kill
        client:Message(MT.DimGray, "[LEVEL TRACKER] Level " .. current_level .. ": " .. current_kills .. " kills")
    end
end

-- Handle level up event
function level_tracking.on_level_up(client, new_level)
    local char_id = client:CharacterID()
    local old_level = new_level - 1
    local current_exp = client:GetEXP()
    
    -- Store ending data for previous level
    local end_key = BUCKET_PREFIX .. char_id .. "_" .. old_level .. END_SUFFIX
    eq.set_data(end_key, tostring(current_exp))
    
    -- Calculate and store experience gained for the completed level
    local start_key = BUCKET_PREFIX .. char_id .. "_" .. old_level .. START_SUFFIX
    local start_exp = tonumber(eq.get_data(start_key)) or 0
    local exp_gained = current_exp - start_exp
    local exp_key = BUCKET_PREFIX .. char_id .. "_" .. old_level .. EXP_SUFFIX
    eq.set_data(exp_key, tostring(exp_gained))
    
    -- Get kill count for completed level
    local kill_key = BUCKET_PREFIX .. char_id .. "_" .. old_level .. KILL_SUFFIX
    local kills = tonumber(eq.get_data(kill_key)) or 0
    
    -- Report completed level data
    client:Message(MT.Yellow, "[LEVEL TRACKER] *** LEVEL " .. old_level .. " COMPLETE ***")
    client:Message(MT.Yellow, "[LEVEL TRACKER] Kills: " .. kills)
    client:Message(MT.Yellow, "[LEVEL TRACKER] EXP Gained: " .. exp_gained)
    if kills > 0 then
        local avg_exp = math.floor(exp_gained / kills)
        client:Message(MT.Yellow, "[LEVEL TRACKER] Avg EXP per kill: " .. avg_exp)
    end
    
    -- Initialize tracking for new level
    eq.set_data(BUCKET_PREFIX .. char_id .. "_" .. new_level .. START_SUFFIX, tostring(current_exp))
    eq.set_data(BUCKET_PREFIX .. char_id .. "_" .. new_level .. KILL_SUFFIX, "0")
    
    client:Message(MT.Yellow, "[LEVEL TRACKER] Started tracking level " .. new_level)
end

-- Generate a comprehensive report for a character
function level_tracking.generate_report(client, start_level, end_level)
    local char_id = client:CharacterID()
    local report = {}
    
    client:Message(MT.Yellow, "========== LEVEL TRACKING REPORT ==========")
    client:Message(MT.Yellow, "LEVEL  KILLS    EXP_GAINED  AVG_EXP_PER_KILL")
    client:Message(MT.Yellow, "-----  -----    ----------  ----------------")
    
    local total_kills = 0
    local total_exp = 0
    
    for level = start_level, end_level do
        local kill_key = BUCKET_PREFIX .. char_id .. "_" .. level .. KILL_SUFFIX
        local exp_key = BUCKET_PREFIX .. char_id .. "_" .. level .. EXP_SUFFIX
        
        local kills = tonumber(eq.get_data(kill_key)) or 0
        local exp_gained = tonumber(eq.get_data(exp_key)) or 0
        
        if kills > 0 or exp_gained > 0 then
            local avg_exp = kills > 0 and math.floor(exp_gained / kills) or 0
            client:Message(MT.Yellow, string.format("%-6d %-8d %-11d %-16d", 
                level, kills, exp_gained, avg_exp))
            
            total_kills = total_kills + kills
            total_exp = total_exp + exp_gained
        end
    end
    
    client:Message(MT.Yellow, "-----  -----    ----------  ----------------")
    local overall_avg = total_kills > 0 and math.floor(total_exp / total_kills) or 0
    client:Message(MT.Yellow, string.format("TOTAL  %-8d %-11d %-16d", 
        total_kills, total_exp, overall_avg))
    client:Message(MT.Yellow, "==========================================")
end

-- Export data to a formatted string for external analysis
function level_tracking.export_data(client, start_level, end_level)
    local char_id = client:CharacterID()
    local export_lines = {}
    
    -- CSV header
    table.insert(export_lines, "Level,Kills,EXP_Gained,Avg_EXP_Per_Kill")
    
    for level = start_level, end_level do
        local kill_key = BUCKET_PREFIX .. char_id .. "_" .. level .. KILL_SUFFIX
        local exp_key = BUCKET_PREFIX .. char_id .. "_" .. level .. EXP_SUFFIX
        
        local kills = tonumber(eq.get_data(kill_key)) or 0
        local exp_gained = tonumber(eq.get_data(exp_key)) or 0
        
        if kills > 0 or exp_gained > 0 then
            local avg_exp = kills > 0 and math.floor(exp_gained / kills) or 0
            table.insert(export_lines, string.format("%d,%d,%d,%d", 
                level, kills, exp_gained, avg_exp))
        end
    end
    
    -- Send export data to client (they can copy from logs)
    client:Message(MT.White, "========== EXPORT DATA (CSV Format) ==========")
    for _, line in ipairs(export_lines) do
        client:Message(MT.White, line)
    end
    client:Message(MT.White, "============================================")
end

-- Clear tracking data for a character (useful for fresh tests)
function level_tracking.clear_data(client, start_level, end_level)
    local char_id = client:CharacterID()
    local cleared = 0
    
    for level = start_level, end_level do
        local keys = {
            BUCKET_PREFIX .. char_id .. "_" .. level .. KILL_SUFFIX,
            BUCKET_PREFIX .. char_id .. "_" .. level .. EXP_SUFFIX,
            BUCKET_PREFIX .. char_id .. "_" .. level .. START_SUFFIX,
            BUCKET_PREFIX .. char_id .. "_" .. level .. END_SUFFIX
        }
        
        for _, key in ipairs(keys) do
            if eq.get_data(key) ~= "" then
                eq.delete_data(key)
                cleared = cleared + 1
            end
        end
    end
    
    client:Message(MT.Yellow, "[LEVEL TRACKER] Cleared " .. cleared .. " data entries for levels " .. start_level .. "-" .. end_level)
end

function event_command(e)
	-- Level tracking commands
	if e.command == "trackinit" then
		init_level_tracking(e.self)
		return 1
	elseif e.command == "trackreport" then
		local start_level = tonumber(e.args[1]) or 1
		local end_level = tonumber(e.args[2]) or 10
		generate_tracking_report(e.self, start_level, end_level)
		return 1
	elseif e.command == "trackclear" then
		local start_level = tonumber(e.args[1]) or 1
		local end_level = tonumber(e.args[2]) or 65
		clear_tracking_data(e.self, start_level, end_level)
		return 1
	elseif e.command == "trackdebug" then
		debug_tracking_data(e.self)
		return 1
	elseif e.command == "trackkill" then
		-- Manual kill tracking for testing - usage: #trackkill [exp_amount]
		local exp_amount = 0
		if e.args then
			exp_amount = tonumber(e.args) or 0
		end
		if exp_amount <= 0 then
			exp_amount = 1000  -- Default test amount
		end
		track_kill(e.self, exp_amount)
		e.self:Message(MT.Yellow, "[TEST] Manually added kill with " .. exp_amount .. " EXP to tracking")
		return 1
	elseif e.command == "trackevent" then
		-- Toggle event debugging
		local char_id = e.self:CharacterID()
		local debug_key = "track_event_debug_" .. char_id
		local current_debug = eq.get_data(debug_key) or "0"
		if current_debug == "0" then
			eq.set_data(debug_key, "1")
			e.self:Message(MT.Yellow, "[DEBUG] Event tracking ENABLED - you'll see messages when events fire")
		else
			eq.set_data(debug_key, "0")
			e.self:Message(MT.Yellow, "[DEBUG] Event tracking DISABLED")
		end
		return 1
	elseif e.command == "trackstatus" then
		-- Enhanced current level tracking status with new API methods
		local char_id = e.self:CharacterID()
		local level = e.self:GetLevel()
		local current_exp_in_level = e.self:GetEXP()
		local kill_key = BUCKET_PREFIX .. char_id .. "_" .. level .. KILL_SUFFIX
		local exp_key = BUCKET_PREFIX .. char_id .. "_" .. level .. EXP_SUFFIX
		local kills = tonumber(eq.get_data(kill_key)) or 0
		local exp_gained = tonumber(eq.get_data(exp_key)) or 0
		
		-- Get enhanced metrics using new API methods (with overflow protection)
		local exp_modifier = e.self:GetEXPModifier() or 1.0
		local exp_percentage = e.self:GetEXPPercentage() or 0.0
		local playtime = e.self:GetTotalSecondsPlayed() or 0
		local is_grouped = e.self:IsGrouped() or false
		local group_status = is_grouped and "GROUPED" or "SOLO"
		
		-- Clamp exp_percentage to reasonable bounds
		if exp_percentage > 100 or exp_percentage < 0 then
			exp_percentage = 0.0
		end
		
		-- Calculate playtime metrics
		local hours = math.floor(playtime / 3600)
		local minutes = math.floor((playtime % 3600) / 60)
		local playtime_str = string.format("%dh %dm", hours, minutes)
		
		-- Calculate actual EXP needed for this level using API with overflow protection
		local exp_required_for_next = e.self:GetEXPForLevel(level + 1) or 0
		local exp_required_for_current = e.self:GetEXPForLevel(level) or 0
		local exp_needed_total = exp_required_for_next - exp_required_for_current
		
		-- Bounds checking to prevent overflow
		if exp_needed_total < 0 or exp_needed_total > 2147483647 then
			-- Fallback to our known good formula for reasonable levels
			if level <= 15 then
				exp_needed_total = (level * level * 75 * 35) / 10
			else
				exp_needed_total = 0 -- Unknown
			end
		end
		
		local exp_remaining = exp_needed_total - current_exp_in_level
		-- Ensure exp_remaining is not negative due to overflow
		if exp_remaining < 0 then
			exp_remaining = 0
		end
		
		-- Get stored playtime and modifier data
		local playtime_key = BUCKET_PREFIX .. char_id .. "_" .. level .. "_playtime"
		local start_playtime = tonumber(eq.get_data(playtime_key)) or playtime
		local time_spent_this_level = playtime - start_playtime
		local level_hours = math.floor(time_spent_this_level / 3600)
		local level_minutes = math.floor((time_spent_this_level % 3600) / 60)
		local level_time_str = string.format("%dh %dm", level_hours, level_minutes)
		
		e.self:Message(MT.Yellow, "====================== ENHANCED TRACKING STATUS ======================")
		e.self:Message(MT.Yellow, "Character: " .. e.self:GetName() .. " (ID: " .. char_id .. ")")
		e.self:Message(MT.Yellow, "Level: " .. level .. " (" .. group_status .. ")")
		e.self:Message(MT.Yellow, "Total Playtime: " .. playtime_str)
		e.self:Message(MT.Yellow, "Time This Level: " .. level_time_str)
		e.self:Message(MT.Yellow, "EXP Modifier: " .. string.format("%.1f", exp_modifier) .. "x")
		
		-- Only show percentage if it's reasonable
		if exp_percentage >= 0 and exp_percentage <= 100 then
			e.self:Message(MT.Yellow, "Level Progress: " .. string.format("%.1f", exp_percentage) .. "%")
		else
			e.self:Message(MT.Yellow, "Level Progress: Unknown (API overflow)")
		end
		
		e.self:Message(MT.Yellow, "-------------------------------------------------------------------")
		e.self:Message(MT.Yellow, "Kills This Level: " .. kills)
		e.self:Message(MT.Yellow, "EXP Gained from Kills: " .. exp_gained)
		e.self:Message(MT.Yellow, "Current EXP in Level: " .. current_exp_in_level)
		
		if exp_needed_total > 0 then
			e.self:Message(MT.Yellow, "Total EXP Needed: " .. exp_needed_total)
			e.self:Message(MT.Yellow, "EXP Remaining: " .. exp_remaining)
		else
			e.self:Message(MT.Yellow, "Total EXP Needed: Unknown (using fallback calculation)")
			e.self:Message(MT.Yellow, "EXP Remaining: Cannot calculate")
		end
		
		if exp_gained > 0 and exp_needed_total > 0 then
			local efficiency = (exp_gained / exp_needed_total) * 100
			e.self:Message(MT.Yellow, "Kill Efficiency: " .. string.format("%.1f%%", efficiency) .. " (gained/needed)")
		end
		
		if kills > 0 then
			local avg_exp = exp_gained / kills
			e.self:Message(MT.Yellow, "Avg EXP per Kill: " .. string.format("%.1f", avg_exp))
			if exp_remaining > 0 then
				local estimated_kills_needed = math.ceil(exp_remaining / avg_exp)
				e.self:Message(MT.Yellow, "Est. Kills to Level: " .. estimated_kills_needed)
			end
			
			-- Time efficiency metrics
			if time_spent_this_level > 0 then
				local kills_per_hour = (kills * 3600) / time_spent_this_level
				local exp_per_hour = (exp_gained * 3600) / time_spent_this_level
				e.self:Message(MT.Yellow, "Kills per Hour: " .. string.format("%.1f", kills_per_hour))
				e.self:Message(MT.Yellow, "EXP per Hour: " .. string.format("%.1f", exp_per_hour))
			end
		end
		e.self:Message(MT.Yellow, "===================================================================")
		return 1
	elseif e.command == "trackhelp" then
		e.self:Message(MT.Yellow, "=== ENHANCED LEVEL TRACKING COMMANDS ===")
		e.self:Message(MT.Yellow, "#trackinit - Initialize enhanced tracking for current level")
		e.self:Message(MT.Yellow, "#trackreport [start] [end] - Show tracking report (default: 1-10)")
		e.self:Message(MT.Yellow, "#trackclear [start] [end] - Clear tracking data (default: 1-65)")
		e.self:Message(MT.Yellow, "#trackstatus - Enhanced status with playtime & modifiers")
		e.self:Message(MT.Yellow, "#trackapi - Show available API methods being used")
		e.self:Message(MT.Yellow, "#trackdebug - Show debug info for current level")
		e.self:Message(MT.Yellow, "#trackkill [exp] - Manually add a kill with EXP (for testing)")
		e.self:Message(MT.Yellow, "#trackevent - Toggle event debug messages")
		e.self:Message(MT.Yellow, "==========================================")
		return 1
	elseif e.command == "trackapi" then
		e.self:Message(MT.Yellow, "=== EQEmu API METHODS USED IN ENHANCED TRACKING ===")
		e.self:Message(MT.Yellow, "Experience Methods:")
		e.self:Message(MT.Yellow, "  client:GetEXP() - Current EXP within current level")
		e.self:Message(MT.Yellow, "  client:GetEXPForLevel(level) - Total EXP required for level")
		e.self:Message(MT.Yellow, "  client:GetEXPModifier() - Current EXP bonus multiplier")
		e.self:Message(MT.Yellow, "  client:GetEXPPercentage() - Percentage through current level")
		e.self:Message(MT.Yellow, "Character Methods:")
		e.self:Message(MT.Yellow, "  client:GetLevel() - Current character level")
		e.self:Message(MT.Yellow, "  client:CharacterID() - Unique character identifier")
		e.self:Message(MT.Yellow, "  client:GetTotalSecondsPlayed() - Total playtime in seconds")
		e.self:Message(MT.Yellow, "Group Methods:")
		e.self:Message(MT.Yellow, "  client:IsGrouped() - Check if player is in a group")
		e.self:Message(MT.Yellow, "Events:")
		e.self:Message(MT.Yellow, "  event_exp_gain(e) - Fired when EXP is gained (e.exp_gained)")
		e.self:Message(MT.Yellow, "  event_level_up(e) - Fired when character levels up")
		e.self:Message(MT.Yellow, "Total Available: 589 Client methods, 247 events, 22+ constants")
		e.self:Message(MT.Yellow, "===================================================")
		return 1
	end
	
	return eq.DispatchCommands(e);
end

-- Track kills for level progression analysis using exp gain event
function event_exp_gain(e)
  local char_id = e.self:CharacterID()
  local exp_gained = e.exp_gained
  local debug_key = "track_event_debug_" .. char_id
  if eq.get_data(debug_key) == "1" then
    e.self:Message(MT.Red, "[EVENT] event_exp_gain fired! EXP gained: " .. exp_gained)
  end
	level_tracking.track_kill(e.self, exp_gained)
end

return level_tracking