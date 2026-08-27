--Fixed by Luckymaxer

Figure = script.Parent

Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")

Humanoid.MaxHealth = 350
Humanoid.Health = Humanoid.MaxHealth

local wanderTarget 
local wanderAngle 
local wanderConeSize = 6
local maxWanderAngle = 0.75 

function getWanderTarget()
	math.random(tick())
	wanderAngle = (math.random() - 0.5) * maxWanderAngle
	local rotatedLookVector = CFrame.Angles(0, wanderAngle, 0) * Torso.CFrame.lookVector
	return (Torso.Position + wanderConeSize * rotatedLookVector)
end

while true do  	
	local ray = game.Workspace:FindPartOnRay(Ray.new(Torso.Position, Torso.CFrame.lookVector * 5.0), nil)
	if ray and Humanoid and ray.Parent ~= Figure then
		Humanoid.Jump = true
	end     
	wanderTarget = getWanderTarget()	
	Humanoid:MoveTo(wanderTarget, Torso)
	wait(0.125)
end