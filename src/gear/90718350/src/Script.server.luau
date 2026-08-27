-- Made by Stickmasterluke
 -- edited by fusroblox
--[[
	Fixed by ArceusInator
	1/23/2015 - Made it work with FE
--]]

function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
	end
	return obj:FindFirstChild(name)
end

local Reloading = "http://www.roblox.com/asset/?id=50911776"

local Cursors = {
"http://www.roblox.com/asset/?id=90875398",--50912619", -- red -- change the cursors
"http://www.roblox.com/asset/?id=50912641", -- blue
"http://www.roblox.com/asset/?id=90875896", -- purple
Reloading = "http://www.roblox.com/asset/?id=90875896", }--50911776", }

local ClipSize = 45
local Equipped = false

local Tool = script.Parent
local Player = game.Players.localPlayer
local Ammo = WaitForChild(Tool,"Ammo")
local Clips = nil


function UpdateGui()
	
end

Tool.RemoteEvent.OnServerEvent:Connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'ClickDown' then
			local hit = ...
			
			if not Tool.Down.Value then
				Tool.Aim.Value = hit.p
				Tool.Down.Value = true
				while Tool.Down.Value do
					Tool.Aim.Value = hit.p
					wait()
				end
			end
		elseif action == 'ClickUp' then
			Tool.Down.Value = false
		end
	end
end)

function OnEquipped(mouse)
	Equipped = true
	local Player = game.Players.LocalPlayer
	if Player then
		UpdateGui()
	end
end

function OnUnequipped()
	Equipped = false
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)


while Tool:FindFirstChild("Reloading") == nil do
	wait(1)
end
Tool.Reloading.Changed:connect(function()
	UpdateGui()
end)

function PlayFireAni()
	local Humanoid = WaitForChild(Tool.Parent, "Humanoid")
	local Animation = Tool.FireAni
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Tool.R15FireAni
	end 
	local aniTrack = Humanoid:LoadAnimation(Animation)
	aniTrack:Play()
end

Tool.DoFireAni.Changed:connect(PlayFireAni)
