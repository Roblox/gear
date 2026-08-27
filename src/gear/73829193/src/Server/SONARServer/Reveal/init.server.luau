local Character = script.Parent

local Center = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("HumanoidRootPart")

if not Center then script:Destroy() end

local Marking = script:WaitForChild("Indicator",10):WaitForChild("Marking",10)

local Services = {
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

Marking.Parent.Parent = Center
Marking.Parent.Enabled = true

local Rate = 60

for i=1,Rate,1 do
	Services.RunService.Heartbeat:Wait()
	Marking.ImageTransparency = (i/Rate)
end

if Marking then Marking:Destroy() end
script:Destroy()