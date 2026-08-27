--Stickmasterluke


local sp=script.Parent
local sword=sp.Handle
local debris=game:GetService("Debris")


cooldown=10

enabled=true
lastlunge=tick()
lastwdown=tick()

local LungeSound=Instance.new("Sound")
LungeSound.SoundId="rbxasset://sounds\\swordlunge.wav"
LungeSound.Parent=sword
LungeSound.Volume=.6

function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled=false
	mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
	wait(.5)
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	enabled=true
end

function swordUp()
	sp.GripForward=Vector3.new(-1,0,0)
	sp.GripRight=Vector3.new(0,-1,0)
	sp.GripUp=Vector3.new(0,0,1)
end

function swordOut()
	sp.GripForward=Vector3.new(0,0,-1)
	sp.GripRight=Vector3.new(0,-1,0)
	sp.GripUp=Vector3.new(-1,0,0)
end

function recursive(a)
	if a~=nil then
		if a.className=="Part" then
			a.Material="Foil"
			a.BrickColor=BrickColor.new("Bright yellow")
			a.Anchored=true
		elseif a.className=="Decal" or a.className=="Hat" or a.className=="Mesh" or a.className=="CharacterMesh" then
			if a.Parent.Name~="Head" then
				a:remove()
			end
		end
		if a and a~=nil and a.Parent~=nil then
			for i,v in ipairs(a:GetChildren()) do
				recursive(v)
			end
		end
	end
end

function onEquippedLocal(mouse)
	lastequipped=tick()
	local currentlast=lastequipped
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		onButton1Down(mouse)
	end)
	mouse.KeyDown:connect(function(key)
		key=string.lower(key)
		if key=="w" then
			if tick()-lastwdown<.2 and sword.Sparkles.Enabled then
				local h=sp.Parent:FindFirstChild("Humanoid")
				local t=sp.Parent:FindFirstChild("Torso")
				stabanim=h:LoadAnimation(sp:FindFirstChild("Stab2"))
				if t and h and stabanim and h.Health>0 then
					sword.Sparkles.Enabled=false
					stabanim:Play()
					LungeSound:Play()
					lastlunge=tick()
					local mp=Instance.new("Part")
					mp.formFactor="Symmetric"
					mp.Size=Vector3.new(2,2,2)
					mp.CanCollide=false
					mp.Transparency=1
					local sprkl=Instance.new("Sparkles")
					sprkl.SparkleColor=Color3.new(204/255,204/255,0)
					sprkl.Parent=mp
					local bf=Instance.new("BodyForce")
					bf.force=Vector3.new(0,mp:GetMass()*196.2,0)
					bf.Parent=mp
					mp.CFrame=sword.CFrame+Vector3.new(0,-2,0)
					mp.Velocity=t.CFrame.lookVector*25
					debris:addItem(mp,2)
					mp.Touched:connect(function(hit)
						if hit~=nil and hit.Parent~=nil then
							local eh=hit.Parent:FindFirstChild("Humanoid")
							local h=sp.Parent:FindFirstChild("Humanoid")
							if eh~=nil and h~=nil and eh~=h then
								eh:TakeDamage(100)
								if eh.Health<=0 then
									recursive(hit.Parent)
								end
							end
						end
					end)
					mp.Parent=game.Workspace
					wait(.25)
					swordOut()
					wait(.5)
					swordUp()
					wait(1.25)
					if mp and mp~=nil and mp.Parent~=nil then
						mp:remove()
					end
					wait(cooldown-2)
					sword.Sparkles.Enabled=true
				end
			end
			lastwdown=tick()
		end
	end)
	sword.Sparkles.Enabled=false
	wait(cooldown)
	if currentlast==lastequipped then
		sword.Sparkles.Enabled=true
	end
end
sp.Equipped:connect(onEquippedLocal)

sp.Runslash.Changed:connect(function()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	slashanim=h:LoadAnimation(sp:FindFirstChild("SimpleSlash6"))
	if t and h and slashanim and h.Health>0 then
		slashanim:Play()
	end
end)

sword.Sparkles.Enabled=false
