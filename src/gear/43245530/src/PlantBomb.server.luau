local Tool = script.Parent
local Candle = Tool.Handle

local vCharacter


Tool.Enabled = true

function plant(pos)	
   
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	bg = Instance.new("BodyGyro")
	bg.P = 10000
	bg.maxTorque = Vector3.new(1, 1, 1) * bg.P
	bg.cframe = Candle.CFrame
	

	local bomb = Tool.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = pos
	bomb.Name = "Shell"
	bomb.Locked = true

	bg.Parent = bomb

	local p = Instance.new("Part")
	p.FormFactor = 3
	p.Size = Vector3.new(1.8, 0.2, 0.2)
	p.Parent = game.Workspace
	p.Name = "Fuse"

	fire = Instance.new("Fire")
	fire.Parent = p
	fire.Heat = 1.0
	fire.Size = 1.0 

	p.Transparency = 1.0

	pWeld = Instance.new("Weld")
	pWeld.Parent = bomb
	pWeld.Part0 = bomb
	pWeld.Part1 = p
	pWeld.C1 = CFrame.new(0, 0, -1)

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

	bomb.Parent = game.Workspace
	local new_script = Tool.BombScript:clone()	
	new_script.Disabled = false
	new_script.Parent = bomb

	wait(1.5)
	if p then p:Remove() end
end

function onActivated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint

	Tool.Handle.Transparency = 1
	plant(Tool.Handle.Position)
	wait(24)
	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end

Tool.Activated:connect(onActivated)