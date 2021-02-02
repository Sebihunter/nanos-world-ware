-- Spawns/Overrides with default NanosWorld's Sun
Package:Require("Hud.lua")
World:SpawnDefaultSun()

-- Sets the same time for everyone
local gmt_time = os.date("!*t", os.time())
local prolougeSound
--World:SetTime((gmt_time.hour * 60 + gmt_time.min) % 24, gmt_time.sec)
World:SetTime(12,00)
World:SetWeather(0)
World:SetWind(0)
World:SetSunSpeed(0)

global_ware_round = 1

function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

Events:on("ProlougeMusic", function()
	local MySound = Sound(
		Vector(-510, 145, 63), -- Location (if a 3D sound)
		"ware::WARE_Prologue", -- Asset Path
		true, -- Is 2D Sound
		true, -- Auto Destroy (if to destroy after finished playing)
		1, -- Sound Type (Music)
		1, -- Volume
		1 -- Pitch
	)
	MySound:Play()
	prolougeSound = MySound
end)

Events:on("StartWare", function()
	if prolougeSound:IsValid() and prolougeSound:IsPlaying() then
		prolougeSound:FadeOut(1000,0)
	end
end)



Events:on("syncWareRound", function(round)
	if round == 0 then round = 1 end
	global_ware_round = round
end)

Events:on("syncValue", function(ply, value, key)
	ply:SetValue(value,key)
end)

Events:on("syncValue", function(ply, value, key)
	ply:SetValue(value,key)
end)

Events:on("PlaySound", function(soundname)
	local MySound = Sound(
		Vector(0, 0, 0), -- Location (if a 3D sound)
		soundname, -- Asset Path
		true, -- Is 2D Sound
		true, -- Auto Destroy (if to destroy after finished playing)
		0, -- Sound Type (SFX)
		1, -- Volume
		1 -- Pitch
	)
	--MySound:Play()
end)