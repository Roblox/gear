function waitforchild(parent,child)
	while not parent:FindFirstChild(child) do wait() print(parent.Name .. " Waiting for " .. child) end
	return parent[child]
end

local Tool=script.Parent
local MyHumanoid
local IsPlayingMusic = false
local KeyDownConnection
local KeyUpConnection
local ShiftDown = false
local MyPlayer
local Handle = waitforchild(Tool,'Handle')
local Speaker = waitforchild(Handle,'Sound')
local content = Game:GetService("ContentProvider")

local HoldAniTrack
local PluckAniTrack

local MashMeter=0

local MeltDistance = 30

ApplauseID = "http://www.roblox.com/asset/?id=99187949"
content:Preload(ApplauseID)

local PowerChords =
{
	109619047, --A--
	109618940, --B--
	109618842, --C--
	109618754, --D--
	109618695, --E--
	109618563, --F--
	109618435, --G--
}

local PowerSharpChords =
{
	109619047, --A--
	109618940, --B--
	109618842, --C--
	109618754, --D--
	109618695, --E--
	109618563, --F--
	109618435, --G--
}

local Pitches =
{
	.5,--G
	.75,--H
	1,--J
	1.25,--K
	1.5,--L
}

for _,i in ipairs(PowerChords) do
	content:Preload("http://www.roblox.com/asset/?id="..i)
end

for _,i in ipairs(PowerSharpChords) do
	content:Preload("http://www.roblox.com/asset/?id="..i)
end


function OnKeyDown(key)
	print('key is:'..key)
	Speaker:Stop()
	local soundID
	local pitchIndex=0
	if key == 'z' then
		soundID= 1
	elseif key == 'x' then
		soundID= 2
	elseif key == 'c' then
		soundID= 3
	elseif key == 'v' then
		soundID= 4
	elseif key == 'b' then
		soundID= 5
	elseif key == 'n' then
		soundID= 6
	elseif key == 'm' then
		soundID= 7
	elseif key == 'g' then
		pitchIndex=1
	elseif key == 'h' then
		pitchIndex=2
	elseif key == 'j' then
		pitchIndex=3
	elseif key == 'k' then
		pitchIndex=4
	elseif key == 'l' then
		pitchIndex=5
	elseif key == '0' then --shift pressed!
		print('ShiftDown!')
		ShiftDown=true
		MyPlayer:GetMouse().KeyUp:connect(function(nkey)
			if	nkey=='0' then
				ShiftDown=false
				print('shift up!')
			end
		end)
	end

	if pitchIndex>0 then
		Speaker.Pitch= Pitches[pitchIndex]
	elseif soundID then
		--add shift modifier later
		if ShiftDown then
			soundID= PowerSharpChords[soundID]
		else
			soundID= PowerChords[soundID]
		end
		local tspeaker=Speaker:Clone()
		tspeaker.Parent=Handle
		tspeaker.SoundId='http://www.roblox.com/asset/?id='..soundID
		wait(0)
		tspeaker:Play()
		local nconnection
		local startTime=tick()
		nconnection = MyPlayer:GetMouse().KeyUp:connect(function(nkey) OnKeyUp(nkey,key,tspeaker,startTime, nconnection) end)
		PluckAniTrack:Play()
		MashMeter= MashMeter+1
	end
end

function OnKeyUp(key, keymatch, mySpeaker,timeStarted, connection)
	if key == keymatch then
		--enforce minimum note time
		if tick()-timeStarted < .25 then
			wait( .25-(tick()-timeStarted) )
		end
		mySpeaker:Stop()
		Delay(1,function() mySpeaker.Parent=nil end)
		connection:disconnect()
	end
end

function OnClick()
	IsPlayingMusic = not IsPlayingMusic
	if IsPlayingMusic then
		KeyDownConnection = MyPlayer:GetMouse().KeyDown:connect(OnKeyDown)
		Tool.Grip = CFrame.new(0.01923877, 1.19116962, 0.313162446, 0.49999997, 0.707106769, 0.49999997, 0.0564237535, 0.549525201, -0.833569586, -0.864185274, 0.444996685, 0.23486498)

		HoldAniTrack:Play()
	else
		Tool.Grip = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		HoldAniTrack:Stop()
		if KeyDownConnection then
			KeyDownConnection:disconnect()
		end
	end

end

function OnUnequip()
	HoldAniTrack:Stop()
end

Tool.Unequipped:connect(OnUnequip)

function OnEquip(mouse)
	MyHumanoid=waitforchild(Tool.Parent,'Humanoid')
	MyPlayer = Game.Players:GetPlayerFromCharacter(Tool.Parent)
	HoldAniTrack=MyHumanoid:LoadAnimation(waitforchild(Tool,'hold'))
	PluckAniTrack=MyHumanoid:LoadAnimation(waitforchild(Tool,'pluck'))
	mouse.Button1Down:connect(OnClick)
end

Tool.Equipped:connect(OnEquip)

function MeltFace(player)
--	
--	waitforchild(player.Character,'Humanoid').WalkSpeed=0
--	waitforchild(player.Character,'Torso').Anchored=true
--	local head = player.Character.Head
--	local thead = head:Clone()
--	thead.CanCollide = false
--	thead.Transparency = 1
--	for _, i in pairs(thead:GetChildren()) do
--		if not (i:IsA('Decal') or i:IsA('Mesh')) then
--			i:Destroy()
--		elseif i:IsA('Decal') then
--			head[i.Name]:Destroy()
--		end
--	end
--	local bodyvel = Instance.new('BodyVelocity')
--	thead.Position = head.CFrame.p+head.CFrame.lookVector
--	bodyvel.velocity = Vector3.new(0,-1,0)
--	bodyvel.maxForce=Vector3.new(50000,50000,50000)
--	bodyvel.Parent=thead
--	thead.Parent=Workspace
--	
--	local applauseSound = Instance.new('Sound')
--	applauseSound.SoundId = ApplauseID
--	applauseSound.Parent=head
--	applauseSound.Volume=1
--	applauseSound:Play()
--
--	wait(3)
--	player.Character.Humanoid.WalkSpeed=16
--	player.Character.Torso.Anchored=false
end

function MeltNearFaces()
	for _,i in pairs(game.Players:GetPlayers()) do
		if i ~= MyPlayer and i.Character and i.Character:FindFirstChild('Head') and 
			(Handle.CFrame.p-i.Character.Head.CFrame.p).magnitude<MeltDistance then
			Spawn(function() MeltFace(i) end)
		end
	end
end

while true do
	if MashMeter>0 then
		MashMeter= MashMeter-.1
	end
	if MashMeter>9 then
		print("mashscore= " .. MashMeter)
		MeltNearFaces()
		wait(5)
		MashMeter = 0
	end
	wait(1/30)
end