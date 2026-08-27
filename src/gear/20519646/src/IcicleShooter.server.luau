--Edited by Locard for R15
Tool = script.Parent

function fire(v)

	Tool.Handle.Fire:play()
	

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	
	local Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
	if Torso then
		
		local rightShoulder = Torso:FindFirstChild'Right Shoulder' or Tool.Parent.RightUpperArm.RightShoulder		
		
		rightShoulder.DesiredAngle = 3.6			--moves your arm as if firing.
		rightShoulder.MaxVelocity = 0.5
	
		local missile = Instance.new("Part")
	
		local m = Tool.Mesh:Clone()	
		m.Parent = missile
	        
	
		local spawnPos = vCharacter.PrimaryPart.Position
	
		spawnPos  = spawnPos + (v * 8)
	
		missile.CFrame = CFrame.new(spawnPos, spawnPos + v)
		missile.Position = spawnPos
		missile.Size = Vector3.new(1,1,1)
		missile.Velocity = v * 80
		missile.BrickColor = BrickColor.new(23)
		missile.Shape = 0
		missile.BottomSurface = 0
		missile.TopSurface = 0
		missile.Name = "Icicle"
		missile.Elasticity = 0
		missile.Reflectance = 0
		missile.Friction = .4
	
		local force = Instance.new("BodyForce")
		force.force = Vector3.new(0,63,0)
		force.Parent = missile
		
	
		local new_script = script.Parent.Icicle:clone()
		new_script.Disabled = false
		new_script.Parent = missile
	
		local creator_tag = Instance.new("ObjectValue")
		creator_tag.Value = vPlayer
		creator_tag.Name = "creator"
		creator_tag.Parent = missile
		
	
	
		missile.Parent = game.Workspace
	end
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
	local lookAt = (targetPos - character.Head.Position).unit

	fire(lookAt)

	wait(1)

	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)

