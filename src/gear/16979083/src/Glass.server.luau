--print("lol")
--Updated for R15 avatars by StarWars

local grenade = script.Parent
local tosser = script.Parent.Tosser.Value

function GetNearbyPlayers(pos, distance)

	local players = game.Players:GetPlayers()
	local results = {}
	for i=1,#players do
		if (players[i].Character ~= nil) then
			local t = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")
			if (t ~= nil) then
				if ((t.Position - pos).magnitude < distance) then
					results[#results + 1] = players[i]
				end
			end
		end
	end

	return results

end

function FlashBang()
	
	local players = GetNearbyPlayers(grenade.Position, 64)
	--print("number blinded: " .. #players)

	grenade.Transparency = 1

	local effects = {}
	local tosserEffect = nil

	for i = 1,#players do
			local guiMain = Instance.new("GuiMain") 
			guiMain.Parent = players[i].PlayerGui 
			local mainFrame = Instance.new("Frame") 
			mainFrame.Name = "FlashBangEffect"
			mainFrame.Position = UDim2.new(-.2, 0, -.2, 0) 
			mainFrame.Size = UDim2.new(1.5, 0, 1.5, 0) 
			mainFrame.BackgroundColor = BrickColor.new(1,1,1)
			mainFrame.BorderColor = BrickColor.new(1,1,1)
			mainFrame.Parent = guiMain
		if (players[i] ~= tosser) then
			effects[#effects + 1] = mainFrame
		else
			tosserEffect = mainFrame
		end
	end

	wait(.1)
	if tosserEffect ~= nil then
		for t = 1, 9 do
			tosserEffect.Transparency = t / 10
			wait(.1)
		end
		tosserEffect:Remove()
	else
		wait(.9)
	end

	wait(2)

	for t = 1, 9 do
		for n = 1, #effects do
			effects[n].Transparency = t / 10
		end
		wait(.1)
	end

	for n = 1, #effects do
		effects[n]:Remove()
	end
	
	

end

function Touched(part)
	con:disconnect()
	script.Parent.GlassBreak:Play()
	FlashBang()
end


wait(1)
con = script.Parent.Touched:connect(Touched)

wait(30)
script.Parent:Remove()