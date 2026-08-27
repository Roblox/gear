--[[Super Util]]--
function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do  wait(1/30) end
	return parent[child]
end

function MakeValue(class,name,value,parent)
	local temp = Instance.new(class)
	temp.Name = name
	temp.Value = value
	temp.Parent = parent
	return temp
end	

--[[Constants]]--

local Tool = script.Parent
local LeftMesh = WaitForChild(script,'Mesh')
local LeftC0 = WaitForChild(script,'C0')
--[[Workspace Variables]]--

--[[Script Variables]]--

--[[Script Functions]]--
function OnEquip()
	Spawn(function()
		local char = Tool.Parent
		local leftArm = char:FindFirstChild('Left Arm')
		if not leftArm then return end
		leftPart = Instance.new('Part')
		leftPart.Size = Vector3.new(.2,.2,.2)
		leftPart.Name = 'leftHandle'
		local tmesh = LeftMesh:Clone()
		tmesh.Parent = leftPart
		local tweld = Instance.new('Weld')
		tweld.Part0 = leftArm
		tweld.Part1 = leftPart
		tweld.C0 = LeftC0.Value
		tweld.Parent = leftPart
		leftPart.Parent = Tool
	end)
end

function OnUnequip() --Fix implemented by Luckymaxer
	local char = Tool.Parent
	if leftPart and leftPart.Parent then
		leftPart:Destroy()
	end
	
end

--[[Running Logic]]--

Tool.Equipped:connect(OnEquip)

Tool.Unequipped:connect(OnUnequip)
