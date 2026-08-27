--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Slash = Handle:WaitForChild("Slash")

Charge = Tool:WaitForChild("Charge")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

LeftSlash = Tool:WaitForChild("LeftSlash")
RightSlash = Tool:WaitForChild("RightSlash")
Charge = Tool:WaitForChild("Charge")

Equipped = false
Active = false
SpecialActive = false
SlashCoolDown = false
SpecialReloadTime = 30
SlashReloadTime = 0.25
SlashStopReloadTime = 3
LastClick = 0
Clicks = 0
MouseDown = false

ReloadTime = 0.5
Damage = 8

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
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if Character and Player and Humanoid and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
			local right_arm = Character:FindFirstChild("Right Arm")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					TagHumanoid(humanoid, Player)
					local damage = ((SpecialActive and Damage * 2) or Damage)
					humanoid:TakeDamage(Damage)
				end
			end
		end
	end
end

function Attack()
	Active = true
	Spawn(function()
		if (not SlashCoolDown and (not SlashAnim or SlashAnim.KeyframeReached)) then
			SlashCoolDown = true
			local PossibleAnims = {RightSlash, LeftSlash}
			local ChosenAnim = PossibleAnims[math.random(1, #PossibleAnims)]
			SlashAnim = Humanoid:LoadAnimation(ChosenAnim)
			SlashAnim:Play()
			Slash:Play()
			Delay(0.25, function()
				for i = 1, 20 do
					if not SpecialActive then
						local HandleClone = Handle:Clone()
						local HandleMesh = HandleClone:FindFirstChild("Mesh")
						HandleMesh.TextureId = ""
						local RandomColor = math.random(1, 2)
						HandleClone.BrickColor = ((RandomColor == 1 and BrickColor.new(math.random(), math.random(), math.random())) or BrickColor.Random())
						HandleClone.Name = "KatanaSlash"
						HandleClone.Transparency = 0.25
						HandleClone.Anchored = true
						HandleClone.CanCollide = false
						Spawn(function()
							for i = 1, 75 do
								HandleClone.Transparency = HandleClone.Transparency + 0.1
								wait(0.1)
							end
						end)
						Debris:AddItem(HandleClone, 3)
						HandleClone.Parent = game:GetService("Workspace")
						HandleClone.CFrame = Handle.CFrame
						wait(0.01)
					end
				end
			end)
			wait(SlashReloadTime)
			SlashCoolDown = false
		end
	end)
	Active = false
end

function DoubleClick()
	if Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
		SpecialCoolDown = true
		SpecialActive = true
		Active = true
		ChargingAnim = Humanoid:LoadAnimation(Charge)
		ChargingAnim:Play()
		local ChargeTick = tick()
		while (tick() - ChargeTick) < 5 and MouseDown do
			local Tick = tick()
			local r, g, b = math.abs(math.sin(5 * Tick)), math.abs(math.cos(7 * Tick)), math.abs(math.cos(4 * Tick))
			Mesh.VertexColor = Vector3.new(r, g, b)
			wait()
		end
		if ChargingAnim then
			ChargingAnim:Stop()
		end
		Mesh.VertexColor = Vector3.new(1, 1, 1)
		if MouseDown then
			local RainbowTick = tick()
			while (tick() - RainbowTick) < 30 and Equipped do
				local Tick = tick()
				local r, g, b = math.abs(math.sin(5 * Tick)), math.abs(math.cos(7 * Tick)), math.abs(math.cos(4 * Tick))
				Mesh.VertexColor = Vector3.new(r, g, b)
				wait()
			end
			Mesh.VertexColor = Vector3.new(1, 1, 1)
			SpecialActive = false
			wait(SpecialReloadTime)
		else
			SpecialActive = false
			wait(SlashStopReloadTime)
		end
		SpecialCoolDown = false
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Equipped = true
	Mesh.VertexColor = Vector3.new(1, 1, 1)
	Mouse.Button1Down:connect(function()
		MouseDown = true
		Attack()
		local Tick = tick()
		if LastClick == 0 or (Tick - LastClick) <= 0.25 and not SpecialCoolDown then
			LastClick = Tick
			Clicks = Clicks + 1
			if Clicks >= 2 then
				LastClick = 0
				Clicks = 0
				if SlashAnim then
					SlashAnim:Stop()
				end
				DoubleClick()
			else
				Attack()
			end
		else
			Attack()
			Clicks = 1
			LastClick = Tick
		end
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
		Mesh.VertexColor = Vector3.new(1, 1, 1)
		if ChargingAnim then
			ChargingAnim:Stop()
		end
	end)
end

function Unequipped()
	ChargingTick = 0
	LastClick = 0
	Clicks = 0
	Mesh.VertexColor = Vector3.new(1, 1, 1)
	Active = false
	SpecialActive = false
	MouseDown = false
	Equipped = false
	if ChargingAnim then
		ChargingAnim:Stop()
	end
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)