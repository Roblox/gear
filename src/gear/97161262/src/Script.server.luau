-- //Completely redone for R15 avatars and FE by StarWars
local RunService = game:GetChildren('RunService')
local RbxUtility = LoadLibrary("RbxUtility")
local Create = RbxUtility.Create

local Tool = script.Parent
local AnimationsFolder = Tool:WaitForChild('Animations')

local Remotes = Tool:WaitForChild("Remotes")
local ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
local ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

local AnimationsBin = Tool:WaitForChild('Animations')
local AnimationObjects = {
	FlyJets = {Animation = AnimationsBin:WaitForChild("FlyJets"), FadeTime = 0.5, Weight = nil, Speed = 1, Duration = nil},
	R15FlyJets = {Animation = AnimationsBin:WaitForChild("R15FlyJets"), FadeTime = 0.5, Weight = nil, Speed = 1, Duration = nil},
	JumpJets = {Animation = AnimationsBin:WaitForChild("JumpJets"), FadeTime = 0.5, Weight = nil, Speed = 2, Duration = nil},
	R15JumpJets = {Animation = AnimationsBin:WaitForChild("R15JumpJets"), FadeTime = 0.5, Weight = nil, Speed = 2, Duration = nil},
	LandingJets = {Animation = AnimationsBin:WaitForChild("LandingJets"), FadeTime = 0.5, Weight = nil, Speed = 1, Duration = nil},	
	R15LandingJets = {Animation = AnimationsBin:WaitForChild("R15LandingJets"), FadeTime = 0.5, Weight = nil, Speed = 1, Duration = nil},
}

local SoundPowerdown = Tool.Handle:FindFirstChild('SoundPowerdown')
local SoundAccelerate = Tool.Handle:FindFirstChild('SoundAccelerate')
local SoundThrust = Tool.Handle:FindFirstChild('SoundThrust')

local FuelValue = Tool:FindFirstChild('Fuel') or Create('DoubleConstrainedValue'){
	Name = 'Fuel';
	MaxValue = 1;
	MinValue = 0;
	Value = 0;
	Parent = Tool;
}

local Player = nil
local Character = nil
local Head = nil
local HumanoidRootPart = nil
local Humanoid = nil
local Equipped = false

local Rate = 1/30
local Speed = 40
local MaxJetTime = 2.5
local Down = false
local TurningOff = false
local On = false

local Effect = Tool.Effect:Clone()

local BodyVelocity = Create('BodyVelocity'){
	Name = "FlightVelocity";
	P = 10e4;
	Velocity = Vector3.new(0, 0, 0);
	MaxForce = Vector3.new(0, 0, 0);
	Parent = Tool.Handle;
}

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and HumanoidRootPart and HumanoidRootPart.Parent and Player and Player.Parent) and true) or false)
end

local function Off()
	if not On then return end
	if not Character then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end
	if not TurningOff then
		TurningOff = true
		if Humanoid and Humanoid.Health > 0 then
			InvokeClient("Off")
			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", AnimationObjects.R15LandingJets)
				InvokeClient("StopAnimation", AnimationObjects.R15FlyJets)
			else
				InvokeClient("PlayAnimation", AnimationObjects.LandingJets)
				InvokeClient("StopAnimation", AnimationObjects.FlyJets)
			end
			Tool.Handle.Fire.Enabled = false
			local FindEffect = Character:FindFirstChild('Effect')
			if FindEffect then
				FindEffect.Fire.Enabled = false
			end
			if SoundPowerdown then
				SoundPowerdown:Play()
			end
			if SoundAccelerate then
				SoundAccelerate:Stop()
			end
			if SoundThrust then
				SoundThrust:Stop()
			end
		end
		wait(0.5)
		if BodyVelocity then
			BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
		end
		On = false
		Down = false

		TurningOff = false
	end
end

local function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Head = Character:FindFirstChild('Head')
	HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
	Humanoid = Character:FindFirstChild('Humanoid')
	local FindEffect = Character:FindFirstChild('Effect')
	if not FindEffect then
		local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
		local LeftGrip = LeftArm and LeftArm:FindFirstChild('LeftGripAttachment')
		FindEffect = Effect:Clone()
		if LeftGrip then
			local Weld = Create('Weld'){
				Part0 = LeftGrip.Parent;
				Part1 = FindEffect.LeftGripAttachment.Parent;
				C0 = LeftGrip.CFrame;
				C1 = FindEffect.LeftGripAttachment.CFrame;
				Parent = FindEffect;
			}
		else
			--// Must be R6				
			local Weld = Create('Weld'){
				Part0 = LeftArm;
				Part1 = FindEffect;
				C0 = CFrame.new(0, -1, 0) * CFrame.Angles(-math.pi * 0.5, 0, math.pi * 0.5);
				Parent = FindEffect;
			}
		end
		FindEffect.Parent = Character
	end
	
	if BodyVelocity then
		BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
	end
	Equipped = true
	Down = false
end

local function OnMouseButtonDown()
	if Down then return end
	Down = true
	if SoundPowerdown then
		SoundPowerdown:Stop()
	end
	if Character then
		if Humanoid and Humanoid.Health > 0 then
			if SoundAccelerate then
				SoundAccelerate:Play()
			end
			InvokeClient("On")
			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", AnimationObjects.R15JumpJets)
				InvokeClient("PlayAnimation", AnimationObjects.R15FlyJets)
			else
				InvokeClient("PlayAnimation", AnimationObjects.JumpJets)
				InvokeClient("PlayAnimation", AnimationObjects.FlyJets)
			end
			if SoundThrust then
				SoundThrust:Play()
			end
			Tool.Handle.Fire.Enabled = true
			local FindEffect = Character:FindFirstChild('Effect')
			if FindEffect then
				FindEffect.Fire.Enabled = true
			end
			Humanoid.Jump = true
		end
	end
	On = true
	local Fuel = 1
	FuelValue.Value = Fuel
	spawn(function()
		while Down do
			local Delta = wait(Rate)
			if BodyVelocity then
				BodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10e6
				if Character and HumanoidRootPart then
					BodyVelocity.Velocity = (HumanoidRootPart.CFrame.lookVector * Speed) + Vector3.new(0, 3, 0)
				end
				
				Fuel = math.max(0, Fuel - (Delta / MaxJetTime))
				FuelValue.Value = Fuel
				if Fuel <= 0 then
					spawn(Off)
					break
				end
			end
		end
	end)
	
	wait(0.5)
	if not Down then
		Off()
	end
end

local function OnMouseButtonUp()
	Down = false
	Off()
end

local function OnUnequipped()
	Down = false
	if Character then
		local Effect = Character:FindFirstChild('Effect')
		if Effect then
			Effect:Destroy()
		end
	end	
	Off()
	
	if BodyVelocity then
		BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
	end	

	Character = nil
	HumanoidRootPart = nil
	Humanoid = nil
end

function InvokeClient(mode, value)
	local ClientReturn = nil 
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, mode, value)
	end)
	
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not Equipped or not value or not CheckIfAlive() then
		return
	end
	
	if mode == 'MouseDown' then
		if value.Down then
			OnMouseButtonDown()
		else
			OnMouseButtonUp()
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)