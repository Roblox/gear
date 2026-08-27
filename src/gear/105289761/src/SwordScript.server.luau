--Stickmasterluke


sp=script.Parent


r=game:service("RunService")
debris=game:GetService("Debris")

basedamage=1
fulldamage=9
lastattack=0


function waitfor(parent,name)
	while true do
		local child=parent:FindFirstChild(name)
		if child~=nil then
			return child
		end
		wait()
	end
end

UnsheathSound=waitfor(sp.Handle,"GrowlSound1")
waitfor(sp,"RunAnim")

function blow(hit,claw)
	if hit.Parent~=nil and claw~=nil then
		local humanoid=hit.Parent:findFirstChild("Humanoid")
		local vCharacter=sp.Parent
		if vCharacter~=nil and humanoid then
			local vPlayer=game.Players:playerFromCharacter(vCharacter)
			if vPlayer~=nil then
				local hum=vCharacter:findFirstChild("Humanoid")
				if hum~=nil and humanoid~=hum and hum.Health>0 then
					local right_arm=vCharacter:FindFirstChild("Right Arm")
					if right_arm~=nil then
						local joint=right_arm:FindFirstChild("RightGrip")
						if joint~=nil and (joint.Part0==sp.Handle or joint.Part1==sp.Handle) then
							tagHumanoid(humanoid,vPlayer)
							if tick()-lastattack<=1 then
								humanoid:TakeDamage(fulldamage)
							else
								humanoid:TakeDamage(basedamage)
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

sp.Enabled=true
function onActivated()
	local h=sp.Parent:FindFirstChild("Humanoid")
	if h~=nil and h.Health>0 and sp.Enabled then
		sp.Enabled=false
		sp.RunAnim.Value=not sp.RunAnim.Value
		lastattack=tick()
		local sound=sp.Handle:FindFirstChild("GrowlSound"..tostring(math.random(1,2)))
		if sound then
			sound.Pitch=.75+(math.random()*.5)
			sound:Play()
		end
		h.WalkSpeed=26
		wait(.75)
		if h~=nil then
			h.WalkSpeed=8
		end
		wait(.25)
		if h~=nil then
			h.WalkSpeed=16
		end
		sp.Enabled=true
	end
end

function onEquipped()
	UnsheathSound:play()
	delay(0,function()
		if lefthand~=nil then
			lefthand:remove()
			lefthand=nil
		end
		for i,v in ipairs(sp:GetChildren()) do
			if v~=nil and v.Name=="Effect" and v~=leftarm then
				v:remove()
			end
		end
		local leftarm=sp.Parent:FindFirstChild("Left Arm")
		if leftarm~=nil then
			lefthand=sp.Handle:clone()
			local mesh=lefthand:FindFirstChild("Mesh")
			for i,v in ipairs(lefthand:GetChildren()) do
				if v.className~="SpecialMesh" then
					v:remove()
				end
			end
			lefthand.Name="Effect"
			lefthand.CanCollide=false
			local w=Instance.new("Weld")
			w.Part0=leftarm
			w.Part1=lefthand
			w.C0=CFrame.new(-.2,-1.4,0)*CFrame.Angles(-math.pi/2,0,math.pi/2)
			w.Parent=lefthand
			lefthand.Touched:connect(function(hit)
				blow(hit,lefthand)
			end)
			lefthand.Parent=sp
		end
	end)
end

function onUnequipped()
	delay(0,function()
		if lefthand~=nil then
			lefthand:remove()
			lefthand=nil
		end
	end)
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

connection=sp.Handle.Touched:connect(function(hit)
	blow(hit,sp.Handle)
end)


