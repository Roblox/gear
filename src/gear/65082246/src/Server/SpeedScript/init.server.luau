local myCharacter = script.Parent
local myHumanoid = myCharacter:FindFirstChildOfClass("Humanoid")
local Torso = myCharacter:FindFirstChild("Torso") or myCharacter:FindFirstChild("UpperTorso")
if not myHumanoid or not Torso then script:Destroy() end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
}

local DEFAULT_SPEED = 16

local Spirals = script:WaitForChild("SleepSpirals")
Spirals.Parent = Torso
Spirals.Enabled = true

for i=0,60*(20),1 do
	local CurrentColor = Color3.fromRGB(170, 0, 255):lerp(Color3.fromRGB(0,170,255),i/(60*(20)))
	local Precentage = (i/(60*20))
	myHumanoid.WalkSpeed = DEFAULT_SPEED + 2 * (20-((Precentage)*20))
	Spirals.Color = ColorSequence.new(CurrentColor)
	Services.RunService.Heartbeat:Wait()
end

myHumanoid.WalkSpeed = DEFAULT_SPEED	-- Just to check.

if Spirals then Spirals:Destroy() end
script:Destroy()
