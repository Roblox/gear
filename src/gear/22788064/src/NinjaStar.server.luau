Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.Name="NinjaStar"
Pellet.Locked = true
Pellet.BackSurface = 0
Pellet.BottomSurface = 0
Pellet.FrontSurface = 0
Pellet.LeftSurface = 0
Pellet.RightSurface = 0
Pellet.TopSurface = 0
Pellet.Shape = 1
Pellet.formFactor = 2
Pellet.Size = Vector3.new(1,.4,1)
Pellet.BrickColor = BrickColor.new(26)
script.Parent.StarScript:clone().Parent = Pellet


function isTurbo(character)
	return character:FindFirstChild("Medusa") ~= nil
end


function fire(v, turbo)
Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.7
Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3.6
wait(.1)
Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 1
Tool.Handle.Transparency=1
	Tool.Handle.Fire:play()

-- find player's head pos

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end


	local launch = head.Position + 10 * v

		

	local missile = Pellet:clone()
        

	Tool.Handle.Mesh:clone().Parent = missile
		

	missile.Position = launch
	missile.Velocity = v * 80




	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,40,0)
	force.Parent = missile

	if (turbo) then
		missile.Velocity = v * 100
		force.force = Vector3.new(0,45,0)
	end

	missile.StarScript.Disabled = false

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vCharacter
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	missile.Parent = game.Workspace

end



function rndDir()
	return Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit
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
if loaded==true then
	loaded=false

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	fire(lookAt, isTurbo(character) )

	if (isTurbo(character) == true) then
		wait(.1)
		Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.6
		Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3.6
		wait(.1)
		fire(lookAt * .9 + rndDir() * .1, isTurbo(character) )
		Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.6
		Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3.6
		wait(.1)
		fire(lookAt * .8 + rndDir() * .2, isTurbo(character) )
		wait(.1)
	else
		wait(.3)
	end

	Tool.Enabled = true
elseif loaded==false then
Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.6
Tool.Parent.Torso["Right Shoulder"].DesiredAngle = -3.6
	wait(.1)
Tool.Handle.Transparency=0
wait(.1)
	loaded=true
	end
	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
