local Tool = script.Parent
local gui = Tool.ContestGui
local playerGui = nil
local opponentGui = nil
local player = nil
local opp = nil
local opponentChangedSignal = nil
local opponentDiedSignal = nil
local gameCycles = 900
local gameTime = gameCycles
local playerClicks = 0
local opponentClicks = 0
local playerPlaying = false
local playerClickConnection = nil
local opponentClickConnection = nil

Tool.Opponent.Value = nil
local numbers = {Tool.One,Tool.Two,Tool.Three,Tool.Four,Tool.Five}


function onEquipped()

	playerGui = gui:clone()
	player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	playerGui.Parent = player.PlayerGui

	opponentChangedSignal = Tool.Opponent.Changed:connect(opponentChanged)

	for i = 1, #numbers do
		numbers[i]:Stop()
	end
	Tool.Start:Stop()

end


function onUnequipped()

	playerGui:remove()
	playerGui = nil
	if opponentGui ~= nil and playerPlaying then
		opponentGui.AcceptFrame.Visible = false
		opponentGui.MainFrame.Visible = false
		opponentGui.StarterFrame.Visible = false
		opponentGui.WarmUpFrame.Visible = false
		opponentGui.PopupFrame.Visible = true
		opponentGui.PopupFrame.TXT.Text = player.Name .. " dropped out of the contest, you win!!!"
		opponentGui.PopupFrame.Accept.MouseButton1Down:connect(function()
			opponentGui:remove()
			opponentGui = nil
			opp = nil
		end)
	elseif opponentGui ~= nil then
		opponentGui:remove()
			opponentGui = nil
			opp = nil
	end

	playerPlaying = false

	Tool.Opponent.Value = nil
	opponentChangedSignal:disconnect()

	for i = 1, #numbers do
		numbers[i]:Stop()
	end
	Tool.Start:Stop()

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

local changing = false

function opponentChanged()

	local value = Tool.Opponent.Value
	print("clickin'")
	
	if value == nil or playerPlaying then
		return
	end
	local num = math.random(1,100)
	print("Called " .. tostring(num))

	if changing then
		Tool.Opponent.Value = nil
		return
	end
	
	print(value.Name .. tostring(num))

	changing = true

	opp = value

	-- opponent is currently in another game, let the player know and reset
	if opp.PlayerGui:FindFirstChild("BattleshipGui") or opp.PlayerGui:FindFirstChild("ContestGui")  then
		
		playerGui.PopupFrame.TXT.Text = opp.Name .. " is currently playing another game!"
		playerGui.PopupFrame.Visible = true
		playerGui.PopupFrame.Accept.MouseButton1Down:connect(function()
			playerGui.PopupFrame.Visible = false
			playerGui.StarterFrame.TXT.Text = "Click on a Robloxian to challenge them to a hot dog eating contest!"
		end)

	else

		if opponentGui == nil then
			opponentGui = gui:clone()
		end
		opponentGui.StarterFrame.Visible = false
		opponentGui.AcceptFrame.Visible = true
		opponentGui.AcceptFrame.TXT.Text = player.Name .. " challenges you to a hot dog eating contest!"
		opponentGui.Parent = opp.PlayerGui

		playerGui.StarterFrame.TXT.Text = "Awaiting response from " .. opp.Name .. "..."

		opponentGui.AcceptFrame.Accept.MouseButton1Down:connect(opponentAccepted)
		opponentGui.AcceptFrame.Decline.MouseButton1Down:connect(opponentDeclined)
	end
	
	Tool.Opponent.Value = nil

	wait(0.1)
	changing = false

end

function opponentDied()

	playerPlaying = false

	playerGui:remove()
	playerGui = Tool.ContestGui:clone()
	playerGui.Parent = player.PlayerGui

	opponentGui:remove()
	opponentGui = nil
	opponentDiedSignal:disconnect()

end

function opponentAccepted()

	opponentDiedSignal = opp.Character.Humanoid.Died:connect(opponentDied)
	playerPlaying = true

	playerGui.StarterFrame.Visible = false
	opponentGui.AcceptFrame.Visible = false

	-- let players know the game is about to start
	giveWarning()

	-- set up for game and go!
	playerClicks = 0
	opponentClicks = 0
	gameTime = gameCycles

	playerGui.MainFrame.Visible = true
	opponentGui.MainFrame.Visible = true

	gameLoop()

	-- let the players check out the game screen for a second before results
	wait(1)

	playerGui.MainFrame.Visible = false
	opponentGui.MainFrame.Visible = false

	resultsAndReset()

end

function gameLoop()

	if playerClickConnection ~= nil then
		playerClickConnection:disconnect()
	end
	if opponentClickConnection ~= nil then
		opponentClickConnection:disconnect()
	end

	-- allow players to start clicking
	playerClickConnection = playerGui.MainFrame.PlayerIcon.MouseButton1Down:connect(function()
		playerClicks = playerClicks + 1
	end)
	opponentClickConnection = opponentGui.MainFrame.PlayerIcon.MouseButton1Down:connect(function()
		opponentClicks = opponentClicks + 1
	end)

	-- get to clicking!
	while gameTime > 0 do
		updateHotDogs()
		updateGameTime()
	end

end


function resultsAndReset()

	playerClickConnection:disconnect()
	opponentClickConnection:disconnect()
	
	-- player wins
	if playerClicks > opponentClicks then

		playerGui.PopupFrame.TXT.Text = "Congratulations! You beat " .. opp.Name  .. " by " .. tostring(playerClicks - opponentClicks) .. " hot dogs!"
		opponentGui.PopupFrame.TXT.Text = "Sorry, but " .. player.Name .. " ate " .. tostring(playerClicks - opponentClicks) .. " more hot dogs than you :("
		playerGui.PopupFrame.Visible = true
		opponentGui.PopupFrame.Visible = true
	
	-- opponent wins
	elseif playerClicks < opponentClicks then

		opponentGui.PopupFrame.TXT.Text = "Congratulations! You beat " .. player.Name  .. " by " .. tostring(opponentClicks - playerClicks) .. " hot dogs!"
		playerGui.PopupFrame.TXT.Text = "Sorry, but " .. opp.Name .. " ate " .. tostring(opponentClicks - playerClicks) .. " more hot dogs than you :("
		playerGui.PopupFrame.Visible = true
		opponentGui.PopupFrame.Visible = true

	-- a tie
	else

		opponentGui.PopupFrame.TXT.Text = "Unbelievable! A tie! What a great match!"
		playerGui.PopupFrame.TXT.Text = "Unbelievable! A tie! What a great match!"
		playerGui.PopupFrame.Visible = true
		opponentGui.PopupFrame.Visible = true

	end

	playerGui.PopupFrame.Accept.MouseButton1Down:connect(function()

		playerGui.PopupFrame.Visible = false

		playerGui.StarterFrame.TXT.Text = "Click on a Robloxian to challenge them to a hot dog eating contest!"
		playerGui.StarterFrame.Visible = true

		playerPlaying = false

	end)

	opponentGui.PopupFrame.Accept.MouseButton1Down:connect(function()

		opponentGui:remove()
		opponentGui = nil

	end)

end


function giveWarning()

	for i = 5, 1, -1 do
		if i == 5 then
			playerGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29384422"
			playerGui.WarmUpFrame.Visible = true

			opponentGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29384422"
			opponentGui.WarmUpFrame.Visible = true
		elseif i == 4 then
			opponentGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29385594"
			playerGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29385594"
		elseif i == 3 then
			opponentGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29386492"
			playerGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29386492"
		elseif i == 2 then
			opponentGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29385652"
			playerGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29385652"
		elseif i == 1 then
			opponentGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29385679"
			playerGui.WarmUpFrame.InstructionLabel.NumberLabel.Image = "http://www.roblox.com/asset/?id=29385679"
		end
		numbers[i]:Play()
		scaleNumbers()
	end

	opponentGui.WarmUpFrame.Visible = false
	playerGui.WarmUpFrame.Visible = false

	Tool.Start:Play()

end

-- for sweet scaling effect win!
function scaleNumbers()

	local scaler = nil
	for i = 1, 70 do
		scaler = 2.5 * (i/70)
		playerGui.WarmUpFrame.InstructionLabel.NumberLabel.Size = UDim2.new(0,32 * scaler,0,32 * scaler)
		opponentGui.WarmUpFrame.InstructionLabel.NumberLabel.Size = UDim2.new(0,32 * scaler,0,32 * scaler)
		wait()
	end

end


function updateHotDogs()

	local playerPercentage = playerClicks/(playerClicks+opponentClicks)
	local opponentPercentage = opponentClicks/(playerClicks+opponentClicks)

	-- update player gui
	playerGui.MainFrame.PlayerEaten.EatenNumber.Text = tostring(playerClicks)
	playerGui.MainFrame.OppEaten.EatenNumber.Text = tostring(opponentClicks)
	playerGui.MainFrame.PlayerBar.bar.Size = UDim2.new(0,64,0,-256 * playerPercentage)
	playerGui.MainFrame.OppBar.bar.Size = UDim2.new(0,64,0,-256 * opponentPercentage)

	--update opponent gui
	opponentGui.MainFrame.PlayerEaten.EatenNumber.Text = tostring(opponentClicks)
	opponentGui.MainFrame.OppEaten.EatenNumber.Text = tostring(playerClicks)
	opponentGui.MainFrame.PlayerBar.bar.Size = UDim2.new(0,64,0,-256 * opponentPercentage)
	opponentGui.MainFrame.OppBar.bar.Size = UDim2.new(0,64,0,-256 * playerPercentage)

end


function updateGameTime()

	wait(0.0333)
	gameTime = gameTime - 1
	local size =  (gameTime/gameCycles) * 150

	playerGui.MainFrame.TimeTitle.EatenNumber.Size = UDim2.new(0,size,0,20)
	playerGui.MainFrame.TimeTitle.EatenNumber.Position = UDim2.new(0,-20 + (150 - (size))/2,0,60)
	opponentGui.MainFrame.TimeTitle.EatenNumber.Size = playerGui.MainFrame.TimeTitle.EatenNumber.Size
	opponentGui.MainFrame.TimeTitle.EatenNumber.Position = playerGui.MainFrame.TimeTitle.EatenNumber.Position

end


function opponentDeclined()

	opponentGui.Parent = nil
	opponentGui:remove()
	opponentGui = nil
	playerGui.PopupFrame.Visible = true
	playerGui.PopupFrame.TXT.Text = opp.Name .. " decided you are too awesome and declined your challenge."
	playerGui.PopupFrame.Accept.MouseButton1Down:connect(function() 
		playerGui.PopupFrame.Visible = false
		playerGui.StarterFrame.TXT.Text = "Click on a Robloxian to challenge them to a hot dog eating contest!"
	end)

end
