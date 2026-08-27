local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Tool = script.Parent
local Handle = Tool.Handle
if not Handle then return end 

local Character = nil
local RightHand = nil
local SpinningConn = nil 

local SPIN_SPEED = 1500
local SLOW_DOWN_RATE = 50
local CurrentSpeed = 0

function Spin()
	local RightGrip = RightHand:FindFirstChild("RightGrip")
	if RightGrip then
		CurrentSpeed = math.min(CurrentSpeed + SPIN_SPEED, 4000)
		
		if SpinningConn then return end 
		SpinningConn = RunService.Heartbeat:Connect(function(delta)
			RightGrip.C1 = RightGrip.C1 * CFrame.Angles(0, math.rad(-1) * delta * CurrentSpeed, 0)
			CurrentSpeed = math.max(0, CurrentSpeed - (SLOW_DOWN_RATE * delta))
			if CurrentSpeed <= 0 then
				SpinningConn:Disconnect()
				SpinningConn = nil 
			end
		end)
	end
end

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	
	Spin()	
	 
	wait(1)
	Tool.Enabled = true 
end

function OnEquipped()
	Character = Tool.Parent
	RightHand = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
end

function OnUnequipped()
	if SpinningConn then
		SpinningConn:Disconnect()
		SpinningConn = nil 
	end
	
	Character = nil
	RightHand = nil 
	CurrentSpeed = 0
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
Tool.Activated:Connect(OnActivated)