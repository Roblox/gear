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

local Outfits = {	
					[1] = {	["Shirt"] = 91454725},
					[2] = {	["Pants"] = 91490599, ["Shirt"] = 91489746}, 
					[3] = {	["Shirt"] = 91488794,
								["Package"] =	{	
												["LeftArm"] = {46345362,46344860,46345222},
												["LeftLeg"] = {46345362,46344898,46345222},
												["RightArm"] = {46345362,46345037,46345222},
												["RightLeg"] = {46345362,46344972,46345222},
												["Torso"] = {46345362,46345096,46345222}
													}
							},
					[4] = {	["Package"] =	{	
												["LeftArm"] = {0,50321442,50322018},
												["LeftLeg"] = {0,50321575,50322018},
												["RightArm"] = {0,50321932,50322018},
												["RightLeg"] = {0,50322376,50322018},
												["Torso"] = {50322018,50321523,50322018}
													}
							}
						}

local Character = script.Parent
local OutfitNumber = WaitForChild(script,"OutfitNumber")

local OutfitItems = Outfits[OutfitNumber.Value]

local hum = Character:FindFirstChild("Humanoid")
local torso = Character:FindFirstChild("Torso")
local head = Character:FindFirstChild("Head")
if hum and torso and head then
	local oldHeadColor = head.BrickColor
	local curCam = game.Workspace.CurrentCamera
	local oldShirt = Character:FindFirstChild("Shirt")
	local oldTShirt = Character:FindFirstChild("TShirt")
	local oldPants = Character:FindFirstChild("Pants")
	local oldClothing = {oldShirt, oldTShirt, oldPants}

	local newClothing = {}

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


	if Character then
		for i, item in pairs(oldClothing) do
			if item then item.Parent = Character end
		end
	end
	for i, v in pairs(newClothing) do
		if v then v:Destroy() end
	end

end

script:Destroy()

