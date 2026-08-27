--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

StaffSlash = Tool:WaitForChild("StaffSlash")
StaffGrip = Tool:WaitForChild("StaffGrip")

SlashSound = Handle:WaitForChild("SlashSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equipped = false
SpecialReady = true
SpecialActive = false

SlashDamage = 15
FireDamage = 10
ReloadTime = 1
SpecialReloadTime = 15

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if character and character ~= Character and humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
			local right_arm = Character:FindFirstChild("Right Arm")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(SlashDamage)
				end
			end
		end
	end
end

function Activated()
	if Tool.Enabled and not SpecialActive then
		Tool.Enabled = false
		StaffSlashAnim = Humanoid:LoadAnimation(StaffSlash)
		if StaffSlashAnim then
			SlashSound:Play()
			StaffSlashAnim:Play()
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Humanoid or not Torso then
		return
	end
	Equipped = true
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Spawn(function()
		if not SpecialReady then
			wait(SpecialReloadTime)
			SpecialReady = true
		end
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" then
			if SpecialReady and not SpecialActive then
				Spawn(function()
					SpecialReady = false
					SpecialActive = true
					Humanoid.WalkSpeed = 0
					if Equipped then
						StaffGripAnim = Humanoid:LoadAnimation(StaffGrip)
						if StaffGripAnim then
							StaffGripAnim:Play()
						end
						local TorsoPos = Torso.CFrame
						for i = 1, 125 do
							if Equipped then
								local Position = TorsoPos + TorsoPos.lookVector * (i + 4)
								local Hit, Pos = RayCast(Position.p, Vector3.new(0, -1, 0), 6, {Character})
								if Hit then
									local Part = Instance.new("Part")
									Part.Name = "FlamePart"
									Part.Anchored = true
									Part.CanCollide = false
									Part.TopSurface = Enum.SurfaceType.Smooth
									Part.BottomSurface = Enum.SurfaceType.Smooth
									Part.FormFactor = Enum.FormFactor.Custom
									Part.Size = Vector3.new(2, 2, 2)
									Part.Transparency = 1
									local Fire = Instance.new("Fire")
									Fire.Color = Color3.new((85 / 255), (0 / 255), (127 / 255))
									Fire.SecondaryColor = Color3.new((85 / 255), (0 / 255), (255 / 255))
									Fire.Heat = 25
									Fire.Size = 5
									Fire.Enabled = true
									Fire.Parent = Part
									Debris:AddItem(Part, 10)
									Part.Touched:connect(function(Hit)
										if Hit and Hit.Parent then
											local character, humanoid = FindCharacterAncestor(Hit.Parent)
											if character and character ~= Character and humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
												UntagHumanoid(humanoid)
												TagHumanoid(humanoid, Player)
												humanoid:TakeDamage(FireDamage)
											end
										end
									end)
									Part.Parent = Character
									Part.CFrame = CFrame.new(Pos) - Vector3.new(0, Part.Size.Y, 0)
									Spawn(function()
										for i = 0.1, Part.Size.Y, 0.1 do
											Part.CFrame = Part.CFrame + Vector3.new(0, 0.1, 0)
											wait()
										end
									end)
									wait(0.025)
								end										
							else
								break
							end
						end
						wait(1.5)
						if StaffGripAnim then
							StaffGripAnim:Stop()
						end
						Humanoid.WalkSpeed = 16
						SpecialActive = false
						wait(SpecialReloadTime)
						SpecialReady = true
					end
				end)
			end
		end
	end)
end

function Unequipped()
	Equipped = false
	SpecialActive = false
	Humanoid.WalkSpeed = 16
	if StaffSlashAnim then
		StaffSlashAnim:Stop()
	end
	if StaffGripAnim then
		StaffGripAnim:Stop()
	end
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)