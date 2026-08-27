--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

InsertService = game:GetService("InsertService")
Debris = game:GetService("Debris")

CarpetModel = InsertService:LoadAsset(266360667)
Carpet = CarpetModel:GetChildren()[1]:Clone()
Debris:AddItem(CarpetModel, 1)

Handle.Transparency = 0
Tool.Enabled = true

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	CarpetModel = Carpet:Clone()
	local HumanoidRootPart = CarpetModel.HumanoidRootPart
	local AnimateScript = CarpetModel.AnimateScript
	Debris:AddItem(CarpetModel, 60)
	AnimateScript.Disabled = false
	for i, v in pairs(CarpetModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Friction = 2
			v.Elasticity = 0
		end
	end
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.velocity = Vector3.new(0, -8, 0)
	BodyVelocity.Parent = HumanoidRootPart
	HumanoidRootPart.CFrame = ((Handle.CFrame * CFrame.new(0, 0, 0)) * CFrame.Angles((math.pi / 2), -(math.pi / 2), 0))
	CarpetModel.Parent = game:GetService("Workspace")
	Debris:AddItem(Tool, 0)
	Tool:Destroy()
end

Tool.Activated:connect(Activated)