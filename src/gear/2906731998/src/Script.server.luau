-- // Created by StarWars
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
BaseAmmo.Size = Vector3.new(0.613, 0.086, 0.613)	-- The size from the mesh part
BaseAmmo.TopSurface = Enum.SurfaceType.Smooth
BaseAmmo.BottomSurface = Enum.SurfaceType.Smooth
BaseAmmo.Massless = true
local Mesh = Instance.new("SpecialMesh")
Mesh.MeshId = "rbxassetid://" .. 2900583218
Mesh.TextureId = "rbxassetid://" .. 2900585624
Mesh.Parent = BaseAmmo

local VELOCITY = 250
local RELOAD_TIME = 2.5

local Damage = {
	Min = 2,
	Max = 5
}

function FireElf()
	local MouseData = nil
	pcall(function() MouseData = GearData.ClientControls:InvokeClient(GearData.Player, "GetMouseData") end)
	if not MouseData then return end
	local Direction = (MouseData.Position - GearData.RootPart.Position).Unit
	
	local NewAmmo = BaseAmmo:Clone()
	
	NewAmmo.CFrame = CFrame.new(Handle.LaunchAttachment.WorldPosition, MouseData.Position)
	NewAmmo.Velocity = Direction--[[(Direction + Vector3.new(0, 1, 0)).Unit]] * math.random(VELOCITY - 20, VELOCITY + 20)
	NewAmmo.RotVelocity = Vector3.new(0, 0, -math.random(VELOCITY - 20, VELOCITY + 20)) * 0.25
	local Debounce = false
	local TouchedConnection = NewAmmo.Touched:Connect(function(hit)
		if Debounce then return end 
		if hit and hit.Parent and not hit:IsDescendantOf(GearData.Character) then
			Debounce = true
			local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if HitHumanoid then
				HitHumanoid:TakeDamage(math.random(Damage.Min, Damage.Max))
			end
			wait()
			Debounce = false
		end
	end)
	
	delay(5, function()
		if TouchedConnection then
			TouchedConnection:Disconnect()
		end
	end)
--	Handle.Fire:Play()
	NewAmmo.Parent = workspace
	
	Debris:AddItem(NewAmmo, 30)
end

GearData:BindActivateFunction("pizza_launcher", function()
	-- // Pew
	FireElf()	
	
	wait(RELOAD_TIME)
end)