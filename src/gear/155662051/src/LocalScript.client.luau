--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

SummonShip = Tool:WaitForChild("SummonShip")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 5

ShipSize = 10

Damage = 60

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

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		if SummonShipAnim then
			SummonShipAnim:Stop()
		end
		SummonShipAnim = Humanoid:LoadAnimation(SummonShip)
		if SummonShipAnim then
			SummonShipAnim:Play(0.1, 1, 4)
		end
		local Ship = Handle:Clone()
		Handle.Transparency = 1
		Ship.Transparency = 0.35
		Ship.Size = Vector3.new((Ship.Size.X * ShipSize), (Ship.Size.Y * ShipSize), (Ship.Size.Z * ShipSize))
		Ship.Mesh.Scale = Vector3.new((Ship.Mesh.Scale.X * ShipSize), (Ship.Mesh.Scale.Y * ShipSize), (Ship.Mesh.Scale.Z * ShipSize))
		Ship.CanCollide = false
		Debris:AddItem(Ship, 10)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(((Ship:GetMass() * 100) * 100), ((Ship:GetMass() * 100) * 100), ((Ship:GetMass() * 100) * 100))
		BodyVelocity.Parent = Ship
		local HitDebounce = false
		Ship.Touched:connect(function(Hit)
			if Hit and Hit.Parent and not HitDebounce then
				local character, humanoid = FindCharacterAncestor(Hit.Parent)
				if character and humanoid and character ~= Character then
					HitDebounce = true
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
					Ship.Anchored = true
					for i = 1, 65, 0.1 do
						Ship.Transparency = Ship.Transparency + 0.1
						wait()
					end
					Ship:Destroy()
				end
			end
		end)
		Ship.Parent = game:GetService("Workspace")
		Ship.CFrame = Torso.CFrame + Vector3.new(0, ((Torso.Size.Y * 3) + (Ship.Size.Y / 2)), 0)
		Ship.CFrame = CFrame.new(Ship.Position, Humanoid.TargetPoint)
		BodyVelocity.velocity = CFrame.new(Ship.Position, Humanoid.TargetPoint).lookVector * 100
		wait(ReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Player)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Handle.Transparency = 0
	if SummonShipAnim then
		SummonShipAnim:Stop()
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)