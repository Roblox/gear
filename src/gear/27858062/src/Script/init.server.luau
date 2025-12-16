--[[
	Fixed by ArceusInator.  Works with FE, can't dance forever anymore.
--]]
local Duration = 15

local Tool = script.Parent
local DanceAnim = Tool.Dance
local Handle = Tool.Handle
local Song = Handle.SongLoop
local EquipSound = Handle.EquipSound

local EquippedTicket = 0

Tool.Activated:connect(function()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	
	local Character = Tool.Parent
	local Humanoid = Character:FindFirstChild'Humanoid'
	if Humanoid and Humanoid:IsA'Humanoid' and Humanoid.Torso then
		local CharacterScale = Humanoid.Torso.Size.y/2
		local DanceTrack = Humanoid:LoadAnimation(DanceAnim)
		
		local DiscoBall = Instance.new'Part'
		DiscoBall.Name = 'DiscoBall'
		DiscoBall.Locked = true
		DiscoBall.FormFactor = Enum.FormFactor.Symmetric
		DiscoBall.Shape = Enum.PartType.Ball
		DiscoBall.Size = Vector3.new(1,1,1)*4*CharacterScale
		DiscoBall.TopSurface = Enum.SurfaceType.Smooth
		DiscoBall.BottomSurface = Enum.SurfaceType.Smooth
		for index, enum in next, Enum.NormalId:GetEnumItems() do
			local decal = Instance.new'Decal'
			decal.Parent = DiscoBall
			decal.Texture = 'http://www.roblox.com/asset/?id=27831454'
			decal.Face = enum
		end
		DiscoBall.Position = Humanoid.Torso.Position + Vector3.new(0, 5, 0)*CharacterScale -- account for different body sizes
		local DiscoSparkles = Instance.new('Sparkles', DiscoBall)
		local BodyPos = Instance.new('BodyPosition', DiscoBall)
		BodyPos.position = Humanoid.Torso.Position + Vector3.new(0, 15, 0)*CharacterScale
		BodyPos.P = 10000
		BodyPos.D = 1000
		BodyPos.maxForce = Vector3.new(1,1,1)*BodyPos.P
		local BAV = Instance.new('BodyAngularVelocity', DiscoBall)
		BAV.P = 100000
		BAV.angularvelocity = Vector3.new(0,1000,0)
		BAV.maxTorque = Vector3.new(1,1,1)*BAV.P
		
		DiscoBall.Parent = workspace
		
		local TrackScript = script.TrackScript:Clone()
		TrackScript.Parent = Character
		TrackScript.Time.Value = Duration
		local trackKey = 'DancePotion_DanceTrack_'..EquippedTicket
		_G[trackKey] = DanceTrack
		TrackScript.Track.Value = trackKey
		TrackScript.Song.Value = Song
		TrackScript.LinkedTool.Value = Tool
		TrackScript.DiscoBall.Value = DiscoBall
		TrackScript.Disabled = false
		
		DanceTrack:Play()
		Song:Play()
	end
	
	local myEquippedTicket = EquippedTicket+1
	EquippedTicket = myEquippedTicket
	wait(Duration)
	
	if myEquippedTicket == EquippedTicket then
		Tool.Enabled = true
	end
end)

Tool.Equipped:connect(function()
	EquippedTicket = EquippedTicket + 1
	
	EquipSound:Play()
	Tool.Enabled = true
end)