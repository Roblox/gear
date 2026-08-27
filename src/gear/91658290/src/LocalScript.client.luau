-- Made by Stickmasterluke
 -- edited by fusroblox

function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
	end
	return obj:FindFirstChild(name)
end

local Reloading = "http://www.roblox.com/asset/?id=50911776"

local Cursors = {
"http://www.roblox.com/asset/?id=50912619", -- red -- change the cursors
"http://www.roblox.com/asset/?id=50912641", -- blue
"http://www.roblox.com/asset/?id=50911776", -- purple
Reloading = "http://www.roblox.com/asset/?id=50911776", }

local ClipSize = 25
local Equipped = false

local Tool = script.Parent
local Player = game.Players.localPlayer
local Ammo = WaitForChild(Tool,"Ammo")
local Clips = nil

local Gui = nil
while Gui == nil do
	wait()
	Gui = Tool:FindFirstChild("PlasmaAssaultGui")
end

function UpdateGui()
	if Equipped then
		local Player = game.Players.localPlayer
		if Player ~= nil then
			if Ammo == nil then
				Gui.Bar.GunLabel.Text ="Futuro Heavy Pistol" --Tool.Name
				Gui.Bar.AmmoLabel.Text = ""
				Gui.Bar.Fill.Size = UDim2.new( - 1, 0, .8, 0)
			elseif Clips == nil then
				Gui.Bar.GunLabel.Text ="Futuro Heavy Pistol"-- Tool.Name
				Gui.Bar.AmmoLabel.Text = tostring(Ammo.Value).."/"..tostring(ClipSize)
				Gui.Bar.Fill.Size = UDim2.new( - 1 * Ammo.Value/ClipSize, 0, .8, 0)
				Gui.Bar.Fill.Visible = true
			else
				Gui.Bar.GunLabel.Text = "Futuro Heavy Pistol"--Tool.Name
				Gui.Bar.AmmoLabel.Text = tostring(Ammo.Value).."/"..tostring(ClipSize).."   "..tostring(Clips.Value)
				Gui.Bar.Fill.Size = UDim2.new( - 1 * Ammo.Value/ClipSize, 0, .8, 0)
				Gui.Bar.Fill.Visible = true
			end
			Gui.Bar.Fill.BackgroundColor3 = Color3.new(0, 204/255, 1)
			if Tool.Reloading.Value then
				Gui.Bar.AmmoLabel.Text = "Reloading"
			end
		end
	end
end

function OnEquipped(mouse)
	if mouse ~= nil then
		Equipped = true
		local Player = game.Players.LocalPlayer
		if Player ~= nil then
			local plrgui = WaitForChild(Player,"PlayerGui")
			if plrgui ~= nil then
				Gui.Parent = plrgui
			end
			mouse.Button1Down:connect(function()
				if not Tool.Down.Value then
					Tool.Aim.Value = mouse.Hit.p
					Tool.Down.Value = true
					while Tool.Down.Value do
						Tool.Aim.Value = mouse.Hit.p
						wait()
					end
				end
			end)
			mouse.Button1Up:connect(function()
				Tool.Down.Value = false
			end)
			mouse.Icon = Cursors[1]
			Tool.Reloading.Changed:connect(function(val)
				if mouse ~= nil and Equipped then
					if val then
						mouse.Icon = Cursors.Reloading
					else
						mouse.Icon = Cursors[1]
					end
					local Player = game.Players.localPlayer
					if Player ~= nil then
						local gui = WaitForChild(Player.PlayerGui, "AmmoHud")
						if gui ~= nil then
							UpdateGui()
							if Tool.Reloading.Value then
								gui.Bar.AmmoLabel.Text = "Reloading"
							end
						end
					end
				end
			end)
			UpdateGui()
		end
	end
end

function OnUnequipped()
	Gui.Parent = Tool
	Equipped = false
	local Player = game.Players.localPlayer
	if Player ~= nil then
		local gui = WaitForChild(Player.PlayerGui,"AmmoHud")
		if gui ~= nil then
			gui.Bar.GunLabel.Text = ""
			gui.Bar.AmmoLabel.Text = ""
			gui.Bar.Fill.Visible = false
		end
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

if Ammo ~= nil then
	Ammo.Changed:connect(function()
		UpdateGui()
	end)
	if Clips ~= nil then
		Clips.Changed:connect(function()
			UpdateGui()
		end)
	end
end

while Tool:FindFirstChild("Reloading") == nil do
	wait(1)
end
Tool.Reloading.Changed:connect(function()
	UpdateGui()
end)

function PlayFireAni()
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.FireAni)
	aniTrack:Play()
end

Tool.DoFireAni.Changed:connect(PlayFireAni)
