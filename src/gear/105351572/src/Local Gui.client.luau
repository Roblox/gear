--Made by Luckymaxer

local Tool = script.Parent
local Equip
local EquipTime
local Hold
local Swing
local SwingTime
local Humanoid = nil

function SetAnimation(Animation, Boolean, FadeWeight, Time, Speed)
	if Animation ~= nil and Animation:IsA("AnimationTrack") then
		return (Boolean and Animation:Play(FadeWeight, Time, Speed)) or (not Boolean and Animation:Stop(FadeTime))
	end
end

Tool.Enabled = true

Tool.Equipped:connect(function(Mouse)
	if Mouse ~= nil then
		Mouse.Icon = "rbxasset://textures\\GunCursor.png"
		Humanoid = Tool.Parent:findFirstChild("Humanoid")
		EquipTime = tick()
		Swing = Humanoid:LoadAnimation(Tool.TwoHandSwing)
		Equip = Humanoid:LoadAnimation(Tool.Equip)
		Hold = Humanoid:LoadAnimation(Tool.TwoHandAnim)
		SetAnimation(Hold, true)
		SetAnimation(Equip, true, nil, nil, 0.7)
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and (tick() - EquipTime) > 1.7 then
			Tool.Enabled = false
			Mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			SetAnimation(Swing, true)
			wait(0.75)
			SetAnimation(Swing, false)
			Mouse.Icon = "rbxasset://textures\\GunCursor.png"
			Tool.Enabled = true
		end
	end)
end)

Tool.Unequipped:connect(function()
	SetAnimation(Swing, false)
	SetAnimation(Equip, false)
	SetAnimation(Hold, false)
end)