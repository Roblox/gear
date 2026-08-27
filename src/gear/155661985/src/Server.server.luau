--Made by Luckymaxer
--Fixed by TakeoHonorable

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")
RunService = game:GetService("RunService")

PlaySound = Tool:WaitForChild("PlaySound")
local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool

local SlashSound = Handle:WaitForChild("Slash")
local SplashParticle = Handle:WaitForChild("Splash")
local AbilityReady = Handle:WaitForChild("AbilityReady")
local SplashSound = Handle:WaitForChild("SplashSound")
local Equip = Handle:WaitForChild("Unsheath")

local LeftSlash,RightSlash

WaveModel = InsertService:LoadAsset(212226090)
Wave = WaveModel:GetChildren()[1]:Clone()
Wave.Size = Vector3.new(10, 3.5, 20)
WaveModel:Destroy()

SpecialActive = false
SplashParticle.Enabled = true

SpecialReloadTime = 8

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function IsInTable(Table,Value)
	for i,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if character and character ~= Character and Humanoid and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 and not IsTeamMate(Player,Players:GetPlayerFromCharacter(character)) then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(15)
		end
	end
end

local SlashCoolDown = false
function Attack()
	spawn(function()
		if (Tool.Enabled and (not SlashAnim or SlashAnim.KeyframeReached)) then
			Tool.Enabled = false
			local PossibleAnims = {RightSlash, LeftSlash}
			local ChosenAnim = PossibleAnims[math.random(1, #PossibleAnims)]
			SlashAnim = Humanoid:LoadAnimation(ChosenAnim)
			SlashAnim:Play()
			PlaySound.Value = SlashSound.Name
			wait(0.5)
			Tool.Enabled = true
		end
	end)
end

function Activated()
	if Tool.Enabled then
		Attack()
	end
end
local RemoteConnection
function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
	if not Player or not Humanoid or not Torso then
		return
	end
	RightSlash,LeftSlash = Tool:WaitForChild("RightSlash"..Humanoid.RigType.Name),Tool:WaitForChild("LeftSlash"..Humanoid.RigType.Name)
	Equip:Play()
	if not SpecialActive and SplashParticle.Enabled then
		AbilityReady:Play()
	end
	
	if RemoteConnection then RemoteConnection:Disconnect();RemoteConnection = nil end
	RemoteConnection = Remote.OnServerEvent:Connect(function(Player,Key)
		if Key == Enum.KeyCode.Q and not SpecialActive then
			SpecialActive = true
			SplashParticle.Enabled = false
			AbilityReady:Stop()
			local WavePart = Wave:Clone()
			WavePart.Material = Enum.Material.Glass
			WavePart.Transparency = .3
			WavePart.Locked = true
			WavePart.Anchored = false
			WavePart.CanCollide = false
			WavePart.CFrame = ((Torso.CFrame * CFrame.new(0, -Torso.Size.Y, 0))) * CFrame.Angles(0,math.rad(-90),0)
			WavePart.Color = Color3.fromRGB(0,255,204)
			WavePart.UsePartColor = true
			
			local Velo = Instance.new("BodyVelocity")
			Velo.MaxForce = Vector3.new(1,1,1)*math.huge
			Velo.Velocity = Torso.CFrame.lookVector*30
			Velo.Parent = WavePart
			
			local Splash = SplashSound:Clone()
			Splash.Parent = WavePart
			
			WavePart.Parent = workspace
			WavePart:SetNetworkOwner(nil)
			Splash:Play()
			
			Debris:AddItem(WavePart,4)

			local AffectedHumanoids = {}
			WavePart.Touched:Connect(function(hit)
				if not hit or not hit.Parent then return end
				local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
				if not Hum or Hum == Humanoid or Hum.Health <= 0 then return end
				if IsTeamMate(Player,Players:GetPlayerFromCharacter(Hum.Parent)) or IsInTable(AffectedHumanoids,Hum) then return end
				table.insert(AffectedHumanoids,Hum)
				UntagHumanoid(Hum)
				TagHumanoid(Hum,Player)
				Hum:TakeDamage(50)
				spawn(function()
					local Knockback = Instance.new("BodyVelocity")
					Knockback.MaxForce = Vector3.new(1,1,1)*math.huge
					Knockback.Velocity = (hit.CFrame.p-WavePart.CFrame.p).unit*50
					Knockback.Parent = hit
					Debris:AddItem(Knockback,.5)
				end)
			end)
			
			wait(SpecialReloadTime)
			if AbilityReady:IsDescendantOf(workspace) then
				AbilityReady:Play()
			end
			SplashParticle.Enabled = true
			SpecialActive = false
		end
	end)
end

function Unequipped()
	if SlashAnim then
		SlashAnim:Stop()
	end
	AbilityReady:Stop()
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

Handle.Touched:Connect(Blow)