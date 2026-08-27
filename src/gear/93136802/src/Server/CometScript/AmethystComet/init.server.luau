local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting"))
}

local CometRef = script:WaitForChild("CometRef",10).Value

local Creator = script:WaitForChild("Creator",5)

local AmethystLocal = script:WaitForChild("AmethystLocal",5)

local OriginalTime = Services.Lighting.ClockTime
local TimeTween = Services.TweenService:Create(Services.Lighting,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{ClockTime = 20})
TimeTween:Play()

local LocalScripts = {}

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local function PlantLocalForce(character)
	local Found = character:FindFirstChild(AmethystLocal.Name)
	if not character or Found or not character:FindFirstChild("HumanoidRootPart") then return end
	if (CometRef.CFrame.p-character:FindFirstChild("HumanoidRootPart").CFrame.p).Magnitude > 700 then if Found and IsInTable(LocalScripts,Found) then Found:Destroy() end return end
	local Clone = AmethystLocal:Clone()
	LocalScripts[#LocalScripts+1] = Clone
	Clone.Parent = character
	Clone.Disabled = false
end



spawn(function()
	while CometRef:IsDescendantOf(workspace) do
		for _,players in pairs(Services.Players:GetPlayers()) do
			if players and players.Character and Creator.Value ~= players then
				PlantLocalForce(players.Character)
			end
		end	
		wait(1/2)
	end	
end)

Services.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if player ~= Creator.Value then
			PlantLocalForce(character)
		end
	end)
end)

while CometRef and CometRef.Parent and CometRef:IsDescendantOf(workspace) do
	Services.RunService.Heartbeat:Wait()
end

for _,scripts in pairs(LocalScripts) do --Cleanup
	if scripts then
		scripts:Destroy()
	end	
end

TimeTween = Services.TweenService:Create(Services.Lighting,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{ClockTime = OriginalTime})
TimeTween:Play()


script:Destroy()

