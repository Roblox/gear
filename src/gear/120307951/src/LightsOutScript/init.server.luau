local Lighting = game.Lighting
local Ambient = Lighting.Ambient
local OutdoorAmbient = Lighting.OutdoorAmbient
local TimeOfDay = Lighting.TimeOfDay
local LightHolder = script:WaitForChild('LightHolder').Value
local Handle = script:WaitForChild('Handle').Value

local BLACK = Color3.new(0,0,0)
local MIDNIGHT = "00:00:00"
local LIGHT_BRIGHTNESS = 5
local LIGHT_RANGE = 45
local TIME_OF_DARKNESS = 15

local function AbsorbLight()
	Lighting.Ambient = BLACK
	Lighting.OutdoorAmbient = BLACK
	Lighting.TimeOfDay = MIDNIGHT
	
	local light = Instance.new("PointLight")
	light.Brightness = LIGHT_BRIGHTNESS
	light.Range = LIGHT_RANGE
	light.Parent = LightHolder
	
	Handle.Transparency = 1.0
end

local function ReturnToNormal()
	Lighting.Ambient = Ambient
	Lighting.OutdoorAmbient = OutdoorAmbient
	Lighting.TimeOfDay = TimeOfDay
	
	local tag = Lighting:FindFirstChild("BlackPeriastronWasHere")
	if tag then tag:Remove() end
	
	LightHolder:Destroy()
	
	Handle.Transparency = 0.0
end

AbsorbLight()
wait(TIME_OF_DARKNESS)
ReturnToNormal()
script:Remove()
