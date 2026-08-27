--Made by Luckymaxer
--Fixed by TakeoHonorable

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")


local input
SlashSound = Handle:WaitForChild("SlashSound")
local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool
Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equipped = false
SpecialReady = true
SpecialActive = false

SlashDamage = 15
ReloadTime = 1
SpecialReloadTime = 30

NormalGrip = CFrame.new(0, 1.75, 0, 0, 0, 1, 0.00042643919, -0.999999881, 0, 0.999999881, 0.00042643919, -0)

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChildOfClass("Humanoid")
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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if character and character ~= Character and humanoid and humanoid.Health > 0 and Humanoid.Health > 0 and not IsTeamMate(Player,Players:GetPlayerFromCharacter(character)) then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(SlashDamage)
		end
	end
end

function Activated()
	if Tool.Enabled and not SpecialActive then
		Tool.Enabled = false
		local StaffSlash = Tool:WaitForChild("StaffSlash"..Humanoid.RigType.Name)
		StaffSlashAnim = Humanoid:LoadAnimation(StaffSlash)
		if StaffSlashAnim then
			SlashSound:Play()
			StaffSlashAnim:Play()
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end
local touch
function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	touch = Handle.Touched:Connect(Blow)
	if not Character or not Humanoid then
		return
	end
	Equipped = true
	Tool.Grip = NormalGrip
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	--[[spawn(function()
		if not SpecialReady then
			wait(SpecialReloadTime)
			SpecialReady = true
		end
	end)]]
input = Remote.OnServerEvent:Connect(function(Player,Key)
		if Key == Enum.KeyCode.Q then
			if SpecialReady and not SpecialActive then
				spawn(function()
					SpecialReady = false
					SpecialActive = true
					Humanoid.WalkSpeed = 0
					while Equipped and Tool.GripPos.Y >= -0.25 do
						Tool.GripPos = Vector3.new(Tool.GripPos.X, (Tool.GripPos.Y - 0.1), Tool.GripPos.Z)
						wait()
					end
					if Equipped then
						local ShieldParts = {}
						local Radius = 25
						ShieldModel = Instance.new("Model")
						ShieldModel.Name = "ShieldModel"
						Debris:AddItem(ShieldModel, 20)
						ShieldModel.Parent = game:GetService("Workspace")
						for i = 1, 15 do
							local ShieldPart = Instance.new("Part")
							ShieldPart.Name = "ShieldPart"
							ShieldPart.BrickColor = BrickColor.new("Medium stone grey")
							ShieldPart.Material = Enum.Material.Plastic
							ShieldPart.Shape = Enum.PartType.Block
							ShieldPart.FormFactor = Enum.FormFactor.Custom
							ShieldPart.TopSurface = Enum.SurfaceType.Smooth
							ShieldPart.BottomSurface = Enum.SurfaceType.Smooth
							ShieldPart.Size = Vector3.new(Radius, 0.4, Radius)
							ShieldPart.Anchored = true
							ShieldPart.CanCollide = false
							ShieldPart.Locked = true
							ShieldPart.Transparency = (0.25 + (0.05 * (i - 0)))
							local Mesh = Instance.new("CylinderMesh")
							Mesh.Parent = ShieldPart
							table.insert(ShieldParts, ShieldPart)
							ShieldPart.Parent = ShieldModel
							ShieldPart.CFrame = Character:GetModelCFrame() - Vector3.new(0, ((Character:GetModelSize().Y / 2) - (ShieldPart.Size.Y / 2) - (ShieldPart.Size.Y * (i - 1))), 0)
						end
						spawn(function()
							local IgnoreObjects = {Character, ShieldModel}
							while ShieldModel and ShieldModel.Parent do
								local Humanoids = {}
								for i, v in pairs(ShieldParts) do
									if v and v.Parent then
										local NegativePartRadius = Vector3.new((v.Size.X / 2), 0, (v.Size.Z / 2))
										local PositivePartRadius = Vector3.new((v.Size.X / 2), 0, (v.Size.Z / 2))
										local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(v.Position - NegativePartRadius, v.Position + PositivePartRadius), IgnoreObjects, 100)
										for i, v in pairs(Parts) do
											if v and v.Parent then
												local humanoid = v.Parent:FindFirstChildOfClass("Humanoid")
											if not CheckTable(Humanoids, humanoid) then
													table.insert(Humanoids, humanoid)
												end
											end
										end
									end
								end
								for i, v in pairs(Humanoids) do
									if v and v.Parent and v.Health > 0 and not IsTeamMate(Player,Players:GetPlayerFromCharacter(v.Parent)) then
										UntagHumanoid(v)
										TagHumanoid(v, Player)
										v:TakeDamage(v.MaxHealth)
										if v.Health == 0 and v.Parent then
											for i, v in pairs(v.Parent:GetChildren()) do
												if v:IsA("BasePart") then
													v.Anchored = true
												end
											end
										end
									end
								end
								wait()
							end
						end)
						wait(SpecialReloadTime)
						Humanoid.WalkSpeed = 16
						Tool.Grip = NormalGrip
						SpecialActive = false
						SpecialReady = true
					end
				end)
			end
		end



	end)
end

function Unequipped()
	if touch then touch:Disconnect() end
	if input then input:Disconnect() end
	Equipped = false
	SpecialActive = false
	Humanoid.WalkSpeed = 16
	if StaffSlashAnim then
		StaffSlashAnim:Stop()
	end
	if ShieldModel and ShieldModel.Parent then
		ShieldModel:Destroy()
	end
end



Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)