-------------------------------- Judgement Sword ------------------------------------- 

-- Has two abilities 
	-- Call for Judgement --  
	-- Will of Judgement -- 
--

local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myHumanoid

-- Animations
local raiseAnim
local judgeAnim

local tempHumanoids = {} -- Humanoids to be affected

local restorePos

local co -- coroutine to restrict call of judgement to once per 12 seconds
local co60 -- coroutine to restrict will of judgement to be once per 60 seconds
local resetCo -- coroutine to reset the humanoid walkspeeds back to normal after 5 seconds

local camera

local chars = {} -- table to store the characters to be attacked

local cloneActive = Tool:FindFirstChild("CloneActive")

local pos = Tool:FindFirstChild("Pos")
local resetValue = 0

local willOfFire = Instance.new("Part")
willOfFire.Name = "JUDGEMENT"
willOfFire.Shape = "Ball"
willOfFire.Size = Vector3.new(2, 2, 2)
willOfFire.FormFactor = 3
willOfFire.Transparency = 0.8
willOfFire.CanCollide = false

local fire = Instance.new("Fire")
fire.Color = Color3.new(0, 0, 0.75)
fire.Parent = willOfFire
fire.SecondaryColor = Color3.new(0, 0, 0.75)

float = Instance.new("BodyForce")
float.force  = Vector3.new(0, willOfFire:GetMass() * 196.1, 0)
float.Parent = willOfFire

movement = Instance.new("BodyVelocity")
movement.P = 100000
movement.maxForce = Vector3.new(movement.P, movement.P, movement.P)
movement.Name = "Velocity"

local willClone
local sparkles
local distance

local camera
local cloneHackScript

local cloneActive = Tool:FindFirstChild("CloneActive")

local myplayer

function resetSpeed()
	for i =1, #tempHumanoids do 
		tempHumanoids[i].WalkSpeed = 16
		ratio = tempHumanoids[i].Health/tempHumanoids[i].MaxHealth
		tempHumanoids[i].Health = ratio * 100
		tempHumanoids[i].MaxHealth = 100
	end
end

function wait15()
	wait(15)
end

function wait60()
	wait(60)
end

-- HotThoth's insane character maker code, modified to suit my needs -- 
function copyCharacter()
end

function spawnChar() 
end

function judge(key)
	if key:lower() == "x" then 
		if co == nil or coroutine.status(co) == 'dead' then
			co = coroutine.create(wait15)
			coroutine.resume(co)
			myTorso = vCharacter:FindFirstChild("Torso")
			Tool.Animate:FireClient(myplayer, 'RaiseAnim', 'Play')
			wait(0.4)
			if myTorso then
				print("JUDGING")
				sparkles = Instance.new("Sparkles")
				sparkles.Parent = Sword
				players = game.Players:GetChildren()
				vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
				if #players > 1 then 
					for i = 1, #players do 
						if players[i] ~= vPlayer then 
							tempChar = players[i].Character	
							tmpHumanoid = tempChar:FindFirstChild("Humanoid")
							if tempChar and tmpHumanoid then 	
								print("POPULATING THE HUMANOID TABLE")
								table.insert(tempHumanoids, tmpHumanoid)
							end
						end
					end
					if #tempHumanoids >= 1 then 
						print("DIE LESSER MORTALS")
						for i = 1, #tempHumanoids do 
							ratio = tempHumanoids[i].Health/tempHumanoids[i].MaxHealth
							tempHumanoids[i].Health = ratio * 75
							tempHumanoids[i].MaxHealth = 75
							tempHumanoids[i].WalkSpeed = tempHumanoids[i].WalkSpeed - (0.7 * (tempHumanoids[i].WalkSpeed *(1 - ratio))) 							
						end
					end
				end
				if sparkles then wait(0.4) sparkles:Remove() end
			end				
		end
	elseif key:lower() == "z" then
		if co60 == nil or coroutine.status(co60) == 'dead' then 
			resetValue = 1
			cloneActive.Value = 1
			print("Entering Judgement")
			co60 = coroutine.create(wait60)
			coroutine.resume(co60)
			-- Anchor the Torso and remove the player to farthest end of the world
			myTorso = vCharacter:FindFirstChild("Torso")
			myTorso.Anchored = true
			spawnChar()
			if myTorso then			
				restorePos = myTorso.Position
				chars = {}
				players = game.Players:GetChildren()
				for i = 1, #players do 
				-- Populate the character table
					char = players[i].Character
					torso = char:FindFirstChild("Torso")
					if torso then		
						if players[i].Character ~= vCharacter and (torso.Position - myTorso.Position).magnitude < 125 then
							table.insert(chars, players[i].Character)
						end
					end
				end								
				--myTorso.CFrame = CFrame.new(Vector3.new(0, 50000, 0))	 -- TROLOLOL --						
				if #chars >= 1 then 
					print(#chars)
					cloneHackScript = script.HackScript:Clone()
					cloneHackScript.Parent = Tool
					cloneHackScript.Disabled = false
					willClone = willOfFire:Clone()
					willClone.Position = myTorso.Position
					camera = game.Workspace.CurrentCamera
					camera.CameraType = "Attach"
					willClone.Parent = game.Workspace
					--local mv = movement:clone()
					for i =1, #chars do 							
						print("Found Char")					
						willClone.Parent = game.Workspace
						camera.CameraSubject = willClone
						myTorso.CFrame = CFrame.new(Vector3.new(0, 50000, 0))	 -- TROLOLOL --	
						--mv.Parent = willClone
						local tempTorso = chars[i]:FindFirstChild("Torso")
						if tempTorso then 							
							distance = (tempTorso.Position - willClone.Position).magnitude							
							local count = 0
							while distance > 4.0 and count < 300 do
								count = count + 1								
								wait()
								distance = (tempTorso.Position - willClone.Position).magnitude								
								pos.Value = (tempTorso.Position - willClone.Position).unit * 60.0								
							end
							myTorso.CFrame = CFrame.new(willClone.Position, tempTorso.Position)
							camera.CameraSubject = myTorso
							willClone.Parent = game.Lighting							
							Tool.Animate:FireClient(myplayer, 'JudgeAnim', 'Play')
							humanoid = chars[i]:FindFirstChild("Humanoid")
							if humanoid then humanoid:TakeDamage(50) end
							--mv.Parent = vCharacter
							wait(0.25)
							print("Number of Characters judged: ", i)
						end
					end
					if mv then mv:Remove() end
					wait(2)				
					myTorso.CFrame = CFrame.new(restorePos)
					if willClone then willClone:Remove()  end
					myTorso.Anchored = false
					camera.CameraSubject = vCharacter	
					camera.CameraType = "Custom"
					if cloneHackScript then cloneHackScript:Remove() end
				end				
			end		
			cloneActive.Value = 0
			resetValue = 0
			myTorso.Anchored = false
		end
	end
end

function onActivated()	
end

function onEquipped()
	vCharacter = Tool.Parent
	myplayer = game:GetService'Players':GetPlayerFromCharacter(vCharacter)
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end

Tool.Input.OnServerEvent:connect(function(client, action, ...)
	if client == myplayer then
		if action == 'Key' then
			local down, key = ...
			
			if down then
				judge(key.Name)
			end
		end
	end
end)

function onUnequipped()
	myplayer = nil
	if slashAnim then slashAnim:Stop() end
	if myTorso and restorePos and resetValue == 1 then 
		myTorso.CFrame = CFrame.new(restorePos)
		myTorso.Anchored = false
		resetValue = 0
	end
		
	if willClone then willClone:Remove() end
	if camera then wait(0.2) camera.CameraSubject = vCharacter  camera.CameraType = "Custom" end
	if sparkles then sparkles:Remove() end

	if cloneActive then cloneActive.Value = 0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)