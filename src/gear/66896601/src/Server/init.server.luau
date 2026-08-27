--Rescripted/Revamped by TakeoHonorable
--True form of neverending frost

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
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Tip = Handle:WaitForChild("Tip")
Tip:WaitForChild("Snowflakes").Enabled = true

local MouseLoc,Remote = Tool:WaitForChild("MouseLoc"),Tool:WaitForChild("Remote")

local Player,Character,Humanoid,Torso

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Grips = {
	Out = Tool:WaitForChild("Out").Value,
	In = Tool:WaitForChild("In").Value
}
Tool.Grip = Grips.In

local Sounds = {
	FrostLoop = Handle:WaitForChild("FrostLoop"),
	Shoot = Handle:WaitForChild("Shoot")
}

local flake = Create("Part"){
	Shape = Enum.PartType.Block, 
	Size = Vector3.new(1.7, 0.4, 1.7),
	Locked = true,
	Name = "Snowflake",
	CanCollide = false, 
	Transparency = 0.0,
}

local flakeMesh = Create("SpecialMesh") {
	MeshId = "http://www.roblox.com/asset/?id=66877034",
	TextureId = "http://www.roblox.com/asset/?id=66876289",
	Parent = flake,
	Scale = Vector3.new(2, 2, 2),
}

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Center = Character:WaitForChild("HumanoidRootPart")
	Sounds.FrostLoop:Play()
end

function Unequipped()
	Sounds.FrostLoop:Stop()
end

function Activated()
	if not Player or not Humanoid or Humanoid.Health <= 0 or not Tool.Enabled then return end
	Tool.Enabled = false
	local Sucess,Pos = pcall(function() return MouseLoc:InvokeClient(Player)end)
	Pos = (Sucess and Pos) or Vector3.new(0,0,0)
	
	coroutine.wrap(function()
		Tool.Grip = Grips.Out
		wait(1)
		Tool.Grip = Grips.In
	end)()
	
	local SpawnPos = Tip.WorldPosition + (Pos - Tip.WorldPosition).Unit * 4
	
	local FlakeProj = flake:Clone()
	FlakeProj.CFrame = CFrame.new(SpawnPos)*CFrame.Angles(0,0,0)
	
	local Velo = Create("BodyVelocity"){
		MaxForce = Vector3.new(1,1,1)*math.huge,
		Velocity = (Pos - SpawnPos).Unit * 100,
		Parent = FlakeProj
	}
	
	local SnowflakeScript = script:WaitForChild("SnowflakeScript"):Clone()
	SnowflakeScript:WaitForChild("Creator").Value = Player
	SnowflakeScript.Parent = FlakeProj
	SnowflakeScript.Disabled = false
	
	Sounds.Shoot:Play()
	FlakeProj.Parent = workspace
	FlakeProj:SetNetworkOwner(nil)
	wait(3)
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

local Special = true
Remote.OnServerEvent:Connect(function(Client,Key)
	if not Tool.Enabled or Client ~= Player or not Key or not Humanoid or Humanoid.Health <= 0 or not Tool:IsDescendantOf(Character) then return end
	if Key == Enum.KeyCode.Q and Special then
		Tool.Enabled = false
		coroutine.wrap(function()
			Special = false
			Tip:WaitForChild("Snowflakes").Enabled = false
			wait(20)
			Tip:WaitForChild("Snowflakes").Enabled = true
			Special = true
		end)()
		local ThudAnim = Humanoid:LoadAnimation(Tool:WaitForChild("Thud"..Humanoid.RigType.Name))
		ThudAnim:Play()
		Tool.Grip = Grips.In * CFrame.new(0,2,0) -- Makes the character hold the staff at the top
		wait(0.95)
		if Tool:IsDescendantOf(Character) then
			Sounds.Shoot:Play()
		end
		local IcingScript = script:WaitForChild("Icing"):Clone()
		IcingScript:WaitForChild("Position").Value = Center.CFrame.p - Vector3.new(0,Center.Size.Y*1.5,0)
		IcingScript:WaitForChild("Creator").Value = Player
		IcingScript.Parent = Services.ServerScriptService
		IcingScript.Disabled = false
		Tool.Grip = Grips.In
		Tool.Enabled = true
	end
end)