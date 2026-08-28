local Tool = script.Parent
local planeObject = Tool.Plane
local plane = Tool.Plane.Value
local velocityConstant = Tool.VelocityConstant.Value
local player = nil

local smoke = Instance.new("Smoke")

local maxForwardSpeed = 120
local maxReverseSpeed = -60

function killSmoke()
	smoke.Parent = nil
	plane.squealTires.Looped = false
	plane.squealTires:Stop()
end


planeObject.Changed:connect(function()	
	plane = Tool.Plane.Value		
	player.PlayerGui.PaperPlaneGui.MainFrame.ThrowPlane.TXT.Text = "End Flight"
	Tool.CamFocus.Value = plane
	plane.Fly.maxForce = Vector3.new(4000, 0, 4000)
	plane.Velocity = Vector3.new(0, 0, 0)
	plane.Fly.velocity = Vector3.new(0, 0, 0)
	plane.Turn.angularvelocity = Vector3.new(0, 0, 0)
	while plane do
		velocityConstant = Tool.VelocityConstant.Value
		plane.Fly.velocity = velocityConstant * plane.CFrame.lookVector.unit
		plane.idleSound.Volume = 1 * math.abs(velocityConstant/(maxForwardSpeed/2))
		plane.idleSound.Pitch = (math.abs(velocityConstant/(maxForwardSpeed/2)) * 2) + 1
		plane.Bank.maxTorque = Vector3.new(40000, 0, 40000)
		local cf = plane.CFrame

		local rv = plane.RotVelocity.y
		if rv > 0.5 then rv = 0.5 end
		if rv < -0.5 then rv = -0.5 end
		plane.Bank.cframe = CFrame.new(cf.p, cf.p+Vector3.new(cf.lookVector.x, 0, cf.lookVector.z))*CFrame.fromEulerAnglesXYZ(0, 0, rv*0.9) --*0.5	
		if player.PlayerGui.PaperPlaneGui.MainFrame.Gas.Selected and player.PlayerGui.PaperPlaneGui.MainFrame.Brake.Selected then
			smoke.Parent = plane
			plane.squealTires.Volume = 1
			plane.squealTires.Looped = true
			plane.squealTires:Play()
		else
			delay(2,killSmoke)
		end		
		wait()
	end

end)


function onEquipped()
	player = game.Players:GetPlayerFromCharacter(Tool.Parent)
end


function onUnequipped()	
	player = nil
end


Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
