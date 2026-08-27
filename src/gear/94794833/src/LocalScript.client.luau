--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
StarterGui = game:GetService("StarterGui")
ContentProvider = game:GetService("ContentProvider")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}
InteractiveConnections = {}

Directions = {
	Left = false,
	Right = false,
	Up = false,
	Down = false,
	Forward = false,
	Backward = false
}

Equipped = false

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" and Humanoid then
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
	elseif Mode == "RequestCamera" and Value then
		local PropertyValue = nil
		pcall(function()
			PropertyValue = Camera[Value]
		end)
		return PropertyValue
	elseif Mode == "SetCamera" and Value then
		local Success = false
		pcall(function()
			Camera[Value.Property] = Value.Value
			Success = true
		end)
		return Success
	elseif Mode == "SetCoreGuiEnabled" and Value then
		StarterGui:SetCoreGuiEnabled(Value.Enum, Value.Boolean)
	elseif Mode == "FunctionBat" and Value then
		Spawn(function()
			FunctionBat(Value)
		end)
	end
end)

function InvokeServer(Mode, Value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(Mode, Value)
	end)
	return ServerReturn
end

function KeyPress(Value)
	local Key = Value.Key
	local Down = Value.Down
	if Key == "w" or Key == "" then
		Directions.Forward = Down
	elseif Key == "s" or Key == "" then
		Directions.Backward = Down
	elseif Key == "a" or Key == "" then
		Directions.Left = Down
	elseif Key == "d" or Key == "" then
		Directions.Right = Down
	elseif Key == "e" then
		Directions.Up = Down
	elseif Key == "q" then
		Directions.Down = Down
	elseif Key == " " and Down then
		local CheckEquipped = InvokeServer("CheckEquipped")
		if CheckEquipped then
			InvokeServer("Transform")
		end
	end
end

function FunctionBat(BatBody)
	if not BatBody then
		return
	end
	local Consistency = 0.0001
	local BatMoveFactor = 1.8
	local TargetPoint = Vector3.new(0, 0, 0)
	TargetPoint = Torso.Position
	while BatBody and BatBody.Parent and BatBody.Parent.Parent == Character and Humanoid and Humanoid.Parent and Humanoid.Health > 0 do
		local CoordinateFrame = Camera.CoordinateFrame
		local CameraLookVector = CoordinateFrame.lookVector
		local BatCFrame = CFrame.new(Torso.Position, Torso.Position + CameraLookVector)
		local ForwardVector = BatCFrame.lookVector
		local UpVector = BatCFrame:vectorToWorldSpace(Vector3.new(0, 1, 0))
		local RightVector = ForwardVector:Cross(UpVector)
		local MoveVector = Vector3.new(0, 0, 0)
		if Directions.Forward then
			MoveVector = (MoveVector + ForwardVector)
		end
		if Directions.Backward then
			MoveVector = (MoveVector - ForwardVector)
		end
		if Directions.Left then
			MoveVector = (MoveVector - RightVector)
		end
		if Directions.Right then
			MoveVector = (MoveVector + RightVector)
		end
		if Directions.Up then
			MoveVector = (MoveVector + UpVector)
		end
		if Directions.Down then
			MoveVector = (MoveVector - UpVector)
		end
		TargetPoint = (TargetPoint + (MoveVector * BatMoveFactor))
		local thit, tpos, tnorm = workspace:FindPartOnRay(
			Ray.new(
				Torso.Position,
				TargetPoint - Torso.Position
			),
			Character
		)
		TargetPoint = tpos
		BatCFrame = BatCFrame - Torso.Position + Torso.Position:Lerp(TargetPoint, 0.25)
		Torso.CFrame = BatCFrame
		Spawn(function()
			local TemporaryTorso = Character:FindFirstChild("Torso")
			InvokeServer("CFramePart", {Part = TemporaryTorso, CFrame = BatCFrame})
		end)
		wait(Consistency)
	end
	for i, v in pairs(Directions) do
		Directions[i] = false
	end
	if not Equipped then
		for i, v in pairs(InteractiveConnections) do
			if v then
				v:disconnect()
			end
		end
		InteractiveConnections = {}
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

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(InteractiveConnections) do
		if v then
			v:disconnect()
		end
	end
	InteractiveConnections = {}
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("Button1Click", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("Button1Click", {Down = false})
	end)
	Mouse.Button2Down:connect(function()
		InvokeServer("Button2Click", {Down = true})
	end)
	Mouse.Button2Up:connect(function()
		InvokeServer("Button2Click", {Down = false})
	end)
	local KeyDown = PlayerMouse.KeyDown:connect(function(Key)
		KeyPress({Key = Key, Down = true})
	end)
	local KeyUp = PlayerMouse.KeyUp:connect(function(Key)
		KeyPress({Key = Key, Down = false})
	end)
	for i, v in pairs({KeyDown, KeyUp}) do
		table.insert(InteractiveConnections, v)
	end
	Equipped = true
	
	if game:GetService'UserInputService'.TouchEnabled then
		game:GetService'UserInputService'.JumpRequest:connect(function()
			local CheckEquipped = InvokeServer("CheckEquipped")
			if CheckEquipped then
				InvokeServer("Transform")
			end
		end)
	end
end

function Unequipped()
	Equipped = false
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	if PreventJump then
		PreventJump:disconnect()
	end
	Animations = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)