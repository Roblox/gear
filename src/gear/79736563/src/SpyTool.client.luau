local spyTool = script.Parent
local spyHandle = spyTool.Handle
local vChar
local Torso, Head
local RightArm
local Weld 
local equipAnim

while GUI == nil do
	wait()
	GUI = spyTool:FindFirstChild("ScreenGui")
end

function onEquipped(mouse)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	vChar = spyTool.Parent
	Torso = vChar:FindFirstChild("Torso")
	Head = vChar:FindFirstChild("Head")
	RightArm = vChar:FindFirstChild("Right Arm")
	local Humanoid = vChar:FindFirstChild("Humanoid")
	while RightArm:FindFirstChild("RightGrip") == nil do
		wait()
	end
	Weld = RightArm:FindFirstChild("RightGrip")
	Weld.Part0 = Head
	Weld.Part1 = spyHandle
	wait()
	Weld.C0 = CFrame.new(-0.810000002, 0.75, -0.150000006, 0.866025388, 0, 0.5, -0.5, 0, 0.866025388, 0, -1, 0)
	Weld.C1 = CFrame.new(-1, 0, 0, 1, 0, 0, 0, -4.37113883e-008, 1, 0, -1, -4.37113883e-008)

	local cam = game.Workspace.CurrentCamera
	mouse.Button1Down:connect(function() getPlayer(mouse) end)
	
	equipAnim = Humanoid:LoadAnimation(spyTool.CheckEye)
	equipAnim:Play()

end

function onUnequipped()
	local player = game.Players.LocalPlayer
	if player ~= nil then
		local char = player.Character
		if char ~= nil and char:FindFirstChild("Humanoid") ~= nil then
			game.Workspace.CurrentCamera.CameraSubject = char.Humanoid
			game.Workspace.CurrentCamera.FieldOfView = 70.000000488294
		end
	end
	equipAnim:Stop()
	GUI.Parent = spyTool
end

function getPlayer(mouse)
	local notfound = true
	local theCam = game.Workspace.CurrentCamera
	if mouse.Target ~= nil then 
		local target = mouse.Target
		local head = target.Parent:FindFirstChild("Head")
		local human = target.Parent:FindFirstChild("Humanoid")
		if spyTool.Parent ~= target.Parent then
			if head ~= nil and human ~= nil then
				theCam.CameraSubject = human
				theCam.FieldOfView = 80
				if spyTool:FindFirstChild("Sound") then
					spyTool.Sound:Play()
				end
				notfound = false
				local player = game.Players.LocalPlayer
				if player ~= nil then
					GUI.Parent = player.PlayerGui
				end
			end
		end
	end
	if notfound then 
		local player = game.Players.LocalPlayer
		if player ~= nil then
			local char = player.Character
			if char ~= nil and char:FindFirstChild("Humanoid") ~= nil then
				theCam.CameraSubject = char.Humanoid
				theCam.FieldOfView = 70.000000488294
				GUI.Parent = spyTool
			end
		end
	end
end

spyTool.Equipped:connect(onEquipped)
spyTool.Unequipped:connect(onUnequipped)