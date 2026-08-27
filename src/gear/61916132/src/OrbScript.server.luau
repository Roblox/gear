local Tool = script.Parent
local Orb = Tool.Handle

local vCharacter 
local myTorso
local myHumanoid

local screenGui

local healAmount = 20

local orbClones = {}

local numberOfOrbs

local dropOrb = Tool:FindFirstChild("DropOrb")
while dropOrb == nil do
	dropOrb = Tool:FindFirstChild("DropOrb")
	wait()
end

function canInfuse(hit, orb)
	if hit and hit.Parent then 
		if hit.Parent.className == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		else
			humanoid = hit.Parent:FindFirstChild("Humanoid")
		end
		if humanoid == myHumanoid then 
			if humanoid.Health + healAmount <= myHumanoid.MaxHealth then 
				humanoid.Health = humanoid.Health + healAmount
			else 
				humanoid.Health = humanoid.MaxHealth
			end	
			if myHumanoid.WalkSpeed == 16 then 
				myHumanoid.WalkSpeed = 26.0
				coroutine.resume(coroutine.create(function() 
					wait(4.0)
					if myHumanoid then myHumanoid.WalkSpeed = 16 end
				end))
			end			
			if orb and orb.Parent then 
				orb:Remove() 
				numberOfOrbs = Tool:FindFirstChild("NumberOfOrbs")
				if numberOfOrbs and numberOfOrbs.Value < 8 then 
					numberOfOrbs.Value = numberOfOrbs.Value + 1 
				end
			end			
		end
	end
end

function healTheMan()
	while orbClones and #orbClones > 0 do 
		for i = 1, #orbClones do
			if orbClones[i] then 
				local timer = orbClones[i]:FindFirstChild("Timer")
				if timer and timer.Value > 0 then 
					timer.Value = timer.Value - 1
					if orbClones[i] then
						local distance = (orbClones[i].Position - myTorso.Position).magnitude
						if distance < 15 then 
							if orbClones[i]:FindFirstChild("BP") then orbClones[i].BP:Remove() end
							orbClones[i].Velocity = (myTorso.Position - orbClones[i].Position).unit * 30
						end
					end
				else
					if orbClones[i] then orbClones[i]:Remove() end
					table.remove(orbClones, i)
				end		
			end
		end
		wait(0.1)
	end
end

function makeOrb()
	dropOrb = Tool:FindFirstChild("DropOrb")
	if dropOrb and dropOrb.Value == 1 then 
		local orbClone = Orb:Clone()
	
		Orb.Transparency = 1.0

		local bg = Instance.new("BodyGyro")
		bg.cframe = Orb.CFrame 
		bg.P = 100000
		bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P)
		bg.Parent = orbClone

		local bp = Instance.new("BodyPosition")
		bp.Name = "BP"
		bp.P = 50000
		bp.maxForce = Vector3.new(bp.P, bp.P, bp.P)
		bp.position = Orb.Position + Vector3.new(0, 3, 0)
		bp.Parent = orbClone		
		
		orbClone.CanCollide = false
		orbClone.Transparency = 0.0
		orbClone.Parent = game.Workspace		

		local bav = Instance.new("BodyAngularVelocity")
		bav.Name = "BAV"
		bav.P = 20000
		bav.maxTorque = Vector3.new(0, bav.P * 50, 0)
		bav.angularvelocity = Vector3.new(0, 2, 0)
		bav.Parent = orbClone 		

		timer = Instance.new("NumberValue")
		timer.Name = "Timer"
		timer.Value = 250		

		timer.Parent = orbClone
		wait(0.25)
		if bg then bg:Remove() end		
		Orb.Transparency = 0.0
		wait(1.75)
		table.insert(orbClones, orbClone)

		orbClone.Touched:connect(function(hit) canInfuse(hit, orbClone) end)
		if #orbClones == 1 then coroutine.resume(coroutine.create(healTheMan)) end
		wait(2.0)
		dropOrb.Value = 0
	end
end

dropOrb.Changed:connect(makeOrb)


function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	myHumanoid.Died:connect(function()
		numberOfOrbs = Tool:FindFirstChild("NumberOfOrbs")		
		if orbClones and numberOfOrbs then
			for i = 1, #orbClones do 
				if orbClones[i] then orbClones[i]:Remove() end
				numberOfOrbs = numberOfOrbs + 1
				wait(0.5)
			end
			
		end
	end)

	numberOfOrbs = Tool:FindFirstChild("NumberOfOrbs")      
      
	screenGui = Instance.new("ScreenGui") 
	screenGui.Name = "OrbsGui" 
	if myPlayer then 
		screenGui.Parent = myPlayer.PlayerGui 
	end      
	frame = Instance.new("Frame") 
	frame.Name = "TrapContainer" 
	frame.Position = UDim2.new(0, 0, 0.75, 0) 
	frame.Size = UDim2.new(0, 75, 0, 75) 
	frame.Parent = screenGui 
	frame.BackgroundTransparency = 1.0 

	image = Instance.new("ImageLabel") 
	image.Name = "Trap" 
	image.Image = "http://www.roblox.com/asset/?id=61885374" 
	image.Parent = frame 
	image.Size = UDim2.new(0, 75, 0, 75) 
	image.BackgroundTransparency = 1.0 

	text = Instance.new("TextLabel") 
	text.Text = numberOfOrbs.Value 

	numberOfOrbs.Changed:connect(function() if numberOfOrbs then text.Text = numberOfOrbs.Value end end) 

	text.Position = UDim2.new(0.75, 0, 0.75, 0) 
	text.Size = UDim2.new(0.5, 0, 0.5, 0) 
	text.Parent = frame 
	text.BackgroundTransparency = 1.0 
	text.TextColor = BrickColor.new("Earth green")
	text.FontSize = 7 
end

function onUnequipped()	
	Orb.Transparency = 0.0
	if screenGui then screenGui:Remove() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)