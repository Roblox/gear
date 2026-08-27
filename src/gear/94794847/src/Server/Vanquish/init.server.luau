--The wave that made the vampires and bats no more!
--Stuns players, but eradicates all things bats and vampires!

local Creator, SpawnPos = script:FindFirstChild("Creator"), script:FindFirstChild("Position")

if not Creator or not Creator.Value or not SpawnPos then script:Destroy() end
--print("Vanquishing")

SpawnPos = SpawnPos.Value

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
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

local Vector,Cframe,ceil,huge,max,lower,find,Region,unpac,Seed = Vector3,CFrame,math.ceil,math.huge,math.max,string.lower,string.find,Region3,unpack,Random.new() -- pre-declaring these variables should help with latency

local WavePart = Create("Part"){
	Name = "Effect",
	Locked = true,
	CanCollide = false,
	Anchored = true,
	CastShadow = false,
	CFrame = Cframe.new(SpawnPos),
	Size = Vector.new(1,1,1),
	Material = Enum.Material.ForceField,
	Color = Color3.fromRGB(117,0,0),
	Parent = workspace
}
local WaveMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.Sphere,
	Scale = Vector.new(0,0,0),
	Parent = WavePart
}

local IgnoreList = {}
local IgnoreHumanoids = {}
local Anims = {}

local TargetNames = {"undying", "vampire", "bat"} 

local function VanquishStun(Hum) -- Quick check to see if they're not stunned
	local Children = Services.ServerScriptService:GetChildren()
	for i=1, #Children do
		if Children[i]:IsA("Script") and Children[i].Name == "VanquishStun" and Children[i]:FindFirstChild("Target") and Children[i]:FindFirstChild("Target").Value == Hum.Parent then
			return true
		end
	end
	return false
end

local function FoundTarget(Character)
	
	for i=1,#TargetNames do --check to see if the target is potentially a bat or a vampire
		if not Services.Players:GetPlayerFromCharacter(Character) and find(lower(Character.Name), lower(TargetNames[i])) then
			return true
		end
		local Descendants = Character:GetDescendants()
		for v = 1, #Descendants do
			if (Descendants[v]:IsA("BasePart") or Descendants[v]:IsA("Model") or Descendants[v]:IsA("Tool")) and find(lower(Descendants[v].Name), lower(TargetNames[i])) then
				--Target sighted!
				return true
			end
		end
	end
	return false
end

local function StunArea(Range)
	if not WavePart then return end
	local Position = WavePart.Position
	local Neg, Pos = Position - Vector.new(1,1,1) * (Range*.5), Position + Vector.new(1,1,1) * (Range*.5)
	local Reg = Region.new(Neg,Pos)
	local Parts = workspace:FindPartsInRegion3WithIgnoreList(Reg,{(Creator and Creator.Value and Creator.Value.Character) or nil,unpac(IgnoreList)},huge) 

	for i=1,#Parts,1 do
		if Parts[i] and Parts[i].Parent and (Parts[i].Position-Position).Magnitude <= Range then
			IgnoreList[#IgnoreList+1] = Parts[i] -- Ignore it so lag is mitigated
			
			local Hum,FF = Parts[i].Parent:FindFirstChildOfClass("Humanoid"),Parts[i].Parent:FindFirstChildOfClass("ForceField")
			if Hum and Hum.Health ~= 0 and not FF and not IsInTable(IgnoreHumanoids,Hum) and not IsTeamMate(Creator.Value, Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
				IgnoreHumanoids[#IgnoreHumanoids+1] = Hum
				if FoundTarget(Hum.Parent) then
					
					warn("Target Sighted!")
					
					UntagHumanoid(Hum)
					TagHumanoid(Hum,Creator.Value)
					Hum.Parent:BreakJoints() --Make sure it KOs
					
					local EffectBox = Create("Part"){
						Locked = true,
						Anchored = true,
						CanCollide = false,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
						Size = Vector3.new(0,0,0),
						CFrame = Parts[i].CFrame,
						Transparency = 1,
						Parent = workspace
					}
					
					local PoofSmoke = script:WaitForChild("PoofSmoke"):Clone()
					PoofSmoke.Parent = EffectBox
					PoofSmoke:Emit(100)
					
					local PoofSound = script:WaitForChild("PoofSound"):Clone()
					PoofSound.Parent = EffectBox
					PoofSound:Play()
					
					Services.Debris:AddItem(EffectBox,max(PoofSmoke.Lifetime.Max,PoofSound.TimeLength)+.5)
					
					for _,parts in pairs(Hum.Parent:GetDescendants()) do
						if parts:IsA("BasePart") then
							parts:Destroy()
						end
					end
					
					else
						if not VanquishStun(Hum) then
							--local HeadShake = Hum:LoadAnimation(script:WaitForChild("Animations"):WaitForChild(Hum.RigType.Name):WaitForChild("HeadShake"))
							--HeadShake:Play(nil,nil,Seed:NextNumber(1,3))
							local VanquishScript = script:WaitForChild("VanquishStun"):Clone()
							Create("ObjectValue"){
								Name = "Target",
								Value = Hum.Parent,
								Parent = VanquishScript
							}
							VanquishScript.Parent = Services.ServerScriptService
							VanquishScript.Disabled = false
						end
				end
				--print("Affecting "..Hum.Parent.Name)
			end	
		end
	end
end

for i=1, ceil(60*(3)),1 do
	if WaveMesh and WavePart then
		WaveMesh.Scale = Vector.new(1,1,1)* (300 * (i/ceil(60*(3))))
		WavePart.Transparency = (i/ceil(60*(3)))
		coroutine.wrap(function()
			StunArea((300 * (i/ceil(60*(3)))))
		end)()
	end

	Services.RunService.Stepped:Wait()
end

if WavePart then
	WavePart:Destroy()
end

for i=1,#Anims do
	if Anims[i] then Anims[i]:Stop() end
end

script:Destroy()