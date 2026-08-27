local vCharacter = script.Parent

function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		wait()
	end
end

waitForChild(vCharacter, "Torso")
waitForChild(vCharacter, "Humanoid")

local insertTable = {}
local headTable = {}
local torsoTable = {}

local myTorso = vCharacter:FindFirstChild("Torso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local trollLeftArm = game:GetService("InsertService"):LoadAsset(69945662)
local trollLeftLeg = game:GetService("InsertService"):LoadAsset(69945697)
local trollRightArm = game:GetService("InsertService"):LoadAsset(69945629)
local trollRightLeg = game:GetService("InsertService"):LoadAsset(69945724)
local trollTorso = game:GetService("InsertService"):LoadAsset(69945590)
local trollHat = game:GetService("InsertService"):LoadAsset(69900491)

if trollLeftArm then trollLeftArm = trollLeftArm:GetChildren()[1] end
if trollRightArm then trollRightArm = trollRightArm:GetChildren()[1] end
if trollLeftLeg then trollLeftLeg = trollLeftLeg:GetChildren()[1] end
if trollRightLeg then trollRightLeg = trollRightLeg:GetChildren()[1] end 
if trollTorso then trollTorso = trollTorso:GetChildren()[1] end 
if trollHat then trollHat = trollHat:GetChildren()[1] end

coroutine.resume(coroutine.create(function() 
	local duration = 7
	if myHumanoid then 
		myHumanoid.WalkSpeed = -16
		while duration > 0 do 			
			myHumanoid.WalkSpeed = -16
			duration = duration - wait() 
			wait() 
		end
		myHumanoid:TakeDamage(17)
		myHumanoid.WalkSpeed = 16
	end
end))


charChildren = vCharacter:GetChildren()
for c = 1, #charChildren do
	if charChildren[c].className ~= "Part" and charChildren[c].className ~= "Script" and charChildren[c].className ~= "LocalScript" and charChildren[c].className ~= "Humanoid" and charChildren[c].className ~= "Tool" and charChildren[c].className ~= "ForceField" then
		local clone = charChildren[c]:Clone()
		table.insert(insertTable, clone)                              
	end
	if charChildren[c].Name == "Head" then
		headChildren = charChildren[c]:GetChildren()
		for a =1, #headChildren do
			if headChildren[a].className == "Decal" then
				local clone = headChildren[a]:Clone()
				table.insert(headTable, clone)                                                       
			end
		end
	end
	if charChildren[c].Name == "Torso" then
		torsoChildren = charChildren[c]:GetChildren()
		for x=1, #torsoChildren do
			if torsoChildren[x].className == "Decal" then
				local clone = torsoChildren[x]:Clone()
				table.insert(torsoTable, clone)
			end
		end
	end
end

local graphics = vCharacter:GetChildren()
for j = 1, #graphics do
	if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" and graphics[j].className ~= "ForceField" then                          
		graphics[j]:Remove()                         
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

trollLeftArm.Parent = vCharacter
trollRightArm.Parent = vCharacter
trollLeftLeg.Parent = vCharacter
trollRightLeg.Parent = vCharacter
trollTorso.Parent = vCharacter
trollHat.Parent = vCharacter


wait(10.0)

if insertTable ~= nil then	
	local graphics = vCharacter:GetChildren()
	for j = 1, #graphics do
		if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" then                     
			graphics[j]:Remove()                         
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
script:Remove()




