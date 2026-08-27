--// Made by StarWars
local Debris = game:GetService("Debris")
local InsertService = game:GetService("InsertService")
local LightningModel = InsertService:LoadAsset(787396013):GetChildren()[1]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Character = nil
local Player = nil
local Humanoid = nil

local CreatorValue = Instance.new("ObjectValue")
CreatorValue.Name = "creator"

local CarScript = Tool.CarScript

function DropCar()
	Tool.Enabled = false
	local NewCreator = CreatorValue:Clone()
	NewCreator.Value = Player
	local NewModel = LightningModel:Clone()
	NewCreator.Parent = NewModel
	NewModel:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.new(0, 0, 10))
	local NewScript = CarScript:Clone()
	NewScript.Parent = NewModel
		
	local CloneHandle = Handle:Clone()
	CloneHandle.CanCollide = true	
	CloneHandle.CFrame = Handle.CFrame
	Handle.Transparency = 1
	CloneHandle.Parent = workspace
	Debris:AddItem(CloneHandle, 0.2)
	
	wait(0.2)
	NewModel.Parent = workspace
	NewScript.Disabled = false
	Tool:Destroy()
end

function OnActivated()
	if not Player then return end
	if not Tool.Enabled then return end
	Tool.Enabled = false
	local NewCreator = CreatorValue:Clone()
	NewCreator.Value = Player
	local NewModel = LightningModel:Clone()
	NewCreator.Parent = NewModel
	NewModel:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.new(0, 0, 10))
	local NewScript = CarScript:Clone()
	NewScript.Parent = NewModel
		
	local CloneHandle = Handle:Clone()
	CloneHandle.CanCollide = true	
	CloneHandle.CFrame = Handle.CFrame
	Handle.Transparency = 1
	CloneHandle.Parent = workspace
	Debris:AddItem(CloneHandle, 0.2)
	
	wait(0.2)
	NewModel.Parent = workspace
	NewScript.Disabled = false
	Tool:Destroy()
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	DropCar()
end

function OnUnequipped()
	Character = nil
	Player = nil
	Humanoid = nil
end

Tool.Activated:Connect(OnActivated)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)