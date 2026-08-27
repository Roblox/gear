--Scripted by TakeoHonorable

local Tool = script.Parent
Tool.Enabled = true

local Seed = Random.new(tick())

local Player,Character,Humanoid,Center

local Properties = {
	CurrentRadius = 20
}

local Components = {
	Handle = Tool:WaitForChild("Handle",10),
	MouseInput = Tool:WaitForChild("MouseInput",10),
	Remote = Tool:WaitForChild("Remote",10)
}

local PointLight = Components.Handle:WaitForChild("PointLight",10)
PointLight.Enabled = true
local Particles = Components.Handle:WaitForChild("Particle",10):WaitForChild("Leaf",10)
Particles.Enabled = true

local Service = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Sounds = {
	Rustle = Components.Handle:WaitForChild("Rustle",10),
	HeavyWind = Components.Handle:WaitForChild("HeavyWind",10),
	LungeSound = Components.Handle:WaitForChild("LungeSound",10),
	SlashSound = Components.Handle:WaitForChild("SlashSound",10),
}

local Animations

local Deletables = {}--Refer to this table for anything deletable

local Leaf3D = Instance.new("Part")
Leaf3D.Size = Vector3.new(1.77, 0.2, 2)*2;
Leaf3D.CanCollide = false
Leaf3D.Anchored = false
Leaf3D.Locked = true

local LeafMesh = Instance.new("SpecialMesh")
LeafMesh.MeshType = Enum.MeshType.FileMesh
LeafMesh.Scale = Vector3.new(1.2, 1.2, 1.2)*2
LeafMesh.MeshId = "rbxassetid://96476430"
LeafMesh.TextureId = "rbxassetid://96476383"
LeafMesh.Parent = Leaf3D

local TouchConnection
local PassiveConnection,Debounce = nil,false

local function GetAllMassParts(obj)
	local TotalMass = 0
	for _,v in pairs(obj:GetDescendants()) do
		if v:IsA("BasePart") then
			TotalMass = TotalMass + v:GetMass()
		end
	end
	return TotalMass
end


function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Service.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
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

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

Tool.Equipped:Connect(function()
	Character = Tool.Parent
	Player = Service.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid then return end
	
	Animations = {
		Spin = Tool:WaitForChild(Humanoid.RigType.Name):WaitForChild("Spin"),
		Slash = Tool:WaitForChild(Humanoid.RigType.Name):WaitForChild("Slash"),
		SlashAnim = Tool:WaitForChild(Humanoid.RigType.Name):WaitForChild("SlashAnim"),
		RightSlash = Tool:WaitForChild(Humanoid.RigType.Name):WaitForChild("RightSlash")
	}
	
	Center = Character:WaitForChild("HumanoidRootPart")
	for i,animations in pairs(Animations) do
		Animations[i]= Humanoid:LoadAnimation(animations)
	end
	
	TouchConnection = Components.Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not Hum  or Humanoid == Hum or IsTeamMate(Player,Service.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		Hum:TakeDamage(9)
	end)
	
	wait(1)
	PassiveConnection = Service.RunService.Heartbeat:Connect(function()
		if not Player or Debounce or not Tool:IsDescendantOf(Character) then return end
		Debounce = true
		for i=1,Seed:NextInteger(5,20),1 do
			local Leaf = Leaf3D:Clone()
			Leaf.CFrame = Center.CFrame + Vector3.new(Seed:NextInteger(-60,60),Seed:NextInteger(40,60),Seed:NextInteger(-60,60))
			local BodyForce = Instance.new("BodyForce")
			BodyForce.Force = Vector3.new(0,(Leaf:GetMass()*workspace.Gravity)*.95,0);BodyForce.Parent = Leaf
			Leaf.RotVelocity = Vector3.new(Seed:NextInteger(0,10),Seed:NextInteger(0,10),Seed:NextInteger(0,10))
			Leaf.Velocity = Leaf.Velocity + Vector3.new(Seed:NextInteger(-20,20),0,Seed:NextInteger(-20,20))
			Leaf.Parent = workspace
			Service.Debris:AddItem(Leaf,60)
			--Leaf:SetNetworkOwner(nil)
			Leaf:SetNetworkOwner(Player)
			Leaf.Touched:Connect(function(hit)
				if not hit or not hit.Parent then return end
				local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
				if Hum and Hum ~= Humanoid and not IsTeamMate(Player,Service.Players:GetPlayerFromCharacter(Hum.Parent)) then
					UntagHumanoid(Hum)
					TagHumanoid(Hum,Player)
					Hum:TakeDamage(35)
				end
				Leaf:Destroy()
			end)
		end
		wait(1)
		Debounce = false
	end) -- Leaf masterpiece
	
end)

Tool.Unequipped:Connect(function()
	if PassiveConnection then PassiveConnection:Disconnect(); PassiveConnection = nil end
	if TouchConnection then TouchConnection:Disconnect();TouchConnection = nil end
	for i,animations in pairs(Animations) do
		animations:Stop()
	end
	--Character,Humanoid,Player = nil,nil,nil
	for _,obj in pairs(Deletables) do
		if obj then obj:Destroy() end
	end
end)

local CurrentTime,LastTime = tick(),tick()
function Activated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	CurrentTime = tick()
	if (CurrentTime-LastTime) <= 0.2 then
		--print("Lunge")
		Sounds.LungeSound:Play()
		local MousePosition = Components.MouseInput:InvokeClient(Player)
		local Direction = CFrame.new(Center.Position, Vector3.new(MousePosition.X, Center.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 100
		Service.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Center
		Center.CFrame = CFrame.new(Center.CFrame.p,Center.CFrame.p+Direction.lookVector)
		wait(1.5)
	else
		local SwingAnims = {Animations.Slash,Animations.SlashAnim,Animations.RightSlash}
		local AttackAnim = SwingAnims[Seed:NextInteger(1,#SwingAnims)]
		spawn(function()
			if AttackAnim ~= Animations.SlashAnim then
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

Tool.Activated:Connect(Activated)

Components.Remote.OnServerEvent:Connect(function(Client,KeyCode) --Registers ability
	if not Tool.Enabled or Client ~= Player then return end --Potential exploiter
	if not KeyCode then return end
	if KeyCode == Enum.KeyCode.Q and Particles.Enabled then
		local Center = Character:WaitForChild("HumanoidRootPart")
		local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
		local Particle = Particles:Clone();Particle.Rate = 200;Particle.Parent = Center;Particle.Speed = NumberRange.new(20)
		for i=1,3,1 do -- Make Tornado-esque particle
			spawn(function()
				local Amplitude = 6
				local AttachmentF = Instance.new("Attachment");AttachmentF.Position = Vector3.new(0,5-(i*2.5),-Properties.CurrentRadius+((i-1)*Amplitude))
				local AttachmentB = Instance.new("Attachment");AttachmentB.Position = Vector3.new(0,5-(i*2.5),Properties.CurrentRadius-((i-1)*Amplitude))
				AttachmentF.Parent = Torso
				AttachmentB.Parent = Torso
				local WindWaveF = Instance.new("Beam")
				WindWaveF.Segments = 50
				WindWaveF.Width0 = 8
				WindWaveF.Width1 = 8
				WindWaveF.LightEmission = 0;WindWaveF.LightInfluence = 1;WindWaveF.Texture = "rbxassetid://1569510006"
				WindWaveF.TextureSpeed = 3;WindWaveF.CurveSize0 = 27-((i-1)*Amplitude+2);WindWaveF.CurveSize1= -27+((i-1)*Amplitude+2);
				local WindWaveB = WindWaveF:Clone();WindWaveB.CurveSize0 = -27+((i-1)*Amplitude+2);WindWaveB.CurveSize1 = 27-((i-1)*Amplitude+2)
				WindWaveF.Width0=2;WindWaveF.Width1 = 2;WindWaveF.Transparency = NumberSequence.new(.8)
				WindWaveB.Width0=2;WindWaveB.Width1 = 2;WindWaveB.Transparency = NumberSequence.new(.8)
				WindWaveF.FaceCamera = true
				WindWaveB.FaceCamera = true
				WindWaveF.Attachment0 = AttachmentF
				WindWaveF.Attachment1 = AttachmentB
				WindWaveB.Attachment0 = AttachmentB
				WindWaveB.Attachment1 = AttachmentF
				WindWaveF.Parent = Torso
				WindWaveB.Parent = Torso
				Deletables[#Deletables+1]=WindWaveF
				Deletables[#Deletables+1]=WindWaveB
				Deletables[#Deletables+1]=AttachmentF
				Deletables[#Deletables+1]=AttachmentB
			end)
		end
		Particle.Enabled = true
		Deletables[#Deletables+1]=Particle
		Tool.Enabled = false
		Particles.Enabled = false
		Animations.Spin:Play(nil,nil,3)
		local Levitate = Instance.new("BodyForce")
		Levitate.Force = Vector3.new(0,(GetAllMassParts(Character)*workspace.Gravity)*.7,0)
		Levitate.Parent = Center
		Deletables[#Deletables+1]=Levitate
		local WindSound = Sounds.HeavyWind:Clone()
		WindSound.Parent = Center
		WindSound:Play()
		local LeafSound = Sounds.Rustle:Clone()
		LeafSound.Parent = Center
		LeafSound:Play()
		Deletables[#Deletables+1]=WindSound
		Deletables[#Deletables+1]=LeafSound
		spawn(function()
			repeat
				local NegativeRegion = (Center.Position - Vector3.new(Properties.CurrentRadius, (Center.Size.Y * 1.5), Properties.CurrentRadius))
				local PositiveRegion = (Center.Position + Vector3.new(Properties.CurrentRadius, Properties.CurrentRadius, Properties.CurrentRadius))
				local Region = Region3.new(NegativeRegion, PositiveRegion)
				local Parts = workspace:FindPartsInRegion3(Region,Character,math.huge)
				local TaggedHumanoids = {}
				for _,hit in pairs(Parts) do
					local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
					if Hum and Hum ~= Humanoid and not IsInTable(TaggedHumanoids,Hum) and not IsTeamMate(Player,Service.Players:GetPlayerFromCharacter(Hum.Parent)) then
						table.insert(TaggedHumanoids,Humanoid)
						UntagHumanoid(Hum)
						TagHumanoid(Hum,Player)
						Hum:TakeDamage(2)
						local Force = Instance.new("BodyVelocity")
						Force.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
						Force.Velocity = (hit.CFrame.p-Center.CFrame.p).unit*Seed:NextNumber(50,100)
						Force.Parent = hit
						Service.Debris:AddItem(Force,.5)
					end
				end
				wait(1/10)
				--Service.RunService.Heartbeat:Wait()
			until not Animations.Spin.IsPlaying
		end)
		wait(10)
		Tool.Enabled = true
		for _,v in pairs(Deletables) do
			if v then 
				v:Destroy()
			end
		end
		Animations.Spin:Stop()
		spawn(function()
			wait(25)
			Particles.Enabled = true
		end)
	end
end)