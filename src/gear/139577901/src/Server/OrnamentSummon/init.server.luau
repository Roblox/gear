local Character = script.Parent

local Root = Character:WaitForChild("HumanoidRootPart",10)

local OrnamentControl = script:WaitForChild("OrnamentControl",10)

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Tool = script:WaitForChild("Tool",10).Value

if not Humanoid or Humanoid.Health <= 0 or not Root then script:Destroy() end


local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting"))
}


local Properties = {
	OrnamentDuration = 20,
	OrnamentScaleRadius = 18.36,
	BaseUrl = "rbxassetid://"
}


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


local function weldBetween(a, b)
    local weld = Instance.new("Weld")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse() * a.CFrame
    weld.Parent = a
    return weld;
end

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

local OrnamentBall
local HoHoHo = script:WaitForChild("HoHoHo",10)


function Cleanup()
	Humanoid.PlatformStand = false
	OrnamentBall:Destroy()
	OrnamentControl:Destroy()
	script:Destroy()
end

OrnamentBall = Create("Part"){
		Anchored = false,
		CanCollide = true,
		Locked = true,
		Shape = Enum.PartType.Ball,
		Color = Color3.fromRGB(255,0,0),
		Material = Enum.Material.SmoothPlastic,
		Size = Vector3.new(1,1,1) * Properties.OrnamentScaleRadius,
		CFrame = Root.CFrame,
	}
	HoHoHo.Parent = OrnamentBall
	local OrnamentMesh = Create("SpecialMesh"){
		Scale = (Vector3.new(1,1,1)*2.7) * Properties.OrnamentScaleRadius,
		Offset = Vector3.new(0,0,0),
		MeshType = Enum.MeshType.FileMesh,
		MeshId = Properties.BaseUrl .. "99795003",
		TextureId = Properties.BaseUrl .. "99795207",
		Parent = OrnamentBall,
		VertexColor = Vector3.new(1,1,1),
	}
	
	local OrnaWeld = Create("WeldConstraint"){
		Part0 = Root,
		Part1 = OrnamentBall,
		Parent = OrnamentBall
	}
	
	OrnamentControl = script:WaitForChild("OrnamentControl"):Clone()

	OrnamentControl:WaitForChild("Orb",10).Value = OrnamentBall
	OrnamentControl.Parent = Character
	OrnamentControl.Disabled = false
	
	OrnamentBall.CFrame = Root.CFrame
	OrnamentBall.Parent = workspace


local OrnamentCleanup = script:WaitForChild("OrnamentCleanup",5)
OrnamentCleanup.Parent = OrnamentBall
OrnamentCleanup.Disabled = false

OrnamentControl.Disabled = false -- Let's go!!!

Tool.Unequipped:Connect(function()
	Cleanup()
end)	
	
Humanoid.Died:Connect(function()
	Cleanup()
end)

spawn(function()
	repeat
		Services.RunService.Heartbeat:Wait()
	until not OrnamentBall or not OrnamentBall:IsDescendantOf(workspace)
	Cleanup()
end)

local OrnamentTouch = OrnamentBall.Touched:Connect(function(hit)
		
		if not hit or not hit.Parent or hit.Anchored then return end
		
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")

		if not Hum or Hum == Humanoid or Hum.Health <= 0 or IsTeamMate(Services.Players:GetPlayerFromCharacter(Humanoid.Parent),Services.Players:GetPlayerFromCharacter(Hum.Parent)) or ForceField or Hum:IsDescendantOf(OrnamentBall) then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Services.Players:GetPlayerFromCharacter(Humanoid.Parent))
		Hum.Parent:BreakJoints()--Temporary
		HoHoHo:Play()
		
		local FakeChar = Create("Model"){
			Parent = OrnamentBall
		}
		Services.Debris:AddItem(FakeChar,4)
		for _,v in pairs(Hum.Parent:GetChildren()) do
			local Clone
			if not v:IsA("Humanoid") then
				Clone = v:Clone();Clone.Parent = FakeChar
			end
			
			if Clone and Clone:IsA("BasePart") then
				Clone.CanCollide = false
				Clone.Anchored = false
				weldBetween(Clone,OrnamentBall)
			end
			
			if v:IsA("BasePart") or v:IsA("Accessory") then
				v:Destroy()
			end
		end
	end)
	
	Humanoid.PlatformStand = true
	
	wait(Properties.OrnamentDuration)
	Cleanup()
	
	
	