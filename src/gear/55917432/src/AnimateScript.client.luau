local Tool = script.Parent
local Ballista = Tool.Handle

local vCharacter 
local holdAnim
local ballistaActive
local myHumanoid

local firebolt 

function wait15() 
	wait(5)
	firebolt = Tool:FindFirstChild("FireBolt")
	if firebolt then firebolt.Value = false end
	wait(10)
end

function fireb(key)
	if key:lower() == "x" then 	
		if co == nil or coroutine.status(co) == 'dead' then 
			co = coroutine.create(wait15)
			coroutine.resume(co)
			firebolt = Tool:FindFirstChild("FireBolt")
			if firebolt then firebolt.Value = true end
		end
	end
end

function animate()
	ballistaActive = Tool:FindFirstChild("BallistaActive")
	if ballistaActive then
		if ballistaActive.Value and myHumanoid then 
			--holdAnim = myHumanoid:LoadAnimation(Tool.HoldAnim)
			if holdAnim then holdAnim:Play() end
		else 
			if holdAnim then holdAnim:Stop() end
		end
	end
end


function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	ballistaActive = Tool:FindFirstChild("BallistaActive")
	if ballistaActive then ballistaActive.Changed:connect(animate)	end
	if mouse then mouse.KeyDown:connect(fireb) end
end

function onUnequipped()
	if holdAnim then holdAnim:Stop () end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)