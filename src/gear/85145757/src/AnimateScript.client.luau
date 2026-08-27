local Tool = script.Parent
local Bow = Tool.Handle

local vCharacter 
local walkAnim
local arrowAnim

local spamArrow
local co

local debounce = false

function onKeyDown(key)
	if key:lower() == "q" then 		
		if debounce == false then
			spamArrow = Tool:FindFirstChild("SpamArrow")
			if spamArrow then 
				spamArrow.Value = 1  
				co = coroutine.create(reset)
				coroutine.resume(co)
				debounce = true
			end	
		end
	end
end

function reset()
	wait(5)
	spamArrow = Tool:FindFirstChild("SpamArrow")
	if spamArrow then spamArrow.Value = 0 end
	wait(5)
	debounce = false
end

function onActivatedLocal()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	--arrowAnim = myHumanoid:LoadAnimation(Tool.ArrowAnim)
	if arrowAnim then arrowAnim:Play() end

	wait(1.0)
	
end

function onEquippedLocal(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	

	mouse.KeyDown:connect(onKeyDown)
end

function onUnequippedLocal()
	if walkAnim then walkAnim:Stop() end	
	if arrowAnim then arrowAnim:Stop()end

	iceArrow = Tool:FindFirstChild("IceArrow")
	if iceArrow then iceArrow.Value = 0 end
end

Tool.Activated:connect(onActivatedLocal)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
