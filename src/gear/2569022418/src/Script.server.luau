-- Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local gear = GearService:BindGear(tool, "LaserGun")
gear.Class:SetColors({Color3.fromRGB(103, 241, 29)})

local leftHandle = handle:Clone()
do
	local attachment = leftHandle:FindFirstChild("RightGripAttachment")
	if attachment then
		attachment.Name = "LeftGripAttachment"
	end
end

local activeLeft

local barrels = {}
local side = 0

function weldAttachments(attach1, attach2)
    local weld = Instance.new("Weld")
    weld.Part0 = attach1.Parent
    weld.Part1 = attach2.Parent
    weld.C0 = attach1.CFrame
    weld.C1 = attach2.CFrame
    weld.Parent = attach1.Parent
    return weld
end

local function buildWeld(weldName, parent, part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Name = weldName
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = parent
    return weld
end

local function findFirstMatchingAttachment(model, name)
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("Attachment") and child.Name == name then
            return child
        elseif not child:IsA("Accoutrement") and not child:IsA("Tool") then -- Don't look in hats or tools in the character
            local foundAttachment = findFirstMatchingAttachment(child, name)
            if foundAttachment then
                return foundAttachment
            end
        end
    end
end

tool.Activated:Connect(function()
	if tool.Enabled and gear:IsPlayerAlive() then
		side = (side + 1) % 2
		gear.Class.Barrel = barrels[side + 1]
	end
end)

tool.Equipped:Connect(function()
	barrels = {}
	
	local attachment = handle:FindFirstChild("Barrel")
	if attachment then
		table.insert(barrels, attachment)
	end
	
	activeLeft = leftHandle:Clone()
	attachment = activeLeft:FindFirstChild("Barrel")
	if attachment then
		table.insert(barrels, attachment)
	end	
	
	local leftGrip = findFirstMatchingAttachment(tool.Parent, "LeftGripAttachment")
	local leftHandleGrip = activeLeft:FindFirstChild("LeftGripAttachment")
	
	activeLeft.Parent = tool
	
	if leftGrip and leftHandleGrip then
		weldAttachments(leftHandleGrip, leftGrip)
	end
end)

tool.Unequipped:Connect(function()
	barrels = {}
	if activeLeft then
		activeLeft:Destroy()
	end
	
	activeLeft = nil
end)