--Stickmasterluke
--A nice simple sword


sp=script.Parent


r=game:service("RunService")
debris=game:GetService("Debris")
check=true

anims={"RightSlash","LeftSlash","OverHeadSwing"}

basedamage=2
slashdamage=14
swingdamage=18
cooldown=.7
damage=basedamage

function waitfor(parent,name)
	print("Waiting for",name)
	while parent:FindFirstChild(name)==nil do
		parent.ChildAdded:wait()
	end
	print("Found",name)
	return parent:FindFirstChild(name)
end

sword=waitfor(sp,"Handle")
sparkles=waitfor(sword,"Sparkles")
waitfor(sp,"Taunting")
waitfor(sp,"RunAnim")
waitfor(sp,"AnimToRun")
waitfor(sp,"MouseSide")
SlashSound=waitfor(sword,"SlashSound")
UnsheathSound=waitfor(sword,"UnsheathSound")
ClashSound=waitfor(sword,"ClashSound")
sp.Taunting.Value=false

function blow(hit)
	if hit.Parent~=nil then
		local humanoid=hit.Parent:findFirstChild("Humanoid")
		local vCharacter=sp.Parent
		local vPlayer=game.Players:playerFromCharacter(vCharacter)
		local hum=vCharacter:findFirstChild("Humanoid")
		if humanoid~=nil then
			if hum~=nil and humanoid~=hum and hum.Health>0 and humanoid.Health>0 then
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
		elseif hit.Parent.className=="Tool" and clashdebounce then
			clashdebounce=false
			sparkles.Enabled=true
			ClashSound.Pitch=.75+(math.random()*.5)
			ClashSound:Play()
			wait(.3)
			sparkles.Enabled=false
			clashdebounce=true
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

check=true
function onActivated()
	if check and not sp.Taunting.Value then
		check=false
		local character=sp.Parent;
		local humanoid=character.Humanoid
		if humanoid==nil then
			print("Humanoid not found")
			return 
		end
		SlashSound:play()
		local newanim=(sp.MouseSide.Value=="Left" and "LeftSlash") or (sp.MouseSide.Value=="Center" and "OverHeadSwing") or "RightSlash"
		sp.AnimToRun.Value=newanim
		wait()
		sp.RunAnim.Value=not sp.RunAnim.Value
		if newanim=="OverHeadSwing" then
			damage=swingdamage
		else
			damage=slashdamage
		end
		wait(cooldown)
		damage=basedamage
		if newanim=="OverHeadSwing" then
			wait(.4)
		end
		check=true
	end
end

function onEquipped()
	UnsheathSound:play()
	sparkles.Enabled=false
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)

connection=sword.Touched:connect(blow)


