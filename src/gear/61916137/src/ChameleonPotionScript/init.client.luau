-- Populate the Brick Color, Vertex Color table, eww
-- Maybe not, it might be better to temporarily just convert the character meshes safely and bring them back

local Tool = script.Parent
local Potion = Tool.Handle


local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true

local minRange = 2
local maxRange = 200

local childScript
local changeTo

local drinkAnim

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false

	local target = myHumanoid.TargetPoint 
	local direction = (target - Potion.Position).unit

	local hit = game.Workspace:FindPartOnRay(Ray.new(Potion.Position + direction * minRange, direction * maxRange), vCharacter)

	drinkAnim = myHumanoid:LoadAnimation(Tool.DrinkAnim)
	if drinkAnim then drinkAnim:Play() end 
	Tool.GripPos = Vector3.new(0, 0, 0)
	wait(1.5)
	Tool.GripPos = Vector3.new(0, -0.5, 0)
	Potion.Transparency = 1.0	
	if hit then 
		if mouse then 			
			local surface = mouse.TargetSurface			   
		end
		childScript = vCharacter:FindFirstChild("ChangeFormScript")
		if childScript == nil then 
			childScript = script.ChangeFormScript:Clone()
			childScript.Parent = vCharacter				
		end	

		changeTo = childScript:FindFirstChild("ChangeTo")
		if changeTo then 
			changeTo.Value = hit 
			if childScript.Disabled == true then 
				childScript.Disabled = false
			end
		end 	
	end		

	wait(5.0)
	Potion.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped(m)
	if m then mouse = m end	
end

function onUnequipped()	
	Potion.Transparency = 0.0
	if drinkAnim then drinkAnim:Stop() end
	Tool.GripPos = Vector3.new(0, -0.5, 0)
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
