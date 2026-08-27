-- // Created by StarWars
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Tool = script.Parent
local Remotes = Tool:WaitForChild("Remotes")
local AnimationsFolder = Tool:WaitForChild("Animations")
local ServerControls = Remotes:WaitForChild("ServerControls")

local Camera = workspace.CurrentCamera

local InputBegan = nil
local InputEnded = nil

local ToolEquipped = false
local Flying = false

local Character = nil
local Humanoid = nil

local ZERO_VECTOR = Vector3.new(0, 0, 0)
local DOWN_VECTOR = Vector3.new(0, -1, 0)
local XZ_VECTOR = Vector3.new(1, 0, 1)

local Animations = {
	Flying = {Animation = AnimationsFolder:WaitForChild("R6"):WaitForChild("Flying"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

local AnimationTracks = {}

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(AnimationTracks, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(AnimationTracks, i)
			end
		end
	end
end

function CastRay(start, direction, length, ignore)
	ignore = ignore or {}
	length = length or 999
	local NewRay = Ray.new(start, direction * length)
	
	return workspace:FindPartOnRayWithIgnoreList(NewRay, ignore)
end

function GetTotalMass(character)
	local TotalMass = 0
	for _, part in next, character:GetDescendants() do
		if typeof(part) == 'Instance' and part:IsA("BasePart") then
			TotalMass = TotalMass + part:GetMass()
		end
	end
	
	return TotalMass
end

function CreateJetpackBodyForce()
	local Jetpack = Character:FindFirstChild("Jetpack")
	if not Jetpack then return end 
	
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.P = GetTotalMass(Character) * workspace.Gravity * 2
	BodyVelocity.MaxForce = ZERO_VECTOR
	BodyVelocity.Velocity = ZERO_VECTOR
	BodyVelocity.Parent = Humanoid.RootPart
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.MaxTorque = ZERO_VECTOR
	BodyGyro.D = 50
	BodyGyro.P = 10000
	BodyGyro.Parent = Humanoid.RootPart
	
	if Humanoid and Humanoid.Health > 0 then
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

Tool.Equipped:Connect(function()
	if ToolEquipped then return end 
	ToolEquipped = true
	
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end 
	
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations = {
			Flying = {Animation = AnimationsFolder:WaitForChild("R15"):WaitForChild("Flying"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
		}		
	else
		Animations = {
			Flying = {Animation = AnimationsFolder:WaitForChild("R6"):WaitForChild("Flying"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
		}		
	end
	
	InputBegan = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Flying = true
			Humanoid.Jump = true
			CreateJetpackBodyForce()
			ServerControls:InvokeServer("MouseDown")
			SetAnimation("PlayAnimation", Animations.Flying)
		end
	end)
	
	InputEnded = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Flying = false
			local BodyVelocity = Humanoid and Humanoid.RootPart and Humanoid.RootPart:FindFirstChildOfClass("BodyVelocity")
			local BodyGyro = Humanoid and Humanoid.RootPart and Humanoid.RootPart:FindFirstChildOfClass("BodyGyro")
			if BodyVelocity then
				BodyVelocity:Destroy()
			end
			if BodyGyro then
				BodyGyro:Destroy()
			end
			ServerControls:InvokeServer("MouseUp")
			SetAnimation("StopAnimation", Animations.Flying)
		end
	end)
	
	RunService:BindToRenderStep("jetpack_flying", Enum.RenderPriority.Input.Value + 1, function(delta)
		if not Character then return end 
		local Jetpack = Character:FindFirstChild("Jetpack")
		
		if not Flying or not Jetpack or Jetpack.Parent == nil or not Humanoid or not Humanoid.RootPart then return end
		
		local BodyVelocity = Humanoid.RootPart:FindFirstChildOfClass("BodyVelocity")
		local BodyGyro = Humanoid.RootPart:FindFirstChildOfClass("BodyGyro")
		
		if not BodyGyro or not BodyVelocity then return end
		
		local CameraCFrame = Camera.CFrame
		local Hit, Endpoint = CastRay(Humanoid.RootPart.Position, DOWN_VECTOR, Humanoid.RootPart.Size.Y * 15, {Character}) 

		if not Hit then
			BodyVelocity.MaxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
			
			local RootCFrame = Humanoid.RootPart.CFrame
			local Direction = RootCFrame.lookVector * XZ_VECTOR
			local FlightDirection = Camera.CFrame.lookVector
			FlightDirection = FlightDirection * XZ_VECTOR
			
			local FlightCFrame = CFrame.new(Humanoid.RootPart.Position, (Humanoid.RootPart.CFrame + FlightDirection * 2).p) * CFrame.Angles(-(math.pi * 0.5), math.pi * 2, 0)
			BodyVelocity.Velocity = CameraCFrame.lookVector * 75
			if tostring(FlightCFrame.p.X) ~= "-1.#IND" and FlightCFrame.p.Y ~= "-1.#IND" and FlightCFrame.p.Z ~= "-1.#IND" then
				BodyGyro.cframe = FlightCFrame
			end
		else
			BodyVelocity.MaxForce = Vector3.new(0, BodyVelocity.P, 0)
			
			BodyVelocity.Velocity = (CameraCFrame.lookVector.Unit * Vector3.new(0, 1, 0)) * 50
			BodyGyro.CFrame = CameraCFrame
		end
	end)
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 
	
	ToolEquipped = false
	
	if InputBegan then
		InputBegan:Disconnect()
	end
	
	if InputEnded then
		InputEnded:Disconnect()
	end
	
	Character = nil
	Humanoid = nil
	
	InputBegan = nil
	InputEnded = nil
	
	RunService:UnbindFromRenderStep("jetpack_flying")
	SetAnimation("StopAnimation", Animations.Flying)
end)