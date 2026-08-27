--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
FoamSound = Handle:WaitForChild("FoamSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 3

Damage = 0.25

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

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Activated()
	if Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
		Tool.Enabled = false
		local SteamPart = Instance.new("Part")
		SteamPart.Name = "SteamPart"
		SteamPart.Shape = Enum.PartType.Block
		SteamPart.FormFactor = Enum.FormFactor.Custom
		SteamPart.TopSurface = Enum.SurfaceType.Smooth
		SteamPart.BottomSurface = Enum.SurfaceType.Smooth
		SteamPart.Material = Enum.Material.Plastic
		SteamPart.Anchored = false
		SteamPart.CanCollide = false
		SteamPart.Locked = true
		SteamPart.Transparency = 1
		SteamPart.Size = Vector3.new(0.2, 0.2, 0.2)
		local Steam = Instance.new("Smoke")
		Steam.Parent = SteamPart
		Debris:AddItem(SteamPart, 3)
		local BodyForce = Instance.new("BodyForce")
		BodyForce.force = Vector3.new(0, SteamPart:GetMass() * 196.20, 0)
		BodyForce.Parent = SteamPart
		SteamPart.Parent = game:GetService("Workspace")
		SteamPart.CFrame = CFrame.new(Handle.Position, Humanoid.TargetPoint)
		SteamPart.CFrame = SteamPart.CFrame + Handle.CFrame.lookVector * Handle.Size.Z
		SteamPart.Velocity = CFrame.new(SteamPart.Position, Humanoid.TargetPoint).lookVector * 10
		local SteamStart = CFrame.new(SteamPart.Position)
		local SteamRadius = Vector3.new(1, 1, 1)
		Spawn(function()
			FoamSound:Play()
			while SteamPart and SteamPart.Parent do
				for i = 1, (SteamStart.p - SteamPart.Position).magnitude, 0.1 do
					local Humanoids = {}
					local SteamPosition = (SteamStart + CFrame.new(SteamStart.p, SteamPart.Position).lookVector * i).p
					local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(SteamPosition - SteamRadius, SteamPosition + SteamRadius), {Character, SteamPart}, 100)
					for i, v in pairs(Parts) do
						if v and v.Parent then
							local humanoid = v.Parent:FindFirstChild("Humanoid")
							if not CheckTable(Humanoids, humanoid) then
								table.insert(Humanoids, humanoid)
							end
						end
					end
					for i, v in pairs(Humanoids) do
						if v and v.Parent and v.Health > 0 then
							UntagHumanoid(v)
							TagHumanoid(v, Player)
							v:TakeDamage(Damage)
						end
					end
				end
				wait(0.1)
			end
			FoamSound:Stop()
		end)
		wait(ReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	FoamSound:Stop()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)