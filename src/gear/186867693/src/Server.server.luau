--Updated for R15 avatars by StarWars
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Light = Handle:WaitForChild("Light")
local Remote = Tool:WaitForChild("Remote")

local Weld
local Motor
local MotorPart0
local MotorPart1

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function setPointDirection(position)
	local char = Tool.Parent
	if not char then return end
	local Torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	local RightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
	local RightShoulder = RightArm:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")
	
	if not Weld then
		Motor = RightShoulder:Clone()
		MotorPart0 = Torso
		MotorPart1 = RightArm
		
		Weld = Instance.new("Weld")
		Weld.Part0 = Torso
		Weld.Part1 = RightArm
		Weld.C0 = CFrame.new(1, 1, 0)
		Weld.Parent = Weld.Part0
	end
	
	local jointPosition = Weld.Part0.CFrame:toWorldSpace(CFrame.new(1, 0.5, 0))
	local cframe = CFrame.new(jointPosition.p, position) * CFrame.Angles(math.pi/2, 0, 0) * CFrame.new(0, -1, 0)
	Weld.C0 = Weld.Part0.CFrame:toObjectSpace(cframe)
end

function toggleLight()
	Light.Enabled = not Light.Enabled
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "UpdateDirection" then
		setPointDirection(...)
	elseif func == "ToggleLight" then
		toggleLight()
	end
end

function onUnequipped()
	if Weld then
		Weld:Destroy()
		Weld = nil
	end
	
	if Motor then
		Motor.Part0 = MotorPart0
		Motor.Part1 = MotorPart1
		Motor.Parent = MotorPart0
		Motor = nil
	end
end

Remote.OnServerEvent:connect(onRemote)
Tool.Unequipped:connect(onUnequipped)