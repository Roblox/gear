local Tool = script.Parent;


enabled = true

function fire(v)



	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)



	local missile = Tool.Handle:Clone()


	local spawnPos = vCharacter.PrimaryPart.Position
	
	--local PewPew = Tool.Handle:FindFirstChild("Whoosh")

	--if (PewPew == nil) then
	--	PewPew = Instance.new("Sound")
	--	PewPew.Name = "Whoosh"
	--	PewPew.SoundId = "http://www.roblox.com/asset/?id=13510352"
	--	PewPew.Parent = Tool.Handle
	--	PewPew.Pitch = .85
	--	PewPew.Volume = 1
	--end
	

	spawnPos  = spawnPos + (v * 10)

	targetPos = spawnPos + (v * 100)

	
	missile.Position = spawnPos
	missile.RotVelocity = Vector3.new(0, 20, 0)
	missile.Velocity = v * 150
	missile.CanCollide = true
	missile.Elasticity = .05
	missile.Friction = .7

	
	local bodyp = Instance.new("BodyPosition")
	bodyp.maxForce = Vector3.new(1e3,1e3,1e3)
	bodyp.D = 1.25e3
	bodyp.P = 1e3
	bodyp.position = targetPos
	bodyp.Parent = missile
	
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile

	local new_script = script.Parent.BoomerangControl:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	--PewPew:Play()

end



function chakramUp()
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripRight = Vector3.new(0,0,1)
	Tool.GripUp = Vector3.new(1,0,0)
end

function chakramSideways()
	Tool.GripForward = Vector3.new(1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end



function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end


function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = 7
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end

	if torso:FindFirstChild("Right Shoulder") then
		Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.7
		Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3.6
		--chakramSideways()
		wait(.1)
		Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 1
		
		wait(.1)
	end

	fire(lookAt)

	Tool.Handle.Transparency = 1

	--chakramUp()




	wait(reload)

	Tool.Handle.Transparency = 0

	enabled = true

end


script.Parent.Activated:connect(onActivated)

