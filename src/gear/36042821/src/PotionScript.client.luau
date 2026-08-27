-- music used under the Creative Commons licensing (by Attribution): all credit for the sample loop used goes to Mike Koenig

local Tool = script.Parent;
local dancer = nil

enabled = true


function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	--[[--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(27831659)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local torso = Tool.Parent:FindFirstChild("Torso")

	root = root:FindFirstChild("DiscoBall")
	root.Position = Vector3.new(torso.Position.x, torso.Position.y + 5, torso.Position.z)

	local sparkles = Instance.new("Sparkles")
	sparkles.Parent = root

	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = Vector3.new(torso.Position.x, torso.Position.y + 15, torso.Position.z)
	bodyPos.P = 10000
	bodyPos.D = 1000
	bodyPos.maxForce = Vector3.new(bodyPos.P,bodyPos.P,bodyPos.P)
	bodyPos.Parent = root

	local rotater = Instance.new("BodyAngularVelocity")
	rotater.P = 100000
	rotater.angularvelocity = Vector3.new(0,1000,0)
	rotater.maxTorque = Vector3.new(rotater.P,rotater.P,rotater.P)
	rotater.Parent = root

	root.Parent = game.Workspace
	]]--
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local torso = Tool.Parent:FindFirstChild("Torso")


	dancer = humanoid:LoadAnimation(Tool.monstermash)
	Tool.DanceObject.Value = dancer
	dancer:Play()
	Tool.Handle.SongLoop:Play()
	wait(11)
	Tool.Handle.SongLoop:Stop()
	dancer:Stop()
	dancer:remove()
	--root:remove()

	enabled = true

end

function onEquipped()
	--Tool.Handle.EquipSound:play()
end

function onUnequipped()
	--Tool.Handle.EquipSound:stop()
	if dancer ~= nil then
		dancer:Stop()
		dancer:remove()
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(OnUnequipped)
