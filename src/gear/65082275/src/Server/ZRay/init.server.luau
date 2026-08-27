local Target = script:WaitForChild("Target")

local Active = script:WaitForChild("Active")

if not Target or not Active then script:Destroy() end

Target = Target.Value

local Head = Target:WaitForChild("Head")

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

function Sleep()
	local Z = script:WaitForChild("Z")
	Z.Parent = Head
	Z.Enabled = true
	
	local Services = {
		Players = (game:FindService("Players") or game:GetService("Players")),
		Debris = (game:FindService("Debris") or game:GetService("Debris")),
	}
	
	local SleepAnim = Humanoid:LoadAnimation(script:WaitForChild("Sleep"..Humanoid.RigType.Name))
	SleepAnim:Play(.5)
	
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
	
	wait(7)
	Stop = false
	if Services.Players:GetPlayerFromCharacter(Target) then	
		local Enable = script:WaitForChild("EnableBackpack")
		Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
		Enable.Disabled = false
		Services.Debris:AddItem(Enable,1)
	end
	SleepAnim:Stop()
	Humanoid.JumpPower = 50
	Humanoid.WalkSpeed = 16
	Z:Destroy()
	script:Destroy()
end

local Slept = false
Active.Changed:Connect(function(property)
	warn(property)
	if Active.Value and not Slept then
		Slept = true
		warn("Sleeping")
		Sleep()
	end
end)