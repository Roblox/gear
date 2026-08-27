--[[
	Fixed by ArceusInator & ReallyLongArms
--]]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local Sound = Handle:WaitForChild("Sound")
local LastRequestTime = 0

function floodCheck()
	local timeNow = tick()
	local elapsed = timeNow - LastRequestTime
	if elapsed > 0.5 then
		LastRequestTime = timeNow
		return false
	end
	return true
end

function onUnequip()
	Sound:Stop()
end

function onActivate()
	Remote:FireClient(getPlayer(), "ChooseSong")
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function isPotentiallyValid(id)
	local idNumber = tonumber(id)

	if not idNumber then
		return false
	end

	if idNumber > 100000000000000000000 then
		return false
	end

	return true
end

function playSong(id)	
	id = id or ""

	if not isPotentiallyValid(id) then
		return
	end

	if not Sound then
		Sound = Instance.new'Sound'
	end

	Sound.Parent = Handle
	Sound.Volume = 1
	Sound.Looped = true
	Sound.PlayOnRemove = false
	Sound.SoundId = "http://www.roblox.com/asset/?id="..id
	Sound:Play()
end

function onRemote(player, func, ...)
	if floodCheck() then return end
	if player ~= getPlayer() then return end

	if func == "Activate" then
		onActivate(...)
	end

	if func == "PlaySong" then
		playSong(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
Tool.Unequipped:connect(onUnequip)