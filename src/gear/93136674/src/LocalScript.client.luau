r = game:service("RunService")

local sword = script.Parent.Handle
local Tool = script.Parent

local SlashDamage=3

local UpperCutAni

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = sword
SlashSound.Volume = .7


local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1

local BodyPos=Instance.new('BodyPosition')
BodyPos.maxForce=Vector3.new(99999,99999,99999)
local BVel= Instance.new('BodyVelocity')
BVel.maxForce=Vector3.new(0,99999,0)
BVel.velocity=Vector3.new(0,40,0)
local BGyro=Instance.new('BodyGyro')
BGyro.maxTorque=Vector3.new(999999,999999,999999)

--current slash pos character is in
local SlashPoseAni=nil

--mode can be 'wait' :waiting for attack
--'throw':able to throw player
--'slash':slashing a player
local Mode='wait'

local SlashPoses= {}

--last character thrown
local LastThrown=nil

function SpinCamera(center,focus,length)
	local cam = workspace.CurrentCamera
	local radius = 15
	local angle = 0
	local omega = .025
	local startTime=time()
	while time()-startTime<length do
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CoordinateFrame = CFrame.new(center + Vector3.new(math.sin(angle) * radius, 0, math.cos(angle) * radius), focus)
		angle = angle + omega
 		wait(1/30)
	end
	cam.CameraSubject=game.Players.LocalPlayer
	workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
end


function doDamage(human,damage)
	tagHumanoid(human, vPlayer)
	human:TakeDamage(damage)
	wait(1)
	untagHumanoid(human)
end

function throwCharacter(character)
	LastThrown=character
	BVel.Parent=character.Torso
	delay(1,function()
		BVel.Parent=nil
	end)
	delay(2,function()
		if LastThrown==character and Mode ~= 'slash' then
			LastThrown=nil
		end
	end)
end

function OnTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		if Mode=='throw' then
			throwCharacter(humanoid.Parent)
			--Spawn(function() doDamage(humanoid,30) end)
		end
	end
end


function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end


function Uppercut()
	UpperCutAni:Play(.1,1,2)
	Mode='throw'
	SlashSound:play()
	wait(.75)
	if Mode=='throw' then
		Mode='wait'
	end
end

function ExitSlash()
	Mode='wait'

	BodyPos.Parent=nil
	BGyro.Parent=nil

	if LastThrown:FindFirstChild('Torso') then
		LastThrown.Torso.Anchored=false
	end

	LastThrown=nil

	if SlashPosAni then
		SlashPosAni:Stop()
		SlashPosAni=nil
	end
end

function FadeOut(part,length)
	local startTime=time()
	while time()-startTime<length do
		part.Transparency=(time()-startTime)/length
		wait()
	end
	part:Destroy()
end


function EnterSlash()
	Mode='slash'
	print('entering slash')
	Tool.Handle.powerup:Play()
	if not LastThrown:FindFirstChild('Torso') then return end
	LastThrown.Torso.Anchored=true
	Tool.Parent.Humanoid.TargetPoint=LastThrown.Torso.CFrame.p
	BodyPos.position=LastThrown.Torso.CFrame.p+(LastThrown.Torso.CFrame.lookVector*5)
	BodyPos.Parent=Tool.Parent.Torso
	BGyro.cframe=CFrame.new(BodyPos.position,LastThrown.Torso.CFrame.p)
	BGyro.Parent=Tool.Parent.Torso
	Spawn(function() SpinCamera(LastThrown.Torso.CFrame.p+Vector3.new(0,5,0),LastThrown.Torso.CFrame.p,5) end)
	delay(5, ExitSlash)
end

function DoSlash()
	local tani= SlashPoses[math.random(#SlashPoses)]
	tani:Play(0)
	if SlashPosAni then
		SlashPosAni:Stop()
	end
	SlashPosAni =tani

	
	if(LastThrown:FindFirstChild('Humanoid')) then
		local tslash=Tool.SlashPart:Clone()
		
		tslash.CFrame=CFrame.new((Tool.Parent.Torso.CFrame.p+LastThrown.Torso.CFrame.p)*.5,LastThrown.Torso.CFrame.p)*
			CFrame.Angles(math.random()*math.pi*2,math.random()*math.pi*2,math.random()*math.pi*2)
		tslash.Parent=Tool
		tslash.Sound.Pitch=(math.random()*.5)+.75
		tslash.Sound:Play()

		--local flashgui=Tool.FlashScreen:Clone()
		--flashgui.Parent = game.Players.LocalPlayer.PlayerGui
		--flashgui.FlashScript.Disabled=false
		local otherPlayer=game.Players:GetPlayerFromCharacter(LastThrown)
		--if otherPlayer then
		--	flashgui=Tool.FlashScreen:Clone()
		--	while not otherPlayer:FindFirstChild('PlayerGui') do wait() end
		--	flashgui.Parent = otherPlayer.PlayerGui
		--	flashgui.FlashScript.Disabled=false
		--end

		Spawn(function()FadeOut(tslash,.5) end)
		Spawn(function()doDamage(LastThrown.Humanoid,SlashDamage) end)
	end
	
end

Tool.Enabled = true
function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	if LastThrown and (Mode=='wait' or Mode=='throw') then
		EnterSlash()
	elseif Mode == 'slash' then
		DoSlash()
	elseif Mode=='wait' then
		Uppercut()
	end
	Tool.Enabled = true
end


function onEquipped()
	UnsheathSound:play()
	while not Tool.Parent:FindFirstChild('Humanoid') do wait() end
	UpperCutAni = Tool.Parent.Humanoid:LoadAnimation(Tool.uppercut)
	SlashPoses={}
	local i=1
	while Tool.poses:FindFirstChild(i) do
		table.insert(SlashPoses,Tool.Parent.Humanoid:LoadAnimation(Tool.poses[i]))
		i=i+1
	end
end

function onUnequipped()
	workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
	if Mode=='slash' then
		BodyPos.Parent=nil
		if LastThrown then
			local enemyTorso=LastThrown:FindFirstChild('Torso')
			if enemyTorso then
				enemyTorso.Anchored=false
			end
		end
	end
	BVel.Parent=nil
	BGyro.Parent=nil
	if SlashPoseAni then
		SlashPoseAni:Stop()
	end
	Mode='wait'
	LastThrown=nil
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

script.Parent.Unequipped:connect(onUnequipped)


connection = sword.Touched:connect(OnTouched)


