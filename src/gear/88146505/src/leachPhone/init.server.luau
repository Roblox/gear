FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

blowsound = Instance.new("Sound")
		blowsound.SoundId = "http://www.roblox.com/Asset?ID=86300411"
		blowsound.Parent = script.Parent
		blowsound.Volume = 1	

cricketsound = Instance.new("Sound")
		cricketsound.SoundId = "http://www.roblox.com/Asset?ID=86300687"
		cricketsound.Parent = script.Parent
		cricketsound.Volume = 1

laugh1sound = Instance.new("Sound")
		laugh1sound.SoundId = "http://www.roblox.com/Asset?ID=86300561"
		laugh1sound.Parent = script.Parent
		laugh1sound.Volume = 1

laugh2sound = Instance.new("Sound")
		laugh2sound.SoundId = "http://www.roblox.com/Asset?ID=86300471"
		laugh2sound.Parent = script.Parent
		laugh2sound.Volume = 1


laugh3sound = Instance.new("Sound")
		laugh3sound.SoundId = "http://www.roblox.com/Asset?ID=86300362"
		laugh3sound.Parent = script.Parent
		laugh3sound.Volume = 1






local total_time = 5 -- seconds
local cur_time = 0

		


function update(frac)
	--script.Parent.Fuse.Color = Color3.new(1,1 - frac,0)
end

local players_ret= {}
function getNearPlayers(mindist,pos)
	local parent_pos= pos
	
	local i=1
	for _, player in pairs(game.Players:GetPlayers()) do
		print (player)
			tdist= (player.Character.Torso.CFrame.p-parent_pos).magnitude
			
			if tdist<mindist then
				players_ret[i]=player
				i=i+1
				print (tdist)
			end
	end
	--table.setn(players,i+1)
	return players_ret
end

function blowUp()
	blowsound:play()
	wait(.45)
	explosion = Instance.new("Explosion")
	explosion.BlastRadius = 12
	explosion.BlastPressure = 0 -- these are really wussy units
	explosion.ExplosionType = Enum.ExplosionType.NoCraters

	
	-- find instigator tag
	local creator = script.Parent:findFirstChild("creator")
	if creator ~= nil then
		explosion.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
	end

	explosion.Position = script.Parent.Position
	explosion.Parent = game.Workspace
	script.Parent.Transparency = 1

	local players = getNearPlayers(20,script.Parent.Position)
	print(players)
	wait(1.4)
	print(table.getn(players))
	local num_play = table.getn(players)
	if num_play<1 then
		cricketsound:play()
		print("cricket sound played")
	elseif num_play==1 then
		laugh1sound:play()
		forceLaugh(players,5)
	elseif num_play==2 then
		laugh2sound:play()
		forceLaugh(players,7)
	else
		laugh3sound:play()
		forceLaugh(players,10)
	end
end

function forceLaugh(players,ltime)
	local startTime= time()
	local char
	
	for _, player in pairs (players) do
		char=player.Character
		if char then 
			local lscript = script:FindFirstChild("callScript"):Clone()
			lscript.Parent=char
			lscript:FindFirstChild("laughTime").Value=ltime
			lscript.Disabled = false 
		end
	end
	print("stopped laughing")
end

function onPlayerBlownUp(part, distance, creator)
	if part.Name == "Head" then
		local humanoid = part.Parent.Humanoid
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)
	-- tag does not need to expire iff all explosions lethal
	
	if creator ~= nil then
		local new_tag = creator:clone()
		new_tag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

function isPlayerCreator(player)
	local creator_tag = script.Parent:FindFirstChild('creator')
	if creator_tag and creator_tag.Value == player then
		return true
	end
	return false
end

local onTouchConn = nil

function onTouch(part)
	local h = part.Parent:findFirstChild("Humanoid")
	if h and not isPlayerCreator(game.Players:playerFromCharacter(part.Parent)) and not h.Parent:FindFirstChild("callScript") then
		if onTouchConn then
			print('Disconnecting touch')
			onTouchConn:disconnect()
			onTouchConn = nil
		end
		local lscript = script:FindFirstChild("callScript"):Clone()
		lscript.Parent=h.Parent
		lscript:FindFirstChild("laughTime").Value=5
		lscript.Disabled = false 
		local tphone=script.Parent:Clone()
		tphone.Parent = lscript
		tphone.Name= "Handle"
		local tweld= Instance.new("Weld")
		tweld.Parent = h.Parent:FindFirstChild("Right Arm")
		tweld.Part0 = h.Parent:FindFirstChild("Right Arm") --> part0 has to be the parent 
		tweld.Part1 = tphone
		tweld.C0 = CFrame.new(0.5,-1.0,0,1,0,0,0,0,1,0,-1,0)  
		
		--lscript

	end
end

onTouchConn = script.Parent.Touched:connect(onTouch)

--countdown
while cur_time < total_time do
	update(cur_time / total_time)
	local e,g = wait(.5)
	cur_time = cur_time + e
end



--blowUp()
wait(5)
script.Parent:remove()
