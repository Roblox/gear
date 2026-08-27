math.randomseed(tick()); math.random()

function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tool = script.Parent
local Handle = Tool.Handle
local Tank = game:GetService("InsertService"):LoadAsset(56936657)
local SplashSound
if Tank then
	Tank = Tank:GetChildren()[1]
	waitForChild(Tool, "TankRemoveScript"):Clone().Parent = Tank
	local GeneratingPlayer = Instance.new("ObjectValue")
	GeneratingPlayer.Name = "GeneratingPlayer"
	GeneratingPlayer.Parent = Tank
	local OtherPlayer = Instance.new("ObjectValue")
	OtherPlayer.Name = "OtherPlayer"
	OtherPlayer.Parent = Tank
	local locSplashSound = Instance.new("Sound")
	locSplashSound.Name = "SplashSound"
	locSplashSound.SoundId = "http://www.roblox.com/asset/?id=58274204"
	locSplashSound.Parent = Tank
end
local TankClone

local toolContestGui = waitForChild(Tool, "FishingContestGui")
local toolOpponentDiedGui = waitForChild(toolContestGui, "OpponentDiedGui")
local toolOpponent = waitForChild(toolOpponentDiedGui, "Opponent")

local ContestGui = toolContestGui:Clone()
local IntroFrame = waitForChild(ContestGui, "IntroFrame")
local IntroText = waitForChild(IntroFrame, "IntroText")
local MessageFrame = waitForChild(ContestGui, "MessageFrame")
local OKButton = waitForChild(MessageFrame, "OKButton")
local MessageText = waitForChild(MessageFrame, "MessageText")
local AnnounceFrame = waitForChild(ContestGui, "AnnounceFrame")
local AnnounceText = waitForChild(AnnounceFrame, "AnnounceText")
local ContestFrame = waitForChild(ContestGui, "ContestFrame")
local YourName = waitForChild(ContestFrame, "YourName")
local YourScore = waitForChild(ContestFrame, "YourScore")
local OtherName = waitForChild(ContestFrame, "OtherName")
local OtherScore = waitForChild(ContestFrame, "OtherScore")
local TroutPic = waitForChild(ContestFrame, "TroutPic")
local Timer = waitForChild(ContestFrame, "Timer")
local SecondsLeft = waitForChild(ContestFrame, "SecondsLeft")
local OpponentDiedGui = waitForChild(ContestGui, "OpponentDiedGui")
local OnOpponentDied = waitForChild(OpponentDiedGui, "OnOpponentDied")
local DingSound = waitForChild(ContestGui, "DingSound")
local BuzzSound = waitForChild(ContestGui, "BuzzSound")

local NewContestGui
local otherAskingFrame
local otherAnnounceFrame
local otherAnnounceText
local otherMessageFrame
local otherOKButton
local otherMessageText
local otherContestFrame
local otherMessageFrame
local otherMessageText
local otherOpponentDiedGui
local otherOpponent
local otherOnOpponentDied
local otherDingSound
local otherBuzzSound

local Opponent = waitForChild(OpponentDiedGui, "Opponent")
local otherPlayer
local otherPlayerName
local otherPlayerGui
local otherCharacter
local otherHumanoid
local otherTorso

local myCharacter
local myPlayer
local myPlayerName
local myPlayerGui

local Trout
local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, 196.2 * Handle:GetMass(), 0)
AntiGrav.Name = "AntiGrav"
local randTheta
local velX
local velY
local myTroutNumber = 0
local otherTroutNumber = 0
local recentlyHit = false

local signs = {1, -1}

local guiCo
local timerCo

local debris = game:GetService("Debris")

local currentlyPlaying = false
local askingOpponent = false
local otherPlayerInWater = false
local myPlayerInWater = false


function totalReset(thingRemoved)
	if thingRemoved == ContestGui then
		local CloneScript = script:Clone()
		CloneScript.Parent = Tool
		script:Remove()
	end
end

function clearContestFrame()
	local contestFrameChildren = ContestFrame:GetChildren()
	for i = 1, #contestFrameChildren do
		if contestFrameChildren[i].Name == "TroutPic" and contestFrameChildren[i].Visible then
			contestFrameChildren[i]:Remove()
		end
	end
	YourName.Text = "You:"
	OtherName.Text = "Other Player:"
	YourScore.Text = "0"
	OtherScore.Text = "0"
	SecondsLeft.Text = "               seconds left!"
	Timer.Text = "30"
	Timer.TextColor3 = Color3.new(0, 1, 0)
	SecondsLeft.Visible = false
	Timer.Visible = false
end

function reset()
	IntroText.Text = "Click a character to challenge him/her to bare-handed fishin'!"
	MessageFrame.Visible = false
	clearContestFrame()
	ContestFrame.Visible = false
	IntroFrame.Visible = true
	askingOpponent = false
	currentlyPlaying = false
	toolOpponent.Value = nil
	if Opponent then Opponent.Value = nil end
	otherPlayerInWater = false
	myPlayerInWater = false
	myTroutNumber = 0
	otherTroutNumber = 0
end

function onMyCharRemoved()
	Handle.Transparency = 0.0
	reset()
	ContestGui.Parent = nil
	if TankClone then TankClone:Remove() end
	if NewContestGui then
		otherMessageFrame = NewContestGui:FindFirstChild("MessageFrame")
		if otherMessageFrame then
			otherOKButton = otherMessageFrame:FindFirstChild("OKButton")
			otherMessageText = otherMessageFrame:FindFirstChild("MessageText")
			if otherOKButton and otherMessageText then
				otherMessageText.Text = myPlayerName .. " died. So you win by default!"
				otherOKButton.Text = "Hooray!"
				otherOKButton.MouseButton1Click:connect(function() NewContestGui:Remove() end)
				otherAskingFrame.Visible = false
				if otherAnnounceFrame then otherAnnounceFrame.Visible = false end
				if otherContestFrame then otherContestFrame.Visible = false end
				otherMessageFrame.Visible = true
			else
				NewContestGui:Remove()
			end
		else
			NewContestGui:Remove()
		end
	end
end

function onEquipped()
	if currentlyPlaying then return end
	reset()
	myCharacter = Tool.Parent
	if myCharacter then
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		if myPlayer then
			myPlayerName = myPlayer.Name
			myPlayerGui = waitForChild(myPlayer, "PlayerGui")
			ContestGui.Parent = myPlayerGui
			myPlayerGui.ChildRemoved:connect(totalReset)
		end
	end
end

function onUnequipped()
	if Tool.Parent == nil or Tool.Parent == game.Workspace or not currentlyPlaying then
		Handle.Transparency = 0.0
		reset()
		ContestGui.Parent = nil
		if TankClone then TankClone:Remove() end
		if NewContestGui then
			otherMessageFrame = NewContestGui:FindFirstChild("MessageFrame")
			if otherMessageFrame then
				otherOKButton = otherMessageFrame:FindFirstChild("OKButton")
				otherMessageText = otherMessageFrame:FindFirstChild("MessageText")
				if otherOKButton and otherMessageText then
					if currentlyPlaying then
						otherMessageText.Text = myPlayerName .. " can't challenge you any more. So you win by default!"
						otherOKButton.Text = "Hooray!"
						otherOKButton.MouseButton1Click:connect(function() NewContestGui:Remove() end)
						otherAskingFrame.Visible = false
						if otherAnnounceFrame then otherAnnounceFrame.Visible = false end
						if otherContestFrame then otherContestFrame.Visible = false end
						otherMessageFrame.Visible = true
					else
						NewContestGui:Remove()
					end
				else
					NewContestGui:Remove()
				end
			else
				NewContestGui:Remove()
			end
		end
	end
end

function troutTouched(hit)
	if not myCharacter and otherCharacter then
		Trout:Remove()
		return
	end
	if not recentlyHit then
		if (hit.Parent == myCharacter) then
			recentlyHit = true
			myTroutNumber = myTroutNumber + 1
			YourScore.Text = "" .. myTroutNumber
			otherContestFrame.OtherScore.Text = "" .. myTroutNumber
			local myNewTroutPic = TroutPic:Clone()
			myNewTroutPic.Position = UDim2.new(0, -5 + 15 * myTroutNumber, 0.5, -70)
			myNewTroutPic.Visible = true
			myNewTroutPic.Parent = ContestFrame
			local otherNewTroutPic = TroutPic:Clone()
			otherNewTroutPic.Position = UDim2.new(0, -5 + 15 * myTroutNumber, 0.5, 50)
			otherNewTroutPic.Visible = true
			otherNewTroutPic.Parent = otherContestFrame
			DingSound:Play()
			otherBuzzSound:Play()
			if Trout then Trout:Remove() end
			wait(1)
			spawnTrout()
		elseif (hit.Parent == otherCharacter) then
			recentlyHit = true
			otherTroutNumber = otherTroutNumber + 1
			OtherScore.Text = "" .. otherTroutNumber
			otherContestFrame.YourScore.Text = "" .. otherTroutNumber
			local myNewTroutPic = TroutPic:Clone()
			myNewTroutPic.Position = UDim2.new(0, -5 + 15 * otherTroutNumber, 0.5, 50)
			myNewTroutPic.Visible = true
			myNewTroutPic.Parent = ContestFrame
			local otherNewTroutPic = TroutPic:Clone()
			otherNewTroutPic.Position = UDim2.new(0, -5 + 15 * otherTroutNumber, 0.5, -70)
			otherNewTroutPic.Visible = true
			otherNewTroutPic.Parent = otherContestFrame
			BuzzSound:Play()
			otherDingSound:Play()
			if Trout then Trout:Remove() end
			wait(1)
			spawnTrout()
		else	-- It hit something that isn't a character...
			randTheta = math.pi * (math.random() - 0.5)
		end
	end
end

function moveTrout()
	for i = 1, 90 do
		if not Trout then break end
		newPosition = Trout.Position + Vector3.new(0, WaterPos.Y - Trout.Position.Y, 0)
		velX = Trout.Velocity.X
		velZ = Trout.Velocity.Z
		newVelocity = Vector3.new(math.cos(randTheta/150) * velX - math.sin(randTheta/150) * velZ, 0, math.sin(randTheta/50) * velX + math.cos(randTheta/150) * velZ)
		newVelocity = 10 * newVelocity.unit
		Trout.CFrame = CFrame.new(newPosition, newPosition + newVelocity) * CFrame.Angles(-math.pi/2, 0, -math.pi/2)
		Trout.Velocity = newVelocity
		wait()
	end
end

function spawnTrout()
	if not currentlyPlaying then return end
	if not TankClone then return end
	Handle.Transparency = 1.0
	recentlyHit = false
	Trout = Handle:Clone()
	Trout.Transparency = 0.0
	Trout.CanCollide = true
	Trout.Name = "Trout"
	Trout.Parent = TankClone
	AntiGrav.Parent = Trout
	WaterPos = TankClone.Water.Position
	Trout.CFrame = CFrame.new(WaterPos + 7 * Vector3.new(signs[math.random(2)], 0, signs[math.random(2)]))
	Trout.Velocity = 10 * Vector3.new(math.random(), 0, math.random())
	Trout.CFrame = CFrame.new(Trout.Position, Trout.Position + Trout.Velocity) * CFrame.Angles(-math.pi/2, 0, -math.pi/2)
	Trout.Touched:connect(troutTouched)
	while Trout do
		if ((Trout.Position - WaterPos).magnitude > 20) then	-- If Trout's escaped the pool, then force it back in.
			Trout.CFrame = CFrame.new(WaterPos + 7 * Vector3.new(signs[math.random(2)], 0, signs[math.random(2)]))
			Trout.Velocity = 10 * Vector3.new(math.random(), 0, math.random())
			Trout.CFrame = CFrame.new(Trout.Position, Trout.Position + Trout.Velocity) * CFrame.Angles(-math.pi/2, 0, -math.pi/2)
		end
		randTheta = math.pi * (math.random() - 0.5)
		moveTrout()
	end
end

function endContest()
	currentlyPlaying = false
	otherPlayerInWater = false
	myPlayerInWater = false
	if TankClone then TankClone:Remove() end
	if Trout then Trout:Remove() end
	Handle.Transparency = 0.0
	clearContestFrame()
	ContestFrame.Visible = false
	otherContestFrame.Visible = false
	otherMessageFrame = NewContestGui.MessageFrame
	otherMessageText = otherMessageFrame.MessageText
	otherOKButton = otherMessageFrame.OKButton
	local deltaTrout = myTroutNumber - otherTroutNumber

	local CheerSound = Tool:FindFirstChild("CheerSound")
	if CheerSound then CheerSound = CheerSound:Clone() end
	local AwwSound = Tool:FindFirstChild("AwwSound")
	if AwwSound then AwwSound = AwwSound:Clone() end

	if (deltaTrout > 0) then
		MessageText.Text = "Congrats! You beat " .. otherPlayerName .. " by " .. deltaTrout .. " trout!"
		otherMessageText.Text = "Aw, man. " .. myPlayerName .. " beat you by " .. deltaTrout .. " trout."
		CheerSound.Parent = myPlayer
		AwwSound.Parent = otherPlayer
		OKButton.Text = "Awesome!"
		otherOKButton.Text = "OK... :("
	elseif (deltaTrout < 0 ) then
		otherMessageText.Text = "Congrats! You beat " .. myPlayerName .. " by " .. -deltaTrout .. " trout!"
		MessageText.Text = "Aw, man. " .. otherPlayerName .. " beat you by " .. -deltaTrout .. " trout."
		CheerSound.Parent = otherPlayer
		AwwSound.Parent = myPlayer
		OKButton.Text = "OK... :("
		otherOKButton.Text = "Awesome!"
	else	-- deltaTrout == 0
		MessageText.Text = "It's a tie! You both caught " .. myTroutNumber .. " trout."
		otherMessageText.Text = MessageText.Text
		OKButton.Text = "Huh. OK."
		otherOKButton.Text = "Huh. OK."
	end

	if CheerSound then 
		debris:AddItem(CheerSound, 5)
		CheerSound:Play() 
	end
	if AwwSound then 
		debris:AddItem(AwwSound, 5)
		AwwSound:Play() 
	end

	OKButton.MouseButton1Click:connect(reset)
	otherOKButton.MouseButton1Click:connect(function() NewContestGui:Remove() end)
	MessageFrame.Visible = true
	otherMessageFrame.Visible = true
end

function timeContest()
	otherTimer = otherContestFrame.Timer
	otherSecondsLeft = otherContestFrame.SecondsLeft
	Timer.Visible = true
	SecondsLeft.Visible = true
	otherTimer.Visible = true
	otherSecondsLeft.Visible = true
	for i = 1, 30 do
		wait(1)
		local newText = "" .. 30 - i
		Timer.Text = newText
		otherTimer.Text = newText
		local newColor = Color3.new(i/30, (30 - i) / 30, 0)
		Timer.TextColor3 = newColor
		otherTimer.TextColor3 = newColor
		if i == 29 then
			SecondsLeft.Text = "               second left!"
			otherSecondsLeft.Text = "               second left!"
		end
	end
	endContest()
end

function runContest()
	YourName.Text = myPlayerName .. ":"
	OtherName.Text = otherPlayerName .. ":"
	otherContestFrame = NewContestGui.ContestFrame
	otherContestFrame.YourName.Text = otherPlayerName .. ":"
	otherContestFrame.OtherName.Text = myPlayerName .. ":"
	ContestFrame.Visible = true
	otherContestFrame.Visible = true
	AnnounceText.Text = "Ready!"
	otherAnnounceText.Text = "Ready!"
	AnnounceFrame.Visible = true
	otherAnnounceFrame.Visible = true
	wait(1)
	AnnounceText.Text = "Set!"
	otherAnnounceText.Text = "Set!"
	wait(1)
	AnnounceText.FontSize = Enum.FontSize.Size18
	otherAnnounceText.FontSize = Enum.FontSize.Size18
	AnnounceText.Text = "GO!"
	otherAnnounceText.Text = "GO!"
	guiCo = coroutine.create(function() wait(1); AnnounceFrame.Visible = false; otherAnnounceFrame.Visible = false end)
	coroutine.resume(guiCo)
	timerCo = coroutine.create(timeContest)
	coroutine.resume(timerCo)
	spawnTrout()
end

function waterTouch(hit)
	local hitThing = hit.Parent
	if not hitThing then return end
	if hitThing:FindFirstChild("Humanoid") then
		if hitThing == myCharacter then
			if not myPlayerInWater then
				AnnounceFrame.Visible = false
				myPlayerInWater = true
				if SplashSound then SplashSound:Play() end
			end
		elseif hitThing == otherCharacter then
			if not otherPlayerInWater then
				otherAnnounceFrame.Visible = false
				otherPlayerInWater = true
				if SplashSound then SplashSound:Play() end
			end
		else	-- Someone else touched the water -- move them out!
			local lookVector
			if hitThing:FindFirstChild("Torso") then
				lookVector = hitThing.Torso.CFrame.lookVector
			else
				lookVector = Vector3.new(1, 0, 0)
			end
			hitThing:MoveTo(TankClone.Water.Position - 20 * lookVector)
			local UnwantedGui = waitForChild(Tool, "UnwantedTroutFisherGui"):Clone()
			local hitPlayer = game.Players:GetPlayerFromCharacter(hitThing)
			if hitPlayer then
				local ExistingGui = hitPlayer.PlayerGui:FindFirstChild("UnwantedTroutFisherGui")
				if ExistingGui then ExistingGui:Remove() end
				UnwantedGui.Parent = hitPlayer.PlayerGui
				waitForChild(UnwantedGui, "UnwantedGuiRunner").Disabled = false
			end
		end
	end
end

function beginContest()
	askingOpponent = false
	currentlyPlaying = true
	otherAskingFrame.Visible = false
	otherCharacter = otherPlayer.Character
	otherTorso = otherCharacter:FindFirstChild("Torso")
	if not otherTorso then
		reset()
	else
		TankClone = Tank:Clone()
		TankClone.Name = "Trout Fishing Tank"
		TankClone.Parent = game.Workspace
		TankClone:MoveTo(otherTorso.Position + 20 * otherTorso.CFrame.lookVector + Vector3.new(0, -2.9, 0))
		TankClone.PrimaryPart.Anchored = true
		waitForChild(TankClone, "GeneratingPlayer").Value = myPlayer
		waitForChild(TankClone, "OtherPlayer").Value = otherPlayer
		waitForChild(TankClone, "TankRemoveScript").Disabled = false
		otherDingSound = waitForChild(NewContestGui, "DingSound")
		otherBuzzSound = waitForChild(NewContestGui, "BuzzSound")
		SplashSound = waitForChild(TankClone, "SplashSound")
		IntroFrame.Visible = false
		AnnounceText.FontSize = Enum.FontSize.Size12
		AnnounceText.Text = "Get in the water!"
		AnnounceFrame.Visible = true
		otherAnnounceFrame = NewContestGui.AnnounceFrame
		otherAnnounceText = otherAnnounceFrame.AnnounceText
		otherAnnounceText.FontSize = Enum.FontSize.Size12
		otherAnnounceText.Text = "Get in the water!"
		otherAnnounceFrame.Visible = true
		TankClone.Water.Touched:connect(waterTouch)
		local count = 0
		while myCharacter and otherCharacter and not (otherPlayerInWater and myPlayerInWater) and count < 300 do
			wait()
			count = count + 1
		end
		if count == 300 then
			otherMessageFrame = NewContestGui.MessageFrame
			otherMessageText = otherMessageFrame.MessageText
			otherOKButton = otherMessageFrame.OKButton
			AnnounceFrame.Visible = false
			otherAnnounceFrame.Visible = false
			MessageText.Text = "Water unavailable/unreached; game canceled."
			otherMessageText.Text = "Water unavailable/unreached; game canceled."
			OKButton.Text = "OK"
			otherOKButton.Text = "OK"
			MessageFrame.Visible = true
			otherMessageFrame.Visible = true
			OKButton.MouseButton1Click:connect(reset)
			otherOKButton.MouseButton1Click:connect(function() NewContestGui:Remove() end)
			TankClone:Remove()
		else
			runContest()
		end
	end
	currentlyPlaying = false
end

function displayMessage()
	OKButton.MouseButton1Click:connect(reset)
	IntroFrame.Visible = false
	MessageFrame.Visible = true
end

function contestDeclined()
	askingOpponent = false
	NewContestGui:Remove()
	MessageText.Text = otherPlayerName .. " is scared of your fishin' prowess, and didn't accept your challenge."
	OKButton.Text = "OK. Their loss."
	toolOpponent.Value = nil
	if Opponent then Opponent.Value = nil end
	displayMessage()
end

function newOpponent()
	if toolOpponent.Value == nil then return end
	if askingOpponent or currentlyPlaying then return end
	
	if NewContestGui then NewContestGui:Remove() end

	otherPlayer = toolOpponent.Value
	otherPlayerGui = otherPlayer.PlayerGui
	otherPlayerName = otherPlayer.Name
	otherCharacter = otherPlayer.Character
	otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
	if not otherHumanoid then
		reset()
	end

	-- Skip it, and report the problem, if the opponent is already playing something else.
	if otherPlayerGui:FindFirstChild("BattleshipGui") or otherPlayerGui:FindFirstChild("ContestGui") or otherPlayerGui:FindFirstChild("FishingContestGui") then
		MessageText.Text = otherPlayerName .. " is already in a game; you'll have to wait a bit before you can show 'em what for."
		OKButton.Text = "Aw, shucks."
		displayMessage()
	else
		askingOpponent = true
		IntroText.Text = "Asking " .. otherPlayerName .. " about the contest..."
		NewContestGui = ContestGui:Clone()
		otherOpponentDiedGui = waitForChild(NewContestGui, "OpponentDiedGui")
		otherOpponent = waitForChild(otherOpponentDiedGui, "Opponent")
		if myPlayer then
			Opponent.Value = toolOpponent.Value
			otherOpponent.Value = myPlayer
			local NewOnOpponentDied = OnOpponentDied:Clone()
			NewOnOpponentDied.Parent = OpponentDiedGui
			NewOnOpponentDied.Disabled = false
			NewContestGui.Parent = otherPlayerGui
			waitForChild(otherOpponentDiedGui, "OnOpponentDied").Disabled = false
			otherAskingFrame = NewContestGui.AskingFrame
			NewContestGui.IntroFrame.Visible = false
			otherAskingFrame.Visible = true
			otherAskingFrame.QuestionText.Text = myPlayerName .. " challenges you to some bare-handed fishin'! Do you accept the challenge?"
			otherAskingFrame.AcceptButton.MouseButton1Click:connect(beginContest)
			otherAskingFrame.DeclineButton.MouseButton1Click:connect(contestDeclined)
		end	
	end	
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

toolOpponent.Changed:connect(newOpponent)

-- The following is in case this script is a clone of an earlier one, which was removed
--  when our opponent died.
if Tool.Parent ~= game.Workspace then
	Handle.Transparency = 0.0
	onEquipped()
end