local Tool = script.Parent
local planeObject = Tool.Plane
local plane = Tool.Plane.Value
local velocityConstant = Tool.VelocityConstant.Value
local player = game.Players.LocalPlayer;
local smoke = Instance.new("Smoke")

local maxForwardSpeed = 60
local maxReverseSpeed = -40

function killSmoke()
	smoke.Parent = nil
	if (plane:findFirstChild("squealTires")) then
		plane.squealTires.Looped = false
		plane.squealTires:Stop()
	end
end


planeObject.Changed:connect(function()
	plane = Tool.Plane.Value
	if player.PlayerGui:findFirstChild("PaperPlaneGui") then
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
			plane.idleSound.Pitch = (((math.abs(velocityConstant/(maxForwardSpeed/2)) * 2) + 1 ) / 2)
			plane.Bank.maxTorque = Vector3.new(40000, 0, 40000)
			local cf = plane.CFrame
			plane.Bank.cframe = CFrame.new(cf.p, cf.p+Vector3.new(cf.lookVector.x, 0, cf.lookVector.z))*CFrame.fromEulerAnglesXYZ(0, 0, plane.RotVelocity.y*0.5)
			if player.PlayerGui:findFirstChild("PaperPlaneGui") then
				if player.PlayerGui.PaperPlaneGui.MainFrame.Gas.Selected and player.PlayerGui.PaperPlaneGui.MainFrame.Brake.Selected then
					smoke.Parent = plane
					plane.squealTires.Volume = 1
					plane.squealTires.Looped = true
					plane.squealTires:Play()
				else
					delay(2,killSmoke)
				end
			end
			wait()
		end
	end
end)


