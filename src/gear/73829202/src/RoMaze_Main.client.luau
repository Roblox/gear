function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local function class(name)
	local def = {}
	getfenv(0)[name] = def
	return function(ctor, static)
		local nctor = function(...)
			local this = {}
			if ctor then
				ctor(this, ...)
			end
			return this
		end
		getfenv(0)['Create'..name] = nctor
		if static then static(def) end
	end
end

class'Signal'(function(this)
	local mListeners = {}
	local mWaitObject = Create'BoolValue'{}

	function this:connect(func)
		local connection = {}
		function connection:disconnect()
			mListeners[func] = nil
		end
		mListeners[func] = connection
		return connection
	end

	function this:fire(...)
		--print("Fire evt<"..tostring(this).."> from script<"..mDebugId..">")
		for func, conn in pairs(mListeners) do
			--print("-> "..tostring(func).."( ... )")
			func(...)
		end
		mWaitObject.Value = not mWaitObject.Value
	end

	function this:wait()
		mWaitObject.Changed:wait()
	end
end)

local function frand(a,b)
	return a+math.random()*(b-a)
end

local function frand2(a,b)
	return frand(a,b)*frand(a,b)
end

---------------------------------------------------------------------------------

local Tool = script.Parent
local Mouse;

kBlueColor = Color3.new(0, 0.7, 1)
kWhiteColor = Color3.new(1, 1, 1)
kBlackColor = Color3.new(0, 0, 0)


local function Color3Lerp(c1, c2, frac)
	local frac_ = 1-frac
	return Color3.new(c1.r*frac_ + c2.r*frac,
	                  c1.g*frac_ + c2.g*frac,
	                  c1.b*frac_ + c2.b*frac)
end


function ShowTitleScreen(container)
	local kTitleText = 'ROMAZE'
	local kHighlightStart, kHighlightEnd = 1,2
	local kTextSize = 'Size36'
	local kTextFont = 'Arial'
	local kHighlightFont = 'ArialBold'
	local kTextSpacing = 32
	--
	local kBaseTextColor = kWhiteColor
	local kHighlightTextColor = kBlueColor
	--
	local mGui = Create'Frame'{
		Name = 'ContentFrame',
		Parent = container,
		BackgroundColor3 = kBlackColor,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
	}
	--
	local mLetterGuis = {}
	local mLetterOrigin;
	do
		local availW = container.AbsoluteSize.x
		mLetterOrigin = (availW - kTextSpacing*(#kTitleText))/2
	end
	for i = 1, #kTitleText do
		local letter = kTitleText:sub(i,i)
		local gui = Create'TextLabel'{
			Name = 'LetterGui',
			Parent = mGui,
			Font = kTextFont,
			FontSize = kTextSize,
			TextColor3 = kBaseTextColor,
			BackgroundTransparency = 1,
			Text = letter,
			--
			Size = UDim2.new(0, kTextSpacing, 0, kTextSpacing),
			Position = UDim2.new(0, mLetterOrigin+kTextSpacing*(i-1), 0.5, -kTextSpacing/2),
			--
			Create'Frame'{
				Name = 'Covering',
				BorderSizePixel = 0,
				BackgroundColor3 = kBlackColor,
				Size = UDim2.new(1, 0, 1, 0),
				--
				Create'Frame'{
					Name = 'CoveringBar',
					BorderSizePixel = 0,
					BackgroundColor3 = kBaseTextColor,
					Size = UDim2.new(0, 2, 1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Visible = false,
				},
			},
		}
		mLetterGuis[i] = gui
	end

	Spawn(function()
		--reveal letters
		local nCompleted = 0
		for i = 1, #mLetterGuis do
			local gui = mLetterGuis[i]
			Spawn(function()
				gui.Covering.CoveringBar.Visible = true
				gui.Covering:TweenSize(UDim2.new(0, 0, 1, 0), 'Out', 'Quart', 1)
				for i = 0, 1, 1/30 do
					gui.Covering.CoveringBar.BackgroundTransparency = i
					wait()
				end
				gui.Covering.CoveringBar.Visible = false
				nCompleted = nCompleted+1
			end)
			wait(0.3)
		end
		while nCompleted < #mLetterGuis do wait() end

		--Flash to bold the highlight letters
		nCompleted = 0
		Spawn(function()
			for i = kHighlightStart, kHighlightEnd do
				mLetterGuis[i].Font = kHighlightFont
			end
			for lerp = 0, 1, 0.02 do
				for i = kHighlightStart, kHighlightEnd do
					mLetterGuis[i].TextColor3 = Color3Lerp(kBaseTextColor,
					                                       kHighlightTextColor,
					                                       math.sqrt(lerp))
				end
				wait()
			end
			nCompleted = nCompleted+1
		end)
		Spawn(function()
			local lineLen = (kHighlightEnd-kHighlightStart+1)*kTextSpacing
			local f1 = Create'Frame'{
				Name = 'Overline',
				Parent = mGui,
				BackgroundColor3 = kHighlightTextColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, mLetterOrigin, 0.5, -kTextSpacing/2)
			}
			local f2 = Create'Frame'{
				Name = 'Underline',
				Parent = mGui,
				BackgroundColor3 = kHighlightTextColor,
				BorderSizePixel = 0,
			}
			for i = 0, 1, 0.02 do
				f1.BackgroundTransparency = (1-i)
				f2.BackgroundTransparency = (1-i)
				--
				f1.Size = UDim2.new(0, i*lineLen, 0, 2)
				f2.Size = UDim2.new(0, i*lineLen, 0, 2)
				f2.Position = UDim2.new(0, mLetterOrigin+(1-i)*lineLen, 0.5, kTextSpacing/2)
				wait()
			end
			nCompleted = nCompleted+1
		end)
		while nCompleted < 2 do wait() end

		wait(1)
		mGui.Parent = nil
		return ShowMainMenu(container)
	end)
end

function CreateFrightenedButton(name, x, y, text, hBegin, hEnd)
	hBegin = hBegin or 0
	hEnd = hEnd or 0
	--
	--use a temporary screengui to get text-bounds to update right away
	local tmpScreenGui = Create'ScreenGui'{
		Parent = game.Players:GetPlayerFromCharacter(Tool.Parent).PlayerGui,
	}
	local mGui = Create'ImageButton'{
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.new(),
		Position = UDim2.new(0, x, 0, y),
		Parent = tmpScreenGui,
		--
		Create'Frame'{
			Name = 'TextMover',
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		},
	}

	local HTextLabel;
	local mCurOffset = 0
	if hBegin == hEnd and hBegin == 0 then
		local text1 = Create'TextLabel'{
			Name = 'Letters',
			Parent = mGui.TextMover,
			BackgroundTransparency = 1,
			Font = 'Arial',
			FontSize = 'Size18',
			TextColor3 = kWhiteColor,
			Text = text,
		}
		mCurOffset = text1.TextBounds.x
	else
		if hBegin > 1 then
			local text1 = Create'TextLabel'{
				Name = 'Letters',
				Parent = mGui.TextMover,
				BackgroundTransparency = 1,
				Font = 'Arial',
				FontSize = 'Size18',
				TextColor3 = kWhiteColor,
				Text = text:sub(1,hBegin-1),
			}
			text1.Size = UDim2.new(0, text1.TextBounds.x, 1, 0)
			text1.Position = UDim2.new(0, 0, 0, 0)
			mCurOffset = mCurOffset+text1.TextBounds.x
		end
		--
		local text2 = Create'TextLabel'{
			Name = 'Letters',
			Parent = mGui.TextMover,
			BackgroundTransparency = 1,
			Font = 'ArialBold',
			FontSize = 'Size18',
			TextColor3 = kBlueColor,
			Text = text:sub(hBegin,hEnd),
		}
		text2.Size = UDim2.new(0, text2.TextBounds.x, 1, 0)
		text2.Position = UDim2.new(0, mCurOffset, 0, 0)
		mCurOffset = mCurOffset+text2.TextBounds.x 
		HTextLabel = text2
		--
		if hEnd < #text then
			local text3 = Create'TextLabel'{
				Name = 'Letters',
				Parent = mGui.TextMover,
				BackgroundTransparency = 1,
				Font = 'Arial',
				FontSize = 'Size18',
				TextColor3 = kWhiteColor,
				Text = text:sub(hEnd+1, #text),
			}
			text3.Size = UDim2.new(0, text3.TextBounds.x, 1, 0)
			text3.Position = UDim2.new(0, mCurOffset, 0, 0)
			mCurOffset = mCurOffset+text3.TextBounds.x
		end
	end

	--use the calculated width to patch the button size
	mGui.Size = UDim2.new(0, mCurOffset, 0, 20)

	--shake on hover
	local mMouseHoverN = 0
	local mMouseHovering = false
	mGui.MouseEnter:connect(function()
		mMouseHovering = true
		local thisMouseHover = mMouseHoverN
		while mMouseHoverN == thisMouseHover do
			mGui.TextMover.Position = UDim2.new(0, frand(-2,2), 0, frand(-2,2))
			wait()
		end
		mGui.TextMover.Position = UDim2.new()
	end)
	mGui.MouseLeave:connect(function()
		mMouseHovering = false
		mMouseHoverN = mMouseHoverN+1
	end)

	--throb highlighted text label
	if HTextLabel then
		local tOffset = frand(1,20)
		Spawn(function()
			while mGui.Parent do
				if mMouseHovering then
					HTextLabel.TextColor3 = kBlueColor
				else
					local x = 2*(tick()+tOffset)
					--now everbody lets make some noise!
					local frac = math.abs(math.cos(x/10)^5 * (math.sin(x)^4*math.cos(x+1)^2+
					                                          0.5*math.cos(x+2)-math.sin(3*x+2)))
					frac = (frac > 1) and 1 or frac
					HTextLabel.TextColor3 = Color3Lerp(kWhiteColor, kBlueColor, frac)
				end
				wait()
			end
		end)
	end

	return mGui
end

function ShowMainMenu(container)
	--make base gui
	local mGui = Create'Frame'{
		Name = 'MenuFrame',
		Parent = container,
		BorderSizePixel = 0,
		BackgroundColor3 = kBlackColor,
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = true,
		--
		Create'ImageLabel'{
			Name = 'LED_Image',
			BackgroundTransparency = 1,
			Image = 'http://www.roblox.com/asset/?id=70584247',
			Position = UDim2.new(0, 170, 0, 40),
			Size = UDim2.new(0, 200, 0, 150),
		},
		--
		CreateFrightenedButton('HelpButton', 10, 280, "HELP", 1, 1),
		CreateFrightenedButton('EasyButton', 15, 305, "> NEWB", 4, 4),
		CreateFrightenedButton('MedButton',  25, 330, "> LEARNED", 3, 3),
		CreateFrightenedButton('HardButton', 40, 355, "> EXPERIEANCED", 5, 5),
		--
		Create'Frame'{
			Name = 'Overlay',
			BorderSizePixel = 0,
			BackgroundColor3 = kBlackColor,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 170, 0, 40),
			Size = UDim2.new(0, 200, 0, 150),
		},
		--
		Create'ImageButton'{
			Name = 'HelpPanel',
			Style = 'RobloxButton',
			AutoButtonColor = false,
			Size = UDim2.new(0, 300, 0, 150),
			Position = UDim2.new(0.5, -150, 0, -152),
			--
			Create'TextLabel'{
				Name = 'Label1',
				BackgroundTransparency = 1,
				Font = 'ArialBold',
				FontSize = 'Size18',
				TextColor3 = Color3.new(0, 102/255, 204/255),
				Position = UDim2.new(0, 50, 0, 35),	
				Text = "B L U E",
			},
			Create'TextLabel'{
				Name = 'Label2',
				BackgroundTransparency = 1,
				Font = 'Arial',
				FontSize = 'Size14',
				TextColor3 = kWhiteColor,
				Position = UDim2.new(0, 170, 0, 35),	
				Text = "is    your   friend,   seek   him",
			},
			Create'TextLabel'{
				Name = 'Label3',
				BackgroundTransparency = 1,
				Font = 'ArialBold',
				FontSize = 'Size18',
				TextColor3 = Color3.new(165/255, 0, 33/255),
				Position = UDim2.new(0, 50, 0, 90),	
				Text = "R  E  D",
			},
			Create'TextLabel'{
				Name = 'Label4',
				BackgroundTransparency = 1,
				Font = 'Arial',
				FontSize = 'Size14',
				TextColor3 = kWhiteColor,
				Position = UDim2.new(0, 170, 0, 90),	
				Text = "is    your   enemy,   flee   him",
			},
		},
	}

	--make flickering overlay
	local mOverlay = mGui.Overlay
	Spawn(function()
		local tOffset = frand(1,50)
		while mGui.Parent do
			local x = (tick()+tOffset)*2.5
			local y = x*10
			--now everbody lets make some noise!
			local frac = math.abs(math.cos(x/10)^20 * (math.sin(y)^4*math.cos(y+1)^2+
			                                           0.5*math.cos(y+2)-math.sin(3*y+2)))
			frac = 1-frac
			mOverlay.BackgroundTransparency = frac
			wait()
		end
	end)

	--do button-ey stuff
	local HelpIsShown = false
	mGui.HelpButton.MouseButton1Down:connect(function()
		if HelpIsShown then
			HelpIsShown = false
			mGui.HelpPanel:TweenPosition(UDim2.new(0.5, -150, 0, -152), 'Out', 'Quart', 0.5)
		else
			HelpIsShown = true
			mGui.HelpPanel:TweenPosition(UDim2.new(0.5, -150, 0, 10), 'Out', 'Quart', 0.5)
		end
	end)
	mGui.HelpPanel.MouseButton1Down:connect(function()
		mGui.HelpPanel:TweenPosition(UDim2.new(0.5, -150, 0, -152), 'Out', 'Quart', 0.5)
		HelpIsShown = false
	end)
	mGui.EasyButton.MouseButton1Down:connect(function()
		mGui.Parent = nil
		DoLevelset(container, EasyGame)
	end)
	mGui.MedButton.MouseButton1Down:connect(function()
		mGui.Parent = nil
		DoLevelset(container, MediumGame)
	end)
	mGui.HardButton.MouseButton1Down:connect(function()
		mGui.Parent = nil
		DoLevelset(container, HardGame)
	end)
end

function PlayGame(container, levelData, onAction)
	local kSquareSize = 16
	--
	local mBoard = {}
	local mTotalWidth, mTotalHeight = 0, 0;

	--calculate the total space neede for all the panels
	for _, pane in pairs(levelData) do
		if pane.X+pane.W-1 > mTotalWidth then
			mTotalWidth = pane.X+pane.W-1
		end
		if pane.Y+pane.H-1 > mTotalHeight then
			mTotalHeight = pane.Y+pane.H-1
		end
	end

	--make the main gui container
	local mGui = Create'Frame'{
		Name = 'GameContainer',
		Parent = container,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = kBlackColor,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		--
		Create'Frame'{
			Name = 'PanelContainer',
			BackgroundTransparency = 1,
			Size = UDim2.new(0, kSquareSize*mTotalWidth, 
			                 0, kSquareSize*mTotalHeight),
			Position = UDim2.new(0.5, -0.5*kSquareSize*mTotalWidth, 
			                     0.5, -0.5*kSquareSize*mTotalHeight),
		},
	}

	--key connection
	local mKeyCn;

	--generate the board
	local mPaneToGuiMap = {}
	--
	local mNoMoveFlag = false
	local mPlayerList = {}

	local MovePlayer;
	local function KillPlayer(player)
		--kill the player
		player.Gui.BackgroundTransparency = 1

		--do a death animation with some particles and then move
		--the players back where they started
		local particleList = {}
		for i = 1, 20 do
			local particle = {}
			particle.Gui = Create'Frame'{
				Name = 'DestroyParticlePlayer',
				Parent = player.Gui,
				BorderSizePixel = 0,
				BackgroundColor3 = kWhiteColor,
				Size = UDim2.new(0, 2, 0, 2),
			}
			local theta = frand(0, math.pi*2)
			local dist = math.random(50, 100)
			particle.VX = math.sin(theta)*dist
			particle.VY = -math.cos(theta)*dist
			particle.Gui:TweenPosition(UDim2.new(0.5, particle.VX, 0.5, particle.VY), 'In', 'Linear', 1)
			--
			particleList[#particleList+1] =  particle
		end

		--disalow movement
		mNoMoveFlag = true

		--animate
		for i = 0, 1, 1/30 do
			for _, particle in pairs(particleList) do
				particle.Gui.BackgroundTransparency = i
			end
			wait()
		end

		--kill the particles
		for _, particle in pairs(particleList) do
			particle.Gui:Destroy()
		end

		--reshow the player
		player.Gui.BackgroundTransparency = 0

		--put each player back to their starting pos
		for _, p in pairs(mPlayerList) do
			p.OX, p.OY = p.StartOX, p.StartOY
			p.Gui.Parent = mPaneToGuiMap[p.StartPane]
			MovePlayer(p, p.StartX, p.StartY)
		end

		--turn back on movement
		mNoMoveFlag = false
	end

	MovePlayer = function(player, x, y)
		local tile = (mBoard[x] or {})[y]
		if tile and tile.Walkable then
			player.X, player.Y = x, y
			player.Gui.Position = UDim2.new(0, (player.X-player.OX+0.2)*kSquareSize-1,
			                                0, (player.Y-player.OY+0.2)*kSquareSize)
			if tile.Type == 'Kill' then
				KillPlayer(player)
				return --we don't and to continue to the other move handling code now
			elseif tile.Type == 'Tele' then
				--use spawn to give the other blocks a chance to move
				Spawn(function()
					--check for a player obstructing the destination
					local isObstructed = false
					for _, p in pairs(mPlayerList) do
						if p.X == tile.TeleportToX and p.Y == tile.TeleportToY then
							isObstructed = true
						end
					end
					if not isObstructed then
						--fade player out
						mNoMoveFlag = true
						for i = 0, 1, 0.1 do
							wait()
							player.Gui.BackgroundTransparency = i
						end
						local toTile = mBoard[tile.TeleportToX][tile.TeleportToY]
						player.Gui.Parent = mPaneToGuiMap[toTile.Pane]
						player.OX, player.OY = toTile.Pane.X, toTile.Pane.Y
						MovePlayer(player, tile.TeleportToX, tile.TeleportToY)
						for i = 1, 0, -0.1 do
							wait()
							player.Gui.BackgroundTransparency = i
						end
						player.Gui.BackgroundTransparency = 0
						mNoMoveFlag = false
						return
					end 
				end)
			end
		end
	end

	for paneIndex, pane in pairs(levelData) do
		--make a player for the pane
		local player = {}
		player.OX = pane.X
		player.StartOX = pane.X
		player.OY = pane.Y
		player.StartOY = pane.Y
		player.StartPane = pane

		--make a GUI for each pane
		local paneGui = Create'Frame'{
			Name = 'GamePane',
			Parent = mGui.PanelContainer,
			Position = UDim2.new(0, (pane.X-1)*kSquareSize-400*pane.SlideInDirX, 
			                     0, (pane.Y-1)*kSquareSize-400*pane.SlideInDirY),
			Size = UDim2.new(0, pane.W*kSquareSize, 0, pane.H*kSquareSize),
			BackgroundColor3 = kBlackColor,
			BorderColor3 = kBlueColor,
			BorderSizePixel = 0,
		}
		mPaneToGuiMap[pane] = paneGui
		--
		for y = pane.Y, pane.Y+pane.H-1 do
			local rowData = pane.Data[y-pane.Y+1]
			for x = pane.X, pane.X+pane.W-1 do
				local sym = rowData:sub(x-pane.X+1,x-pane.X+1)
				if not mBoard[x] then mBoard[x] = {} end

				--
				local square = {}
				square.Pane = pane

				--handle special symbols
				if sym == 'O' then
					player.StartX, player.StartY = x, y
					player.X, player.Y = x, y
					sym = ' '
				elseif sym == 'E' then
					player.EndX, player.EndY = x, y
				elseif pane.Teleports[sym] then
					local tele = pane.Teleports[sym]
					tele.Pane = tele.Pane or paneIndex
					local destPane = levelData[tele.Pane]
					square.TeleportToX = destPane.X+tele.X-1
					square.TeleportToY = destPane.Y+tele.Y-1
					sym = 'Tele'
				end

				--
				if sym == '#' then
					square.Type = 'Wall'
					square.Walkable = false
					square.Gui = Create'Frame'{
						Name = 'WallTile',
						Parent = paneGui,
						Size = UDim2.new(0, kSquareSize-1, 0, kSquareSize-1),
						Position = UDim2.new(0, (x-pane.X)*kSquareSize, 
						                     0, 1+(y-pane.Y)*kSquareSize),
						BackgroundColor3 = kWhiteColor,
						BorderSizePixel = 0,
					}
				elseif sym == 'E' then
					square.Type = 'End'
					square.Walkable = true
					square.Gui = Create'Frame'{
						Name = 'EndTile',
						Parent = paneGui,
						Size = UDim2.new(0, kSquareSize-4, 0, kSquareSize-4),
						Position = UDim2.new(0, 2+(x-pane.X)*kSquareSize, 
						                     0, 2+(y-pane.Y)*kSquareSize),
						BackgroundColor3 = kBlackColor,
						BorderColor3 = kBlueColor,
						BorderSizePixel = 1,		
					}
				elseif sym == '*' then
					square.Type = 'Kill'
					square.Walkable = true
					square.Gui = Create'Frame'{
						Name = 'KillTile',
						Parent = paneGui,
						Size = UDim2.new(0, kSquareSize-3, 0, kSquareSize-3),
						Position = UDim2.new(0, 2+(x-pane.X)*kSquareSize, 
						                     0, 2+(y-pane.Y)*kSquareSize),
						BackgroundColor3 = Color3.new(0.5, 0, 0),
						BorderSizePixel = 0,	
						--
						Create'Frame'{
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(1, 0, 0),
							Size = UDim2.new(1, -4, 1, -4),
							Position = UDim2.new(0, 2, 0, 2),
						},
					}
				elseif sym == 'Tele' then
					square.Type = 'Tele'
					square.Walkable = true
					square.Gui = Create'Frame'{
						Name = 'TeleTile',
						Parent = paneGui,
						Size = UDim2.new(0, kSquareSize-3, 0, kSquareSize-3),
						Position = UDim2.new(0, 2+(x-pane.X)*kSquareSize, 
						                     0, 2+(y-pane.Y)*kSquareSize),
						BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
						BorderSizePixel = 0,	
						--
						Create'Frame'{
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(0.4, 0.4, 0.4),
							Size = UDim2.new(1, -4, 1, -4),
							Position = UDim2.new(0, 2, 0, 2),
						},
					}
				elseif sym == ' ' then
					square.Type = 'Empty'
					square.Walkable = true
				end
				--
				mBoard[x][y] = square
			end
		end

		-- if there was a starting point in this pane, use the player from it.
		if player.X then
			mPlayerList[#mPlayerList+1] = player

			--make the player's gui
			player.Gui = Create'Frame'{
				Name = 'PlayerSquare',
				Parent = paneGui,
				BorderSizePixel = 0,
				Size = UDim2.new(0, math.ceil(kSquareSize*0.6)+1, 0, math.ceil(kSquareSize*0.6)+1),
				BackgroundColor3 = kWhiteColor,
			}

			--do an initial move of the player to get them in the right position
			MovePlayer(player, player.X, player.Y)
		end
	end

	for _, pane in pairs(levelData) do
		--slide in the panes
		mPaneToGuiMap[pane]:TweenPosition(UDim2.new(0, (pane.X-1)*kSquareSize, 
		                                  0, (pane.Y-1)*kSquareSize),
		                                  'In', 'Quad', 1)
	end
	wait(1)
	mKeyCn = Mouse.KeyDown:connect(function(key)
		if mNoMoveFlag then return end
		key = key:lower()
		local dx, dy = 0, 0;
		--
		if key == 'q' then
			--reset
			KillPlayer(mPlayerList[1])
			return
		elseif key == 'w' then
			dy = -1
		elseif key == 's' then
			dy = 1
		elseif key == 'a' then
			dx = -1
		elseif key == 'd' then
			dx = 1
		end
		--
		for _, player in pairs(mPlayerList) do
			MovePlayer(player, player.X+dx, player.Y+dy)
		end
		--check for a win
		local hasWon = true
		for _, player in pairs(mPlayerList) do
			if mBoard[player.X][player.Y].Type ~= 'End' then
				hasWon = false
				break
			end
		end
		if hasWon then
			mNoMoveFlag = true
			Spawn(function()
				--fade out players
				for i = 0, 1, 0.05 do
					for _, p in pairs(mPlayerList) do
						p.Gui.BackgroundTransparency = i
					end
					wait()
				end

				--slide out panes
				for _, pane in pairs(levelData) do
					mPaneToGuiMap[pane]:TweenPosition(UDim2.new(0, (pane.X-1)*kSquareSize-400*pane.SlideInDirX, 
					                                            0, (pane.Y-1)*kSquareSize-400*pane.SlideInDirY),
					                                  'Out', 'Quad', 1)
				end
				wait(1)

				--done, delete gui and announce viectory to listener
				mGui.Parent = nil
				mKeyCn:disconnect()
				return onAction('win')
			end)
		end
	end)

	--do throb effect for feild
	Spawn(function()
		local mWaveSourceX = mTotalWidth/2
		local mWaveSourceY = mTotalHeight/2
		local freq = 0.5
		local lambda = 10
		local omega = 2*math.pi*freq
		local k = 2*math.pi/lambda
		--
		while mGui.Parent do
			local startT = tick()
			for i = 0, 1, 0.02 do
				local t = tick()-startT
				for x = 1, mTotalWidth do
					for y = 1, mTotalHeight do
						local tl = mBoard[x][y]
						if tl and tl.Type == 'Wall' then
							local dx = mWaveSourceX-x
							local dy = mWaveSourceY-y
							local x = math.sqrt(dx*dx + dy*dy)
							tl.Gui.BackgroundTransparency = 0.15*(i*math.sin(k*x - omega*t)^2)
						end
					end
				end
				wait()
			end
			for i = 1, 0, -0.02 do
				local t = tick()-startT
				for x = 1, mTotalWidth do
					for y = 1, mTotalHeight do
						local tl = mBoard[x][y]
						if tl and tl.Type == 'Wall' then
							local dx = mWaveSourceX-x
							local dy = mWaveSourceY-y
							local x = math.sqrt(dx*dx + dy*dy)
							tl.Gui.BackgroundTransparency = 0.15*(i*math.sin(k*x - omega*t)^2)
						end
					end
				end
				wait()
			end
			wait(frand(1,3))
		end
	end)
end

function DoLevelset(container, levelSet, i)
	i = i or 1
	if i <= #levelSet then
		PlayGame(container, levelSet[i], function(action)
			if action == 'win' then
				DoLevelset(container, levelSet, i+1)
			elseif action == 'quit' then
				--todo:
			end
		end)
	end
end

local gui;
local Humanoid;
Tool.Equipped:connect(function(mouse)
	Mouse = mouse
	Humanoid = Tool.Parent.Humanoid
	local player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	Humanoid.WalkSpeed = 0
	gui = Create'ScreenGui'{
		Name = 'RoMaze_Gui',
		Parent = player.PlayerGui,
		Create'Frame'{
			Name = 'Container',
			Style = 'RobloxRound',
			Size = UDim2.new(0, 400, 0, 400),
			Position = UDim2.new(0.5, -200, 0.5, -200),
		},
	}
	ShowTitleScreen(gui.Container)
end)

Tool.Unequipped:connect(function()
	Humanoid.WalkSpeed = 16
	if gui then
		gui:Destroy()
		gui = nil
	end
end)

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--
-- #  Corrosponds to generic walls.
--
-- O  the "O"rigin of the pane, where a player starts.
--
-- E  the "E"nd of the pane, where the player tries to 
--    get to.
--
--    (Space) empty space, nothing here.
--
-- *  A killing block, kills the player if they move 
--    onto it.
-- 
-- Teleporters:
--   Any other symbol can be used as a teleport square.
--   If you use another symbol and add it to the "Teleports"
--   map of the given pane, it will be treated as a teleporter
--   and will move players to the space specified by the 
--

Game_Level1 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### O####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### E####",
			"##########",
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Game_Level2 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### O####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### E####",
			"##########",
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},		
	},
	{
		X = 11, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"#   ######",
			"# E     O#",
			"#   ######",
			"##########",
			"##########",
			"##########",
			"##########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Game_Level3 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### O####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### E####",
			"##########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},		
	},
	{
		X = 11, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"#   ######",
			"# E     O#",
			"#   ######",
			"##########",
			"##########",
			"##########",
			"##########",
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 1, Y = 11,
		W = 20, H = 10,
		Data = {
			"####################",
			"####################",
			"####################",
			"# # E #   #   #   ##",
			"# # # # # # # # # ##",
			"#   #   #   #   #O##",
			"####################",
			"####################",
			"####################",
			"####################",
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {},
	},
}

Game_Level4 = {
	{
		X = 1, Y = 1,
		W = 20, H = 10,
		Data = {
			"####################",
			"####################",
			"####################",
			"# # E #   #   #   ##",
			"# # # # # # # # # ##",
			"#   #   #   #   #O##",
			"####################",
			"####################",
			"####################",
			"####################",
		},
		SlideInDirX = 0,
		SlideInDirY = 1,
		Teleports = {},
	},
	{
		X = 1, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##O   E ##",
			"## #######",
			"## #######",
			"## #######",
			"##E#######",
			"## #######",
			"##########",
			"##########",	
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 11, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"####### ##",
			"#######E##",
			"####### ##",
			"####### ##",
			"####### ##",
			"## E   O##",
			"##########",
			"##########",	
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Game_Level5 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##O   E ##",
			"## #######",
			"## #######",
			"## #######",
			"##E#######",
			"## #######",
			"##########",
			"##########",	
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},		
	},
	{
		X = 11, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### #####",
			"####O#####",
			"#### #####",
			"# E     ##",
			"#### #####",
			"#### #####",
			"#### #####",
			"##########",
			"##########",	
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},	
	},
	{
		X = 1, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"#   ######",
			"# E     O#",
			"#   ######",
			"##########",
			"##########",
			"##########",
			"##########",
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {},
	},
	{
		X = 11, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"####### ##",
			"#######E##",
			"####### ##",
			"####### ##",
			"####### ##",
			"## E   O##",
			"##########",
			"##########",	
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Game_Level6 = {
	{
		X = 1, Y = 1,
		W = 20, H = 20,
		Data = {
			"####################",
			"#O  * *B  *   **** #",
			"#** * *** * *    * #",
			"#   *   * * ***    #",
			"# ***** *   * * ***#",
			"# *   * *** * ***  #",
			"#   * *   ***   ** #",
			"#**** * * *A*** ** #",
			"#       * *   *    #",
			"# ***** * * ***** *#",
			"# *   * * * *   * *#",
			"#   * * *** *** *  #",
			"#**** *       *  * #",
			"#C*   ***** * ** * #",
			"# * *** * *****  * #",
			"# *     *   *    * #",
			"# ******* * **** * #",
			"# *   *   * *    * #",
			"#   *   ***   ****E#",
			"####################",
		},
		Teleports = {
			['A'] = {X=19,Y=2},
			['B'] = {X=14,Y=11},
			['C'] = {X=14,Y=5},
		},
		SlideInDirX = 0,
		SlideInDirY = 0,
	},
}

Game_Level7 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##T     O#",
			"##########",
			"#        #",
			"#      E #",
			"#        #",
			"##########",
			"##########",
			"##########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {
			['T'] = {X=7,Y=6},
		},
	},
	{
		X = 11, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"#   ######",
			"# E     O#",
			"#   ######",
			"##########",
			"##########",
			"##########",
			"##########",			
		},
		SlideInDirX = 0,
		SlideInDirY = 1,
		Teleports = {},
	},
	{
		X = 1, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"###    ###",
			"###  O ###",
			"### E  ###",
			"###    ###",
			"##########",
			"##########",
			"##########",			
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {},
	},
	{
		X = 11, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### O####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### E####",
			"##########",			
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Game_Level8 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#       O#",
			"#        #",
			"#   #    #",
			"#   E    #",
			"#        #",
			"#        #",
			"#        #",
			"#        #",
			"##########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 11, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### O####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### E####",
			"##########",			
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 1, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"###    ###",
			"###  O ###",
			"### E  ###",
			"###    ###",
			"##########",
			"##########",
			"##########",			
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {},			
	},
}

Game_Level9 = {
	{
		X = 1, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#       O#",
			"#        #",
			"#   #    #",
			"#   E    #",
			"#        #",
			"#        #",
			"#        #",
			"#        #",
			"##########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 11, Y = 1,
		W = 10, H = 10,
		Data = {
			"##########",
			"#### O####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### #####",
			"#### E####",
			"##########",			
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 1, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"##########",
			"##########",
			"###    ###",
			"###  O ###",
			"### E  ###",
			"###    ###",
			"##########",
			"##########",
			"##########",			
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {},			
	},
	{
		X = 11, Y = 11,
		W = 10, H = 10,
		Data = {
			"##########",
			"#       O#",
			"#        #",
			"#        #",
			"#        #",
			"#        #",
			"#    E  ##",
			"#        #",
			"#        #",
			"##########",
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {},
	},
}

Game_Level10 = {
	{
		X = 1, Y = 1,
		W = 20, H = 20,
		Data = {
			"##########    *     ",
			"#O*     *#       #  ",
			"# * *** *#    #     ",
			"# *   * *#          ",
			"# **  *  #          ",
			"#   * *  #      *   ",
			"#*  * ** #          ",
			"# * * ** #  #    #  ",
			"# *    *E#      *   ",
			"##########          ",
			"            ##  *   ",
			"                    ",
			"   #    #  #        ",
			"   ##  *  * #       ",
			"   # * * *  *   *   ",
			" *    #  #  *  *    ",
			"          #*  *     ",
			"  #          *   *  ",
			" #     *    #       ",
			"      #             ",
		},
		SlideInDirX = 0,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Easy_1 = {
	{
		X = 1, Y = 1,
		W = 10, H = 9,
		Data = {
			"##########",
			"######   #",
			"###### O #",
			"#        #",
			"#        #",
			"#        #",
			"# E ######",
			"#   ######",
			"##########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Easy_2 = {
	{
		X = 1, Y = 1,
		W = 16, H = 7,
		Data = {
			"################",
			"############# O#",
			"###########    #",
			"#########    ###",
			"##         #####",
			"##E      #######",
			"################",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 1, Y = 8,
		W = 16, H = 5,
		Data = {
			"################",
			"############   #",
			"#E           O #",
			"############   #",
			"################",	
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
}

Easy_3 = {
	{
		X = 1, Y = 1,
		W = 7, H = 7,
		Data = {
			"#######",
			"#O*   #",
			"# *   #",
			"#   * #",
			"#**** #",
			"#E    #",
			"#######",
		},
		SlideInDirX = 0,
		SlideInDirY = 1,
		Teleports = {},
	},
}

Easy_4 = {
	{ ----- pane #1 -----
		X = 1, Y = 1,
		W = 7, H = 7,
		Data = {
			"#######",
			"#O   A#",
			"#     #",
			"#*****#",
			"#     #",
			"#    E#",
			"#######",
		},
		SlideInDirX = 0,
		SlideInDirY = -1,
		Teleports = {
			['A'] = {Pane=1, X=2, Y=6},
		},
	}
}

Easy_5 = {
	{ --pane #1
		X = 1, Y = 1,
		W = 8, H = 5,
		Data = {
			"########",
			"#   ####",
			"# T   O#",
			"#   ####",
			"########",
		},
		SlideInDirX = 1,
		SlideInDirY = 0,
		Teleports = {
			['T'] = {Pane=2, X=6, Y=3},
		}
	},
	{ -- pane #2
		X = 9, Y = 1,
		W = 8, H = 5,
		Data = {
			"########",
			"#***   #",
			"#*E    #",
			"#***   #",
			"########",
		},
		SlideInDirX = -1,
		SlideInDirY = 0,
		Teleports = {},
	},
	{
		X = 1, Y = 6,
		W = 16, H = 5,
		Data = {
			"################",
			"#   #   #   # O#",
			"# # # # # # # ##",
			"#E#   #   #   ##",
			"################",			
		},
		SlideInDirX = 0,
		SlideInDirY = -1,	
		Teleports = {},	
	},
}

Easy_6 = {
	{ -- pane #1
		X = 1, Y = 1;
		W = 16, H = 5;
		Data = {
			"################";
			"#   #   #   # O#";
			"# # * * * * * *#";
			"#E#   #   #   ##";
			"################";	
		},
		SlideInDirX = -1;
		SlideInDirY = 0;	
		Teleports = {};
	};
	{ -- pane #2
		X = 1, Y = 6;
		W = 8, H = 5;
		Data = {
			"########";
			"####   #";
			"#E     #";
			"####   #";
			"########";
		},
		SlideInDirX = 1;
		SlideInDirY = 0;
		Teleports = {};
	};
	{ --pane #3
		X = 9, Y = 6;
		W = 8, H = 5;
		Data = {
			"########";
			"#  J## #";
			"# *   O#";
			"#   ####";
			"########";
		};
		SlideInDirX = 0;
		SlideInDirY = -1;
		Teleports = {
			['J'] = {Pane=2, X=7, Y=3};
		}
	};
}

EasyGame = {Easy_1, Easy_2, Easy_3, Easy_4, Easy_5, Easy_6}

MediumGame = {Game_Level1, Game_Level2, Game_Level3, 
              Game_Level4, Game_Level5, Game_Level6, 
              Game_Level7, Game_Level8, Game_Level9,
              Game_Level10,}

HardGame = {}