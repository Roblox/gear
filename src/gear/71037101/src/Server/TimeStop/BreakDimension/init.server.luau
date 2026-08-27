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

local Target = script:WaitForChild("Target").Value

local Duration = script:WaitForChild("Duration").Value
if not Target or not Duration then script:Destroy() end

local Humanoid = Target:FindFirstChildOfClass("Humanoid")
Humanoid:UnequipTools()

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
}

if Services.Players:GetPlayerFromCharacter(Target) then
	
	local TimeGrayScale = script:WaitForChild("GrayScale")
	TimeGrayScale.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Create("NumberValue"){
		Name = "Duration",
		Value = Duration,
		Parent = TimeGrayScale
	}
	TimeGrayScale.Disabled = false
	Services.Debris:AddItem(TimeGrayScale,Duration+5)
	if TimeGrayScale:FindFirstChildOfClass("ColorCorrection") then
		delay(Duration+5,function()
			if TimeGrayScale:FindFirstChildOfClass("ColorCorrection") then
				TimeGrayScale:FindFirstChildOfClass("ColorCorrection"):Destroy()
			end
		end)
		--Services.Debris:AddItem(TimeGrayScale:FindFirstChildOfClass("ColorCorrection"),Duration+5)
	end
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
	--[[repeat
		Services.RunService.Heartbeat:Wait()
	until not TimeGrayScale or not TimeGrayScale.Parent]]
end

wait((Duration or 5)+2.5)

Stop = false
if Services.Players:GetPlayerFromCharacter(Target) then	
	local Enable = script:WaitForChild("EnableBackpack")
	Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Enable.Disabled = false
	Services.Debris:AddItem(Enable,1)
end

Humanoid.JumpPower = 50
Humanoid.WalkSpeed = 16

script:Destroy()