--Much efficient way to hide the backpack without causing lag

local StarterGui = game:GetService("StarterGui")

local PlayerCamera = workspace.CurrentCamera

local rService = game:GetService("RunService")

for _,accessory in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
	if accessory and accessory:IsA("BasePart") then
		accessory.Transparency = 1
	end
end

repeat
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Head") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		PlayerCamera.CameraType = Enum.CameraType.Scriptable
		PlayerCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Head")
		PlayerCamera.CFrame = CFrame.new(game.Players.LocalPlayer.Character:FindFirstChild("Head").CFrame.p)*(game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame-game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
	end
	rService.RenderStepped:Wait()
until not script or not StarterGui
