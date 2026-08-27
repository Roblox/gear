--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
ContentProvider = game:GetService("ContentProvider")
UserInputService = game:GetService("UserInputService")

InputCheck = Instance.new("ScreenGui")
InputCheck.Name = "InputCheck"
InputFrame = Instance.new("Frame")
InputFrame.BackgroundTransparency = 1
InputFrame.Size = UDim2.new(1, 0, 1, 0)
InputFrame.Parent = InputCheck

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Rate = (1 / 60)

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

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		PlayerMouse = Player:GetMouse()
		Mouse.Button1Down:connect(function()
			InvokeServer("Button1Click", {Down = true})
		end)
		Mouse.Button1Up:connect(function()
			InvokeServer("Button1Click", {Down = false})
		end)
		Mouse.KeyDown:connect(function(Key)
			InvokeServer("KeyPress", {Key = Key, Down = true})
		end)
		Mouse.KeyUp:connect(function(Key)
			InvokeServer("KeyPress", {Key = Key, Down = false})
		end)
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			InputCheckClone = InputCheck:Clone()
			if UserInputService.TouchEnabled then
				InputCheckClone = InputCheck:Clone()
				InputCheckClone.InputButton.InputBegan:connect(function()
					InvokeServer("Button1Click", {Down = true})
				end)
				InputCheckClone.InputButton.InputEnded:connect(function()
					InvokeServer("Button1Click", {Down = false})
				end)
				InputCheckClone.Parent = PlayerGui
			end
		end
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("Animation") then
				ContentProvider:Preload(v.AnimationId)
			end
		end
	end)
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	if InputCheckClone then
		Debris:AddItem(InputCheckClone, 0)
	end
	if ObjectLocalTransparencyModifier then
		ObjectLocalTransparencyModifier:disconnect()
	end
	LocalObjects = {}
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
	if not ToolEquipped or not CheckIfAlive() then
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
	elseif mode == "MousePosition" then
		return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}) or nil)
	elseif Mode == "SetLocalTransparencyModifier" and value and ToolEquipped then
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
							if ((not v.AutoUpdate and (v.Object.LocalTransparencyModifier == 1 or  v.Object.LocalTransparencyModifier == 0)) or v.AutoUpdate) then
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