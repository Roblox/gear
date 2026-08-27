--  INACTIVE ICONS -- 
-- 53557574 53557657 53557672 53557706
-- ACTIVE ICONS -- 
-- 53603082 53603120 53603150 53603172 

-- Need to do a better job at swapping icons --

local Tool = script.Parent
local Hammer = Tool.Handle

local vCharacter
local myHumanoid

local hammerAnim
local stalkAnim

local skeletonValue = Tool:WaitForChild("Skeleton") --Fix implemented by Luckymaxer
local mark = Tool:WaitForChild("Mark")

local co

local skeleGui

local puppet = Tool:WaitForChild("Puppet")

-- Puppet actions
local dancing =  false
local following = false
local attacking  = false
local explode = false

-- Image Buttons
local imBt1
local imBt2
local imBt3
local imBt4

function dance()
	if dancing == false then
		dancing = true
		following = false
		attacking = false
		if stalkAnim then stalkAnim:Stop() end
		imBt1.Image = "http://www.roblox.com/asset/?id=53603082"
		imBt2.Image = "http://www.roblox.com/asset/?id=53557657"
		imBt3.Image = "http://www.roblox.com/asset/?id=53557672"
		imBt4.Image = "http://www.roblox.com/asset/?id=53557706"

		wait(0.5)
		if puppet and puppet.Value ~= nil then 
			humanoid = puppet.Value:FindFirstChild("Humanoid")
			if humanoid then 
				danceAnim = humanoid:LoadAnimation(Tool.DanceAnim)
				if danceAnim then danceAnim:Play() end			
				wait(2.5)				
			end
		else 
			if skeleGui then skeleGui:Remove() end
		end		
		
		dancing = false
	end
end

function explode()
	imBt1.Image = "http://www.roblox.com/asset/?id=53557574"
	imBt2.Image = "http://www.roblox.com/asset/?id=53603120" 
	imBt3.Image = "http://www.roblox.com/asset/?id=53557672"
	imBt4.Image = "http://www.roblox.com/asset/?id=53557706"
	attacking = false 
	following = false 
	wait(0.5)
	if puppet and puppet.Value ~= nil then
		if stalkAnim then stalkAnim:Stop() end
		torso = puppet.Value:FindFirstChild("Torso")
		e = Instance.new("Explosion")
		e.BlastPressure = 500000
		e.BlastRadius = 10
		e.Parent = game.Workspace
		e.Position = torso.Position
	else 
		if skeleGui then skeleGui:Remove() end
	end
	wait(0.5)
	if puppet then puppet.Value = nil end
	if skeleGui then skeleGui:Remove() end
end

function attack()
	if attacking == false then
		imBt1.Image = "http://www.roblox.com/asset/?id=53557574"
		imBt2.Image = "http://www.roblox.com/asset/?id=53557657"
		imBt3.Image = "http://www.roblox.com/asset/?id=53557672"
		imBt4.Image = "http://www.roblox.com/asset/?id=53603172"
		attacking = true
		following = false
		local enemyChar
		if puppet then
			puppetChar = puppet.Value
			if puppetChar then torso = puppetChar:FindFirstChild("Torso") end
			if torso then
				players = game.Players:GetChildren()
				for i = 1, #players do 
					tempChar = players[i].Character
					if tempChar ~= vCharacter then 
						distance = (tempChar.Torso.Position - torso.Position).magnitude
						if distance < 40 then
							enemyChar = tempChar
						end
					end
				end
				if enemyChar then 
					stalkAnim = Tool:FindFirstChild("StalkAnim")
					if stalkAnim then stalkAnim:play() end
					while attacking and puppet do 
						if puppetChar:FindFirstChild("Humanoid") then							
							puppetChar.Humanoid:MoveTo(enemyChar.Torso.Position, enemyChar.Torso)
						end
						wait(1.0)
					end
				end
			end	
		else 
			if skeleGui then skeleGui:Remove() end
		end
	end
end

function follow()
	if following == false then 
		imBt1.Image = "http://www.roblox.com/asset/?id=53557574"
		imBt2.Image = "http://www.roblox.com/asset/?id=53557657"
		imBt3.Image = "http://www.roblox.com/asset/?id=53603150"
		imBt4.Image = "http://www.roblox.com/asset/?id=53557706"
		if stalkAnim then stalkAnim:Stop() end
		following = true
		attacking = false
		if puppet and vCharacter then 
			puppetChar = puppet.Value
			if puppetChar then
				while following and puppet do 
					if puppetChar:FindFirstChild("Humanoid") then
						puppetChar.Humanoid:MoveTo(vCharacter.Torso.Position + ((puppetChar.Torso.Position - vCharacter.Torso.Position).unit * 5.0), vCharacter.Torso)
					end
					wait(1.0)
				end
			end
		else
			if skeleGui then skeleGui:Remove()  end
		end
	end
end

function createGui()
	if skeletonValue.Value == 1 then
		skeleGui = Instance.new("ScreenGui")
		skeleGui.Name = "ControlGUI"
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		skeleGui.Parent = vPlayer.PlayerGui

		frame = Instance.new("Frame")
		frame.Parent = skeleGui
		frame.Position = UDim2.new(0.05, 0, 0.60, 0)
		frame.Size = UDim2.new(0, 175, 0, 175)		
		frame.BackgroundTransparency = 1.0

		imBt1 = Instance.new("ImageButton")
		imBt1.Name = "Dance"
		imBt1.Image = "http://www.roblox.com/asset/?id=53557574"		
		imBt1.Size = UDim2.new(0.5, 0, 0.5, 0)
		imBt1.Position = UDim2.new(0, 0, 0, 0)		
		imBt1.Parent = frame
		imBt1.BackgroundTransparency = 1.0
		imBt1.MouseButton1Click:connect(dance)
		
		imBt2 = Instance.new("ImageButton")
		imBt2.Name = "Explode"		
		imBt2.Image = "http://www.roblox.com/asset/?id=53557657"
		imBt2.Size = UDim2.new(0.5, 0, 0.5, 0)
		imBt2.Position = UDim2.new(0, 0, 0.5, 0)		
		imBt2.BackgroundTransparency = 1.0
		imBt2.Parent = frame
		imBt2.MouseButton1Click:connect(explode)
		
		imBt3 = Instance.new("ImageButton")
		imBt3.Name = "Follow"		
		imBt3.Image = "http://www.roblox.com/asset/?id=53557672"
		imBt3.Size = UDim2.new(0.5, 0, 0.5, 0)
		imBt3.Position = UDim2.new(0.5, 0, 0, 0)		
		imBt3.BackgroundTransparency = 1.0
		imBt3.Parent = frame
		imBt3.MouseButton1Click:connect(follow)
		
		imBt4 = Instance.new("ImageButton")
		imBt4.Name = "Attack"		
		imBt4.Image = "http://www.roblox.com/asset/?id=53557706"
		imBt4.Size = UDim2.new(0.5, 0, 0.5, 0)
		imBt4.Position = UDim2.new(0.5, 0, 0.5, 0)		
		imBt4.BackgroundTransparency = 1.0
		imBt4.Parent = frame
		imBt4.MouseButton1Click:connect(attack)
	end
end

skeletonValue.Changed:connect(createGui)

function wait12()
	wait(12)
end

function castSpell(key)
	if key:lower() == "x" then 
		if skeletonValue.Value == 0 then 
			if co == nil or coroutine.status(co) == 'dead' then
			-- Cast mark of the damned on the target
				print("Ready to mark")
				mark.Value = 1
				co = coroutine.create(wait12)
				coroutine.resume(co)
				fire = Instance.new("Fire")
				fire.Parent = Hammer
				wait(5.0)
				fire:Remove()
			end
		end
	end 
end

local anims = {"Swing", "Slam"}

function onActivated()
	while Tool.Enabled == false do wait() end

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	
	hammerAnim = myHumanoid:LoadAnimation(Tool:FindFirstChild(anims[math.random(1,2)]))
	if hammerAnim then hammerAnim:Play() end	
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	mouse.KeyDown:connect(castSpell)
end

function onUnequipped()
	if hammerAnim then hammerAnim:Stop() end	
	if skeleGui then skeleGui:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

