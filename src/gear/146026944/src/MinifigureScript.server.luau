local Tool = script.Parent
local Figure = Tool.Handle

local vCharacter
local myTorso

local clapSound

local sparkles

Tool.Enabled = true

local connection

function glow(hit)
	if hit and hit.Parent and hit.Parent ~= vCharacter then 
		if hit.Size.X <= 5 and hit.Size.Y <= 5 and hit.Size.Z <= 5 then
			hit.Material = Enum.Material.Ice
			hit.BrickColor = BrickColor.new("Bright yellow")
			hit.TopSurface = 0
			hit.BottomSurface = 0
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myTorso == nil then 
		return
	end

	clapSound = Figure:FindFirstChild("ClapSound")
	if clapSound then clapSound:Play() end

	sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = Color3.new(0.5, 0.5, 0.5)
	sparkles.Parent = Figure
	connection = Figure.Touched:connect(glow)
	wait(5.0)
	if connection then connection:disconnect() end
	if sparkles then sparkles:Destroy() end
	Tool.Enabled = true
end

function onUnequipped()
	if clapSound then clapSound:Stop() end
	if sparkles then sparkles:Destroy() end
	if connection then connection:disconnect() end
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

