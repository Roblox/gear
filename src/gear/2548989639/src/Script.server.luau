-- // Recreated by StarWars
local RunService = game:GetService("RunService")

local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local slashSound = handle.SlashSound

local animations = {
	Block = {Animation = tool.Animations.R6.Block},
	LeftSlash = {Animation = tool.Animations.R6.LeftSlash},
	RightSlash = {Animation = tool.Animations.R6.RightSlash},
	
	R15Block = {Animation = tool.Animations.R15.Block},
	R15LeftSlash = {Animation = tool.Animations.R15.LeftSlash},
	R15RightSlash = {Animation = tool.Animations.R15.RightSlash}	
}

local RELOAD_TIME = 1
local BASE_DAMAGE = 8
local SLASH_DAMAGE = 15
local BLOCK_DAMAGE = 20

local damage = BASE_DAMAGE
local leftSword
local lastAttack = 0

local attackReady = true
local blockReady = true

local rand = Random.new()

function InvokeClient(mode, value)
	if not mode then return end
	
	local result
	pcall(function()
		result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
	end)
	
	return result
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character = Hit.Parent
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if gear.Humanoid and gear.Humanoid ~= humanoid and humanoid and gear.Humanoid.Health > 0 and humanoid.Health > 0 then
			local Right_Arm = gear.Character:FindFirstChild("Right Arm") or gear.Character:FindFirstChild("RightHand")
			if Right_Arm then
				local Joint = Right_Arm:FindFirstChild("RightGrip")
				if (Joint and (Joint.Part0 == handle or Joint.Part1 == handle)) then
					humanoid:TakeDamage(damage)
				end
			end
		end
	end
end

function CreateFakeHandle()
	if not gear.Character then return end

	leftSword = handle:Clone()
	leftSword.Name = "FakeHandle"
	leftSword.CanCollide = false
	
	local mesh = leftSword:FindFirstChildOfClass("SpecialMesh")
	if mesh then
		mesh.MeshId = "rbxassetid://" .. 2548915856 
	end
	
	local leftSwordWeld = Instance.new("Motor6D")
	leftSwordWeld.Part1 = leftSword
	leftSwordWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
	leftSwordWeld.C1 = tool.Grip
	
	local leftArm = gear.Character:FindFirstChild("Left Arm") or gear.Character:FindFirstChild("LeftHand")
	if leftArm and leftArm.Name == "LeftHand" then
		local att = leftArm:FindFirstChild("LeftGripAttachment")
		if att then
			leftSwordWeld.C0 = att.CFrame
		end
	else
		
	end
	leftSwordWeld.Part0 = leftArm
	leftSword.Parent = tool
	leftSwordWeld.Parent = leftSword
	
	leftSword.Touched:Connect(Blow)	
end

function Attack()
	attackReady = false
	damage = SLASH_DAMAGE
	local randomSlashAnim = rand:NextInteger(1, 2)
	print(randomSlashAnim)
	local anim = animations.LeftSlash
	if randomSlashAnim == 2 then
		if gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
			anim = animations.RightSlash
		else
			anim = animations.R15RightSlash
		end
	else
		if gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
			anim = animations.R15LeftSlash
		end
	end
	
	InvokeClient("PlayAnimation", anim)
	wait(0.5)
	InvokeClient("StopAnimation", anim)
	damage = BASE_DAMAGE
	attackReady = true
end

function DoubleClick()
	blockReady = false
	attackReady = false
	damage = BLOCK_DAMAGE
	
	local anim = animations.Block
	if gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		anim = animations.R15Block
	end
	
	InvokeClient("PlayAnimation", anim)
	wait(0.5)
	InvokeClient("StopAnimation", anim)
	damage = BASE_DAMAGE
	attackReady = true
	blockReady = true
end

tool.Activated:Connect(function()
	if tool.Enabled and gear:IsPlayerAlive() and blockReady then
		tool.Enabled = false
		local t = RunService.Stepped:wait()
		if t - lastAttack < 0.2 then
			spawn(DoubleClick)
		elseif attackReady then
			spawn(Attack)
		end	
		
		InvokeClient("PlaySound", slashSound)
		lastAttack = t						
		tool.Enabled = true
	end
end)

tool.Equipped:Connect(function()
	if leftSword then
		leftSword:Destroy()
	end
	
	wait()
	CreateFakeHandle()
end)

tool.Unequipped:Connect(function()
	if leftSword then
		leftSword:Destroy()
		leftSword = nil
	end
end)

handle.Touched:Connect(Blow)