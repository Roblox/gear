-- // Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local gear = GearService:BindGear(tool)
gear:SetupLocalScript("MouseIcon")

local DAMAGE = 12
local DEBOUNCE = 0.5
local SWING_LENGTH = 8

local grips = {
	Equip = tool.Grip,
	Swing = tool.Grip * CFrame.Angles(math.rad(90), 0, 0)
}

local randomSound = Random.new()

function onActivated()
	local hit = GearService:CastRay(gear.RootPart.CFrame.p, gear.RootPart.CFrame.lookVector, SWING_LENGTH, {gear.Character})
	
	local animation = Instance.new("StringValue")
	animation.Name = "toolanim"
	animation.Value = "Slash"
	
	tool.Grip = grips.Swing
	
	if hit and hit.Parent then
		local parentTo = hit.Parent
		if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
			parentTo = parentTo.Parent
		end
		
		local humanoid = parentTo:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(DAMAGE)
			-- // play keytar sound
			handle.Keytar.PlaybackSpeed = randomSound:NextNumber(0.5, 2)
			handle.Keytar:Play()
		end
	else
		-- // play slash sound
		handle.Slash:Play()
	end	
	wait(DEBOUNCE)
	tool.Grip = grips.Equip
end

function onEquipped()
	handle.Unsheath:Play()
end

gear:BindEquippedFunction("keytarSwordEquip", onEquipped)
gear:BindActivateFunction("keytarSwordActivate", onActivated)