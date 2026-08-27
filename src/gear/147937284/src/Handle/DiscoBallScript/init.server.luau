--Made by Luckymaxer

DiscoBall = script.Parent
Light = DiscoBall:WaitForChild("Light")

DanceScript = script:WaitForChild("DanceScript")

Players = game:GetService("Players")

DanceScripts = {}

DanceRadius = 50

LightColorChange = 0
LightChangeRate = 0.5

Spawn(function()
	while true do
		DiscoBall.CFrame = DiscoBall.CFrame * CFrame.Angles(0, 0.1, 0)
		if (tick() - LightColorChange) >= LightChangeRate then
			LightColorChange = tick()
			Light.Color = Color3.new(math.random(), math.random(), math.random())
		end
		wait(0.01)
	end
end)

for i, v in pairs(Players:GetChildren()) do
	if v:IsA("Player") and v.Character and v.Character:FindFirstChild("Humanoid") and (v.Character:GetModelCFrame().p - DiscoBall.Position).magnitude <= DanceRadius then
		if not v.Character.Humanoid:FindFirstChild(DanceScript.Name) then
			local DanceScriptClone = DanceScript:Clone()
			DanceScriptClone.Disabled = false
			table.insert(DanceScripts, DanceScriptClone)
			DanceScriptClone.Parent = v.Character.Humanoid
		end
	end
end

wait(15)

for i, v in pairs(DanceScripts) do
	pcall(function()
		local StopDance = Instance.new("StringValue")
		StopDance.Name = "StopDance"
		StopDance.Parent = v
	end)
end

DiscoBall:Destroy()