local Player = game.Players.LocalPlayer

local Tool = script.Parent
local LaunchShirtEvent = Tool:WaitForChild("LaunchShirt")

local FIRE_RATE = 3
local WAIT_TIME = 1/60

local ShirtId = 79219345

local Gui = Tool:WaitForChild("ShirtGui")
local LastFired = 0

local function UpdateId(property)
	if property == "Text" then
		if Gui:FindFirstChild("Frame") and Gui.Frame:FindFirstChild("ImageLabel") and Gui.Frame:FindFirstChild("Frame") then
			ShirtId = tonumber(tostring(Gui.Frame.Frame.TextBox.Text)) or 0
			Gui.Frame.ImageLabel.Image = "rbxassetid://" .. tostring(ShirtId - 1)
			Gui.Frame.Frame.TextBox.Text = tostring(ShirtId)
		end
	end
end

Gui.Frame.Frame.TextBox.Changed:connect(UpdateId)
UpdateId()

Tool.Equipped:connect(function(mouse)
	Gui.Parent = Player:WaitForChild("PlayerGui")
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		local ClickTime = time()
		if ClickTime - LastFired > FIRE_RATE then
			LastFired = ClickTime
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			LaunchShirtEvent:FireServer(mouse.Hit.p, ShirtId)
			wait(FIRE_RATE)
			mouse.Icon = "rbxasset://textures\\GunCursor.png"
		end
	end)
end)

Tool.Unequipped:connect(function()
	Gui.Parent = Tool
end)