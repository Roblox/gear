-- First Plushie! 

-- Needed for calculating time
-- r = game:service("RunService")

-- Store the Tool information 
local Tool = script.Parent

-- Variable for making sure our function is entered only once during a particular instance
enabled = true
local sitting_on_character = false

--Terrible failed experiment

--local glasses=Instance.new("Part",workspace)
--glasses.Locked = true
--glasses.BackSurface = 3
--glasses.BottomSurface = 3
--glasses.FrontSurface = 3
--glasses.LeftSurface = 3
--glasses.RightSurface = 3
--glasses.TopSurface = 3
--glasses.Size = Vector3.new(1, 2.5, 1)
--glasses.BrickColor = BrickColor.new(23)
--glasses.FormFactor = 3
--glasses.CanCollide = false
--glasses.Anchored = true
--glasses.Transparency= 1

--local glassesMesh = Instance.new("SpecialMesh")

--glassesMesh.MeshId = "http://www.roblox.com/asset/?id=51177557"
--glassesMesh.TextureId = "http://www.roblox.com/asset/?id=51177552"
--glassesMesh.Parent=glasses
--glassesMesh.Offset= Vector3.new(0,0,10)
math.randomseed(tick())
-- Sounds

local onSit = Instance.new("Sound")
onSit.SoundId = "http://www.roblox.com/asset/?id=85452270"
onSit.Parent = Tool.Handle

local onSitAlt = Instance.new("Sound")
onSitAlt.SoundId = "http://www.roblox.com/asset/?id=85462695"
onSitAlt.Parent = Tool.Handle

local all_sounds = {onSit,onSitAlt}

local ani_time=2.0

--local glasses=nil

-- Three functions for onActivate, onEquip and onUnEquip

function onActivated()

	-- Need to do this particular check, so that it disables multiple instances of this function getting activated
	if not enabled then return
	end
	-- If the above constraint fails, then lock it
	-- This lock is tentative since during multithreading there is still a chance for there to be multiple instances of this function
	enabled = false	
	
	-- Check to see if the robot is sitting on the character
	if not sitting_on_character then
		sitting_on_character = true	
		--Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=45450768"	
		--Tool.GripForward = Vector3.new(0, -1, 0)
		--Tool.GripRight = Vector3.new(1, 0, 0)
		--Tool.GripUp = Vector3.new(0, 0, -1)
		Tool.GripPos = Vector3.new(-1.0, 2.8, -1.0)
		local cam=game.Workspace.CurrentCamera
		game.Workspace.CurrentCamera.CameraSubject=Tool.Handle
		local cam_start=Vector3.new(game.Workspace.CurrentCamera.CoordinateFrame.x,game.Workspace.CurrentCamera.CoordinateFrame.y,game.Workspace.CurrentCamera.CoordinateFrame.z)
		cam.CameraType="Custom"
		local cam_final= Vector3.new(Tool.Handle.CFrame.x+(Tool.Handle.CFrame.lookVector.x*3),Tool.Handle.CFrame.y+(Tool.Handle.CFrame.lookVector.y*3),Tool.Handle.CFrame.z+(Tool.Handle.CFrame.lookVector.z*3))
		local start_time=time();
		while time()-start_time<ani_time do
			cam.CoordinateFrame=CFrame.new(cam_start:Lerp(cam_final,(time()-start_time)/ani_time))
			wait()
		end
		--local rotvec=CFrame.Angles(0, 3.14/2.0, 0)
		--Tool.Handle.CFrame=CFrame.new(Vector3.new(Tool.Handle.CFrame.x+(Tool.Handle.CFrame.lookVector.x*1),Tool.Handle.CFrame.y+(Tool.Handle.CFrame.lookVector.y*1),Tool.Handle.CFrame.z+(Tool.Handle.CFrame.lookVector.z*1)))
		--glasses.CFrame=CFrame.new(Vector3.new(Tool.Handle.CFrame.x+(Tool.Handle.CFrame.lookVector.x*1.0),Tool.Handle.CFrame.y+(Tool.Handle.CFrame.lookVector.y*1.2),Tool.Handle.CFrame.z+(Tool.Handle.CFrame.lookVector.z*1.0)),-1.0*Tool.Handle.CFrame.lookVector)
		--glasses.CFrame=Tool.Handle.CFrame
		--glasses.Transparency= 0
		--glasses
		if math.random(1,10)==1 then
			onSit:Play()
			print("alt played!")
		else
			onSitAlt:Play()
		end
		wait(2)	

	else 
		game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
		game.Workspace.CurrentCamera.CameraType = "Custom"
		sitting_on_character = false
		--Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=45450798"
		--Tool.GripForward = Vector3.new(0, -1, 0)
		--Tool.GripRight = Vector3.new(-1, 0, 0)
		--Tool.GripUp = Vector3.new(0, 0, 1)
		--Tool.GripForward = Vector3.new(0, -1, 0)
		Tool.GripPos = Vector3.new(0, 0, 0)
		--glasses.Transparency= 1
		--Tool.GripRight = Vector3.new(-1, 0, 0)
		--Tool.GripUp = Vector3.new(0, 0, 1)
		--hold_sounds[math.random(1, #hold_sounds)]:Play()
		--wait(2)	
		
	end
	enabled = true	
end


function onEquipped()
	-- Unmute all Sounds
	for i=1, #all_sounds do
		all_sounds[i].Volume = 1
	end
end

function onUnequipped()
	-- Mute all Sounds
	for i=1,#all_sounds do
		all_sounds[i].Volume = 0
	end
	sitting_on_character = false
	Tool.GripPos = Vector3.new(0, 0, 0)
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
	game.Workspace.CurrentCamera.CameraType = "Custom"
	--glasses.Transparency= 1
end

-- This is to connect our function to the Activate functionality of the Player Character!
script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
