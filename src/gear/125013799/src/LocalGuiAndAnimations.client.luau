local Tool = script.Parent;

local EquipAnim
local ShootAnim 

function OnChanged(property, mouse)
	if property == 'Enabled' then
		if EquipAnim then EquipAnim:Stop() end
		if Tool.Enabled == false then
			ShootAnim:Play()
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		else
			mouse.Icon = "rbxasset://textures\\GunCursor.png"
		end
	end
end



function onEquippedLocal(mouse)
	local humanoid = Tool.Parent:FindFirstChild('Humanoid')
	EquipAnim = humanoid:LoadAnimation(Tool.Equip)
	ShootAnim = humanoid:LoadAnimation(Tool.Shoot)

	-- Make sure that the tool is still equiped when we play equip anim
	Spawn(function() wait() if Tool:IsDescendantOf(Workspace) then	EquipAnim:Play() end end)
	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Tool.Changed:connect(function(property) OnChanged(property, mouse) end)
end

function onUnequippedLocal()
	if EquipAnim then EquipAnim:Stop() end
	if ShootAnim then ShootAnim:Stop() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)