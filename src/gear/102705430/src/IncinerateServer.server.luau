local SpreadSpeed = .5
local MaxVolume = 9*9*9
local VolumeFireConst = 4.5 --volume of part to size of fire
local MaxPartsBurned = 20

local Textures = 
{
	Ash = 102496105,

}

local AshColor = Vector3.new(42/255,53/255,55/255) 

local Sounds =
{
	Fire = 102503996,
}
--yay lua has no definable enums, IM SO HAPPY ABOUT THIS
local BurnStates =
{
	wait = 1,
	burn = 2,
	done = 3,
}
--aren't character meshes just Greeeeaaat?
local CharacterMeshToPart = {}

CharacterMeshToPart[	Enum.BodyPart.LeftArm ] = 'Left Arm'
CharacterMeshToPart[	Enum.BodyPart.LeftLeg ] = 'Left Leg'
CharacterMeshToPart[	Enum.BodyPart.RightArm ]= 'Right Arm'
CharacterMeshToPart[	Enum.BodyPart.RightLeg ]= 'Right Leg'
CharacterMeshToPart[	Enum.BodyPart.Head ]= 'Head'
CharacterMeshToPart[	Enum.BodyPart.Torso ]= 'Torso'


local Parent = script.Parent



--all parts ever registered
local RegisteredParts = {}

local TouchConnections = {}

function RegisterModel(nchar)
		--array of tables with:
	--state
	--part (associated part for character meshes)
	--owner (root object)
	local Parts = {}
	local BodyMeshes = {}
	for _, i in pairs(nchar:GetChildren()) do
		if i:IsA('CharacterMesh') then
			local nentry ={}
			nentry['owner'] = i
			nentry['state'] = BurnStates['wait']
			print(i.BodyPart)
			nentry['part'] = nchar:FindFirstChild(CharacterMeshToPart[i.BodyPart])
			if nentry['part'] then
				RegisteredParts[nentry['part'] ] = true
			end
			table.insert(BodyMeshes,nentry)
		elseif i:IsA('Humanoid') then
			local thum = i
			Spawn(function() 
				local startTime = tick() 
				while tick()- startTime<5 do
					thum:TakeDamage(1)
					wait(1/15)
				end
			end )
		elseif i:IsA('Hat') then
			local t_hat = i 
			Delay(5*.75, function() t_hat:Destroy() end)
		end
	end
	
	Delay(5*.75, function() 
	
		local nhat = Instance.new('Hat')
		nhat.AttachmentPos= Vector3.new(0,-.15,0)
		local nhandle = Instance.new('Part')
		nhandle.Name = 'Handle'
		nhandle.FormFactor = 'Custom'
		nhandle.Size = Vector3.new(1.45, 0.38, 2)
		local nmesh = Instance.new('SpecialMesh')
		nmesh.MeshId = 'http://www.roblox.com/asset/?id=102706424'
		nmesh.TextureId = 'http://www.roblox.com/asset/?id=102706523'
		nmesh.Parent = nhandle
		nhandle.Parent = nhat
		nhat.Parent= nchar
  end)

	for _, i in pairs(nchar:GetChildren()) do
		if i:IsA('Part') and not RegisteredParts[i] then
			local nentry ={}
			nentry['owner'] = i
			nentry['state'] = BurnStates['wait']
			table.insert(Parts,nentry)
			RegisteredParts[i]=true
		end
	end
	
	while #BodyMeshes ~= 0 do
		local tentry = BodyMeshes[#BodyMeshes]
		table.remove(BodyMeshes)
		if tentry['part'] then
			burnPart(tentry['part'], 5,false)
			local tmesh = tentry['owner']
			Delay(5*.75, function() print('getting here') tmesh.BaseTextureId = 102496105 tmesh.OverlayTextureId = 102496105 end)
		end
			wait(1)
		
	end

	while #Parts ~=0 do
		local tentry = Parts[#Parts]
		table.remove(Parts)
		if tentry['owner'] then
			burnPart(tentry['owner'], 5,false)
			wait(1)
		end
	end
end


function burnPart(part, length, breakJoints)
	local partVolume = part.Size.x*part.Size.y*part.Size.z
	local nsound = Instance.new('Sound')
	nsound.SoundId ='http://roblox.com/asset/?id='..Sounds['Fire']
	nsound.Parent = part
	nsound.Looped = true
	nsound.Volume = 0
	nsound:Play()
	game.Debris:AddItem(nsound,length+1)
	local nfire = Instance.new('Fire')
	nfire.Heat = 1
	nfire.Size = 2
	nfire.Parent = part
	game.Debris:AddItem(nfire,length+1)
	local stage2Delay = length *.75

	local tconnect = part.Touched:connect(function(hit) onTouch(part,hit,length) end)
	table.insert(TouchConnections,tconnect)
	--change color/texture of any meshes
	for _,i in pairs(part:GetChildren()) do
		if i:IsA('SpecialMesh') and i.MeshType == 'FileMesh' then
			Spawn(function()
				local startTime = tick()
				while tick()-startTime<stage2Delay do
					wait(1/30)
				end
				i.TextureId = 'http://roblox.com/asset/?id=' .. Textures['Ash']
			end)
		end
	end

	--tween fire size, sound volume
	Spawn(function	()
		local startTime = tick()
		while tick()-startTime<stage2Delay do
			local alpha = (tick()-(startTime))/(stage2Delay)
			nfire.Heat = 5 --TODO
			nfire.Size = partVolume*VolumeFireConst*alpha
			nsound.Volume = alpha
			wait(1/30)
		end
		
		tconnect:disconnect()

		while tick()-startTime<length do
			local alpha = 1-((tick()-(startTime+stage2Delay))/(length-stage2Delay))
			nfire.Heat = 5*alpha 
			nfire.Size = partVolume*VolumeFireConst*alpha
			nsound.Volume = alpha
			wait(1/30)
		end
	end)

end
--[[
while true do
	if math.random(0,1) and #Parts then
	
	elseif #BodyMeshes then

	end
	wait(SpreadSpeed)
end
--]]

function onTouch(owner,hit,burnTime)
	if #RegisteredParts<MaxPartsBurned and tick()-burnTime>SpreadSpeed and hit.Name ~= 'Effect' and not RegisteredParts[hit] then
		if hit.Size.x*hit.Size.y*hit.Size.z<MaxVolume then
			burnPart(hit, 5, false)
			MaxPartsBurned = MaxPartsBurned+1
		end
		if hit.Parent:FindFirstChild('Humanoid') then
			RegisterModel(hit.Parent)
		end
	end
end

table.insert(TouchConnections, Parent.Touched:connect(function(hit) 
	if hit.Size.x*hit.Size.y*hit.Size.z<MaxVolume and hit.Name ~= 'Effect' then
		Parent.Anchored = true
		Parent.Transparency = 1
		Parent.CFrame = CFrame.new(0,1000000,0)
		onTouch(Parent,hit,0)
	end
end))

local ExecuteTime = tick()
while #RegisteredParts<MaxPartsBurned and tick()-ExecuteTime<20 do
	wait(1/30)
end

for _, i in pairs(TouchConnections) do
	i:disconnect()
end
wait(5)

script.Parent:Destroy()
