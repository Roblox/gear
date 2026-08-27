local Tool = script.Parent

local TIME_BETWEEN_USES = 32
local BEFORE_SOUND_TIME = 0.5
local AFTER_SOUND_TIME = 1.5

local LeftArmMesh = nil
local RightArmMesh = nil

local Anims = {}

local CLOSED_C1 = CFrame.new(-0.00384521484, -0.523071289, -0.435760498, 0.999947309, -0.00898111332, 0.00493008271, 0.010026129, 0.758797944, -0.651248157, 0.00210815505, 0.651264191, 0.758848369)

local function Attach(part0, part1, name)
	local motor = Instance.new("Motor6D")
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = CFrame.new()
	motor.C1 = CLOSED_C1
	if name then
		motor.Name = name
	end
	motor.Parent = part0
	return motor
end

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

function OnActivated()
	if Tool.Enabled then
		Tool.Enabled = false
		local character = Tool.Parent
		if character and not character:FindFirstChild('VeggieArmsCharacterMeshChanger') then
			local meshChanger = Tool:FindFirstChild('VeggieArmsCharacterMeshChanger')
			local enableScript = script:FindFirstChild('EnableScript')
			if meshChanger then
				Play('EatAnim')
				wait(BEFORE_SOUND_TIME)
				if character == Tool.Parent then	-- Check that character is still drinking
					local enableScriptClone = enableScript:Clone()
					enableScriptClone.Disabled = false
					enableScriptClone.Parent = Tool
					local drinkSound = Tool:FindFirstChild('DrinkSound')
					if drinkSound then drinkSound:Play() end
					wait(AFTER_SOUND_TIME)
					local meshChangerClone = meshChanger:Clone()
					meshChangerClone.Parent = character
					meshChangerClone.Disabled = false
				else
					Tool.Enabled = true
				end
			end
		end
	end
end

function OnEquipped()
	Attach(Tool.Handle, Tool.Lid)
	Stop('EatAnim')
	Play('EquipAnim')
end

function OnUnequipped()
	Stop('EatAnim')
	Stop('EquipAnim')
end
	

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)

