-- // Created by StarWars
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Motor = Handle:FindFirstChildOfClass("Motor6D")
if Motor then
	Motor:Destroy()
	Motor = nil
end

local GearService = require(1075123174)
local GearData = GearService:BindGear(Tool)
GearData:SetupRemoteFunctions()
GearData:SetupLocalScript("MouseIcon")

local Ammo = Tool.Ammo:Clone()
Ammo.Transparency = 0
Tool.Ammo:Destroy()

local VELOCITY = 120
local RELOAD_TIME = 2.5

local Damage = {
	Min = 2,
	Max = 5
}

function FireTurkey()
	local MouseData = GearData.ClientControls:InvokeClient(GearData.Player, "GetMouseData")
	if not MouseData then return end
	local Direction = (MouseData.Position - GearData.RootPart.Position).Unit
	
	local NewAmmo = Ammo:Clone()
	
	NewAmmo.CFrame = Handle.CFrame * CFrame.new(0, 0, -5)
	NewAmmo.Velocity = (Direction + Vector3.new(0, 1, 0)).Unit * math.random(VELOCITY - 20, VELOCITY + 20) 
	local Debounce = false
	local TouchedConnection = NewAmmo.Touched:Connect(function(hit)
		if Debounce then return end 
		if hit and hit.Parent and not hit:IsDescendantOf(GearData.Character) then
			Debounce = true
			local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if HitHumanoid then
				HitHumanoid:TakeDamage(math.random(Damage.Min, Damage.Max))
			end
			wait()
			Debounce = false
		end
	end)
	
	delay(5, function()
		if TouchedConnection then
			TouchedConnection:Disconnect()
		end
	end)
	Handle.Fire:Play()
	NewAmmo.Parent = workspace
	
	Debris:AddItem(NewAmmo, 30)
end

GearData:BindActivateFunction("turkey_gun", function()
	-- // Pew
	FireTurkey()	
	
	wait(RELOAD_TIME)
end)

GearData:BindEquippedFunction("turkey_gun", function()
	
end)