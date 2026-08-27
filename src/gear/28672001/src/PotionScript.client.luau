local Tool = script.Parent;
local dancer = nil
local debris = game:GetService("Debris")
local enabled = true
local drinker = nil
local humanoid = nil

local equalizingForce = 236 / 1.2 -- amount of force required to levitate a mass
local gravity = 1.05 -- things float at > 1

function onActivated()
	if not enabled  then
		return
	end

	enabled = false

		humanoid = Tool.Parent:FindFirstChild("Humanoid")
		local bodyPos = Instance.new("BodyPosition")
		
		drinker = humanoid:LoadAnimation(Tool.drink)
		drinker:Play()
		wait(0.35)
		Tool.Handle.Drink:Play()
		wait(1)
		drinker:remove()
		
		local hats = {}

		if humanoid.Parent:FindFirstChild("GoalHat") == nil then
				
			local humanStuff = humanoid.Parent:GetChildren()
			for i = 1, #humanStuff do

				if humanStuff[i].className == "Hat" then
					table.insert(hats,humanStuff[i])
					if humanStuff[i]:FindFirstChild("Handle") ~= nil then
						humanStuff[i].Handle.Transparency = 1
					end
				end
	
			end

			local hat = Instance.new("Hat")
			hat.AttachmentPos = Vector3.new(0, 0.7, 0.1)

			local handle = Instance.new("Part")
			handle.Name = "Handle"
			handle.Size = Vector3.new(4,2.4,2)
			local mesh = Instance.new("SpecialMesh")

			mesh.MeshId = "http://www.roblox.com/asset/?id=28663399"
			mesh.TextureId = "http://www.roblox.com/asset/?id=28663458"

			mesh.Parent = handle
			handle.Parent = hat

			hat.Parent = humanoid.Parent
			--[[local hat = Tool.GoalHat:clone()
			hat.Parent = humanoid.Parent]]
			debris:AddItem(hat,6.3)
		end

		Tool.Handle.Goal:Play()

		local mass = recursiveGetLift(Tool.Parent)

		bodyPos.P = mass * 5
		bodyPos.D = 0
		bodyPos.maxForce = Vector3.new(bodyPos.P,bodyPos.P,bodyPos.P)
		bodyPos.position = Vector3.new(0,0,0)

		local torso = humanoid.Parent:FindFirstChild("Torso")
		if torso ~= nil then

			local lookAt = torso.CFrame.lookVector.unit
			local denom = math.abs(lookAt.x) + math.abs(lookAt.z)
			local xPos = lookAt.x/denom
			local zPos = lookAt.z/denom
			local moveForward = 48

			bodyPos.position  = Vector3.new(torso.Position.x + (xPos * moveForward), torso.Position.y, torso.Position.z + (zPos * moveForward))

		end

		dancer = humanoid:LoadAnimation(Tool.goal)
		dancer:Play(0.1,1,0.5)
		wait(0.5)
		if torso ~= nil then
			bodyPos.Parent = torso
		end
		debris:AddItem(bodyPos,2.25)
		wait(2.3)
		humanoid.Jump = true
		wait(3.5)

		for i = 1, #hats do
			hats[i].Handle.Transparency = 0
		end

	enabled = true

end

function onEquipped()
	Tool.Handle.Goal:Stop()
end

function onUnequipped()
	print("hit it")

	Tool.Handle.Goal:Stop()
	if dancer ~= nil then
		dancer:Stop()
		dancer:remove()
	end

end

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

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(OnUnequipped)
