-- Variable to stores the Canvas Item ID of Health UI (to be used to edit a specific Canvas Item (Text))
my_local_character = nil
ware_players = {}
ware_winners = {}
ware_losers = {}
my_local_player = nil


-- Spawns a WebUI with the HTML file you just created
MainHUD = WebUI("Main HUD", "file:///UI/index.html")



-- When LocalPlayer spawns, sets an event on it to trigger when we possesses a new character, to store the local controlled character locally. This event is only called once, see Package:Subscribe("Load") to load it when reloading a package
NanosWorld:Subscribe("SpawnLocalPlayer", function(local_player)
	my_local_player = local_player
    local_player:Subscribe("Possess", function(ply,chr)
		my_local_character = chr
		UpdateLocalCharacter(chr)
		
    end)
end)

-- When package loads, verify if LocalPlayer already exists (eg. when reloading the package), then try to get and store it's controlled character
Package:Subscribe("Load", function()
    if (NanosWorld:GetLocalPlayer() ~= nil) then
        UpdateLocalCharacter(NanosWorld:GetLocalPlayer():GetControlledCharacter())
    end
end)

Package:Subscribe("Unload", function()
	if (general_timer ~= nil) then
		ClearTimeout(general_timer)
	end
end)


-- Function to set all needed events on local character (to update the UI when it takes damage or dies)
function UpdateLocalCharacter(chr)
	-- Verifies if character is not nil (eg. when GetControllerCharacter() doesn't return a character)
    if (chr == nil) then return end
	my_local_character = chr
	
    -- Updates the UI with the current character's health
    UpdateHealth(chr:GetHealth())

    -- Sets on character an event to update the health's UI after it takes damage
	chr:Subscribe("TakeDamage", function(damage, type, bone, from_direction, instigator)
        UpdateHealth(chr:GetHealth())
    end)

    -- Sets on character an event to update the health's UI after it dies
    chr:Subscribe("Death", function(chr)
        UpdateHealth(0)
    end)

    -- Try to get if the character is holding any weapon
    local current_picked_item = chr:GetPicked()

    -- If so, update the UI
    if (current_picked_item and current_picked_item:GetType() == "Weapon") then
        UpdateAmmo(true, current_picked_item:GetAmmoClip(), current_picked_item:GetAmmoBag())
    end

    -- Sets on character an event to update his grabbing weapon (to show ammo on UI)
    chr:Subscribe("PickUp", function(chr,object)
        if (object:GetType() == "Weapon") then
            UpdateAmmo(true, object:GetAmmoClip(), object:GetAmmoBag())
        end
    end)

    -- Sets on character an event to remove the ammo ui when he drops it's weapon
    chr:Subscribe("Drop", function(chr,object)
        UpdateAmmo(false)
    end)

    -- Sets on character an event to update the UI when he fires
    chr:Subscribe("Fire", function(chr, weapon)
        UpdateAmmo(true, weapon:GetAmmoClip(), weapon:GetAmmoBag())
    end)

    -- Sets on character an event to update the UI when he reloads the weapon
    chr:Subscribe("Reload", function(chr,weapon, ammo_to_reload)
        UpdateAmmo(true, weapon:GetAmmoClip(), weapon:GetAmmoBag())
    end)
end

-- Function to update the Ammo's UI
function UpdateAmmo(enable_ui, ammo, ammo_bag)
    MainHUD:CallEvent("UpdateWeaponAmmo", {enable_ui, ammo, ammo_bag})
end

-- Function to update the Health's UI
function UpdateHealth(health)
    MainHUD:CallEvent("UpdateHealth", {health})
end

-- Updates valuable information
local general_timer = Timer:SetTimeout(100, function()
    if (my_local_character and my_local_character:IsValid() ) then
		local my_vector = my_local_character:GetLocation()
		--MainHUD:CallEvent("UpdatePosition", {tostring(my_vector.X), tostring(my_vector.Y), tostring(my_vector.Z)})
	end
	
	--Clear tables
	for i=0, #ware_players do ware_players[i]=nil end
	for i=0, #ware_winners do ware_winners[i]=nil end
	for i=0, #ware_losers do ware_losers[i]=nil end

	
	for key, ply in pairs(NanosWorld:GetPlayers()) do
		if ply:IsLocalPlayer() then my_local_player = ply end
		if (ply:GetControlledCharacter()) then
			table.insert(ware_players, ply)
			local ch = ply:GetControlledCharacter()
			my_local_character = ch
			local health = ch:GetHealth()
			local text_render = ply:GetValue("Nametag")
			local wareWon = ply:GetValue("wareWon")
			if (text_render and text_render:IsValid()) then
				text_render:SetColor(Color(1*(1-(health/100)),1*health/100,0))
			end			
			if (wareWon == true) then
				table.insert(ware_winners, ply)
			else
				table.insert(ware_losers, ply)
			end		
		end
	end
	
	local wRound = my_local_player:GetValue("warePoints")
	local aRound = global_ware_round
	perc = round(my_local_player:GetValue("warePoints")/aRound,3)*100
	local winners = #ware_winners
	local losers = #ware_losers
	local winstring = ""
	local losestring = ""
	
	local first = true
	
	for key, ply in pairs(ware_winners) do
		local points = ply:GetValue("warePoints")
		if first then
			first = false
			winstring = winstring..""..ply:GetName().." ("..points.."/"..aRound.." - "..(round(points/aRound,3)*100).."%)"
		else
			winstring = winstring.."<br>"..ply:GetName().." ("..points.."/"..aRound.." - "..(round(points/aRound,3)*100).."%)"
		end
	end
	
	first = true
	
	for key, ply in pairs(ware_losers) do
		local points = ply:GetValue("warePoints")
		if first then
			first = false
			losestring = losestring..""..ply:GetName().." ("..points.."/"..aRound.." - "..(round(points/aRound,3)*100).."%)"
		else
			losestring = losestring.."<br>"..ply:GetName().." ("..points.."/"..aRound.." - "..(round(points/aRound,3)*100).."%)"
		end	
	end			
	
	MainHUD:CallEvent("UpdateList", {tostring(wRound), tostring(aRound), tostring(perc), tostring(winners), tostring(winstring), tostring(losers), tostring(losestring)})		
end)


-- Function to add a Nametag to a Player
function AddNametag(player, chr)
    -- Try to get it's character
    if (chr == nil) then
        chr = player:GetControlledCharacter()
        if (chr == nil) then return end
    end
	
	if player:IsLocalPlayer()then return end
    -- Spawns the Nametag (TextRender), attaches it to the character and saves it to the player's values
    local nametag = TextRender(Vector(0,0,0), Rotator(0,0,0), player:GetName(), Color(0, 1, 0), 1, 0, 24, 1, true)
    nametag:AttachTo(chr, "", Vector(0, 0, 250), Rotator())
    player:SetValue("Nametag", nametag)
	nametag:SetCollision(false)
end

-- Function to remove a Nametag from  a Player
function RemoveNametag(player, chr)
    -- Try to get it's character
    if (chr == nil) then
        chr = player:GetControlledCharacter()
        if (chr == nil) then return end
    end

    -- Gets the Nametag from the player, if any, and destroys it
    local text_render = player:GetValue("Nametag")
    if (text_render and text_render:IsValid()) then
        text_render:Destroy()
    end
end

-- Adds a new Nametag to a character which was possessed
Character:Subscribe("Possessed", function(chr, player)
    AddNametag(player, chr)
end)


Events:Subscribe("UpdateText", function(text)
	MainHUD:CallEvent("UpdateText",{tostring(text)})
end)


-- Removes the Nametag from a character which was unpossessed
Character:Subscribe("UnPossessed", function(chr, player)
    RemoveNametag(player, chr)
end)

-- When a Player is spawned - for when you connect and there is already Player's connected
Player:Subscribe("Spawn", function(player)
    RemoveNametag(player)
    AddNametag(player)
end)


Events:Subscribe("ShowWinners", function()
	local allPlayers = {}
	local highestScore = 0;
	for key, ply in pairs(NanosWorld:GetPlayers()) do
		if (ply:GetControlledCharacter()) then
			allPlayers[#allPlayers+1] = {}
			allPlayers[#allPlayers][0] = ply:GetName()
			allPlayers[#allPlayers][1] = ply:GetValue("warePoints")	

			if (ply:GetValue("warePoints")) > highestScore then
				highestScore = ply:GetValue("warePoints");
			end
		end
	end

	local place = 1;
	local roundOverString = "<u>Winners</u><br>";
		table.sort(allPlayers, function(lhs, rhs) return lhs[1] > rhs[1] end)
	for key, ply in pairs(allPlayers) do
		if place == 1 then
			roundOverString = roundOverString.."1st <i>"..tostring(ply[0]).." ("..tostring(ply[1]).."/"..tostring(global_ware_round)..")</i>"
		elseif place == 2 then
			roundOverString = roundOverString.."<br>2nd <i>"..tostring(ply[0]).." ("..tostring(ply[1]).."/"..tostring(global_ware_round)..")</i>"
		elseif place == 3 then
			roundOverString = roundOverString.."<br>3rd <i>"..tostring(ply[0]).." ("..tostring(ply[1]).."/"..tostring(global_ware_round)..")</i>"
		elseif place == 4 then
			roundOverString = roundOverString.."<br><br><small><u>Also played:</u><br><i>"..tostring(ply[0]).." ("..tostring(ply[1]).."/"..tostring(global_ware_round)..")</i></small>"
		else
			roundOverString = roundOverString.."<small>, <i>"..tostring(ply[0]).." ("..tostring(ply[1]).."/"..tostring(global_ware_round)..")</i></small>"
		end
		place = place+1;
    end
    MainHUD:CallEvent("ShowWinners",{tostring(roundOverString)})
end)
