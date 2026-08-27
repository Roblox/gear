local InsertService = game:GetService("InsertService")
local Debris = game:GetService("Debris")

local ZombieModel = InsertService:LoadAsset(93601062):GetChildren()[1]

local Tool = script.Parent
local Handle = Tool.Handle

local ThrowSound = Handle:FindFirstChild("ThrowSound")
local ExplodeSound = Handle:FindFirstChild("ExplodeSound")

local Player = nil
local Character = nil
local Torso = nil
local RightArm
local Humanoid = nil

local LastUse = Tool.LastUse

local COOLDOWN_TIME = 10
local POWER = 50

local GetMousePosition = Instance.new("RemoteFunction")
GetMousePosition.Name = "GetMousePosition"
GetMousePosition.Parent = Tool

local CreatorObject = Instance.new("ObjectValue")
CreatorObject.Name = "creator"

function CreateZombie(grenade)
	local NewZombie = ZombieModel:Clone()
	local GrenadeCreator = grenade:FindFirstChild("creator")
	if GrenadeCreator then
		GrenadeCreator:Clone().Parent = NewZombie
	end
	Debris:AddItem(NewZombie, 35)
	NewZombie.Parent = workspace
	NewZombie:MoveTo(grenade.Position + (((Vector3.new(2, 0, 2)*math.random()) - Vector3.new(1, 0, 1)) * 7))
end

function ExplodeGrenade(grenade)
	local Smoke = Instance.new("Smoke")
	Smoke.Size = 20
	Smoke.RiseVelocity = 20
	Smoke.Color = Color3.new(0, 0.8, 0)
	Smoke.Parent = grenade
	
	local Fire = Instance.new("Fire")
	Fire.Heat = 0
	Fire.Size = 100
	Fire.Color = Color3.new(0, 1, 0)
	Fire.SecondaryColor = Color3.new(0, 0, 0)
	Fire.Parent = grenade
	
	local GrenadeExplodeSound = grenade:FindFirstChild("ExplodeSound")
	if GrenadeExplodeSound then
		GrenadeExplodeSound:Play()
	end
	
	wait(0.3)
	for i = 1, math.random(3, 4) do
		CreateZombie(grenade)
	end
	wait(0.2)
	grenade:Destroy()
end

function ThrowGrenade()
	if not Player then return end
	if not Character then return end
	if not Humanoid then return end
	if Humanoid.Health <= 0 then return end
	if not Torso then return end
	if not RightArm then return end

	local MousePosition = GetMousePosition:InvokeClient(Player)	
	
	if ThrowSound then
		ThrowSound:Play()
	end
	
	local Shoulder = Torso:FindFirstChild("Right Shoulder") or Torso:FindFirstChild("RightShoulder")
	if Shoulder then
		Shoulder.CurrentAngle = math.pi
	end
	
	local Grenade = Handle:Clone()
	Grenade.Name = "Effect"
	Grenade.CanCollide = true
	Grenade.Transparency = 0
	
	local ThrowVector = (MousePosition - Torso.Position).Unit
	Grenade.CFrame = CFrame.new(Torso.Position, Torso.Position + ThrowVector) * CFrame.new(0, 0, -5)
	Grenade.Velocity = (ThrowVector * POWER) + Vector3.new(0, 20, 0)
	Grenade.RotVelocity = ((Vector3.new(1, 1, 1) * math.random()) - Vector3.new(0.5, 0.5, 0.5)) * 20
	
	local NewCreator = CreatorObject:Clone()
	NewCreator.Value = Player
	NewCreator.Parent = Grenade
	Debris:AddItem(Grenade, 10)
	Grenade.Parent = workspace
	
	return Grenade
end

function OnActivate()
	if not Tool.Enabled then return end
	LastUse.Value = tick() + 3
	Tool.Enabled = false
	Handle.Transparency = 1
	local NewGrenade = ThrowGrenade()
	wait(3)
	ExplodeGrenade(NewGrenade)	
	
	LastUse.Value = tick()
	wait(COOLDOWN_TIME)	
	Handle.Transparency = 0
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	RightArm = Character:FindFirstChild("RightArm") or Character:FindFirstChild("RightHand")
	Humanoid = Character:FindFirstChildOfClass("Humanoid")	
end

function OnUnequipped()
	Player = nil
	Character = nil
	Torso = nil
	RightArm = nil
	Humanoid = nil
end

Tool.Activated:Connect(OnActivate)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnEquipped)