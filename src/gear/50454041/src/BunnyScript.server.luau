local InsertService = game:GetService("InsertService")

local Tool = script.Parent
local Carrot = Tool.Handle

local PackageMaker = require(836581200)

Tool.Enabled = true
local vCharacter = Tool.Parent

local insertTable = {}
local headTable = {}
local torsoTable = {}

local co

local biteSound

local bunnyActive = Tool:FindFirstChild("BunnyActive")

-- getBunny
bunnyLeftArm = InsertService:LoadAsset(50383173)
bunnyLeftLeg = InsertService:LoadAsset(50383219)
bunnyRightArm = InsertService:LoadAsset(50383126)
bunnyRightLeg = InsertService:LoadAsset(50383252)
bunnyTorso = InsertService:LoadAsset(50383074)

bunnyFace = InsertService:LoadAsset(1080949)


--if bunnyLeftArm then bunnyLeftArm = bunnyLeftArm:GetChildren() bunnyLeftArm = bunnyLeftArm[1] end
--if bunnyRightArm then bunnyRightArm = bunnyRightArm:GetChildren() bunnyRightArm = bunnyRightArm[1] end
--if bunnyLeftLeg then bunnyLeftLeg = bunnyLeftLeg:GetChildren() bunnyLeftLeg = bunnyLeftLeg[1] end
--if bunnyRightLeg then bunnyRightLeg = bunnyRightLeg:GetChildren() bunnyRightLeg = bunnyRightLeg[1] end
--if bunnyTorso then bunnyTorso = bunnyTorso:GetChildren() bunnyTorso = bunnyTorso[1] end
if bunnyFace then bunnyFace = bunnyFace:GetChildren() bunnyFace = bunnyFace[1] end

--

-- Wait until Tool is picked up or equipped by Character
while vCharacter:FindFirstChild("Humanoid") == nil do
	wait()
	vCharacter = Tool.Parent
end

charChildren = vCharacter:GetChildren()
for c = 1, #charChildren do 
	if not charChildren[c]:IsA("BasePart") and not charChildren[c]:IsA("BaseScript") and not charChildren[c]:IsA("Humanoid") and not charChildren[c]:IsA("Tool") and not charChildren[c]:IsA("ForceField") then 
		clone = charChildren[c]:Clone()
		table.insert(insertTable, clone)						
	end
	if charChildren[c].Name == "Head" then
		headChildren = charChildren[c]:GetChildren()
		for a =1, #headChildren do 
			if headChildren[a]:IsA("Decal") or headChildren[a]:IsA("SpecialMesh") then
				clone = headChildren[a]:Clone()
				table.insert(headTable, clone)											
			end
		end
	end
	if charChildren[c].Name == "Torso" or charChildren[c].Name == "UpperTorso" then 
		torsoChildren = charChildren[c]:GetChildren()
		for x=1, #torsoChildren do 
			if torsoChildren[x]:IsA("Decal") then 
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

	if biteSound then biteSound:Play() end

	graphics = vCharacter:GetChildren()
	myHumanoid:RemoveAccessories()
	for j = 1, #graphics do 
		if not graphics[j]:IsA("BasePart") and not graphics[j]:IsA("BaseScript") and not graphics[j]:IsA("Humanoid") and not graphics[j]:IsA("Tool") and not graphics[j]:IsA("ForceField") then					
			graphics[j]:Destroy()					
		end	
	end

--	bLA = bunnyLeftArm:Clone() bLA.Parent = vCharacter
--	bLL = bunnyLeftLeg:Clone() bLL.Parent = vCharacter
--	bRA = bunnyRightArm:Clone() bRA.Parent = vCharacter
--	bRL = bunnyRightLeg:Clone() bRL.Parent = vCharacter
--	bT = bunnyTorso:Clone() bT.Parent = vCharacter

	PackageMaker.ApplyBodyPart(vCharacter, bunnyLeftArm.R15, bunnyLeftArm.R6) 
	PackageMaker.ApplyBodyPart(vCharacter, bunnyLeftLeg.R15, bunnyLeftLeg.R6) 
	PackageMaker.ApplyBodyPart(vCharacter, bunnyRightArm.R15, bunnyRightArm.R6) 
	PackageMaker.ApplyBodyPart(vCharacter, bunnyRightLeg.R15, bunnyRightLeg.R6) 
	PackageMaker.ApplyBodyPart(vCharacter, bunnyTorso.R15, bunnyTorso.R6)

	myHumanoid:AddAccessory(bunnyFace:Clone())

	if co == nil or coroutine.status(co) == 'dead' then
		print("Coroutine created")
		co = coroutine.create(reset)		
		coroutine.resume(co)
		bunnyActive.Value = 1
	else
		print(coroutine.status(co))
		-- do nothing
	end

	Carrot.Transparency = 1.0

	if myHumanoid then myHumanoid.WalkSpeed = 28 end
	
	while bunnyActive.Value == 1 do wait(1) end
	Tool.Enabled = true
end

function reset()
	wait(25)
	bunnyActive.Value = 0
	Carrot.Transparency = 0.0

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then 
		myHumanoid.WalkSpeed = 16
	end
	if insertTable ~= nil then 
		if morphResetSound then morphResetSound:Play() end
		graphics = vCharacter:GetChildren()
		for j = 1, #graphics do 
			if not graphics[j]:IsA("BasePart") and not graphics[j]:IsA("BaseScript") and not graphics[j]:IsA("Humanoid") and not graphics[j]:IsA("Tool") then					
				graphics[j]:Destroy()					
			end
		end
		for i =1, #insertTable do 
			clone = insertTable[i]:Clone()
			clone.Parent = vCharacter
		end		
	end
end

function onEquipped()
	if bunnyActive.Value == 1 then Carrot.Transparency = 1.0 end
end

function onUnequipped()	
	--if bunnyActive then bunnyActive.Value = 0 end
	if Carrot then Carrot.Transparency = 0.0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
