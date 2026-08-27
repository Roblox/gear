local Tool = script.Parent 
local Hammer = Tool.Handle 

local raiseAnim 
local vCharacter 

local co
local removeCo

local clonedSgs = {}

sg = Instance.new("ScreenGui")
sg.Name = "DARK"

image = Instance.new("ImageLabel")
image.Image = "http://www.roblox.com/asset/?id=53620870"
image.Active = true 
image.BackgroundTransparency = 1.0
image.Size = UDim2.new(1, 0, 1, 0)
image.Parent = sg

function wait25()
	wait(25)
end

function remove()
	wait(2.5)
	if clonedSgs and #clonedSgs >=1 then 
		for i = 1, #clonedSgs do
			clonedSgs[i]:Remove()
		end
	end
end

function blind(key)
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	myTorso = vCharacter:FindFirstChild("Torso")
	if key:lower() == "x" then 
		if co == nil or coroutine.status(co) == 'dead' then
			co = coroutine.create(wait25)
			coroutine.resume(co)					
			players = game.Players:GetChildren()
			if #players > 1 then 
				for i = 1, #players do 	
					if players[i] ~= vPlayer then 
						tempChar = players[i].Character
						if (tempChar.Torso.Position - myTorso.Position).magnitude < 100 then
							cloneSg = sg:Clone()
							table.insert(clonedSgs, cloneSg)
							cloneSg.Parent = players[i].PlayerGui
						end
					end
				end
				removeCo = coroutine.create(remove)
				coroutine.resume(removeCo)
			end			
		end
	end
end

function onActivated() 
	while Tool.Enabled == false do wait() end
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")           
	if myHumanoid == nil then 
		return 
	end 
	raiseAnim = myHumanoid:LoadAnimation(Tool.RaiseAnim) 
	if raiseAnim then raiseAnim:Play() end            
end 

function onEquipped(mouse) 
	vCharacter = Tool.Parent
	mouse.KeyDown:connect(blind)
end 


function onUnequipped() 
	if raiseAnim then raiseAnim:Stop() end 
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 