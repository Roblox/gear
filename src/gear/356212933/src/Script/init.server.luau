--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Steam = script:WaitForChild("Steam")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Animations = {}

Sounds = {}

Gravity = 196.20
Rate = (1 / 60)

FireDamage = 10

FireTick = 0

MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function RotateFlame()
	if not ParticleWeld or not ParticleWeld.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local MouseData = InvokeClient("MouseData")
	if MouseData then
		local MousePosition = MouseData.Position
		local Angle = (math.acos((MousePosition - Handle.Position).unit:Dot(Head.CFrame.lookVector)))
		if Angle < (math.pi / 3) then
			local Vec = (MouseData.Position - Head.Position)
			local Pos = (Handle.CFrame * ParticleWeld.C0).p
			local NewCFrame = (CFrame.new(Pos, (Pos + Vec)) * CFrame.Angles(-(math.pi / 2), 0, 0))
			ParticleWeld.C0 = Handle.CFrame:toObjectSpace(NewCFrame)
			ParticleWeld.C1 = CFrame.new(0, 0, 0)
		end
	end
end

function CreateParticlePart(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if Create then
		ParticlePart = BasePart:Clone()
		ParticlePart.Name = "ParticlePart"
		ParticlePart.Transparency = 1
		ParticlePart.CanCollide = false
		ParticleWeld = Instance.new("Weld")
		ParticleWeld.Part0 = Handle
		ParticleWeld.Part1 = ParticlePart
		ParticleWeld.C0 = CFrame.new(0, 0, -1.5) * CFrame.Angles(-(math.pi / 2), 0, 0)
		ParticleWeld.Parent = ParticlePart
		Particles = Steam:Clone()
		Particles.Parent = ParticlePart
		RotateFlame()
		ParticlePart.Parent = Tool
	end
end

function FireHit(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Hit.Name == "Effect" or Hit.Parent:IsA("Tool") then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (Player == player or IsTeamMate(Player, player)) then
			return
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(FireDamage)
	end)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	CreateParticlePart(false)
	MouseDown = false
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

CreateParticlePart(false)

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		if Down and not MouseDown and Tool.Enabled then
			MouseDown = true
			CreateParticlePart(true)
			Spawn(function()
				Particles.Enabled = true
				while MouseDown and ToolEquipped and CheckIfAlive() and ParticleWeld and ParticleWeld.Parent do
					RotateFlame()
					if (tick() - FireTick) > 0.1 then
						FireTick = tick()
						local FirePart = BasePart:Clone()
						FirePart = BasePart:Clone()
						FirePart.Name = "Effect"
						FirePart.Transparency = 1
						FirePart.Size = Vector3.new(1, 1, 1)
						FirePart.CanCollide = false
						FireHit(FirePart)
						local Direction = CFrame.new(ParticlePart.Position, (ParticlePart.CFrame * CFrame.new(0, 1, 0)).p).lookVector
						local Velocity = (Direction * Particles.Speed.Max)
						FirePart.CFrame = ParticlePart.CFrame + Direction * ((ParticlePart.Size.Z / 2) + (FirePart.Size.Z / 2))
						FirePart.Velocity = Velocity
						local Mass = (FirePart:GetMass() * Gravity)
						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
						BodyVelocity.velocity = Velocity
						BodyVelocity.Parent = FirePart
						Debris:AddItem(FirePart, Particles.Lifetime.Max)
						FirePart.Parent = game:GetService("Workspace")
					end
					wait(Rate)
				end
				if ParticlePart and ParticlePart.Parent then
					Debris:AddItem(ParticlePart, 2)
					if Particles and Particles.Parent then
						Particles.Enabled = false
					end
				end
				Tool.Enabled = false
				wait(3)
				Tool.Enabled = true
			end)
		elseif not Down and MouseDown then
			MouseDown = false
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)