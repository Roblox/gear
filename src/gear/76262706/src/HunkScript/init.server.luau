while script:FindFirstChild("Unequipped") == nil do wait() end 

local unequipped_BoolValue = script.Unequipped 

local vCharacter = script.Parent 
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
local myTorso = vCharacter:FindFirstChild("Torso") 

local insertTable = {}
local headTable = {}
local torsoTable = {}

local headColor 

local hunkLeftArm = game:GetService("InsertService"):LoadAsset(32336182)
local hunkLeftLeg = game:GetService("InsertService"):LoadAsset(32336243)
local hunkRightArm = game:GetService("InsertService"):LoadAsset(32336117)
local hunkRightLeg = game:GetService("InsertService"):LoadAsset(32336306)
local hunkTorso = game:GetService("InsertService"):LoadAsset(76215493)

local hunkFace = game:GetService("InsertService"):LoadAsset(27171262)

--local hunkShirt = game:GetService("InsertService"):LoadAsset(53062494)
local hunkShirt = game:GetService("InsertService"):LoadAsset(64393082)
local hunkPants = game:GetService("InsertService"):LoadAsset(53062825)

local hunkHead = game:GetService("InsertService"):LoadAsset(6340213)


if hunkLeftArm then hunkLeftArm = hunkLeftArm:GetChildren() hunkLeftArm = hunkLeftArm[1] end
if hunkRightArm then hunkRightArm = hunkRightArm:GetChildren() hunkRightArm = hunkRightArm[1] end
if hunkLeftLeg then hunkLeftLeg = hunkLeftLeg:GetChildren() hunkLeftLeg = hunkLeftLeg[1] end
if hunkRightLeg then hunkRightLeg = hunkRightLeg:GetChildren() hunkRightLeg = hunkRightLeg[1] end
if hunkTorso then hunkTorso = hunkTorso:GetChildren() hunkTorso = hunkTorso[1] end
if hunkFace then hunkFace = hunkFace:GetChildren() hunkFace = hunkFace[1] hunkFace.Handle.Mesh.Scale = Vector3.new(1.2, 1.2, 1.2) end
if hunkShirt then hunkShirt = hunkShirt:GetChildren() hunkShirt = hunkShirt[1] end
if hunkPants then hunkPants = hunkPants:GetChildren() hunkPants = hunkPants[1] end
if hunkHead then hunkHead = hunkHead:GetChildren() hunkHead = hunkHead[1] end

local charChildren = vCharacter:GetChildren()
for c = 1, #charChildren do
	if charChildren[c].className ~= "Part" and charChildren[c].className ~= "Script" and charChildren[c].className ~= "LocalScript" and charChildren[c].className ~= "Humanoid" and charChildren[c].className ~= "Tool" and charChildren[c].className ~= "ForceField" then
		 clone = charChildren[c]:Clone()
		 table.insert(insertTable, clone)                              
	end
	if charChildren[c].Name == "Head" then
		local headColor = charChildren[c].BrickColor 
		charChildren[c].BrickColor = BrickColor.new("Nougat")
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
	if charChildren[c].Name == "Left Arm" then 
		leftArmColor = charChildren[c].BrickColor
		charChildren[c].BrickColor = BrickColor.new("Medium stone grey")				
	end
	if charChildren[c].Name == "Right Arm" then 
		rightArmColor = charChildren[c].BrickColor 
		charChildren[c].BrickColor = BrickColor.new("Medium stone grey")
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
				headChildren[a]:Remove() 
			end
		end
	end			
end

local bLA = hunkLeftArm:Clone() bLA.Parent = vCharacter
local bLL = hunkLeftLeg:Clone() bLL.Parent = vCharacter
local bRA = hunkRightArm:Clone() bRA.Parent = vCharacter
local bRL = hunkRightLeg:Clone() bRL.Parent = vCharacter
local bT = hunkTorso:Clone() bT.Parent = vCharacter

local bFace = hunkFace:Clone() bFace.Parent = vCharacter
--local bShirt = hunkShirt:Clone() bShirt.Parent = vCharacter
local bPants = hunkPants:Clone() bPants.Parent = vCharacter

local bHead = hunkHead:Clone() bHead.Parent = vCharacter.Head

local charChildren = vCharacter:GetChildren()
for c = 1, #graphics do	
	if charChildren[c].Name == "Left Arm" then 		
		charChildren[c].BrickColor = BrickColor.new("Medium stone grey")		
		print(vCharacter["Left Arm"].BrickColor, charChildren[c].BrickColor) 
	end
	if charChildren[c].Name == "Right Arm" then 		
		charChildren[c].BrickColor = BrickColor.new("Medium stone grey")
	end 
end 



function reset()
	wait()	

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
			if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" and graphics[j]:IsA("ForceField") then                     
				graphics[j]:Remove()                         
			end
			if graphics[j].Name == "Head" then 
				if headColor then charChildren[c].BrickColor = headColor end 
				headChildren = graphics[j]:GetChildren()
				for a = 1, #headChildren do 
					if headChildren[a].Name == "Mesh" then headChildren[a]:Remove() end
				end
			end
			if graphics[j].Name == "Right Arm" then 
				graphics[j].BrickColor = rightArmColor
			end
			if graphics[j].Name == "Left Arm" then 
				graphics[j].BrickColor = leftArmColor
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
	end

	wait(1.0)
	if script then script:Destroy() end 
end

unequipped_BoolValue.Changed:connect(function()
	if unequipped_BoolValue and unequipped_BoolValue.Value == true then 
		reset()
	end 
end) 


wait(45)
if unequipped_BoolValue and unequipped_BoolValue.Value == false then 
	reset()
end 
