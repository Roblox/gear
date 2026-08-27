local vChar = script.Parent
local torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
local humanoid = vChar:FindFirstChild("Humanoid")

local bv = torso:FindFirstChild("Rebound")

local spider = vChar:FindFirstChild("spider")

local count = 1

function pin(hit)
	if hit.Parent and hit:IsA("BasePart") and hit.Name ~= "spider" then
		if count == 1 then
			if bv then bv:Destroy() end
			count = count + 1			
			torso.Anchored = true
			humanoid.WalkSpeed = 0.0		
			wait(2.0)	
			torso.Anchored = false
			humanoid.WalkSpeed = 16			
		end
	end
end

local pinConnection = torso.Touched:connect(pin)

wait(0.75)
bv = torso:FindFirstChild("Rebound")
if bv then bv:Destroy() end
wait(2.5)
if spider then spider:Destroy() end
wait(0.5)
if pinConnection then pinConnection:disconnect() end

wait(1.0)
script:Destroy()