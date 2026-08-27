-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local MyModel = script.Parent

local Pet = WaitForChild(script, 'Pet').Value
local PetHumanoid = WaitForChild(Pet, 'Humanoid')

local AnimationToPlayObject = WaitForChild(script, 'AnimationToPlay')

local ReplicationScript = WaitForChild(script, 'ReplicateNpcAnimation')
local AnimToReplicateObject = WaitForChild(ReplicationScript, 'AnimationToReplicate')
local PlayOrStopObject = WaitForChild(ReplicationScript, 'PlayOrStop')

WaitForChild(ReplicationScript, 'PetHumanoid').Value = PetHumanoid

WaitForChild(script, 'NewNoogieLoop') -- Hardcoded or we'll never see it

local AnimationTupleTable = {}
local LastAnimationTrack = nil

-- Take any child animations and add them and their tracks to AnimationTupleTable
for _, child in pairs(script:GetChildren()) do
	if child and child:IsA('Animation') then
		AnimationTupleTable[child.Name] = {child, PetHumanoid:LoadAnimation(child)}
		print("Animation pre-loaded:", child.Name) --DEBUG
	end
end

-- When AnimationToPlay is changed, try to play the animation or stop the last
AnimationToPlayObject.Changed:connect(function(newValue)
	if newValue ~= '' then
		local animationTuple = AnimationTupleTable[newValue]
		if animationTuple then
			animationTuple[2]:Play()
			AnimToReplicateObject.Value = animationTuple[1]
			PlayOrStopObject.Value = true
			LastAnimationTrack = animationTuple[2]

			-- Replicate the child script to all other players so they can see the NPC animating
			for _, player in pairs(PlayersService:GetPlayers()) do
				if player.Character and player.Character ~= MyModel then
					local replicationScriptClone = ReplicationScript:Clone()
					DebrisService:AddItem(replicationScriptClone, 10) -- Just in case
					replicationScriptClone.Parent = player.Character
					replicationScriptClone.Disabled = false
				end
			end

		end
	else
		if LastAnimationTrack then
			LastAnimationTrack:Stop()
		end
		PlayOrStopObject.Value = false
	end

end)

--NOTE: This script would be much nicer if AnimationTracks could be sent using ObjectValues. (Or directly sent through some other means)
