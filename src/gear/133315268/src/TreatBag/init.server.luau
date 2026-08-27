local Tool = script.Parent 
local Bag = Tool.Handle 

local Character 
local Humanoid 

local Unequip = script:WaitForChild('Unequip') 

local function OnEquipped()  
	Character = Tool.Parent 
	Humanoid = Character:WaitForChild('Humanoid') 	
	Humanoid.WalkSpeed = 22.0 
end

local function OnUnequipped() 
	Humanoid.WalkSpeed = 16.0 
end

Tool.Equipped:connect(OnEquipped) 
Tool.Unequipped:connect(OnUnequipped) 

Unequip.OnInvoke = function()
	Humanoid.Walkspeed = 16.0 
end