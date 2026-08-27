local RELOAD_TIME = 10

local Create = LoadLibrary('RbxUtility').Create

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local RocketScript = Tool:WaitForChild('RocketScript')
local Player;
local Character;
local Torso;
local Humanoid;
local Equipped = false

local LastUse = Tool:WaitForChild('LastUse')

local Cursor_PlaceRocket = 'http://www.roblox.com/asset/?id=119809015'
local Cursor_Reloading =   'http://www.roblox.com/asset/?id=119809109'

local ANIM_Hold =  Tool:WaitForChild('ANIM_Hold')
local ANIM_Place = Tool:WaitForChild('ANIM_Place')
local Anim_Hold, Anim_Place;

local function IsReadyToFire()
	return (Workspace.DistributedGameTime - LastUse.Value) > RELOAD_TIME
end

local function PlaceRocket()
	local rocket = Handle:Clone()
	rocket.CanCollide = true
	rocket.creator.Value = Player
	local sc = RocketScript:Clone()
	sc.Parent = rocket
	--
	Anim_Place:Play()
	repeat until Anim_Place.KeyframeReached:wait() == 'Dropped'
	Handle.Transparency = 1
	--
	rocket.Parent = game.Workspace
	local curDir = rocket.CFrame.lookVector
	local at = rocket.Position + Torso.CFrame.lookVector*0.9 + Vector3.new(0, -0.5, 0)
	rocket.CFrame = CFrame.new(at, at + Vector3.new(curDir.x, 0, curDir.z))
	rocket.RotVelocity = Vector3.new(0,0,0)
	rocket.Velocity = Vector3.new(0,0,0)
	local correctGyro = Create'BodyGyro'{
		Parent = rocket;
		maxTorque = Vector3.new(100,100,100);
		cframe = rocket.CFrame;
	}
	game.Debris:AddItem(correctGyro, 0.5)
	sc.Disabled = false
	--
	for i = 1, 0, -0.06 do
		Handle.Transparency = i
		wait()
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(function(mouse)
	Equipped = true
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:WaitForChild('Humanoid')
	Torso = Character:WaitForChild('Torso')
	--
	Anim_Hold =  Humanoid:LoadAnimation(ANIM_Hold)
	Anim_Place = Humanoid:LoadAnimation(ANIM_Place)
	--
	Anim_Hold:Play()
	--
	if IsReadyToFire then
		mouse.Icon = Cursor_PlaceRocket
	else
		mouse.Icon = Cursor_Reloading
		while not IsReadyToFire() do wait() end
		if not Equipped then return end
		mouse.Icon = Cursor_PlaceRocket
	end
	--
	mouse.Button1Down:connect(function()
		local elapsed = (Workspace.DistributedGameTime - LastUse.Value)
		if not IsReadyToFire() then return end
		LastUse.Value = Workspace.DistributedGameTime
		--
		PlaceRocket()
		--
		mouse.Icon = Cursor_Reloading
		wait(RELOAD_TIME)
		mouse.Icon = Cursor_PlaceRocket
	end)
end)

Tool.Unequipped:connect(function()
	Equipped = false
	Handle.Transparency = 0
	if Anim_Hold then
		Anim_Hold:Stop()
	end
	if Anim_Place then
		Anim_Place:Stop()
	end
end)