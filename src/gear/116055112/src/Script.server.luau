local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local TransparentInfo = TweenInfo.new(2) 

local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle
local FireEffect = Handle.Fire

local LastMode = Random.new()

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local Animations = {
	Fire = {Animation = Tool.Animations.R6.Fire};
	Punt = {Animation = Tool.Animations.R6.Punt};
	Warchant = {Animation = Tool.Animations.R6.Warchant};
	
	R15Fire = {Animation = Tool.Animations.R15.Fire};
	R15Punt = {Animation = Tool.Animations.R15.Punt};
	R15Warchant = {Animation = Tool.Animations.R15.Warchant};	
}

function CreateWarchantSword()
	local SwordPart = Instance.new("Part")
	SwordPart.Name = "WarchantSword"
	SwordPart.TopSurface = Enum.SurfaceType.Smooth
	SwordPart.BottomSurface = Enum.SurfaceType.Smooth
	SwordPart.Size = Vector3.new(1, 0.8, 4)
	SwordPart.Anchored = true
	SwordPart.Locked = true
	SwordPart.CanCollide = false
	SwordPart.Transparency = 0.2
	
	local SwordMesh = Instance.new("SpecialMesh")
	SwordMesh.MeshType = Enum.MeshType.FileMesh
	SwordMesh.Name = "Mesh"
	SwordMesh.MeshId = "rbxasset://fonts/sword.mesh"
	SwordMesh.TextureId = "rbxasset://textures/SwordTexture.png"
	SwordMesh.Scale = Vector3.new(4, 2, 4)
	SwordMesh.Parent = SwordPart
	
	return SwordPart
end

function InvokeClient(Mode, Value)
	if Gear:IsPlayerAlive() then
		local Result = nil
		pcall(function()
			Result = Gear.ClientControls:InvokeClient(Gear.Player, Mode, Value)
		end)
		
		return Result
	end
end

function DoPunt()
	local Animation = Animations.Punt
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Punt
	end
	InvokeClient("PlayAnimation", Animation)
	wait(0.65)
	
	Handle.Transparency = 1
	Handle.CanCollide = false
	
	local Punted = Handle:Clone()
	Punted.Transparency = 0
	Debris:AddItem(Punted, 5)
	
	Punted.CFrame = Punted.CFrame + Gear.RootPart.CFrame.lookVector * 1.4
	Punted.CanCollide = true
	Punted.Velocity = (Gear.RootPart.CFrame * CFrame.Angles(0.6, 0, 0)).lookVector * 100
	Punted.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
	
	Punted.Parent = workspace

	InvokeClient("PlaySound", Handle.SOUND_Punt)	
	
	wait(1)
	local FadeInTween = TweenService:Create(Handle, TransparentInfo, {Transparency = 0})
	FadeInTween:Play()
	FadeInTween.Completed:wait()
	Handle.CanCollide = true
end

function DoWarchant()
	local Animation = Animations.Warchant
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Warchant
	end	
	local CacheWalkSpeed = Gear.Humanoid.WalkSpeed
	local HumanoidToReset = Gear.Humanoid	
	Gear.Humanoid.WalkSpeed = 0 	
	
	InvokeClient("PlayAnimation", Animation)
	InvokeClient("PlaySound", Handle.SOUND_Warchant)
	
	local ChantSword = CreateWarchantSword()
	ChantSword.Parent = workspace
	ChantSword.CFrame = Gear.RootPart.CFrame * CFrame.Angles(-math.pi * 0.5, 0, 0) * CFrame.new(0, 3, -3)
	local SwordTween = TweenService:Create(ChantSword, TweenInfo.new(3), {CFrame = Gear.RootPart.CFrame * CFrame.Angles(-math.pi * 0.5, 0, 0) * CFrame.new(0, 3, 17)})
	delay(2, function()
		local SwordFadeOutTween = TweenService:Create(ChantSword, TweenInfo.new(1), {Transparency = 1})
		SwordFadeOutTween:Play()
	end)	
	SwordTween:Play()	
	SwordTween.Completed:wait()
	if ChantSword then
		ChantSword:Destroy()
	end	
	
	if HumanoidToReset then
		HumanoidToReset.WalkSpeed = CacheWalkSpeed
	end
end

function DoOnFire()
	local Animation = Animations.Fire
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Fire
	end	
	InvokeClient("PlayAnimation", Animation)
	FireEffect.Enabled = true
	
	local Humanoid = Gear.Humanoid
	delay(0.5, function()
		if Humanoid then
			Humanoid:TakeDamage(5)
			InvokeClient("PlaySound", Handle.SOUND_Damaged)
		end
	end)
	
	delay(1, function()
		if Humanoid then
			Humanoid:TakeDamage(5)
			InvokeClient("PlaySound", Handle.SOUND_Damaged)
		end
	end)
	
	wait(1.2)
	
	FireEffect.Enabled = false
	local Dummy = Handle:Clone()
	Dummy.CanCollide =true
	Dummy.Fire.Enabled = true
	Debris:AddItem(Dummy, 5)
	Dummy.Parent = workspace
	Dummy.Velocity = Gear.RootPart.CFrame.lookVector * 20
	
	Handle.Transparency = 1
	
	wait(1)
	local FadeInTween = TweenService:Create(Handle, TransparentInfo, {Transparency = 0})
	FadeInTween:Play()
	FadeInTween.Completed:wait()
end

Gear:BindActivateFunction("ogre_activate", function()
	local NewMode = LastMode:NextInteger(1, 3)
	if NewMode == 1 then
		DoPunt()
	elseif NewMode == 2 then
		DoWarchant()
	elseif NewMode == 3 then
		DoOnFire()
	end
end)

Gear:BindUnequippedFunction("ogre_unequip", function()
	FireEffect.Enabled = false
	if Gear.Humanoid then
		Gear.Humanoid.WalkSpeed = 16
	end
	
	Handle.Transparency = 0
end)