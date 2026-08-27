local Tool = script.Parent
local ToolHandle = Tool.Handle

local cooldown = 3 -- Seconds until another can be thrown
local timeToLive = 10 -- Seconds until each old one is destroyed
local throwSpeed = 100

-- {PoisonApple, PoisonCake, PoisonPorkChop}
local baseIdUrl = "http://www.roblox.com/asset/?id="
local iconIds = {"87862872", "87863072", "87871704"}
local meshIds = {"87862943", "87863104", "87863169"}
local textureIds = {"87862921", "87863090", "87863148"}
local handleSizes = {Vector3.new(1.2, 1.2, 1.2), Vector3.new(1.08, 1.11, 1.14), Vector3.new(0.45, 1.82, 1.33)}

local myModel = nil
local myWeld = nil

local function onEquipped()
	myModel = Tool.Parent

end

local function onActivated()
	if not myModel or not myModel:FindFirstChild("Humanoid") or not Tool.Enabled then return end
	Tool.Enabled = false
	ToolHandle.Transparency = 1

	local handleClone = ToolHandle:Clone()
	Game:GetService("Debris"):AddItem(handleClone, 60) -- Takes care of non-player humanoids picking it up
	handleClone.Velocity = (myModel.Humanoid.TargetPoint - ToolHandle.CFrame.p).unit * throwSpeed
	handleClone.Name = "Food"
	handleClone.Parent = Workspace
	handleClone.Transparency = 0
	handleClone.CanCollide = true
	Instance.new("BodyGyro", handleClone) -- Keeps it upright
	local selfDestructScript = handleClone:FindFirstChild("SelfDestruct")
	if selfDestructScript and selfDestructScript:FindFirstChild("TimeToLive") then
		selfDestructScript.TimeToLive.Value = timeToLive
		selfDestructScript.Disabled = false
	end
	local foodScript = handleClone:FindFirstChild("PoisonedFood")
	if foodScript then
		local creator = Instance.new("ObjectValue", foodScript)
		creator.Name = "Creator"
		creator.Value = myModel
		foodScript.Disabled = false
	end

	-- Load new item (while we wait)
	local index = math.random(3)
	ToolHandle.Mesh.MeshId = baseIdUrl .. meshIds[index]
	ToolHandle.Mesh.TextureId = baseIdUrl .. textureIds[index]
	ToolHandle.Size = handleSizes[index] -- This breaks the weld
--	myWeld.Parent = Game.JointsService -- Fix the weld
	Tool.TextureId = baseIdUrl .. iconIds[index] -- Change the tool icon

	wait(cooldown)

	ToolHandle.Transparency = 0
	Tool.Enabled = true
end

local function onUnequipped()
	ToolHandle.Transparency = 0
end

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
