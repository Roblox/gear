local MOUSE_ICON = "rbxasset://textures/GunCursor.png"
local RELOAD_ICON = "rbxasset://textures/GunWaitCursor.png"

local player = game.Players.LocalPlayer
local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local launch = tool:WaitForChild("LaunchEgg")
local active = true
local mouse

local Settings = require(tool:WaitForChild("Settings"))

local function deactivate()
	active = false
	if mouse then
		mouse.Icon = RELOAD_ICON
	end
end

local function reactivate()
	active = true
	if mouse then
		mouse.Icon = MOUSE_ICON
	end
end

local function getTargetPos(mouse)
	local ignoreList = {}
	local mouseRay = Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000)
	local part, pos, normal
	local noTargetFound = false
	repeat
		part, pos, normal = workspace:FindPartOnRayWithIgnoreList(mouseRay, ignoreList)
		if not part then
			noTargetFound = true
		elseif part.CanCollide == false or part.Anchored == false then
			table.insert(ignoreList, part)
			part = nil
		end
	until part or noTargetFound
	if noTargetFound then
		pos = mouseRay.Origin + mouseRay.Direction
	else
		pos = pos + 2 * normal
	end
	
	if (pos - handle.Position).Magnitude > Settings.MaxDist then
		local launchRay = Ray.new(handle.Position, (mouse.Hit.Position - handle.Position).Unit * Settings.MaxDist)
		noTargetFound = false
		repeat
			part, pos, normal = workspace:FindPartOnRayWithIgnoreList(launchRay, ignoreList)
			if not part then
				noTargetFound = true
			elseif part.CanCollide == false or part.Anchored == false then
				table.insert(ignoreList, part)
				part = nil
			end
		until part or noTargetFound
		if noTargetFound then
			pos = launchRay.Origin + launchRay.Direction
		else
			pos = pos + 2 * normal
		end
	end
	
	if not part then
		noTargetFound = false
		local downRay = Ray.new(pos, Vector3.new(0, -2 * Settings.MaxDist, 0))
		repeat
			part, pos, normal = workspace:FindPartOnRayWithIgnoreList(downRay, ignoreList)
			if not part then
				noTargetFound = true
			elseif part.CanCollide == false or part.Anchored == false then
				table.insert(ignoreList, part)
				part = nil
			end
		until part or noTargetFound
		if noTargetFound then
			pos = downRay.Origin + downRay.Direction
		end
		if part then
			pos = pos + 2 * normal
		end
	end
	
	return pos
end

tool.Activated:Connect(function()
	if mouse and active then
		local origin = handle.Barrel.WorldPosition
		local pos = getTargetPos(mouse)
		local launched = launch:InvokeServer(origin, pos)
		if launched then
			deactivate()
			delay(Settings.Cooldown, function()
				reactivate()
			end)
		end
	end
end)

tool.Equipped:Connect(function(m)
	mouse = m
	mouse.Icon = active and MOUSE_ICON or RELOAD_ICON
end)

tool.Unequipped:Connect(function()
	mouse = nil
end)