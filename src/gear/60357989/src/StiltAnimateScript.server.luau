local vChar = script.Parent
local myTorso = vChar:FindFirstChild("Torso")

if myTorso == nil then script:Remove() end


local leftStilt = vChar:FindFirstChild("LeftStilt")
local rightStilt = vChar:FindFirstChild("RightStilt")
local leftStiltWeld = myTorso:FindFirstChild("LeftStiltWeld")
local rightStiltWeld = myTorso:FindFirstChild("RightStiltWeld")

while leftStiltWeld == nil or rightStiltWeld == nil do 
	leftStiltWeld = myTorso:FindFirstChild("LeftStiltWeld")
	rightStiltWeld = myTorso:FindFirstChild("RightStiltWeld")
	wait()
end

local lswOrigin = leftStiltWeld.C1
local rswOrigin = rightStiltWeld.C1

function animateStilts()
	local sign = 1
	local count = 0
	local rest = 1
	while leftStilt and rightStilt and leftStiltWeld and rightStiltWeld and myTorso do 		
		count = count + 1
		if count%2 == 1 then
			rest = 0
		else
			sign =  sign * 1
			rest = 1
		end
		leftStiltWeld.C1 = lswOrigin * CFrame.Angles(-math.pi/18 * sign * rest, 0, 0)
		rightStiltWeld.C1 = rswOrigin * CFrame.Angles(-math.pi/18 * sign * rest, 0, 0)
		wait(0.25)		
	end
	print("Exiting")
	script:Remove()
end

animateStilts()
