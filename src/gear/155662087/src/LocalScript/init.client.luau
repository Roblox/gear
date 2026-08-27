--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Loaded = Tool:WaitForChild("Loaded")
PauseScript = script:WaitForChild("PauseScript")

PlaySound = Tool:WaitForChild("PlaySound")

Meshes = {
	Cannon = "http://www.roblox.com/asset?id=155461643",
	CannonWithAnchor = "http://www.roblox.com/asset?id=155460734",
	Anchor = "http://www.roblox.com/asset?id=155461628"
}

Grips = {
	Cannon = CFrame.new(0.061999999, -0.5, 1.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	CannonWithAnchor = CFrame.new(0.0625, -0.5, 2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Players = game:GetService("Players")
Debris = game:GetService("Debris")
ContentProvider = game:GetService("ContentProvider")

ReloadTime = 3

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
		Loaded.Value = false
		local Anchor = Handle:Clone()
		Anchor.Mesh.MeshId = Meshes.Anchor
		Anchor.Size = Vector3.new(0.5, 1.5, 2)
		Debris:AddItem(Anchor, 3)
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(((Anchor:GetMass() * 100) * 100), ((Anchor:GetMass() * 100) * 100), ((Anchor:GetMass() * 100) * 100))
		BodyVelocity.Parent = Anchor
		PlaySound.Value = "AnchorShot"
		local HitDebounce = false
		Anchor.Touched:connect(function(Hit)
			if Hit and Hit.Parent and not HitDebounce then
				local character, humanoid = FindCharacterAncestor(Hit.Parent)
				if character and humanoid and character ~= Character then
					HitDebounce = true
					if not humanoid:FindFirstChild(PauseScript.Name) then
						local PauseScriptClone = PauseScript:Clone()
						PauseScriptClone.Disabled = false
						PauseScriptClone.Parent = humanoid
					end
					Anchor:Destroy()
				end
			end
		end)
		Anchor.Parent = game:GetService("Workspace")
		Anchor.CFrame = CFrame.new(Handle.Position, Humanoid.TargetPoint)
		Anchor.CFrame = Anchor.CFrame + Handle.CFrame.lookVector * Handle.Size.Z
		BodyVelocity.velocity = CFrame.new(Anchor.Position, Humanoid.TargetPoint).lookVector * 100
		wait(ReloadTime)
		Loaded.Value = true
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
	Mesh.MeshId = ((Loaded.Value and Meshes.CannonWithAnchor) or Meshes.Cannon)
	Tool.Grip = ((Loaded.Value and Grips.CannonWithAnchor) or Grips.Cannon)
	if not Tool.Enabled then
		wait(ReloadTime)
		Loaded.Value = true
		Tool.Enabled = true
	end
end

function Unequipped()
end

Loaded.Changed:connect(function()
	Mesh.MeshId = ((Loaded.Value and Meshes.CannonWithAnchor) or Meshes.Cannon)
	Tool.Grip = ((Loaded.Value and Grips.CannonWithAnchor) or Grips.Cannon)
end)

for i, v in pairs(Meshes) do
	ContentProvider:Preload(v)
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)