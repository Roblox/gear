--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Module = require(185791213)

GuitarDanceScript = script:WaitForChild("GuitarDanceScript")

Sounds = {
	S1 = Handle:WaitForChild("S1"),
	S2 = Handle:WaitForChild("S2"),
	S3 = Handle:WaitForChild("S3"),
	S4 = Handle:WaitForChild("S4")
}

Animations = {
	Equipped = {Animation = Tool:WaitForChild("Equipped"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Gravity = 196.20

NoteTextures = {60667024, 60667032, 60667053, 60667087}

DanceEnabled = true
DanceReload = 10

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v.Name == "FakeHandle" then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "KeyPress" and Value then
		local Key = string.lower(Value.Key)
		local ByteKey = string.byte(Key)
		local Down = Value.Down
		if Value.Down and Tool.Enabled then
			if Key == "q" and DanceEnabled then
				
				Tool.Enabled = false
				
				DanceEnabled = false
				
				SetUpGuitar()
				
				
				if ToolUnequipped then
					ToolUnequipped:disconnect()
				end
				local CurrentlyEquipped = true
				ToolUnequipped = Tool.Unequipped:connect(function()
					CurrentlyEquipped = false
				end)
				
				local Sound = Sounds.S4
				Module.PlaySound(FakeHandle, {Sound = Sound, SoundId = Sound.SoundId}, Sound.Pitch, nil)
				for i = 1, 12 do
				
					local Note = BasePart:Clone()
					Note.Name = "Note"
					Note.Size = Vector3.new(1, 1, 1)
					Note.CanCollide = false
	
					local NoteMesh = Instance.new("SpecialMesh")
					NoteMesh.MeshId = "http://www.roblox.com/asset/?id=60666966"
					NoteMesh.TextureId = ("http://www.roblox.com/asset/?id=" .. NoteTextures[math.random(1, #NoteTextures)])
					NoteMesh.Parent = Note
	
					local BF = Instance.new("BodyForce")
					BF.force = Vector3.new(0, (Note:GetMass() * Gravity), 0)
					BF.Parent = Note
						
					local Pos = CFrame.Angles(-(math.pi / 12), (i * (math.pi / 6)), 0) * Torso.CFrame.lookVector
					local SpawnPos = Torso.Position + (Pos * 5)
					
					Note.Velocity = Pos * 4
					Debris:AddItem(Note, 2)
					
					Note.Parent = game:GetService("Workspace")
					
					Note.CFrame = CFrame.new(SpawnPos, (SpawnPos + Pos)) 
				
				end

				local Radius = 10
				local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(Torso.Position - Vector3.new(Radius, Radius, Radius), Torso.Position + Vector3.new(Radius, Radius, Radius)), {Character}, 100)
				for i, v in pairs(Parts) do
					if v and v.Parent then
						local character = v.Parent
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 and not character:FindFirstChild(GuitarDanceScript.Name) then
							local GuitarDanceScriptClone = GuitarDanceScript:Clone()
							GuitarDanceScriptClone.Disabled = false
							Debris:AddItem(GuitarDanceScriptClone, 7.5)
							GuitarDanceScriptClone.Parent = character
						end
					end
				end
				
				wait(2)
				
				if CurrentlyEquipped then
					if ToolUnequipped then
						ToolUnequipped:disconnect()
					end
					DismountGuitar()
				end
				
				Tool.Enabled = true
				
				wait(DanceReload)				
				
				DanceEnabled = true
			
			end			
		end
	end
end)

Tool.Enabled = true

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function Activated()
	
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	if not LeftArm or not RightArm then
		return
	end

	Tool.Enabled = false
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	SetUpGuitar()
	
	local Duration = 10	
	
	local RandomSongs = {Sounds.S1, Sounds.S2, Sounds.S3}
	local RandomSong = RandomSongs[math.random(1, #RandomSongs)]
	
	Module.PlaySound(FakeHandle, {Sound = RandomSong, SoundId = RandomSong.SoundId}, RandomSong.Pitch, Duration)
	
	wait(Duration)
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	DismountGuitar()
	
	Tool.Enabled = true
end

function SetUpGuitar()
	Handle.Transparency = 1
	FakeHandle = Handle:Clone()
	FakeHandle.Name = "FakeHandle"
	FakeHandle.Transparency = 0
	TorsoWeld = Instance.new("Weld")
	TorsoWeld.Part0 = Torso
	TorsoWeld.Part1 = FakeHandle
	TorsoWeld.C1 = CFrame.Angles(math.pi, 0, -(math.pi / 4)) + Vector3.new(0, 0.2, -0.9)	
	TorsoWeld.Parent = FakeHandle
	FakeHandle.Parent = Tool
	InvokeClient("PlayAnimation", Animations.Equipped)
end

function DismountGuitar()
	InvokeClient("StopAnimation", Animations.Equipped)
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	Handle.Transparency = 0
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
end

function Unequipped()
	Equipped = false
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	DismountGuitar()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)