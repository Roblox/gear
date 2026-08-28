local Self = script

local Game,world = game,workspace

local Pairs = pairs

local Destroy,Clone,GetChildren,IsA = Game.Destroy,Game.Clone,Game.GetChildren,Game.IsA

local Tool = Self.Parent
Tool.Enabled = true
Tool.RequiresHandle = false
Tool.CanBeDropped = false

local Services = {
	InsertService = (Game:FindService("InsertService") or Game:GetService("InsertService"))
}

local Model = Services.InsertService:LoadAsset(4148787987)

local NPC = Model:FindFirstChildOfClass("Model")

local Current_NPC

function Equipped()

	if Current_NPC then
		Destroy(Current_NPC)
	end
	
	local Character = Tool.Parent
	local Center = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
	
	Current_NPC = Clone(NPC)
	
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = Current_NPC
	
	local AIScript = Clone(Self:WaitForChild("AIScript"))
	AIScript.Parent = Current_NPC
	
	local NPC_Humanoid = Current_NPC:FindFirstChildOfClass("Humanoid")
	
	if NPC_Humanoid then
		NPC_Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		NPC_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		NPC_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		NPC_Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		NPC_Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		NPC_Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
	end
	
	Current_NPC.PrimaryPart = (Current_NPC.PrimaryPart or Current_NPC:FindFirstChild("HumanoidRootPart"))
	Current_NPC:SetPrimaryPartCFrame(Center.CFrame * CFrame.new(6,0,0))
	
	Current_NPC.Name = Character.Name.."'s StarWars D-0 Droid"
	
	Current_NPC.Parent = world
	AIScript.Disabled = false
	
	for _,v in Pairs(GetChildren(Current_NPC)) do
		if v and IsA(v,"BasePart") and v:CanSetNetworkOwnership() then
			v:SetNetworkOwner(nil)
		end
	end
	
end

function Unequipped()
	if Current_NPC then
		Destroy(Current_NPC)
	end
end

if NPC then
	NPC.Parent = nil
	Tool.Equipped:Connect(Equipped)
	Tool.Unequipped:Connect(Unequipped)
end

