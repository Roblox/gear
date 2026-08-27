--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Fire = Handle:WaitForChild("Fire")

HitScript = script:WaitForChild("HitScript")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

NinjaStars = {
	Meshes = {159689261, 159689271},
	Textures = {159689289}
}

Grip = CFrame.new(-0.550000012, 0.300000012, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0)

FireRate = 0.5
Power = 42

function RandomizeStar()
	Mesh.MeshId = "http://www.roblox.com/asset?id=" .. NinjaStars.Meshes[math.random(1, #NinjaStars.Meshes)]
	Mesh.TextureId = "http://www.roblox.com/asset?id=" .. NinjaStars.Textures[math.random(1, #NinjaStars.Textures)]
end

function ThrowStar(Start, Vector)
	if Start and Vector then
		local Star = Handle:Clone()
		Star.Name = "Effect"
		local Mesh = Star:FindFirstChild("Mesh")
		Star.CanCollide = true
		Star.Transparency = 0
		Star.Velocity = (Vector * Power)
		local BodyForce = Instance.new("BodyForce")
		BodyForce.force = Vector3.new(0, Star:GetMass() * 196.20, 0)
		BodyForce.Parent = Star
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = Star
		local HitScriptClone = HitScript:Clone()
		HitScriptClone.Disabled = false
		HitScriptClone.Parent = Star
		Debris:AddItem(Star, 15)
		Star.Parent = game:GetService("Workspace")
		Star.CFrame = CFrame.new(Start)
		Star.CFrame = CFrame.new(Star.Position, Handle.Position)
		Star.CFrame = Star.CFrame * CFrame.Angles(0, (math.pi / 2), 0)
		Star.RotVelocity = Star.CFrame.lookVector * -100
	end
end

function Activated()
	if Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
		Tool.Enabled = false
		Fire:Play()
		local BaseVector = (Humanoid.TargetPoint - Torso.Position).unit
		ThrowStar(Torso.Position + BaseVector * 5.5, BaseVector)
		Handle.Transparency = 1
		wait(FireRate)
		RandomizeStar()
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
	Handle.Transparency = 0
end

RandomizeStar()
Tool.Grip = Grip

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)