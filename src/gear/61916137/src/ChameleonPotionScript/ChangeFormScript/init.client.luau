local vCharacter = script.Parent
local myHumanoid
local myTorso

local changeTo = script:FindFirstChild("ChangeTo")
local charMeshTable = {}
local fakeHead
local specialMeshTable = {}

local overlayTextureTable

-- Character copying stuff
local insertTable = {}
local headTable = {}
local torsoTable = {}
local brickColorTable = {}

local restoreCo 

local duration = 40

while changeTo == nil do 
	changeTo = script:FindFirstChild("ChangeTo")
	wait()
end

function storeCharacter()	
	charChildren = vCharacter:GetChildren()
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
			for x = 1, #torsoChildren do 
				if torsoChildren[x].className == "Decal" then 
					clone = torsoChildren[x]:Clone()
					table.insert(torsoTable, clone)
				end
			end
		end
		if charChildren[c].className == "Part" then 
			brickColorTable[charChildren[c].Name] = charChildren[c].BrickColor
		end		
	end
end

function copyCharacter(newCharacter)
	graphics = vCharacter:GetChildren()
	for j = 1, #graphics do 
		if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" and graphics[j].className ~= "ForceField" then 					
			graphics[j]:Remove()					
		end
		if graphics[j].Name == "Head" then
			graphics[j].Transparency = 1.0
			headChildren = graphics[j]:GetChildren()
			for a =1, #headChildren do 
				if headChildren[a].className == "Decal" or headChildren[a].className == "SpecialMesh" then							
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
		if graphics[j].Name == "FakeHead" then 
			graphics[j]:Remove() 
		end
	end
	

	newGraphics = newCharacter:GetChildren()
	for k = 1, #newGraphics do 
		if newGraphics[k].className ~= "Part" and newGraphics[k].className ~= "Script" and newGraphics[k].className ~= "Humanoid" and newGraphics[k].className ~= "Tool" then
			clone = newGraphics[k]:Clone()
			clone.Parent = vCharacter
		end		
		if newGraphics[k].Name == "Head" then				
			headChildren = newGraphics[k]:GetChildren()
			for b =1, #headChildren do 
				if headChildren[b].className == "Decal" or headChildren[b].className == "SpecialMesh" then							
					clone = headChildren[b]:Clone()							
					clone.Parent = vCharacter:FindFirstChild("Head")
				end
			end			
			local fakeHead = newGraphics[k]:Clone()
			fakeHead.Transparency = 0.0
			local fakeNeck			
			fakeHead.Name = "FakeHead"
			fakeHead.Parent = vCharacter 
			fakeHead.CFrame = newGraphics[k].CFrame
			local torso = vCharacter:FindFirstChild("Torso")
			if torso then 
				neck = torso:FindFirstChild("Neck")
				if neck then 
					fakeNeck = neck:Clone() 
					fakeNeck.Name = "FakeNeck"
					fakeNeck.Part1 = fakeHead 	
					fakeNeck.Part0 = torso
					fakeNeck.Parent = torso
				end
			end	
		end	
		if newGraphics[k].Name == "Torso" then 
			torsoChildren = newGraphics[k]:GetChildren()
			for y=1, #torsoChildren do 
				if torsoChildren[y].className == "Decal" then 
					clone = torsoChildren[y]:Clone()
					clone.Parent = vCharacter:FindFirstChild("Torso")
				end
			end
		end
	end
end

function restoreCharacter()
	while duration > 0 do 
		duration = duration - 1
		wait(1.0)
	end
	if insertTable ~= nil then 
		if morphResetSound then morphResetSound:Play() end
		graphics = vCharacter:GetChildren()
		for j = 1, #graphics do 
			if graphics[j].className ~= "Part" and graphics[j].className ~= "Script" and graphics[j].className ~= "LocalScript" and graphics[j].className ~= "Humanoid" and graphics[j].className ~= "Tool" then 				
				graphics[j]:Remove()					
			end
			if graphics[j].Name == "FakeHead" then
				graphics[j]:Remove()
			end
			if graphics[j].Name == "Head" then
				graphics[j].Transparency = 0.0
				headChildren = graphics[j]:GetChildren()
				for a =1, #headChildren do 
					if headChildren[a].className == "Decal" or headChildren[a].className == "SpecialMesh" then							
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
		for i, v in pairs(brickColorTable) do
			if vCharacter:FindFirstChild(i) then 
				vCharacter:FindFirstChild(i).BrickColor = v
			end
		end
	end
end

function applyTexture(texture, part)
	if part == nil or texture  == nil then return end
	local characterMeshCount = 0 -- This needs to be 6, ideally
	local children = vCharacter:GetChildren()
	for i = 1, #children do
		if children[i].className == "CharacterMesh" then 
			characterMeshCount = characterMeshCount + 1
			children[i].OverlayTextureId = texture
		end
		if children[i].className == "Hat" and children[i]:FindFirstChild("Handle") and children[i].Handle:FindFirstChild("Mesh") then
			children[i].Handle.Mesh.TextureId = "http://www.roblox.com/asset/?id=" .. texture
		end
		if children[i].className == "Shirt" or children[i].className == "Pants" then
			children[i]:Remove()
		end
		if children[i].Name == "Head" then 
			children[i].Transparency = 1.0				
			if children[i]:FindFirstChild("face") then 
				children[i].face:Remove()
			end
			if vCharacter:FindFirstChild("FakeHead") then 
				vCharacter.FakeHead:Remove()
			end
			local fakeHead = children[i]:Clone()
			fakeHead.Transparency = 0.0
			local fakeNeck			
			fakeHead.Name = "FakeHead"
			fakeHead.Parent = vCharacter 
			fakeHead.CFrame = children[i].CFrame
			local torso = vCharacter:FindFirstChild("Torso")
			if torso then 
				neck = torso:FindFirstChild("Neck")
				if neck then 
					fakeNeck = neck:Clone() 
					fakeNeck.Name = "FakeNeck"
					fakeNeck.Part1 = fakeHead 	
					fakeNeck.Part0 = torso
					fakeNeck.Parent = torso
				end
			end	
			if fakeHead:FindFirstChild("Mesh") then 		
				print(1.1)
				fakeHead.Mesh.TextureId = "http://www.roblox.com/asset/?id=" .. texture
				fakeHead.Transparency = 0.0
			end
		end	
	end
	if characterMeshCount < 6 then 
		for i = 1, #children do 
			if children[i].className == "Part" then 
				children[i].BrickColor = part.BrickColor
			end
		end		
	end
end

function reform()
	local meshTexture 
	local part
	changeTo = script:FindFirstChild("ChangeTo")
	if changeTo == nil then return end

	part = changeTo.Value	

	local humanoid = part.Parent:FindFirstChild("Humanoid")
	
	if part.Parent.className == "Hat" or part.Parent.className == "Tool" then
		humanoid = part.Parent.Parent:FindFirstChild("Humanoid")
	end
	
	if humanoid  then 		
		copyCharacter(humanoid.Parent)		
		if restoreCo == nil or coroutine.status(restoreCo) == "dead" then
			restoreCo = coroutine.create(restoreCharacter)
			coroutine.resume(restoreCo)
		else 
			duration = 30
		end
		return
	end

	if part:FindFirstChild("Mesh") then 	
		print(1)
		local pos = string.find(part.Mesh.TextureId, "=")
		if pos > 0 then 
			local urlTextureId = tonumber(string.sub(part.Mesh.TextureId, pos+1))			
			if restoreCo == nil or coroutine.status(restoreCo) == "dead" then
				restoreCo = coroutine.create(restoreCharacter)
				coroutine.resume(restoreCo)
				print(urlTextureId)
				applyTexture(urlTextureId, part)
			else 
				duration = 30
			end
		return
		end		
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then		
		local ch = vCharacter:GetChildren()
		for i  = 1, #ch do
			if ch[i].className == "CharacterMesh" then
				ch[i]:Remove()
			end
			if ch[i].className == "Hat" then
				ch[i]:Remove()
			end
			if ch[i].className == "Part" then 
				ch[i].BrickColor = part.BrickColor
			end
			if ch[i].className == "Shirt" or ch[i].className == "Pant" then 
				ch[i]:Remove() 
			end
			if ch[i].Name == "Head" then 
				ch[i].Transparency = 1.0				
				if ch[i]:FindFirstChild("face") then 
					ch[i].face:Remove()
				end
				if vCharacter:FindFirstChild("FakeHead") then 
					vCharacter.FakeHead:Remove()
				end
				local fakeHead = ch[i]:Clone()				
				fakeHead.Transparency = 0.0
				local fakeNeck
				fakeHead.Name = "FakeHead"
				fakeHead.Parent = vCharacter 
				fakeHead.CFrame = ch[i].CFrame
				local torso = vCharacter:FindFirstChild("Torso")
				if torso then 
					neck = torso:FindFirstChild("Neck")
					if neck then 
						fakeNeck = neck:Clone() 
						fakeNeck.Name = "FakeNeck"
						fakeNeck.Part1 = fakeHead 	
						fakeNeck.Part0 = torso
						fakeNeck.Parent = torso
					end
				end				
			end
		end
	end
	if restoreCo == nil or coroutine.status(restoreCo) == "dead" then
		restoreCo = coroutine.create(restoreCharacter)
		coroutine.resume(restoreCo)
	else 
		duration = 30
	end
end

storeCharacter()
reform()

changeTo.Changed:connect(reform)


wait(120)
restoreCharacter()
script:Remove()

