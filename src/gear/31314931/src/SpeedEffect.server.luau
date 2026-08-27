-- assume we are in the character, let's check
function sepuku()
	script.Parent = nil
end

local debris = game:GetService("Debris")

local h = script.Parent:FindFirstChild("Humanoid")
if (h == nil) then sepuku() end

local torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")
if (torso == nil) then sepuku() end

local head = script.Parent:FindFirstChild("Head")
if (head == nil) then head = torso end

local equalizingForce = 236 / 1.2 -- amount of force required to levitate a mass
local gravity = .75 -- things float at > 1
local fire = Instance.new("Fire")
fire.Parent = head
fire.Heat = 10
fire.Size = 3

function recursiveGetLift(node)
	local m = 0
	local c = node:GetChildren()
	if (node:FindFirstChild("Head") ~= nil) then head = node:FindFirstChild("Head") end -- nasty hack to detect when your parts get blown off

	for i=1,#c do
		if c[i].className == "Part" then
			if (head ~= nil and (c[i].Position - head.Position).magnitude < 10) then -- GROSS
				if c[i].Name == "Handle" then
					m = m + (c[i]:GetMass() * equalizingForce * 1) -- hack that makes hats weightless, so different hats don't change your jump height
				else
					m = m + (c[i]:GetMass() * equalizingForce * gravity)
				end
			end
		end
		m = m + recursiveGetLift(c[i])
	end
	return m
end

function jumpIt()

	local mass = recursiveGetLift(h.Parent)
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,mass * 2,0)
	force.Parent = torso
	debris:AddItem(force,0.5)

end

local con = h.Jumping:connect(jumpIt)

local oldSpeed = h.WalkSpeed
h.WalkSpeed = h.WalkSpeed * 1.6

local oldMaxHealth = h.MaxHealth
h.MaxHealth = oldMaxHealth * 1.5
h.Health = h.MaxHealth

local bodySpin = Instance.new("BodyAngularVelocity")
bodySpin.P = 200000
bodySpin.angularvelocity = Vector3.new(0,15,0)
bodySpin.maxTorque = Vector3.new(bodySpin.P,bodySpin.P,bodySpin.P)
bodySpin.Parent = torso

wait(30)

fire:Destroy()

h.WalkSpeed = oldSpeed
h.MaxHealth = oldMaxHealth
if h.Health > 60 then
	h.Health = 60
end
con:disconnect()
bodySpin:Destroy()
sepuku()
