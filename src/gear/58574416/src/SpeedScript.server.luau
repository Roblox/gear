local myCharacter = script.Parent
local myHumanoid = myCharacter:FindFirstChildOfClass("Humanoid")
local Torso = myCharacter:FindFirstChild("Torso") or myCharacter:FindFirstChild("UpperTorso")
if not myHumanoid or not Torso then script:Destroy() end

local DEFAULT_SPEED = 16

local Sparkles = Instance.new("Sparkles")
Sparkles.Name = "Sarsaparilla Sparkles"
Sparkles.SparkleColor = Color3.new(0, 1, 0)
Sparkles.Parent = Torso

for i = 1, 20 do
	myHumanoid.WalkSpeed = DEFAULT_SPEED + 2 * (20 - i)
	Sparkles.SparkleColor = Color3.new(i/20, (20 - i)/20, 0)
	wait(1)
end

myHumanoid.WalkSpeed = DEFAULT_SPEED	-- Just to check.

if Sparkles then Sparkles:Destroy() end
script:Destroy()
