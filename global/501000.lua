
local config_loans = dofile("/home/eqemu/server/quests/global/loan_config.lua")

-- Supermob depop timer: configurable from loan_config.lua
function event_spawn(e)
	local depop_ms = (config_loans.SUPER_MOB_DEPOP_MINUTES or 3) * 60000 -- minutes to ms
	eq.set_timer("depop", depop_ms)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.stop_timer("depop")
		eq.debug("Depop timer fired. Attempting to depop all supermobs with ID: " .. tostring(config_loans.SUPER_MOB_NPC_ID))
		eq.depop_all(config_loans.SUPER_MOB_NPC_ID)
	end
end

-- Despawn supermob if it kills a player
function event_killed(e)
	if e.killed:IsClient() then
		eq.debug("Supermob killed a player. Attempting to depop all supermobs with ID: " .. tostring(config_loans.SUPER_MOB_NPC_ID))
		eq.depop_all(config_loans.SUPER_MOB_NPC_ID)
	end
end
