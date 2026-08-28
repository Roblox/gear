-- // Created by StarWars
local players = game:GetService("Players")

local tool = script.Parent

local player
local character
local humanoid

local remotesFolder = tool.Remotes
local serverControls = remotesFolder.ServerControls
local clientControls = remotesFolder.ClientControls

local PUSH_SPEED = 100
local MAX_RANGE = 25

function InvokeClient(mode, value)
	if not player then return end
	
	local result
	
	pcall(function()
		result = clientControls:InvokeClient(player, mode, value)
	end)	
	
	return result
end

tool.Equipped:Connect(function()
	character = tool.Parent
	player = players:GetPlayerFromCharacter(character)
	humanoid = character:FindFirstChildOfClass("Humanoid")
	tool.Enabled = true
end)

tool.Unequipped:Connect(function()
	player = nil
	character = nil
	humanoid = nil
	tool.Enabled = false
end)

tool.Activated:Connect(function()
	if player and character and humanoid and humanoid.RootPart and humanoid.Health > 0 and tool.Enabled then
		tool.Enabled = false
		local mouseData = InvokeClient("GetMouseData")
		if mouseData then
			if mouseData.Target then
				local distance = (mouseData.Target.CFrame.p - humanoid.RootPart.CFrame.p).Magnitude
				if distance <= MAX_RANGE then
					local parentTo = mouseData.Target.Parent
					if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
						parentTo = parentTo.Parent
					end
					local targetHumanoid = parentTo:FindFirstChildOfClass("Humanoid")
					if targetHumanoid and targetHumanoid.RootPart and targetHumanoid.Health > 0 then
						local direction = (targetHumanoid.RootPart.CFrame.p - humanoid.RootPart.CFrame.p).Unit			
						local velocity = direction * PUSH_SPEED
						
						targetHumanoid.Sit = true			
						targetHumanoid.RootPart.Velocity = velocity
					end
				end
			end
		end
		
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "toolanim"
		stringValue.Value = "Slash"
		stringValue.Parent = tool		
		
		wait(1)
		tool.Enabled = true
	end
end)

serverControls.OnServerInvoke = function(client, mode, value)
	if player == client then
		-- we have nothing to worry about here.
	end
end