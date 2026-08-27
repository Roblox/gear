local player = script.Parent--script:FindFirstChild("target").Value--game.Players.LocalPlayer
local character = player:FindFirstChild("Humanoid")

local laughAni= Instance.new("Animation")
	laughAni.AnimationId = "http://www.roblox.com/Asset?ID=99815141"

local startTime= time()
local hum=script.Parent:FindFirstChild('Humanoid')
local animTrack=hum:LoadAnimation(laughAni)
local ltime=script:FindFirstChild("laughTime")
while not ltime do
	ltime=script:FindFirstChild("laughTime")
	wait()
end

local originPlayer=script:FindFirstChild("OriginPlayer")
while not originPlayer do
	originPlayer=script:FindFirstChild("OriginPlayer")
	wait()
end

local cheer=script:FindFirstChild("cheerSound")
while not cheer do
	cheer=script:FindFirstChild("cheerSound")
	wait()
end

cheer.Parent=player:FindFirstChild('Head')
cheer:Play()

animTrack:Play()
animTrack:AdjustSpeed(3)
--local chat= Instance.new("Dialog")
--chat.Parent=script.Parent



local onTouchConn = nil

function onTouch(part)
	local h = part.Parent:findFirstChild("Humanoid")
	if h and not h.Parent:FindFirstChild("callScript") then
		if onTouchConn then
			print('Disconnecting touch')
			onTouchConn:disconnect()
			print('Touch Connected is ' .. tostring(onTouchConn.connected))
			onTouchConn = nil
		end
		local lscript = script:Clone()
		lscript.Parent=h.Parent
		lscript:FindFirstChild("laughTime").Value=5
		lscript.Disabled = false 
		
		--lscript
	end
		script:FindFirstChild("laughTime").Value=5
end

local Handle = script:FindFirstChild("Handle")

if Handle then
	onTouchConn = Handle.Touched:connect(onTouch)
end

function forceMove()
	if not script.Parent.Torso then return end
	local nearplayer = originPlayer.Value
	if not nearplayer then return end
	print (character)
	character:MoveTo(nearplayer.Character.Torso.CFrame.p,nearplayer.Character.Torso)
end

while(time()-startTime<ltime.Value) do
	forceMove()
	wait(.3)
	forceMove()
	wait(.2)
end


animTrack:Stop()

print("stopped laughing")

script:Destroy()