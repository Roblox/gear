local Tool = script.Parent
local Candle = Tool.Handle

local Character


Tool.Enabled = true

function plant(pos)	
   
	local Character = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(Character)

	local spawnPos = Character.PrimaryPart.Position
	

	local bomb = Tool.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = pos
	bomb.Name = "Shell"
	bomb.Locked = true

	local bForce = Instance.new('BodyForce')
	bForce.force = Vector3.new(0, bomb:GetMass() * 220, 0)
	bForce.Parent = bomb 

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
	new_script.Parent = bomb

	wait(1.5)
	new_script.Disabled = false
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