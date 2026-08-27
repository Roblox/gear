--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Slide = Tool:WaitForChild("Slide")

ClientControl = Tool:WaitForChild("ClientControl")
ServerControl = Tool:WaitForChild("ServerControl")

ServerControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "Animation" then
		if Value then
			SlideAnim = Humanoid:LoadAnimation(Slide)
			if SlideAnim then
				SlideAnim:Play()
			end
		elseif not Value then
			if SlideAnim then
				SlideAnim:Stop()
			end
		end
	else
		return Humanoid.TargetPoint
	end
end)

function Click(Down)
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	pcall(function()
		ClientControl:InvokeServer("Click", Down)
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Mouse.Button1Down:connect(function()
		Click(true)
	end)
	Mouse.Button1Up:connect(function()
		Click(false)
	end)
end

function Unequipped()
	PlayerMouse = nil
	if SlideAnim then
		SlideAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)