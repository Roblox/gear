--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

WhackAnim = Tool:WaitForChild("Whack")

SlashSound = Handle:WaitForChild("SlashSound")

Damage = 15

ReloadTime = 0.75

Kills = 0

PlayerAssets = {}
KorbloxAssets = {68539149, 68539179, 68539213, 68539233, 68539263}
KorbloxHats = {127505532, 81722693, 98450218, 136803300}
LocalKorbloxAssets = {}
Korbloxized = false

for i, v in pairs(KorbloxAssets) do
	local AssetModel = InsertService:LoadAsset(v)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	AssetModel:Destroy()
	KorbloxAssets[i] = Asset
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

function UnKorbloxizePlayer()
	Humanoid.WalkSpeed = OriginalWalkSpeed
	for i, v in pairs(LocalKorbloxAssets) do
		v:Destroy()
	end
	for i, v in pairs(PlayerAssets) do
		v.Parent = Character
	end
	PlayerAssets = {}
	LocalKorbloxAssets = {}
	Kills = 0
	Korbloxized = false
end

function KorbloxizePlayer()
	if Kills >= 3 then
		Korbloxized = true
		PlayerAssets = {}
		OriginalWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = 32
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("CharacterMesh") or v:IsA("Hat") then
				table.insert(PlayerAssets, v:Clone())
				v:Destroy()
			end
		end
		for i, v in pairs(KorbloxAssets) do
			local AssetClone = v:Clone()
			table.insert(LocalKorbloxAssets, AssetClone)
			AssetClone.Parent = Character
		end
		local Sparkles = Instance.new("Sparkles")
		table.insert(LocalKorbloxAssets, Sparkles)
		Sparkles.Parent = Handle
		local KorbloxHatModel = InsertService:LoadAsset(KorbloxHats[math.random(1, #KorbloxHats)])
		local KorbloxHat = KorbloxHatModel:GetChildren()[1]:Clone()
		KorbloxHatModel:Destroy()
		table.insert(LocalKorbloxAssets, KorbloxHat)
		KorbloxHat.Parent = Character
		local IgnoreChange = false
		local UnequippedConnection = Tool.Unequipped:connect(function()
			IgnoreChange = true
		end)
		wait(30)
		if not IgnoreChange then
			UnKorbloxizePlayer()
		end
	end
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if Humanoid and Humanoid ~= humanoid and humanoid and Humanoid.Health > 0 and humanoid.Health > 0 then
			local Right_Arm = Character:FindFirstChild("Right Arm")
			if Right_Arm then
				local Joint = Right_Arm:FindFirstChild("RightGrip")
				if (Joint and (Joint.Part0 == Handle or Joint.Part1 == Handle)) then
					humanoid:TakeDamage((Korbloxized and (Damage * 2)) or Damage)
					if humanoid.Health <= 0 and not Korbloxized then
						Kills = Kills + 1
						KorbloxizePlayer()
					end
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
				end
			end
		end
	end
end

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false 
		Whack = Humanoid:LoadAnimation(WhackAnim)
		if Whack then
			Whack:Play()
			SlashSound:Play()
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Equipped(mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Humanoid or not Torso then
		return 	
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	if Whack then
		Whack:Stop()
	end
	if Korbloxized then
		UnKorbloxizePlayer()
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Handle.Touched:connect(Blow)