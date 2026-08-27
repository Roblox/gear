Tool = script.Parent

function fire(v)


	local vCharacter = Tool.Parent

	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3			--moves your arm as if firing.

	local missile = Tool.Bolt:Clone()

	-- find firing direction

	local v1 = -Tool.Bolt.CFrame.lookVector.unit
	local v2 = v.unit
	

	local dot = (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z)
	local ang = math.acos(dot)

	-- test if in cone
	if (ang < 3.14 / 8) then

	else
		-- not in cone, find projection
		-- n = v1 x v2
		--local n = Vector3.new(v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z, v1.z * v2.y - v1.y * v2.x)

		--return
	end

	

	

	
	--missile.CFrame = Tool.Bolt.CFrame + (Tool.Bolt.CFrame.lookVector * -8)
	missile.CFrame = Tool.Bolt.CFrame + (v * 8)

	missile.Transparency = 0

	missile.Velocity =  v * 50

	missile.Name = "CrossbowBolt"

	missile.Elasticity = 0


	local force = Instance.new("BodyForce")

	force.force = Vector3.new(0,150,0)

	force.Parent = missile

	missile.BodyGyro.cframe = CFrame.new(Vector3.new(0,0,0), -Tool.Bolt.CFrame.lookVector.unit)
	missile.BodyGyro.maxTorque = Vector3.new(5e5,5e5,5e5)



	local new_script = script.Parent.CrossbowBoltScript:clone()

	new_script.Disabled = false

	new_script.Parent = missile



	local creator_tag = Instance.new("ObjectValue")

	creator_tag.Value = vPlayer

	creator_tag.Name = "creator"

	creator_tag.Parent = missile

	
	missile.Parent = game.Workspace



end







Tool.Enabled = true

function onActivated(v)


	if not Tool.Enabled then

		return

	end


	Tool.Enabled = false

	local character = Tool.Parent;

	local humanoid = character.Humanoid

	if humanoid == nil then

		print("Humanoid not found")

		return 

	end

	local targetPos = v

	local lookAt = (targetPos - character.Head.Position).unit

	Tool.Handle.FireSound:Play()

	fire(lookAt)

	wait(2)

	Tool.Enabled = true

end



script.Parent.Fire.OnServerEvent:connect(function(client, at)
	if client.Character == script.Parent.Parent then
		onActivated(at)
	end
end)



