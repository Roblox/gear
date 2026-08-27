-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent

local MouseDownObject = WaitForChild(script, 'MouseDown')	

local TargetPosition = WaitForChild(script, 'TargetPosition')

local HoldAniTrack
local ThrowAniTrack
local ChargeAniTrack
local ChargeArmAniTrack

local ChargeUpSound = WaitForChild(WaitForChild(Tool,'Handle'),'ChargeUp')
local SonicBoomSound = WaitForChild(WaitForChild(Tool,'Handle'),'SonicBoom')


local ChargeAniBaseLength=4
local MaxChargeSpeed=15

local BaseFire = Instance.new('Fire')
BaseFire.Size = 4

local ChargingThrust = false

local function ChargeThrust()
	ChargingThrust = true
	local aniSpeed = 5
	Spawn(function() while ChargingThrust and MouseDownObject.Value do wait(1/30) end SonicBoomSound:Play() end)
	ChargeArmAniTrack:Play(0,1,.5)
	while ChargingThrust and MouseDownObject.Value and aniSpeed<MaxChargeSpeed do
		ChargeAniTrack:Play(0,1,aniSpeed)
		ChargeUpSound:Play()
		wait((ChargeAniBaseLength/aniSpeed)/2)
		if ChargingThrust then ChargeUpSound:Play() end
		wait((ChargeAniBaseLength/aniSpeed)/2)
		aniSpeed=aniSpeed*1.3
	end
	
	local tfire1 = BaseFire:Clone()
	local tfire2 = BaseFire:Clone()

	if ChargingThrust and MouseDownObject.Value then 
		tfire2.Parent = Tool.Parent:FindFirstChild('Right Leg')
		tfire1.Parent = Tool.Parent:FindFirstChild('Left Leg')
	end

	while ChargingThrust and MouseDownObject.Value do
		ChargeAniTrack:Play(0,1,aniSpeed)
		ChargeUpSound:Play()
		wait((ChargeAniBaseLength/aniSpeed)/2)
		if ChargingThrust then ChargeUpSound:Play() end
		wait((ChargeAniBaseLength/aniSpeed)/2)
	end
	
	game.Debris:AddItem(tfire1,1)
	game.Debris:AddItem(tfire2,1)
end

local function OnMouseDown()
	if Tool.Enabled then
		HoldAniTrack:Play()
		Spawn(ChargeThrust)
	end
end

local function OnMouseUp()
	if Tool.Enabled then
		ChargingThrust = false
		HoldAniTrack:Stop()
		ChargeArmAniTrack:Stop()
		ThrowAniTrack:Play()
	end
end


local function OnEquipped()
	local MyChar = script.Parent.Parent

	HoldAniTrack = MyChar.Humanoid:LoadAnimation(WaitForChild(Tool,'HoldAni'))
	ThrowAniTrack = MyChar.Humanoid:LoadAnimation(WaitForChild(Tool,'ThrowAni'))
	ChargeAniTrack = MyChar.Humanoid:LoadAnimation(WaitForChild(Tool,'ChargeUpAni'))
	ChargeArmAniTrack = MyChar.Humanoid:LoadAnimation(WaitForChild(Tool,'ChargeUpArm'))
end

local function OnUnequipped()
	MouseDownObject.Value = false
	ChargingThrust = false
	HoldAniTrack:Stop()
	ChargeArmAniTrack:Stop()
end

-- Also activate when the Action Button is pressed
local function OnChildAdded(child)
	if child.Name == 'ActionButtonData' then
		child.Changed:connect(function(newValue)
			local bindable = child:FindFirstChild('GetTargetPosition')
			if bindable then
				if string.sub(newValue, 1, 1) == 'v' then -- Button down
					OnMouseDown()
				elseif string.sub(newValue, 1, 1) == '^' then  -- Button up
					OnMouseUp()
				end
			end
		end)
	end
end
Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == Tool.Parent then
		if action == 'Mouse1' then
			local down, hit = ...
			
			if down then
				if Tool.Enabled and not MouseDownObject.Value then
					MouseDownObject.Value = true 
					OnMouseDown()
				end
			else
				if MouseDownObject.Value then
					wait(0.01) --NOTE: Wait added to fix immediate down-up issue on iPad
					TargetPosition.Value=hit.p --set this early to prevent lag problems
					MouseDownObject.Value = false
					OnMouseUp()
				end
			end
		end
	end
end)

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.ChildAdded:connect(OnChildAdded)
