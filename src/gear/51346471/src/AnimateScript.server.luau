local Tool = script.Parent
local Kodachi = Tool:WaitForChild("Handle")

local vCharacter
local walkAnim
local slashAnim

local stabAnim

local HiddenBlade


local lastKeyDown = 0
local dashTime = 0
local lastSlash = 0

local myHumanoid
local dualSlashSound

swordActive = Tool:WaitForChild("SwordActive")
hiddenBladeActive = Tool:WaitForChild("HiddenBladeActive")
batto = Tool:WaitForChild("Batto")

-- game service
local r = game:GetService("RunService")

local damage = 20

function blow(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
		leftArm = vCharacter:FindFirstChild("Left Arm") or vCharacter:FindFirstChild('LeftHand')
		if rightArm then 
			leftGrip = leftArm:FindFirstChild("LeftGrip1")
			if leftGrip and (leftGrip.Part0 == HiddenBlade or leftGrip.Part1 == HiddenBlade) then 
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid then 
		tag = humanoid:FindFirstChild("creator")
		if tag then tag:Remove() end
	end
end

function initiateHiddenBlade(key)
	key = key:lower()-- print('onkey',key=='q',key=='w')
	if key == "q" then		
		vChar = Tool.Parent
		myHumanoid = vChar:FindFirstChild("Humanoid")
		if myHumanoid == nil then 
		--	print("Humanoid not found")		
			return
		end
		
		if hiddenBladeActive.Value == 0 and swordActive.Value == 1 then 			
			--initiateCloneAnim = myHumanoid:LoadAnimation(Tool.initiateCloneAnim)
			--initiateCloneAnim:Play(0, 1.0, 1.0)
			wait(0.4)

			HiddenBlade = Instance.new("Part")
			HiddenBlade.Name = "Sword"
			HiddenBlade.FormFactor = 3
			HiddenBlade.Shape = "Block"
			HiddenBlade.Size = Vector3.new(0.45, 3, 0.42)
			HiddenBlade.CanCollide = false

			leftSwordMesh = Instance.new("SpecialMesh")
			leftSwordMesh.Parent = HiddenBlade
			leftSwordMesh.MeshId = "http://www.roblox.com/asset/?id=51286923"
			leftSwordMesh.TextureId = "http://www.roblox.com/asset/?id=51237309"
			leftSwordMesh.Scale = Vector3.new(0.6, 0.6, 0.6)

			HiddenBlade.Parent = vChar	

			leftArm = vChar:FindFirstChild("Left Arm") or vChar:FindFirstChild('LeftHand')
			
			if Tool.Parent:FindFirstChild("Humanoid") ~= nil then
				leftGrip = leftArm:FindFirstChild("LeftGrip")
				if leftGrip then Kodachi.Transparency = 1.0 end
				local leftWeld = Instance.new("Weld")
				leftWeld.Name = "LeftGrip1"
				leftWeld.Parent = leftArm
				leftWeld.Part0 = leftArm
				leftWeld.Part1 = HiddenBlade
				if myHumanoid then
					if myHumanoid.RigType == Enum.HumanoidRigType.R6 then
						leftWeld.C1 = (CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(-math.pi/2, 0.0, math.pi/2)) + Vector3.new(-1, 2.5, 0)
					elseif myHumanoid.RigType == Enum.HumanoidRigType.R15 then
						leftWeld.C1 = (CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(-math.pi/2, 0.0, math.pi/2)) + Vector3.new(-0.2, 2.5, 0)
					end
				end						
				--leftWeld.C1 = (CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(-math.pi/2, 0, math.pi/2)) + Vector3.new(-1, 2.5, 0)
				hiddenBladeActive.Value = 1
				connection = HiddenBlade.Touched:connect(blow)
				myHumanoid.WalkSpeed = 18
			end	
		end
	end
	if key == "w" then 
		t = r.Stepped:wait()
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t
	end
end

function onActivatedLocal()
	vCharacter = Tool.Parent

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end

	rightArm = vCharacter:FindFirstChild("Right Arm")
	if rightArm == nil then 
		return 	
	end
	rightGrip = rightArm:FindFirstChild("RightGrip")
	rightGrip=rightArm:WaitForChild("RightGrip")
--	print("FOUND GRIP")
	if slashAnim then slashAnim:Stop() end
	if batto.Value == 0.0 then
	--	print("Playing Battojutsu")
		if myHumanoid then
			if myHumanoid.RigType == Enum.HumanoidRigType.R6 then
				stabAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
			elseif myHumanoid.RigType == Enum.HumanoidRigType.R15 then
				stabAnim = myHumanoid:LoadAnimation(Tool.R15SlashAnim)				
			end
		end
		
		if stabAnim then stabAnim:Play() end
	elseif hiddenBladeActive.Value == 0.0 then
		if myHumanoid then
			if myHumanoid.RigType == Enum.HumanoidRigType.R6 then
				stabAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
			elseif myHumanoid.RigType == Enum.HumanoidRigType.R15 then
				stabAnim = myHumanoid:LoadAnimation(Tool.R15SlashAnim)				
			end
		end
		if stabAnim then stabAnim:Play() 	end
	else
		if myHumanoid then
			if myHumanoid.RigType == Enum.HumanoidRigType.R6 then
				dualSlashAnim = myHumanoid:LoadAnimation(Tool.DualSlash)
			elseif myHumanoid.RigType == Enum.HumanoidRigType.R15 then
				dualSlashAnim = myHumanoid:LoadAnimation(Tool.R15DualSlash)				
			end
		end
		
		if dualSlashAnim then dualSlashAnim:Play() end
		dualSlashSound = Tool:FindFirstChild("DualSlashSound")
		if dualSlashSound then dualSlashSound:Play() end
	end
	
	
	while Tool.Enabled == false do
		wait()
	end
end
function onEquippedLocal()
	vCharacter = Tool.Parent
	if vCharacter then
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
--		if myHumanoid then 
--			walkAnim = myHumanoid:LoadAnimation(Tool:WaitForChild("KodachiWalk"))
--			walkAnim:Play()
--		end
	end
end

Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'KeyDown' then
			local key = ...
			
			initiateHiddenBlade(key)
		end
	end
end)

function onUnequippedLocal()
	if walkAnim then walkAnim:Stop() end
	if stabAnim then stabAnim:Stop() end
	if slashAnim then slashAnim:Stop() end
	if dualSlashAnim then dualSlashAnim:Stop() end

	if hiddenBladeActive then hiddenBladeActive.Value = 0 end

	if HiddenBlade then HiddenBlade:Remove() end
	--if leftGrip1 then leftGrip1:Remove() end
	if vCharacter then myHumanoid = vCharacter:findFirstChild("Humanoid") 
		if myHumanoid then myHumanoid.WalkSpeed = 16.0	end
	end
	if dualSlashSound then dualSlashSound:Stop() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

Tool.Activated:connect(onActivatedLocal)