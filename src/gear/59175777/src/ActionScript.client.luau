local Tool = script.Parent
local Potion = Tool.Handle

local vCharacter
local myHumanoid
local myTorso
local vPlayer

local spikeyCD
local spikeCo 

Tool.Enabled = true

local drinkAnim

local instructionGui
local activated = false

function activateAbility(key)
	key = key:lower()
	if (key == "q" or key == "e" or key == "c" or key == "z") and activated then	
		spikeScript = vCharacter:FindFirstChild("SpikeScript")
		if spikeScript == nil then 
			spikeScript = Tool:FindFirstChild("SpikeScript"):Clone()
			spikeScript.Parent = vCharacter			
			keyValue = spikeScript:FindFirstChild("Key")
		end
		if keyValue then 
			keyValue.Value = key
		end	
		if spikeScript then spikeScript.Disabled = false end 			
	else 
		-- do nothing 
	end
end

function onActivated()
	if (Tool.Enabled == false) or activated then 
		return
	end

	Tool.Enabled = false
	
	
 	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if myHumanoid == nil or vPlayer == nil then 
		return
	end	

	drinkAnim = myHumanoid:LoadAnimation(Tool.DrinkAnim)
	if drinkAnim then drinkAnim:Play() end
	wait(0.5)

	Potion.Transparency = 1.0

	instructionGui = Instance.new("ScreenGui")
	instructionGui.Parent = vPlayer.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200, 0, 100)
	frame.Position = UDim2.new(0.02, 0, 0.5, 0)
	frame.Parent = instructionGui
	frame.BackgroundTransparency = 1.0

	local image = Instance.new("ImageLabel")
	image.Position = UDim2.new(0, 0, 0, 0)
	image.Parent = frame
	image.Image = "http://www.roblox.com/asset/?id=59123068"
	image.Size = UDim2.new(1, 0, 1, 0)
	image.BackgroundTransparency = 1.0
	activated = true	

	wait(30.0)
	if instructionGui then instructionGui:Remove() end
	activated = false
	Potion.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	if mouse then 
		mouse.KeyDown:connect(activateAbility)
	end
end

function onUnequipped()
	if instructionGui then instructionGui:Remove() end
	if drinkAnim then drinkAnim:Stop() end
	Potion.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)



