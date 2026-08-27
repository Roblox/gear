local Tool = script.Parent;
local bodyp = Instance.new("BodyPosition")
local targetPos = nil
local lookAt = nil

enabled = true

function fire(v)
	
	if(Tool.Handle.FlyingSound.IsPlaying == false) then
		Tool.Handle.FlyingSound:Play()
	end

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	
	local missile = Tool.Handle

	local spawnPos = vCharacter.PrimaryPart.Position

	targetPos = spawnPos + (v * 100)

	Tool.Parent = game.Workspace
	
	bodyp.maxForce = Vector3.new(1e3,1e3,1e3)
	bodyp.D = 1.5e3
	bodyp.P = 1e3
	bodyp.position = targetPos
	bodyp.Parent = missile
	wait(1)

	bodyp.position = Vector3.new(targetPos.X,0,targetPos.Z)
	bodyp.D = 1.6e3
	wait(1)

	bodyp.Parent = Tool
	Tool.Handle.FlyingSound:Stop()
end


function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	targetPos = humanoid.TargetPoint
	lookAt = (targetPos - character.Head.Position).unit
	
	fire(lookAt)

	wait(1)

	enabled = true

end

function onTouched(part)
	local h = part.Parent:FindFirstChild("Humanoid")
	if h ~= nil and Tool.Parent == game.Workspace then
		Tool.Handle.FlyingSound:Stop()
		bodyp.Parent = Tool
		--Tool.Parent = h.Parent
	end

end

Tool.Handle.Touched:connect(onTouched)
script.Parent.Activated:connect(onActivated)

