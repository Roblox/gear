function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local FROG_ASSET_ID = 106808835
local GLib = require(206209239)

local Handle = script.Parent
local Tool = Handle.Parent
local Character
local Humanoid
local SludgeMesh = WaitForChild(Tool, "SludgeMesh")
local FrogScript = WaitForChild(Handle, "FrogScript")

local SludgeSound = WaitForChild(Handle, 'Sludge')
local MagicSound = WaitForChild(Handle, 'Magic')

local charWelds = {}

function saveWelds(model, weldTable)
	if model:IsA("JointInstance") then
		weldTable[model] = model.Parent
	end
	for _, v in pairs(model:GetChildren()) do
		saveWelds(v, weldTable)
	end
end

function storeWelds(char)
	charWelds[char] = {}
	saveWelds(char, charWelds[char])
end

function returnWelds(char)
	for weld, weldParent in pairs(charWelds[char]) do
		weld.Parent = weldParent
	end
end

function removeToolsFromChar(char)
	local charParts = char:GetChildren()
	for i = 1, #charParts do
		if charParts[i]:IsA("Tool") then
			charParts[i]:Remove() 
		end
	end
end

local InsertedFrog = game:GetService("InsertService"):LoadAsset(FROG_ASSET_ID)
local Froggy
if InsertedFrog then
	Froggy = InsertedFrog:GetChildren()[1]
end

--local Froggy = workspace.Froggy

function transformPlayer(player)
	--[[
	local newFroggy = Froggy:Clone()
	local newFrogScript = FrogScript:Clone()
	local oldCharacter = player.Character

	newFroggy:TranslateBy(oldCharacter:GetModelCFrame().p - newFroggy:GetModelCFrame().p)
	storeWelds(oldCharacter)
	oldCharacter.Parent = nil
	newFroggy.Parent = workspace
	player.Character = newFroggy
	newFrogScript.Parent = newFroggy
	newFrogScript.Disabled = false
	
	wait(20)
	newFroggy.Parent = nil
	returnWelds(oldCharacter)
	removeToolsFromChar(oldCharacter)
	oldCharacter.Parent = workspace
	player.Character = oldCharacter
	--]]
	
	local new = Instance.new'Part'
	new.Name = 'Frog'
	new.CanCollide = false
	new.Locked = true
	new.FormFactor = 'Custom'
	new.Size = Vector3.new(1,1,1)
	local mesh = script.FrogMesh:Clone()
	mesh.Parent = new
	local newScript = FrogScript:Clone()
	
	new:MakeJoints()
	local char = player.Character
	if char:FindFirstChild'Frog' then return end
	
	new.Parent = char
	newScript.Parent = char
	newScript.Disabled = false
	local w = Instance.new('Weld')
	w.Part0 = char.HumanoidRootPart
	w.Part1 = new
	w.C0 = CFrame.new(0, -3+1/2+0.05, 0)
	w.Parent = new
	
	local original = {} do
		for i,v in next, GLib.GetDescendants(char) do
			if v:IsA'BasePart' and v~=new then
				original[v] = {
					Transparency = v.Transparency
				}
				
				v.Transparency = 1
			elseif v:IsA'Decal' then
				original[v] = {
					Transparency = v.Transparency
				}
				
				v.Transparency = 1
			elseif v:IsA'Fire' or v:IsA'Sparkles' or v:IsA'Smoke' then
				original[v] = {
					Enabled = v.Enabled
				}
				
				v.Enabled = false
			end
		end
	end
	
	wait(20)
	new:Destroy()
	
	for v, p in next, original do
		for i,n in next, p do
			v[i] = n
		end
	end
	newScript:Destroy()
end

local playersToTransform = {}
function checkForEnemy(foundParts)
	local currTime = tick()
	for i = 1, #foundParts do
		local char = foundParts[i].Parent
		if char and char ~= Character and char.Name ~= "Froggy" then
			local player = game.Players:GetPlayerFromCharacter(char)
			if player and (not playersToTransform[player] or currTime - playersToTransform[player] > 10) then
				playersToTransform[player] = tick()
				delay(0, function() transformPlayer(player) end)
			end
		end
	end
end

function doSludge(sludge, sludgeMesh)
	local timeWaited = 0
	while timeWaited < 1 do
		timeWaited = timeWaited + wait()
		sludge.CFrame = sludge.CFrame * CFrame.Angles(0, math.pi/15, 0)
	end
	local foundParts = workspace:FindPartsInRegion3(Region3.new(sludge.CFrame.p - Vector3.new(1.5, .1, 1.5), sludge.CFrame.p + Vector3.new(1.5, 3, 1.5)), nil, 30)
	
	
	SludgeSound:Play()
	checkForEnemy(foundParts)
	
	local startCFrame = sludge.CFrame	
	timeWaited = 0
	while timeWaited < .5 do
		timeWaited = timeWaited + 3*wait()
		sludge.CFrame = startCFrame + Vector3.new(0, timeWaited*10, 0)
		sludgeMesh.Scale = Vector3.new(3, timeWaited*20, -3)
	end
	
	foundParts = workspace:FindPartsInRegion3(Region3.new(sludge.CFrame.p - Vector3.new(1.5, 5, 1.5), sludge.CFrame.p + Vector3.new(1.5, 5, 1.5)), nil, 30)
	
	checkForEnemy(foundParts)
	
	while timeWaited > 0 do
		timeWaited = timeWaited - 2*wait()
		sludge.CFrame = startCFrame + Vector3.new(0, timeWaited*10, 0)
		sludgeMesh.Scale = Vector3.new(3, timeWaited*20, -3)
	end
	
	sludge:Remove()
end


Tool.Enabled = false
function onActivated(hit)
	if not Humanoid or Tool.Enabled then return end
	Tool.Enabled = true
	MagicSound:Play()
	local newSludge = Instance.new("Part")
	newSludge.formFactor = "Custom"
	newSludge.Size = Vector3.new(1, 1, 1)
	newSludge.Reflectance = .01
	newSludge.Material = "Ice"
	newSludge.TopSurface = "Smooth"
	newSludge.BottomSurface = "Smooth"
	newSludge.BrickColor = BrickColor.new("Br. yellowish green")
	newSludge.CanCollide = false
	newSludge.Anchored = true
	newSludge.CFrame = CFrame.new(hit.p + Vector3.new(0, .25, 0))
	
	local newSludgeMesh = SludgeMesh:Clone()
	newSludgeMesh.Parent = newSludge

	newSludge.Parent = workspace
	delay(0, function() doSludge(newSludge, newSludgeMesh) end)	
	
	wait(.5)
	Tool.Enabled = false
end

function onEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
end

--Tool.Activated:connect(onActivated)
Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1' then
			local down, hit = ...
			
			if down then
				onActivated(hit)
			end
		end
	end
end)
Tool.Equipped:connect(onEquipped)
