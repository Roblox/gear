local Tool = script.Parent
local torso = nil

function onEquipped()
	torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
end
Tool.Equipped:connect(onEquipped)


function onUnequipped()
	if Tool.Handle.Transparency == 1 then
		Tool.Parent = game.Players:GetPlayerFromCharacter(torso.Parent).Backpack
	end
end
Tool.Unequipped:connect(onUnequipped)

function pinataExists()
	return game.Workspace:FindFirstChild(torso.Parent.Name .. "'s Pinata")
end

local enabled = false
function onActivated()

	if pinataExists() == nil then
		enabled = false
	end

	if enabled then return end
	enabled = true

	local pinata = Tool.Handle:clone()
	pinata.Name = "Head"
	pinata.CanCollide = true
	pinata.Size = Vector3.new(3,3,1)
	pinata.Position = Vector3.new(torso.Position.x + (torso.CFrame.lookVector.unit.x * 8),torso.Position.y,torso.Position.z + (torso.CFrame.lookVector.unit.z * 8))

	local model = Instance.new("Model")
	model.Name = torso.Parent.Name .. "'s Pinata"
	pinata.Parent = model
	model.Parent = game.Workspace

	local sound = Instance.new("Sound")
	sound.Name = "BrokenSound"
	sound.SoundId = "http://www.roblox.com/asset/?id=34300463"
	sound.Parent = pinata

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 0
	humanoid.Parent = model

	Tool.Handle.Transparency = 1
	
	local script = Tool.PinataScript:clone()
	script.Parent = pinata
	script.Disabled = false
	
	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = Vector3.new(pinata.Position.x,torso.Position.y + 5, pinata.Position.z)
	bodyPos.P = 8000
	bodyPos.D = bodyPos.P
	bodyPos.maxForce = Vector3.new(bodyPos.P,bodyPos.P,bodyPos.P)
	bodyPos.Parent = pinata

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 50
	bodyGyro.D = bodyGyro.P
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P,0,0)
	bodyGyro.cframe = pinata.CFrame
	bodyGyro.Parent = pinata

	Tool:Destroy()

	checkForTransparency()

end
Tool.Activated:connect(onActivated)


function checkForTransparency()
	while pinataExists() do wait(0.5) end
	Tool.Handle.Transparency = 0
end
