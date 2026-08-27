local Tool = script.Parent 
local Glove = Tool.Handle

local vCharacter 
local vPlayer 
local myTorso 
local myHumanoid 

local genericTextLabel
local sg 
local frame 

local otherPlayer

local challengeGui = Instance.new("ScreenGui")

local challengeAccepted = false
local debris = game:GetService("Debris")

local cloneId = 68452456
local cloneAsset = game:GetService("InsertService"):LoadAsset(cloneId):GetChildren()[1] 
local cloneChildren = cloneAsset:GetChildren()
for i = 1, #cloneChildren do 
	if cloneChildren[i]:IsA("Script") then 
		cloneChildren[i].Disabled = true 
	end 
end 

local vClone
local otherClone 

local unequipped = false

local slapSound

function createFloatingIcon(pos, icon, suspension, speed)
	local p = Instance.new("Part")
	p.Name = "FloatingPoint"
	p.FormFactor = "Custom"
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Transparency = 1
	p.CanCollide = false
	p.CFrame = CFrame.new(pos)

	local bf = Instance.new("BodyForce")
	bf.force = Vector3.new(0, speed * (196.0 * p:GetMass()), 0)

	local bbGui = Instance.new("BillboardGui")
	bbGui.Size = UDim2.new(2, 0, 2,0 )
	bbGui.Adornee = p
	
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = icon

	imageLabel.Parent = bbGui
	bbGui.Parent = p
	bf.Parent = p
	p.Parent = game.Workspace
	debris:AddItem(p, suspension) 
end

function createFloatingText(pos, text, suspension, speed)
	local p = Instance.new("Part")
	p.Name = "FloatingPoint"
	p.FormFactor = "Custom"
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Transparency = 1
	p.CanCollide = false
	p.CFrame = CFrame.new(pos)

	local bf = Instance.new("BodyForce")
	bf.force = Vector3.new(0, speed * (196.0 * p:GetMass()), 0)

	local bbGui = Instance.new("BillboardGui")
	bbGui.Size = UDim2.new(2, 0, 1, 0)
	bbGui.Adornee = p
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.FontSize = Enum.FontSize.Size18
	textLabel.TextColor3 = Color3.new(0, 1, 0)
	textLabel.Text = text

	textLabel.Parent = bbGui
	bbGui.Parent = p
	bf.Parent = p
	p.Parent = game.Workspace
	debris:AddItem(p, suspension) 
end

function createClone(character)	
	if character then 
		local thisClone = cloneAsset:Clone() 
		local children = character:GetChildren()
		for i = 1, #children do
			if children[i] then
				if children[i].ClassName == "Hat" then
					-- Special
					local hat = Instance.new("Hat")
					local Hpart = children[i].Handle:Clone()
					Hpart.Parent = hat
					Hpart.Position = thisClone.Head.Position
					hat.Name = children[i].Name
					hat.Parent = thisClone
					hat.AttachmentPos = children[i].AttachmentPos
					hat.AttachmentRight = children[i].AttachmentRight
					hat.AttachmentUp = children[i].AttachmentUp
					hat.AttachmentForward = children[i].AttachmentForward
				elseif children[i].Name == "Head" then
					local headChildren = children[i]:GetChildren()
					local cloneHead = thisClone:FindFirstChild("Head")
					local cloneHeadChildren = cloneHead:GetChildren()
					for j = 1, #cloneHeadChildren do
						if cloneHeadChildren then cloneHeadChildren[j]:Destroy() end
					end
					for k = 1, #headChildren do
						if headChildren[k] then
							local c = headChildren[k]:Clone()
							if c then c.Parent = cloneHead end
						end
					end
				elseif children[i].ClassName == "ForceField" or children[i].ClassName == "Script" or children[i].ClassName == "LocalScript" or children[i]:IsA("Humanoid") then
						-- Ignore it
				elseif children[i]:IsA("BasePart") then 
					if thisClone[children[i].Name] then 
						thisClone[children[i].Name].BrickColor = children[i].BrickColor 
					end 
				else
					children[i]:Clone().Parent = thisClone
				end
			end
		end
		return thisClone
	end 
end 

function createGame()	
	if otherPlayer then 
		if frame then frame.Visible = false end
		vClone = createClone(vPlayer.Character)
		otherClone = createClone(otherPlayer.Character)	
		
		if vClone and otherClone then 
			vClone.Name = vCharacter.Name 
			otherClone.Name = otherPlayer.Character.Name 
			vClone.Torso.CFrame = myTorso.CFrame 
			vClone.Parent = game.Workspace 			

			game.Workspace.CurrentCamera.CameraSubject = vClone
			game.Workspace.CurrentCamera.CameraType = "Custom" 
			
			myTorso.CFrame = CFrame.new(Vector3.new(0, 65000, 0) )
			myTorso.Anchored = true 

			local deployScript = Tool.CameraHijackScript:Clone()
			deployScript.Parent = otherPlayer.Character

			local cameraFocus = Instance.new("ObjectValue") 
			cameraFocus.Name = "CamJam" 
			cameraFocus.Value = otherClone 
			cameraFocus.Parent = deployScript 

			local endGame = Instance.new("BoolValue")
			endGame.Name = "End"
			endGame.Parent = deployScript 

			local otherJam = Instance.new("ObjectValue")
			otherJam.Name = "OtherJam"
			otherJam.Value = vClone
			otherJam.Parent = deployScript
			
			deployScript.Disabled = false
			
			otherClone.Parent = game.Workspace
			otherClone.Torso.CFrame = CFrame.new(vClone.Torso.Position + vClone.Torso.CFrame.lookVector * 3, vClone.Torso.Position)

			print("Let the slapping begin")
			local c1 = Tool:Clone() 
			c1.Parent = game.Workspace
			local c2 = Tool:Clone()
			c2.Parent = game.Workspace 
			local vCloneHumanoid = vClone.Humanoid 
			local otherCloneHumanoid = otherClone.Humanoid 
			vCloneHumanoid:EquipTool(c1)
			otherCloneHumanoid:EquipTool(c2)

			local vCloneAnim = vCloneHumanoid:LoadAnimation(Tool.SlapAnim)
			local otherCloneAnim = otherCloneHumanoid:LoadAnimation(Tool.SlapAnim)

			slapSound = Glove:FindFirstChild("SlapSound") 
				
			while vCloneHumanoid.Health > 1 and otherCloneHumanoid.Health > 1 and not unequipped do 
				if vCloneAnim then vCloneAnim:Play() end 
				if slapSound then slapSound:Play() end 
				wait(0.25)
				if math.random() > 0.25 then 
					if otherCloneHumanoid.Health - 10 > 1 then otherCloneHumanoid.Health = otherCloneHumanoid.Health - 10
					else
						otherCloneHumanoid.Health = 1
					end 
					createFloatingIcon(vClone.Head.Position + Vector3.new(0, 5, 0), "http://www.roblox.com/asset/?id=75554763", 1.5, 1.025)
				else 
					createFloatingIcon(vClone.Head.Position + Vector3.new(0, 5, 0), "http://www.roblox.com/asset/?id=75554701", 1.5, 1.025)
				end 		
				wait(0.25)
				if slapSound then slapSound:Play() end 
				if otherCloneAnim then otherCloneAnim:Play() end 		
				if math.random() > 0.25 then 
					if vCloneHumanoid.Health - 10 > 1 then vCloneHumanoid.Health = vCloneHumanoid.Health - 10 
					else 
						vCloneHumanoid.Health = 1
					end 
					createFloatingIcon(otherClone.Head.Position + Vector3.new(0, 5, 0), "http://www.roblox.com/asset/?id=75554763", 1.5, 1.025)
				else 
					createFloatingIcon(otherClone.Head.Position + Vector3.new(0, 5, 0), "http://www.roblox.com/asset/?id=75554701", 1.5, 1.025)
				end 
				wait(0.45)				
			end 
			 
			if vCloneHumanoid.Health == otherCloneHumanoid.Health then 
				createFloatingText((vClone.Torso.Position + vClone.Torso.CFrame.lookVector * 3.0) + Vector3.new(0, 5, 0), "Its a tie", 5, 1.005) 
			elseif vCloneHumanoid.Health > otherCloneHumanoid.Health then
				createFloatingText((vClone.Torso.Position + vClone.Torso.CFrame.lookVector * 3.0) + Vector3.new(0, 5, 0), vClone.Name .. " won the contest" , 5, 1.005) 
			else 
				createFloatingText((vClone.Torso.Position + vClone.Torso.CFrame.lookVector * 3.0) + Vector3.new(0, 5, 0), otherClone.Name .. "  won the contest", 5, 1.005) 
			end 
			wait(5.5)
			if frame then frame.Visible = true end
			if endGame then endGame.Value = true end 
			myTorso.CFrame = vClone.Torso.CFrame 
			myTorso.Anchored = false 
			
			game.Workspace.CurrentCamera.CameraSubject = vCharacter
			game.Workspace.CurrentCamera.CameraType = "Custom"			
			if vClone then vClone:Destroy() end 
			if otherClone then otherClone:Destroy() end 
		end 
	end 
end 

function createChallengeGui()
	local sGui = Instance.new("ScreenGui")
	sGui.Name = "SlapChallengeGui"
	
	local sFrame = Instance.new("Frame")
	sFrame.Name = "Challenge Frame"
	sFrame.Size = UDim2.new(0, 150, 0, 50)
	sFrame.Position = UDim2.new(0, 10, 0.5, 0)
	sFrame.Parent = sGui
	sFrame.BackgroundTransparency = 1.0 

	local sButton = Instance.new("TextButton")
	sButton.Name = "Challenge Button"
	sButton.Size = UDim2.new(1, 0, 1, 0)
	sButton.Text = "Click to accept slap challenge!"
	sButton.Position = UDim2.new(0, 0, 0, 0)
	sButton.Size = UDim2.new(1, 0, 1, 0)
	sButton.Parent = sFrame	
	sButton.BackgroundColor3 = Color3.new(1, 1, 1)
	
	return sGui 
end 

function onEquipped(mouse)
	unequipped = false 
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then 
		local playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui and playerGui:FindFirstChild("GloveGui") == nil then 
			sg = Instance.new("ScreenGui")
			sg.Name = "GloveGui"
			sg.Parent = playerGui 

			frame = Instance.new("Frame")
			frame.Parent = sg 
			frame.Size = UDim2.new(0, 360, 0, 30)
			frame.Position = UDim2.new(0.5, -180, 1, -130) 
			frame.Style = Enum.FrameStyle.RobloxRound

			genericTextLabel = Instance.new("TextLabel")
			genericTextLabel.BackgroundTransparency = 1.0
			genericTextLabel.Size = UDim2.new(1, 0, 1, 0)
			genericTextLabel.Visible = true 
			genericTextLabel.ZIndex = 10 
			genericTextLabel.FontSize = Enum.FontSize.Size10 
			genericTextLabel.Font = Enum.Font.Legacy
			genericTextLabel.TextColor3 = Color3.new(1, 1, 0)
			genericTextLabel.TextXAlignment = Enum.TextXAlignment.Center
			genericTextLabel.TextYAlignment = Enum.TextYAlignment.Top
			genericTextLabel.Parent = frame
			genericTextLabel.Text = "Click on someone to challenge them to a duel!" 
		end 
	end 
	if mouse then 
		mouse.Button1Down:connect(function()
			if mouse.Target then 
				print(mouse.Target)
				local target = mouse.Target 
				if target.Parent then 
					local otherHumanoid = target.Parent:FindFirstChild("Humanoid")
					if target.Parent:IsA("Hat") and target.Parent.Parent then
						otherHumanoid = target.Parent.Parent:FindFirstChild("Humanoid")
					end 
					if otherHumanoid then 
						otherPlayer = game.Players:GetPlayerFromCharacter(otherHumanoid.Parent) 
						if otherPlayer and otherPlayer:FindFirstChild("PlayerGui") and not challengeGui.Parent then 
							challengeGui = createChallengeGui()
							--debris:AddItem(challengeGui, 15)								
							challengeGui.Parent = otherPlayer.PlayerGui
								
							print(challengeGui, challengeGui.Parent, otherPlayer) 
							
							local acceptScript = Tool.AcceptanceScript:Clone()
							acceptScript.Parent = challengeGui							

							while acceptScript:FindFirstChild("Accept") == nil do wait() end 
							acceptVal = acceptScript.Accept 

							acceptVal.Changed:connect(function()
								if acceptVal and acceptVal.Value == true then 
									print("Creating Game")
									createGame()
								end 
							end) 
							
							acceptScript.Disabled = false
							print("Enabled") 

							if genericTextLabel then 
								genericTextLabel.Text = "Waiting on " .. otherPlayer.Name .. " to accept"
								coroutine.resume(coroutine.create(function()
									wait(16.0)
									if not challengeAccepted then 
										genericTextLabel.Text = "Click on someone to challenge them to a slapping contest!" 
									end 
								end))
							end 								
						end 
					end 
				end 
			end			
		end) 
	end 
end 

function onUnequipped()
	if sg then sg:Remove() end 
	challengeAccepted = false 
	if challengeGui then challengeGui:Destroy() end 
	unequipped = true 
	if slapSound then slapSound:Stop() end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
