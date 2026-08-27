-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local Tool = script.Parent
Tool.RequiresHandle = false

local IMAGE_SIZE = UDim2.new(0,100,0,100)

if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

local Rhino = InsertService:LoadAsset(1214987177)
Rhino = Rhino:GetChildren()[1]:Clone()

local CurrentRhino = nil
local Character = nil

local function createUi(adornee)
	local hub = Instance.new("ScreenGui")
	local ui = Instance.new("BillboardGui")
	ui.Parent = hub
	ui.Size = IMAGE_SIZE
	ui.StudsOffset = Vector3.new(0,3,0)
	ui.Adornee = adornee
	ui.AlwaysOnTop = true
	local image = Instance.new("ImageLabel")
	image.Parent = ui
	image.Size = UDim2.new(1,0,1,0)
	image.Image = "rbxassetid://1213254909"
	image.BackgroundTransparency = 1
	game:GetService("Debris"):AddItem(hub,5)
	return hub
end

function OnEquipped()
	Character = Tool.Parent
	CurrentRhino = Rhino:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentRhino
	
	local rhinoHead = CurrentRhino["Head"] or nil
	if rhinoHead then
		local ui = createUi(rhinoHead)
		ui.Parent = rhinoHead
	end
	
	CurrentRhino.Name = Character.Name .. "'s_Rhino"
	CurrentRhino.Parent = workspace
	CurrentRhino:MakeJoints()
	CurrentRhino:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(10, 0, 12)).p)
end

function OnUnequip()
	if CurrentRhino then 
		CurrentRhino:Destroy()
	end
	
	CurrentRhino = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)