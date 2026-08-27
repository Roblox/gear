--Stickmasterluke


sp=script.Parent


r=game:service("RunService")
debris=game:GetService("Debris")

anims={"RightSlash","LeftSlash","OverHeadSwing","LeftSwingFast","RightSwingFast"}

basedamage=5
slashdamage=10
swingdamage=15
damage=basedamage

sword=sp.Handle
sp.Taunting.Value=false

local SlashSound=Instance.new("Sound")
SlashSound.SoundId="rbxasset://sounds\\swordslash.wav"
SlashSound.Parent=sword
SlashSound.Volume=.7

local UnsheathSound=Instance.new("Sound")
UnsheathSound.SoundId="rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent=sword
UnsheathSound.Volume=.5

function waitfor(parent,name)
	while true do
		local child=parent:FindFirstChild(name)
		if child~=nil then
			return child
		end
		wait()
	end
end
waitfor(sp,"Taunting")
waitfor(sp,"Summon")
waitfor(sp,"RunAnim")
sparkles=waitfor(sword,"Sparkles")

function blow(hit)
	if hit.Parent~=nil then
		local humanoid=hit.Parent:findFirstChild("Humanoid")
		local vCharacter=sp.Parent
		if vCharacter~=nil then
			local vPlayer=game.Players:playerFromCharacter(vCharacter)
			if vPlayer~=nil then
				local hum=vCharacter:findFirstChild("Humanoid")
				if humanoid~=nil then
					if hum~=nil and humanoid~=hum and hum.Health>0 then
						local right_arm=vCharacter:FindFirstChild("Right Arm")
						if right_arm~=nil then
							local joint=right_arm:FindFirstChild("RightGrip")
							if joint~=nil and (joint.Part0==sword or joint.Part1==sword) then
								sparkles.Enabled=true
								tagHumanoid(humanoid,vPlayer)
								humanoid:TakeDamage(damage)
								wait(.3)
								sparkles.Enabled=false
							end
						end
					end
				end
			end
		end
		if hit.Name=="Handle" then
			sparkles.Enabled=true
			wait(.3)
			sparkles.Enabled=false
		end
	end
end


function tagHumanoid(humanoid,player)
	for i,v in ipairs(humanoid:GetChildren()) do
		if v.Name=="creator" then
			v:remove()
		end
	end
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	creator_tag.Parent=humanoid
	debris:AddItem(creator_tag,1)
end

function createzombie(plr,pos)
	local zombie=game:GetService("InsertService"):LoadAsset(93601062):GetChildren()[1]
	--local zombie=game.Lighting.Zombie:clone()

	local creator=Instance.new("ObjectValue")
	creator.Value=plr
	creator.Name="creator"
	creator.Parent=zombie

	local p=Instance.new("Part")
	p.Name="Effect"
	p.Transparency=1
	p.FormFactor="Custom"
	p.Size=Vector3.new(.2,.2,.2)
	p.Anchored=true
	p.CFrame=CFrame.new(pos)+Vector3.new(0,-4,0)
--[[	local smoke=Instance.new("Smoke")
	smoke.Color=Color3.new(0,.1,0)
	smoke.RiseVelocity=10
	smoke.Parent=p]]
	local smoke=Instance.new("Fire")
	smoke.Color=Color3.new(0,0,0)
	smoke.SecondaryColor=Color3.new(0,1,0)
	smoke.Size=10
	smoke.Heat=100
	smoke.Parent=p
	debris:AddItem(p,2)
	p.Parent=game.Workspace
	delay(1,function()
		if smoke and smoke~=nil then
			smoke.Enabled=false
		end
	end)

	debris:AddItem(zombie,30)
	zombie.Parent=game.Workspace
	zombie:MoveTo(pos)
end

sp.Summon.Changed:connect(function()
	local chr=sp.Parent
	if chr then
		local torso=chr:FindFirstChild("Torso")
		local plr=game.Players:GetPlayerFromCharacter(chr)
		if plr and plr~=nil and torso and torso~=nil then
			createzombie(plr,(torso.CFrame*CFrame.new(5,0,-5)).p)
			createzombie(plr,(torso.CFrame*CFrame.new(-5,0,-5)).p)
		end
	end
end)

sp.Enabled=true
function onActivated()
	if sp.Enabled and not sp.Taunting.Value then
		sp.Enabled=false
		local character=sp.Parent
		local humanoid=character.Humanoid
		if humanoid==nil then
			print("Humanoid not found")
			return 
		end
		SlashSound:play()
		newanim=anims[math.random(1,#anims)]
		while newanim==sp.RunAnim.Value do
			newanim=anims[math.random(1,#anims)]
		end
		sp.RunAnim.Value=newanim
		if newanim=="OverHeadSwing" then
			damage=swingdamage
		else
			damage=slashdamage
		end
		wait(.75)
		damage=basedamage
		sp.Enabled=true
	end
end

function onEquipped()
	UnsheathSound:play()
	sparkles.Enabled=false
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)

connection=sword.Touched:connect(blow)


