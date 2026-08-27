--Stickmasterluke


local sp=script.Parent
local Backpack = sp.Handle



rate=1/30

equipped=false
check=true
debris=game:GetService("Debris")


while sp.Handle:FindFirstChild("Motor")==nil do 
	wait()
end
local storeWeld=sp.Handle.Motor

local HoseSound  


function playsound(soundname)
	if soundname and sp:FindFirstChild("SoundScript")~=nil then
		local soundtag=Instance.new("StringValue")
		soundtag.Name=soundname
		soundtag.Parent=sp.SoundScript
	end
end

function setwelds()
	if storeWeld then
		storeWeld.Parent=sp.Handle
	end
	if equipped then
		local ra=sp.Parent:FindFirstChild("Right Arm")
		local t=sp.Parent:FindFirstChild("Torso")
		if ra~=nil and t~=nil then
			local rg=ra:FindFirstChild("RightGrip")
			if rg~=nil then
				rg.Part0=t
				rg.C0=CFrame.new(0,0,1)*CFrame.Angles(-math.pi/2,0,0)
				rg.C1=CFrame.new(0,0,0)
			end
		end
	end
end

function spraypart()
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		local p=Instance.new("Part")
		p.formFactor="Custom"
		p.TopSurface="Smooth"
		p.BottomSurface="Smooth"
		if plr.MembershipType==Enum.MembershipType.OutrageousBuildersClub then
			p.BrickColor=BrickColor.new("New Yeller")
			p.Material="Foil"
			p.Size=Vector3.new(2,.6,.8)
		elseif plr.MembershipType==Enum.MembershipType.TurboBuildersClub then
			p.BrickColor=BrickColor.new("Dark green")
			p.Size=Vector3.new(1.56,.2,.66)
			local d=Instance.new("Decal")
			d.Face="Top"
			d.Texture="http://www.roblox.com/asset/?id=16658163"
			d.Parent=p
			local d=Instance.new("Decal")
			d.Face="Bottom"
			d.Texture="http://www.roblox.com/asset/?id=16658163"
			d.Parent=p
		elseif plr.MembershipType==Enum.MembershipType.BuildersClub then
			p.BrickColor=BrickColor.new("Dark green")
			p.Size=Vector3.new(1.56,.2,.66)
			local d=Instance.new("Decal")
			d.Face="Top"
			d.Texture="http://www.roblox.com/asset/?id=16658163"
			d.Parent=p
			local d=Instance.new("Decal")
			d.Face="Bottom"
			d.Texture="http://www.roblox.com/asset/?id=16658163"
			d.Parent=p
		else
			p.BrickColor=BrickColor.new("Bright yellow")
			p.Size=Vector3.new(1,.2,.6)
			local d=Instance.new("Decal")
			d.Face="Top"
			d.Texture="http://www.roblox.com/asset/?id=8057767"
			d.Parent=p
			local d=Instance.new("Decal")
			d.Face="Bottom"
			d.Texture="http://www.roblox.com/asset/?id=8057767"
			d.Parent=p
		end
		p.Velocity=((sp.Handle.HosePart.CFrame*CFrame.Angles(-math.pi/2,0,0)).lookVector*60)+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*10)
		p.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*10
		p.CFrame=sp.Handle.HosePart.CFrame*CFrame.new(1,-3,1.5)*CFrame.new((math.random()-.5),(math.random()-.5),(math.random()-.5))*CFrame.Angles(0,0,math.pi/2)
		debris:AddItem(p,30)
		p.Parent=game.Workspace
	end
end

function onEquipped(mouse)
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	equipped=true
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		if check and equipped then			
			check=false
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			local h=sp.Parent:FindFirstChild("Humanoid")
			local t=sp.Parent:FindFirstChild("Torso")
			local ra=sp.Parent:FindFirstChild("Right Arm")
			if t and h then
				if h.Health>0 then
					HoseSound = Backpack:FindFirstChild("HoseSound")
					if HoseSound then HoseSound:Play() end 
					--theanim:Play()
					playsound("Spray")
					if storeWeld then
						storeWeld.DesiredAngle=-.5
					end
					for i= 1, 10 do
						spraypart()
						wait(0.1)
					end
					if storeWeld then
						storeWeld.DesiredAngle=0
					end
					wait(2)
				end
			end
			mouse.Icon="rbxasset://textures\\GunCursor.png"
			check=true
		end
	end)
	setwelds()
end

function onUnequipped()
	equipped=false
	if HoseSound then HoseSound:Stop() end 
end


sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
setwelds()


