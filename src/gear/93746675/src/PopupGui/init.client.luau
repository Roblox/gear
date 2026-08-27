-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local PlayersService = Game:GetService('Players')
local MyPlayer = PlayersService.LocalPlayer

local Tool = script.Parent

local ScreenGui = WaitForChild(script, 'ScreenGui')
local ClonedFrame = nil

local NeverEquipped = true

local function OnEquipped(mouse)
	if NeverEquipped then
		NeverEquipped = false

		local guiClone = ScreenGui:Clone()
		guiClone.Parent = MyPlayer.PlayerGui

		ClonedFrame = WaitForChild(guiClone, 'Frame')
	end
end

local function OnActivated()
	ClonedFrame.Visible = false
end

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
