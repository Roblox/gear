local Properties = {
	MaxHealth = 250,
	WalkSpeed = 20
}

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

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Animations = {}

local Sounds = {
	Drink = Handle:WaitForChild("Drink"),
}

local pale=BrickColor.new("Pastel yellow")
local clothes=BrickColor.new("Black")

local Character,Humanoid,Torso,BodyColors

local RunService = (game:FindService("RunService") or game:GetService("RunService"))

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	BodyColors = Character:FindFirstChildOfClass("BodyColors")
	Torso = (Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso"))
	Animations = Tool:WaitForChild("Animations")
	Animations = {
		Drink = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("Drink")),
		Slam = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("Slam"))
	}
end

local Sequenced = false
function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 or not Torso or Sequenced or not Character then return end
	Tool.Enabled = false
	Sequenced = true
	Animations.Drink:Play()
	Sounds.Drink:Play()
	local start = tick()
	repeat
		local current = tick()
		RunService.Heartbeat:Wait()
	until (current - start) >= 1.5 or not Sequenced
	if not Sequenced then return end
	Animations.Slam:Play()
	start = tick()
	repeat
		local current = tick()
		RunService.Heartbeat:Wait()
	until (current - start) >= .5 or not Sequenced
	if not Sequenced then return end
	if BodyColors then
		BodyColors.HeadColor=pale
		BodyColors.TorsoColor=clothes
		BodyColors.LeftArmColor=pale
		BodyColors.LeftLegColor=clothes
		BodyColors.RightArmColor=pale
		BodyColors.RightLegColor=clothes
	else
		Create("BodyColors"){
			HeadColor=pale,
			TorsoColor=clothes,
			LeftArmColor=pale,
			bLeftLegColor=clothes,
			RightArmColor=pale,
			RightLegColor=clothes,
			Parent = Character
		}
	end
	if Torso then
		if not Torso:FindFirstChildOfClass("Sparkles") then
			Create("Sparkles"){
				Enabled = true,
				SparkleColor = Color3.new(1,1,1),
				Parent = Torso,
			}
		end
		local VampireSoundScript = script:WaitForChild("VampireSoundScript")
		VampireSoundScript.Parent = Torso
		VampireSoundScript.Disabled = false
	end
	if Humanoid then
		Humanoid.MaxHealth = Properties.MaxHealth
		Humanoid.Health = Properties.MaxHealth
		Humanoid.WalkSpeed = Properties.WalkSpeed
	end
	local BrokenGlass = Handle:Clone()
	BrokenGlass:BreakJoints()
	BrokenGlass.Anchored = false
	BrokenGlass.Locked = true
	BrokenGlass.CanCollide = true
	BrokenGlass:WaitForChild("ThrowScript").Disabled = false
	BrokenGlass.Velocity = Vector3.new(0,-40,0)
	BrokenGlass.Parent = workspace
	BrokenGlass:SetNetworkOwner(nil)
	for _,anim in pairs(Animations) do
		if anim then anim:Stop() end
	end
	Tool:Destroy()
end

function Unequipped()
	if Sequenced then 
		Sequenced = false
		delay(1,function()
			Tool.Enabled = true
		end)
	end
	for _,anim in pairs(Animations) do
		if anim then anim:Stop() end
	end
	for _,sound in pairs(Sounds) do
		if sound then sound:Stop() end
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)
Tool.Unequipped:Connect(Unequipped)