wait(3)
zombieParent = false

while zombieParent == false do

	wait(1)
	if script.Parent.Name == "SummonedZombie" then
		zombieParent = true
	end

end

local larm = script.Parent:FindFirstChild("Left Arm")
local rarm = script.Parent:FindFirstChild("Right Arm")
local waitTimer = 0

function findNearestTorso(pos)
	local list = game.Workspace:children()
	local torso = nil
	local dist = 100
	local temp = nil
	local human = nil
	local temp2 = nil
	for x = 1, #list do
		temp2 = list[x]
		if (temp2.className == "Model") and (temp2 ~= script.Parent) and (temp2.Name ~= "SummonedZombie") then
			temp = temp2:findFirstChild("Torso")
			human = temp2:findFirstChild("Humanoid")
			if (temp ~= nil) and (human ~= nil) and (human.Health > 0) and (human ~= script.Parent.Owner.Value) then
				if (temp.Position - pos).magnitude < dist then
					torso = temp
					dist = (temp.Position - pos).magnitude
				end
			end
		end
	end
	return torso
end

function Hit(hit)
	local human = hit.Parent:FindFirstChild("Humanoid")
	if human ~= nil and human ~=  script.Parent.Owner.Value and waitTimer == 0 and human.Parent.Name ~= "SummonedZombie" then
		human:TakeDamage(20)
		waitTimer = 3
	end
end

larm.Touched:connect(Hit)
rarm.Touched:connect(Hit)

while true do
	wait(1)
	local target = findNearestTorso(script.Parent.Torso.Position)
	if target ~= nil then
		script.Parent.Humanoid:MoveTo(target.Position, target)
	end
	if waitTimer > 0  then
		waitTimer = waitTimer - 1
	end
	if script.Parent.Humanoid.Health < 1 then
		wait(3)
		script.Parent:remove()
	end
	jumper = math.random(1,2)
	if jumper == 2 then
		script.Parent.Humanoid.Jump = true
	end
end
