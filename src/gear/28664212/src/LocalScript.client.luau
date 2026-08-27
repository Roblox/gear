local Tool = script.Parent
local connection = nil
local enabled = true
local human = nil 
local shooting = false
local kick = nil

local debris = game:GetService("Debris")

function onButton1Down(mouse)

	if mouse.Target == nil or not enabled then
		return
	end

	enabled = false

		local humanoid = mouse.Target.Parent:FindFirstChild("Humanoid")

		-- pass the ball to someone
		if humanoid ~= nil and game.Players:FindFirstChild(humanoid.Parent.Name) ~= nil then
			Tool.PersonToPassTo.Value = "changer"
			wait()
			Tool.PersonToPassTo.Value = humanoid.Parent.Name

			kick:Play()
			kick.Stopped:connect(function()
				kick:remove()
			end)

		-- kick the ball
		else
			shooting = true

			kick:Play()
			kick.Stopped:connect(function()
				kick:remove()
			end)

			local targetPos = human.TargetPoint
			local v = (targetPos - Tool.Parent.Head.Position).unit

			local currTorso = Tool.Parent.Torso
			local lookAt = currTorso.CFrame.lookVector.unit
			local outFrontBuffer = 5
			local denom = math.abs(lookAt.x) + math.abs(lookAt.z)

			local xPos = (lookAt.x/denom) * outFrontBuffer
			local zPos = (lookAt.Z/denom) * outFrontBuffer

			wait()
			Tool.Parent = game.Workspace
			Tool.Handle.Position = Vector3.new(Tool.Handle.Position.x + xPos, Tool.Handle.Position.y, Tool.Handle.Position.z + zPos)
			Tool.Handle.Velocity = v * 100
			Tool.Handle.kick:Play()

			wait(0.1)

			shooting = false
		end

	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	connection = mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	
	human = Tool.Parent:FindFirstChild("Humanoid")
	kick = human:LoadAnimation(Tool.soccerkick)

end

function onUnequippedLocal()

	connection = nil

end

function onTouched(part)

	if shooting then
		local pos = Tool.Handle.Position
		Tool.Parent = game.Workspace
		Tool.Handle.Position = pos
		return
	end
end

Tool.Handle.Touched:connect(onTouched)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

