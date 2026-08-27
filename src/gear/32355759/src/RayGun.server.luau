local Tool = script.Parent;
local Handle = Tool.Handle

local enabled = true
local humanoid = nil
local amountInFront = 15

local reloadSound = Instance.new("Sound")
reloadSound.Name = "reloadSound"
reloadSound.SoundId = "http://www.roblox.com/asset/?id=25299064"
reloadSound.Parent = Tool.Handle
reloadSound.Volume = 2

local debris = game:GetService("Debris")

local ClientControl = Tool:FindFirstChild("ClientControl") or Instance.new("RemoteEvent")
ClientControl.OnServerEvent:Connect(function(player, target)
	if player == Player then
		if not target then return end
		Tool.PersonToAttack.Value = target
	end
end)
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function fire(torso, humanoid)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	Handle.noobShoot:Play()

	for i = 1,3 do

		--This call will cause a "wait" until the data comes back
		local root = game:GetService("InsertService"):LoadAsset(27410797)

		local instances = root:GetChildren()
		if #instances == 0 then
			root:Remove()
			return
		end

		local targetTorso = humanoid.Parent:FindFirstChild("Torso") or humanoid.Parent:FindFirstChild("UpperTorso")
		if targetTorso == nil then
			return
		end
		local spawnPoint = targetTorso.Position
		
		local torsoNormal = targetTorso.CFrame.lookVector
		local denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
		local posX = amountInFront * (torsoNormal.x/denom)
		local posZ = amountInFront * (torsoNormal.z/denom)

		local character = Tool.Parent
		local targetPos = humanoid.TargetPoint
		local lookAt = (targetPos - character.Head.Position).unit

		local pos = Vector3.new(spawnPoint.x + posX, spawnPoint.y + 10, spawnPoint.z + posZ)

		--Continue the insert process
		local noob = root:FindFirstChild("n00b",false)

		local animator = Tool.Animate:clone()
		local messenger = Tool.MessageScript:clone()
		local welder = Tool.Welder:clone()
		
		animator.Disabled = false
		messenger.Disabled = false
		welder.Disabled = false

		animator.Parent = noob
		welder.Parent = noob
			
		local parts = noob:GetChildren()
		for i = 1, #parts do
			if parts[i]:IsA("BasePart") then
				local transformer = Tool.NoobTransformer:clone()
				transformer.Disabled = false
				transformer.Parent = parts[i]
			end
		end

		noob.PersonToPester.Value = torso
		noob.Torso.Position = pos
		noob.Parent = workspace

		local angularForce = Instance.new("BodyAngularVelocity")
		angularForce.P = 100000
		angularForce.angularvelocity = Vector3.new(math.random(-100,100),math.random(-100,100),math.random(-100,100))
		angularForce.maxTorque = Vector3.new(angularForce.P,angularForce.P,angularForce.P)

		if i == 2 then
			lookAt = Vector3.new(lookAt.x + math.random(-0.1,0.1), lookAt.y,lookAt.z + math.random(-0.1,0.1))
			pos = Vector3.new(pos.x + 5,pos.y,pos.z)
		elseif i == 3 then
			lookAt = Vector3.new(lookAt.x + math.random(-0.1,0.1), lookAt.y + math.random(-0.1,0.1),lookAt.z)
			pos = Vector3.new(pos.x - 5,pos.y,pos.z)
		end
		angularForce.Parent = noob.Torso
		noob.Torso.Velocity = lookAt * 150
		noob:moveTo(pos)

		debris:AddItem(angularForce, 3)
		debris:AddItem(noob,30)

	end

end


function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent
	humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local reload = 10

	fire(script.Parent.PersonToAttack.Value, humanoid)

	wait(reload)

	enabled = true

end

function onEquipped()
	if not Handle then return end
	Handle.noobShoot:Stop()
end

function onUnequipped()
	if not Handle then return end
	Handle.noobShoot:Stop()
end


script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
