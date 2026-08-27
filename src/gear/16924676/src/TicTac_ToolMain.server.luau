local gameState = 0 --[[
0 = no game
1 = waiting for opponent to accept or decline
2 = game running
3 = game over message pending
]]

local gameTurn = true --[[
true = your turn
false = opponents turn

acts as a spinlock for the main loop
]]

local resourceGui = script.Parent.TicTacGui
resourceGui.Parent = nil
local opponentGui = nil
local playerGui = nil --[[
the guis for your and the opponent
]]

local opponentCleanupScript = nil --[[
script to clean up the opponent's gui if I leave
]]

local gameBoard = {{},{},{}} --[[
the gameboard, values := [0 = empty, 1 = player, 2 = opponent] 
]]

local player = nil
local opponent = nil --[[
me and the opponent, (and possibly other players / viewers in other games)
]]

local opponentChangedSignal = nil --[[
signal must be connected when the tool is deselected, unlike mouse ones which expire automatically
]]

local RunService = (game:FindService("RunService") or game:GetService("RunService"))

function hasWon(num)
	---- debugging ----
	print("--- Checking for win of", num, "---")
	for x = 1, 3 do
		local str = ""
		for y = 1, 3 do	
			str = str..gameBoard[x][y].."  "
		end
		print(str)
	end
	print("--------------------------------------")
	-----------------------
	--cols
	for x = 1, 3 do
		local col = true
		for y = 1, 3 do
			if gameBoard[x][y] ~= num then 
				col = false
				break
			end
		end
		if col then return true end
	end
	--rows
	for y = 1, 3 do
		local row = true
		for x = 1, 3 do
			if gameBoard[x][y] ~= num then
				row = false
				break;
			end
		end
		if row then return true end
	end
	--diagonal x = y
	local diag = true
	for i = 1, 3 do
		if gameBoard[i][i] ~= num then
			diag = false
			break
		end
	end
	if diag then return true end
	--diagonal x = -y
	diag = true
	for i = 1, 3 do
		if gameBoard[i][4-i] ~= num then
			diag = false
			break
		end
	end
	if diag then return true end
end

function boardFull()
	for x = 1, 3 do
	for y = 1, 3 do
		if gameBoard[x][y] == 0 then
			return false
		end
	end
	end
	return true
end

function setupPlayerBoard()
	for x = 1, 3 do
	for y = 1, 3 do
		local coordStr = x..y
		playerGui.MainFrame.BoardFrame[coordStr].MouseButton1Down:Connect(function()
			if gameTurn and gameBoard[x][y] == 0 then
				gameBoard[x][y] = 1
				playerGui.MainFrame.BoardFrame[coordStr].Image = "http://www.roblox.com/asset/?id=16417305"
				opponentGui.MainFrame.BoardFrame[coordStr].Image = "http://www.roblox.com/asset/?id=16417305"
			end
			gameTurn = false
		end)
	end
	end
end

function setupOpponentBoard()
	for x = 1, 3 do
	for y = 1, 3 do
		local coordStr = x..y
		opponentGui.MainFrame.BoardFrame[coordStr].MouseButton1Down:Connect(function()
			if not gameTurn and gameBoard[x][y] == 0 then
				gameBoard[x][y] = 2
				playerGui.MainFrame.BoardFrame[coordStr].Image = "http://www.roblox.com/asset/?id=16417300"
				opponentGui.MainFrame.BoardFrame[coordStr].Image = "http://www.roblox.com/asset/?id=16417300"
			end
			gameTurn = true
		end)
	end
	end
end

function createPlayerGui()
	--remove the old gui
	if playerGui then
		playerGui:Destroy()
	end
	--set up the player's GUI
	playerGui = resourceGui:Clone()
	playerGui.Parent = player.PlayerGui
	playerGui.SideFrame.Visible = true
	setupPlayerBoard()
	--make the popupframe hide on ok pressed
	playerGui.PopupFrame.Accept.MouseButton1Down:Connect(function()
		--hack, this must be the gameover message if gameState is 3, reset game state
		if gameState == 3 then
			playerGui.MainFrame.Visible = false
			playerGui.SideFrame.TXT1.Text = "Click on a player to"
			playerGui.SideFrame.TXT2.Text = "challenge them"
			playerGui.SideFrame.Visible = true
			spawn(function()
				for i = -128, 0, 4 do
					playerGui.SideFrame.Position = UDim2.new(0, i, 0.5, -16)
					RunService.Heartbeat:Wait()
					--wait()
				end	
			end)			
			gameState = 0
		end
		--hide me
		playerGui.PopupFrame.Visible = false
	end)
end

function playGame()
	--== create a new board for the player (reusing old one causes some rendering bugs with the x and o images)
	createPlayerGui()
	--==set up the opponent's gui connections (the player's are setup on tool selection)
	setupOpponentBoard()
	--==hide the player's sideframe
	spawn(function()
		for i = 0, -128, -4 do
			playerGui.SideFrame.Position = UDim2.new(0, i, 0.5, -16)
			wait()
		end	
	end)
	--==set turn and gamestate
	local gameRunning = true
	gameTurn = true
	gameState = 2
	--reset the board, and the player's board gui
	for x = 1, 3 do
	for y = 1, 3 do
		gameBoard[x][y] = 0
		playerGui.MainFrame.BoardFrame[x..y].Image = ""
	end
	end
	--==connection for if the opponent leaves
	local opponentLeftSignal = game.Players.ChildRemoved:Connect(function(p)
		if p == opponent then
			gameState = 3
			playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "Opponent has left"
			playerGui.PopupFrame.Visible = true
		end
	end)
	--==connection to put back the gui if the opponent dies
	local opponentDiedSignal = opponent.Changed:Connect(function(property)
		if property == "Character" then
			opponentGui.Parent = opponent.PlayerGui
		end
	end)
	--==player died, panic and trash the game
	local playerDiedSignal = player.Character.Humanoid.Died:Connect(function()
		--clean up connections to opponent
		opponentLeftSignal:Disconnect()
		opponentDiedSignal:Disconnect()
		--clean up opponentcleanup
		opponentCleanupScript:Disconnect()
		--clean up guis
		opponentGui:Disconnect()
		opponentGui = nil
		--player's is going to get cleaned up right anyways, TODO : maybe show a popup message
		--playerGui:Destroy()
		--playerGui = nil
	end)
	--=="quit" button pressed connections
	local playerQuitSignal = playerGui.MainFrame.InfoFrame.BN_Quit.MouseButton1Down:Connect(function()
		playerGui.MainFrame.Visible = false
		playerGui.PopupFrame.TXT.Text = "You have quit the game"
		playerGui.PopupFrame.Visible = true
		--
		opponentGui.MainFrame.Visible = false
		opponentGui.PopupFrame.TXT.Text = player.Name.." has quit, you win!"
		opponentGui.PopupFrame.Visible = true		
		--
		gameRunning = false
		gameTurn = not gameTurn
	end)
	local opponentQuitSignal = opponentGui.MainFrame.InfoFrame.BN_Quit.MouseButton1Down:Connect(function()
		playerGui.MainFrame.Visible = false
		playerGui.PopupFrame.TXT.Text = opponent.Name.." has quit, you win!"
		playerGui.PopupFrame.Visible = true
		--
		opponentGui:Destroy()
		opponentGui = nil
		--
		gameRunning = false
		gameTurn = not gameTurn
	end)
	--
	local piframe = playerGui.MainFrame.InfoFrame
	playerGui.MainFrame.Visible = true
	piframe.Opponent.TXT.Text = opponent.Name
	piframe.Turn.TXT.Text = "Your turn"
	piframe.PlayAs.IMG.Image = "http://www.roblox.com/asset/?id=16417305"
	local oiframe = opponentGui.MainFrame.InfoFrame
	opponentGui.MainFrame.Visible = true
	oiframe.Opponent.TXT.Text = player.Name
	oiframe.Turn.TXT.Text = "Opponent's turn"
	oiframe.PlayAs.IMG.Image = "http://www.roblox.com/asset/?id=16417300"
	--==enter the main gameloop
	while gameRunning do
		--wait for the spinlock, for a player to make a move
		local tmp = gameTurn
		while gameTurn == tmp do
			wait()
		end
		if not gameRunning then
			break
		end
		--change turn displays
		if gameTurn then
			piframe.Turn.TXT.Text = "Your turn"
			oiframe.Turn.TXT.Text = "Opponent's turn"
		else
			piframe.Turn.TXT.Text = "Opponent's turn"
			oiframe.Turn.TXT.Text = "Your turn"
		end
		--check for a win
		if hasWon(1) then
			playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "You have won!"
			playerGui.PopupFrame.Visible = true
			--
			opponentGui.MainFrame.Visible = false
			opponentGui.PopupFrame.TXT.Text = "You have lost =("
			opponentGui.PopupFrame.Visible = true
			--
			break
		elseif hasWon(2) then
			playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "You have lost =("
			playerGui.PopupFrame.Visible = true
			--
			opponentGui.MainFrame.Visible = false
			opponentGui.PopupFrame.TXT.Text = "You have won!"
			opponentGui.PopupFrame.Visible = true	
			--
			break
		elseif boardFull() then
			playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "It's a tie!"
			playerGui.PopupFrame.Visible = true
			--
			opponentGui.MainFrame.Visible = false
			opponentGui.PopupFrame.TXT.Text = "It's a tie!"
			opponentGui.PopupFrame.Visible = true	
			--
			break			
		end
	end
	--==disconnect the signals made
	opponentDiedSignal:Disconnect()
	opponentLeftSignal:Disconnect()
	playerQuitSignal:Disconnect()
	opponentQuitSignal:Disconnect()
	--==set the gamestate to gameover message pending
	gameState = 3
end

script.Parent.Equipped:Connect(function()
	print("TicTacTool Equipped")
	gameState = 0
	gameTurn = true
	player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	--listen for a player clicked notification sent from the localscript
	opponentChangedSignal = script.Parent.Opponent.Changed:Connect(function()
		--was set to nil, ignore change
		if not script.Parent.Opponent.Value then 
			print("Opponent value set back to nil") 
			return 
		end
		print("Clicked an opponent")
		--if there's no game, challenge this player
		if gameState == 0 then
			print("Starting game")
			--if they're allready playing tictactoe then return
			if script.Parent.Opponent.Value.PlayerGui:FindFirstChild("TicTacGui") then 
				print("Opponent is already playing a game")
				if script.Parent.Opponent.Value.Character:FindFirstChild(script.Parent.Name) then
					playerGui.PopupFrame.TXT.Text = "Can't play a player with TicTacToe equipped"
					playerGui.PopupFrame.Visible = true
				else
					playerGui.PopupFrame.TXT.Text = "Player is already playing a game"
					playerGui.PopupFrame.Visible = true
				end
				wait(0.1)
				script.Parent.Opponent.Value = nil
				return 
			end
			--set the gamestate
			gameState = 1
			opponent = script.Parent.Opponent.Value
			wait(0.1)
			script.Parent.Opponent.Value = nil
			--set up the opponent's GUI
			opponentGui = resourceGui:Clone()
			opponentGui.SideFrame.Visible = false
			opponentGui.AcceptFrame.Visible = true
			opponentGui.AcceptFrame.TXT.Text = player.Name.." wants to play TicTacToe with you!"
			--==set up the opponent's cleanup if this player leaves
			opponentCleanupScript = script.Parent.TicTac_OpponentCleanup:Clone()
			opponentCleanupScript.Challenger.Value = player
			opponentCleanupScript.Cleanup.Value = opponentGui
			opponentCleanupScript.Disabled = false
			--should I put it straight in workspace or is that considered namespace pollution? that will work for now at least
			opponentCleanupScript.Parent = game.Workspace
			--on accept
			opponentGui.AcceptFrame.Accept.MouseButton1Down:Connect(function()
				warn("Accepted!!!")
				opponentGui.AcceptFrame.Visible = false
				playGame()
			end)
			--on decline
			opponentGui.AcceptFrame.Decline.MouseButton1Down:Connect(function()
				--reset player's sideframes' text
				playerGui.SideFrame.TXT1.Text = "Click on a player to"
				playerGui.SideFrame.TXT2.Text = "challenge them"
				--show me a popup stating player declined
				playerGui.PopupFrame.TXT.Text = "Opponent Declined =("
				playerGui.PopupFrame.Visible = true	
				--reset the game state
				gameState = 0
				--remove opponent gui
				opponentGui:Destroy()
				opponentGui = nil
				--remove opponent cleanup script
				opponentCleanupScript:Destroy()
				opponentCleanupScript = nil
			end)
			--hide popup on OK pressed
			opponentGui.PopupFrame.Accept.MouseButton1Down:Connect(function()
				--only called on game waiting for over, delete this gui and "this player left" script if it exists
				if opponentCleanupScript then
					opponentCleanupScript:Destroy()
					opponentCleanupScript = nil
				end
				opponentGui:Destroy()
				opponentGui = nil
			end)
			--gui set up, add it
			opponentGui.Parent = opponent.PlayerGui
			--set the player's GUI
			playerGui.SideFrame.TXT1.Text = "Sending Challenge"
			playerGui.SideFrame.TXT2.Text = "Please wait..."
		else
			print("Game already started")
			wait(0.1)
			script.Parent.Opponent.Value = nil
		end
	end)
	--create the player's gui
	createPlayerGui()
	--pretty effects, scroll out the side frame
	for i = -128, 0, 4 do
		playerGui.SideFrame.Position = UDim2.new(0, i, 0.5, -16)
		wait()
	end
	print("TicTacTool finished setup")
end)

function doCleanUp()
	--clean up the guis if they exist
	if opponentGui then
		opponentGui:Destroy()
		opponentGui = nil
	end
	if playerGui then
		playerGui:Destroy()
		playerGui = nil
	end	
	--remove the connection to opponentchanged
	opponentChangedSignal:Disconnect()
end

script.Parent.Unequipped:Connect(function()
	print("Tool unequipped, clean up...")
	doCleanUp()
	--TODO: send some friendly notification to a possible
	--opponent that the player exited the map or deselected
	--the tool. As the player will have exited a separate
	--script is required for this
end)






