local Tool = script.Parent 
local Cloner = Tool.Handle

local Character
local Player 

local PlayerGui 

local FabregeGui 

local Torso 
local Humanoid 

local SelectedFabrege = nil 

local FabregeToAward 

local PersistBadges
local BadgeConnection 


local EggIcons_List = {
	['DreamWeaverFabregeEgg'] = {['Selected'] = 110685176, ['Unselected'] = 110685141, ['BadgeId'] = 110693091},
	['PurpleFabregeEgg'] = {['Selected'] = 110685266, ['Unselected'] = 110685222, ['BadgeId'] = 110692797},
	['DragonFabrege'] = {['Selected'] = 110685357, ['Unselected'] = 110685335, ['BadgeId'] = 110693177},
}

local FontSizes = {
	Enum.FontSize.Size18,
	Enum.FontSize.Size14,
	Enum.FontSize.Size18,
	Enum.FontSize.Size24, 
}

local function IsFabEgg(badgeId)
	for eggName, eggList in pairs(EggIcons_List) do 
		if eggList['BadgeId'] == badgeId then 
			return eggName 
		end 
	end 
	return nil 
end

local function ShowNotification(eggName)
	local gui = Instance.new('ScreenGui')
	gui.Name = 'FabGui'
	gui.Parent = PlayerGui 
	print(PlayerGui, " is nil") 
	
	local tLabel = Instance.new('TextLabel')
	tLabel.Font = Enum.Font.ArialBold 
	tLabel.TextColor3 = Color3.new(54/255, 96/255, 192/255)
	tLabel.Size = UDim2.new(0, 200, 0, 20)
	tLabel.BackgroundTransparency = 1.0
	tLabel.Parent = gui 
	tLabel.Text = "Congratulations! You just cloned yourself a " .. eggName 
	tLabel.Position = UDim2.new(0.5, -100, 0, 150)
	tLabel.FontSize = Enum.FontSize.Size18
	
	local lastTick = tick() 
	local count = 0 
	Game:GetService('Debris'):AddItem(gui, 4.5)  
end

local function CreateGui()
	FabregeGui = Instance.new('ScreenGui')
	FabregeGui.Parent = PlayerGui 
	
	local frame = Instance.new('Frame')
	frame.Name = 'SelectorFrame' 
	frame.Size = UDim2.new(0, 300, 0, 100)
	frame.Parent = FabregeGui 
	frame.BackgroundTransparency = 1.0 
	frame.Position = UDim2.new(0.5, -150, 1, -200)
	
	for egg, eggImageList in pairs(EggIcons_List) do 
		local eggButton = Instance.new('ImageButton')
		eggButton.Name = egg
		eggButton.Parent = frame 
		eggButton.Image = "http://www.roblox.com/asset/?id=" .. eggImageList['Unselected'] 
		eggButton.BackgroundTransparency = 1.0
		eggButton.Size = UDim2.new(0, 100, 0, 100) 
		eggButton.Position = UDim2.new(0, (#frame:GetChildren() -1) * 100, 0, 0) 
	
		eggButton.MouseButton1Click:connect(function()
			FabregeToAward.Value = eggImageList['BadgeId']  
			for _, eButton in pairs(frame:GetChildren()) do 
				eButton.Image = "http://www.roblox.com/asset/?id=" .. EggIcons_List[eButton.Name]['Unselected'] 
			end
			eggButton.Image = "http://www.roblox.com/asset/?id=" .. eggImageList['Selected'] 
		end)
	end 
end 

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character)
	if Player:FindFirstChild('FabregeToAward') == nil then 
		FabregeToAward = Instance.new('IntValue')
		FabregeToAward.Name = 'FabregeToAward' 
		FabregeToAward.Parent = Player 
	else 
		FabregeToAward = Player:WaitForChild('FabregeToAward') 
	end 
	PlayerGui = Player:WaitForChild('PlayerGui') 
	if FabregeGui then 
		FabregeGui.Parent = PlayerGui 
	else 
		CreateGui()
	end 	
	PersistBadges = Player:WaitForChild('PersistBadges') 
	if not BadgeConnection then 
		BadgeConnection = PersistBadges.ChildAdded:connect(function(child)
			if child and child:IsA('IntValue') then 
 				if IsFabEgg(child.Value) and child.Value == FabregeToAward.Value then 
					local egg = IsFabEgg(child.Value) 
					ShowNotification(egg)
				end 
			end 
		end)
	end 
end

local function OnUnequipped()
	FabregeGui.Parent = nil 
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped) 

