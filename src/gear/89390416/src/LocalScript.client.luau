--Rescripted by StarWars
local Player = game.Players.LocalPlayer
local COOL_DOWN = 20
local LastClick = 0

local function OnEquipped(mouse)
	if mouse then
		if tick() - COOL_DOWN > LastClick then
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			wait(LastClick - (tick() - COOL_DOWN))
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		else
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		end
		
		mouse.Button1Up:connect(function()
			if tick() - COOL_DOWN > LastClick and mouse.Target and mouse.Hit then
				local Character = Player.Character
				if Character then
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if Humanoid and Humanoid.Health > 0 then
						LastClick = tick()
						mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
					end
				end
			end
		end)
	end
end

script.Parent.Equipped:connect(OnEquipped)