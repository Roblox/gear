-- Allows the wielder to become a boss 
-- Destroy all those flyers with this
-- Who is the Kami now? 

-- 20 second cooldown
-- Add a RBXGear lib that allows for unified GUIs 

local Range = 150
local RunService = (game:FindService("RunService") or game:GetService("RunService"))
local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print(instance) 
		wait() 
	end 
	return parent:FindFirstChild(instance)
end 

local function Wait(para) -- bypasses the latency
	para = para or wait()
	local Initial = tick()
	repeat
		RunService.Stepped:Wait()
	until tick()-Initial >= para
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end


function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

--[[local function WeldTogether(Part0, Part1, JointType, WeldParent)
	--- Weld's 2 parts together
	-- @param Part0 The first part
	-- @param Part1 The second part (Dependent part most of the time).
	-- @param [JointType] The type of joint. Defaults to weld.
	-- @param [WeldParent] Parent of the weld, Defaults to Part0 (so GC is better).
	-- @return The weld created.
 
	JointType = JointType or "Weld"
 
	local NewWeld = Instance.new(JointType)
	NewWeld.Part0  = Part0;
	NewWeld.Part1  = Part1;
	NewWeld.C0     = CFrame.new();
	NewWeld.C1     = Part1.CFrame:toObjectSpace(Part0.CFrame);
	NewWeld.Parent = WeldParent or Part0;
 
	return NewWeld
end]]

local Tool = script.Parent 
local Sword = Tool.Handle
local AbilityInput = (Tool:FindFirstChild("WingSlash") or Instance.new("RemoteFunction"));AbilityInput.Name = "WingSlash";AbilityInput.Parent = Tool

local Sounds = {
	Slash = Sword:WaitForChild("SlashSound")
	}

local Directory -- Used for Guiding for R6 and R15 animations
local Animations

Tool.Enabled = true 

-- The coolness factor 
local Fire_Part = Sword:WaitForChild("FirePart")
local Wing_Fire = Fire_Part:WaitForChild("WingFire")
--[[function CreateFire()
	Fire_Part = (Sword:FindFirstChild("FirePart") or Instance.new("Part"));Fire_Part.Name = "FirePart"
	Fire_Part.Size = Vector3.new(0.2,0.2,0.2)
	Fire_Part.Transparency = 1
	Fire_Part.CanCollide = false
	
	Wing_Fire =(Fire_Part:FindFirstChild("WingFire") or Instance.new("Fire"));Wing_Fire.Name = "WingFire"
	Wing_Fire.Color = Color3.fromRGB(51, 102, 153)
	Wing_Fire.SecondaryColor = Color3.fromRGB(165, 0, 33)
	Wing_Fire.Heat = 25
	Wing_Fire.Size = 4
	Wing_Fire.Parent = Fire_Part
	
	Fire_Part.CFrame = Sword.CFrame*CFrame.new(0,-1,0)
	Fire_Part.Parent = Sword
	if not Tool:FindFirstChild("JointInstance") then
	WeldTogether(Sword,Fire_Part,"Weld",Fire_Part)	
	end
end]]


-- Flat damage, it also has burst using the WingCutter
local Damage = 19

local Debris = (game:FindService("Debris") or game:GetService("Debris"))
local Players = (game:FindService("Players") or game:GetService("Players"))

local Effect_Part = Instance.new('Part')
Effect_Part.FormFactor =3
Effect_Part.Size = Vector3.new(2, 2, 2)
Effect_Part.Name = 'WingCutter'

-- TODO: Add the mesh and texture IDs 
local Effect_Mesh = Instance.new('SpecialMesh')
Effect_Mesh.Scale = Vector3.new(1, 1, 1)
Effect_Mesh.Parent = Effect_Part

local Effect_Fire = Wing_Fire:Clone()
--Effect_Fire.Heat = 25 
--Effect_Fire.Size = 5
Effect_Fire.LockedToPart = false
Effect_Fire.Parent = Effect_Part

local IsHeld = false
local Character
local Humanoid
local Torso
function blow(hit)	
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid ~= Humanoid and Humanoid and not IsTeamMate(Players:GetPlayerFromCharacter(Character),Players:GetPlayerFromCharacter(humanoid.Parent)) then 			
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid,Players:GetPlayerFromCharacter(Character))
			humanoid:TakeDamage(Damage)
			if Wing_Fire and Wing_Fire.Enabled == true then
				spawn(function()
					local Root = (humanoid.Parent:FindFirstChild("HumanoidRootPart") or humanoid.Parent:FindFirstChild("Torso"))
					if humanoid and humanoid.Parent and Root and not Root:FindFirstChild("WingFire") and not IsTeamMate(Players:GetPlayerFromCharacter(Character),Players:GetPlayerFromCharacter(humanoid.Parent)) then
						local cFire = Wing_Fire:Clone()
						cFire.Parent = Root
						Debris:AddItem(cFire, 4) 
						local duration = 4
						while duration > 0 do
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid,Players:GetPlayerFromCharacter(Character))
							humanoid:TakeDamage(5)
							duration = duration - 1 
							wait(1.0) 
						end 
					end 
				end)
			end 
		end 
	end 
end

function onEquipped()
	--CreateFire()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = (Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart"))
	
	Directory = Tool:WaitForChild(Humanoid.RigType.Name)
	Animations = {
	Charge = Directory:WaitForChild("ChargeAnim"),
	Slash = Directory:WaitForChild("SlashAnim"),
	Stab = Directory:WaitForChild("StabAnim"),
	Wing = Directory:WaitForChild("WingAnim")
	}
	--Wing_Fire.Enabled = true
end 

function onUnequipped()	
	IsHeld = false
	--CreateFire()
end

Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)
Tool.Activated:Connect(function()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	IsHeld = true
	local currentSpeed = Humanoid.WalkSpeed
	local ChargeAnim = Humanoid:LoadAnimation(Animations.Charge)
	if ChargeAnim then ChargeAnim:Play() end
	while IsHeld do
		Humanoid.WalkSpeed = math.min(Humanoid.WalkSpeed + 0.1, 22) 
		Wait(0.1)
	end
	local Anim 
	if ChargeAnim then ChargeAnim:Stop();
	local index = math.random(1,2)
	Anim = ((index>1 and Animations.Stab) or Animations.Slash)
	local SlashingAnim = Humanoid:LoadAnimation(Anim)	
		if SlashingAnim then
			SlashingAnim:Play()
		end	
	end
	if Sounds.Slash then Sounds.Slash:Play() end
	if Anim == Animations.Stab then
	Tool.Grip = CFrame.new(0, -2.5, 0, 1, -0, 0, 0, 0, -1, 0, 1, 0)
	end
	Wait(1.3)
	Tool.Grip = CFrame.new(0, -2.5, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0)
	Humanoid.WalkSpeed = (currentSpeed > 0 and currentSpeed) or 16
	Tool.Enabled = true
end)
Tool.Deactivated:Connect(function()
	IsHeld = false
end)
Sword.Touched:Connect(blow)

local function IsInTable(Table,Value)
	for i,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function IsCharacterFlying(char) -- helps check if person is flying
	local FlightClasses = {"BodyPosition","BodyThrust","BodyVelocity"}
	if char then
		for i,v in pairs(FlightClasses) do
			if char:FindFirstChildWhichIsA(v,true) then
				return true
			end
		end
	end
	return false
end

local Special = true
function AbilityInput.OnServerInvoke(Player,Key)
	if not Key == Enum.KeyCode.Q then return end
	if not Special then return end
	Special = false
		local WingAnim = Humanoid:LoadAnimation(Animations.Wing)
		if Humanoid and WingAnim then
			WingAnim:Play()
		end
		Humanoid.WalkSpeed = 0
		Wait(1.25)
		Humanoid.WalkSpeed = 16
		for i,v in pairs(Players:GetPlayers()) do
			if v and v~= Player and v.Character then
				local Root = (v.Character:FindFirstChild("Torso") or v.Character:FindFirstChild("HumanoidRootPart"))
				local EnemyHumanoid = v.Character:FindFirstChildOfClass("Humanoid")
				if Root and (Root.CFrame.p-Torso.CFrame.p).magnitude<=Range then
					local GearFound = v.Character:FindFirstChildOfClass("Tool")
					if GearFound and IsCharacterFlying(v.Character) and not IsTeamMate(Player,v) then
						Root.Anchored = true
						if EnemyHumanoid then
							EnemyHumanoid:UnequipTools()
						end
						
						GearFound:Destroy()
						
						local ePart = Effect_Part:Clone()
						ePart.CFrame = Torso.CFrame 
						ePart.CanCollide = false 

						local bForce = Instance.new('BodyForce')
						bForce.Name = 'Float'
						bForce.force = Vector3.new(0, ePart:GetMass() * 196.2, 0)
						bForce.Parent = ePart 

						-- I know, this is super fast, but that's how I roll 
						ePart.Velocity = (Root.CFrame.p - Torso.CFrame.p).unit * 200.0 
						ePart.Parent = workspace

						Debris:AddItem(ePart, 5)
						local TouchedHumanoids = {}
						ePart.Touched:Connect(function(hit)
						local Hum = hit.Parent:FindFirstChildOfClass("Humanoid") 
							if hit and hit.Parent and Root and Hum ~= Humanoid then 
								if Hum and not IsInTable(TouchedHumanoids,Hum) then 
									TouchedHumanoids[#TouchedHumanoids+1]=Hum
									print("Damaging " ..Hum.Parent.Name)
									UntagHumanoid(Hum)
									TagHumanoid(Hum,Player)
									Hum:TakeDamage(65)
								end 
							end 
						end) 
						
						if not v.Character:FindFirstChild('UnwingScript') then 
							local tScript = script.UnwingScript:Clone()
							tScript.Parent = v.Character
							tScript.Disabled = false 
						end 
					end
					--Root.Anchored = true
					
					
						
				end
			end
		end
Wait(20)
Special = true

	
	end


