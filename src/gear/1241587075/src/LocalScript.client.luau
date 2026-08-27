--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
UserInputService = game:GetService("UserInputService")

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

ToolEquipped = false

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
	Mouse.Button1Down:connect(function()
		InvokeServer("Mouse1", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("Mouse1", {Down = false})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("Key", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("Key", {Key = Key, Down = false})
	end)
	if Jumping then
		Jumping:disconnect()
	end
	Jumping = Humanoid.Jumping:connect(function()
		InvokeServer("Dismount", {Dismount = true})
	end)
	Spawn(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			InputCheckClone = InputCheck:Clone()
			if UserInputService.TouchEnabled then
				InputCheckClone = InputCheck:Clone()
				InputCheckClone.InputButton.InputBegan:connect(function()
					InvokeServer("Mouse1", {Down = true})
				end)
				InputCheckClone.InputButton.InputEnded:connect(function()
					InvokeServer("Mouse1", {Down = false})
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
		while ToolEquipped and CheckIfAlive() and CurrentlyEquipped do
			if Mouse then
				InvokeServer("MouseUpdate", Mouse.Hit)
			end
			wait(FrameRate)
		end
	end)
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	if InputCheckClone then
		Debris:AddItem(InputCheckClone, 0)
	end
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
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)