
local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
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

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
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

local Creator,Position = script:WaitForChild("Creator"),script:WaitForChild("Position").Value

local IceFloor = Create("Part"){
	Name = "Ice Floor",
	Size = Vector3.new(0,0,0),
	Material = Enum.Material.Neon,
	Transparency = 0.95,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Color = Color3.fromRGB(0,170,255),
	Locked = true,
	CanCollide = false,
	Anchored = true,
	Shape = Enum.PartType.Block,
	CFrame = CFrame.new(Position),
	Parent = workspace
}

local IcePlatform = Create("Part"){
	Name = "Ice Platform",
	Size = Vector3.new(0,0,0),
	Material = Enum.Material.Glass,
	Transparency = .3,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Color = Color3.fromRGB(0,170,255),
	Locked = true,
	CanCollide = true,
	Anchored = true,
	Shape = Enum.PartType.Cylinder,
	CFrame = CFrame.new(Position),
	Parent = workspace
}

local Puff = script:WaitForChild("Puff")
Puff.Parent = IceFloor
Puff.Enabled = true

local Snowflakes = script:WaitForChild("Snowflakes")
Snowflakes.Parent = IceFloor
Snowflakes.Enabled = true

local Frost = script:WaitForChild("FreezeSound")
Frost.Parent = IceFloor
Frost:Play()

local Speed = 3 -- time approximated in seconds to complete
local Range = 75 --How far the range of the ice floor will go


local Touch,TouchEnd

local RecHumanoids = {} --Records the Humanoid and their time in the frost
--{Humanoid = nil,TimeInFrost = 0}
local function GetHumanoidTime(Table,Hum)
	local Found
	for _,HumTable in pairs(Table) do
		if HumTable["Humanoid"] and HumTable["TimeInFrost"] and HumTable["Humanoid"] == Hum then
			Found = HumTable
		end
	end
	
	if Found then
		Found["TimeInFrost"] = Found["TimeInFrost"] + (1/60)
		return Found["TimeInFrost"]
	else
		Table[#Table+1] = {Humanoid = Hum,TimeInFrost = 0}
		return 0
	end
end



coroutine.wrap(function()
	repeat
		local Hums = {}
		local Pos,Neg = IceFloor.CFrame.p + Vector3.new(IceFloor.Size.Z,IceFloor.Size.X,IceFloor.Size.Z)*.5 + Vector3.new(0,IceFloor.Size.X*.5,0), IceFloor.CFrame.p - Vector3.new(IceFloor.Size.Z,IceFloor.Size.X,IceFloor.Size.Z)*.5 - Vector3.new(0,IceFloor.Size.X*.5,0)
		local Region = Region3.new(Neg,Pos)
		local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Creator.Value.Character},math.huge)
		
		for _,part in pairs(Parts) do
			
			if part and part.Parent then
				local Hum,FF = part.Parent:FindFirstChildOfClass("Humanoid"),part.Parent:FindFirstChildOfClass("ForceField")
				if Hum and not IsInTable(Hums,Hum) and Hum.Health ~= 0 and not FF and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
					Hums[#Hums+1] = Hum
					Hum:TakeDamage((20/60))
					Hum.WalkSpeed = math.clamp(Hum.WalkSpeed - (16/(60*2)),0,16) -- Progressive Slowdown
					if Hum.Health <= 0 or GetHumanoidTime(RecHumanoids,Hum) >= 2 then --Freeze them when they have no walkspeed or health left
						local function Frozen(Character) -- Quick check to see if they're not frozen
							for _,v in pairs(Services.ServerScriptService:GetChildren()) do
								if v:IsA("Script") and v.Name == "Freeze" and v:FindFirstChild("Target") and v:FindFirstChild("Target").Value == Hum.Parent then
									return true
								end
							end
							return false
						end
						if not Frozen(Hum.Parent) then
							local FreezeScript = script:WaitForChild("Freeze"):Clone()
							FreezeScript:WaitForChild("Creator").Value = Creator.Value
							FreezeScript:WaitForChild("Target").Value = Hum.Parent
							FreezeScript.Parent = Services.ServerScriptService
							FreezeScript.Disabled = false
							Hum.Parent:BreakJoints()
						end
					end
					
					UntagHumanoid(Hum)
					TagHumanoid(Hum,Creator.Value)
				end
			end				
		end
		Services.RunService.Heartbeat:Wait()
	until not Puff.Enabled
end)()


for i=1,60*(Speed),1 do
	IcePlatform.Size = Vector3.new(2,(i/(60*Speed))*Range,(i/(60*Speed))*Range)
	IcePlatform.CFrame = CFrame.new(Position-Vector3.new(0,IceFloor.Size.X,0))*CFrame.Angles(0,0,math.rad(90))
	
	IceFloor.Size = Vector3.new(5,(i/(60*Speed))*Range,(i/(60*Speed))*Range)
	IceFloor.CFrame = CFrame.new(Position+Vector3.new(0,IceFloor.Size.X/2,0))*CFrame.Angles(0,0,math.rad(90))
	Frost.EmitterSize = (i/(60*Speed))*Range
	Services.RunService.Heartbeat:Wait()
end

wait(8)

IceFloor.Transparency = 1
Puff.Enabled = false
Snowflakes.Enabled = false

wait(Puff.Lifetime.Max)
Frost:Stop()

while IcePlatform.Size.Z > 1 do
	IcePlatform.Size = IcePlatform.Size - Vector3.new(0,.5,.5)
	IcePlatform.CFrame = CFrame.new(Position-Vector3.new(0,IceFloor.Size.X,0))*CFrame.Angles(0,0,math.rad(90))
	Services.RunService.Heartbeat:Wait()
end

IcePlatform:Destroy()
IceFloor:Destroy()

script:Destroy()