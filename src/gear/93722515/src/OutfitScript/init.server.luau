--By QuantumSama

local DURATION = 30

function WaitForChild(parent, child)
	local result = parent:FindFirstChild(child)
	delay(3,function() if not result then print("Warning: Long wait for", child) end end)
	while not result do
		parent.ChildAdded:wait()
		result = parent:FindFirstChild(child)
	end
	return result
end

local Outfits = 
{	
	[1] = { ["Transparency"] = 1, --cursed hand
				["Mesh"] = {37241605,37241842,Vector3.new(3.2,3.2,3.2)}
			},
	[2] = { ["Transparency"] = 1, --floating eyeball
				["Mesh"] = {1185246,16855066,Vector3.new(3.2,3.2,3.2)}
			},
	[3] = {	["Shirt"] = 91488794, 
				["Package"] =	{	--Zombie
								["LeftArm"] = {0,63639263,63639334},
								["LeftLeg"] = {0,63639276,63639334},
								["RightArm"] = {0,63639283,63639334},
								["RightLeg"] = {0,63639288,63639334},
								["Torso"] = {0,63639291,63639334}
									},
				["Hat"] = {63639945,63639451,Vector3.new(1,1,1)}
			},
	[4] = {	["Package"] =	{ --werewolf
								["LeftArm"] = {0,37689083,37689298},
								["LeftLeg"] = {0,37689111,37689298},
								["RightArm"] = {0,37689140,37689298},
								["RightLeg"] = {0,37689206,37689298},
								["Torso"] = {0,37689237,37689298}
									},
				["Hat"] = {15010063,37689298, Vector3.new(1.65,1.5,1.5)}
			},
	[5] = { ["Transparency"] = .8}, --ghost
	[6] = {	["Package"] =	{	--mummy
								["LeftArm"] = {0,63637682,63637809},
								["LeftLeg"] = {0,63637691,63637809},
								["RightArm"] = {0,63637701,63637809},
								["RightLeg"] = {0,63637711,63637809},
								["Torso"] = {0,63637732,63637809}
									},
				["Hat"] = {63638055,63638307, Vector3.new(1,1,1)}
			},
	[7] = {	["Package"] =	{	--Skeleton
								["LeftArm"] = {0,36780032,36780292},
								["LeftLeg"] = {36780292,36780079,36780292},
								["RightArm"] = {0,36780156,36780292},
								["RightLeg"] = {0,36780195,36780292},
								["Torso"] = {0,36780113,36780292}
									},
				["Hat"] = {36869983,36869975, Vector3.new(1,1,1)}
			},
	[8] = { ["Transparency"] = 1, --pumpkin
				["Mesh"] = {1158007,5251789,Vector3.new(1.35,1.35,1.35)}
			},
	[9] = { ["Transparency"] = 1, --bat
				["Hat"] = {37223772,37223767,Vector3.new(2.5,2.5,2.5)}
			},
	[10] = { ["Transparency"] = 1, --spider
				["Mesh"] = {64485380,80857256,Vector3.new(3.5,3.5,3.5), CFrame.new(0,-1.3,0)}
			},
	[11] = { ["Transparency"] = 1, --Specter
				["Mesh"] = {42579239,42578558,Vector3.new(9,9,9)}
			},
	[12] = { ["Transparency"] = 1, --terrordactyl
				["Mesh"] = {64041667,64041707,Vector3.new(3,3,3)}
			},
	[13] = { ["Transparency"] = 1, --Evil Duck
				["Mesh"] = {14810664,14810649,Vector3.new(6.5,6.5,6.5), CFrame.new(0,-.4,0)}
			}
}

local Character = script.Parent
local newClothing = {}
local oldClothing = {}

function TakeOffOutfit()
	if Character then
		for i, item in pairs(oldClothing) do
			if item then item.Parent = Character end
		end
		for i,part in pairs(Character:GetChildren()) do
			if part:IsA("Part") then
				part.Transparency = 0
			end
			if part:IsA("Hat") then
				local handle = part:FindFirstChild("Handle")
				if handle then handle.Transparency = 0 end
			end
		end
		local head = Character:FindFirstChild("Head")
		if head then 
			for i,decal in pairs(head:GetChildren()) do
				if decal:IsA("Decal") then 
					decal.Transparency = 0
				end
			end
		end
	end
	oldClothing = {}
	for i, v in pairs(newClothing) do
		if v then v:Destroy() end
	end
	newClothing = {}
end


local outfitChanges = 0

function SetOutfit(outfitNumber)
	print('wearing outfit', outfitNumber)
	outfitChanges = outfitChanges+1
	TakeOffOutfit()
	local OutfitItems = Outfits[outfitNumber]
	if not OutfitItems then print('bad outfit number') return end
	
	local hum = Character:FindFirstChild("Humanoid")
	local torso = Character:FindFirstChild("Torso")
	local head = Character:FindFirstChild("Head")
	if hum and torso and head then
		local oldHeadColor = head.BrickColor
		local curCam = game.Workspace.CurrentCamera
		local oldShirt = Character:FindFirstChild("Shirt")
		local oldTShirt = Character:FindFirstChild("TShirt")
		local oldPants = Character:FindFirstChild("Pants")
		oldClothing = {oldShirt, oldTShirt, oldPants}
	
		newClothing = {}
		if OutfitItems["Transparency"] then
			for i,part in pairs(Character:GetChildren()) do
				if part:IsA("Part") then
					part.Transparency = OutfitItems["Transparency"]
				end
				if part:IsA("Hat") then
					local handle = part:FindFirstChild("Handle")
					if handle then handle.Transparency = OutfitItems["Transparency"] end
				end
			end
			for i,decal in pairs(head:GetChildren()) do
				if decal:IsA("Decal") then 
					decal.Transparency = OutfitItems["Transparency"]
				end
			end
		end
		if OutfitItems["Shirt"] then
			if oldShirt then oldShirt.Parent = nil end
			local newShirt = Instance.new("Shirt")
			newShirt.ShirtTemplate = "http://www.roblox.com/asset/?id=" .. OutfitItems["Shirt"]
			newShirt.Parent = Character
			table.insert(newClothing, newShirt)
		end
		if OutfitItems["Pants"] then
			if oldPants then oldPants.Parent = nil end
			local newPants = Instance.new("Pants")
			newPants.PantsTemplate = "http://www.roblox.com/asset/?id=" .. OutfitItems["Pants"]
			newPants.Parent = Character
			table.insert(newClothing, newPants)
		end
		if OutfitItems["Hat"] then
			local hatPart = Instance.new("Part")
			hatPart.CanCollide = false
			hatPart.FormFactor = "Custom"
			hatPart.Size = Vector3.new(.5,.5,.5)
			local hatMesh = Instance.new("SpecialMesh")
			hatMesh.MeshId = "http://www.roblox.com/asset/?id=" .. OutfitItems["Hat"][1]
			hatMesh.TextureId = "http://www.roblox.com/asset/?id=" .. OutfitItems["Hat"][2]
			hatMesh.Scale = OutfitItems["Hat"][3]
			hatMesh.Parent = hatPart
			hatPart.Parent = Character
			local hatWeld = Instance.new("Weld")
			hatWeld.Part0 = hatPart
			hatWeld.Part1 = head
			hatWeld.Parent = hatPart
			table.insert(newClothing, hatPart)
		end
		if OutfitItems["Mesh"] then
			local meshPart = Instance.new("Part")
			meshPart.CanCollide = false
			meshPart.FormFactor = "Custom"
			meshPart.Size = Vector3.new(.5,.5,.5)
			local partMesh = Instance.new("SpecialMesh")
			partMesh.MeshId = "http://www.roblox.com/asset/?id=" .. OutfitItems["Mesh"][1]
			partMesh.TextureId = "http://www.roblox.com/asset/?id=" .. OutfitItems["Mesh"][2]
			partMesh.Scale = OutfitItems["Mesh"][3]
			partMesh.Parent = meshPart
			meshPart.Parent = Character
			local meshWeld = Instance.new("Weld")
			meshWeld.Part0 = meshPart
			meshWeld.Part1 = torso
			if OutfitItems["Mesh"][4] then
				meshWeld.C1 = OutfitItems["Mesh"][4]
			end
			meshWeld.Parent = partMesh
			table.insert(newClothing, meshPart)
		end
		if OutfitItems["Package"] then
			for i, v in pairs(Character:GetChildren()) do
				if v:IsA("CharacterMesh") then
					v.Parent = nil
					table.insert(oldClothing, v)
				end
			end
			for bodyPart, ids in pairs(OutfitItems["Package"]) do
				local newMesh = Instance.new('CharacterMesh')
				newMesh.BodyPart = bodyPart
				newMesh.BaseTextureId = ids[1]
				newMesh.MeshId = ids[2]
				newMesh.OverlayTextureId = ids[3]
				newMesh.Parent = Character
				table.insert(newClothing,newMesh)
			end
		end
	
		wait(DURATION)

	end
	outfitChanges = outfitChanges - 1
	if outfitChanges == 0 then
		TakeOffOutfit()
		script:Destroy()
	end
end


local OutfitNumber = WaitForChild(script,"OutfitNumber")

OutfitNumber.Changed:connect(function() wait() SetOutfit(OutfitNumber.Value) end)

SetOutfit(OutfitNumber.Value)