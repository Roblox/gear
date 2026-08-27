local Tool = script.Parent 
local Compass = Tool.Handle 

local Character
local Player 

local Torso 
local Humanoid 

local Eggs_Model = Game.Workspace:WaitForChild('Eggs')
local EggMetaData_Model = Game.Lighting:WaitForChild('Eggs')

local Compass_Type = Tool:WaitForChild('CompassType')
local RarityRange = {40, 100}
local EggType_List = {
	['ChocolateEgg'] = true,
	['TigerEgg'] = true,
	['ScrambledEgg'] = true,
	['EggoEgg'] = true,
	['GGEEgg'] = true 
} 

local Pos = Tool:WaitForChild('Pos')

if Compass_Type.Value == 'Rare' then 
	RarityValue = {20 , 39}	
end 

local Equipped = false 

local function CacheEggTypes()
	local eChildren = EggMetaData_Model:GetChildren()
	for _, eggMD in pairs(eChildren) do 
		if eggMD:FindFirstChild('Rarity') and eggMD['Rarity'].Value >= RarityRange[1] and eggMD['Rarity'].Value < RarityRange[2] then 
			--EggType_List[eggMD.Name] = true 
		end 
	end 
end 

local function FindPartInModel(model)
	local mChildren = model:GetChildren()	
	for i = 1, #mChildren do 
		if mChildren[i]:IsA('BasePart') then 
			return mChildren[i]			
		end 		 
	end 	
	for i = 1, #mChildren do 
		if #mChildren[i]:GetChildren() >= 1 then 
			return FindPartInModel(mChildren[i])
		end
	end 
end 

local function FindNearestEgg()
	local minDistance = math.huge 
	local egg
	local eggLocation 
	for eggName, _ in pairs(EggType_List) do
		if Eggs_Model:FindFirstChild(eggName) then 
			local eggPart = FindPartInModel(Eggs_Model[eggName])
			local distance = (eggPart.Position - Torso.Position).magnitude 
			if distance < minDistance then 
				egg = Eggs_Model[eggName]
				eggLocation = eggPart.Position 
				minDistance = distance 
			end 
		end 
	end 
	return egg, eggLocation 
end 

local function OnEquipped()
	Equipped = true 
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character) 
	Torso = Character:WaitForChild('Torso')	
	Humanoid = Character:WaitForChild('Humanoid')
	--Arrow.Parent = Character
	Spawn(function()		
		local lastEggTime 
		local egg, eggLocation
		while Equipped do 			
			if not lastEggTime or tick() - lastEggTime > 5.0 then 
				lastEggTime = tick() 
				--print('Finding closer egg - ', math.floor(tick() - lastEggTime))
				egg, eggLocation = FindNearestEgg() 
--				print('Egg that is found - ', egg) 
				if egg.Parent then 
					--print('EGG parent is ', egg.Parent)
				end 
			end 			
			if egg and eggLocation then 	
				-- Come back and optimize 
				-- This is running at 30HZ or more 			
				Pos.Value = eggLocation 
			end 
			wait(0.015)
		end
	end)
end

local function OnUnequipped()
	--Arrow.Parent = nil 
	Equipped = false 
end

CacheEggTypes() 
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)