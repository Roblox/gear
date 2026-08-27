local Rocket = Instance.new("Part")

local Tool = script.Parent

local vel = Instance.new("BodyVelocity")

vel.Parent = Rocket


Rocket.Locked = true

Rocket.Size = Vector3.new(1,1,1)

Rocket.BrickColor = BrickColor.new(24)

Rocket.CanCollide = false



Tool.Note:clone().Parent = Rocket

Tool.RocketScript:clone().Parent = Rocket

--Tool.Explosion:clone().Parent = Rocket

--Tool.Swoosh:clone().Parent = Rocket





function fire(vTarget)



	local vCharacter = Tool.Parent;

	

	local vHandle = Tool:findFirstChild("Handle")

	if vHandle == nil then

		print("Handle not found")

		return 

	end


	local chord = Tool:FindFirstChild("sax" .. tostring(Tool.mode.Value)):clone()
	

	chord.Name = "chord"



	local dir = Vector3.new(math.random()-.5, 1, math.random() - .5).unit



	local missile = Rocket:clone()



	chord.Parent = missile



	local pos = vHandle.Position + Vector3.new(0, 5 ,0)

	

	--missile.Position = pos

	missile.CFrame = CFrame.new(pos,  pos + dir)

	missile.BodyVelocity.velocity = dir * 30

	local vPlayer = game.Players:playerFromCharacter(vCharacter)



	if vPlayer == nil then

		print("Player not found")

	end
	

	missile.RocketScript.Disabled = false


	missile.Parent = game.Workspace

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

	fire(targetPos)



	Tool.Enabled = true

end

script.Parent.Activated:connect(onActivated)



