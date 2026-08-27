local Tool = script.Parent;
local gui = script.Parent.EggGUI
local guiEnabled = false
local guiOnPlayer = nil
local fixedGui = false

enabled = true

-- when activated, either bring gui up or down, depending on current state

function onActivated()

	if not enabled  then
		return
	end
	
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		if guiEnabled == false then
			local p = game.Players:GetPlayerFromCharacter(Tool.Parent)
			if(guiOnPlayer == nil) then
				guiOnPlayer = gui:Clone()
				guiOnPlayer.Parent = p.PlayerGui
			end
			guiEnabled = true
			guiOnPlayer.GUIFrame.Visible  = true
			Tool.GripForward = Vector3.new(-0,-0,1)
			Tool.GripPos = Vector3.new(-0.3,-0.6,0)
			Tool.GripRight = Vector3.new(-1,0,0)
			Tool.GripUp = Vector3.new(0,1,0)
		else
			Tool.GripForward = Vector3.new(-0,-0,1)
			Tool.GripPos = Vector3.new(-0,-0,0)
			Tool.GripRight = Vector3.new(1,0,0)
			Tool.GripUp = Vector3.new(0,1,0)
			guiEnabled = false
			guiOnPlayer.GUIFrame.Visible = false
		end
	end
	
	wait(1)

	enabled = true

end

-- remove gui when item is unequipped

function onUnequipped()

	if guiEnabled == true then
		Tool.GripForward = Vector3.new(-0,-0,1)
		Tool.GripPos = Vector3.new(-0,-0,0)
		Tool.GripRight = Vector3.new(1,0,0)
		Tool.GripUp = Vector3.new(0,1,0)
		guiEnabled = false
		guiOnPlayer:remove()
		guiOnPlayer = nil
	end

end

function onEquipped()

	if fixedGui == false then

		local children = gui.GUIFrame:GetChildren()
		for i = 1 , #children do
			if i == 17 then print("")
			elseif children[i] ~= nil then
				print(i)
				children[i]:FindFirstChild("Egg Name").Text = GetEggName(i)
				children[i]:FindFirstChild("Egg Image").Image = "http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=110&ht=110&aid=" .. tostring(GetEggAssetID(i))
			end
		end
		fixedGui = true
	end

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
script.Parent.Activated:connect(onActivated)


function updateGUI()

	local eggs = game.Workspace:FindFirstChild("eggroot")
	
	-- clear out gui numbers
	for i = 1, 24 do
		if i == 17 then print("")
		else
			guiOnPlayer.GUIFrame:FindFirstChild(tostring(i)).EggQuantity.Text = "0"
		end
	end

	if eggs ~= nil then
		eggs = eggs:getChildren()

		-- update gui numbers
		for i = 1, #eggs do
			local eggNum = tonumber(eggs[i].Name)
			updateFrame(eggNum)
		end
	end

end

function GetEggName(eggnum)
                if eggnum == 1 then return "Specular Egg of Red, No Blue" end
                if eggnum == 2 then return "Chrome Egg of Speeding Bullet" end
                if eggnum == 3 then return "Agonizingly Ugly Egg of Screensplat" end
                if eggnum == 4 then return "Unassuming Egg of Shyness" end
                if eggnum == 5 then return "POW! To the Moon! Egg" end
                if eggnum == 6 then return "Scenic Egg of the Clouds" end
                if eggnum == 7 then return "Shiny Gold Egg of Switcheroo" end
                if eggnum == 8 then return "Egg of Equinox: Day" end
                if eggnum == 9 then return "Egg of Equinox: Night" end
                if eggnum == 10 then return "Rusty Egg of Magnetism" end
                if eggnum == 11 then return "Explosive Egg of Kaboom!" end
                if eggnum == 12 then return "Radioactive Egg of Zombie Apochalypse" end
                if eggnum == 13 then return "Vicious Egg of Singularity" end
                if eggnum == 14 then return "Blue Faberge Egg" end
                if eggnum == 15 then return "Red Faberge Egg" end
                if eggnum == 16 then return "Green Faberge Egg" end
                if eggnum == 18 then return "Fiery Egg of Egg Testing" end
                if eggnum == 19 then return "Dark Crimson Egg of Nemesis" end
                if eggnum == 20 then return "Starry Egg of Wild Ride" end
                if eggnum == 21 then return "Zeno's Egg of Paradox" end
                if eggnum == 22 then return "Extinct Dino Egg on Ice" end
                if eggnum == 23 then return "Hot Pink Faberge Egg" end
                if eggnum == 24 then return "Golden Faberge Egg of Hivemind" end
end

function GetEggAssetID(eggnum)
                if eggnum == 1 then return 24826800 end
                if eggnum == 2 then return 24826640 end
                if eggnum == 3 then return 24826811 end
                if eggnum == 4 then return 24826840 end
                if eggnum == 5 then return 24826737 end
                if eggnum == 6 then return 24826725 end
                if eggnum == 7 then return 24826693 end
                if eggnum == 8 then return 24826656 end
                if eggnum == 9 then return 24826683 end
                if eggnum == 10 then return 24826787 end
                if eggnum == 11 then return 24826755 end
                if eggnum == 12 then return 24826704 end
                if eggnum == 13 then return 24826853 end
                if eggnum == 14 then return 24830979 end
                if eggnum == 15 then return 24832618 end
                if eggnum == 16 then return 24832637 end
                if eggnum == 18 then return 27345567 end
                if eggnum == 19 then return 27398610 end
                if eggnum == 20 then return 31151864 end
                if eggnum == 21 then return 31157811 end
                if eggnum == 22 then return 31156903 end
                if eggnum == 23 then return 31149956 end
                if eggnum == 24 then return 31149244 end
end

function updateFrame(eggNum)

	numOfEggs = tonumber(guiOnPlayer.GUIFrame:FindFirstChild(eggNum).EggQuantity.Text)
	numOfEggs = numOfEggs + 1
	guiOnPlayer.GUIFrame:FindFirstChild(eggNum).EggQuantity.Text = tostring(numOfEggs)

end

while true do
	
	if guiEnabled then
		updateGUI()
	end
	wait(2)

end

