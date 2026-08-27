bombScript = script.Parent.Bomb
Tool = script.Parent

function plant(pos)
	
   
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position


	local bomb = Tool.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = pos
	bomb.Name = "Shell"
	bomb.Locked = true


	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb
	local new_script = bombScript:clone()
	new_script.Parent = bomb
	
	local bForce = Instance.new('BodyForce')
	bForce.force = Vector3.new(0, bomb:GetMass() * 250, 0)
	bForce.Parent = bomb
	
	bomb.Parent = game.Workspace
	
	wait(1.5)
	bForce:Destroy()
	new_script.Disabled = false
end


Tool.Enabled = true
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
	wait(3)
	Tool.Handle.Transparency = 0

	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)