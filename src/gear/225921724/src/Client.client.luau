local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local Mouse = Player:GetMouse()
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Tracks = {}
local InputType = Enum.UserInputType

local BeganConnection, EndedConnection

function playAnimation(animName, ...)
	if Tracks[animName] then
		Tracks[animName]:Play()
	else
		local anim = Tool:FindFirstChild(animName)
		if anim and Tool.Parent and Tool.Parent:FindFirstChild("Humanoid") then
			Tracks[animName] = Tool.Parent.Humanoid:LoadAnimation(anim)
			playAnimation(animName, ...)
		end
	end
end

function stopAnimation(animName)
	if Tracks[animName] then
		Tracks[animName]:Stop()
	end
end

function inputBegan(input)
	if input.UserInputType == InputType.MouseButton1 then
		Remote:FireServer("LeftDown", Mouse.Hit.p)
	end
end

function inputEnded(input)
	if input.UserInputType == InputType.MouseButton1 then
		Remote:FireServer("LeftUp")
	end
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	elseif func == "StopAnimation" then
		stopAnimation(...)
	end
end

function onEquip()
	BeganConnection = UIS.InputBegan:connect(inputBegan)
	EndedConnection = UIS.InputEnded:connect(inputEnded)
end

function onUnequip()
	if BeganConnection then
		BeganConnection:disconnect()
		BeganConnection = nil
	end
	
	if EndedConnection then
		EndedConnection:disconnect()
		EndedConnection = nil
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnClientEvent:connect(onRemote)