local Tool = script.Parent;
Tool.Grip = CFrame.new(0,0,0,0,0,0,0,0,0,0,0,0)
enabled = true


local r = 1
local g = 0
local b = 0
local mode = 0
local light = script.Parent.Handle.PointLight
spark = true

function onActivated()
	if not enabled then return end
	enabled = false
	spark = not spark
	if spark then
		light.Enabled = true
		script.Parent.Handle.Sparkles.Enabled = true
		for i = 1,math.random(10),1 do
			part = Instance.new("Part")
			part.FormFactor = "Custom"
			part.Size = Vector3.new(0.5,0.5,0.5)
			part.Position = script.Parent.Handle.Position
			part.Velocity = Vector3.new(math.random(-50,50),math.random(70),math.random(-50,50))
			part.TopSurface = "Smooth"
			part.BottomSurface = "Smooth"
			newlight = Instance.new("PointLight")
			newlight.Range = 15
			newlight.Enabled = true
			newlight.Color = Color3.new(r,g,b)
			newlight.Parent = part
			sparkles = Instance.new("Sparkles")
			sparkles.SparkleColor = Color3.new(r,g,b)
			sparkles.Parent = part
			part.Parent = game.Workspace
			game.Debris:AddItem(part,20);
		end
		Tool.Handle.DrinkSound.Looped = true
		Tool.Handle.DrinkSound:Play()
	else
		light.Enabled = false
		script.Parent.Handle.Sparkles.Enabled = false
		Tool.Handle.DrinkSound.Looped = false
		Tool.Handle.DrinkSound:Stop()
	end
	wait(0.2)
	enabled = true
end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

while wait(0.1) do
	light.Color = Color3.new(r,g,b)
	script.Parent.Handle.Sparkles.SparkleColor = Color3.new(r,g,b)
	mode = mode + 0.02
	if spark then
		if mode < 1 then
			r = 1
			g = 0
			b = 0
		elseif mode < 2 then
			r = 1
			g = 1
			b = 1
		elseif mode < 3 then
			r = 0
			g = 0
			b = 1
		else
			mode = 0
		end
	end
end

