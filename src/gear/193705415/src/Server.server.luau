local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Dropped = false

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function onActivate()
	if Dropped then return end
	
	local root = Tool.Parent:FindFirstChild("HumanoidRootPart")
	if root then
		local model = game:GetService("InsertService"):LoadAsset(193299081)
		model.Parent = workspace
		model:GetChildren()[1].CFrame = root.CFrame * CFrame.new(0, 0, -4)
		Dropped = true
		game:GetService("Debris"):AddItem(Tool, 0)
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		onActivate()
	end
end

Remote.OnServerEvent:connect(onRemote)