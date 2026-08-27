local Tool = script.Parent
local Figure = Tool.Handle

local vCharacter
local myTorso

local clapSound

local sparkles

Tool.Enabled = true

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
	sparkles.SparkleColor = Color3.new(1.0, 215/255, 0)
	sparkles.Parent = Figure
	wait(5.0)
	if sparkles then sparkles:Remove() end
	Tool.Enabled = true
end

function onUnequipped()
	if clapSound then clapSound:Stop() end
	if sparkles then sparkles:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

