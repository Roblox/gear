local debris = game:GetService("Debris")

local tool = script.Parent

local gravity = workspace.Gravity
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	gravity = workspace.Gravity
end)

local mass = tool.Handle:GetMass()

local RELOAD_TIME = 8
local lastCheck = 0

tool.Equipped:Connect(function(mouse)
	if mouse then
		mouse.Button1Down:Connect(function()
			if tick() - lastCheck >= RELOAD_TIME then
				lastCheck = tick()
				local fakeHandle = tool.Handle:Clone()
				local bodyForce = Instance.new("BodyForce")
				bodyForce.Force = Vector3.new(0, (mass * gravity) + 0.5, 0)
				bodyForce.Parent = fakeHandle
				fakeHandle.Name = "Effect"
				fakeHandle.Transparency = 0
				fakeHandle.CanCollide = false
				fakeHandle.RotVelocity = Vector3.new(0, 10, 0)
				local fire = Instance.new("Fire")
				fire.Color = Color3.new(0, 1, 0)
				fire.Parent = fakeHandle
				delay(1, function()
					if fakeHandle then
						fakeHandle.Transparency = 1
					end
					wait(1)
					if fire then
						fire.Enabled = false
					end
				end)
				debris:AddItem(fakeHandle, 3)
				fakeHandle.Parent = workspace
			end
		end)
	end
end)