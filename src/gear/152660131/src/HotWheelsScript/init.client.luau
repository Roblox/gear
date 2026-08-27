local ASSETS = 
{
	CarMesh = 149408914;
	CarTX = 152653238;
	Icon = 152653157;
}


local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Character = nil
local Torso = nil
local Humanoid = nil
local CarPrefab = Game:GetService("InsertService"):LoadAsset(147928844):GetChildren()[1]
--local CarPrefab = Game.ReplicatedStorage.Car:Clone()
local MyMouse = nil
local Camera = Workspace.CurrentCamera

local CurrentCar = newCar

local GuiPrefab = script:WaitForChild('HWGui')

local CurrentGui = nil

local function DestroyCar()
	--print("Calling unitialized destroy car func")
end

function OnActivated()
	if not Tool.Enabled then return end
	if Character and Torso and Humanoid then
		Tool.Enabled = false
		Humanoid.WalkSpeed = 0
		DestroyCar()
		Handle.Transparency = 1
		CurrentCar = CarPrefab:Clone()
		CurrentCar:TranslateBy((Torso.CFrame.p + Torso.CFrame.lookVector * 3)  - CurrentCar:GetModelCFrame().p)
		CurrentCar.Parent = Camera
		
		local CurrentCarMesh = CurrentCar and CurrentCar:FindFirstChild('Chassis') and CurrentCar:FindFirstChild('Chassis'):FindFirstChild('Mesh')
		CurrentCarMesh.MeshId = "http://www.roblox.com/asset?id=" .. tostring(ASSETS['CarMesh'])
		CurrentCarMesh.TextureId = "http://www.roblox.com/asset?id=" .. tostring(ASSETS['CarTX'])
		
		CurrentGui = GuiPrefab:Clone()
		if Player and Player:FindFirstChild('PlayerGui') then
			CurrentGui.Parent = Player:FindFirstChild('PlayerGui')
		end
		Camera.CameraSubject = CurrentCar
		Camera.CameraType = 'Follow'
		local newCarScript = CurrentCar:WaitForChild('HWCarScript')
		local SteeringEvent = newCarScript:WaitForChild('SteeringEvent')
		local ThrottleEvent = newCarScript:WaitForChild('ThrottleEvent')
		local ThrottleEvent = newCarScript:WaitForChild('ThrottleEvent')
		newCarScript.Parent = Character
		
		DestroyCar = function()
			if CurrentCar then
				CurrentCar:Destroy()
				CurrentCar = nil
			end
			if newCarScript then
				newCarScript:Destroy()
				newCarScript = nil
			end
			if CurrentGui then
				CurrentGui:Destroy()
				CurrentGui = nil
			end
			Handle.Transparency = 0
		end
		
		local function onCharDied()
			DestroyCar()
			if Humanoid then
				if Camera then
					Camera.CameraSubject = Humanoid
					Camera.CameraType = 'Custom'
				end
				Humanoid.WalkSpeed = 16
			end
		end
		
		Humanoid.Died:connect(onCharDied)
		
		Spawn(function()
			while true do
				wait()
				if Character ~= Player.Character or (CurrentCar and (CurrentCar.Parent == nil or CurrentCar:GetModelCFrame().p.Y < -300)) then
					onCharDied()
				end
			end
		end)
		if MyMouse then
			local downKeys = { [string.byte('s')] = false; [string.byte('w')] = false; [string.byte('a')] = false; [string.byte('d')] = false }
			local function UpdateEvents()
				--FireServer
				local rightArrow = 19
				local leftArrow = 20
				local forwardArrow = 17
				local backArrow = 18
				ThrottleEvent:Fire(((downKeys[string.byte('w')] or downKeys[forwardArrow]) and 1 or 0) + ((downKeys[string.byte('s')] or downKeys[backArrow]) and -1 or 0))
				SteeringEvent:Fire(((downKeys[string.byte('d')] or downKeys[rightArrow]) and 1 or 0) + ((downKeys[string.byte('a')] or downKeys[leftArrow]) and -1 or 0))
			end
			MyMouse.KeyDown:connect(function(key)
				key = string.lower(key)
				downKeys[string.byte(key)] = true
				UpdateEvents()
			end)
			MyMouse.KeyUp:connect(function(key)
				key = string.lower(key)		
				downKeys[string.byte(key)] = false
				UpdateEvents()
			end)
			UpdateEvents()
		else
			print("No mouse found")
		end
		newCarScript.Disabled = false
		
		wait(5) -- Cooldown
		Tool.Enabled = true
	else
		print("Couldn't find Torso")
	end
end

function OnEquipped(mouse)	
	Handle.Transparency = 0
	Character = Tool.Parent
	Player = Game:GetService('Players'):GetPlayerFromCharacter(Character)
	Torso = Character:FindFirstChild('Torso') or Character:FindFirstChild("UpperTorso")
	Humanoid = Character:WaitForChild('Humanoid')
	MyMouse = mouse
	Player.CharacterAdded:connect(function()
		Camera.CameraSubject = Humanoid
		Camera.CameraType = 'Custom'
	end)
end

function OnUnequipped()
	DestroyCar()
	if Humanoid then
		if Camera then
			Camera.CameraSubject = Humanoid
			Camera.CameraType = 'Custom'
		end
		Humanoid.WalkSpeed = 16
	end
end

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

local HandleMesh = Handle and Handle:FindFirstChild('Mesh')

HandleMesh.MeshId = "http://www.roblox.com/asset?id=" .. tostring(ASSETS['CarMesh'])
HandleMesh.TextureId = "http://www.roblox.com/asset?id=" .. tostring(ASSETS['CarTX'])
Tool.TextureId = "http://www.roblox.com/asset/?id=" .. tostring(ASSETS['Icon'])
