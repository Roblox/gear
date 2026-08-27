local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child]
end 

local Tool = script.Parent 
local Book = Tool.Handle

local vCharacter
local vTorso
local vHead 
local vHumanoid

local vPlayer
local PlayerGui

local MaxRange = 30

local LowerBound = nil
local UpperBound = nil

local debris = game:GetService("Debris")
local r = game:GetService("RunService")

local SCROLL_SPEED = 0.5 

Tool.Enabled = true

local AORGui 
local AORGui_Id = 114481858
local AORFrame 
local RBX_InsertService = game:GetService("InsertService") 
local RBX_AssetLoader = RBX_InsertService.LoadAsset 
local RBX_ContentProvider = game:GetService("ContentProvider") 

local NextPage_ImageButton
local LastClick = tick()
local PageCount = 1 

local function GetAABB()
	local torsoXAxis = vTorso.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)).unit
	local torsoYAxis = vTorso.CFrame:vectorToWorldSpace(Vector3.new(0, 1, 0)).unit
	local torsoZAxis = vTorso.CFrame:vectorToWorldSpace(Vector3.new(0, 0, 1)).unit
	LowerBound = nil
	UpperBound = nil
	-- create bounding box for blinking
	charChildren = vCharacter:GetChildren()
	for i = 1, #charChildren do
		local handle = nil
		if charChildren[i].className == "Hat" or charChildren[i].className == "Tool" then
			handle = charChildren[i]:FindFirstChild("Handle")
		elseif charChildren[i].className == "Part" then
			handle = charChildren[i]
		end
		if handle ~= nil then
			lowCornerTC = handle.CFrame:vectorToWorldSpace(-handle.Size / 2) + handle.Position - vTorso.Position
			highCornerTC = handle.CFrame:vectorToWorldSpace(handle.Size / 2) + handle.Position - vTorso.Position
			if LowerBound == nil then LowerBound = lowCornerTC end
			if UpperBound == nil then UpperBound = highCornerTC end
			LowerBound = Vector3.new(math.min(LowerBound.X, lowCornerTC.X), math.min(LowerBound.Y, lowCornerTC.Y), math.min(LowerBound.Z, lowCornerTC.Z))
			UpperBound = Vector3.new(math.max(UpperBound.X, lowCornerTC.X), math.max(UpperBound.Y, lowCornerTC.Y), math.max(UpperBound.Z, lowCornerTC.Z))
			LowerBound = Vector3.new(math.min(LowerBound.X, highCornerTC.X), math.min(LowerBound.Y, highCornerTC.Y), math.min(LowerBound.Z, highCornerTC.Z))
			UpperBound = Vector3.new(math.max(UpperBound.X, highCornerTC.X), math.max(UpperBound.Y, highCornerTC.Y), math.max(UpperBound.Z, highCornerTC.Z))
		end
	end
end

local function TeleportForward()
	local torsoPos = vTorso.Position
	local headPos = vHead.Position
	hum = vCharacter:FindFirstChild("Humanoid")
	if hum == nil then return end
	Tool.Enabled = false
	GetAABB()
	print(LowerBound)
	print(UpperBound)
	hum.WalkSpeed = 0


	local newBG = vTorso:FindFirstChild("TinyFloat")
	if newBG == nil then
		newBG = Instance.new("BodyPosition")
		newBG.position = vTorso.Position + Vector3.new(0, 0.5, 0)
		newBG.P = 1000000
		newBG.maxForce = Vector3.new(0, newBG.P, 0)
		newBG.Name = "TinyFloat"
		newBG.Parent = vTorso
	end

	-- changed torsoPos for headPos here...
	local teleportSpot = hum.TargetPoint * Vector3.new(1, 0, 1) + Vector3.new(0, headPos.Y, 0)
	local teleportDir = (teleportSpot - headPos).unit	
	local charWidth = UpperBound.Z - LowerBound.Z
	local teleRise = UpperBound.Y - LowerBound.Y

	tZ = teleportDir
	tY = Vector3.new(0, 1, 0)
	tX = tZ:Cross(tY).unit
	
	local smoker = Instance.new("Part")
	smoker.Name = "NinjaSmoke"
	smoker.Transparency = 1
	smoker.CanCollide = false
	smoker.Anchored = true
	smoker.CFrame = vTorso.CFrame - Vector3.new(0, 4, 0)
	smoker.Parent = game.Workspace

	local smoke = Instance.new("Smoke")
	smoke.Name = "smoke"
	smoke.Color = Color3.new(.3,0,.3)
	smoke.Opacity = .9
	smoke.RiseVelocity = 2
	smoke.Parent = smoker

	local smoke2 = Instance.new("Smoke")
	smoke2.Name = "smoke2"
	smoke2.Color = Color3.new(.5, 0, .5)
	smoke2.Opacity = .8
	smoke2.RiseVelocity = 3
	smoke2.Parent = smoker

	local collision = false
	local parts = {}
	for i = MaxRange, charWidth, -charWidth do ---charWidth/2 do
		teleportSpot = torsoPos + i*teleportDir
		parts = game.Workspace:FindPartsInRegion3(Region3.new(teleportSpot+LowerBound, teleportSpot+UpperBound), vCharacter, 100)
		collision = false
		for p = 1, #parts do
			if parts[p] ~= nil and parts[p].CanCollide then collision = true break end
		end
		if not collision then
			-- teleport!!
			wait(1)
			hum.WalkSpeed = 16
			if newBG ~= nil then newBG:remove() end
			vTorso.CFrame = CFrame.new(teleportSpot, teleportSpot+tZ)			
			break
		end

		-- try lifting teleportSpot a bit before discounting it as blocked
		teleportSpot = teleportSpot + Vector3.new(0, teleRise, 0)
		parts = game.Workspace:FindPartsInRegion3(Region3.new(teleportSpot+LowerBound, teleportSpot+UpperBound), vCharacter, 100)
		collision = false
		for p = 1, #parts do
			if parts[p] ~= nil and parts[p].CanCollide then collision = true break end
		end
		if not collision then			
			wait(1)
			hum.WalkSpeed = 16
			if newBG ~= nil then newBG:remove() end
			vTorso.CFrame = CFrame.new(teleportSpot, teleportSpot+tZ)			
			break
		end
	end
	smoker.smoke.RiseVelocity = .5
	smoker.smoke2.RiseVelocity = .75
	wait(1)
	smoker:remove()
	hum.WalkSpeed = 16
	if newBG ~= nil then newBG:remove() end
end

local function OnActivated()
	if Tool.Enabled == false then
		return 
	end 
	wait(0.2) 	
	print(AORFrame) 
	if AORFrame then  	
		AORFrame.Visible = true 
	end 
	Tool.Enabled = true  
end 

local function OnEquipped()
	-- This is dumb 
	-- Need to fix the UnequipTools() API call to actually fire the unequipped signal 
	Tool.Enabled = true 
	vCharacter = Tool.Parent 
	vTorso = vCharacter:FindFirstChild('Torso') or vCharacter:FindFirstChild("UpperTorso")
	vHumanoid = vCharacter:WaitForChild('Humanoid') 
	vHead = vCharacter:WaitForChild('Head') 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	PlayerGui = waitForChild(vPlayer, "PlayerGui")
	if AORGui then 
		AORGui.Parent = PlayerGui
	else 
		AORGui = RBX_AssetLoader(RBX_InsertService, AORGui_Id):GetChildren()[1] 
		AORGui.Parent = PlayerGui 
	end 
	AORFrame = waitForChild(AORGui, "AORFrame") 	
	AORFrame.Visible = false 
	print(AORFrame) 
	local fChildren = AORFrame:GetChildren()
	for i = 1, #fChildren do 
		if i == 1 then 
			fChildren[i].ZIndex = 9
		else 
			fChildren[i].ZIndex = 1
		end 
		fChildren[i].Visible = true 
	end 
	NextPage_ImageButton = waitForChild(AORFrame, "Next")
	NextPage_ImageButton.ZIndex = 10 
	NextPage_ImageButton.MouseButton1Click:connect(function()
		if tick() < LastClick + SCROLL_SPEED then
			return
		end
		LastClick = tick()
		PageCount = PageCount + 1 
		if PageCount > 13 then
			PageCount = 1 
			vHumanoid:UnequipTools()  
			TeleportForward() 			
		end 
		local fChildren = AORFrame:GetChildren()
		for i = 1, #fChildren do 
			if fChildren[i].Name == tostring(PageCount) and fChildren[i]:IsA("ImageLabel") then 
				fChildren[i].ZIndex = 9
			elseif fChildren[i]:IsA("ImageButton") then 
				fChildren[i].ZIndex = 10
			else 
				fChildren[i].ZIndex = 1
			end  
		end  
	end) 
end 

local function OnUnequipped()
	if AORGui then 
		AORGui.Parent = nil 
	end  	
end 

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
