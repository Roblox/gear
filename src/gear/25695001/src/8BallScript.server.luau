r = game:service("RunService")
local Tool = script.Parent
local last_attack = 0
local humanoid = nil

function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false
	

	t = r.Stepped:wait()

	if (t - last_attack < 0.6) then
		humanoid = Tool.Parent:FindFirstChild("Humanoid")
		if humanoid ~= nil then
			throw()
		end
	else
		shake()
	end

	last_attack = t

	
	Tool.Enabled = true

end

function shake()

	Tool.Handle.Shake:Play()
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	fortune = Tool:FindFirstChild("ScreenGui")

	if fortune ~= nil then
		
		fortune = Tool:FindFirstChild("ScreenGui"):clone()
		fortune.Parent = vPlayer.PlayerGui

	end

	Tool.GripPos = Vector3.new(0.3,-0.4,0)
	wait(.1)
	Tool.GripPos = Vector3.new(-0.3,-0.4,0)
	wait(.1)
	Tool.GripPos = Vector3.new(0.3,-0.4,0)
	wait(.1)
	Tool.GripPos = Vector3.new(-0.3,-0.4,0)
	wait(.1)
	Tool.GripPos = Vector3.new(0,-0.4,0)

	Tool.Handle.Shake:Stop()

end

function throw()

	Tool.Parent = game.Workspace
	local character = humanoid.Parent
	local lookAt = character.Head.CFrame.lookVector
	Tool.Handle.Velocity = lookAt * 100
end

Tool.Activated:connect(onActivated)

while true do
	players = game.Players:getChildren()
	if players ~= nil then
		wait(math.random(1,#players))
		if #players > 0 then
			math.random(1, #players)
		end
	end
	wait(1)
end
