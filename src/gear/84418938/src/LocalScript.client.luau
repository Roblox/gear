--Stickmasterluke
--Altered by QuantumSama


local Tool=script.Parent
local Backpack = Tool.Handle

rate=1/30

equipped=false
check=true
debris=game:GetService("Debris")


while Tool.Handle:FindFirstChild("Motor")==nil do 
	wait()
end
local storeWeld=Tool.Handle.Motor

local HoseSound  


function playsound(soundname)
	if soundname and Tool:FindFirstChild("SoundScript")~=nil then
		local soundtag=Instance.new("StringValue")
		soundtag.Name=soundname
		soundtag.Parent=Tool.SoundScript
	end
end

function setwelds()
	if storeWeld then
		storeWeld.Parent=Tool.Handle
	end
	if equipped then
		local ra=Tool.Parent:FindFirstChild("Right Arm")
		local t=Tool.Parent:FindFirstChild("Torso")
		if ra~=nil and t~=nil then
			local rightgrip=ra:FindFirstChild("RightGrip")
			if rightgrip~=nil then
				rightgrip.Part0=t
				rightgrip.C0=CFrame.new(0,0,1)*CFrame.Angles(0,0,math.pi)
				rightgrip.C1=CFrame.new(0,0,0)
			end
		end
	end
end

function doSuck()
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		local radiusVec = Vector3.new(6,6,6)
		local handle = Tool:FindFirstChild("Handle")
		local hose = handle:FindFirstChild("HosePart")
		local hoseCFrame = hose.CFrame*CFrame.Angles(math.pi/2,0,0)
		local hoseTarget = hoseCFrame + hoseCFrame.lookVector*9
		local suckTarget = hoseCFrame + hoseCFrame.lookVector*3
		local suckPart = Instance.new("Part")
		suckPart.CanCollide = false
		suckPart.FormFactor = "Custom"
		--suckPart.Shape = "Ball"
		suckPart.Size = Vector3.new(.2,.2,.2)
		suckPart.CFrame = hoseTarget + Vector3.new((math.random()-.5)*10,(math.random()-.5)*10,(math.random()-.5)*10)
		suckPart2 = suckPart:Clone()
		suckPart2.CFrame = hoseTarget + Vector3.new((math.random()-.5)*10,(math.random()-.5)*10,(math.random()-.5)*10)
		debris:AddItem(suckPart,3)
		debris:AddItem(suckPart2,3)
		suckPart.Parent = game.Workspace
		suckPart2.Parent = game.Workspace

		local suckRegion = Region3.new(hoseTarget.p - radiusVec, hoseTarget.p + radiusVec)

		local suckableParts = game.Workspace:FindPartsInRegion3(suckRegion, Tool.Parent,50)

		local limbChance = .075
		for i,v in pairs(suckableParts) do
			if v and v.Parent and v:IsA("BasePart") and not v:IsA("Terrain") and v:getMass() < 40 and not v:FindFirstChild("bp") then
				local bp = Instance.new("BodyPosition")
				bp.Name = "bp"
				bp.maxForce = Vector3.new(99999,99999,99999)
				bp.D = 3000
				bp.P = 30000
				bp.position = suckTarget.p
				debris:AddItem(bp,.5)
				local hum = v.Parent:FindFirstChild("Humanoid")
				if hum then
					if math.random() < limbChance or hum.Health == 0 then
						local creatorTag = Instance.new("ObjectValue")
						creatorTag.Value = plr
						creatorTag.Name = "creator"
						debris:AddItem(creatorTag,.5)
						creatorTag.Parent = hum

						v:BreakJoints()
						bp.Parent = v
						debris:AddItem(v,.15)
					end
				else
					bp.Parent = v
					if not v.Parent:IsA("Tool") then
						delay(0,function()
							local pos = v.Position
							wait(.15)
							if (pos-v.Position).magnitude > .1 then
								v:Destroy()
							end
						end)
					end
				end
			end
		end
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
			local hum=Tool.Parent:FindFirstChild("Humanoid")
			local torso=Tool.Parent:FindFirstChild("Torso")
			--local rightArm=Tool.Parent:FindFirstChild("Right Arm")
			if torso and hum then
				if hum.Health>0 then
					HoseSound = Backpack:FindFirstChild("HoseSound")
					if HoseSound then HoseSound:Play() end 
					--theanim:Play()
					playsound("Spray")
					if storeWeld then
						storeWeld.DesiredAngle=-.5
					end
					local frames = 10
					for i = 1, frames do
						if not equipped then break end
						doSuck()
						wait(.2)
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


Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
setwelds()


