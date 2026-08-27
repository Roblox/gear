--// Redone for R15 avatars by StarWars
local Tool = script.Parent
local MouseClick = Tool:WaitForChild("MouseClick")

local Firerate = 0.7

local Player = game.Players.LocalPlayer

local function OnEquipped(mouse)
	local Torso = Player.Character:FindFirstChild("Torso") or Player.Character:FindFirstChild("UpperTorso")
	if mouse then
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:Connect(function()
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			local Fired = MouseClick:FireServer((mouse.Hit.p - Torso.Position).Unit)
			wait(Firerate)
			mouse.Icon = "rbxasset://textures\\GunCursor.png"
		end)
	end
end

Tool.Equipped:Connect(OnEquipped)