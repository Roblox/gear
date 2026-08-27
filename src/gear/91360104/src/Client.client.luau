--Rescripted by TakeoHonorable

local Tool = script.Parent

local PlayerClick = Tool:WaitForChild("MouseClick",10)

local PlayerMouse = game:GetService("Players").LocalPlayer:GetMouse()


function Activated() --Step 1 Check on the client to help reduce latency
	local Hit = PlayerMouse.Target
	if not Hit or not Hit.Parent then return end
	local Directory = Hit.Parent
	if Directory:IsA("Accoutrement") then
		Directory = Directory.Parent
	end
	local Humanoid = Directory:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 then return end
	
	PlayerClick:FireServer(Hit)
end

Tool.Activated:Connect(Activated)



