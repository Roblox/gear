bombScript = script.Parent.Spikey
Tool = script.Parent

function plant(pos)
	
   
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local dir = vCharacter.Torso.CFrame.lookVector

	

	local bomb = Tool.Handle:Clone()
	bomb.RotVelocity = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 5
	bomb.Velocity = dir * 5
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = pos
	bomb.Size = Vector3.new(1,1,1)
	bomb.Name = "Caltrop"
	bomb.Locked = true


	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

	bomb.Parent = game.Workspace
	local new_script = bombScript:clone()
	new_script.Disabled = false
	new_script.Parent = bomb

	Tool.Handle.OpenSound:Play()

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
	wait(.5)
	Tool.Handle.Transparency = 0

	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)