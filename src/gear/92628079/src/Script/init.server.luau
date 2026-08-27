--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")
Shield = Tool:WaitForChild("Shield")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 30
StunBonus = 8

Meshes = {
	Blade = "http://www.roblox.com/asset/?id=92541982",
	Sword = "http://www.roblox.com/asset/?id=92542050",
	SwordAndBlade = "http://www.roblox.com/asset/?id=92542016"
}

Animations = {
	ShieldBash = Tool:WaitForChild("ShieldBash"),
	ShieldWalk = Tool:WaitForChild("ShieldWalk"),
	Equip = Tool:WaitForChild("Equip"),
	Slash = Tool:WaitForChild("Slash")
}

Sounds = {
	BashHit = Handle:WaitForChild("BashHit"),
	BashMiss = Handle:WaitForChild("BashMiss"),
	PowerUp = Handle:WaitForChild("PowerUp"),
	Slash = Handle:WaitForChild("Slash"),
	Sprint = Handle:WaitForChild("Sprint"),
	SwordDraw = Handle:WaitForChild("SwordDraw"),
	SwordHit = Handle:WaitForChild("SwordHit")
}

StunScript = script:WaitForChild("StunScript")

ShieldWeld = Instance.new("Weld")
ShieldWeld.Name = "ShieldWeld"
ShieldWeld.Part0 = Shield
ShieldWeld.Part1 = Handle
ShieldWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
ShieldWeld.C1 = CFrame.new(0.400000572, 1.68563652, 0.280401707, 0, 0, -0.99999994, 0.50000912, -0.866020083, 0, -0.866020083, -0.50000912, 0)

UnequippedWeldCopy = ShieldWeld:Clone()

MouseRightDownTime = tick()

BashedPlayers = {}
SlashedPlayers = {}

Swinging = false
Bashing = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player then
		return
	end
	if Mode == "Button1" then
		Activated()
	elseif Mode == "Button2" then
		if Value.Down then
			MouseRightDownTime = tick()
		else
			ShieldBash(Value.TargetPoint)
		end
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
end

function AbleToAttack()
	return Player and Character and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CreateStunnedGui(player, character)
	if not player or not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local bg = Instance.new("BillboardGui")
	bg.Parent = character.Head
	bg.Adornee = character.Head
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.StudsOffset = Vector3.new(0, 2.5, 0)
	 
	local frame = Instance.new("Frame")
	frame.Parent = bg
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	 
	local text = Instance.new("TextLabel")
	text.Parent = frame
	text.Position = UDim2.new(0.25, 0, 0.25, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.TextColor3 = Color3.new(1, (39 / 255), (20 / 255))
	text.TextStrokeColor3 = Color3.new(1, (225 / 255), (73 / 255))
	text.TextStrokeTransparency = 0
	text.BackgroundTransparency = 1
	text.Text = "Stunned!"
	text.FontSize = Enum.FontSize.Size18
	Debris:AddItem(bg, 2)
end

function ShieldBashBlow(Hit)
	if not Hit or not Hit.Parent or not AbleToAttack() then
		return
	end
	if Bashing then
		local HitParent = Hit.Parent
		local humanoid = HitParent:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 and HitParent ~= Character and not BashedPlayers[HitParent] then
			BashedPlayers[HitParent] = true
			local torso = HitParent:FindFirstChild("Torso")
			if torso and Torso and Torso.Parent then				
				local bashForce = Instance.new('BodyVelocity')
				bashForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
				if Torso.Velocity.magnitude > 0.1 then
					bashForce.velocity = Torso.Velocity.unit * 100
				else
				 	bashForce.velocity = (torso.CFrame.p - Torso.CFrame.p).unit * 100
				end
				bashForce.Parent = torso
				Debris:AddItem(bashForce, 0.07)
				local ChargeVelocity = Torso:FindFirstChild("ChargeVelocity")
				if ChargeVelocity then
					ChargeVelocity:Destroy()
					Torso.Velocity = Vector3.new()
				end
				CreateStunnedGui(Players:GetPlayerFromCharacter(HitParent), HitParent)
				CreateStunnedGui(Player, HitParent)
			end
			if not HitParent:FindFirstChild(StunScript.Name) then
				local stun = StunScript:Clone()
				stun.Disabled = false
				stun.Parent = HitParent
			end
			InvokeClient("PlaySound", Sounds.BashHit)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			wait(0.1)
			if Humanoid then
				Humanoid.PlatformStand = false
			end
		end
	end
end

function SwordAttackBlow(Hit)
	if not Hit or not Hit.Parent or not AbleToAttack() then
		return
	end
	local HitParent = Hit.Parent
	if Swinging then
		local humanoid = HitParent:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 and  HitParent ~= Character and not SlashedPlayers[HitParent] then
			SlashedPlayers[HitParent] = true
			TagHumanoid(humanoid, Player)
			InvokeClient("PlaySound", Sounds.SwordHit)
			humanoid:TakeDamage(Damage)
			if HitParent:FindFirstChild("StunScript") then
				humanoid:TakeDamage(StunBonus)
			end
		end
	end
end

function ShieldBash(TargetPoint)
	if tick() - MouseRightDownTime > 0.2 then
		return
	end
	if Bashing or (UnequippedWeld and UnequippedWeld.Parent)or not AbleToAttack() then
		return
	end
	Bashing = true
	BashedPlayers = {}
	InvokeClient("PlaySound", Sounds.Sprint)
	if Torso and Torso.Parent then
		local chargeForce = Instance.new("BodyVelocity")
		chargeForce.Name = "ChargeVelocity"
		chargeForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
		chargeForce.velocity = (TargetPoint * Vector3.new(1, 0, 1) - Torso.CFrame.p * Vector3.new(1, 0, 1)).unit * 150
		chargeForce.Parent = Torso
		Debris:AddItem(chargeForce, 0.15)
		Torso.CFrame = CFrame.new(Torso.CFrame.p, Torso.CFrame.p + chargeForce.velocity)
		local gyro = Instance.new("BodyGyro")
		gyro.Parent = Torso
		Debris:AddItem(gyro, 0.3)
	end
	wait(0.1)
	InvokeClient("PlayAnimation", {Animation = Animations.ShieldBash, Speed = nil})
	InvokeClient("PlaySound", Sounds.BashMiss)
	wait(1.2)
	Bashing = false
end

function PhaseInBlade()
	if BladeHolder then
		return
	end
	BladeHolder = Handle:Clone()
	for i, v in pairs(BladeHolder:GetChildren()) do
		v:Destroy()
	end
	BladeHolder.Name = "Blade"
	local theMesh = Instance.new("SpecialMesh")
	theMesh.MeshId = Meshes.Blade
	theMesh.Parent = BladeHolder
	theMesh.TextureId = "http://www.roblox.com/asset/?id=92537877"
	theMesh.Scale = Vector3.new(0.7,0,0.7)
	BladeHolder.Parent = Tool
	local theWeld = Instance.new("Weld")
	theWeld.Part0 = BladeHolder
	theWeld.Part1 = Handle
	theWeld.C0 = CFrame.new() + Vector3.new(0, -0.92, 0.09)
	theWeld.Parent = BladeHolder
	InvokeClient("PlaySound", Sounds.PowerUp)
	Spawn(function()
		for i = 1, 14 do
			if BladeHolder and theMesh then
				theMesh.Scale = theMesh.Scale + Vector3.new(0, 0.05, 0)
			end
			wait(0.03)
		end
	end)
end

function CreateArmWeld()
	if not AbleToAttack() then
		return
	end
	LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end
	if not WeldedToArm then
		WeldedToArm = LeftArm.ChildRemoved:connect(function(Child)
			if Child.Name == "ArmWeld" then
				CreateArmWeld()
			end
		end)
	end
	ArmShieldWeld = Instance.new("Weld")
	ArmShieldWeld.Name = "ArmWeld"
	ArmShieldWeld.Part0 = LeftArm
	ArmShieldWeld.Part1 = Shield
	ArmShieldWeld.C0 = CFrame.new() * CFrame.Angles(math.rad(-90), math.rad(90), 0)
	ArmShieldWeld.C1 = CFrame.new() + Vector3.new(0, 0, 0.6)
	ArmShieldWeld.Parent = LeftArm
end

function CreateBackWeld()
	if Torso and Shield then
		for i, v in pairs(Torso:GetChildren()) do
			if v:IsA("JointInstance") and v.Name == "BackWeld" then
				v:Destroy()
			end
		end
		BackWeld = Instance.new("Weld")
		BackWeld.Name = "BackWeld"
		BackWeld.Part0 = Torso
		BackWeld.Part1 = Shield
		BackWeld.C0 = CFrame.new() * CFrame.Angles(0, math.rad(180), 0)
		BackWeld.C1 = CFrame.new() + Vector3.new(0, 0, 1.2)
		BackWeld.Parent = Torso
	end
end

function DestroyRightGrip()
	local RightArm = Character:FindFirstChild("Right Arm")
	if RightArm then
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if RightGrip then
			RightGripCopy = RightGrip:Clone()
			RightGrip:Destroy()
		end
		RightGripRemoval = RightArm.ChildAdded:connect(function(Child)
			if Child:IsA("JointInstance") and Child.Name == "RightGrip" then
				RightGripCopy = RightGrip:Clone()
				Debris:AddItem(RightGrip, 0.1)
			end
		end)
	end
end

function Activated()
	if Swinging or not AbleToAttack() then
		return
	end
	local DontWait = false
	if UnequippedWeld and UnequippedWeld.Parent then
		DontWait = true
		InvokeClient("PlayAnimation", {Animation = Animations.ShieldWalk, Speed = nil})
		if UnequippedWeld then
			UnequippedWeld:Destroy()
		end
		for i, v in pairs(Shield:GetChildren()) do
			if v:IsA("JointInstance") and v.Name == "ShieldWeld" then
				v:Destroy()
			end
		end
		InvokeClient("PlaySound", Sounds.SwordDraw)
		if BackWeld and BackWeld.Parent then
			BackWeld:Destroy()
		end
		PhaseInBlade()
	else
		InvokeClient("PlayAnimation", {Animation = Animations.Slash, Speed = nil})
	end
	CreateArmWeld()
	if RightGripCopy then
		local RightArm = Character:FindFirstChild("Right Arm")
		if RightArm then
			RightGripCopy.Parent = RightArm
		end
	end
	SlashedPlayers = {}
	Swinging = true
	if not DontWait then
		wait(0.8)
	end

	Swinging = false
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not AbleToAttack() then
		return
	end
	ShieldBlowConnection = Shield.Touched:connect(ShieldBashBlow)
	SwordBlowConnection = Handle.Touched:connect(SwordAttackBlow)
	DestroyRightGrip()
	CreateBackWeld()
	if UnequippedWeldCopy then
		if UnequippedWeld then
			UnequippedWeld:Destroy()
		end
		UnequippedWeld = UnequippedWeldCopy:Clone()
		UnequippedWeld.Parent = Shield
	end
end

function Unequipped()
	for i, v in pairs({ShieldBlowConnection, SwordBlowConnection, WeldedToArm, RightGripRemoval}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs({UnequippedWeld, BladeHolder, BackWeld, ArmShieldWeld, RightGripCopy}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if RightArm then
		for i, v in pairs(RightArm:GetChildren()) do
			if v:IsA("JointInstance") and v.Name == "RightGrip" then
				v:Destroy()
			end
		end
	end
	BladeHolder = nil
	if Shield then
		Shield.CanCollide = true
	end
	for i, v in pairs({AnimTrack, ShieldWalk}) do
		if v then
			v:Stop()
		end
	end
	if not UnequippedWeld.Parent then
		UnequippedWeld = UnequippedWeldCopy:Clone()
	end
	UnequippedWeld.Parent = Shield
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)