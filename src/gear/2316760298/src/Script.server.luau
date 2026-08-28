-- // Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent

local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local HEAL_AMOUNT = 10
local RELOAD_RATE = 5
local HEAL_RADIUS = 20

local lastReload = 0

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
		local mouseData = InvokeClient("GetMouseData")
		if mouseData and mouseData.Target and mouseData.Position and (mouseData.Position - gear.RootPart.CFrame.p).Magnitude <= HEAL_RADIUS then
			local parentTo = mouseData.Target.Parent
			if parentTo then
				if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
					parentTo = parentTo.Parent
				end
				
				local humanoid = parentTo and parentTo:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = math.min(humanoid.Health + HEAL_AMOUNT, humanoid.MaxHealth)
				end
			end
		end 
		
		wait(RELOAD_RATE)
		tool.Enabled = true
	end
end)