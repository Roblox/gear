local Tool = script.Parent;

local enabled = true
local humanoid = nil
local thrower = nil

local ClientControl = Tool:WaitForChild("ClientControl")

function onButton1Down(mouse)

	if not enabled then
		return
	end
	if not mouse.Target then return end
	thrower:Play()
	local target = mouse.Target.Parent:FindFirstChild("Torso") or mouse.Target.Parent:FindFirstChild("UpperTorso")
	ClientControl:FireServer(target)
	wait(10)
end

function onEquippedLocal(mouse)
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			thrower = humanoid:LoadAnimation(Tool:WaitForChild("R15throwfrombag"))
		else
			thrower = humanoid:LoadAnimation(Tool:WaitForChild("throwfrombag"))
		end
	end
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)

end

function onUnequippedLocal()

	if thrower then
		thrower:Stop()
		thrower:Destroy()
	end
	thrower = nil
	humanoid = nil

end


Tool.Unequipped:connect(onUnequippedLocal)
Tool.Equipped:connect(onEquippedLocal)
