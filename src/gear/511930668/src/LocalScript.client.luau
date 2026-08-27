--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

InputCheck = Instance.new("ScreenGui")
InputCheck.Name = "InputCheck"
InputFrame = Instance.new("Frame")
InputFrame.Name = "InputButton"
InputFrame.BackgroundTransparency = 1
InputFrame.Size = UDim2.new(1, 0, 1, 0)
InputFrame.Parent = InputCheck

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

FrameRate = (1 / 20)

Animations = {}
LocalObjects = {}

Anims = {
	Sit = {Animation = Tool:WaitForChild("Sit"), FadeTime = nil, Weight = nil, Speed = nil},
}

ToolEquipped = false

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(Animations, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	end
end

function DisableJump(Boolean)
	if PreventJump then
		PreventJump:disconnect()
	end
	if Boolean then
		PreventJump = Humanoid.Changed:connect(function(Property)
			if Property ==  "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function KeyPressed(Key, Down)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Mouse.Button1Down:connect(function()
		MouseDown = true
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
	Mouse.KeyDown:connect(function(Key)
		KeyPressed(Key, true)
	end)
	Mouse.KeyUp:connect(function(Key)
		KeyPressed(Key, false)
	end)
	MouseDown = false
	ToolEquipped = true
	if Jumping then
		Jumping:disconnect()
	end
	SetAnimation("PlayAnimation", Anims.Sit)
	DisableJump(true)
	Humanoid.WalkSpeed = 0
	Humanoid.AutoRotate = false
	Spawn(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			InputCheckClone = InputCheck:Clone()
			if UserInputService.TouchEnabled then
				InputCheckClone = InputCheck:Clone()
				InputCheckClone.InputButton.InputBegan:connect(function()
					MouseDown = true
				end)
				InputCheckClone.InputButton.InputEnded:connect(function()
					MouseDown = false
				end)
				InputCheckClone.Parent = PlayerGui
			end
		end
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		BodyGyro = Create("BodyGyro"){
			D = 500,
			P = 1000000,
			maxTorque = Vector3.new(math.huge, math.huge, math.huge),
			cframe = RootPart.CFrame,
			Parent = RootPart,
		}
		BodyPosition = Create("BodyPosition"){
			D = 1250,
			P = 10000,
			maxForce = Vector3.new(math.huge, math.huge, math.huge),
			position = BodyGyro.CFrame.p,
			Parent = RootPart,
		}
		local Delta = 0
		local BroomGoTo = nil
		while ToolEquipped and CheckIfAlive() and CurrentlyEquipped and Mouse do
			if MouseDown then
				local Now = tick()
				local Speed = ((MouseDown and 20) or 0)
				local DeltaSpeed = (Speed * (Delta / FrameRate))
				if BroomGoTo then
					local BroomGoToWorld = (Handle.Position + BroomGoTo)
					BodyGyro.cframe = CFrame.new(RootPart.Position, BroomGoToWorld)
				end
				BodyPosition.position = (Handle.Position + BodyGyro.CFrame.lookVector * Speed)
				BroomGoTo = (Mouse.Hit.p - RootPart.Position)
			end
			wait(FrameRate)
		end
	end)
end

function Unequipped()
	MouseDown = false
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.AutoRotate = true
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	if InputCheckClone then
		Debris:AddItem(InputCheckClone, 0)
	end
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump, ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs({BodyGyro, BodyPosition}) do
		if v and v.Parent then
			Debris:AddItem(v, 0)
		end
	end
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not mode then
		return
	end
	if mode == "PlayAnimation" then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "DisableJump" then
		DisableJump(value)
	elseif mode == "SetLocalTransparencyModifier" and value and ToolEquipped then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent then
							local CurrentTransparency = v.Object.LocalTransparencyModifier
							if ((not v.AutoUpdate and (CurrentTransparency == 1 or  CurrentTransparency == 0)) or v.AutoUpdate) then
								v.Object.LocalTransparencyModifier = v.Transparency
							end
						else
							table.remove(LocalObjects, i)
						end
					end
				end)
			end
		end)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)