--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")

InputCheck = Instance.new("ScreenGui")
InputCheck.Name = "InputCheck"
InputButton = Instance.new("Frame")
InputButton.Name = "InputMonitor"
InputButton.BackgroundTransparency = 1
InputButton.Size = UDim2.new(1, 0, 1, 0)
InputButton.Parent = InputCheck

Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

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
				v.AnimationTrack:Stop(value.FadeTime)
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
		PreventJump = Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
			Humanoid.Jump = false
		end)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Mouse
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	Mouse.Button1Down:connect(function()
		InvokeServer("Button1Click", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("Button1Click", {Down = false})
	end)
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		if UserInputService.TouchEnabled then
			InputCheckClone = InputCheck:Clone()
			InputCheckClone.InputMonitor.InputBegan:connect(function()
				InvokeServer("Button1Click", {Down = true})
			end)
			InputCheckClone.InputMonitor.InputEnded:connect(function()
				InvokeServer("Button1Click", {Down = false})
			end)
			InputCheckClone.Parent = PlayerGui
		end
	end
end

function Unequipped()
	ToolEquipped = false
	if InputCheckClone and InputCheckClone.Parent then
		InputCheckClone:Destroy()
	end
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs(LocalObjects) do
		if v.Object then
			v.Object.LocalTransparencyModifier = 0
		end
	end
	for i, v in pairs({PreventJump, ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	Animations = {}
	LocalObjects = {}
end

function InvokeServer(mode, value)
	local ServerReturn
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not mode then
		return
	end
	if mode == "PlayAnimation" and value then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MouseData" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	elseif mode == "DisableJump" then
		DisableJump(value)
	elseif mode == "SetLocalTransparencyModifier" and value then
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
					local Camera = game:GetService("Workspace").CurrentCamera
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent then
							local CurrentTransparency = v.Object.LocalTransparencyModifier
							local ViewDistance = (Camera.CoordinateFrame.p - Head.Position).Magnitude
							if ((not v.AutoUpdate and (CurrentTransparency == 1 or CurrentTransparency == 0)) or v.AutoUpdate) then
								if ((v.Distance and ViewDistance <= v.Distance) or not v.Distance) then
									v.Object.LocalTransparencyModifier = v.Transparency
								else
									v.Object.LocalTransparencyModifier = 0
								end
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