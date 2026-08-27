--Scripted by TakeoHonorable

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

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}



function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Remote = Tool:WaitForChild("Remote")

local Animations = Tool:WaitForChild("Animations")

local Sounds = {
	Drink = Handle:WaitForChild("DrinkSound"),
	Break = Handle:WaitForChild("Break")
}

local Properties = {
	Cooldown = 10
}

local Player,Character,Humanoid,Root


function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	Animations = Tool:WaitForChild("Animations")
	Animations = Animations:WaitForChild(Humanoid.RigType.Name)
	Animations = {
		Drink = Humanoid:LoadAnimation(Animations:WaitForChild("Drink")),
		Throwdown = Humanoid:LoadAnimation(Animations:WaitForChild("Throwdown"))
	}
end

function Unequipped()
	for _,v in pairs(Animations) do
		v:Stop()
	end
end

function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	Animations.Drink:Play()
	delay(.5,function()
		Sounds.Drink:Play()	
	end)
	wait(1)
	local SpeedScript = script:WaitForChild("SpeedScript"):Clone()
	SpeedScript.Parent = Character
	SpeedScript.Disabled = false
	repeat
		Services.RunService.Heartbeat:Wait()
	until not SpeedScript or not SpeedScript:IsDescendantOf(Character)
	Tool.Enabled = true
end





Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

Remote.OnServerEvent:Connect(function(player,Key)
	if player ~= Player or not Humanoid or Humanoid.Health == 0 or not Tool.Enabled then return end
	if Key and Key == Enum.KeyCode.Q then
		Tool.Enabled = false
		Animations.Throwdown:Play()
		wait(.3)
		Handle.Transparency = 1
		Sounds.Break:Play()
		local SmogPart = Create("Part"){
			Anchored = true,
			CanCollide = false,
			Transparency = 1,
			Locked = true,
			Size = Vector3.new(1,1,1)*0,
			Name = "SmogPart",
			CFrame = CFrame.new(Handle.CFrame.p),
			Parent = workspace
		}
		
		local SleepyTime = script:WaitForChild("SleepyTime"):Clone()
		SleepyTime.Parent = SmogPart
		SleepyTime:WaitForChild("Creator").Value = Player
		SleepyTime.Disabled = false
		wait(Properties.Cooldown)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end)