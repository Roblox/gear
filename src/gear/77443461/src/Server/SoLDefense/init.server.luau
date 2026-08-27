--Damage resistance & additive healing for Sword of Light
--Scripted by TakeoHonorable

local Services = {
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
}

local ToolRef = script:WaitForChild("ToolRef").Value

local HealingLight = script:WaitForChild("HealLight")

local Character = script.Parent

local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

if not Character or not Humanoid or Humanoid.Health <= 0 or not Torso then script:Destroy() end

HealingLight.Parent = Torso
HealingLight.Enabled = true

local function SunIsVisible(Character)
	local dir = Services.Lighting:GetSunDirection()
	if Vector3.new(0,1,0):Dot(dir) > 0 then
	-- BUG: particles block raycast
	local hit = workspace:FindPartOnRay(Ray.new(ToolRef:WaitForChild("Handle").Position,dir*999),Character)
		if not hit or (hit and not hit.CanCollide)then
			return true
		end
	end
	return false
end

local Resistance,Heal

local IgnoreHealthChange = false
		local CurrentHealth = Humanoid.Health
		Resistance = Humanoid.Changed:Connect(function(Property)
			local NewHealth = Humanoid.Health
			if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth and NewHealth > 0 then
				if NewHealth < CurrentHealth then
					local DamageDealt = (CurrentHealth - NewHealth)
					IgnoreHealthChange = true
					Humanoid.Health = Humanoid.Health + (DamageDealt * .6)
					IgnoreHealthChange = false
				end
			end
		CurrentHealth = NewHealth
end) 


	
local Step = false
ExtraHeal = Services.RunService.Heartbeat:Connect(function()
	if Step or not Humanoid or Humanoid.Health <= 0 then return end
	Step = true
	Humanoid.Health = Humanoid.Health + .05
	Step = false
end)

function Terminate()
	HealingLight.Enabled = false
	Services.Debris:AddItem(HealingLight,HealingLight.Lifetime.Max)
	if ExtraHeal then ExtraHeal:Disconnect();ExtraHeal = nil end
	if Resistance then Resistance:Disconnect();Resistance = nil end
	script:Destroy()
end

ToolRef.Changed:Connect(function(property)
	if property == "Parent" and ToolRef:IsDescendantOf(workspace) and not ToolRef:IsDescendantOf(Character) then
		Terminate()
	end
end)

Services.Lighting.Changed:Connect(function(property)
	if property == "ClockTime" then
		if not SunIsVisible(Character) then
			Terminate()
		end
	end
end)

