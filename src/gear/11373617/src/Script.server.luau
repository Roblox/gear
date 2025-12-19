--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

HatModel = InsertService:LoadAsset(9910420)
Hat = HatModel:GetChildren()[1]:Clone()
Debris:AddItem(HatModel, 1)

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	WoodWalk = Handle:WaitForChild("WoodWalk"),
}

Grips = {
	Up = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, 0, 0, 0.194998264, 0.975938141, -0.0975725725, -0.980757415, 0.194987625, -0.00973754004, 0.00952220801, 0.0975938067, 0.995180845),
}

TransparentParts = {}

ToolEquipped = false

Tool.Grip = Grips.Up
Tool.Enabled = true

function IsTurbo(character)
	return character:FindFirstChild(Hat.Name)
end

function SetTransparency(PrimaryParent, Transparency)
	local Parts = {}
	local function SetParentTransparency(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			--if v ~= Tool then
				local ItemTransparent = false
				for ii, vv in pairs(TransparentParts) do
					if vv and vv.Part and vv.Part == v then
						ItemTransparent = true
					end
				end
				if not ItemTransparent then
					local HasTransparency = false
					pcall(function()
						local Property = v["Transparency"]
						if Property < 1 then
							HasTransparency = true
						end
					end)
					if HasTransparency then
						table.insert(Parts, {Part = v, Transparency = 0})
					end
				end
				SetParentTransparency(v, Transparency)
			--end
		end
	end
	SetParentTransparency(PrimaryParent)
	for i, v in pairs(Parts) do
		v.Part.Transparency = Transparency
	end
	return Parts
end

Tool.Enabled = true
function Activated()
	
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	Tool.Enabled = false
	
	for i, v in pairs({ToolUnequipped, ItemAdded, ItemRemoved}) do
		if v then
			v:disconnect()
		end
	end
	
	local CurrentlyEquipped = true
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	Sounds.WoodWalk:Play()
	Tool.Grip = Grips.Out
	wait(0.5)
	if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
		Tool.Grip = Grips.Up
		local Transparency = ((IsTurbo(Character) and 0.97) or 0.94)
		TransparentParts = SetTransparency(Character, Transparency)
		ItemAdded = Character.ChildAdded:connect(function(Child)
			for i, v in pairs(SetTransparency(Child, Transparency)) do
				table.insert(TransparentParts, v)
			end
		end)
		ItemRemoved = Character.ChildRemoved:connect(function(Child)
			for i, v in pairs(Child:GetChildren()) do
				for ii, vv in pairs(TransparentParts) do
					if vv.Part == v then
						vv.Part.Transparency = vv.Transparency
						table.remove(TransparentParts, ii)
					end
				end
			end
		end)
		wait(8)
		if CurrentlyEquipped then
			for i, v in pairs(TransparentParts) do
				if v.Part and v.Part.Parent then
					v.Part.Transparency = v.Transparency
				end
			end
			TransparentParts = {}
			Sounds.WoodWalk:Stop()
		end
	end
	wait(3)
	Tool.Grip = Grips.Up
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Sounds.Equip:Play()
end

function Unequipped()
	Tool.Grip = Grips.Up
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	for i, v in pairs({ToolUnequipped, ItemAdded, ItemRemoved}) do
		if v then
			v:disconnect()
		end
	end	
	for i, v in pairs(TransparentParts) do
		if v.Part and v.Part.Parent then
			v.Part.Transparency = v.Transparency
		end
	end
	TransparentParts = {}
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)