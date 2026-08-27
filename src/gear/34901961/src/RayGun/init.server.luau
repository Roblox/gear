local Tool = script.Parent;
Tool.Enabled = true
local Handle = Tool:WaitForChild("Handle",math.huge)
local MousePos = Tool:WaitForChild("MouseInput",math.huge)
local humanoid

local Sounds = {
	Shoot = Handle:WaitForChild("Shoot",math.huge)
}

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game:GetService("Players"):GetPlayerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	local noise = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).Unit

	--v = (v + (noise * .05)).Unit


	local spawnPos = Handle.Position
	
	
	

	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,1)
	missile.CanCollide = false
	missile.Locked = true
	missile.Anchored = false
	missile.BrickColor = BrickColor.new(49)
	missile.Shape = Enum.PartType.Ball
	missile.BottomSurface = Enum.SurfaceType.Smooth
	missile.TopSurface = Enum.SurfaceType.Smooth
	missile.Material = Enum.Material.CorrodedMetal
	missile.Elasticity = .05
	missile.Friction = .7
	missile.Name = "Bullet"



	local force = Instance.new("BodyVelocity")
	force.Name = "BulletFloat"
	force.MaxForce = Vector3.new(1,1,1)*math.huge
	force.Velocity = v *150
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.LaserBlast:Clone()
	new_script.Parent = missile
	new_script.Disabled = false

	local otherScript = script.GravityScript:Clone()
	otherScript.Parent = missile

	missile.Parent = workspace

	Sounds.Shoot:Play()
end



function gunUp()
	Tool.GripForward = Vector3.new(0,.981,-.196)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false


	local character = Tool.Parent;
	humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return 
	end

	local Sucess,targetPos = pcall(function() return MousePos:InvokeClient(game:GetService("Players"):GetPlayerFromCharacter(character)) end)
	targetPos = (Sucess and targetPos) or Vector3.new(0,0,0)
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = 10*0.67

	fire(lookAt)
	wait(reload)

	Tool.Enabled = true

end

Tool.Activated:Connect(onActivated)