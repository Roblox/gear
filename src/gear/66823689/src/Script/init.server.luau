-- // Created by StarWars		-- hackily repurposed by Luke
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")



local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle 

local AnimationsFolder = Tool:WaitForChild("Animations")
local R6Folder = AnimationsFolder:WaitForChild("R6")
local R15Folder = AnimationsFolder:WaitForChild("R15")


local Animations =
{
	Swing1 = {Animation = R6Folder:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
	Swing2 = {Animation = R6Folder:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};	
	Swing3 = {Animation = R6Folder:WaitForChild("Swing3"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
}

local PossibleAnimations =
{
	{Animation = Animations.Swing1,};
	{Animation = Animations.Swing2,};
	{Animation = Animations.Swing3,};
}

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local Remotes = Tool:WaitForChild("Remotes")
local ClientControl = Remotes:WaitForChild("ClientControls")

local ToolEquipped = false


function swordUp()
	Tool.Grip = CFrame.new(0, 0, -1.70000017, 8.74227766e-08, 0, -1, -1, 0, -8.74227766e-08, 0, 1, 0)
end

function swordDown()
	Tool.GripUp = Vector3.new(1, 0, 0)
	Tool.GripRight = Vector3.new(0, 1, 0)
	Tool.GripForward = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(1, 0, 0)
end

function specialAttack(myHumanoid, myTorso) 	
	swordDown()
	local bg = Instance.new("BodyGyro") 
	bg.P = 100000 
	bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P) 
	bg.Name = "BodyGyro" 

	local torsoCFrames = {}
	torsoCFrames[1] = myTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0)
	torsoCFrames[2] = myTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0)
	torsoCFrames[3] = myTorso.CFrame * CFrame.Angles(0, math.pi, 0)
	torsoCFrames[4] = myTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0)
	torsoCFrames[5] = myTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0)
	torsoCFrames[6] = myTorso.CFrame

	bg.Parent = myTorso

	for i = 1, 84 do
		local c = i%6 + 1
		if bg then
			bg.cframe = torsoCFrames[c]
		end
		wait(0.025) 
	end       

	swordUp()

	if bg then
		bg:Destroy()
	end 
end


local BladeDebounce = false
local attacking = false
local slowScript = script:WaitForChild('SlowScript')
Handle.Touched:Connect(function(hit)
	if BladeDebounce and attacking then
		return
	end 
	BladeDebounce = true
	if hit and hit.Parent then
		local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 and Humanoid ~= Gear.Humanoid then
			Humanoid:TakeDamage(10)
			if not hit.Parent:FindFirstChild('SlowScript') then
				local newSlowScript = slowScript:clone()
				newSlowScript.Parent = hit.Parent
				newSlowScript.Disabled = false
			end
			wait(.2)
		end
	end
	BladeDebounce = false
end)

local lastAttack = tick()
local specialDebounce = true
Gear:BindActivateFunction("icicle_sword_activate", function()
	-- Play swing sound
	attacking = true
	local RandomSwing = PossibleAnimations[math.random(#PossibleAnimations)]
	pcall(function()
		ClientControl:InvokeClient(Gear.Player, "PlayAnimation", RandomSwing.Animation)
		ClientControl:InvokeClient(Gear.Player, "PlaySound", RandomSwing.Audio)
	end)
	local thisAttack = tick()
	print(thisAttack-lastAttack)
	if thisAttack-lastAttack < .15 and specialDebounce and Gear.Humanoid and Gear.Humanoid.Health > 0 then
		local hrp = Gear.Humanoid.Parent:FindFirstChild('HumanoidRootPart')
		if hrp then
			specialDebounce = false
			specialAttack(Gear.Humanoid, hrp)
			specialDebounce = true
		end
	end
	wait(.6)
	attacking = false
	lastAttack = tick()
end)

Gear:BindEquippedFunction("icicle_sword_equipped", function()
	
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations =
		{
			Swing1 = {Animation = R15Folder:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
			Swing2 = {Animation = R15Folder:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};	
			Swing3 = {Animation = R15Folder:WaitForChild("Swing3"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};			
		}	
		
		PossibleAnimations =
		{
			{Animation = Animations.Swing1};
			{Animation = Animations.Swing2};
			{Animation = Animations.Swing3};
		}			
	else
		Animations =
		{
			Swing1 = {Animation = R6Folder:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};
			Swing2 = {Animation = R6Folder:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};	
			Swing3 = {Animation = R6Folder:WaitForChild("Swing3"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil};			
		}
		
		PossibleAnimations =
		{
			{Animation = Animations.Swing1};
			{Animation = Animations.Swing2};
			{Animation = Animations.Swing3};
		}		
	end	
	
	
	ToolEquipped = true

end)

