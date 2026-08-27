--Stickmasterluke


sp=script.Parent


r=game:service("RunService")
debris=game:GetService("Debris")

anims={"RightSlash","LeftSlash"}

basedamage=2
slashdamage=14
rangedamage=46
damage=basedamage

specialready=true
lastclick=0

sword=sp.Handle

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

handle=sp:WaitForChild("Handle")
specialfire=handle:WaitForChild("Fire")
mesh=waitfor(sp.Handle,"Mesh")
waitfor(sp,"RunAnim")
debris=game:GetService("Debris")


specialfire.Enabled=true
function lunge()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = sp
end

function blow(hit)
	if hit.Parent~=nil then
		local humanoid=hit.Parent:findFirstChild("Humanoid")
		local vCharacter=sp.Parent
		if vCharacter~=nil then
			local vPlayer=game.Players:playerFromCharacter(vCharacter)
			if vPlayer~=nil then
				local hum=vCharacter:findFirstChild("Humanoid")
				if humanoid~=nil then
					if hum~=nil and humanoid~=hum then
						local right_arm=vCharacter:FindFirstChild("Right Arm")
						if right_arm~=nil then
							local joint=right_arm:FindFirstChild("RightGrip")
							if joint~=nil and (joint.Part0==sword or joint.Part1==sword) then
								tagHumanoid(humanoid,vPlayer)
								humanoid:TakeDamage(damage)
							end
						end
					end
				end
			end
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

function lunge()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = sp
end

sp.Enabled=true
function onActivated()
	delay(.01,function()
		lastclick=tick()
	end)
	if sp.Enabled then
		sp.Enabled=false
		local character=sp.Parent;
		local humanoid=character.Humanoid
		if humanoid==nil then
			print("Humanoid not found")
			return 
		end
		if (tick()-lastclick)<.2 and specialready then
			specialready=false
			specialfire.Enabled=false
			SlashSound.Volume=1
			SlashSound:play()
			lunge()
			damage=0
			local t=sp.Parent:FindFirstChild("Torso")
			if t~=nil then
				local p=Instance.new("WedgePart")
				p.FormFactor="Custom"
				p.Name="EffectFlag"
				p.BrickColor=BrickColor.new("Bright blue")
				p.Transparency=.25
				p.Size=Vector3.new(10,3,6.18)
				p.CanCollide=false
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.Velocity=t.CFrame.lookVector*30
				p.CFrame=t.CFrame*CFrame.new(1.5,.5,-3)*CFrame.Angles(math.pi/2,0,0)
				
				--[[local sparkles=Instance.new("Sparkles")
				sparkles.SparkleColor=Color3.new(1,1,1)
				sparkles.Enabled=true
				sparkles.Parent=p]]
				--[[local smoke=Instance.new("Smoke")
				smoke.Color=Color3.new(.7,.7,1)
				smoke.Size=2
				smoke.RiseVelocity=2
				smoke.Parent=p]]
				local fire=Instance.new("Fire")
				fire.Color=Color3.new(0,.3,1)
				fire.SecondaryColor=Color3.new(.9,.95,1)
				fire.Size=15
				fire.Heat=3
				fire.Parent=p
				
				local bf=Instance.new("BodyForce")
				bf.force=Vector3.new(0,196.2*p:GetMass(),0)
				bf.Parent=p
				p.Touched:connect(function(hit)
					if hit~=nil then
						local h=hit.Parent:FindFirstChild("Humanoid")
						local mh=sp.Parent:FindFirstChild("Humanoid")
						if h~=nil and mh~=nil and h~=mh then
							local plr=game.Players:playerFromCharacter(mh.Parent)
							if plr~=nil then
								tagHumanoid(h,plr)
							end
							h:TakeDamage(rangedamage)
							p:remove()
						end
					end
				end)
				local s=sp.Handle:FindFirstChild("WaveSound")
				if s~=nil then
					s:Play()
				end
				debris:AddItem(p,1.5)
				p.Parent=game.Workspace
			end
			wait(1)
			delay(9,function()
				specialfire.Enabled=true
				specialready=true
			end)
		else
			SlashSound.Volume=.7
			SlashSound:play()
			newanim=anims[math.random(1,#anims)]
			while newanim==sp.RunAnim.Value do
				newanim=anims[math.random(1,#anims)]
			end
			sp.RunAnim.Value=newanim
			damage=slashdamage
			wait(.5)
		end
		damage=basedamage
		sp.Enabled=true
	end
end

function onEquipped()
	UnsheathSound:play()
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)

connection=sword.Touched:connect(blow)


