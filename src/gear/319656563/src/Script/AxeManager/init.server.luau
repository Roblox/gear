--Made by Luckymaxer
--Updated for R15 avatar

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

GearModel = InsertService:LoadAsset(315617026)
Gear = GearModel:GetChildren()[1]:Clone()
Debris:AddItem(GearModel, 1)

Functions = require(script:WaitForChild("Functions"))

Particles = script:WaitForChild("Particles")

Creator = Model:WaitForChild("Creator")

NPCConfiguration = {
	Name = "AxeMonster",
	FireRate = {Min = 2, Max = 2},
	Damage = 15,
}

for i, v in pairs(NPCConfiguration.FireRate) do
	NPCConfiguration.FireRate[i] = (v * 1000)
end

NPCsControlled = false
NPCs = {}

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

function ControlNPCs()
	if NPCsControlled or #NPCs == 0 then
		return
	end
	NPCsControlled = true
	while #NPCs > 0 do
		local CreatorPlayer = Functions.GetCreator(Creator)
		if CreatorPlayer then
			local HasUpgradeWeapon = false
			for i, v in pairs({CreatorPlayer.Character, CreatorPlayer.Backpack}) do
				if v and v.Parent then
					for ii, vv in pairs(v:GetChildren()) do
						if vv:IsA("Tool") and vv.Name == Gear.Name and vv.TextureId == Gear.TextureId then
							HasUpgradeWeapon = true
							break
						end
					end
				end
			end
			local Now = tick()
			for i, v in pairs(NPCs) do
				local TargetPlayer = nil
				if v and v.NPC and v.NPC.Parent and v.Humanoid and v.Humanoid.Health > 0 and v.Torso and v.Torso.Parent then
					local Axes = v.AxeThrowFunctions.GetAxes()
					for ii, vv in pairs(Axes) do
						local AxeParticles = vv:FindFirstChild("AxeParticles")
						if HasUpgradeWeapon then
							if not AxeParticles then
								AxeParticles = Particles:Clone()
								AxeParticles.Name = "AxeParticles"
								AxeParticles.Enabled = true
								AxeParticles.Parent = vv
							end
						else
							local AxeParticles = vv:FindFirstChild("AxeParticles")
							if AxeParticles then
								AxeParticles.Name = "Particles"
								AxeParticles.Enabled = false
								Debris:AddItem(AxeParticles, 2)
							end
						end
					end
					if v.Target.Value then
						local character = v.Target.Value
						if character and character.Parent then
							local player = Players:GetPlayerFromCharacter(character)
							if not player or (player and player ~= CreatorPlayer and not Functions.IsTeamMate(CreatorPlayer, player)) then
								local humanoid = character:FindFirstChild("Humanoid")
								local head = character:FindFirstChild("Head")
								local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
								if humanoid and humanoid.Health > 0 and head and torso then
									TargetPlayer = {Character = character, Humanoid = humanoid, Head = head}
									if TargetPlayer then
										local SpawnPos = v.Torso.Position
										local TargetPos = TargetPlayer.Head.Position
										local Direction = CFrame.new(SpawnPos, Vector3.new(TargetPos.X, SpawnPos.Y, TargetPos.Z))
										local Distance = (SpawnPos - TargetPos).Magnitude
										local BodyGyro = Create("BodyGyro"){
											maxTorque = Vector3.new(math.huge, math.huge, math.huge),
											cframe = Direction,
										}
										Debris:AddItem(BodyGyro, 0.5)
										BodyGyro.Parent = v.Torso
										if (Now - v.Throws.Tick) >= v.Throws.Delay and not Functions.CheckUpsideDown(v.Torso.CFrame, Enum.NormalId.Top, (math.pi / 3)) and Distance <= 200 then
											v.Throws.Tick = Now
											v.Throws.Delay = (math.random(NPCConfiguration.FireRate.Min, NPCConfiguration.FireRate.Max) * 0.001)
											v.AxeThrowFunctions.ThrowAxes(TargetPos, (NPCConfiguration.Damage * ((HasUpgradeWeapon and 1.5) or 1)))
										end
									end
								end
							end
						end
					end
				end
			end
		end
		wait()
	end
	NPCsControlled = false
end

function FunctionNPC(Child)
	if not Child:IsA("Model") or not string.find(string.lower(Child.Name), string.lower(NPCConfiguration.Name)) then
		return
	end
	for i, v in pairs(NPCs) do
		if v and v.NPC and v.NPC == Child then
			return
		end
	end
	local NPC = Child
	local Humanoid = NPC:FindFirstChild("Humanoid")
	local Torso = NPC:FindFirstChild("Torso") or NPC:FindFirstChild("UpperTorso")
	local Target = NPC:WaitForChild("Target")
	local AxeThrowFunctions = require(NPC:WaitForChild("ThrowAxes"))
	if not Humanoid or Humanoid.Health == 0 or not Torso or not Target then
		return
	end
	local ThrowDelay = (math.random(NPCConfiguration.FireRate.Min, NPCConfiguration.FireRate.Max) * 0.001)
	local Table = {
		NPC = Child,
		Humanoid = Humanoid,
		Torso = Torso,
		Target = Target,
		TargetPlayer = nil,
		AxeThrowFunctions = AxeThrowFunctions,
		Throws = {Tick = tick(), Delay = ThrowDelay},
	}
	table.insert(NPCs, Table)
end

for i, v in pairs(Model:GetChildren()) do
	FunctionNPC(v)
end

Model.ChildAdded:connect(function(Child)
	FunctionNPC(Child)
end)

Model.ChildRemoved:connect(function(Child)
	for i, v in pairs(NPCs) do
		if v and v.NPC and v.NPC == Child then
			table.remove(NPCs, i)
			break
		end
	end
end)

ControlNPCs()