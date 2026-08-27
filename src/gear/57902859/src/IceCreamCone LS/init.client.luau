math.randomseed(tick()); math.random()

function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tool = script.Parent

local myCharacter
local myHumanoid
local myPlayer

local waitCo

local lickNum = 0
local lastLickTime = 0
local thisLickTime = 0

local BrainfreezeGui

local SpeedScript
local NewSpeed

local LickSound

local LickAnim

local haltWaitCo = false

local debris = game:GetService("Debris")

function onActivated()
	if not Tool.Enabled then return end
	myCharacter = Tool.Parent
	if myCharacter then
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			LickSound = Tool:FindFirstChild("LickSound")
			LickAnim = Tool:FindFirstChild("LickAnim")
			if LickAnim then 
				LickAnim = myHumanoid:LoadAnimation(LickAnim)
				LickAnim:Play() 
			end
			breakWaitCo = true
			wait(0.5)
			breakWaitCo = false
			if LickSound then LickSound:Play() end
			thisLickTime = tick()
			if (thisLickTime - lastLickTime < 2) then	-- Brainfreeze
				myHumanoid:TakeDamage(30)
				myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
				if myPlayer then
					BrainfreezeGui = waitForChild(Tool, "IceCreamConeBrainfreezeGui"):Clone()
					debris:AddItem(BrainfreezeGui, 2)
					BrainfreezeGui.Parent = myPlayer.PlayerGui
				end
			end
			SpeedScript = script:FindFirstChild("IceCreamConeSpeedScript")
			if SpeedScript then
				SpeedScript = SpeedScript:Clone()
				NewSpeed = waitForChild(SpeedScript, "NewSpeed")
				if waitCo then waitCo = coroutine.yield() end
				lickNum = lickNum + 1
				if (math.random() > 1.5 / lickNum) then
					--do sugar crash
					NewSpeed.Value = 12
					waitCo = coroutine.create(function() 
						Tool.Enabled = false 
						lickNum = 0
						wait(10) 
						Tool.Enabled = true 
					end)
					coroutine.resume(waitCo)
				else
					NewSpeed.Value = 20 * lickNum
					waitCo = coroutine.create(function()
						for i = 1, 300 do
							if i == 300 then lickNum = 0 end
							if breakWaitCo then break end
							wait()
						end
					end)
					coroutine.resume(waitCo)
				end
				if myCharacter:FindFirstChild("IceCreamConeSpeedScript") then
					myCharacter.IceCreamConeSpeedScript:Remove()
				end
				lastLickTime = thisLickTime
				SpeedScript.Parent = myCharacter
				SpeedScript.Disabled = false
			end
		end
	end
end

function onEquipped()
	myCharacter = Tool.Parent
	if not Tool.Enabled then
		wait(8)
		Tool.Enabled = true
	end
end

function onUnequipped()
	if LickAnim then LickAnim:Stop() end
	if LickSound then LickSound:Stop() end
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if myPlayer then
		local oldSpeedGui = myPlayer:FindFirstChild("IceCreamConeSpeedGui")
		local oldFreezeGui = myPlayer:FindFirstChild("IceCreamConeBrainfreezeGui")
		if oldSpeedGui then oldSpeedGui:Remove() end
		if oldFreezeGui then oldFreezeGui:Remove() end
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)