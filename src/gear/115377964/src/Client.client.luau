--Rescripted by TakeoHonorable

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

local MousePos = Tool:WaitForChild("MousePos")

local Character,Humanoid

local MouseMove,Activate
function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or Humanoid.Health <= 0 then return end
	MouseMove = game:GetService("RunService").Heartbeat:Connect(function()
		MousePos:FireServer(Mouse.Hit)
	end)
	Activate = Tool.Activated:Connect(function()--For the aid of Mobile users
		MousePos:FireServer(game.Players.LocalPlayer:GetMouse().Hit)
	end)
end

function Unequipped()
	if MouseMove then
		MouseMove:Disconnect();MouseMove = nil
	end
	if Activate then
		Activate:Disconnect();Activate = nil
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)