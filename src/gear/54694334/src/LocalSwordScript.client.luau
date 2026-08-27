local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter

local thornActive 

local greenFire

local co

local sparkle

function wait20()
	wait(7.5)
	thornActive = Tool:FindFirstChild("ThornActive")
	if thornActive then thornActive.Value = 0 end
	if sparkle then sparkle:Remove() end
	wait(12.5)
end

function onKeyDown(key)
	if key:lower() == "x" then
		if co == nil or coroutine.status(co) == 'dead' then	
			co = coroutine.create(wait20)
			coroutine.resume(co)
			vCharacter = Tool.Parent
			myHumanoid = vCharacter:findFirstChild("Humanoid")
			thornActive = Tool:FindFirstChild("ThornActive")
			if myHumanoid ~= nil and thornActive then                                              
				thornActive.Value = 1        
				sparkle = Instance.new("Sparkles")
				sparkle.SparkleColor = Color3.new(0, 0.9, 0)
				sparkle.Name = "SPARK"
				sparkle.Parent = Sword
			end
		end
	end
end

function onEquippedLocal(mouse)
     mouse.KeyDown:connect(onKeyDown)
end

function onUnequippedLocal()
	thornActive = Tool:FindFirstChild("ThornActive")
	if thornActive then thornActive.Value = 0 end
		
	if greenFire then greenFire:Remove() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal) 
