--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

NewAnimate = script:WaitForChild("NewAnimate")

ShoeDisplay = Tool:FindFirstChild("ShoeDisplay")
if ShoeDisplay then
	ShoeDisplay:Destroy()
end

if not Players:GetPlayerFromCharacter(Tool.Parent) then
	Handle.Transparency = 0
end

BaseShoe = Handle:Clone()
BaseShoe.Transparency = 0
BaseShoe.Size = Vector3.new((Handle.Size.X / 2), Handle.Size.Y, Handle.Size.Z)
BaseShoe.CanCollide = false

BoostActive = false

Tool.Enabled = true

function Activated()
	if not Tool.Enabled or BoostActive then
		return
	end
	Tool.Enabled = false
	BoostActive = true
	Humanoid.WalkSpeed = 48
	local Unequipped = false
	local ToolUnequipped = Tool.Unequipped:connect(function()
		Unequipped = true
	end)
	wait(30)
	if not Unequipped then
		Humanoid.WalkSpeed = 24
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	BoostActive = false
	wait(15)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	wait()
	Handle.Transparency = 1
	local LeftLeg = Character:FindFirstChild("Left Leg")
	local RightLeg = Character:FindFirstChild("Right Leg")
	if LeftLeg then
		LeftShoe = BaseShoe:Clone()
		LeftShoe.Name = "LeftShoe"
		LeftShoe.Mesh.MeshId = "http://www.roblox.com/asset?id=165710807"
		LeftShoeWeld = Instance.new("Weld")
		LeftShoeWeld.Part0 = LeftLeg
		LeftShoeWeld.Part1 = LeftShoe
		LeftShoeWeld.C1 = CFrame.new(0, 0.45, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		LeftShoeWeld.Parent = LeftShoe
		LeftShoe.Parent = Character
	end
	if RightLeg then
		RightShoe = BaseShoe:Clone()
		RightShoe.Name = "RightShoe"
		RightShoe.Mesh.MeshId = "http://www.roblox.com/asset?id=165710830"
		RightShoeWeld = Instance.new("Weld")
		RightShoeWeld.Part0 = RightLeg
		RightShoeWeld.Part1 = RightShoe
		RightShoeWeld.C1 = CFrame.new(0, 0.45, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		RightShoeWeld.Parent = RightShoe
		RightShoe.Parent = Character
	end
	Humanoid.WalkSpeed = 24
	HumanoidJumped = Humanoid.Jumping:connect(function(Boolean)
		if BoostActive then
			Torso.Velocity = Vector3.new(0, 100, 0)
		end
	end)
	Animate = Character:FindFirstChild("Animate")
	if Animate then
		Animate.Disabled = true
	end
	NewAnimateClone = NewAnimate:Clone()
	NewAnimateClone.Disabled = false
	NewAnimateClone.Parent = Character
end

function Unequipped()
	wait()
	BoostActive = false
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	if HumanoidJumped then
		HumanoidJumped:disconnect()
	end
	for i, v in pairs({LeftShoe, RightShoe, NewAnimateClone}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if Animate and Animate.Parent then
		Animate.Disabled = false
	end
	Handle.Transparency = 0
end


Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)