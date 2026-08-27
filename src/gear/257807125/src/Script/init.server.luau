--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Light = Handle:WaitForChild("Light")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

SplashScreen = script:WaitForChild("SplashScreen")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

BaseLight = BasePart:Clone()
BaseLight.Transparency = 0.375
BaseLight.Name = "Effect"
BaseLight.Material = Enum.Material.Fabric
BaseLight.CanCollide = false
LightMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	VertexColor = Vector3.new(0.55, 0.25, 1),
	Offset = Vector3.new(0, 0, 0),
	Scale = Vector3.new(0, 0, 0), --(Vector3.new(1, 1, 1) / Vector3.new(0.5, 0.75, 0.5))
	MeshId = (BaseUrl .. "1033714"),
	TextureId = (BaseUrl .. "252883294"),
	Parent = BaseLight,
}

BaseDragon = BasePart:Clone()
BaseDragon.Name = "Effect"
BaseDragon.Transparency = 0
BaseDragon.CanCollide = false
DragonMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Scale = Vector3.new(20, 20, 20),
	MeshId = (BaseUrl .. "252790481"),
	TextureId = (BaseUrl .. "252790885"),
	Parent = BaseDragon,
}

BaseDragonSize = Vector3.new(7.5, 2, 4) --Mesh scale Vector3.new(1, 1, 1)

Rate = (1 / 60)

MaxRange = 200

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

EquipTime = 0

LightEnabled = false
ToolEquipped = false

Light.Enabled = false
Tool.Enabled = true

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end
	
function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if CheckTableForString(ProjectileNames, Hit.Name) then
			return true
		end
		local character = Hit.Parent
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("Humanoid") then
				return true
			end
		end
	end
	return false
end
	
function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function CreateLight(Display)
	if LightPart and LightPart.Parent then
		LightPart:Destroy()
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not Display then
		return
	end
	Dragon = BaseDragon:Clone()
	RotatorPart = BasePart:Clone()
	RotatorPart.Name = "Effect"
	RotatorPart.Transparency = 1
	RotatorPart.CanCollide = false
	RotatorWeld = Create("Weld"){
		Part0 = Handle,
		Part1 = RotatorPart,
		Parent = RotatorPart
	}
	LightPart = BaseLight:Clone()
	LightWeld = Create("Weld"){
		Part0 = RotatorPart,
		Part1 = LightPart,
		Parent = LightPart
	}
	DragonWeld = Create("Weld"){
		Part0 = LightPart,
		Part1 = Dragon,
		Parent = Dragon,
	}
	LightPart.Parent = RotatorPart
	RotatorPart.Parent = Tool
	LookDirection = Handle.CFrame
	LightPart.Parent = Tool
end

function Activated()
	LightEnabled = not LightEnabled
	Light.Enabled = LightEnabled
	CreateLight(LightEnabled)
	if LightEnabled then
		while LightEnabled and LightPart.Parent and LightPart:FindFirstChild("Mesh") and LightWeld.Parent and RotatorPart.Parent and RotatorWeld.Parent do
			if not ToolEquipped or not CheckIfAlive() or not LightEnabled then
				break
			end
			local MousePosition = InvokeClient("MousePosition")
			if MousePosition then
				MousePosition = MousePosition.Position
				--local Angle = (math.acos((MousePosition - Handle.Position).unit:Dot(Handle.CFrame.lookVector)))
				--if Angle >= 0 and Angle <= (math.pi / 3) then
					LookDirection = CFrame.new(Handle.Position, MousePosition)
				--end
				if LookDirection and LightEnabled then
					local RayHit, RayPos, RayNormal = CastRay(Handle.Position, LookDirection.lookVector, ((Handle.Size.Z / 2) + MaxRange), {Character}, false)
					local Length = ((Handle.Position - RayPos).magnitude - (Handle.Size.Z / 2))
					local Mesh = LightPart:FindFirstChild("Mesh")
					if Mesh then
						Mesh.Scale = Vector3.new(Clamp((1.5 * Length / 5), 1.5, 7.5), Clamp(Length, 6.5, MaxRange), Clamp((1.5 * Length / 5), 1.5, 7.5))
					end
					
					local LightOffset = ((Handle.Size.Z / 2) + (Length / 3) + (GetPercentage(1, MaxRange, Length) * 0.075))
					
					local Vec = LookDirection.lookVector
					local Pos = (Handle.CFrame * CFrame.new(0, 0, -((Handle.Size.Z / 2) - 0.5))).p
					local NewCFrame = CFrame.new(Pos, (Pos + Vec))
					RotatorWeld.C0 = Handle.CFrame:toObjectSpace(NewCFrame)
					RotatorWeld.C1 = CFrame.new(0, 0, 0)
					LightWeld.C0 = (CFrame.new(0, 0, -LightOffset) * CFrame.Angles((math.pi / 2), 0, 0))
					
					DragonWeld.C0 = CFrame.new(0, -((Length / 2) - (BaseDragonSize.X * 2.5)), 0) * CFrame.Angles(-(math.pi / 2), (math.pi / 2), 0)
					
					if Length >= (MaxRange * 0.5) and math.abs(Handle.Position.Y - MousePosition.Y) > 20 then
						Dragon.Parent = Tool
					else
						Dragon.Parent = nil
					end
					
				end
			end
			wait(Rate)
		end
		if not LightEnabled then
			if LightPart and LightPart.Parent then
				LightPart:Destroy()
			end
		end
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui and ((tick() - EquipTime) > 5 or LastPlayer ~= Player) then
		EquipTime = tick()
		SplashScreenCopy = SplashScreen:Clone()
		Debris:AddItem(SplashScreenCopy)
		SplashScreenCopy.Parent = PlayerGui
	end
	LastPlayer = Player
	ToolEquipped = true
end

function Unequipped()
	LightEnabled = false
	Light.Enabled = false
	CreateLight(false)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if Player ~= player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

CreateLight(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)