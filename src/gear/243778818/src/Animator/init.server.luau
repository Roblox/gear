--[[
	By ArceusInator
--]]
local GLib = require(206209239)
local Tool = script.Parent

local Tracks = {}
local Equipped = false

Tool.Equipped:connect(function()
	if Equipped then return end
	Equipped = true
	
	local character, player, humanoid = GLib.GetCharacter(Tool)
	if humanoid then
		for index, anim in next, script:GetChildren() do
			if anim:IsA'Animation' then
				Tracks[anim.Name] = humanoid:LoadAnimation(anim)
			end
		end
		
		--
		Tracks.Shield_Idle:Play()
	end
end)

Tool.Unequipped:connect(function()
	if not Equipped then return end
	Equipped = false
	
	for index, track in next, Tracks do
		track:Stop()
	end
	Tracks = {}
end)

script.PlayAnimation.Event:connect(function(name, speed)
	local track = Tracks[name]
	
	if track ~= nil then
		track:Play(0.1, 1, speed or 1)
	end
end)
script.StopAnimation.Event:connect(function(name)
	local track = Tracks[name]
	
	if track ~= nil then
		track:Stop()
	end
end)