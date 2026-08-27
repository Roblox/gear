--Stickmasterluke


sp=script.Parent
exploded=false
stuffhit={}

time=5
damage=100
radius=19
pressure=-100



function applyvelocity(center,part)
	if part~=nil then
		local dist=(center-part.Position).magnitude
		local vec=(part.Position-center).unit
		part.Velocity=part.Velocity+((vec*pressure))		--possibly incorperate distance for less velocity
	end
end

function checkalreadyhit(object)
	for i2,v2 in ipairs(stuffhit) do
		if v2==object then
			return true
		end
	end
end



function explode()
	if not exploded then
		exploded=true
		local sound=Instance.new("Sound")
		sound.SoundId="rbxasset://sounds\\Rocket shot.wav"
		sound.Parent=sp
		sound.Volume=1
		sound.Pitch=2
		sound:play()
		pos=sp.Position
		sp.Transparency=1
		delay(0,function()
			local p=Instance.new("Part")
			p.Name="Effect"
			p.TopSurface="Smooth"
			p.BottomSurface="Smooth"
			p.Anchored=true
			p.CanCollide=false
			p.BrickColor=BrickColor.new("Toothpaste")
			p.FormFactor="Custom"
			p.Size=Vector3.new(.2,.2,.2)
			p.CFrame=CFrame.new(pos)
			local m=Instance.new("SpecialMesh")
			m.MeshType="Sphere"
			m.Scale=Vector3.new(1,1,1)*radius*5*2
			m.Parent=p
			p.Parent=game.Workspace
			local rate=.033
			local frames=math.floor(.5/rate)
			for frame=1,frames do
				local percent=frame/frames
				if m~=nil then
					m.Scale=Vector3.new(1,1,1)*radius*2*5*(1-percent)
				end
				if p~=nil then
					p.Transparency=1-percent
				end
				wait(rate)
			end
			if p~=nil then
				p:remove()
			end
			sp.Parent=nil
		end)
		hits=game.Workspace:FindPartsInRegion3(Region3.new(pos-Vector3.new(radius,radius,radius),pos+Vector3.new(radius,radius,radius)),sp,100)
		for i,v in ipairs(hits) do
			if v.Anchored==false and v.Name~="Handle" then
				h=v.Parent:FindFirstChild("Humanoid")
				if h~=nil then
					local plr=game.Players:GetPlayerFromCharacter(v.Parent)
					local tag=sp:FindFirstChild("creator")
					if plr~=nil and tag~=nil then
						if plr~=sp.creator.Value then
							table.insert(stuffhit,v.Parent)
							for _,v in ipairs(h:GetChildren()) do
								if v.Name=="creator" then
									v:remove()
								end
							end
							tag:clone().Parent=h
							if h.Health<=damage then
								h.Health=0
								h.Parent:BreakJoints()
								for i3,v3 in ipairs(v.Parent:GetChildren()) do
									if v3.className=="Part" then
										applyvelocity(pos,v3)
									end
								end
							else
								h.Health=h.Health-damage
							end
						end
					else
						if not checkalreadyhit(v.Parent) then
							table.insert(stuffhit,v.Parent)
							if tag then
								for _,v in ipairs(h:GetChildren()) do
									if v.Name=="creator" then
										v:remove()
									end
								end
								tag:clone().Parent=h
							end
							if h.Health<=damage then
								h.Health=0
								h.Parent:BreakJoints()
								for i3,v3 in ipairs(v.Parent:GetChildren()) do
									if v3.className=="Part" then
										applyvelocity(pos,v3)
									end
								end
							else
								h.Health=h.Health-damage
							end
						end
					end
				else
					v:BreakJoints()
					v.CFrame=v.CFrame+Vector3.new(0,.1,0)
					applyvelocity(pos,v)
				end
			end
		end
	end
end

function playsound(pitch)
	pitch=pitch or 1
	local s=sp:FindFirstChild("BeepTone")
	if s~=nil then
		s.Pitch=pitch
		s:Play()
	end
end

for i=1,time-1 do
	wait(1)
	playsound(1.5)
end
wait(1)
playsound(2)
local sound2=Instance.new("Sound")
sound2.SoundId="http://www.roblox.com/asset/?id=75992638"
sound2.Parent=sp
sound2.Volume=1
sound2.Pitch=3
sound2:play()
wait(.1)
playsound(2)
wait(.1)
playsound(2)
wait(.5)
explode()
sp.CanCollide=false
sp.Anchored=true
sp.Transparency=1
wait(2)
sp:remove()




