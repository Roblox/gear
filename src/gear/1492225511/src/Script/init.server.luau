-- // Created by StarWars
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local GearService = require(1075123174)

local BASE_URL = "rbxassetid://"
local THROW_SPEED = 50
local BASE_DAMAGE = 10
local TIME_OUT = 30
local RELOAD_TIME = 1

local BasePart = Instance.new("Part")
BasePart.Anchored = false
BasePart.CanCollide = false
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)

local BaseQuiver = BasePart:Clone()
BaseQuiver.Name = "Quiver"

local BaseBlot = BasePart:Clone()
BaseBlot.Name = "Bolt"
BaseBlot.Anchored = true

local BaseMesh = Instance.new("SpecialMesh")

local BaseLightningParticle = script.ParticleEmitter

local BaseQuiverMesh = BaseMesh:Clone()
BaseQuiverMesh.TextureId = BASE_URL .. 1450707336
BaseQuiverMesh.MeshId = BASE_URL .. 1450702804
BaseQuiverMesh.Offset = Vector3.new(-0.5, 1, 0.2)
BaseQuiverMesh.Parent = BaseQuiver

local BaseBoltMesh = BaseMesh:Clone()
BaseBoltMesh.TextureId = BASE_URL .. 1450707601
BaseBoltMesh.MeshId = BASE_URL .. 1450702331
BaseBoltMesh.Parent = BaseBlot

local Tool = script.Parent
Tool.RequiresHandle = false

local Handle = Tool:FindFirstChild("Handle")
if Handle then
	Handle:Destroy()
end

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local FlyingBolts = {}

local Animations = {
	BoltThrow = {Animation = Tool.Animations.R6.Throw},
	R15BoltThrow = {Animation = Tool.Animations.R15.Throw}
}

local CurrentQuiver = nil

function InvokeClient(Mode, Value)
	local Result = nil
	pcall(function()
		Result = Gear.ClientControls:InvokeClient(Gear.Player, Mode, Value)
	end)
	
	return Result
end

function EquipQuiver()
	if Gear:IsPlayerAlive() then
		CurrentQuiver = BaseQuiver:Clone()
		
		local BodyBackAttachment = Gear.Character:FindFirstChild("BodyBackAttachment", true)
		if BodyBackAttachment then
			CurrentQuiver.Parent = Gear.Character
			local NewMotor = Instance.new("Motor6D")
			NewMotor.Name = "QuiverJoint"
			NewMotor.Part0 = CurrentQuiver
			NewMotor.Part1 = BodyBackAttachment.Parent
			NewMotor.C1 = BodyBackAttachment.CFrame
			NewMotor.Parent = CurrentQuiver
		end	
	end
end

function ThrowBolt()
	local MouseData = InvokeClient("GetMouseData")
	
	if MouseData then
		local Animation = Animations.BoltThrow
		if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15BoltThrow
		end
		InvokeClient("PlayAnimation", Animation)
		wait(0.25)
		local NewBolt = BaseBlot:Clone()
		local Direction = (MouseData.Position - Gear.RootPart.CFrame.p).Unit
		local StartCFrame = Gear.RootPart.CFrame * CFrame.new(1.5, 0, -2)
		local Velocity = Direction * THROW_SPEED
		
		FlyingBolts[NewBolt] = {Position = CFrame.new(StartCFrame.p, StartCFrame.p + Direction), Velocity = Velocity, Direction = Direction, Part = NewBolt, StartTime = tick()}
		NewBolt.CFrame = CFrame.new(StartCFrame.p, StartCFrame.p + Direction)
		NewBolt.Parent = workspace
	end
end

Gear:BindEquippedFunction("blot_equipped", EquipQuiver)

Gear:BindUnequippedFunction("blot_unequipped", function()
	if CurrentQuiver then
		CurrentQuiver:Destroy()
	end
	
	CurrentQuiver = nil
end)

Gear:BindActivateFunction("blot_activate", function()
	ThrowBolt()
	
	wait(RELOAD_TIME)
end)

RunService.Heartbeat:Connect(function(Step)
	local Now = tick()
	
	for Key, Bolt in next, FlyingBolts do
		local StepVector = Bolt.Velocity * Step
		local NewPoint = Bolt.Position.p + StepVector
		local NewRay = Ray.new(Bolt.Position.p, (Bolt.Position.p - NewPoint).Unit)
		
		local Orientation = Bolt.Position - Bolt.Position.p
		Bolt.Part.CFrame = CFrame.new(NewPoint) * Orientation		 
		
		local Hit, Endpoint = workspace:FindPartOnRayWithIgnoreList(NewRay, {Gear.Character})
		if Hit and Hit.Parent then
			local ParentTo = Hit.Parent
			if ParentTo:IsA("Tool") or ParentTo:IsA("Accessory") then
				ParentTo = ParentTo.Parent
			end
			
			local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
			if HitHumanoid then
				local CacheSpeed = HitHumanoid.WalkSpeed
				HitHumanoid:TakeDamage(BASE_DAMAGE)
				
				local NewParticle = BaseLightningParticle:Clone()
				NewParticle.Parent = HitHumanoid.RootPart
				NewParticle.Enabled = true	
				HitHumanoid.WalkSpeed = 0
				delay(3, function()
					if HitHumanoid then
						HitHumanoid.WalkSpeed = CacheSpeed
					end
				end)
				
				Debris:AddItem(NewParticle, 3)			
			end

			Bolt.Part:Destroy()
			FlyingBolts[Key] = nil
		elseif Now - Bolt.StartTime >= TIME_OUT then
			Bolt.Part:Destroy()
			FlyingBolts[Key] = nil
		elseif Bolt.Position.Y < workspace.FallenPartsDestroyHeight then
			Bolt.Part:Destroy()
			FlyingBolts[Key] = nil
		end
		
		Bolt.Position = CFrame.new(NewPoint) * Orientation
	end
end)