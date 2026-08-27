-----------------
--| Constants |--
-----------------

local COOLDOWN = 0.5 --TODO: 4 -- Seconds until Tool can be used again
local TIME_TO_LIVE = 300 -- Seconds until the pet is destroyed
local RESPAWN_TIME = 4 -- Seconds until pet can be re-summoned (only after death)

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local InsertService = Game:GetService('InsertService')
local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local AiScript = WaitForChild(script, 'CrashAi')
local OwnerTag = WaitForChild(AiScript, 'Owner')

local BaseAniScript = WaitForChild(script,'Animate')
local HealthRegenScript = WaitForChild(script,'HealthRegenerationScript')
local SoundScript = WaitForChild(script,'Sound')

local SummonSound --TODO: = WaitForChild(ToolHandle, 'Laugh1')

local AnimationScript = WaitForChild(Tool, 'PetAnimation')
local PetObject = WaitForChild(AnimationScript, 'Pet')

local MyModel = nil
local MyTorso = nil
local MyHumanoid = nil

local Pet = nil
local AnimationScriptClone = nil

local Sounds = {}
for _,i in pairs(script:GetChildren()) do
	if i:IsA('Sound') then
		table.insert(Sounds,i)
	end
end

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	MyModel = Tool.Parent
	MyTorso = MyModel:FindFirstChild('Torso')
	MyHumanoid = MyModel:FindFirstChild('Humanoid')
	OwnerTag.Value = MyModel
end


local function GenerateCrash()

	local Crash = Instance.new("Model")
	Crash.Name = "Minion"

		local LeftArm = Instance.new("Part")
		LeftArm.Anchored = false
		LeftArm.CanCollide = false
		LeftArm.TopSurface = Enum.SurfaceType.Smooth
		LeftArm.Parent = Crash
		LeftArm.Name = "Left Arm"
		LeftArm.FormFactor = 'Custom'
		LeftArm.Size = Vector3.new(0.48599997162819, 1.0, 0.48599997162819)
		LeftArm.CFrame = CFrame.new(39.526447296143, 1.8573211431503, -31.007932662964, 0.99446070194244, -0.0093411989510059, 0.1046929359436, -3.8847058903002e-009, 0.99604308605194, 0.088871710002422, -0.10510884225369, -0.088379420340061, 0.99052572250366)
		LeftArm.BottomSurface = Enum.SurfaceType.Smooth
		LeftArm.Locked = false
		LeftArm.Position = Vector3.new(39.526447296143, 1.8573211431503, -31.007932662964)

			local Mesh = Instance.new("SpecialMesh")
			Mesh.Scale = Vector3.new(1.1, 1.1, 1.1)
			Mesh.MeshId = "http://www.roblox.com/asset/?id=119448714"
			Mesh.TextureId = "http://www.roblox.com/asset/?id=119444340"
			Mesh.Parent = LeftArm
		
		local Head = Instance.new("Part")
		Head.Anchored = false
		Head.TopSurface = Enum.SurfaceType.Smooth
		Head.Parent = Crash
		Head.Name = "Head"
		Head.Transparency = 1
		Head.FormFactor = 'Custom'
		Head.Size = Vector3.new(0,0,0)--Vector3.new(0.97200006246567, 0.97200006246567, 0.97200006246567)
		Head.CFrame = CFrame.new(40.201114654541, 3.1295635700226, -31.242385864258, 0.99446070194244, 2.3461873788949e-018, 0.10510884225369, -2.5434017125882e-018, 1, 1.7422487515995e-018, -0.10510884225369, -1.999932056022e-018, 0.99446070194244)
		Head.BottomSurface = Enum.SurfaceType.Smooth
		Head.Locked = false
		Head.Position = Vector3.new(40.201114654541, 3.1295635700226, -31.242385864258)
			
			local CrashGui = Instance.new("BillboardGui")
			CrashGui.Active = false
			CrashGui.Name = "CrashGui"
			CrashGui.Parent = Head
			CrashGui.StudsOffset = Vector3.new(0, 3.5, 0)
			CrashGui.AlwaysOnTop = true
			CrashGui.Size = UDim2.new(1, 0, 1, 0)

				local CB = Instance.new("ImageLabel")
				CB.Active = false
				CB.Parent = CrashGui
				CB.Image = "http://www.roblox.com/Asset?ID=119803178"
				CB.ZIndex = 9
				CB.Size = UDim2.new(4, 0, 4, 0)
				CB.Draggable = false
				CB.ClipsDescendants = false
				CB.Transparency = 1
				CB.BackgroundTransparency = 1
				CB.Position = UDim2.new(-1.5, 0, 0, 0)
				CB.Name = "C&B"

				
			game.Debris:AddItem(CrashGui,5)

		local RightArm = Instance.new("Part")
		RightArm.Anchored = false
		RightArm.CanCollide = false
		RightArm.TopSurface = Enum.SurfaceType.Smooth
		RightArm.Parent = Crash
		RightArm.Name = "Right Arm"
		RightArm.FormFactor = 'Custom'
		RightArm.Size = Vector3.new(0.48600003123283, 1.0, 0.48600003123283)
		RightArm.CFrame = CFrame.new(40.906513214111, 1.8496809005737, -31.232267379761, 0.99446070194244, 0.0093412064015865, 0.1046929359436, -3.8847058903002e-009, 0.99604308605194, -0.088871710002422, -0.10510884225369, 0.088379420340061, 0.99052572250366)
		RightArm.BottomSurface = Enum.SurfaceType.Smooth
		RightArm.Locked = false
		RightArm.Position = Vector3.new(40.906513214111, 1.8496809005737, -31.232267379761)

			local Mesh2 = Instance.new("SpecialMesh")
			Mesh2.Scale = Vector3.new(1.1, 1.1, 1.1)
			Mesh2.MeshId = "http://www.roblox.com/asset/?id=119448556"
			Mesh2.TextureId = "http://www.roblox.com/asset/?id=119444340"
			Mesh2.Parent = RightArm
			Mesh2.MeshType = Enum.MeshType.FileMesh

			local Swoosh = Instance.new("Sound")
			Swoosh.Parent = RightArm
			Swoosh.Name = "Swoosh"
			Swoosh.Volume = 0.69999998807907
			Swoosh.SoundId = "rbxasset://sounds/swoosh.wav"
			Swoosh.Looped = false
			Swoosh.PlayOnRemove = false

		local RightLeg = Instance.new("Part")
		RightLeg.Anchored = false
		RightLeg.CanCollide = false
		RightLeg.TopSurface = Enum.SurfaceType.Smooth
		RightLeg.Parent = Crash
		RightLeg.Name = "Right Leg"
		RightLeg.FormFactor = 'Custom'
		RightLeg.Size = Vector3.new(0.6075000166893, 1.05, 0.85050004720688)
		RightLeg.CFrame = CFrame.new(40.442035675049, 0.81883311271667, -31.159261703491, 0.99446070194244, -0.0093412064015865, 0.1046929359436, 3.8847058903002e-009, 0.99604308605194, 0.088871710002422, -0.10510884225369, -0.088379420340061, 0.99052572250366)
		RightLeg.BottomSurface = Enum.SurfaceType.Smooth
		RightLeg.Locked = false
		RightLeg.Position = Vector3.new(40.442035675049, 0.81883311271667, -31.159261703491)

			local Mesh3 = Instance.new("SpecialMesh")
			Mesh3.Scale = Vector3.new(1.1, 1.1, 1.1)
			Mesh3.MeshId = "http://www.roblox.com/asset/?id=119448742"
			Mesh3.TextureId = "http://www.roblox.com/asset/?id=119444340"
			Mesh3.Parent = RightLeg
			Mesh3.MeshType = Enum.MeshType.FileMesh

		local LeftLeg = Instance.new("Part")
		LeftLeg.Anchored = false
		LeftLeg.CanCollide = false
		LeftLeg.TopSurface = Enum.SurfaceType.Smooth
		LeftLeg.Parent = Crash
		LeftLeg.Name = "Left Leg"
		LeftLeg.FormFactor = 'Custom'
		LeftLeg.Size = Vector3.new(0.6075000166893, 1.05, 0.85049992799759)
		LeftLeg.CFrame = CFrame.new(39.95832824707, 0.81884551048279, -31.227575302124, 0.99446070194244, 0.0093411989510059, 0.1046929359436, 3.8847058903002e-009, 0.99604308605194, -0.088871710002422, -0.10510884225369, 0.088379420340061, 0.99052572250366)
		LeftLeg.BottomSurface = Enum.SurfaceType.Smooth
		LeftLeg.Locked = false
		LeftLeg.Position = Vector3.new(39.95832824707, 0.81884551048279, -31.227575302124)

			local Mesh4 = Instance.new("SpecialMesh")
			Mesh4.Scale = Vector3.new(1.1, 1.1, 1.1)
			Mesh4.MeshId = "http://www.roblox.com/asset/?id=119448654"
			Mesh4.TextureId = "http://www.roblox.com/asset/?id=119444340"
			Mesh4.Parent = LeftLeg
			Mesh4.MeshType = Enum.MeshType.FileMesh

		local Sound6 = Instance.new("Script")
		Sound6.Parent = Crash
		Sound6.Name = "Sound"
		Sound6.Disabled = false


		local Torso = Instance.new("Part")
		Torso.Anchored = false
		Torso.TopSurface = Enum.SurfaceType.Smooth
		Torso.Parent = Crash
		Torso.Name = "Torso"
		Torso.FormFactor = 'Custom'
		Torso.Size = Vector3.new(1.0934998989105, 1.0, 0.72900003194809)
		Torso.CFrame = CFrame.new(40.208778381348, 2.0555002689362, -31.169893264771, 0.99446070194244, 2.3461873788949e-018, 0.10510884225369, -2.5434017125882e-018, 1, 1.7422487515995e-018, -0.10510884225369, -1.999932056022e-018, 0.99446070194244)
		Torso.BottomSurface = Enum.SurfaceType.Smooth
		Torso.Locked = false
		Torso.Position = Vector3.new(40.208778381348, 2.0555002689362, -31.169893264771)

			local Mesh1 = Instance.new("SpecialMesh")
			Mesh1.Scale = Vector3.new(1.1, 1.1, 1.1)
			Mesh1.MeshId = "http://www.roblox.com/asset/?id=119448208"
			Mesh1.TextureId = "http://www.roblox.com/asset/?id=119444340"
			Mesh1.Parent = Torso
			Mesh1.MeshType = Enum.MeshType.FileMesh

			local RightHip = Instance.new("Motor6D")
			RightHip.part1 = RightLeg
			RightHip.MaxVelocity = 0.10000000149012
			RightHip.DesiredAngle = -0.088989116251469
			RightHip.CurrentAngle = -0.088989116251469
			RightHip.Parent = Torso
			RightHip.Name = "Right Hip"
			RightHip.Part1 = RightLeg
			RightHip.C1 = CFrame.new(0, .5, 0, -4.3711388286738e-008, 0, 1, 0, 1, 0, -1, 0, -4.3711388286738e-008)
			RightHip.C0 = CFrame.new(0.23084968328476, -0.8, -0.024299010634422, -4.3711388286738e-008, 0, 1, 0, 1, 0, -1, 0, -4.3711388286738e-008)
			RightHip.Part0 = Torso

			local LeftHip = Instance.new("Motor6D")
			LeftHip.part1 = LeftLeg
			LeftHip.MaxVelocity = 0.10000000149012
			LeftHip.DesiredAngle = -0.088989116251469
			LeftHip.CurrentAngle = -0.088989116251469
			LeftHip.Parent = Torso
			LeftHip.Name = "Left Hip"
			LeftHip.Part1 = LeftLeg
			LeftHip.C1 = CFrame.new(0, 0.5, 0, -4.3711388286738e-008, 0, -1, 0, 1, 0, 1, 0, -4.3711388286738e-008)
			LeftHip.C0 = CFrame.new(-0.24299995601177, -0.8, -0.024299010634422, -4.3711388286738e-008, 0, -1, 0, 1, 0, 1, 0, -4.3711388286738e-008)
			LeftHip.Part0 = Torso

			local Neck = Instance.new("Motor6D")
			Neck.part1 = Head
			Neck.MaxVelocity = 0.10000000149012
			Neck.Parent = Torso
			Neck.Name = "Neck"
			Neck.Part1 = Head
			Neck.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, -4.3711388286738e-008, -1, 0, 1, -4.3711388286738e-008)
			Neck.C0 = CFrame.new(0, 1.0740633010864, -0.072897039353848, 1, 0, 0, 0, -4.3711388286738e-008, -1, 0, 1, -4.3711388286738e-008)
			Neck.Part0 = Torso

			local RightShoulder = Instance.new("Motor6D")
			RightShoulder.part1 = RightArm
			RightShoulder.MaxVelocity = 0.5
			RightShoulder.DesiredAngle = 0.088989116251469
			RightShoulder.CurrentAngle = 0.088989116251469
			RightShoulder.Parent = Torso
			RightShoulder.Name = "Right Shoulder"
			RightShoulder.Part1 = RightArm
			RightShoulder.C1 = CFrame.new(0, -.02, -0.025000000372529, -4.3711388286738e-008, 0, 1, 0, 1, 0, -1, 0, -4.3711388286738e-008)
			RightShoulder.C0 = CFrame.new(0.55, -0.7, .023601150140166, -4.3711388286738e-008, 0, 1, 0, 1, 0, -1, 0, -4.3711388286738e-008)
			RightShoulder.Part0 = Torso

			local LeftShoulder = Instance.new("Motor6D")
			LeftShoulder.part1 = LeftArm
			LeftShoulder.MaxVelocity = 0.5
			LeftShoulder.DesiredAngle = 0.088989116251469
			LeftShoulder.CurrentAngle = 0.088989116251469
			LeftShoulder.Parent = Torso
			LeftShoulder.Name = "Left Shoulder"
			LeftShoulder.Part1 = LeftArm
			LeftShoulder.C1 = CFrame.new(0, -.02, -0.025000000372529, -4.3711388286738e-008, 0, -1, 0, 1, 0, 1, 0, -4.3711388286738e-008)
			LeftShoulder.C0 = CFrame.new(-0.55, -0.7, 0.027249908074737, -4.3711388286738e-008, 0, -1, 0, 1, 0, 1, 0, -4.3711388286738e-008)
			LeftShoulder.Part0 = Torso
			
	for _,i in pairs(Sounds) do
		local tsound = i:Clone()
		tsound.Parent = Torso
	end

	return Crash

end

local function Summon()
	if not MyTorso or not MyHumanoid then return end

	

	Pet = GenerateCrash()

	if Pet then
		DebrisService:AddItem(Pet, TIME_TO_LIVE) -- Make sure it will get deleted

		local humanoid = Instance.new('Humanoid')
		humanoid.MaxHealth = 1000
		humanoid.Health = 1000
		humanoid.WalkSpeed = 16
		humanoid.Parent = Pet
		
		local nanimate = BaseAniScript:Clone()
		nanimate.Parent = Pet
		nanimate.Disabled = false	
		
		Pet.Parent = Workspace
		ToolHandle.Transparency = 1.0

		local torso = WaitForChild(Pet, 'Torso')
		torso.Anchored = false

		-- Play the summoning sound
		if SummonSound then SummonSound:Play() end

		-- Send pet object to AnimationScript
		PetObject.Value = Pet

		-- Clone AnimationScript to MyModel
		local animationScriptClone = AnimationScript:Clone()
		AnimationScriptClone = animationScriptClone
		DebrisService:AddItem(animationScriptClone, TIME_TO_LIVE)
		animationScriptClone.Parent = MyModel
		animationScriptClone.Disabled = false

		-- Clone AiScript to Pet
		local aiScriptClone = AiScript:Clone()
		aiScriptClone.Parent = Pet
		aiScriptClone.Disabled = false

		-- On Pet death, clean up and show the handle
		humanoid.Died:connect(function()
			if AnimationScriptClone then AnimationScriptClone:Destroy() end
			DebrisService:AddItem(Pet, RESPAWN_TIME)
			wait(RESPAWN_TIME)
			ToolHandle.Transparency = 0.0
		end)

		-- After TIME_TO_LIVE, show the handle
		coroutine.resume(coroutine.create(function()
			wait(TIME_TO_LIVE + 0.1)
			if not Pet:FindFirstChild('Humanoid') then
				ToolHandle.Transparency = 0.0
			end
		end))

		-- Health has problems being set directly
		Delay(5, function() if humanoid then humanoid:TakeDamage(-900) end end)
		--[[Spawn(function()
			while Pet and humanoid do
				humanoid.MaxHealth = 1000
				humanoid.Health = 1000
				wait(1)
			end
		end)]]

		Pet:MoveTo(MyTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
	end
end

local function OnActivated()
	if not Tool.Enabled or not MyTorso or not MyHumanoid then return end

	Tool.Enabled = false

	if not Pet or not Pet.Parent then
		Summon()
	end

	-- Raycast to click location for ClickTarget setting
	local target = MyHumanoid.TargetPoint
	local direction = (target - MyTorso.Position).unit
	local hit = Game.Workspace:FindPartOnRay(Ray.new(MyTorso.Position, direction * 150), MyModel)
	if hit and Pet and Pet:FindFirstChild('ClickTarget') then
		local clickedHumanoid = hit.Parent:FindFirstChild('Humanoid')
		if clickedHumanoid and clickedHumanoid.Health > 0 then
			if Pet.ClickTarget.Value == clickedHumanoid then
				Pet.ClickTarget.Value = nil -- Ensures a changed event
			end
			Pet.ClickTarget.Value = clickedHumanoid
			wait(COOLDOWN) -- Only wait if they clicked a valid target
		else
			Pet.ClickTarget.Value = nil
		end
	end

	Tool.Enabled = true
end

local function OnUnequipped()
	if Pet then Pet:Destroy() end
	if SummonSound then SummonSound:Stop() end
	if AnimationScriptClone then AnimationScriptClone:Destroy() end
	ToolHandle.Transparency = 0.0
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)
