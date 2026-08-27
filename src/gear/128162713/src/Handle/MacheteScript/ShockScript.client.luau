local Character = script.Parent
local Humanoid = Character:WaitForChild('Humanoid')
local Torso = Character:WaitForChild('Torso')

local Sparkles = Instance.new('Sparkles')
Sparkles.Parent = Torso

--[[local controllerService = game:GetService("ControllerService")
local controller = controllerService:GetChildren()[1]
controller.Parent = nil]]

Humanoid.WalkSpeed=0

Humanoid.Changed:connect(function()
	if Humanoid.Jump and Humanoid.WalkSpeed==0 then
		Humanoid.Jump=false
	end
end)

for i=1,10,1 do
	Humanoid:TakeDamage(5)
	wait(1)
end

--controller.Parent = controllerService

Humanoid.WalkSpeed=16


Sparkles.Parent = nil

script.Parent = nil

