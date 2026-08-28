-- // Created by StarWars
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle 
local SideBlade1 = Tool.SideBlade1
local SideBlade2 = Tool.SideBlade2
local Blade = Tool.Blade
local AnimationsFolder = Tool:WaitForChild("Animations")
local R6Folder = AnimationsFolder:WaitForChild("R6")
local R15Folder = AnimationsFolder:WaitForChild("R15")

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

Handle.Transparency = 0

SideBlade1.Transparency = 1
SideBlade2.Transparency = 1
Blade.Transparency = 1

CollectionService:AddTag(Blade, "roblox_lightsaber_blade")

local Sounds = {
	Open = Handle.TurnOn,
	Close = Handle.TurnOff,
	Hum = Handle.Hum
}

local HitSounds = {
	1194460845,
	1194461060
}

local Animations =
{
	Swing1 = {Animation = R6Folder:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
	Swing2 = {Animation = R6Folder:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};	
	Swing3 = {Animation = R6Folder:WaitForChild("Swing3"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
}

local PossibleAnimations =
{
	{Animation = Animations.Swing1, Audio = Handle.Swing};
	{Animation = Animations.Swing2, Audio = Handle.Swing2};
	{Animation = Animations.Swing3, Audio = Handle.Swing3};
}

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local Remotes = Tool:WaitForChild("Remotes")
local ClientControl = Remotes:WaitForChild("ClientControls")

local ToolEquipped = false

local BladeDebounce = false
Blade.Touched:Connect(function(hit)
	if BladeDebounce then return end 
	BladeDebounce = true
	if hit and CollectionService:HasTag(hit, "roblox_lightsaber_blade") then
		-- make ligthsaber hit sound
		local HitSound = Instance.new("Sound")
		HitSound.SoundId = "rbxassetid://" .. HitSounds[math.random(#HitSounds)]
		HitSound.Volume = 0.2
		HitSound.Parent = Handle
		HitSound:Play()
		Debris:AddItem(HitSound, 1)
		wait()
	elseif hit and hit.Parent then
		local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 and Humanoid ~= Gear.Humanoid then
			Humanoid:TakeDamage(60)
			wait()
		end
	end
	BladeDebounce = false
end)

local SideBlade1Debounce = false
SideBlade1.Touched:Connect(function(hit)
	if SideBlade1Debounce then return end 
	SideBlade1Debounce = true
	if hit and CollectionService:HasTag(hit, "roblox_lightsaber_blade") then
		-- make ligthsaber hit sound
		local HitSound = Instance.new("Sound")
		HitSound.SoundId = "rbxassetid://" .. HitSounds[math.random(#HitSounds)]
		HitSound.Volume = 0.2
		HitSound.Parent = Handle
		HitSound:Play()
		Debris:AddItem(HitSound, 1)
		wait()
	elseif hit and hit.Parent then
		local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 and Humanoid ~= Gear.Humanoid then
			Humanoid:TakeDamage(5)
			wait()
		end
	end
	SideBlade1Debounce = false
end)


local SideBlade2Debounce = false
SideBlade2.Touched:Connect(function(hit)
	if SideBlade2Debounce then return end 
	SideBlade2Debounce = true
	if hit and CollectionService:HasTag(hit, "roblox_lightsaber_blade") then
		-- make ligthsaber hit sound
		local HitSound = Instance.new("Sound")
		HitSound.SoundId = "rbxassetid://" .. HitSounds[math.random(#HitSounds)]
		HitSound.Volume = 0.2
		HitSound.Parent = Handle
		HitSound:Play()
		Debris:AddItem(HitSound, 1)
		wait()
	elseif hit and hit.Parent then
		local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 and Humanoid ~= Gear.Humanoid then
			Humanoid:TakeDamage(5)
			wait()
		end
	end
	SideBlade2Debounce = false
end)

Gear:BindActivateFunction("kylo_lightsaber_activate", function()
	-- Play swing sound
	local RandomSwing = PossibleAnimations[math.random(#PossibleAnimations)]
	pcall(function()
		ClientControl:InvokeClient(Gear.Player, "PlayAnimation", RandomSwing.Animation)
		ClientControl:InvokeClient(Gear.Player, "PlaySound", RandomSwing.Audio)
	end)
	wait(0.6)	
end)

Gear:BindEquippedFunction("kylo_lightsaber_equipped", function()
	for _, obj in next, Blade:GetChildren() do
		if obj and (obj:IsA("SurfaceLight") or obj:IsA("Beam")) then
			obj.Enabled = true
		end
	end	
	
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations =
		{
			Swing1 = {Animation = R15Folder:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
			Swing2 = {Animation = R15Folder:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};	
			Swing3 = {Animation = R15Folder:WaitForChild("Swing3"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};			
		}	
		
		PossibleAnimations =
		{
			{Animation = Animations.Swing1, Audio = Handle.Swing};
			{Animation = Animations.Swing2, Audio = Handle.Swing2};
			{Animation = Animations.Swing3, Audio = Handle.Swing3};
		}			
	else
		Animations =
		{
			Swing1 = {Animation = R6Folder:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
			Swing2 = {Animation = R6Folder:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};	
			Swing3 = {Animation = R6Folder:WaitForChild("Swing3"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};			
		}
		
		PossibleAnimations =
		{
			{Animation = Animations.Swing1, Audio = Handle.Swing};
			{Animation = Animations.Swing2, Audio = Handle.Swing2};
			{Animation = Animations.Swing3, Audio = Handle.Swing3};
		}		
	end	
	
	Blade.Transparency = 0
	
	-- Play turn on sound
	ToolEquipped = true
	Sounds.Open:Play()
	delay(1.21, function()
		if Sounds.Open.IsPlaying and ToolEquipped then
			Sounds.Hum:Play()
		end
	end)
	delay(0.35, function()
		if Sounds.Open.IsPlaying and ToolEquipped then
			SideBlade1.Transparency = 0
			SideBlade2.Transparency = 0	
		end
	end)
end)

Gear:BindUnequippedFunction("kylo_lightsaber_unequipped", function()
	for _, obj in next, Blade:GetChildren() do
		if obj and (obj:IsA("SurfaceLight") or obj:IsA("Beam")) then
			obj.Enabled = false
		end
	end	
	
	ToolEquipped = false
	
	Blade.Transparency = 1	
	SideBlade1.Transparency = 1
	SideBlade2.Transparency = 1	
	
	-- Play turn off sound
	Sounds.Hum:Stop()
	Sounds.Close:Play()
end)
