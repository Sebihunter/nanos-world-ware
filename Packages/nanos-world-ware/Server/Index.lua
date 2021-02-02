-- List of Character Meshes
map_boundaries = {}
--scaleFix = nil

wareState = -1
wareGame = -1
wareRound = 0
wareMaxRounds = 20
wareTimers = {}
wareObjects = {}


--[[
Game Ideas:
- Survive
- Kill somebody
- Avoid the explosion
- Avoid the insanity cow
- Dont get punched by the robot
- Dive
- Type in the answer (maths)
- Don't fall
- jump on the boxes
- get in the checkpoint
- Land safe (parachute)
- Do the crab (look up)
- Stay dry
- Watch the crates, then break a melon
- Shoot a Box
- Shoot the object
- Shut down the music
- Catch a packet (things falling)
- Catch a bouncing ball
- Collect money
- Dont get hit
- Work as a team - break all crates
- Find a battery and plug it in
- Hit the bullseye exactly X times
- Jump the crate with reverse vision
- shoot colored boxes in the right
]]

--[[
-- Add Scoreboard with ranks (highscore of the round)
-- Better graphics
]]

syncedValues = {}

wareGameList = {}

wareGames = {
	{"Crouch", 4000, false}, -- 1
	{"Jump", 4000, false}, -- 2
	{"Walk slowly", 7000, false}, -- 3
	{"Don't move", 7000, false}, -- 4
	{"Don't stop running", 7000, false}, -- 5
	{"Switch into first-person mode", 3000, false}, --6
	{"Switch into third-person mode", 3000, false}, -- 7
	{"Get on the floor", 3000, false}, -- 8
	{"Punch somebody", 5000, false},-- 9
	{"Punch the robot", 10000, false},-- 10
	{"Don't get hit", 5000, false} -- 11
}
	

character_meshes = {
	"NanosWorld::SK_Male",
	"NanosWorld::SK_Female",
	--"NanosWorld::SK_Mannequin"
}

-- List of Spawn Locations
spawn_locations = {
	Vector(0, 0, 1300),
	Vector(100, 100, 1300),
	Vector(150, 150, 1300),
	Vector(200, 200, 1300),
	Vector(250, 250, 1300),
	Vector(300, 300, 1300),
	Vector(350, 350, 1300),
	Vector(400, 400, 1300),
	Vector(450, 450, 1300),
	Vector(500, 500, 1300),
	Vector(-100, 100, 1300),
	Vector(-150, 150, 1300),
	Vector(-200, 200, 1300),
	Vector(-250, 250, 1300),
	Vector(-300, 300, 1300),
	Vector(-350, 350, 1300),
	Vector(-400, 400, 1300),
	Vector(-450, 450, 1300),
	Vector(-500, 500, 1300),
	Vector(100, -100, 1300),
	Vector(150, -150, 1300),
	Vector(200, -200, 1300),
	Vector(250, -250, 1300),
	Vector(300, -300, 1300),
	Vector(350, -350, 1300),
	Vector(400, -400, 1300),
	Vector(450, -450, 1300),
	Vector(-500, -500, 1300),
	Vector(-100, -100, 1300),
	Vector(-150, -150, 1300),
	Vector(-200, -200, 1300),
	Vector(-250, -250, 1300),
	Vector(-300, -300, 1300),
	Vector(-350, -350, 1300),
	Vector(-400, -400, 1300),
	Vector(-450, -450, 1300),
	Vector(-500, -500, 1300)	
}

function resetPlayer(player)
	setSyncedValue(player, "wareWon", false)
	setSyncedValue(player, "warePoints", 0)
end

function playSound(player, sound)
	Events:CallRemote("PlaySound", player, {sound})
end

function setSyncedValue(player, value, key)
	if not player then return end
	player:SetValue(value, key)
	if not syncedValues[value] then
		table.insert(syncedValues, value)
	end
	Events:BroadcastRemote("syncValue", {player, value, key})
end

function startMinigame()
	for key, ply in pairs(NanosWorld:GetPlayers()) do
		playSound(ply, "ware::WARE_New")
		setSyncedValue(ply, "wareWon", false)
	end
	
	wareState = 0
	wareRound = wareRound+1
	if #wareGameList == 0 then
		for i = 1, #wareGames do
			table.insert(wareGameList, i)
		end
	end
	local selectGame = math.random(1, #wareGameList)
	
	wareGame = wareGameList[selectGame]
	--Server:BroadcastChatMessage(wareGame.." "..selectGame.." "..#wareGames.." "..#wareGameList)
	table.remove(wareGameList, selectGame)
	
	--wareGame = math.random(1, #wareGames)
	--wareGame = 1
	
	local gameDuration = wareGames[wareGame][2]/6
	for i = 1, 5, 1 do --pseudocode
		table.insert(wareTimers, Timer:SetTimeout(gameDuration*i, function(i)
			--Server:BroadcastChatMessage("<orange>"..(6-i).."</>")
			for key, ply in pairs(NanosWorld:GetPlayers()) do
				playSound(ply, "ware::WARE_Count"..(6-i))
				if wareGame == 3 then
					if ply:GetValue("gait")  ~= 1 then
						if ply:GetValue("wareWon") == true then playSound(ply, "ware::WARE_l"..math.random(1,3)) end
						setSyncedValue(ply, "wareWon", false)
					end
				elseif wareGame == 4 then
					if ply:GetValue("gait")  ~= 0 then
						if ply:GetValue("wareWon") == true then playSound(ply, "ware::WARE_l"..math.random(1,3)) end
						setSyncedValue(ply, "wareWon", false)
					end
				elseif wareGame == 5 then
					if ply:GetValue("gait")  ~= 2 then
						if ply:GetValue("wareWon") == true then playSound(ply, "ware::WARE_l"..math.random(1,3)) end
						setSyncedValue(ply, "wareWon", false)
					end
				elseif wareGame == 6 then
					local ch = ply:GetControlledCharacter()
					if ch then
						if ch:GetViewMode() ~= 0 then
							if ply:GetValue("wareWon") == true then playSound(ply, "ware::WARE_l"..math.random(1,3)) end
							setSyncedValue(ply, "wareWon", false)	
						else
							if ply:GetValue("wareWon") == false then playSound(ply, "ware::WARE_w"..math.random(1,3)) end
							setSyncedValue(ply, "wareWon", true)							
						end
					end			
				elseif wareGame == 7 then
					local ch = ply:GetControlledCharacter()
					if ch then
						if ch:GetViewMode() == 0 then
							if ply:GetValue("wareWon") == true then playSound(ply, "ware::WARE_l"..math.random(1,3)) end
							setSyncedValue(ply, "wareWon", false)	
						else
							if ply:GetValue("wareWon") == false then playSound(ply, "ware::WARE_w"..math.random(1,3)) end
							setSyncedValue(ply, "wareWon", true)							
						end
					end			
				end
			end
			return false
		end, {i}))
	end	
	
	Events:BroadcastRemote("UpdateText", {"<div style='color:#ffa500'>Objective</div> "..wareGames[wareGame][1]})

	if wareGame == 1 then -- Duck
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			if (ply:GetValue("stance") == 2) then
				setSyncedValue(ply, "wareWon", true)
				playSound(ply, "ware::WARE_w"..math.random(1,3))
			end
		end
	elseif wareGame == 2 then
		-- Do nothing
	elseif wareGame == 3 or wareGame == 4 or wareGame == 5 then
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			setSyncedValue(ply, "wareWon", true)
		end		
	elseif wareGame == 6 then
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			local ch = ply:GetControlledCharacter()
			if ch then
				if ch:GetViewMode() == 0 then
					setSyncedValue(ply, "wareWon", true)
					playSound(ply, "ware::WARE_w"..math.random(1,3))			
				end
			end
		end	
	elseif wareGame == 7 then
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			local ch = ply:GetControlledCharacter()
			if ch then
				if ch:GetViewMode() == 1 or ch:GetViewMode() == 2 or ch:GetViewMode() == 3 then
					setSyncedValue(ply, "wareWon", true)
					playSound(ply, "ware::WARE_w"..math.random(1,3))			
				end
			end
		end			
	elseif wareGame == 8 then -- Duck
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			if (ply:GetValue("stance") == 3) then
				setSyncedValue(ply, "wareWon", true)
				playSound(ply, "ware::WARE_w"..math.random(1,3))
			end
		end
	elseif wareGame == 10 then --Punch the robot
		local playerTable = {}
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			ply:SetValue("wareRobot", false)
			if ply:GetControlledCharacter() ~= nil then
				table.insert(playerTable, ply)
			end
		end	
		
		local robotPlayer = playerTable[math.random(1, #playerTable)]
		local chr = robotPlayer:GetControlledCharacter()
		if chr and chr:IsValid() then
			local position = chr:GetLocation()
			local rotation = chr:GetRotation()
			chr:Destroy()
			local new_char = Character(position, rotation,"NanosWorld::SK_Mannequin")
			new_char:SetScale(Vector(2,2,2))
			robotPlayer:Possess(new_char)
			robotPlayer:SetValue("wareRobot", true)
		end
	elseif wareGame == 11 then
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			local ch = ply:GetControlledCharacter()
			if ch then
				setSyncedValue(ply, "wareWon", true)
			end
		end		
	end
	
	table.insert(wareTimers, Timer:SetTimeout(wareGames[wareGame][2], function()
		endMinigame()
		return false
	end))
	
	wareState = 1
end


function endMinigame()
	wareState = 0
	Events:BroadcastRemote("syncWareRound", {wareRound})
	for key, ply in pairs(NanosWorld:GetPlayers()) do
		if ply:GetValue("wareWon") == true then
			playSound(ply, "ware::WARE_Win")
			setSyncedValue(ply, "warePoints", (ply:GetValue("warePoints"))+1)
			Events:CallRemote("UpdateText", ply, {"<div style='color:#00ff00'>You won the round.<br>+1 Point(s)</div>"})
		else
			playSound(ply, "ware::WARE_Lose")
			Events:CallRemote("UpdateText", ply, {"<div style='color:#ff0000'>You lost the round.</div>"})
		end
		
		if wareGame == 10 then
			if ply:GetValue("wareRobot") == true then
				ply:SetValue("wareRobot", false)
				local chr = ply:GetControlledCharacter()
				if chr and chr:IsValid() then
					local position = chr:GetLocation()
					local rotation = chr:GetRotation()
					chr:Destroy()
					local new_char = Character(spawn_locations[math.random(#spawn_locations)], Rotator(), character_meshes[math.random(#character_meshes)])	
					new_char:SetLocation(position)
					new_char:SetRotation(rotation)
					ply:Possess(new_char)
				end				
			end
		end
	end
	
	if wareRound >= wareMaxRounds then
		table.insert(wareTimers, Timer:SetTimeout(10000, function()
			--Server:ReloadPackage("nanos-world-ware")
			return false
		end))		
	else
		table.insert(wareTimers, Timer:SetTimeout(3000, function()
			startMinigame()
			return false
		end))
	end
end


function resetWare()
	for i = 1, #wareObjects, 1 do --pseudocode
		if (wareObjects[i]) then wareObjects[i]:Destroy() end
	end	
	for i = 1, #wareTimers, 1 do --pseudocode
		if (wareTimers[i]) then Timer:ClearTimeout(wareTimers[i]) end
	end		
	wareState = 0
	wareGame = -1
	wareRound = 0
	wareTimers = {}
	wareObjects = {}
end

-- When Player Connects, spawns a new Character and gives it to him
Player:on("Spawn", function(player)
	if (#NanosWorld:GetPlayers() ~= 0) then
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			for key2, value in pairs(syncedValues) do
				local key3 = ply:GetValue(value)
				Events:CallRemote("syncValue", player, {ply, value, key3})
			end
		end	
	end	

	resetPlayer(player)
	Events:CallRemote("syncWareRound", player, {wareRound})
	--scaleFix:SetScale(Vector(60,60,2))
	local new_char = Character(spawn_locations[math.random(#spawn_locations)], Rotator(), character_meshes[math.random(#character_meshes)])
	player:Possess(new_char)
	
	if wareState == -1 then
		Events:CallRemote("ProlougeMusic", player, {})
	end
	
	-- Sets a callback to automatically respawn the character, 5 seconds after he dies
	player:on("Death", function()
		Timer:SetTimeout(10000, function(player)
			if player and player:IsValid() then
				local character = player:GetControlledCharacter()
				if (character and character:IsValid()) then
					character:SetHealth(100)
					character:Respawn()
				end

				return false
			else
				return true
			end
		end, {player})
	end)
end)

-- Called when Character respawns
Character:on("Respawn", function(character)
	-- Sets the Initial Character's Location (location where the Character will spawn). After the Respawn event, a
	-- call for SetLocation(InitialLocation) will be triggered. If you always want something to respawn at the same
	-- position you do not need to keep setting SetInitialLocation, this is just for respawning at random spots
	character:SetInitialLocation(spawn_locations[math.random(#spawn_locations)])
end)

-- When Player Unpossess a Character (when player is unpossessing because is disconnecting 'is_player_disconnecting' = true)
Player:on("UnPossess", function(player, character, is_player_disconnecting)
	if (is_player_disconnecting) then
		character:Destroy()
		if (#NanosWorld:GetPlayers() == 1) then
			Server:ReloadPackage("nanos-world-ware") -- End the gamemode if nobody is online
		end
	end
end)

-- Catchs a custom event "MapLoaded" to override this script spawn locations
Events:on("MapLoaded", function(map_custom_spawn_locations)
	spawn_locations = map_custom_spawn_locations
	
	
end)

--0 - Shot, 1 - Explosion
Character:on("TakeDamage", function(chr, damage, bonestring, damType, fromDirection, instigator)
	local ply = chr:GetPlayer()
	if ply then
		if wareGame == 9 and wareState == 1 and instigator ~= ply and instigator:GetValue("wareWon") ~= true then
			setSyncedValue(instigator, "wareWon", true)
			playSound(instigator, "ware::WARE_w"..math.random(1,3))	
		elseif wareGame == 10 and wareState == 1 and instigator ~= ply and instigator:GetValue("wareWon") ~= true then
			if ply:GetValue("wareRobot") == true then			
				setSyncedValue(instigator, "wareWon", true)
				playSound(instigator, "ware::WARE_w"..math.random(1,3))	
			end
		elseif wareGame == 11 and wareState == 1 and instigator ~= ply and instigator:GetValue("wareWon") ~= true then
			setSyncedValue(ply, "wareWon", false)
			playSound(instigator, "ware::WARE_l"..math.random(1,3))	
		end	
	end
end)


--0 - None, 1 - Standing, 2 - Crouching, 3 - Proning
Character:on("StanceModeChanged", function(chr, oldState, newState)
	local ply = chr:GetPlayer()
	if ply then
		ply:SetValue("stance", newState)
		if wareGame == 1 and newState == 2 and wareState == 1 then
			setSyncedValue(ply, "wareWon", true)
			playSound(ply, "ware::WARE_w"..math.random(1,3))	
		elseif wareGame == 1 and newState ~= 2 and oldState == 2 and wareState == 1 then
			setSyncedValue(ply, "wareWon", false)
			playSound(ply, "ware::WARE_l"..math.random(1,3))
		elseif wareGame == 8 and newState == 3 and wareState == 1 then
			setSyncedValue(ply, "wareWon", true)
			playSound(ply, "ware::WARE_w"..math.random(1,3))	
		elseif wareGame == 8 and newState ~= 3 and oldState == 3 and wareState == 1 then
			setSyncedValue(ply, "wareWon", false)
			playSound(ply, "ware::WARE_l"..math.random(1,3))
		end		
	end
end)

--0 - None, 1 - Walking, 2 - Sprinting
Character:on("GaitModeChanged", function(chr, oldState, newState)
	local ply = chr:GetPlayer()
	if ply then
		ply:SetValue("gait", newState)
	end
end)


--0 - None, 1 - Jumping, 2 - Climbing, 3 - Vaulting, 4 - Falling, 5 - HighFalling, 6 - Parachuting, 7 - SkyDiving
Character:on("FallingModeChanged", function(chr, oldState, newState)
	local ply = chr:GetPlayer()
	if ply then
		if wareGame == 2 and newState == 1 then
			setSyncedValue(ply, "wareWon", true)
			playSound(ply, "ware::WARE_w"..math.random(1,3))	
		end
	end
end)

Package:on("Load", function()
	print("nanos-world-ware loaded")
	Server:BroadcastChatMessage("<bold>*********************************************************</>")
	Server:BroadcastChatMessage("Welcome to <orange>nanos world ware</> dev-version!")
	Server:BroadcastChatMessage("<orange>The goals are simple:</>")
	Server:BroadcastChatMessage("<orange>-</> Do what the game says")
	Server:BroadcastChatMessage("<orange>-</> Collect points by winning minigames")
	Server:BroadcastChatMessage("<orange>-</> The person with the most points after <orange>"..wareMaxRounds.." rounds</> wins.")
	Server:BroadcastChatMessage("The game starts in <orange>10 seconds</>.")
	Server:BroadcastChatMessage("<bold>*********************************************************</>")
	local MyProp = Prop( Vector(0,0, 1000), Rotator(0, 0, 0),  "NanosWorld::SM_Cylinder")
	MyProp:SetCollision(0)
	MyProp:SetScale(Vector(60,60,2))
	MyProp:SetTintColor(Color(0.2,0.2,0,0))
	MyProp:SetGravityEnabled(false)
	Events:BroadcastRemote("ProlougeMusic", {})
	--scaleFix = MyProp
	table.insert(map_boundaries, MyProp)
	for key, ply in pairs(NanosWorld:GetPlayers()) do
		if (ply:GetControlledCharacter()) then
			local ch = ply:GetControlledCharacter()
			ply:GetControlledCharacter():Respawn()
			resetPlayer(ply)
		end
	end
	
	table.insert(wareTimers, Timer:SetTimeout(2000, function()
		if (#NanosWorld:GetPlayers() < 1) then
			return true
		else
			Events:BroadcastRemote("StartWare", {})
			startMinigame()
		end
		return false
	end))

end)

Package:on("Unload", function()
	print("nanos-world-ware unloaded")
	for i = 1, #map_boundaries, 1 do --pseudocode
		map_boundaries[i]:Destroy()
	end	
end)


-- Updates valuable information
local general_timer = Timer:SetTimeout(250, function()
	if (#NanosWorld:GetPlayers() == 0) then
	
	else
		for key, ply in pairs(NanosWorld:GetPlayers()) do
			if (ply:GetControlledCharacter()) then
				local ch = ply:GetControlledCharacter()
				local pos = ch:GetLocation()
				if (pos.Z < 1000) then
					ch:SetHealth(1)
				end
			end
		end	
	end
   -- if (my_local_character ~= nil ) then
	--	local my_vector = my_local_character:GetLocation()
	--	MainHUD:CallEvent("UpdatePosition", {tostring(my_vector.X), tostring(my_vector.Y), tostring(my_vector.Z)})
	--end
end)