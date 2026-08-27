local Tool = script.Parent 
local Launcher = Tool.Handle

local Character
local Player 
local Humanoid 
local Torso 

local EggsToClone = {
	'Egg of Life',
	'Egg of Verticality',
	'Basic Egg',
	'Poached Egg',
	'Luregg',
	'Malicious Egg',
	'Egg of Frost',
} 

local Eggs_Model = Game.ServerStorage:WaitForChild('Eggs') 
local SpawnedEggs = Game.Workspace:WaitForChild('SpawnedEggs') 

local function FindPartInModel(model)
	return model:FindFirstChild('EggPart', 1) or model:FindFirstChild('Handle', 1)
end 


local function MakeFake(egg)
	local eChildren = egg:GetChildren()
	for _, child in pairs(eChildren) do 
		if child:IsA('Script') or child:IsA('LocalScript') then 
			child:Destroy() 
		else 
			MakeFake(child) 
		end				
	end 
	return egg 
end 

Tool.Enabled = true  
local function OnActivated()
	if not Humanoid or not Torso then 
		return 
	end 
	
	if not Tool.Enabled then 
		return 
	end 
	
	print('Tool is enabled') 
	
	Tool.Enabled = false 
	
	local target = Humanoid.TargetPoint 
	local egg = Eggs_Model:FindFirstChild(EggsToClone[math.random(1, #EggsToClone)]):Clone() 
	print('Found egg ', egg) 
	local eggPart = FindPartInModel(egg)
	
	if math.random() > 0.05 then 
		eggPart = MakeFake(eggPart) 
		egg = Instance.new('Model')
		eggPart.Parent = egg
		local eConnection = eggPart.Touched:connect(function(hitPart)
			if hitPart and hitPart.Parent and Game.Players:GetPlayerFromCharacter(hitPart.Parent) then 
				local gui = Instance.new('ScreenGui') 
				gui.Parent = Game.Players:GetPlayerFromCharacter(hitPart.Parent):WaitForChild('PlayerGui') 
				
				local tLabel = Instance.new('TextLabel') 
				tLabel.Text = "IT IS A FAKE. BETTER LUCK NEXT TIME" 
				tLabel.TextColor3 = Color3.new(1, 0, 0)
				tLabel.Size = UDim2.new(0, 300, 0, 50)
				tLabel.BackgroundTransparency = 1.0
				tLabel.Position = UDim2.new(0.5, -150, 0.5, -25) 
				tLabel.Parent = gui 
				
				Game:GetService('Debris'):AddItem(gui, 2.0)
				if eConnection then 
					eConnection:disconnect() 
				end 
			end 
		end)
		Game:GetService('Debris'):AddItem(egg, 4.5) 
	else 
		Game:GetService('Debris'):AddItem(egg, 55)
	end 
	egg.Parent = SpawnedEggs 
	eggPart.Anchored = false
	eggPart.CFrame = Torso.CFrame + Torso.CFrame.lookVector * 5.0 
	eggPart.Velocity = (target - Torso.Position).unit * 30.0
	print('Fire in the hole') 
	wait(5.5)
	Tool.Enabled = true 
	
end 

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character)
	Torso = Character:FindFirstChild('Torso') or Character:FindFirstChild("UpperTorso")
	Humanoid = Character:WaitForChild('Humanoid') 
end 

local function OnUnequipped()
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated) 


