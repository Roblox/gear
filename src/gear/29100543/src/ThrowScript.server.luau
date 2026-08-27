local Tool = script.Parent

local flakes = {"28575797", "28575813", "28575821", "28575833", "28575848"}
local globs = {"28575761", "28575775"}

local debris = game:GetService("Debris")

function onEquipped()

	Tool.ThrowStrength.Changed:connect(throwBalloon)
	if Tool.Handle:FindFirstChild("BodyForce") ~= nil then
		Tool.Handle:FindFirstChild("BodyForce"):Destroy()
	end
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	
end

local throwing = false

function throwBalloon(throwStrength)

	if throwing then
		return
	end

	throwing = true

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
		force.force = Vector3.new(0,(throwStrength/30),0)
		force.Parent = balloon

		debris:AddItem(balloon,20)

		wait(1.5)
		Tool.Handle.Transparency = 0

	end

	throwing = false

end

Tool.Equipped:connect(onEquipped)

