local Tool = script.Parent
local Handle = Tool.Handle

local Pom = Handle:Clone()
Pom.Name = "LeftPom"

local Character = nil
local LeftGripAttachment = nil 
local LeftPom = nil

local ToolEquipped = false

local function WeldPom()
	if LeftPom then
		LeftPom:Destroy()
	end
	
	LeftPom = Pom:Clone()
	LeftPom.Parent = Tool
	
	local Motor6D = Instance.new("Motor6D")
	Motor6D.Part0 = LeftGripAttachment.Parent
	Motor6D.Part1 = LeftPom
	Motor6D.C0 = CFrame.new()
	Motor6D.C1 = CFrame.new(LeftGripAttachment.Position)
	Motor6D.Parent = LeftGripAttachment.Parent
end

function Equipped()
	if ToolEquipped then return end 
	ToolEquipped = true
	Character = Tool.Parent
	local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
	LeftGripAttachment = LeftArm:FindFirstChild("LeftGripAttachment")
	WeldPom()
end

function Unequipped()
	Character = nil
	LeftGripAttachment = nil
	ToolEquipped = false
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)