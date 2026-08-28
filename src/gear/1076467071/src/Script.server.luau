local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local GearService = require(1075123174)

local LaserInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)


local Tool = script.Parent
local Handle = Tool.Handle 
local Gear = GearService:BindGear(Tool, "Staff")

function LaserEffect(endPoint)
	local Distance = (Handle.Emitter.WorldPosition - endPoint).Magnitude
	
	local LaserPart = Instance.new("Part")
	local LaserGoals = {Size = Vector3.new(0, 0, Distance), Transparency = 1}
	local LaserTween = TweenService:Create(LaserPart, LaserInfo, LaserGoals)
	LaserPart.Size = Vector3.new(0.2, 0.2, Distance)
	LaserPart.CFrame = CFrame.new(Handle.Emitter.WorldPosition, endPoint) * CFrame.new(0, 0, -Distance * 0.5)
	LaserPart.Material = Enum.Material.Neon
	LaserPart.Anchored = true 
	LaserPart.CanCollide = false
	LaserPart.Color = Color3.fromRGB(5, 255, 226)
	LaserPart.Parent = workspace
	LaserTween:Play()
	
	Debris:AddItem(LaserPart, 1)
end

Gear:BindActivateFunction("default_function", function()
	local MousePosition = Gear.Class.RemoteFunction:InvokeClient(Gear.Player, "GetMousePosition").p
	local Hit, EndPoint = GearService:CastRay(Gear.RootPart.Position, (MousePosition - Gear.RootPart.Position).Unit, 999, {Gear.Character, Tool})
	if Hit and Hit.Parent then
		local HitCharacter = Hit.Parent
		local HitHumanoid = HitCharacter:FindFirstChildOfClass("Humanoid")
		if HitHumanoid then
			HitHumanoid:TakeDamage(Gear.Class.RangeDamage)
		end
		LaserEffect(EndPoint)
	end
	wait(2)
end)