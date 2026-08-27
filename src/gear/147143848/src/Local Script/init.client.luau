--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
SpecialEnabled = Tool:WaitForChild("SpecialEnabled")

SlashSound = Handle:WaitForChild("SlashSound")
Fire = Handle:WaitForChild("Fire")
DamageScript = script:WaitForChild("DamageScript")

Damage = 9
FireballDamage = 50
Anims = {"RightSlash", "LeftSlash", "OverHeadSwing"}

Rate = (1 / 30)

Debris = game:GetService("Debris")
Players = game:GetService("Players")

Equipped = false
Check = true
LastAnim = ""

LastMove = nil

function SwordUp()
	Tool.Grip = CFrame.new(0, -1 ,0)
end

function SwordOut()
	Tool.Grip = CFrame.new(0, -1, 0) * CFrame.Angles(0.5, 0, 0.3)
end

-- Returns a character ancestor and its Humanoid, or nil
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

--To avoid :TakeDamage() bug
function TakeDamage(humanoid, damage)
	if humanoid and humanoid.Parent and not humanoid.Parent:FindFirstChild("ForceField") then
		humanoid.Health = humanoid.Health - Damage
	end
end

function Lunge()
	if Humanoid and Torso and Equipped then
		local Target = Humanoid.TargetPoint
		local Direction = (Target - Torso.Position) * Vector3.new(1, 0, 1)
		if Direction.magnitude > 0.01 then
			Direction = Direction.unit
			local NewBV = Instance.new("BodyVelocity")
			NewBV.P = 100000
			NewBV.maxForce = Vector3.new(NewBV.P, 0, NewBV.P)
			NewBV.velocity = (Direction * 100)
			NewBV.Parent = Torso
			Torso.CFrame = CFrame.new(Torso.Position, Target * Vector3.new(1, 0, 1) + Vector3.new(0, Torso.Position.Y, 0))
			SlashSound:Play()
			wait(0.25)
			if not NewBV then
				NewBV:Destroy()
			end
		end
	end
end

function RemoveCreatorTags(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local humanoid = Hit.Parent:findFirstChild("Humanoid")
		if humanoid and humanoid ~= Humanoid and Humanoid.Health > 0 then
		-- final check, make sure sword is in-hand
		local RightArm = Character:FindFirstChild("Right Arm")
		if RightArm then
			local Joint = RightArm:FindFirstChild("RightGrip")
			if (Joint and (Joint.Part0 == Handle or Joint.Part1 == Handle)) then
				RemoveCreatorTags(humanoid)
				if not Hit:FindFirstChild(Fire.Name) then
					local FireClone = Fire:Clone()
					local DamageScriptClone = DamageScript:Clone()
					DamageScriptClone.Damage.Value = 15
					DamageScriptClone.creator.Value = Player
					DamageScriptClone.Disabled = false
					DamageScriptClone.Parent = FireClone
					FireClone.Parent = Hit
				end
				local Creator_Tag = Instance.new("ObjectValue")
				Creator_Tag.Value = Player
				Creator_Tag.Name = "creator"
				Debris:AddItem(Creator_Tag, 2)
				Creator_Tag.Parent = humanoid
				TakeDamage(humanoid, Damage)
			end
		end
	end
end

function OnEquipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	SwordUp()
	Mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Mouse.Button1Down:connect(function()
		if Check and Equipped then
			if ((LastMove and ((tick() - LastMove) <= 0.75)) and SpecialEnabled.Value) then
				SpecialEnabled.Value = false
				local Fireball = Instance.new("Part")
				Fireball.Name = "Fireball"
				Fireball.Shape = Enum.PartType.Ball
				Fireball.TopSurface = Enum.SurfaceType.Smooth
				Fireball.BottomSurface = Enum.SurfaceType.Smooth
				Fireball.BrickColor = BrickColor.new("Bright red")
				Fireball.Material = Enum.Material.CorrodedMetal
				Fireball.FormFactor = Enum.FormFactor.Custom
				Fireball.Size = Vector3.new(4, 4, 4)
				Fireball.CanCollide = false
				local HandleCFrame = Handle.CFrame
				local FiringPoint = HandleCFrame.p + HandleCFrame:vectorToWorldSpace(Vector3.new(0, 0, 0))
				local ShotCFrame = CFrame.new(FiringPoint, Humanoid.TargetPoint)
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.velocity = ShotCFrame.lookVector * 100
				BodyVelocity.maxForce = Vector3.new(Fireball:GetMass() * 1000, Fireball:GetMass() * 1000, Fireball:GetMass() * 1000)
				BodyVelocity.Parent = Fireball
				local FireClone = Fire:Clone()
				FireClone.Heat = 25
				FireClone.Size = 10
				FireClone.Parent = Fireball
				Debris:AddItem(Fireball, 5)
				Fireball.Parent = game:GetService("Workspace")
				Fireball.CFrame = ShotCFrame + (ShotCFrame.lookVector * (Fireball.Size.Z / 2))
				local Debounce = false
				Fireball.Touched:connect(function(Hit)
					if Hit and Hit.Parent and not Debounce then
						local character, humanoid = FindCharacterAncestor(Hit)
						if humanoid and humanoid.Parent and humanoid ~= Humanoid and humanoid.Health > 0 then
							Debounce = true
							RemoveCreatorTags(humanoid)
							local Creator_Tag = Instance.new("ObjectValue")
							Creator_Tag.Value = Player
							Creator_Tag.Name = "creator"
							Debris:AddItem(Creator_Tag, 2)
							Creator_Tag.Parent = humanoid
							if not character:FindFirstChild("ForceField") then
								Fireball:Destroy()
								TakeDamage(humanoid, FireballDamage)
								for i, v in pairs(character:GetChildren()) do
									if not v:FindFirstChild(Fire.Name) then
										local FireClone = Fire:Clone()
										local DamageScriptClone = DamageScript:Clone()
										DamageScriptClone.Damage.Value = 5
										DamageScriptClone.creator.Value = Player
										DamageScriptClone.Disabled = false
										DamageScriptClone.Parent = FireClone
										FireClone.Parent = v
									end
								end
							end
						end
					end
				end)
			end
			Spawn(function()
				Check = false
				local TempAnims = {}
				for i, v in pairs(Anims) do
					if v ~= LastAnim then
						table.insert(TempAnims, v)
					end
				end
				NewAnim = TempAnims[math.random(1, #TempAnims)]
				LastAnim = NewAnim
				local Anim = Tool:FindFirstChild(NewAnim)
				if Humanoid and Torso and Anim then
					TheAnim = Humanoid:LoadAnimation(Anim)
					if TheAnim and Humanoid.Health > 0 then
						SlashSound:Play()
						TheAnim:Play()
						if NewAnim == "OverHeadSwing" then
							wait(0.25)
							SwordOut()
							wait(0.4)
							SwordUp()
						else
							wait(0.5)
						end
					end
				end
				Check = true
			end)
			LastMove = tick()
		end
	end)
end

function OnUnequipped()
	Equipped = false
	if TheAnim then
		TheAnim:Stop()
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Handle.Touched:connect(Blow)