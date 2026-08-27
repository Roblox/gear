local Players = game:GetService("Players")
local debris = game:GetService("Debris")

local Tool = script.Parent

local Player = nil

local RemoteEvent = Tool:FindFirstChild("Controller") or Instance.new("RemoteEvent")
RemoteEvent.Name = "Controller"
RemoteEvent.OnServerEvent:Connect(function(player, strength)
	if player ~= Player then return end 

	throwBalloon(strength)
end)

RemoteEvent.Parent = Tool

function onEquipped()

	--Tool.ThrowStrength.Changed:connect(throwBalloon)
	if Tool.Handle:FindFirstChild("BodyForce") ~= nil then
		Tool.Handle:FindFirstChild("BodyForce"):Destroy()
	end
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	
	Player = Players:GetPlayerFromCharacter(Tool.Parent)
end

local throwing = false

function throwBalloon(throwStrength)
	if not Tool.Enabled then return end 
	Tool.Enabled = false 

	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if throwStrength > 0 and humanoid ~= nil then
		wait()
		if throwStrength > 200 then
			throwStrength = 200
		end

		local balloon = Tool.Handle:clone()

		Tool.Handle.Transparency = 1

		local targetPos = humanoid.TargetPoint
		local lookAt = (targetPos - Tool.Parent.Head.Position).unit

		local script = Tool.WaterBalloonScript:clone()
		script.Parent = balloon
		script.Disabled = false
		
		balloon.Parent = workspace
		balloon.CanCollide = true

		balloon.Velocity = lookAt * throwStrength

		local force = Instance.new("BodyForce")
		force.force = Vector3.new(0, (workspace.Gravity * balloon:GetMass() * 0.5) + (throwStrength/30),0)
		force.Parent = balloon

		debris:AddItem(balloon,20)

		wait(1.5)
		Tool.Handle.Transparency = 0

	end

	Tool.Enabled = true

end

Tool.Equipped:connect(onEquipped)

