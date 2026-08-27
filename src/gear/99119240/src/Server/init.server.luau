--Rescripted by TakeoHonorable
--Revamped Periastrons: The Periastron of Crimson Catastrophe

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

local Seed = Random.new(tick())

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle",10)

local PointLight = Handle:WaitForChild("PointLight",10)

local Sparkles = Handle:FindFirstChildOfClass("Sparkles")

local Animations = Tool:WaitForChild("Animations",10)

local Deletables = {} --Send all deletables here

local Sounds = {
	LungeSound = Handle:WaitForChild("LungeSound",10),
	SlashSound = Handle:WaitForChild("SlashSound",10),
	Laser = Handle:WaitForChild("Laser",10),
	Charge = Handle:WaitForChild("Charge",10),
}

local AttackAnims

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Components = {
	PeriSparkle = Handle:WaitForChild("Sparkles",10),
	PeriTrail = Handle:WaitForChild("Trail",10),
	MouseInput = Tool:WaitForChild("MouseInput",10)
}
Components.PeriSparkle.Enabled = true
Components.PeriTrail.Enabled = false
PointLight.Enabled = true

local Player,Character,Humanoid,Root,Torso

local Properties = {
	BaseDamage = 27,
	PillarCount = 5,
	PillarRadius = 10,
	PillarHeight = 200,
	SpecialCooldown = 12
}

local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool

local RedPillar = Create("Part"){
	Shape = Enum.PartType.Cylinder,
	Material = Enum.Material.Neon,
	BrickColor = BrickColor.new("Crimson"),
	Size = Vector3.new(Properties.PillarHeight,Properties.PillarRadius,Properties.PillarRadius),
	CanCollide = false,
	Anchored = true,
	Transparency = 0.3,
	Locked = true,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth
}

local Surfaces = {"Front","Back","Left","Right","Top","Bottom"}

local PillarLighting = Create("SurfaceLight"){
	Color = Color3.fromRGB(151, 0, 0),
	Angle = 180,
	Enabled = true,
	Range = 10,
	Shadows = true
}

for _,surfaces in pairs(Surfaces) do
	local Lighting = PillarLighting:Clone()
	Lighting.Face = Enum.NormalId[surfaces]
	Lighting.Parent = RedPillar
end

local Grips = {
	Normal = Tool:WaitForChild("NormalGrip").Value,
	--BackR6 = Tool:WaitForChild("BackGrip").Value,
	--BackR15 = Tool:WaitForChild("BackGrip").Value+Vector3.new(-.7,0,-.7)
}
Tool.Grip = Grips.Normal

function RayCast(Pos, Dir, Max, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
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

local function GetNearestTorso(MarkedPosition,TorsoPopulationTable)
	local ClosestDistance = math.huge
	local ClosestTorso
	for i=1,#TorsoPopulationTable do
		local distance = (TorsoPopulationTable[i].CFrame.p-MarkedPosition).magnitude
		if TorsoPopulationTable[i] and  distance < ClosestDistance then
			ClosestDistance = distance
			ClosestTorso = TorsoPopulationTable[i]
		end
	end
	--warn("The Closest Person is: "..ClosestTorso.Parent.Name)
	return ClosestTorso
end

local CurrentTime,LastTime = tick(),tick()
function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	CurrentTime = tick()
	if (CurrentTime-LastTime) <= 0.2 then
		--print("Lunge")
		Sounds.LungeSound:Play()
		Components.PeriTrail.Enabled = true
		local sucess,MousePosition = pcall(function() return Components.MouseInput:InvokeClient(Player) end)
		MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
		
		local Direction = CFrame.new(Root.Position, Vector3.new(MousePosition.X, Root.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 100
		Services.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Root
		delay(.5,function()
			Components.PeriTrail.Enabled = false
		end)
		Root.CFrame = CFrame.new(Root.CFrame.p,Root.CFrame.p+Direction.lookVector)
		wait(1.5)
	else
		local SwingAnims = {AttackAnims.Slash,AttackAnims.SlashAnim,AttackAnims.RightSlash}
		local AttackAnim = SwingAnims[Seed:NextInteger(1,#SwingAnims)]
		spawn(function()
			if AttackAnim ~= AttackAnims.SlashAnim then
				Sounds.SlashSound:Play()
				else
				Sounds.SlashSound:Play()
				wait(.5)
				Sounds.SlashSound:Play()
			end	
		end)

		AttackAnim:Play()
	--wait(.4)
	end
	LastTime = CurrentTime
	Tool.Enabled = true
end

local Touch
function Equipped(Mouse)
	Character = Tool.Parent
	Root = Character:FindFirstChild("HumanoidRootPart")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	AttackAnims = {
		Slash = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("Slash",10),
		RightSlash = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("RightSlash",10),
		SlashAnim = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("SlashAnim",10),
	}
	for i,v in pairs(AttackAnims) do
		AttackAnims[i] = Humanoid:LoadAnimation(v)
	end
	Touch = Handle.Touched:Connect(function(hit)
		Damage(hit,Properties.BaseDamage,false)
	end)
end


function Unequipped()
	if Touch then Touch:Disconnect();Touch = nil end
	for i,v in pairs(AttackAnims) do
		v:Stop()
	end
end



local HitHumanoids = {}
function Damage(hit,TotalDamage,PillarsUsing)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <=0 or Hum == Humanoid or ForceField then return end
	
	if IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	
	if IsInTable(HitHumanoids,Hum) then return end
	
	spawn(function()
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		HitHumanoids[#HitHumanoids+1]=Hum
		Hum:TakeDamage(TotalDamage)
		--wait(.5)
		for i,v in pairs(HitHumanoids) do
			if v == Hum then
				HitHumanoids[i] = nil
			end
		end
	end)
	if PillarsUsing then
		if not hit.Anchored and string.find(string.lower(hit.Name),"torso") or string.find(string.lower(hit.Name),"head") or (Hum.Health-TotalDamage)<=0 then
			--print("ThanosEffect")
			spawn(function()
				if not Hum or not Hum.Parent or Hum.Parent:FindFirstChild("Vaporize") then return end
				local VaporizeScript = script:WaitForChild("Vaporize",10):Clone()
				VaporizeScript.Parent = Hum.Parent
				VaporizeScript.Disabled = false
			end)
		end
	end
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)


function SummonPillars()
	if not Humanoid or Humanoid.Health <= 0 or not Root or not Tool.Enabled  or not Components.PeriSparkle.Enabled then return end
	Components.PeriSparkle.Enabled = false
	spawn(function()
		local PillarPlates = {}
		local Pillars = {}
		local PillarModelCenter = Create("Part"){
			CFrame = CFrame.new(Root.CFrame.p-Vector3.new(0,3,0)),
			Anchored = true,
			CanCollide = false,
			Transparency = 1,
			Size = Vector3.new(1,1,1)*0,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Locked = true
		}
		
		local PillarsModel = Create("Model"){
			PrimaryPart = PillarModelCenter,
			Name = Character.Name.."'s Pillar Scatter"
		}
		

		
		PillarModelCenter.Parent = PillarsModel
		PillarsModel.Parent = workspace
		delay(20,function()
			PillarsModel:Destroy()
		end)
		Services.Debris:AddItem(PillarsModel,20)
		local SpawnPos = PillarModelCenter.CFrame.p
		for i=1,Properties.PillarCount,1 do -- Create the Pillar plates
			local PillarClone = RedPillar:Clone()
			table.insert(PillarPlates,PillarClone)
			PillarClone.Size = Vector3.new(1,Properties.PillarRadius*1.2,Properties.PillarRadius*1.2)
			PillarClone.CFrame = (CFrame.new(SpawnPos) * CFrame.Angles(0,i*math.rad(360/Properties.PillarCount),math.rad(90))) * CFrame.new(0,12,0)
			PillarClone.Transparency = 1
			PillarClone.Parent = PillarsModel
		end
		spawn(function()
			local ChargeSound = Sounds.Charge:Clone()
			ChargeSound.Parent = PillarModelCenter
			ChargeSound:Play();ChargeSound.Ended:Wait()
			--print("Pillars of Doom!")
			for i, plate in pairs(PillarPlates) do
				local Pillar = plate:Clone()
				
				table.insert(Pillars,Pillar)
				Pillar.Size = Vector3.new(1,Properties.PillarRadius,Properties.PillarRadius)
				Pillar.CFrame = plate.CFrame
				
				local Force = Create("BodyVelocity"){
					--Force = Vector3.new(0,Pillar:GetMass()*workspace.Gravity,0),
					MaxForce = Vector3.new(1,1,1)*math.huge,
					Parent = Pillar
				}
				Pillar.Parent = PillarsModel
				--table.remove(PillarPlates,i)
				plate:Destroy()
				local LaserSound = Sounds.Laser:Clone()
				LaserSound.Parent = Pillar
				LaserSound:Play()
			end
			
			for i=0,200,200/30 do
				for _,pillars in pairs(Pillars) do
					--pillars:Resize(Enum.NormalId.Right,200/60)
					pillars.Size = Vector3.new(i,Properties.PillarRadius,Properties.PillarRadius)
					pillars.CFrame = CFrame.new(pillars.CFrame.p.x,SpawnPos.y+(pillars.Size.x/3),pillars.CFrame.p.z) * (pillars.CFrame-pillars.CFrame.p)
				end
				Services.RunService.Heartbeat:Wait()
			end
			for _,pillars in pairs(Pillars) do
				pillars.Anchored = false
				pillars:SetNetworkOwner(nil)
				--pillars:FindFirstChildOfClass("BodyForce").Force = Vector3.new(0,pillars:GetMass()*workspace.Gravity,0)
				if pillars:FindFirstChildOfClass("BodyVelocity") then
					pillars:FindFirstChildOfClass("BodyVelocity").Velocity = (Vector3.new(pillars.CFrame.p.x,PillarModelCenter.CFrame.p.y,pillars.CFrame.p.z)-PillarModelCenter.CFrame.p).unit*100
				end
				
				--pillars.Velocity = (Vector3.new(pillars.CFrame.p.x,PillarModelCenter.CFrame.p.y,pillars.CFrame.p.z)-PillarModelCenter.CFrame.p).unit*30
				pillars.Touched:Connect(function(hit)
					if hit and hit.Parent and hit:IsA("BasePart") and not hit.Anchored and not hit:FindFirstAncestorWhichIsA("Accessory") and not hit:FindFirstAncestorWhichIsA("Tool") and not hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent ~= PillarsModel and not hit:FindFirstChild("VaporizePart") then
						if (pillars.Size.X*pillars.Size.Y*pillars.Size.Z) > (hit.Size.X*hit.Size.Y*hit.Size.Z) then
							local VaporizePart = script:WaitForChild("VaporizePart"):Clone()
							VaporizePart.Parent = hit
							VaporizePart.Disabled = false
						end
					end
					Damage(hit,70,true)

				end)
			end
			spawn(function()
				wait(6)
				for i=.3,1,.05 do
					for _,plates in pairs(Pillars) do
						plates.Transparency = i
					end
					Services.RunService.Heartbeat:Wait()
				end
				PillarsModel:Destroy()
			end)
			while PillarsModel and PillarsModel.Parent and PillarsModel.PrimaryPart do
				PillarsModel:SetPrimaryPartCFrame(PillarsModel.PrimaryPart.CFrame*CFrame.Angles(0,math.rad(5),0))
				Services.RunService.Heartbeat:Wait()
			end
			wait(Properties.SpecialCooldown)
			Components.PeriSparkle.Enabled = true
		end)
		
		
		for i=1,0.3,-.05 do
			for _,plates in pairs(PillarPlates) do
				plates.Transparency = i
			end
			Services.RunService.Heartbeat:Wait()
		end
		
		
		
	end)

	
end


Remote.OnServerEvent:Connect(function(Client,Key)
	if not Player or not Client or Client ~= Player or not Key then return end
	if Key == Enum.KeyCode.Q then
		SummonPillars()
	end
end)