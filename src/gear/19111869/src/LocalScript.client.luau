--Made by Stickmasterluke
--Rescripted by StarWars

local Players = game:GetService("Players")

local Tool = script.Parent

local Player = Players.LocalPlayer

local LastUse = Tool:WaitForChild("LastUse")

local COOLDOWN = 10

function OnEquipped(mouse)
	if mouse and Player then
		if tick() - COOLDOWN < LastUse.Value then
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			wait(LastUse.Value - (tick() - COOLDOWN))
			mouse.Icon = "rbxasset://textures\\GunCursor.png"
		else
			mouse.Icon = "rbxasset://textures\\GunCursor.png"
		end
		
		mouse.Button1Down:Connect(function()
			if tick() - COOLDOWN < LastUse.Value then
				mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
				wait(LastUse.Value - (tick() - COOLDOWN))
				mouse.Icon = "rbxasset://textures\\GunCursor.png"
			else
				mouse.Icon = "rbxasset://textures\\GunCursor.png"
			end
		end)
	end
end

Tool.Equipped:Connect(OnEquipped)