--Rescripted by Luckymaxer
--Fixed by TakeoHonorable

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

Tool = script.Parent
Tool.Enabled = true
Handle = Tool:WaitForChild("Handle")
Handle.Transparency = 0
Fire = Handle:WaitForChild("Fire")
local Sun

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BlindScript = script:WaitForChild("BlindScript")

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Anchored = false,
	Locked = true,
	CanCollide = true,
}

EyePart = BasePart:Clone()
EyePart.Name = "EyePart"
EyePart.Size = Vector3.new(1, 2, 1)
EyeMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "69433615"),
	TextureId = (BaseUrl .. "69433631"),
	Scale = Vector3.new(1.1, 1.1, 1.1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = EyePart,
}

HatPart = EyePart:Clone()
HatPart.Name = "HatPart"
HatPart.Size = Vector3.new(2, 2, 2)
HatPart.Mesh.MeshId = (BaseUrl .. "22009651")
HatPart.Mesh.TextureId = (BaseUrl .. "22009647")

Handle.Transparency = 0
Fire.Enabled = false
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:FindFirstChild("Humanoid") then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function FireBeam(StartPos, EndPos)
	local Distance = (StartPos - EndPos).magnitude
	Distance = ((Distance > 500 and 500) or Distance)
	local Laser = BasePart:Clone()
	Laser.Name = "Bullet"
	Laser.Anchored = true
	Laser.CanCollide = false
	Laser.Material = Enum.Material.Neon
	Laser.Size = Vector3.new(0.2, 0.2, (Distance + 0.2))
	Laser.BrickColor = BrickColor.new("Bright red")
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, -(Distance / 2))
	Debris:AddItem(Laser, 0.25)
	Laser.Parent = game:GetService("Workspace")
end

function LaunchSun()
	
	local origcharacter = Character

	Sun = Handle:Clone()
	local SunMesh = Sun.Mesh
	
	Handle.Transparency = 1
	
	Sun.Name = "Sun"
	Sun.Transparency = 0
	Sun.Anchored = true
	Sun.CFrame = Handle.CFrame
	Debris:AddItem(Sun, 10) 
	Sun.Parent = game:GetService("Workspace")

	Humanoid.WalkSpeed = 2

	local Fire = Instance.new("Fire")
	Fire.Size = 30
	Fire.Heat = 25
	Fire.Parent = Sun

	local Hats = {}
	
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Accoutrement") then
			table.insert(Hats, v)
			v.Parent = nil
		end
	end
	
	local Hat = HatPart:Clone()
	local HatWeld = Create("Weld"){
		Part0 = Head,
		Part1 = Hat,
		C0 = CFrame.new(0, 0, 0),
		C1 = CFrame.new(0, -0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Parent = Hat,
	}
	Debris:AddItem(Hat, 6.5)
	Hat.Parent = Character
	
	local Eye = EyePart:Clone()
	local EyeWeld = Create("Weld"){
		Part0 = Head,
		Part1 = Eye,
		C0 = CFrame.new(0, 0, 0),
		C1 = CFrame.new(0, -0.05, -0.25, 1, 0, 0, 0, -4.37113883e-008, -1, 0, 1, -4.37113883e-008),
		Parent = Eye,
	}
	Debris:AddItem(Eye, 7.0)
	Eye.Parent = Character
	
	if Sun:FindFirstChild("Summon") then
		Sun:FindFirstChild("Summon"):Play()
	end
	
	local Duration = 2.75
	local DurationTick = tick()
	while (tick() - DurationTick) < Duration do
		wait()
		Sun.CFrame = Sun.CFrame + Vector3.new(0, 2, 0) 
		SunMesh.Scale = SunMesh.Scale * 1.05 
	end		

	for i, v in pairs(Players:GetPlayers()) do
		if v:IsA("Player") and v ~= Player and v.Character and not IsTeamMate(Player, v) then
			local character = v.Character
			local humanoid,FF = character:FindFirstChildOfClass("Humanoid"), character:FindFirstChildOfClass("ForceField")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			local Blind = false
			if humanoid and humanoid.Health > 0 and torso and not FF then
				local Distance = (Sun.Position - torso.Position).Magnitude
				
				if Distance <= 240 then
					
					local RayHit, RayPos = CastRay(Sun.Position, ((torso.Position - Sun.Position).Unit * 500), Distance, {Character}, false)
					FireBeam(Sun.Position, RayPos)
					if RayHit then
						if RayHit.Parent:IsA("Accoutrement") or RayHit.Parent:IsA("Tool") then
							RayHit = RayHit.Parent
						end
						if RayHit.Parent == character then
							Blind = true
						end
					end
					--Blind = true
					--FireBeam(Sun.Position, torso.Position)

				end
				
				if Blind and not character:FindFirstChild(BlindScript.Name) then 
					local BlindScriptClone = BlindScript:Clone()
					BlindScriptClone.Disabled = false
					Create("ObjectValue"){
						Name = "Creator",
						Value = Player,
						Parent = BlindScriptClone,
					}
					Debris:AddItem(BlindScriptClone, 12)
					BlindScriptClone.Parent = character
				end 
			end
		end
	end	

	wait(0.75)
	
	Humanoid.WalkSpeed = 16
	for i, v in pairs({Hat, Eye}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if origcharacter then
		for i, v in pairs(Hats) do
			v.Parent = origcharacter
		end
	end
	
	wait(10.25)
	
	Handle.Transparency = 0
	
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or (Sun and Sun.Parent) then
		return
	end
	Tool.Enabled = false
	LaunchSun()
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	--ToolEquipped = true
end

function Unequipped()
	--ToolEquipped = false
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)