--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

EpicKatanaModel = InsertService:LoadAsset(246270069)
EpicKatana = EpicKatanaModel:GetChildren()[1]:Clone()
Debris:AddItem(EpicKatanaModel, 1)

KatanaGiven = false
Connections = {}

Katanas = {18776718, 18017365, 25545089, 21294489, 22787168, 20577851}

KatanaModels = {}
for i, v in pairs(Katanas) do
	local KatanaModel = InsertService:LoadAsset(v)
	local Katana = KatanaModel:GetChildren()[1]:Clone()
	Debris:AddItem(KatanaModel, 1)
	table.insert(KatanaModels, Katana)
end

function CheckForKatanas(Locations)
	local KatanasFound = {}
	if not CheckIfAlive() or KatanaGiven then
		return {}
	end
	local InCharacter = false
	for i, v in pairs(KatanaModels) do
		local Katana
		for ii, vv in pairs(Locations) do
			if not Katana then
				Katana = vv:FindFirstChild(v.Name)
				if Katana then
					if vv == Character then
						InCharacter = true
					end
					table.insert(KatanasFound, Katana)
				end
			end
		end
	end
	if not InCharacter then
		return {}
	end
	if #KatanasFound < #Katanas then
		return {}
	end
	return KatanasFound
end

function GetEpicKatana(Backpack, Locations)
	if not Backpack or not Locations or KatanaGiven then
		return
	end
	local KatanasAvailable = CheckForKatanas(Locations)
	if #KatanasAvailable == #KatanaModels then
		KatanaGiven = true
		local EpicKatanaClone = EpicKatana:Clone()
		EpicKatanaClone.Parent = Backpack
		Humanoid:UnequipTools()
		Humanoid:EquipTool(EpicKatanaClone)
		for i, v in pairs(KatanasAvailable) do
			if v and v.Parent then
				Debris:AddItem(v, 0)
				v:Destroy()
			end
			Debris:AddItem(Tool, 0)
			Tool:Destroy()
		end
	end
end

function MonitorForEpicKatana()
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	local Backpack = Player:FindFirstChild("Backpack")
	if not Backpack then
		return
	end
	local Locations = {Character, Backpack}
	local Connections = {}
	for i, v in pairs(Locations) do
		local ChildAdded = v.ChildAdded:connect(function()
			GetEpicKatana(Backpack, Locations)
		end)
		table.insert(Connections, ChildAdded)
	end
	GetEpicKatana(Backpack, Locations)
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function ManageEquip()
	if Tool.Parent and Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) then
		Character = ((Tool.Parent:IsA("Backpack") and Tool.Parent.Parent.Character) or (Players:GetPlayerFromCharacter(Tool.Parent) and Players:GetPlayerFromCharacter(Tool.Parent)))
		Player = Players:GetPlayerFromCharacter(Character)
		Humanoid = Character:FindFirstChild("Humanoid")
		if not CheckIfAlive() then
			return
		end
		ToolEquipped = true
		MonitorForEpicKatana()
	else
		for i, v in pairs(Connections) do
			if v then
				v:disconnect()
			end
		end
		Connections = {}
		ToolEquipped = false
	end
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		ManageEquip()
	end
end)

ManageEquip()