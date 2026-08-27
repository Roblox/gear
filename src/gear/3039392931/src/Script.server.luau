-- // Created by StarWars
-- StarWars secertly wants one 👀

local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Motor = Handle:FindFirstChildOfClass("Motor6D")
if Motor then
	Motor:Destroy()
	Motor = nil
end

local Display = Tool:FindFirstChild("Display")
if Display then
	Display:Destroy()
	Display = nil
end

local GearService = require(1075123174)
local GearData = GearService:BindGear(Tool)
GearData:SetupRemoteFunctions()
GearData:SetupLocalScript("MouseIcon")

local BaseAmmo = Instance.new("Part")
BaseAmmo.Size = Vector3.new(0.5, 0.5, 0.5) * 3	-- The size from the mesh part
BaseAmmo.TopSurface = Enum.SurfaceType.Smooth
BaseAmmo.BottomSurface = Enum.SurfaceType.Smooth
BaseAmmo.Massless = true
local Mesh = Instance.new("SpecialMesh")
Mesh.MeshId = "rbxassetid://" .. 3039304183
Mesh.TextureId = "rbxassetid://" .. 3039307464
Mesh.Scale = Vector3.new(0.35, 0.35, 0.35) * 3
Mesh.Parent = BaseAmmo

local VELOCITY = 50
local RELOAD_TIME = 2.5


function FireEgg()
	local MouseData = nil
	local success, MouseData = pcall(function() return GearData.ClientControls:InvokeClient(GearData.Player, "GetMouseData") end)
	if not success then return end
	local Direction = (MouseData.Position - GearData.RootPart.Position).Unit
	
	local NewAmmo = BaseAmmo:Clone()
	
	NewAmmo.CFrame = CFrame.new(Handle.LaunchAttachment.WorldPosition, MouseData.Position)
	NewAmmo.Velocity = Direction--[[(Direction + Vector3.new(0, 1, 0)).Unit]] * math.random(VELOCITY - 20, VELOCITY + 20)
	NewAmmo.RotVelocity = Vector3.new(0, 0, -math.random(VELOCITY - 20, VELOCITY + 20)) * 0.25

	NewAmmo.Name = "AdminEgg"

	Handle.Release:Play()
	NewAmmo.Parent = workspace
	
	Debris:AddItem(NewAmmo, 30)
end

GearData:BindActivateFunction("egg_launcher", function()
	-- // Pew
	FireEgg()	
	
	wait(RELOAD_TIME)
end)