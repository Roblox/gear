-- // Made by StarWars
local RunService = game:GetService('RunService')

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Character = nil
local Torso = nil
local Humanoid = nil

local COOLDOWN_TIME = 20
local SPIN_TIME = 2
local SPINNER_SPEED = 500

local SpawnPoints = {}

function FindPart(model, className)
	for i, v in ipairs(model:GetChildren()) do
		if v:IsA(className) then
			table.insert(SpawnPoints, v)
			FindPart(v, className)
		else
			FindPart(v, className)
		end
	end
end

FindPart(workspace, "SpawnLocation")

function SpinCompass()
	local StartTime = tick()
	local SpinnerWeld = Handle:FindFirstChildOfClass("Weld")
	if SpinnerWeld then
		local StartCFrame = SpinnerWeld.C1
		while tick() - StartTime < SPIN_TIME do
			local Delta = RunService.Heartbeat:wait()
			SpinnerWeld.C1 = SpinnerWeld.C1 * CFrame.Angles(0, math.rad(1) * SPINNER_SPEED * Delta, 0)
		end
		
		SpinnerWeld.C1 = StartCFrame
	end
end

function OnActivated()
	-- // Do teleport stuff
	if not Tool.Enabled then return end
	if not Humanoid then return end
	Tool.Enabled = false
	local RandomPoint = #SpawnPoints > 0 and SpawnPoints[math.random(1, #SpawnPoints)] or nil	
	
	SpinCompass() 
	if Torso then
		Torso.CFrame = (RandomPoint and RandomPoint.CFrame * CFrame.new(0, Humanoid.HipHeight, 0)) or CFrame.new(0, 100, 0)	
	end	
	
	wait(COOLDOWN_TIME)	
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
end

function OnUnequipped()
	Character = nil
	Humanoid = nil
	Torso = nil
end

Tool.Activated:Connect(OnActivated)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)