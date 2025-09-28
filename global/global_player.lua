-- Loan status check on zone entry (uses Zork Broker loan buckets)
-- Configurable penalties
local SICKNESS_SPELL_ID = 5249 -- Change this to your new sickness spell as needed
local SUPER_MOB_NPC_ID = 58015  -- Replace with your super mob NPC ID
local SUPER_MOB_CHANCE = .25 -- 25% chance to spawn super mob if WAY overdue
local BASE_LOAN_DURATION = 60 -- Loan duration in seconds (1 minute), must match 500002.lua

local function check_loan_status_on_zone(client)
	-- These must match the bucket keys in 500002.lua
	local client_id = tostring(client:CharacterID())
	local loan_key = client_id .. "_AC_loan"
	local duration_key = client_id .. "_AC_loan_duration"
	local extensions_key = client_id .. "_AC_loan_extensions"
	local interest_key = client_id .. "_AC_loan_interest"

	local amount = tonumber(eq.get_data(loan_key)) or 0
	local duration = tonumber(eq.get_data(duration_key)) or 0
	local extensions = tonumber(eq.get_data(extensions_key)) or 0
	local interest = tonumber(eq.get_data(interest_key)) or 0

	if amount > 0 then
		local now = os.time()
		local loan_duration = duration - (duration - (BASE_LOAN_DURATION or 360)) -- fallback to config value if not imported
		if loan_duration <= 0 then loan_duration = BASE_LOAN_DURATION or 360 end
		local time_left = duration - now
		local overdue_periods = 0
		if now > duration then
			overdue_periods = math.floor((now - duration) / loan_duration)
		end
		local currency_name = eq.get_item_name(500000) -- Must match currency_item_id in 500002.lua
		local escalated_interest = interest
		if time_left <= 0 then
			-- Escalate interest based on lateness
			if overdue_periods >= 10 then
				escalated_interest = interest + 0.10
			else
				escalated_interest = interest + (overdue_periods * 0.025)
			end
			-- Persist new interest
			eq.set_data(interest_key, tostring(escalated_interest))
			local total_due = math.ceil(amount * (1 + escalated_interest))
			client:Message(MT.Red, "[LOAN OVERDUE] Your loan of " .. amount .. " " .. currency_name .. " is OVERDUE! You owe a total of " .. total_due .. " (including interest). Please pay back your loan immediately or face consequences.")
			
			-- Cast configurable sickness spell
			client:CastSpell(SICKNESS_SPELL_ID, client:GetID())

			-- Milestone penalties
			if overdue_periods >= 2 then
				client:Message(MT.Red, "Your debt is seriously overdue! 2x the loan duration! Additional penalties have been applied.")
				-- Add penalty logic here

			end
			if overdue_periods >= 5 then
				client:Message(MT.Red, "Your debt is EXTREMELY overdue! 5x the loan duration! Severe penalties may occur.")
				-- Add penalty logic here
			end
			if overdue_periods >= 10 then
				client:Message(MT.Red, "Your debt is catastrophically overdue! 10x the loan duration! Beware!")
				-- Faction penalty: Lenders Guild (ID 500000)
				local FACTION_ID = 500000
				local FACTION_HIT = -1000 -- Large enough to make KOS
				client:Message(MT.Red, "Your standing with the Lenders Guild has plummeted!")
				client:Faction(FACTION_ID, FACTION_HIT)
				-- Global shame message
				eq.world_emote(0, "Zork says, " .. client:GetName() .. " is a scoundrel! I loaned him " .. amount .. " " .. currency_name .. " and he has not paid it back. Time to summon my minions!")
				-- Random chance to spawn super mob
				if math.random() < SUPER_MOB_CHANCE then
					local x, y, z = client:GetX(), client:GetY(), client:GetZ()
					eq.spawn2(SUPER_MOB_NPC_ID, 0, 0, x + 2, y + 2, z, 0)
					client:Message(MT.Red, "A debt collector has arrived to collect what you owe!")
				end
			end
		else
			-- Loan active: show reminder with time remaining
			local total_due = math.ceil(amount * (1 + interest))
			local hours = math.floor(time_left / 3600)
			local minutes = math.floor((time_left % 3600) / 60)
			local seconds = time_left % 60
			local time_str = string.format("%02dh %02dm %02ds", hours, minutes, seconds)
			client:Message(MT.Yellow, "[LOAN REMINDER] You have an active loan of " .. amount .. " " .. currency_name .. ". Time remaining: " .. time_str .. ". Total owed (with interest): " .. total_due .. " " .. currency_name)
		end
	end
end

-- Event: Player enters a zone
function event_enter_zone(e)
	e.self:Message(MT.Yellow, "Welcome to LUA.")
	check_loan_status_on_zone(e.self)
end
-- items: 67704, 72091, 62621, 62622, 62844, 62827, 62828, 62836, 62883, 62876, 47100, 62878, 62879

local don = require("dragons_of_norrath")


function event_combine_validate(e)
	-- e.validate_type values = { "check_zone", "check_tradeskill" }
	-- criteria exports:
	--	["check_zone"].         = e.zone_id
	--	["check_tradeskill"]    = e.tradeskill_id (not active)
	if (e.recipe_id == 10344) then
		if (e.validate_type:find("check_zone")) then
			if (e.zone_id ~= Zone.tipt and e.zone_id ~= Zone.vxed) then
				return 1;
			end
		end
	end

	return 0;
end

function event_combine_success(e)
	if (e.recipe_id == 10904 or e.recipe_id == 10905 or e.recipe_id == 10906 or e.recipe_id == 10907) then
		e.self:Message(MT.Default,
		"The gem resonates with power as the shards placed within glow unlocking some of the stone's power. "
		.. "You were successful in assembling most of the stone but there are four slots left to fill, "
		.. "where could those four pieces be?"
		);
	elseif(e.recipe_id == 10903 or e.recipe_id == 10346 or e.recipe_id == 10334) then
		local reward = { };
		reward["melee"] =  { ["10903"] = 67665, ["10346"] = 67660, ["10334"] = 67653 };
		reward["hybrid"] = { ["10903"] = 67666, ["10346"] = 67661, ["10334"] = 67654 };
		reward["priest"] = { ["10903"] = 67667, ["10346"] = 67662, ["10334"] = 67655 };
		reward["caster"] = { ["10903"] = 67668, ["10346"] = 67663, ["10334"] = 67656 };

		local ctype = eq.ClassType(e.self:GetClass());
		e.self:SummonItem(reward[ctype][tostring(e.recipe_id)]);
		e.self:SummonItem(67704); -- Item: Vaifan's Clockwork Gemcutter Tools
		e.self:Message(MT.Default, "Success");
	--cleric 1.5
	elseif(e.recipe_id == 19460) then
		e.self:AddEXP(25000);
		e.self:AddAAPoints(5);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 5 ability points!');
		eq.set_global("cleric_epic","7",5,"F");
	--rogue 1.5
	elseif(e.recipe_id == 13402 or e.recipe_id == 13403 or e.recipe_id == 13404 or e.recipe_id == 13405) then
		e.self:Message(MT.Yellow,"The piece of the metal orb fuses together with the blue diamonds under the intense heat of the forge. As it does, a flurry of images flash through your mind... A ranger and his bear side by side, stoic and unafraid, in a war-torn forest. A bitter tattooed woman with bluish skin wallowing in misery in a waterfront tavern. An endless barrage of crashing thunder and lightning illuminating a crimson brick ampitheater. Two halflings locked in a battle of wits using a checkered board. The images then fade from your mind");
	--ranger 1.5 tree
	elseif(e.recipe_id ==13412) then
		eq.set_global("ranger_epic","3",5,"F");
		if(eq.get_zone_short_name()=="jaggedpine") then
			e.self:Message(MT.Yellow,"The seed grows rapidly the moment you push it beneath the soil. It appears at first as a mere shoot, but within moments grows into a stout sapling and then into a gigantic tree. The tree is one you've never seen before. It is the coloration and thick bark of a redwood with the thick bole indicative of the species. The tree is, however, far too short and has spindly branches sprouting from it with beautiful flowers that you would expect on a dogwood. You take all of this in at a glance. It takes you a moment longer to realize that the tree is moving.");			
			eq.spawn2(181222, 0, 0, e.self:GetX()+3,e.self:GetY()+3,e.self:GetZ(),0); -- NPC: Red_Dogwood_Treant
		else
			e.self:Message(MT.Yellow,"The soil conditions prohibit the seed from taking hold");
			e.self:SummonItem(72091); -- Item: Fertile Earth
			e.self:SummonItem(62621); -- Item: Senvial's Blessing
			e.self:SummonItem(62622); -- Item: Grinbik's Blessing
			e.self:SummonItem(62844); -- Item: Red Dogwood Seed
		end
	--ranger 1.5 final
	elseif(e.recipe_id ==13413) then
		e.self:AddEXP(25000);
		e.self:AddAAPoints(5);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 5 ability points!');
		eq.set_global("ranger_epic","5",5,"F");
	--ranger 2.0
	elseif(e.recipe_id ==19914 or e.recipe_id==19915) then
		e.self:Message(MT.Yellow,'Very Good. Now we must attune the cage to the specific element we wish to free. You will need two items, one must protect from the element and the other must be able to absorb an incredible amount of that element. This is not a simple task. You must first discover the nature of the spirit that you wish to free and then find such items that will allow you to redirect its power. You must know that each spirit represents a specific area within their element and that is what you must focus on, not their element specifically. For example, Grinbik was an earth spirit, but his area of power was fertility. Senvial was a spirit of Water, but his power was in mist and fog.');
		eq.set_global("ranger_epic","8",5,"F");
	elseif(e.recipe_id ==19916) then
		e.self:Message(MT.Yellow,"The Red Dogwood Treant speaks to you from within your sword. 'Well done. This should allow me to free a spirit with power over cold and ice. Now you need to find the power that binds the spirit and unleash it where that spirit is bound.'");	
	elseif(e.recipe_id ==19917) then
		if(eq.get_zone_short_name()=="anguish") then
			eq.spawn2(317113, 0, 0, e.self:GetX(),e.self:GetY(),e.self:GetZ(),0); -- NPC: #Oshimai_Spirit_of_the_High_Air
		end
	-- paladin 1.5 final
	elseif(e.recipe_id ==19880) then
		e.self:AddEXP(25000);
		e.self:AddAAPoints(5);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 5 ability points!');	
		eq.set_global("paladin_epic","8",5,"F");
		e.self:Message(MT.Gray,"As the four soulstones come together, a soft blue light eminates around the dark sword. The soulstones find themselves at home within the sword. A flash occurs and four voices in unison speak in your mind, 'Thank you for saving us and giving us a purpose again. You are truly our savior and our redeemer, and we shall serve you from now on. Thank you, noble knight!")
	--bard 1.5 final	
	elseif(e.recipe_id == 19882) then
		e.self:AddEXP(25000);
		e.self:AddAAPoints(5);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 5 ability points!');	
		eq.set_global("bard15","6",5,"F");
	--druid 1.5 feerrott
	elseif(e.recipe_id == 19888) then
		if(eq.get_zone_short_name()=="feerrott") then
			eq.spawn2(47209, 0, 0, e.self:GetX()+10,e.self:GetY()+10,e.self:GetZ(),0); -- NPC: corrupted_spirit
			e.self:Message(MT.White,"compelled spirit screams as his essences is forced back into the world of the living. 'What is this? Where am I? Who are you? What do you want from me?");
		else
			e.self:SummonItem(62827); -- Item: Mangled Head
			e.self:SummonItem(62828); -- Item: Animating Heads
			e.self:SummonItem(62836); -- Item: Soul Stone
		end
	-- druid 1.5 final
	elseif(e.recipe_id ==19892) then
		e.self:AddAAPoints(5);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 5 ability points!');	
		eq.set_global("druid_epic","8",5,"F");	
		e.self:SendMarqueeMessage(MT.Yellow, 510, 1, 100, 10000, "You plant the Mind Crystal and the Seed of Living Brambles in the pot. The pot grows warm and immediately you see a vine sprouting from the soil. The vine continues to grow at a tremendous rate. Brambles grow into the heart of the crystal where the core impurity is and split it. They continue to grow at an astounding speed and soon burst the pot and form the Staff of Living Brambles");
	--druid 2.0 sub final
	elseif(e.recipe_id ==19908) then
		if(eq.get_zone_short_name()=="anguish") then
			eq.spawn2(317115, 0, 0, e.self:GetX()+3,e.self:GetY()+3,e.self:GetZ(),0); -- NPC: #Yuisaha
			e.self:SummonItem(62883); -- Item: Essence of Rainfall
			e.self:SummonItem(62876); -- Item: Insulated Container
		else
			e.self:Message(MT.Yellow,"The rain spirit cannot be reached here");
			e.self:SummonItem(47100); -- Item: Globe of Discordant Energy
			e.self:SummonItem(62876); -- Item: Insulated Container
			e.self:SummonItem(62878); -- Item: Frozen Rain Spirit
			e.self:SummonItem(62879); -- Item: Everburning Jagged Tree Limb
		end
	--druid 2.0 final
	elseif(e.recipe_id ==19909) then	
		e.self:AddEXP(50000);
		e.self:AddAAPoints(10);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 10 ability points!');	
		eq.set_global("druid_epic","13",5,"F");	
		--e.self:SendMarqueeMessage(MT.Yellow, 510, 1, 100, 10000, "You plant the Mind Crystal and the Seed of Living Brambles in the pot. The pot grows warm and immediately you see a vine sprouting from the soil. The vine continues to grow at a tremendous rate. Brambles grow into the heart of the crystal where the core impurity is and split it. They continue to grow at an astounding speed and soon burst the pot and form the Staff of Living Brambles");
	--warrior 2.0
	elseif(e.recipe_id ==19902) then	
		e.self:AddEXP(50000);
		e.self:AddAAPoints(10);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 10 ability points!');	
		eq.set_global("warrior_epic","21",5,"F");		
	-- CLR 2.0
	elseif (e.recipe_id == 19893) then
		e.self:Message(MT.Red, "Omat should probably see this.");
	--ench 2.0
	elseif (e.recipe_id == 19919) then
		eq.set_global("ench_epic","9",5,"F");
		e.self:Message(MT.Yellow,"Your Oculus of Persuasion gleams with a blinding light for a moment, dimming quickly to its previous understated beauty. The light has left an image burned into your mind, a strangely tattooed woman chanting by a waterfall.");
	--ench 2.0 final
	elseif (e.recipe_id == 19920) then
		e.self:Message(MT.Yellow,"The discordant energy shoots through the staff, sending a shower of sparks through the air. The crystal shatters before you, and as the sparks fade away you notice the changes in your staff.");
		e.self:AddEXP(50000);
		e.self:AddAAPoints(10);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 10 ability points!');
		eq.set_global("ench_epic","10",5,"F");
	--pal 2.0 final
	elseif (e.recipe_id == 19925) then
		e.self:Message(MT.Yellow,"As you combine all six tokens in the scabbard with Redemption, you feel a tugging at your soul. An energy flows through you as you feel the virtues of your inner self being tugged and tempered into the weapon. For a second you feel drained, but now that feeling has subsided. A final flash of light occurs and a new sword is tempered; Nightbane, Sword of the Valiant");
		e.self:AddEXP(50000);
		e.self:AddAAPoints(10);
		e.self:Ding();
		e.self:Message(MT.Yellow,'You have gained 10 ability points!');
		eq.set_global("paladin_epic","11",5,"F");
		eq.delete_global("paladin_epic_mmcc");
		eq.delete_global("paladin_epic_hollowc");
	elseif (e.recipe_id == 2182) then -- Pumpkin Pie
		if (eq.is_task_activity_active(8013, 0)) then -- The Hungry Halfling
			eq.update_task_activity(8013, 0, 1);
		end
	elseif (e.recipe_id == 2181) then -- Pumpkin Bread
		if (eq.is_task_activity_active(8013, 1)) then -- The Hungry Halfling
			eq.update_task_activity(8013, 1, 1);
		end
	elseif (e.recipe_id == 7811) then -- Spiced Pumpkin Cider
		if (eq.is_task_activity_active(8013, 2)) then -- The Hungry Halfling
			eq.update_task_activity(8013, 2, 1);
		end
	elseif (e.recipe_id == 2183) then -- Pumpkin Shake
		if (eq.is_task_activity_active(8013, 3)) then -- The Hungry Halfling
			eq.update_task_activity(8013, 3, 1);
		end
	end
end



--[[ the main key is the ID of the AA
--   the first set is the age required in seconds
--   the second is if to ignore the age and grant anyways live test server style
--   the third is enabled
--]]
vet_aa = {
    [481]  = { 31536000, true, true}, -- Lesson of the Devote 1 yr
    [482]  = { 63072000, true, true}, -- Infusion of the Faithful 2 yr
    [483]  = { 94608000, true, true}, -- Chaotic Jester 3 yr
    [484]  = {126144000, true, true}, -- Expedient Recovery 4 yr
    [485]  = {157680000, true, true}, -- Steadfast Servant 5 yr
    [486]  = {189216000, true, true}, -- Staunch Recovery 6 yr
    [487]  = {220752000, true, true}, -- Intensity of the Resolute 7 yr
    [511]  = {252288000, true, true}, -- Throne of Heroes 8 yr
    [2000] = {283824000, true, true}, -- Armor of Experience 9 yr
    [8081] = {315360000, true, true}, -- Summon Resupply Agent 10 yr
    [8130] = {346896000, true, true}, -- Summon Clockwork Banker 11 yr
    [453]  = {378432000, true, true}, -- Summon Permutation Peddler 12 yr
    [182]  = {409968000, true, true}, -- Summon Personal Tribute Master 13 yr
    [600]  = {441504000, true, true}, -- Blessing of the Devoted 14 yr
}


function event_connect(e)
	grant_veteran_aa(e)
	don.fix_invalid_faction_state(e.self)
	-- Initialize level tracking for new connections
	--level_tracking.init_tracking(e.self)
end

function grant_veteran_aa(e)
	if not eq.is_dragons_of_norrath_enabled() then
		return
	end

    local age = e.self:GetAccountAge();
    for aa, v in pairs(vet_aa) do
        if v[3] and (v[2] or age >= v[1]) then
            e.self:GrantAlternateAdvancementAbility(aa, 1)
        end
    end
end

--[[
0  /*13855*/ Skill1HBlunt = 0,
1  /*13856*/ Skill1HSlashing,
2  /*13857*/ Skill2HBlunt,
3  /*13858*/ Skill2HSlashing,
4  /*13859*/ SkillAbjuration,
5  /*13861*/ SkillAlteration,
6  /*13862*/ SkillApplyPoison, X
7  /*13863*/ SkillArchery, X
8  /*13864*/ SkillBackstab,
9  /*13866*/ SkillBindWound,
10 /*13867*/ SkillBash,
11 /*13871*/ SkillBlock,
12 /*13872*/ SkillBrassInstruments,
13 /*13874*/ SkillChanneling,
14 /*13875*/ SkillConjuration,
15 /*13876*/ SkillDefense,
16 /*13877*/ SkillDisarm,
17 /*13878*/ SkillDisarmTraps, 
18 /*13879*/ SkillDivination,
19 /*13880*/ SkillDodge,
20 /*13881*/ SkillDoubleAttack,
21 /*13882*/ SkillDragonPunch,
21 /*13924*/ SkillTailRake = SkillDragonPunch, // Iksar Monk equivilent
22 /*13883*/ SkillDualWield,
23 /*13884*/ SkillEagleStrike,
24 /*13885*/ SkillEvocation,
25 /*13886*/ SkillFeignDeath,
26 /*13888*/ SkillFlyingKick,
27 /*13889*/ SkillForage, X
28 /*13890*/ SkillHandtoHand,
29 /*13891*/ SkillHide,
30 /*13893*/ SkillKick,
31 /*13894*/ SkillMeditate,
32 /*13895*/ SkillMend,
33 /*13896*/ SkillOffense,
34 /*13897*/ SkillParry,
35 /*13899*/ SkillPickLock, X
36 /*13900*/ Skill1HPiercing,        // Changed in RoF2(05-10-2013)
37 /*13903*/ SkillRiposte,
38 /*13904*/ SkillRoundKick,
39 /*13905*/ SkillSafeFall, 
40 /*13906*/ SkillSenseHeading, X
41 /*13908*/ SkillSinging,
42 /*13909*/ SkillSneak,
43 /*13910*/ SkillSpecializeAbjure,      // No idea why they truncated this one..especially when there are longer ones...
44 /*13911*/ SkillSpecializeAlteration,
45 /*13912*/ SkillSpecializeConjuration,
46 /*13913*/ SkillSpecializeDivination,
47 /*13914*/ SkillSpecializeEvocation,
48 /*13915*/ SkillPickPockets, X
49 /*13916*/ SkillStringedInstruments,
50 /*13917*/ SkillSwimming, X
51 /*13919*/ SkillThrowing,
52 /*13920*/ SkillTigerClaw,
53 /*13921*/ SkillTracking, X
54 /*13923*/ SkillWindInstruments,
55 /*13854*/ SkillFishing, X
56 /*13853*/ SkillMakePoison, X
57 /*13852*/ SkillTinkering, X
58 /*13851*/ SkillResearch, X
59 /*13850*/ SkillAlchemy, X
60 /*13865*/ SkillBaking, X
61 /*13918*/ SkillTailoring, X
62 /*13907*/ SkillSenseTraps, X
63 /*13870*/ SkillBlacksmithing, X
64 /*13887*/ SkillFletching, X
65 /*13873*/ SkillBrewing, X
66 /*13860*/ SkillAlcoholTolerance, X
67 /*13868*/ SkillBegging, 
68 /*13892*/ SkillJewelryMaking, X
69 /*13901*/ SkillPottery, X
70 /*13898*/ SkillPercussionInstruments,
71 /*13922*/ SkillIntimidation,
72 /*13869*/ SkillBerserking,
73 /*13902*/ SkillTaunt,
74 /*05837*/ SkillFrenzy,
75 /*03670*/  SkillRemoveTraps,  X
76 /*13049*/  SkillTripleAttack,
]]--

function event_level_up(e)
  -- Track level progression for empirical data
	level_tracking.on_level_up(e.self, e.self:GetLevel())
  
  local free_skills =  {0,1,2,3,4,5,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28,29,30,31,32,33,34,36,37,38,39,41,42,43,44,45,46,47,49,51,52,54,67,70,71,72,73,74,76};

  for k,v in ipairs(free_skills) do
    if ( e.self:MaxSkill(v) > 0 and e.self:GetRawSkill(v) < 1 and e.self:CanHaveSkill(v) ) then
      e.self:SetSkill(v, 1);
    end
  end

  if e.self:GetLevel() == 5 then
    eq.popup("", "<c \"#F0F000\">Welcome to level 5.</c><br><br>You have just been granted a new ability called '<c \"#F0F000\">Origin</c>' which allows you to teleport back to your starting city.<br><br>Open the Alternate Advancement window by pressing the '<c \"#F0F000\">V</c>' key, look in the '<c \"#F0F000\">General' tab</c>, and find the '<c \"#F0F000\">Origin</c>' ability and select it.<br><br>Now press the '<c \"#F0F000\">Hotkey</c>' button to create a hotkey you can place on your hot bar.");
  end

  if e.self:GetLevel() == 10 and eq.is_dragons_of_norrath_enabled() then
    eq.popup("", "<c \"#F0F000\">Welcome to level 10.</c><br><br>You are now able to begin the new player armor and weapon quests.  Speak with Castlen and Barrenzin or V`Lynn Renloe in the <c \"#66CCFF\">Plane of Knowledge</c> to begin.  One additional quest will become available to you at each level past level 10, so be sure to check back with these NPCs as you continue to gain experience.");
  end
end

test_items = {
    [Class.WARRIOR]			= {38000, 38020}, -- Warrior
    [Class.CLERIC]			= {38168, 38188}, -- Cleric
    [Class.PALADIN]			= {38084, 38104}, -- Paladin
    [Class.RANGER]			= {38105, 38125}, -- Ranger
    [Class.SHADOWKNIGHT]	= {38063, 38083}, -- Shadowknight
    [Class.DRUID]			= {38189, 38209}, -- Druid
    [Class.MONK]			= {38021, 38041}, -- Monk
    [Class.BARD]			= {38147, 38167}, -- Bard
    [Class.ROGUE]			= {38042, 38062}, -- Rogue
    [Class.SHAMAN]			= {38210, 38230}, -- Shaman
    [Class.NECROMANCER]		= {38294, 38314}, -- Necromancer
    [Class.WIZARD]			= {38231, 38251}, -- Wizard
    [Class.MAGICIAN]		= {38252, 38272}, -- Magician
    [Class.ENCHANTER]		= {38273, 38293}, -- Enchanter
    [Class.BEASTLORD]		= {38126, 38146}, -- Beastlord
    [Class.BERSERKER]		= {38315, 38332}, -- Berserker
}
 
function event_test_buff(e)
    if (e.self:GetLevel() < 25) then
        e.self:SetLevel(25)
        eq.scribe_spells(25,1)
        eq.train_discs(25,1)
        for class_id, v in pairs(test_items) do
            if e.self:GetClass() == class_id then
                for item_id = v[1], v[2] do
                    e.self:SummonItem(item_id);
                end
            end
        end
    end
end

function event_task_complete(e)
  don.on_task_complete(e.self, e.task_id)
end
