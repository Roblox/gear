function getRandomValue(table)
	return table[math.random(#table)]
end

HATS = {
	48474294, -- Pinktastic Hair
	51353039, -- Bloxxer Cap
	18174901, -- Guardia in Exile
	30200035,
	48474313,
	19027209,
	16630147,
	19398258,
	16412796
}

HEADS = {
	6340213,
	6340101,
	6340227,
}

FACES = {
	"http://www.roblox.com/asset/?id=7074749", -- Chill
	"rbxasset://textures/face.png",
	"rbxasset://textures/face.png",
}

SHIRTS = {
	"http://www.roblox.com/asset/?id=8561740", -- Guest Shirt
	"http://www.roblox.com/asset/?id=3039068",
}

TEESHIRTS = {
		"http://www.roblox.com/asset/?id=1028594", -- Bloxxer
}

SKIN_COLORS = {
	BrickColor.new("Bright yellow"),
	BrickColor.new("Pastel brown"),
	BrickColor.new("Institutional white")
}

function getDummy()
	
	local dummy = game:GetService("InsertService"):LoadAsset(124120704):GetChildren()[1]
	
	local skinColor = getRandomValue(SKIN_COLORS)
	dummy.Head.BrickColor = skinColor
	dummy["Right Arm"].BrickColor = skinColor
	dummy["Left Arm"].BrickColor = skinColor
	
	if math.random() > .7 then
		dummy.Head.Mesh:Destroy()
		game:GetService("InsertService"):LoadAsset(getRandomValue(HEADS)):GetChildren()[1].Parent = dummy.Head
	end
	
	game:GetService("Debris"):AddItem(dummy, 30)
	dummy.Humanoid.Died:connect(function()
		dummy:Destroy()
	end)
	
	dummy.Torso.BrickColor = BrickColor.random()
	dummy["Left Leg"].BrickColor = BrickColor.random()
	dummy["Right Leg"].BrickColor = BrickColor.random()
	
	local shirtTest = math.random()
	if shirtTest < .5 then
		dummy.Torso.Decal.Texture = getRandomValue(TEESHIRTS)
	elseif shirtTest < .7 then
		dummy.Shirt.ShirtTemplate = getRandomValue(SHIRTS)
	end		
		
	
	dummy.Head.face.Texture = getRandomValue(FACES)
	dummy.Name = script.Parent.Parent.Name .. "'s Fan"
	
	return dummy
end

Tool = script.Parent

function getFans()
	local count = 0
	for _, child in pairs(Workspace:GetChildren()) do
		if child.Name == Tool.Parent.Name .. "'s Fan" then
			count = count + 1
		end
	end
	return count
end

Tool.Enabled = true
function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	Tool.Handle.Boing:play()
	Tool.Handle.Transparency = .5
	
	for i = 1, 6 do
		if getFans() <= 12 then
			local dummy = getDummy()
			dummy.Humanoid.WalkSpeed = math.random(11, 15)
			local torso = script.Parent.Parent:FindFirstChild("Torso") or script.Parent.Parent:FindFirstChild("UpperTorso")
			dummy.Target.Value = torso
			dummy.Parent = Workspace
			dummy.Head:MakeJoints()
			wait()
			if math.random() > .2 then
				game:GetService("InsertService"):LoadAsset(getRandomValue(HATS)):GetChildren()[1].Parent = dummy
			end
			
			local torsoPosition = torso.Position
			
			local x = torsoPosition.X
			local z = torsoPosition.Z
			dummy:MoveTo(Vector3.new(math.random(x - 10, x + 10), torsoPosition.Y, math.random(z - 10, z + 10)))
		end
	end

	wait(14)

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)