--Only those who plant the landsharks will be able to see the ripple effect..

local Self = script

local rService = game:FindService("RunService") or game:GetService("RunService")

local tService = game:FindService("TweenService") or game:GetService("TweenService")

local Debris = game:FindService("Debris") or game:GetService("Debris")

local Loc,PartRef,SharkRef = Self:FindFirstChild("Loc"), Self:FindFirstChild("PartRef"), Self:FindFirstChild("SharkRef")

if not Loc or not PartRef or not SharkRef then return end

Loc = Loc.Value

PartRef = PartRef.Value

SharkRef = SharkRef.Value

local Base = Instance.new("Part")
Base.Shape = Enum.PartType.Cylinder
Base.Color = PartRef.Color
Base.Material = Enum.Material.Glass
Base.Transparency = .6
Base.Size = Vector3.new(.5,0,0)
Base.Anchored = true
Base.CanCollide = false
Base.Locked = true
Base.CFrame = Loc * CFrame.Angles(0,math.rad(90),0)
Base.Parent = workspace

coroutine.wrap(function()
	repeat
		--print(SharkRef.Parent == nil)
		rService.RenderStepped:Wait()
	until not SharkRef or not SharkRef.Parent or not PartRef or not PartRef.Parent
	--print("Despawning the ripple")
	Debris:AddItem(Base,.5)
	--[[if Base then
		Base:Destroy()
	end]]
end)()

local Tween = tService:Create(Base,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,math.huge,false,0),{Transparency = 1, Size = Vector3.new(1,45,45)})

Tween:Play()