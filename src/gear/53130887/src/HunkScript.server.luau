local Tool = script.Parent
local Potion = Tool.Handle

Tool.Enabled = true
local vCharacter = Tool.Parent

local insertTable = {}
local headTable = {}
local torsoTable = {}

local headColor

local co

local biteSound

local hunkActive = Tool:FindFirstChild("HunkActive")

-- get hunk
hunkLeftArm = game:GetService("InsertService"):LoadAsset(32336182)
hunkLeftLeg = game:GetService("InsertService"):LoadAsset(32336243)
hunkRightArm = game:GetService("InsertService"):LoadAsset(32336117)
hunkRightLeg = game:GetService("InsertService"):LoadAsset(32336306)
hunkTorso = game:GetService("InsertService"):LoadAsset(32336059)

hunkFace = game:GetService("InsertService"):LoadAsset(27171262)

hunkShirt = game:GetService("InsertService"):LoadAsset(53062494)
hunkPants = game:GetService("InsertService"):LoadAsset(53062825)
hunkGlass = game:GetService("InsertService"):LoadAsset(51245241)

hunkHead = game:GetService("InsertService"):LoadAsset(6340213)



if hunkLeftArm then hunkLeftArm = hunkLeftArm:GetChildren() hunkLeftArm = hunkLeftArm[1] end
if hunkRightArm then hunkRightArm = hunkRightArm:GetChildren() hunkRightArm = hunkRightArm[1] end
if hunkLeftLeg then hunkLeftLeg = hunkLeftLeg:GetChildren() hunkLeftLeg = hunkLeftLeg[1] end
if hunkRightLeg then hunkRightLeg = hunkRightLeg:GetChildren() hunkRightLeg = hunkRightLeg[1] end
if hunkTorso then hunkTorso = hunkTorso:GetChildren() hunkTorso = hunkTorso[1] end
if hunkFace then hunkFace = hunkFace:GetChildren() hunkFace = hunkFace[1] hunkFace.Handle.Mesh.Scale = Vector3.new(1.2, 1.2, 1.2) end
if hunkShirt then hunkShirt = hunkShirt:GetChildren() hunkShirt = hunkShirt[1] end
if hunkPants then hunkPants = hunkPants:GetChildren() hunkPants = hunkPants[1] end
if hunkGlass then hunkGlass = hunkGlass:GetChildren() hunkGlass = hunkGlass[1] hunkGlass.Handle.Mesh.Scale = Vector3.new(1.1, 1.1, 1.1) end
if hunkHead then hunkHead = hunkHead:GetChildren() hunkHead = hunkHead[1] end

-- 

-- Wait until Tool is picked up or equipped by Character
while vCharacter:FindFirstChild("Humanoid") == nil do
wait()
vCharacter = Tool.Parent
end

charChildren = vCharacter:GetChildren()
for c = 1, #charChildren do
if charChildren[c].className ~= "Part" and charChildren[c].className ~= "Script" and charChildren[c].className ~= "LocalScript" and charChildren[c].className ~= "Humanoid" and charChildren[c].className ~= "Tool" and charChildren[c].className ~= "ForceField" then
	 clone = charChildren[c]:Clone()
	 table.insert(insertTable, clone)                              
end
if charChildren[c].Name == "Head" then
	 headChildren = charChildren[c]:GetChildren()
	 for a =1, #headChildren do
			if headChildren[a].className == "Decal" or headChildren[a].Name == "Mesh" then
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

function onActivated()     

	if Tool.Enabled == false then
		 return
	end     

	Tool.Enabled = false

	biteSound = Tool:FindFirstChild("BiteSound")

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then
		 return
	end

	head = vCharacter:FindFirstChild("Head")
	if head == nil then 
		return
	end

	headColor = head.BrickColor

	if biteSound then biteSound:Play() end

	graphics = vCharacter:GetChildren()
	for j = 1, #graphics do
		 if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" and graphics[j].className ~= "ForceField" then                          
				graphics[j]:Remove()                         
		 end     
		if graphics[j].Name == "Head" then 
			headChildren = graphics[j]:GetChildren() 
			for a = 1, #headChildren do 
				if headChildren[a].Name == "Mesh" then 
					headChildren[a]:Remove() 
				end
			end
		end			
	end

	bLA = hunkLeftArm:Clone() bLA.Parent = vCharacter
	bLL = hunkLeftLeg:Clone() bLL.Parent = vCharacter
	bRA = hunkRightArm:Clone() bRA.Parent = vCharacter
	bRL = hunkRightLeg:Clone() bRL.Parent = vCharacter
	bT = hunkTorso:Clone() bT.Parent = vCharacter

	bFace = hunkFace:Clone() bFace.Parent = vCharacter
	bShirt = hunkShirt:Clone() bShirt.Parent = vCharacter
	bPants = hunkPants:Clone() bPants.Parent = vCharacter
	bGlass = hunkGlass:Clone() bGlass.Parent = vCharacter

	bHead = hunkHead:Clone() bHead.Parent = vCharacter.Head

	head.BrickColor = BrickColor.new("Bright orange")

	if co == nil or coroutine.status(co) == 'dead' then
		 print("Coroutine created")
		 co = coroutine.create(reset)          
		 coroutine.resume(co)
		 hunkActive.Value = 1
	else
		 print(coroutine.status(co))
		 -- do nothing
	end

	Potion.Transparency = 1.0

	if myHumanoid then 
		myHumanoid.WalkSpeed = 25 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 200 
		wait(0.2)
		myHumanoid.Health = ratio * 200
	end

	while hunkActive.Value == 1 do wait(1) end
	Tool.Enabled = true
	end

function reset()
	wait(45)
	hunkActive.Value = 0
	Potion.Transparency = 0.0

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then
		myHumanoid.WalkSpeed = 16
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.Health = ratio * 100
		myHumanoid.MaxHealth = 100
	end
	if insertTable ~= nil then
		if morphResetSound then morphResetSound:Play() end
		graphics = vCharacter:GetChildren()
		for j = 1, #graphics do
			if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" then                     
				graphics[j]:Remove()                         
			end
			if graphics[j].Name == "Head" then 
				headChildren = graphics[j]:GetChildren()
				for a = 1, #headChildren do 
					if headChildren[a].Name == "Mesh" then headChildren[a]:Remove() end
				end
			end
		end
		for i =1, #insertTable do
			clone = insertTable[i]:Clone()
			clone.Parent = vCharacter
		end     
		for i =1, #headTable do 
			if headTable[i].Name == "Mesh" then 
				clone = headTable[i]:Clone()
				clone.Parent = vCharacter.Head
			end
		end
		vCharacter.Head.BrickColor = headColor
	end
end

function onEquipped()
	if hunkActive.Value == 1 then Potion.Transparency = 1.0 end
end

function onUnequipped()     
--if hunkActive then hunkActive.Value = 0 end
if Potion then Potion.Transparency = 0.0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped) 
