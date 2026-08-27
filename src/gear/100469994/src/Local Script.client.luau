--Stickmasterluke


local sp=script.Parent
local sword=sp.Handle


damage=9
anims={"RightSlash","LeftSlash","OverHeadSwing"}
rate=1/30


equipped=false
check=true
lastanim=""
pauldrons={}



function swordUp()
	sp.Grip=CFrame.new(0,-1,0)
end

function swordOut()
	sp.Grip=CFrame.new(0,-1,0)*CFrame.Angles(.5,0,.3)
end

function playsound(soundname)
	local sound=sp.Handle:FindFirstChild(soundname)
	if sound~=nil then
		sound:Play()
	end
end

function lunge()
	local t=sp.Parent:FindFirstChild("Torso")
	local h=sp.Parent:FindFirstChild("Humanoid")
	if t and h and equipped then
		local target=h.TargetPoint
		local direction=(target-t.Position)*Vector3.new(1,0,1)
		if direction.magnitude>.01 then
			direction=direction.unit
			local newBV=Instance.new("BodyVelocity")
			newBV.P=100000
			newBV.maxForce=Vector3.new(newBV.P,0,newBV.P)
			newBV.velocity=direction*100
			newBV.Parent=t
			t.CFrame=CFrame.new(t.Position,target*Vector3.new(1,0,1)+Vector3.new(0,t.Position.Y,0))
			playsound("FlashSound")
			wait(.25)
			if newBV~=nil then
				newBV:remove()
			end
		end
	end
end

function blow(hit)
	if (hit.Parent==nil) then return end -- happens when bullet hits sword
	local humanoid=hit.Parent:findFirstChild("Humanoid")
	local vCharacter=sp.Parent
	local vPlayer=game.Players:playerFromCharacter(vCharacter)
	local hum=vCharacter:findFirstChild("Humanoid") -- non-nil if sp held by a character
	if humanoid~=nil and humanoid~=hum and hum~=nil and hum.Health>0 then
		-- final check, make sure sword is in-hand
		local right_arm=vCharacter:FindFirstChild("Right Arm")
		if (right_arm~=nil) then
			local joint=right_arm:FindFirstChild("RightGrip")
			if (joint~=nil and (joint.Part0==sword or joint.Part1==sword)) then
				for _,v in pairs(humanoid:GetChildren()) do
					if v~=nil and v.Name=="creator" then
						v:remove()
					end
				end
				local creator_tag=Instance.new("ObjectValue")
				creator_tag.Value=vPlayer
				creator_tag.Name="creator"
				creator_tag.Parent=humanoid
				humanoid:TakeDamage(damage)
			end
		end
	end
end

function createpauldrons()
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		local chr=plr.Character
		if chr~=nil then
			for _,v in pairs(chr:GetChildren()) do
				if v~=nil and v.Name=="Pauldrons" then
					v:remove()
				end
			end
			local t=chr:FindFirstChild("Torso")
			if t~=nil then
				local p=Instance.new("Part")
				p.Name="Pauldrons"
				p.FormFactor="Custom"
				p.Size=Vector3.new(4.5,1.2,1.8)
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.CanCollide=false
				p.Locked=true
				local w=Instance.new("Weld")
				w.C0=CFrame.new(0,1.2,0)
				w.C1=CFrame.new(0,0,0)
				w.Part0=t
				w.Part1=p
				w.Parent=p
				local m=Instance.new("SpecialMesh")
				m.Scale=Vector3.new(.9,.9,.9)
				m.MeshId="http://www.roblox.com/asset/?id=100459791"
				m.TextureId="http://www.roblox.com/asset/?id=100458698"
				m.Parent=p
				table.insert(pauldrons,p)
				p.Parent=chr
				p.Touched:connect(blow)
			end
		end
	end
end

function onEquipped(mouse)
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	lastmove=tick()
	equipped=true
	swordUp()
	local plr=game.Players.LocalPlayer
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		if check and equipped then
			check=false
			newanim=anims[math.random(1,#anims)]
			while newanim==lastanim do
				newanim=anims[math.random(1,#anims)]
			end
			lastanim=newanim
			local h=sp.Parent:FindFirstChild("Humanoid")
			local t=sp.Parent:FindFirstChild("Torso")
			local anim=sp:FindFirstChild(newanim)
			if t and h and anim then
				theanim=h:LoadAnimation(anim)
				if theanim and h.Health>0 then
					playsound("SlashSound")
					theanim:Play()
					if newanim=="OverHeadSwing" then
						wait(.25)
						swordOut()
						wait(.4)
						swordUp()
					else
						wait(.5)
					end
					lastmove=tick()
				end
			end
			check=true
		end
	end)
	delay(.01,createpauldrons)
end

function onUnequipped()
	equipped=false
	delay(.01,function()
		for _,v in pairs(pauldrons) do
			if v~=nil then
				v:remove()
			end
		end
	end)
end


sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
sword.Touched:connect(blow)


