-----------------
--| Variables |--
-----------------

local Tool = script.Parent
local R6Folder = script:WaitForChild("R6")
local R15Folder = script:WaitForChild("R15")

local ScytheEquipAnimation = R6Folder:WaitForChild("ScytheEquip2")
local ScytheIdleAnimation = R6Folder:WaitForChild("ScytheIdle2")
local ScytheSlashAnimation = R6Folder:WaitForChild("ScytheSlash")

local ScytheEquipTrack = nil
local ScytheIdleTrack = nil
local ScytheSlashTrack = nil

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	local myModel = Tool.Parent
	local humanoid = myModel:FindFirstChild('Humanoid')
	if humanoid then -- Preload animations
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			ScytheEquipAnimation = R15Folder:WaitForChild("ScytheEquip2")
			ScytheIdleAnimation = R15Folder:WaitForChild("ScytheIdle2")
			ScytheSlashAnimation = R15Folder:WaitForChild("ScytheSlash")
		else
			ScytheEquipAnimation = R6Folder:WaitForChild("ScytheEquip2")
			ScytheIdleAnimation = R6Folder:WaitForChild("ScytheIdle2")
			ScytheSlashAnimation = R6Folder:WaitForChild("ScytheSlash")
		end
		
		ScytheEquipTrack = humanoid:LoadAnimation(ScytheEquipAnimation)
		if ScytheEquipTrack then ScytheEquipTrack:Play() end

		ScytheIdleTrack = humanoid:LoadAnimation(ScytheIdleAnimation)
		if ScytheIdleTrack then ScytheIdleTrack:Play() end

		ScytheSlashTrack = humanoid:LoadAnimation(ScytheSlashAnimation)
	end
end

Tool:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Tool.Enabled == false then
		if ScytheSlashTrack then
			ScytheSlashTrack:Play()
		end
	end
end)

local function OnUnequipped()
	-- Stop all animations
	if ScytheEquipTrack then ScytheEquipTrack:Stop() end
	if ScytheIdleTrack then ScytheIdleTrack:Stop() end
	if ScytheSlashTrack then ScytheSlashTrack:Stop() end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
