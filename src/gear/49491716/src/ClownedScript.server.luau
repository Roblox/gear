vCharacter = script.Parent
humanoid = vCharacter:FindFirstChild("Humanoid")

local insertTable = {}
local headTable = {}
local torsoTable = {}

-- Storing the current attire to reset back after 10 seconds
local charChildren = vCharacter:GetChildren()
for c = 1, #charChildren do 
	if charChildren[c].className ~= "Part" and charChildren[c].className ~= "Script" and charChildren[c].className ~= "LocalScript" and charChildren[c].className ~= "Humanoid" and charChildren[c].className ~= "Tool" and charChildren[c].className ~= "ForceField" then 
		clone = charChildren[c]:Clone()
		table.insert(insertTable, clone)						
	end
	if charChildren[c].Name == "Head" then
		headChildren = charChildren[c]:GetChildren()
		for a =1, #headChildren do 
			if headChildren[a].className == "Decal" or headChildren[a].className == "SpecialMesh" then
				clone = headChildren[a]:Clone()
				table.insert(headTable, clone)											
			end
		end
	end
	if charChildren[c].Name == "Torso" then 
		torsoChildren = charChildren[c]:GetChildren()
		for x=1, #torsoChildren do 
			if torsoChildren[x].className == "Decal" then 
				clone = torsoChildren[x]:Clone()
				table.insert(torsoTable, clone)
			end
		end
	end
end

 -- Removing the current attire
local graphics = vCharacter:GetChildren()
for j = 1, #graphics do 
	if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" and graphics[j].className ~= "ForceField" then 					
		graphics[j]:Remove()					
	end
	if graphics[j].Name == "Head" then
		headChildren = graphics[j]:GetChildren()
		for a =1, #headChildren do 
			if headChildren[a].className == "Decal" then --or headChildren[a].className == "SpecialMesh" then							
				headChildren[a]:Remove()							
			end
		end
	end
	if graphics[j].Name == "Torso" then 
		torsoChildren = graphics[j]:GetChildren()
		for x=1, #torsoChildren do 
			if torsoChildren[x].className == "Decal" then 
				torsoChildren[x]:Remove()
			end
		end
	end
end

local hats = { game:GetService("InsertService"):LoadAsset(1032641),
					game:GetService("InsertService"):LoadAsset(40893248),
					game:GetService("InsertService"):LoadAsset(37208763),
					game:GetService("InsertService"):LoadAsset(1031418),		
					game:GetService("InsertService"):LoadAsset(11721354),		
					game:GetService("InsertService"):LoadAsset(13844687),	
					game:GetService("InsertService"):LoadAsset(20573078)
				}

--vCharacter.Head.Transparency = 1

face = vCharacter.Head:FindFirstChild("face")
if face ~= nil then face.Parent = nil end

num = math.random(1, #hats)
hat = hats[num]

ch = hat:GetChildren()
if hat == nil then return end
hat = hat:GetChildren()
if hat ~= nil then hat = hat[1] end
if hat ~= nil then	
	--hat.Handle.Size = Vector3.new(1,1,2.5)
	hat.Handle.CanCollide = true
	hat.Parent = vCharacter
end

decals = { game:GetService("InsertService"):LoadAsset(42070576),
				game:GetService("InsertService"):LoadAsset(27134344),
				game:GetService("InsertService"):LoadAsset(29348122)
			}
num = math.random(1, #decals)
decal = decals[num]
decal = decal:GetChildren()
if decal  then decal = decal[1] end
if decal then decal.Parent = vCharacter.Head end

chance = math.random(0, 1)
local body = nil
if chance == 1 then
	body = game:GetService("InsertService"):LoadAsset(48474356)
end

if body then girlBody = body:GetChildren() end
if girlBody ~= nil then girlBody = girlBody[1] end

if girlBody ~= nil then girlBody.Parent = vCharacter end

wait(10)

-- Resorting the old attire

if insertTable ~= nil then 
	if morphResetSound then morphResetSound:Play() end
	graphics = vCharacter:GetChildren()
	for j = 1, #graphics do 
		if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" then 				
			graphics[j]:Remove()					
		end
		if graphics[j].Name == "Head" then
			headChildren = graphics[j]:GetChildren()
			for a =1, #headChildren do 
				if headChildren[a].className == "Decal" then --or headChildren[a].className == "SpecialMesh" then							
					headChildren[a]:Remove()							
				end
			end
		end
		if graphics[j].Name == "Torso" then 
			torsoChildren = graphics[j]:GetChildren()
			for x=1, #torsoChildren do 
				if torsoChildren[x].className == "Decal" then 
					torsoChildren[x]:Remove()
				end
			end
		end
	end

	for i =1, #insertTable do 
		clone = insertTable[i]:Clone()
		clone.Parent = vCharacter
	end
	for k = 1, #headTable do 
		clone = headTable[k]:Clone()
		clone.Parent = vCharacter:FindFirstChild("Head")
	end
	for l = 1, #torsoTable do 
		clone = torsoTable[l]:Clone()
		clone.Parent = vCharacter:FindFirstChild("Torso")
	end		
end

wait(1.0)
humanoid = vCharacter:FindFirstChild("Humanoid")
if humanoid ~= nil then 	
	clown = humanoid:FindFirstChild("Clowned")
	clown:Remove()	
end
script:Remove()


