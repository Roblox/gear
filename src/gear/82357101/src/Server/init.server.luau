function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle",10)

local MouseClick = Tool:WaitForChild("MouseClick",10)

local PrisonScript = script:WaitForChild("CellScript",10)
local DisableBackpack = script:WaitForChild("DisableBackpack",10)

local Players = (game:FindService("Players") or game:GetService("Players"))
local Debris = (game:FindService("Debris") or game:GetService("Debris"))

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local function IsJailed(Hum) -- Quick check to see if they're not jailed
	local Children = Services.ServerScriptService:GetChildren()
	for i=1, #Children do
		if Children[i]:IsA("Script") and Children[i].Name == "CellScript" and Children[i]:FindFirstChild("Target") and Children[i]:FindFirstChild("Target").Value == Hum.Parent then
			return true
		end
	end
	return false
end


MouseClick.OnServerEvent:Connect(function(Player,SelectedTargetCharacter)
	--print("Activated")
	if not Player or not SelectedTargetCharacter then return end
	local Torso = (SelectedTargetCharacter:FindFirstChild("HumanoidRootPart") or SelectedTargetCharacter:FindFirstChild("Torso"))
	local Humanoid,FF = SelectedTargetCharacter:FindFirstChildOfClass("Humanoid"),SelectedTargetCharacter:FindFirstChildOfClass("ForceField")
	local UserTorso = (Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character:FindFirstChild("Torso"))
	
	if not UserTorso or FF then return end
	
	local Distance = (Torso.CFrame.p-UserTorso.CFrame.p).magnitude -- Make sure it's legit
	
	if Distance > 15 then return end
	
	if Torso and Humanoid and not SelectedTargetCharacter:FindFirstChild("CellScript") and not IsJailed(Humanoid) then
		local pScript = PrisonScript:Clone()
		Create("ObjectValue"){
			Name = "Target",
			Value = SelectedTargetCharacter,
			Parent = pScript,
		}
		pScript.Parent = Services.ServerScriptService
		pScript.Disabled = false 
		
		if Players:GetPlayerFromCharacter(SelectedTargetCharacter) then
			local DisableScript = DisableBackpack:Clone()
			DisableScript.Parent = SelectedTargetCharacter
			DisableScript.Disabled = false
			Debris:AddItem(DisableScript,10)
		end
	end
end)