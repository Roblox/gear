--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
ContentProvider = game:GetService("ContentProvider")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ToolEquipped = false

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", Value)
	elseif Mode == "StopAnimation" and Value then
		SetAnimation("StopAnimation", Value)
	elseif Mode == "Preload" and Value then
		ContentProvider:Preload(Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "DisableJump" then
		DisableJump(Value)
	elseif Mode == "SetMouseIcon" and Value then
		PlayerMouse.Icon = Value
	elseif Mode == "SetLocalTransparencyModifier" and Value and ToolEquipped then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == Value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, Value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent and ((not v.AutoUpdate and (v.Object.LocalTransparencyModifier == 1 or  v.Object.LocalTransparencyModifier == 0)) or v.AutoUpdate) then
							v.Object.LocalTransparencyModifier = v.Transparency
						end
					end
				end)
			end
		end)
	elseif Mode == "SetMouseSensitivity" and Value then
		if Value.Sensitivity == 1 then
			if MouseSensivityConnection then
				MouseSensivityConnection:disconnect()
			end
		else
			SetMouseSensitivity(Value.Sensitivity)
		end
	elseif Mode == "GetProperty" then
		local PropertyValue = nil
		pcall(function()
			PropertyValue = Value.Object[Value.Property]
		end)
		return PropertyValue
	end
end)

function InvokeServer(Mode, Value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(Mode, Value)
		return ServerReturn
	end)
end

function SetAnimation(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(Value.FadeTime, Value.Weight, Value.Speed)
	elseif Mode == "StopAnimation" and Value then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
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

function SetMouseSensitivity(Sensitivity)

	if MouseSensivityConnection then
		MouseSensivityConnection:disconnect()
	end	
	
	local function EulerAnglesYX(cframe)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:components(cframe)
		return -math.asin(R12), ((math.abs(R12) > 0.99999 and -math.atan2(-R20, R00)) or -math.atan2(-R02, R22))
	end
	
	local DirectionX, DirectionY = EulerAnglesYX(Camera.CoordinateFrame)
	
	local function UpdateSensitivity()
		local CFrameX, CFrameY = EulerAnglesYX(Camera.CoordinateFrame)
		DirectionX = (DirectionX * (1 - Sensitivity) + (CFrameX + (math.pi * 2) * math.floor((DirectionX - CFrameX) / (math.pi * 2) + 0.5)) * Sensitivity)
		DirectionY = (DirectionY * (1 - Sensitivity) + (CFrameY + (math.pi * 2) * math.floor((DirectionY - CFrameY) / (math.pi * 2) + 0.5)) * Sensitivity)
		Camera.CoordinateFrame = CFrame.Angles(0, DirectionY, 0) * CFrame.Angles(DirectionX, 0, 0) * CFrame.new(0, 0, 0.5) + Camera.Focus.p
	end
	
	MouseSensivityConnection = RunService.RenderStepped:connect(UpdateSensitivity)
	
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	Mouse.WheelForward:connect(function()
		InvokeServer("WheelMoved", {Forward = true})
	end)
	Mouse.WheelBackward:connect(function()
		InvokeServer("WheelMoved", {Forward = false})
	end)
	local animationFolder = Tool:WaitForChild("Animations")
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		animationFolder = animationFolder:WaitForChild("R15")
	else
		animationFolder = animationFolder:WaitForChild("R6")
	end
	SetAnimation("PlayAnimation", {Animation = animationFolder:WaitForChild("Equip")})
end

function Unequipped()
	ToolEquipped = false
	LocalObjects = {}
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump, MouseSensivityConnection, ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	PlayerMouse.Icon = ""
	Animations = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)