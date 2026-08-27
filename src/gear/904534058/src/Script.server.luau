-- Made by StarWars
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Tool = script.Parent 
local Handle = Tool.Handle
local BarrelTip = Handle.BarrelTip

local Character = nil
local Player = nil
local Humanoid = nil
local RootPart = nil

local MARSHMALLOW_SPEED = 50
local DAMAGE = 5
local DESPAWN_TIME = 30
local RELOAD_TIME = 1

local BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.4, 0.4, 0.4)
BasePart.CanCollide = false
BasePart.Locked = true
BasePart.Anchored = false
local BaseMesh = Instance.new("SpecialMesh")
BaseMesh.Scale = Vector3.new(2, 2, 2)
BaseMesh.MeshId = "rbxassetid://909438205"
BaseMesh.TextureId = "rbxassetid://901145639"
BaseMesh.Parent = BasePart

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player then return end 
end)

function InvokeClient(Mode, Value)
	local ClientReturn
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function FireMarshmallow()
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then return end 
	
	local Direction = (MousePosition.Position - Handle.Position).Unit
	local NewMarshmallow = BasePart:Clone() 
	local NewBodyForce = Instance.new("BodyForce")
	NewBodyForce.Force = Vector3.new(0, workspace.Gravity * 0.99 * NewMarshmallow:GetMass(), 0)
	NewBodyForce.Parent = NewMarshmallow
	NewMarshmallow.CFrame = CFrame.new(Handle.Position, MousePosition.Position) * CFrame.new(0, 0, -2)
	NewMarshmallow.Velocity = Direction * MARSHMALLOW_SPEED
	NewMarshmallow.Touched:Connect(function(hit)
		if hit and hit.Parent then
			local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if HitHumanoid and HitHumanoid ~= Humanoid then
				HitHumanoid:TakeDamage(DAMAGE)
				NewMarshmallow:Destroy()
			end
		end
	end)	
	
	Debris:AddItem(NewMarshmallow, DESPAWN_TIME)
	
	InvokeClient("PlaySound", Handle.Sound)
	NewMarshmallow.Parent = workspace
end

function Activated()
	if not Tool.Enabled then return end

	Tool.Enabled = false
	FireMarshmallow()
	
	wait(RELOAD_TIME)
	Tool.Enabled = true 
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
end

function Unequipped()
	Character = nil
	Player = nil
	Humanoid = nil
	RootPart = nil 
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
Tool.Activated:Connect(Activated)