--Made by Luckymaxer

function WaitForChild(Parent, Child)
	while Parent:findFirstChild(Child) == nil do
		Parent.ChildAdded:wait()
	end
	return Parent:findFirstChild(Child)
end

local Tool = script.Parent
local Sword = WaitForChild(Tool, "Handle")
local Damage = 7
local Kills = 0
local SkeletonSpawnRadius = 5
local SkeletonScript = WaitForChild(script, "SkeletonScript"):Clone()
local BaseUrl = "http://www.roblox.com/asset?id="
local Parts = {
	["Head"] = {36869983, 36869975},
	["Torso"] = {36780113, 36780292},
	["Right Arm"] = {36780156, 36780292},
	["Left Arm"] = {36780032, 36780292},
	["Right Leg"] = {36780195, 36780292},
	["Left Leg"] = {36780079, 36780292}
}
local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\Swordslash.wav"
SlashSound.Parent = Sword
SlashSound.Volume = 1
local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Sword
UnsheathSound.Volume = 1

function TagHumanoid(Humanoid, Player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Value = Player
	Creator_Tag.Name = "creator"
	Creator_Tag.Parent = Humanoid
end

function UnTagHumanoid(Humanoid)
	if Humanoid ~= nil then
		local Tag = Humanoid:findFirstChild("creator")
		if Tag ~= nil then
			Tag.Parent = nil
		end
	end
end

function TransformSkeleton(Humanoid)
	if Humanoid ~= nil and Humanoid.Parent ~= nil then
		for i, v in pairs(Humanoid.Parent:GetChildren()) do
			if v:IsA("BasePart") then
				for ii, vv in pairs(Parts) do
					if ii == v.Name and type(vv) == "table" then
						for iii, vvv in pairs(v:GetChildren()) do
							vvv:Destroy()
						end
						local Mesh = Instance.new("SpecialMesh", v)
						Mesh.MeshId = BaseUrl .. vv[1]
						Mesh.TextureId = BaseUrl .. vv[2]
					end
				end
			elseif v:IsA("Hat") or v:IsA("Accoutrement") then
				v:Destroy()
			end
		end
	end
end

function SpawnSkeleton()
	if SkeletonScript ~= nil then
		local Torso = Tool.Parent:findFirstChild("Torso")
		if Torso ~= nil then
			local Skeleton = game:GetService("InsertService"):LoadAsset(53604463):GetChildren()[1]
			if Skeleton then
				local Head = Skeleton:FindFirstChild("Head")
				if Head then
					Head.Transparency = 0.99
				end
				Skeleton.Parent = game:GetService("Workspace")
				Skeleton:MakeJoints()
				local SkeletonScriptClone = SkeletonScript:Clone()
				SkeletonScriptClone.Parent = Skeleton
				SkeletonScriptClone.Disabled = false
				local CreatorTag = Instance.new("ObjectValue")
				CreatorTag.Name = "creator"
				CreatorTag.Value = game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
				local IconTag = Instance.new("StringValue", CreatorTag)
				IconTag.Name = "icon"
				IconTag.Value = Tool.TextureId
				CreatorTag.Parent = Skeleton
				game:GetService("Debris"):AddItem(Skeleton, 30)
				local SpawnPosition = Torso.Position + Vector3.new(math.random(-SkeletonSpawnRadius, SkeletonSpawnRadius), 0, math.random(-SkeletonSpawnRadius, SkeletonSpawnRadius))
				Skeleton:MoveTo(SpawnPosition)
				game:GetService("Debris"):AddItem(Part, 0.5)
			end
		end
	end
end

Sword.Touched:connect(function(Hit)
	if Hit ~= nil and Hit.Parent ~= nil then
		local Humanoid = Hit.Parent:findFirstChild("Humanoid")
		local vCharacter = Tool.Parent
		local vPlayer = game.Players:playerFromCharacter(vCharacter)
		local Hum = vCharacter:findFirstChild("Humanoid")
		if Humanoid ~= nil and Humanoid ~= Hum and Hum ~= nil  and Humanoid.Health > 0 then
			local Right_Arm = vCharacter:FindFirstChild("Right Arm")
			if (Right_Arm ~= nil) then
				local joint = Right_Arm:FindFirstChild("RightGrip")
				if (joint ~= nil and (joint.Part0 == Sword or joint.Part1 == Sword)) then
					Humanoid:TakeDamage(Damage)
					TagHumanoid(Humanoid, vPlayer)
					if Humanoid.Health == 0 then
						TransformSkeleton(Humanoid)
						Kills = Kills + 1
						if Kills >= 2 then
							Kills = 0
							SpawnSkeleton()
						end
					end
					wait(1)
					UnTagHumanoid(Humanoid)
				end
			end
		end
	end
end)

Tool.Equipped:connect(function(Mouse)
	UnsheathSound:Play()
	local Character = Tool.Parent
	local Humanoid = Character:findFirstChild("Humanoid")
	if Humanoid ~= nil then
		Mouse.Button1Down:connect(function()
			if Tool.Enabled and Humanoid ~= nil then
				SlashSound:Play()
			end
		end)
	end
end)