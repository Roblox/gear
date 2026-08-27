--Rescripted by StarWars
local Player = game.Players.LocalPlayer

local COOL_DOWN = 20
local TALKING_GRIP = CFrame.new(0.121005774, -1.07626426, 1.151003, -0.571957648, 0.032301072, -0.819646955, 0.0999610648, 0.994521916, -0.0305611696, 0.814169705, -0.0994124785, -0.572053254)
local HOLDING_GRIP = CFrame.new(-0.329237193, -0.576264262, 0.157275885, -0.29237175, 0, -0.956304729, 0.0999610648, 0.994521916, -0.0305611696, 0.951066017, -0.104528464, -0.290770113)

local Tool = script.Parent
local OnMouseClickEvent = Tool:WaitForChild("OnMouseClick")

local LastStrike = 0

function OnEquipped(mouse)
	if tick() - COOL_DOWN < LastStrike then
		mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
		wait(LastStrike-(tick()-COOL_DOWN))
		mouse.Icon="rbxasset://textures\\GunCursor.png"
	else
		mouse.Icon="rbxasset://textures\\GunCursor.png"
	end	
	mouse.Button1Down:connect(function()
		if tick() - LastStrike > COOL_DOWN and mouse.Target and mouse.Hit then
			local Location = mouse.Hit.p
			local Character = Tool.Parent
			if Character then
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character:FindFirstChild("Humanoid")
				if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
					LastStrike = tick()
					mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
					Tool.Grip = TALKING_GRIP
					local Sound = Tool.Handle:FindFirstChild("Sound")
					if Sound then
						Sound:Play()
					end
					OnMouseClickEvent:FireServer(Location)
					wait(5)
					Sound = Tool.Handle:FindFirstChild("Sound")
					if Sound then
						Sound:Stop()
					end
					Tool.Grip = HOLDING_GRIP
					wait(COOL_DOWN - 5)
					mouse.Icon = "rbxasset://textures\\GunCursor.png"
				end
			end
		end
	end)
end

Tool.Equipped:connect(OnEquipped)