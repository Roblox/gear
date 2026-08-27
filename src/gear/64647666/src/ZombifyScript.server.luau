local InsertService = game:GetService("InsertService")

local PackageMaker = require(836581200)

local vCharacter = script.Parent

local insertTable = {}
local headTable = {}
local torsoTable = {}

local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local zombieLeftArm = InsertService:LoadAsset(64438670)
local zombieLeftLeg = InsertService:LoadAsset(64438718)
local zombieRightArm = InsertService:LoadAsset(64438626)
local zombieRightLeg = InsertService:LoadAsset(64438742)
local zombieTorso = InsertService:LoadAsset(64438589)
local zombieHat = InsertService:LoadAsset(64438501):GetChildren()[1]

PackageMaker.ApplyBodyPart(vCharacter, zombieLeftArm.R15, zombieLeftArm.R6)
PackageMaker.ApplyBodyPart(vCharacter, zombieLeftLeg.R15, zombieLeftLeg.R6)
PackageMaker.ApplyBodyPart(vCharacter, zombieRightArm.R15, zombieRightArm.R6)
PackageMaker.ApplyBodyPart(vCharacter, zombieRightLeg.R15, zombieRightLeg.R6)
PackageMaker.ApplyBodyPart(vCharacter, zombieTorso.R15, zombieTorso.R6)

myHumanoid.WalkSpeed = 9.0 

coroutine.resume(coroutine.create(function() 
	local duration = 10
	if myHumanoid then 
		while duration > 0 do 
			myHumanoid:TakeDamage(2.5)
			duration = duration - wait(1) 
			wait(1) 
		end
	end
end))


charChildren = vCharacter:GetChildren()
for c = 1, #charChildren do
	if not charChildren[c]:IsA("BasePart") and not charChildren[c]:IsA("BaseScript") and not charChildren[c]:IsA("Humanoid") and not charChildren[c]:IsA("Tool") and not charChildren[c]:IsA("ForceField") then
		local clone = charChildren[c]:Clone()
		table.insert(insertTable, clone)                              
	end
	if charChildren[c].Name == "Head" then
		headChildren = charChildren[c]:GetChildren()
		for a =1, #headChildren do
			if headChildren[a]:IsA("Decal") then
				local clone = headChildren[a]:Clone()
				table.insert(headTable, clone)                                                       
			end
		end
	end
	if charChildren[c].Name == "Torso" or charChildren[c].Name == "UpperTorso" then
		torsoChildren = charChildren[c]:GetChildren()
		for x=1, #torsoChildren do
			if torsoChildren[x]:IsA("Decal") then
				local clone = torsoChildren[x]:Clone()
				table.insert(torsoTable, clone)
			end
		end
	end
end

local graphics = vCharacter:GetChildren()
for j = 1, #graphics do
	if not graphics[j]:IsA("BasePart") and not graphics[j]:IsA("BaseScript") and not graphics[j]:IsA("Humanoid") and not graphics[j]:IsA("Tool") and not graphics[j]:IsA("ForceField") then                     
		graphics[j]:Destroy()                         
	end     
	if graphics[j].Name == "Head" then 
		headChildren = graphics[j]:GetChildren() 
		for a = 1, #headChildren do 
			if headChildren[a].Name == "Mesh" then 
				-- nothing
			end
		end
	end			
end

myHumanoid:AddAccessory(zombieHat)

wait(10.0)

if insertTable ~= nil then	
	local graphics = vCharacter:GetChildren()
	for j = 1, #graphics do
		if not graphics[j]:IsA("BasePart") and not graphics[j]:IsA("BaseScript") and not graphics[j]:IsA("Humanoid") and not graphics[j]:IsA("Tool") then                    
			graphics[j]:Destroy()                         
		end
	if graphics[j].Name == "Head" then 
		local headChildren = graphics[j]:GetChildren()
		for a = 1, #headChildren do 
			 -- nothing
			end
		end
	end
	for i =1, #insertTable do
		local clone = insertTable[i]:Clone()
		clone.Parent = vCharacter
	end     
	for i =1, #headTable do 
		if headTable[i].Name == "Mesh" then 
			local clone = headTable[i]:Clone()
			--clone.Parent = vCharacter.Head
		end
	end	
end

wait(5.0)
script:Destroy()




