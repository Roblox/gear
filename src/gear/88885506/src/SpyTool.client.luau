--Edited by QS
local height = 300
local zoomLevels = 7

local spyTool = script.Parent
local spyHandle = spyTool.Handle
local vChar
local Torso, Head
local RightArm
local Weld 
local equipAnim
local theCam
local satellitePosition
local camPartCopy
local zoom = 0

local camPart = Instance.new("Part")
camPart.Anchored = true
camPart.Transparency = 1
camPart.CanCollide = false

function castRay(startpos,vec,length,ignore)
	local hit,endpos2 = game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	return hit, endpos2
end

function activateSatellite(mouse)
	local notfound = true
	if spyTool:FindFirstChild("Sound") then
		spyTool.Sound:Play()
	end
	if not theCam then
		--first activation create the camerea
		theCam = game.Workspace.CurrentCamera
		print(theCam.CameraType)
		local startVector = ((theCam.CoordinateFrame.p - Head.CFrame.p)*Vector3.new(1,0,1)).unit
		satellitePosition = Head.Position + Vector3.new(0,height,0) - startVector*60
		zoom = 0
		if Head then
			camPartCopy = spyTool.Handle:Clone()
			camPartCopy.Mesh.Scale = Vector3.new(1,1,1)
			camPartCopy.Anchored = false
			camPartCopy.CanCollide = false
			local bv = Instance.new("BodyVelocity")
			--camPartCopy.CFrame = CFrame.Angles(0,0,math.pi/2) * camPartCopy.CFrame 
			bv.Parent = camPartCopy
			bv.velocity = Vector3.new(0,70,0)
			delay(4.5, function() 
				if bv and camPartCopy then 
					bv:Destroy() 
					camPartCopy.Anchored = true  --Anchor it in the sky after it flies for a bit.  
				end 
			end)
			--camPartCopy.CFrame = CFrame.new(satellitePosition)
			camPartCopy.Parent = Head  --Descendant of character so it dies if player dies
			game:GetService("Debris"):AddItem(camPartCopy,60)
			theCam.CameraType = "Track"
			theCam.CameraSubject = camPartCopy
			
			--theCam.CoordinateFrame = CFrame.new(satellitePosition + Vector3.new(0,50,0) - startVector*15, satellitePosition)
			--theCam.Focus = CFrame.new(satellitePosition)
			theCam.FieldOfView = 80
		end
	else
		--Clicked so zoom in on click
		if mouse and satellitePosition then
			theCam.CameraType = "Scriptable"
			if zoom < zoomLevels then
				zoom = zoom +1
			end
			local lookTarget = mouse.Hit
			if camPartCopy then satellitePosition = camPartCopy.Position end
			local hit, endpos = castRay(satellitePosition, (lookTarget.p-satellitePosition).unit, height+75, spyTool)
			if not hit then endpos = mouse.Hit.p end
			local lookVec = (endpos - satellitePosition)
			local zoomDistance = math.min((zoom-.5) * 27, lookVec.magnitude - 40) --Must be at least 40 studs away from target
			local zoomPosition = satellitePosition + lookVec.unit * zoomDistance
			theCam.Focus = CFrame.new(endpos)

			local camPartCopy = camPart:Clone()
			camPartCopy.CFrame = lookTarget
			--game:GetService("Debris"):AddItem(camPartCopy,5)
			theCam.CameraSubject = camPartCopy
			theCam.FieldOfView = 70 - (zoom/zoomLevels * 50)

			theCam.CoordinateFrame = CFrame.new(zoomPosition, endpos)
		end
	end
end

function resetCamera()
	if theCam then 
		theCam.CameraType = "Custom"
		vChar = spyTool.Parent
		if vChar and vChar:FindFirstChild("Humanoid") then
			theCam.CameraSubject = vChar.Humanoid
		end
		if camPartCopy then camPartCopy:Destroy() end
		theCam.FieldOfView = 70.000000488294
		--theCam:Destroy()
		theCam = nil
	end
end

function onEquipped(mouse)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	vChar = spyTool.Parent
	Torso = vChar:FindFirstChild("Torso")
	Head = vChar:FindFirstChild("Head")
	RightArm = vChar:FindFirstChild("Right Arm")
	local Humanoid = vChar:FindFirstChild("Humanoid")

	local cam = game.Workspace.CurrentCamera
	mouse.Button1Down:connect(function() activateSatellite(mouse) end)

	mouse.KeyDown:connect(function(key)
		key = string.lower(key)
		if key == "x" then
			resetCamera()
		end
	end)

end

function onUnequipped()
	resetCamera()
	equipAnim:Stop()
end



spyTool.Equipped:connect(onEquipped)
spyTool.Unequipped:connect(onUnequipped)