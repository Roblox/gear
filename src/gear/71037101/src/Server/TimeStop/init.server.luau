--TIME STOP!!
--Inspired from some anime :)

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
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

local Root,Creator = script:FindFirstChild("CenterPart"),script:FindFirstChild("Creator")

local Properties = {
	Range = 80,
	Duration = 5, --Measured in seconds
	TimeDifference = 0
}
if not Root or not Root.Value or not Creator or not Creator.Value then script:Destroy() end

local Sounds = {
	TimeStop = script:FindFirstChild("TimeStop"),
	TimeWave = script:FindFirstChild("TimeWave")
}

local timeWave = Create("Part"){
	Size = Vector3.new(0, 0, 0),
	CastShadow = false,
	Transparency = 1,
	CanCollide = false,
	Locked = true,
	Anchored = true
}

local Wave = script:FindFirstChild("Wave")

if Wave then
	Wave.Face = Enum.NormalId.Top
	Wave.Parent = timeWave
	local Clone = Wave:Clone()
	Clone.Face = Enum.NormalId.Bottom
	Clone.Parent = Wave
end

timeWave.Parent = workspace

if Sounds.TimeWave then
	Sounds.TimeWave.Parent = timeWave
	Sounds.TimeWave:Play()
end

if Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.UserId == 30349282 then
	Properties.Range = 2048
end

local LastPosition = Root.Value.CFrame 
for i=0,60*1.5,1 do
	if Root.Value then
		timeWave.Size = Vector3.new(1,0,1) *((i/(60*1.5))*Properties.Range)
		timeWave.CFrame = Root.Value.CFrame
		LastPosition = Root.Value.CFrame
		Services.RunService.Heartbeat:Wait()
	end
end

if Wave then
	timeWave:Destroy()
end

local TimeBubble = Create("Part"){
	Locked = true,
	Anchored = true,
	CastShadow = false,
	CanCollide = false,
	Shape = Enum.PartType.Ball,
	Color = Color3.fromRGB(170, 85, 0),
	Size = Vector3.new(1,1,1) * 0,
	Transparency = 0,
	Material = Enum.Material.Neon,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	CFrame = LastPosition,
	Parent = workspace,
}

local FFBubble = TimeBubble:Clone()
FFBubble.Material = Enum.Material.ForceField
FFBubble.Transparency = 0.1
FFBubble.Color = Color3.new(1,1,0)
FFBubble.Size = Vector3.new(1,1,1)*0
FFBubble.Parent = TimeBubble

local shrinkbubble = FFBubble:Clone()
shrinkbubble.Color = Color3.new(1,1,1)
shrinkbubble.Size = Vector3.new(1,1,1)*0
shrinkbubble.Parent = FFBubble

if Sounds.TimeStop then
	Sounds.TimeStop.EmitterSize = Properties.Range
	Sounds.TimeStop.Parent = TimeBubble
	Sounds.TimeStop:Play()
end

--FREEZE EVERYTHING UNANCHORED!!

local Pos,Neg = LastPosition.p + Vector3.new(1,1,1) * Properties.Range*.5,LastPosition.p - Vector3.new(1,1,1) * Properties.Range*.5

local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region3.new(Neg,Pos),{Creator.Value.Character},math.huge)

local AnchoredParts = {}


local function LockPlayer(hit)
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health<=0 or FF or IsTeamMate(Services.Players:GetPlayerFromCharacter(Hum.Parent),Creator.Value) then return end
	
	local function DimensionBroken(Character) -- Quick check to see if they're not frozen
		for _,v in pairs(Services.ServerScriptService:GetChildren()) do
			if v:IsA("Script") and v.Name == "BreakDimension" and v:FindFirstChild("Target") and v:FindFirstChild("Target").Value == Hum.Parent then
				return true
			end
		end
		return false
	end
	
	if DimensionBroken() then return end
	
	local DimensionScript = script:WaitForChild("BreakDimension"):Clone()
	
	Create("NumberValue"){
		Name = "Duration",
		Value = (Properties.Duration-Properties.TimeDifference),
		Parent = DimensionScript,
	}
	Create("ObjectValue"){
		Name = "Target",
		Value = Hum.Parent,
		Parent = DimensionScript
	}
	Create("ObjectValue"){
		Name = "Creator",
		Value = Creator.Value,
		Parent = DimensionScript
	}
	DimensionScript.Parent = Services.ServerScriptService
	DimensionScript.Disabled = false
	local parts = Hum.Parent:GetDescendants()
	for i=1,#parts do
		if parts[i] and parts[i]:IsA("BasePart") then
			AnchoredParts[#AnchoredParts+1] = parts[i]
			parts[i].Anchored = true
		end
	end
end

local Touch = TimeBubble.Touched:Connect(function(hit)
	if not hit or not hit.Parent or hit.Anchored or (Creator.Value.Character and Creator.Value.Character:IsAncestorOf(hit)) then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if FF then return end
	if Hum and IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	if (hit.Parent:IsA("Accoutrement") or hit.Parent:IsA("Tool")) and hit.Parent.Parent:FindFirstChildOfClass("Humanoid") then return end
	AnchoredParts[#AnchoredParts+1] = hit
	hit.Anchored = true
	LockPlayer(hit)
end)

for i=1,#Parts,1 do
	if Parts[i] and Parts[i].Parent and not Parts[i].Anchored and (Parts[i].Position-TimeBubble.Position).Magnitude <= Properties.Range then
		local Hum,FF = Parts[i].Parent:FindFirstChildOfClass("Humanoid"),Parts[i].Parent:FindFirstChildOfClass("ForceField")
		if not FF then
			if Parts[i] and Parts[i].Parent and Parts[i].Parent.Parent and not Parts[i].Parent.Parent:FindFirstChildOfClass("Humanoid") then
				AnchoredParts[#AnchoredParts+1] = Parts[i]
				Parts[i].Anchored = true
			end
				
			if Hum and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then

				LockPlayer(Parts[i])
			end
		end
	end
end

local shrinktween
pcall(function()
	Services.TweenService:Create(TimeBubble,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Transparency = .7,Size = Vector3.new(1,1,1)*Properties.Range}):Play()
	Services.TweenService:Create(FFBubble,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Size = Vector3.new(1,1,1)*Properties.Range}):Play()
	shrinktween = Services.TweenService:Create(shrinkbubble,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Size = Vector3.new(1,1,1)*Properties.Range}):Play()
	wait(.2)
	Services.TweenService:Create(shrinkbubble,TweenInfo.new(2.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In,0,false,0),{Size = Vector3.new(1,1,1)*0}):Play()
	-- = Services.TweenService:Create(shrinkbubble,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Size = Vector3.new(1,1,1)*Properties.Range}):Play().Completed:Wait()
end)

coroutine.wrap(function()
	Properties.TimeDifference = Properties.TimeDifference + (1/60)--Helps scale the time stunned
	Services.RunService.Heartbeat:Wait()
end)()

wait(Properties.Duration+2.5)

if Touch then Touch:Disconnect() end

for i=1,#AnchoredParts,1 do
	if AnchoredParts[i] then
		AnchoredParts[i].Anchored = false
	end
end

pcall(function()
	Services.TweenService:Create(FFBubble,TweenInfo.new(.5,Enum.EasingStyle.Back,Enum.EasingDirection.In,0,false,0),{Transparency = 1,Size = Vector3.new(1,1,1)*0}):Play()
	Services.TweenService:Create(TimeBubble,TweenInfo.new(.5,Enum.EasingStyle.Back,Enum.EasingDirection.In,0,false,0),{Transparency = 1,Size = Vector3.new(1,1,1)*0}):Play()
end)
wait(1)
if TimeBubble then
	TimeBubble:Destroy()
end


--print("Finished executing the move")
script:Destroy()