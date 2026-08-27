local Target = script:WaitForChild("Target").Value

--[[local Sounds = {
	Confuse = script:WaitForChild("Confuse"),
}]]

local Head = Target:FindFirstChild("Head")

local Star,Spiral = script:WaitForChild("Star"),script:WaitForChild("Spiral")

if not Target then script:Destroy() end

local Humanoid = Target:FindFirstChildOfClass("Humanoid")
Humanoid:UnequipTools()

if Head then
	Star.Parent = Head
	Spiral.Parent = Head
	Star.Enabled = true
	Spiral.Enabled = true
end

local Stop = false
coroutine.wrap(function()
	repeat
		Humanoid.JumpPower = 0
		Humanoid.WalkSpeed = 0
		game:GetService("RunService").Heartbeat:Wait()
	until Stop
end)()

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
}

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

if Services.Players:GetPlayerFromCharacter(Target) then
	local Disable = script:WaitForChild("DisableBackpack")
	Disable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Disable.Disabled = false
	Services.Debris:AddItem(Disable,1)
	Services.Players:GetPlayerFromCharacter(Target).CharacterRemoving:Connect(function(Char)--keeps people from a hidden inventory
		local Enable = script:WaitForChild("EnableBackpack")
		Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
		Enable.Disabled = false
		Services.Debris:AddItem(Enable,1)
	end)
end

local Duration,Start = 3,tick()

repeat
	Services.RunService.Heartbeat:Wait()
until (tick()-Start) >= Duration or Humanoid.Health <= 0

--Services.Debris:AddItem(Sounds.Shatter,Sounds.Shatter.TimeLength+1)


if Star and Spiral then
	Star.Enabled = false
	Spiral.Enabled = false
	Services.Debris:AddItem(Star,Star.Lifetime.Max)
	Services.Debris:AddItem(Spiral,Spiral.Lifetime.Max)
end


Stop = true
Humanoid.JumpPower = 50
Humanoid.WalkSpeed = 16


if Services.Players:GetPlayerFromCharacter(Target) then	
	local Enable = script:WaitForChild("EnableBackpack")
	Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Enable.Disabled = false
	Services.Debris:AddItem(Enable,1)
end

wait(2) -- Grace period (Your're Welcome EuroC2)

script:Destroy()