--Stickmasterluke


sp=script.Parent


r=game:service("RunService")
debris=game:GetService("Debris")

anims={"RightSlash","LeftSlash"}

basedamage=2
beardamage=5
armdamage=25
damage=basedamage

basearmhold=CFrame.new(-1,0,.3)*CFrame.Angles(-.1,0,3)

function waitfor(parent,name)
	while true do
		local child=parent:FindFirstChild(name)
		if child~=nil then
			return child
		end
		wait()
	end
end

waitfor(sp,"Handle")
waitfor(sp.Handle,"Mesh")
waitfor(sp,"RunAnim")
waitfor(sp,"Taunting")
waitfor(sp,"LeftSlash")
waitfor(sp,"RightSlash")
waitfor(sp,"Taunt")


local SlashSound=Instance.new("Sound")
SlashSound.SoundId="rbxasset://sounds\\swordslash.wav"
SlashSound.Parent=sp.Handle
SlashSound.Volume=.7

local UnsheathSound=Instance.new("Sound")
UnsheathSound.SoundId="http://www.roblox.com/asset/?id=85004909"
UnsheathSound.Parent=sp.Handle
UnsheathSound.Volume=1

sp.Taunting.Value=false

function blow(weapon,hit)
	if weapon and hit and weapon.Parent~=nil and hit.Parent~=nil then
		if weapon~=sp.Handle then
			local aw=sp.Handle:FindFirstChild("LeftArmWeld")
			if aw==nil or aw.Part1~=weapon then
				return
			end
		end
		local humanoid=hit.Parent:findFirstChild("Humanoid")
		local vCharacter=sp.Parent
		local vPlayer=game.Players:playerFromCharacter(vCharacter)
		local hum=vCharacter:findFirstChild("Humanoid")
		local aw=sp.Handle:FindFirstChild("LeftArmWeld")
		if humanoid~=nil and humanoid.Health>0 then
			if hum~=nil and humanoid~=hum then
				local right_arm=vCharacter:FindFirstChild("Right Arm")
				if right_arm~=nil then
					local joint=right_arm:FindFirstChild("RightGrip")
					if joint~=nil and (joint.Part0==sp.Handle or joint.Part1==sp.Handle) then
						local t=hit.Parent:FindFirstChild("Torso")
						if hit.Name=="Left Arm" and t~=nil then
							local ls=t:FindFirstChild("Left Shoulder")
							if ls then
								if ls.Part0==hit or ls.Part1==hit then
									local la=hit
									local takearm=true
									local aw=sp.Handle:FindFirstChild("LeftArmWeld")
									if aw~=nil then
										if aw.Part1~=nil and aw.Part1.Parent~=nil then
											takearm=false
										else
											aw:remove()
										end
									end
									if takearm then
										la:BreakJoints()
										local w=Instance.new("Motor")
										w.Name="LeftArmWeld"
										w.MaxVelocity=.4
										w.Part0=sp.Handle
										w.Part1=la
										w.C0=basearmhold
										w.C1=CFrame.new(0,.8,0)
										w.Parent=sp.Handle
										la.Touched:connect(function(hit2)
											blow(la,hit2)
										end)
										sp.RunAnim.Value="OverHeadSwing"
										UnsheathSound:play()
									end
								end
							end
						end
						tagHumanoid(humanoid,vPlayer)
						damage=basedamage
						if not sp.Enabled then
							if weapon~=sp.Handle then
								damage=armdamage
							else
								damage=beardamage
							end
						end
						humanoid:TakeDamage(damage)
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

sp.Enabled=true
function onActivated()
	if sp.Enabled and not sp.Taunting.Value then
		sp.Enabled=false
		local character=sp.Parent;
		local humanoid=character.Humanoid
		if humanoid==nil then
			return 
		end
		SlashSound:play()
		newanim=anims[math.random(1,#anims)]
		while newanim==sp.RunAnim.Value do
			newanim=anims[math.random(1,#anims)]
		end
		sp.RunAnim.Value=newanim
		local aw=sp.Handle:FindFirstChild("LeftArmWeld")
		if aw~=nil then
			aw.DesiredAngle=-.5
			if newanim=="LeftSlash" then
				aw.C0=basearmhold*CFrame.Angles(-.3,0,0)
			elseif newanim=="RightSlash" then
				aw.C0=basearmhold*CFrame.Angles(.3,0,0)
			end
		end
		wait(.5)
		local aw=sp.Handle:FindFirstChild("LeftArmWeld")
		if aw~=nil then
			aw.DesiredAngle=1
		end
		wait(.5)
		local aw=sp.Handle:FindFirstChild("LeftArmWeld")
		if aw~=nil then
			aw.DesiredAngle=0
			aw.C0=basearmhold
		end
		sp.Enabled=true
	end
end

function onEquipped()
	UnsheathSound:play()
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)

sp.Handle.Touched:connect(function(hit)
	blow(sp.Handle,hit)
end)


