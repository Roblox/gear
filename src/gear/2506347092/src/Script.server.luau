-- // Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local RELOAD_TIME = 1.5
local ANIMATIONS = {
	Cheer = {Animation = tool.Animations.R6.Cheer},
	R15Cheer = {Animation = tool.Animations.R15.Cheer}
}

function InvokeClient(mode, value)
	if gear.Player and mode then
		local result
		
		pcall(function()
			result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
		end)
		
		return result
	end
end

tool.Activated:Connect(function()
	if gear:IsPlayerAlive() and tool.Enabled then
		tool.Enabled = false
		
		local anim = ANIMATIONS.Cheer
		if gear.Humanoid and gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
			anim = ANIMATIONS.R15Cheer
		end
		
		InvokeClient("PlayAnimation", anim)
		InvokeClient("PlaySound", handle.Cheer)
		
		wait(RELOAD_TIME)
		tool.Enabled = true
	end
end)