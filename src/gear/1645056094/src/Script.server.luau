local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local DOWN_VECTOR = Vector3.new(0, -1, 0)
local ASSET_ID = 1587361744
local PlantModel = InsertService:LoadAsset(ASSET_ID):GetChildren()[1]

local Tool = script.Parent
local Handle = Tool.Handle
Handle.Transparency = 1

local Player = nil
local Character = nil
local Humanoid = nil

local CurrentPlant = nil

function CreatePlant()
	if not Humanoid or not Humanoid.RootPart then return end 

	if CurrentPlant then 
		CurrentPlant:Destroy()
	end
	CurrentPlant = nil
	
	local NewPlant =  PlantModel:Clone()
	
	local CreatorObject = Instance.new("ObjectValue")
	CreatorObject.Name = "Creator"
	CreatorObject.Value = Player	
	CreatorObject.Parent = NewPlant	
	
	local SpawnPosition = Humanoid.RootPart.CFrame * CFrame.new(0, 0, -5)
	local NewRay = Ray.new(SpawnPosition.p, DOWN_VECTOR * 5)
	
	local Hit, Endpoint = workspace:FindPartOnRayWithIgnoreList(NewRay, {Character})
	if Hit then
		print("?")
		CurrentPlant = NewPlant
		CurrentPlant:SetPrimaryPartCFrame(CFrame.new(Endpoint, Vector3.new(Humanoid.RootPart.CFrame.X, Endpoint.Y, Humanoid.RootPart.CFrame.Z)))
		CurrentPlant:MakeJoints()
		CurrentPlant.Parent = workspace
	else
		NewPlant:Destroy()		
	end	
end

Tool.Equipped:Connect(function()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not CurrentPlant and Humanoid and Humanoid.Health > 0 then
		CreatePlant()
	end	
end)

Tool.Unequipped:Connect(function()
	Character = nil
	Player = nil
	Humanoid = nil
	
	if CurrentPlant then
		CurrentPlant:Destroy()
	end
	
	CurrentPlant = nil
end)