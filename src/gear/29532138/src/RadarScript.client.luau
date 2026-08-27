local Tool = script.Parent
local gui = Tool.RadarGui
local guiEnabled = false
local guiOnPlayer = nil
local range = 300
local torso = nil
local zIndex = 4
local radarCenter = Vector2.new(140,155)
local r = (game:FindService("RunService") or game:GetService("RunService"))

enabled = true


-- when activated, either bring gui up or down, depending on current state

function onActivated()

	if not enabled  then
		return
	end

	enabled = false

	local h = Tool.Parent:FindFirstChildOfClass("Humanoid")
	if h  then
		if not guiEnabled then
			local p = game.Players:GetPlayerFromCharacter(Tool.Parent)
			if not guiOnPlayer then
				guiOnPlayer = gui:Clone()
				guiOnPlayer.Parent = p.PlayerGui
			end
			guiEnabled = true
			guiOnPlayer.Frame.Visible = true
		else
			guiOnPlayer.Frame.Visible = false
			guiEnabled = false
		end
	end

	enabled = true

end

-- remove gui when item is unequipped

function onUnequipped()

	if guiEnabled then
		guiEnabled = false
		guiOnPlayer.Frame.Visible = false
	end
	torso = nil

end

function onEquipped()

	torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")

end

Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)
Tool.Activated:Connect(onActivated)


function removeGUIPlayers()

	local guiPlayers = guiOnPlayer.Frame.Players:GetChildren()
	for i = 1, #guiPlayers do
		guiPlayers[i]:Destroy()
	end

end

function incrementZIndex()

	zIndex = zIndex + 1
	if zIndex > 10000 then
		zIndex = 2
	end

end

function createPlayerGUINode(pos, playerText)

	local playerIcon = Instance.new("ImageLabel")
	playerIcon.Image = "http://www.roblox.com/asset/?id=28625552"
	playerIcon.BackgroundTransparency = 1
	playerIcon.BorderSizePixel = 0
	playerIcon.Size = UDim2.new(0,22.5,0,40.5)
	playerIcon.Position = UDim2.new(0,pos.x,0,pos.y)
	playerIcon.Parent = guiOnPlayer.Frame.Players
	playerIcon.ZIndex = zIndex
	incrementZIndex()
	
	local playerName = Instance.new("TextLabel")
	playerName.BackgroundTransparency = 1
	playerName.BorderSizePixel = 1

	playerName.Text = tostring(playerText)
	playerName.Size = UDim2.new(0,150,0,25)
	playerName.Parent = playerIcon
	playerName.Position = UDim2.new(0,-65,0,0)
	playerName.TextColor3 =  Color3.new(1,0,0.4)
	playerName.ZIndex = zIndex
	incrementZIndex()
end


function updateGUI()

	removeGUIPlayers()
	

	local players = game.Players:GetChildren()

	for i = 1, #players do

		local playerTorso = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")

		if playerTorso then

			local posDiff = Vector3.new(torso.Position.x - playerTorso.Position.x,0,torso.Position.z - playerTorso.Position.z)

			if posDiff.Magnitude < range and playerTorso.Parent.Name ~= torso.Parent.Name then

				-- translate coordinates to radar coordinates
				posDiff = Vector2.new((posDiff.x + range) * 0.5,(posDiff.z + range) * 0.5)

				local rotationVector = Tool.Angle.Value
				local denom = math.abs(rotationVector.x) + math.abs(rotationVector.z)

				local xDirect = (rotationVector.x/denom)
				local zDirect =  (rotationVector.z/denom)
				
				local angle = math.atan2(1,0) - math.atan2(zDirect,xDirect)

				local point = Vector2.new(((posDiff.x - radarCenter.x) * math.cos(angle)) - ((posDiff.y - radarCenter.y) * math.sin(angle))  + radarCenter.x,((posDiff.x - radarCenter.x) * math.sin(angle)) + ((posDiff.y - radarCenter.y) * math.cos(angle)) + radarCenter.y)

				createPlayerGUINode(point, playerTorso.Parent)

			elseif playerTorso.Parent.Name == torso.Parent.Name then

				createPlayerGUINode(radarCenter,playerTorso.Parent)

			end
		end

	end

end


while true do
	
	if guiEnabled then
		updateGUI()
	end
	r.RenderStepped:Wait()

end



