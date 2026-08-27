--Rescripted by TakeoHonorable


local Tool = script.Parent

local Rate=1/30

local Debris = (game:FindService("Debris") or game:GetService("Debris"))

local equipped=false
local check=true

local Cooldown=12
local Range=100

Tool.Grip = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)


local Handle = Tool:WaitForChild("Handle")
local Mesh = Handle:WaitForChild("Mesh")

local Remote = Tool:WaitForChild("ClientInput")

Remote.OnServerEvent:Connect(function(Player,MouseLoc)
	if not check then return end
	if not Player or not Player.Character then return end
	local PlayerHumanoid = Player.Character:FindFirstChildOfClass("Humanoid")
	if not PlayerHumanoid or PlayerHumanoid.Health == 0 then return end
	local Center = Player.Character:FindFirstChild("HumanoidRootPart")
	check = false
	Handle.Transparency = 1
	
	if (Center.Position-MouseLoc).magnitude>Range then
		MouseLoc = Center.Position+(((MouseLoc-Center.Position).unit)*Range)
	end
	
	local cloud = Handle:Clone()
	cloud.Size = Vector3.new(6,2,8)
	cloud.CFrame = Handle.CFrame
	cloud.Name = "EffectCloud"
	cloud.Transparency = 0
	cloud.CanCollide = false
	cloud.Anchored = false
	Debris:AddItem(cloud,30)
	
	local bp = Instance.new("BodyPosition")
	bp.D = 2000
	bp.P = 10000
	bp.MaxForce = Vector3.new(1,1,1)*math.huge--(10^5)
	bp.Position= MouseLoc + Vector3.new(0,20,0)
	bp.Parent = cloud
	cloud.CloudScript.Disabled = false
	
	local smoke = cloud:FindFirstChild("Smoke")
	if smoke then
		smoke.Enabled = true
	end
	cloud.Parent = workspace
	cloud:SetNetworkOwner(Player)
	wait(Cooldown)
	Handle.Transparency=0
	check=true
end)
