-----------------------
--|    Variables    |--
-----------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Players = Game:GetService('Players')

-----------------------
--|       GUI       |--
-----------------------
local ScreenGui = Tool:WaitForChild('ScreenGui')
local Frame = ScreenGui:WaitForChild('Frame')
local Btn = Frame:WaitForChild('TextButton')
local FillBar = Frame:WaitForChild('TextLabel')
--
local ChargeStartTime = 0
--
local IsFired = false
local CanFire = true
local TheCharacter = nil
math.randomseed(tick())

-----------------------
--|    Constants    |--
-----------------------
local FIRE_DEBOUNCE_TIME = 0.25
local MAX_CHARGE_TIME = 1.5

-----------------------
--|    Animations   |--
-----------------------
local CannonHold = Tool:WaitForChild('CannonHoldAnim')
local CannonHoldTrack = nil
local ChargeShotBegin = Tool:WaitForChild('ChargeShotBegin')
local ChargeShotBeginTrack = nil
local ChargeShotEnd = Tool:WaitForChild('ChargeShotEnd')
local ChargeShotEndTrack = nil
local ChargeLoop = Tool:WaitForChild('ChargeLoop')
local ChargeLoopTrack = nil

-----------------------
--|     Sounds      |--
-----------------------
local FireSoundId = 'http://www.roblox.com/asset/?id=' .. tostring(146956281)
local FireSound = Instance.new('Sound')
FireSound.SoundId = FireSoundId
FireSound.Parent = Handle
--
local FuseSoundId = 'http://www.roblox.com/asset/?id=' .. tostring(150908373)
local FuseSound = Instance.new('Sound')
FuseSound.SoundId = FuseSoundId
FuseSound.Parent = Handle
--
local KillSoundId = 'http://www.roblox.com/asset/?id=' .. tostring(150929027)
local KillSound = Instance.new('Sound')
KillSound.SoundId = KillSoundId
KillSound.Parent = Handle
--
local DeathSoundId = 'http://www.roblox.com/asset/?id=' .. tostring(150930819)
local DeathSound = Instance.new('Sound')
DeathSound.SoundId = DeathSoundId
DeathSound.Volume = 0.5
DeathSound.Parent = Handle 
--
local ArrSounds = {}
--
local ArrSound1Id = 'http://www.roblox.com/asset/?id=' .. tostring(150904011)
local ArrSound1 = Instance.new('Sound')
ArrSound1.SoundId = ArrSound1Id
ArrSound1.Parent = Handle
table.insert(ArrSounds, ArrSound1)
--
local ArrSound2Id = 'http://www.roblox.com/asset/?id=' .. tostring(150904797)
local ArrSound2 = Instance.new('Sound')
ArrSound2.SoundId = ArrSound2Id
ArrSound2.Parent = Handle
table.insert(ArrSounds, ArrSound2)
--
local ArrSound3Id = 'http://www.roblox.com/asset/?id=' .. tostring(150905232)
local ArrSound3 = Instance.new('Sound')
ArrSound3.SoundId = ArrSound3Id
ArrSound3.Parent = Handle
table.insert(ArrSounds, ArrSound3) 

-----------------------
--|  Remote Events  |--
-----------------------
local RemoteEvents = Tool:WaitForChild('RemoteEvents')
local FireEvent = RemoteEvents:WaitForChild('OnFire')
local ChargeEvent = RemoteEvents:WaitForChild('OnCharge')
local PlayerKilledEvent = RemoteEvents:WaitForChild('OnKilledPlayer')

-----------------------
--|     Events      |--
-----------------------
local function onPlayerKilled()
	KillSound:Play()
end

local function StartFillBar()
	local xScale = 0
	while not IsFired and xScale < 1 do
		xScale = math.min((tick() - ChargeStartTime) / MAX_CHARGE_TIME, 1)
		FillBar.Size = UDim2.new(xScale, 0, 1, 0)
		wait()
	end
	if not IsFired then
		FillBar.BackgroundColor3 = Color3.new(203 / 255, 0, 0)
	end
end

local function EndFillBar()
	local t = 0
	local deltaTime = tick()
	while t < 0.25 do
		local xScale = math.max(0, 1 - (t / 0.25))
		FillBar.Size = UDim2.new(xScale, 0, 1, 0)
		t = t + (tick() - deltaTime)
		deltaTime = tick()
		wait()
	end
	FillBar.Size = UDim2.new(0, 0, 1, 0)
	FillBar.BackgroundColor3 = Color3.new(0, 85 / 255, 1)
end

local function BeginChargeShot()
	if not TheCharacter then return end
	--
	if not CanFire then return end
	--
	local humanoid = TheCharacter:FindFirstChild('Humanoid')
	if humanoid and humanoid.Health > 0 then
		if ChargeShotBeginTrack then
			FuseSound:Play()
			ChargeShotBeginTrack:Play()		
			wait(0.25)	-- animation delay
			if IsFired then
				IsFired = false
				return
			end
			ChargeStartTime = tick()
			Spawn(StartFillBar)
			ChargeEvent:FireServer()
			ChargeLoopTrack:Play()
		end
	end
end

local function EndChargeShot()
	if not TheCharacter then return end
	--
	if not CanFire then return end
	--
	CanFire = false
	local humanoid = TheCharacter:FindFirstChild('Humanoid')
	if humanoid and humanoid.Health > 0 then
		if ChargeShotBeginTrack then ChargeShotBeginTrack:Stop() end
		if ChargeLoopTrack then ChargeLoopTrack:Stop() end
		if FuseSound then FuseSound:Stop() end
		--
		IsFired = true
		Spawn(EndFillBar)
		FireEvent:FireServer()
		FireSound:Play()
		ChargeShotEndTrack:Play()
		Delay(0, function()
			if ChargeLoopTrack then ChargeLoopTrack:Stop() end
		end)
		wait(FIRE_DEBOUNCE_TIME)
		IsFired = false
	end
	CanFire = true
end

local function OnEquip(mouse)
	TheCharacter = Tool.Parent
	local humanoid = TheCharacter:FindFirstChild('Humanoid')
	
	if humanoid and humanoid.Health > 0 then
		local player = Players:GetPlayerFromCharacter(TheCharacter)
		if player then
			local gui = player:FindFirstChild('PlayerGui')
			if gui then
				ScreenGui.Parent = gui
			end
		end
		humanoid.Died:connect(function()
			DeathSound:Play()
		end)
		local r = math.random(1, #ArrSounds)
		ArrSounds[r]:Play()
		CannonHoldTrack = humanoid:LoadAnimation(CannonHold)
		CannonHoldTrack:Play()
		ChargeShotBeginTrack = humanoid:LoadAnimation(ChargeShotBegin)
		ChargeShotEndTrack = humanoid:LoadAnimation(ChargeShotEnd)
		ChargeLoopTrack = humanoid:LoadAnimation(ChargeLoop)
	end
	
	if mouse then
		mouse.Button1Down:connect(BeginChargeShot)
		mouse.Button1Up:connect(EndChargeShot)
		Btn.MouseButton1Down:connect(BeginChargeShot)
		Btn.MouseButton1Up:connect(EndChargeShot)
	end
end

local function OnUnequip()
	ScreenGui.Parent = Tool
	if CannonHoldTrack then CannonHoldTrack:Stop() end
	if ChargeShotBeginTrack then ChargeShotBeginTrack:Stop() end
	if ChargeShotEndTrack then ChargeShotEndTrack:Stop() end
	if ChargeLoopTrack then ChargeLoopTrack:Stop() end
end

PlayerKilledEvent.OnClientEvent:connect(onPlayerKilled)
Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
