-- // Created by StarWars
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local gear = GearService:BindGear(script.Parent)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local tool = script.Parent
local handle = tool.Handle

local refSword = handle:Clone()

local floatingSword

local targets = {}

local RELOAD_TIME = 2
local DAMAGE = 10

handle.Transparency = 1

function InvokeClient(mode, value)
	if mode and gear.Player then
		local result
		
		pcall(function()
			result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
		end)
		
		return result
	end
end

function ThrowSwordAtTarget(humanoid)
	if humanoid and humanoid.RootPart and floatingSword then
		local newSword = refSword:Clone()
		newSword.CanCollide = false
		newSword.CFrame = floatingSword.CFrame
		
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = Vector3.new(5000, 5000, 5000)
		bodyPosition.Position = newSword.CFrame.p
		
		local bodyForce = Instance.new("BodyForce")
		bodyForce.Force = Vector3.new(0, newSword:GetMass() * workspace.Gravity, 0)
		
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = newSword.CFrame
		
		local fire = Instance.new("Fire")
		fire.Color = Color3.fromRGB(85, 255, 255)
		fire.SecondaryColor = Color3.fromRGB(0, 107, 107)
		fire.Size = 5
		fire.Heat = 9
		fire.Parent = newSword
		
		newSword.Touched:Connect(function(hit)
			local parentTo = hit.Parent
			if parentTo then
				if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
					parentTo = parentTo.Parent
				end
				
				local hum = parentTo:FindFirstChildOfClass("Humanoid")
				if hum == humanoid then
					hum:TakeDamage(DAMAGE)
					if newSword then
						newSword:Destroy()
					end
				end
			end
		end)
		
		bodyPosition.Parent = newSword
		bodyForce.Parent = newSword
		bodyGyro.Parent = newSword
		
		local data = {
			Target = humanoid,
			BodyPosition = bodyPosition,
			BodyGyro = bodyGyro,
			Model = newSword
		}
		
		newSword.Parent = workspace
		Debris:AddItem(newSword, 20)
		
		table.insert(targets, data)
		
	end
end

tool.Equipped:Connect(function()
	if not floatingSword then
		floatingSword = refSword:Clone()
		floatingSword.CFrame = handle.CFrame
		floatingSword.Name = "FloatingSword"
		
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = Vector3.new(5000, 5000, 5000)
		bodyPosition.Position = (floatingSword.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(0, math.rad(90), 0)).p
		
		local bodyForce = Instance.new("BodyForce")
		bodyForce.Force = Vector3.new(0, floatingSword:GetMass() * workspace.Gravity, 0)
		
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = floatingSword.CFrame * CFrame.new(0, 0, 3) * CFrame.Angles(0, math.rad(90), 0)
		
		bodyPosition.Parent = floatingSword
		bodyGyro.Parent = floatingSword
		bodyForce.Parent = floatingSword
		
		local fire = Instance.new("Fire")
		fire.Color = Color3.fromRGB(85, 255, 255)
		fire.SecondaryColor = Color3.fromRGB(0, 107, 107)
		fire.Size = 5
		fire.Heat = 9
		fire.Parent = floatingSword		
		
		floatingSword.Parent = tool.Parent
	end
	
	floatingSword:SetNetworkOwner(game:GetService("Players"):GetPlayerFromCharacter(tool.Parent))
end)

tool.Unequipped:Connect(function()
	if floatingSword then
		floatingSword:Destroy()
	end
	
	floatingSword = nil
end)

tool.Activated:Connect(function()
	if gear:IsPlayerAlive() and tool.Enabled and floatingSword then
		tool.Enabled = false
		local mouseData = InvokeClient("GetMouseData")
		
		if mouseData then
			local hit = mouseData.Target
			if hit and hit.Parent then
				local parentTo = hit.Parent
				if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
					parentTo = parentTo.Parent
				end
				
				local humanoid = parentTo:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid ~= gear.Humanoid and humanoid.Health > 0 then
					floatingSword.Transparency = 1
					local fire = floatingSword:FindFirstChildOfClass("Fire")
					if fire then
						fire.Enabled = false
					end
					ThrowSwordAtTarget(humanoid)
				end
			end
		end
		
		wait(RELOAD_TIME)
		if floatingSword then
			floatingSword.Transparency = 0
			local fire = floatingSword:FindFirstChildOfClass("Fire")
			if fire then
				fire.Enabled = true
			end			
		end
		tool.Enabled = true
	end
end)

RunService.Stepped:Connect(function(_, step)
	for i, data in pairs(targets) do
		if data.Model and data.Target and data.Target.RootPart and data.BodyPosition and data.BodyGyro then
			data.BodyPosition.Position = data.Target.RootPart.CFrame.p
			data.BodyGyro.CFrame = CFrame.new(data.Model.CFrame.p, data.Target.RootPart.CFrame.p) * CFrame.new(0, -math.rad(90), 0)
		else
			table.remove(targets, i)
		end
	end
end)