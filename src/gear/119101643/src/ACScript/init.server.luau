local Tool = script.Parent 
local AC = Tool.Handle

local Player
local Character 

local Torso 
local Humanoid 

local Debris = Game:GetService('Debris')
Tool.Enabled = true 

local MAX_ACs = 18 
local CSB_Model_ID = 119114152
local InsertService = Game:GetService('InsertService')

local CSB_Model = InsertService:LoadAsset(CSB_Model_ID):GetChildren()[1]

local CSB_Sound = AC:WaitForChild('CSBSound')

local Targeted_Players = {} 

local PlayAnim = Tool:WaitForChild('PlayAnim')

local function FindPlayer()
	for _, player in pairs(Game.Players:GetPlayers()) do 
		if player and player ~= Player then 
			if not Targeted_Players[player] then 
				Targeted_Players[player] = 0  
			end 
			if Targeted_Players[player] < 1 then 
				Targeted_Players[player] = Targeted_Players[player] + 1 
				return player 
			end 			
		end 
	end 
	return nil 
end 

local function ShowCSB() 	
	local csb = CSB_Model:Clone() 
	csb.Parent = Game.Workspace 
	csb:MoveTo(Torso.Position + Vector3.new(0, 40, 0))

	Debris:AddItem(csb, 5)
end 
   
local function DropAC() 		
	local ifPlayer = false 
	for i = 1, math.random(MAX_ACs) do
		local targetPlayer = FindPlayer() 
		if targetPlayer then 
			local targetCharacter = targetPlayer.Character 
			if targetCharacter then 
				local targetTorso = targetCharacter:FindFirstChild('Torso')
				if targetTorso and (Torso.Position - targetTorso.Position).magnitude < 120 then 
					ifPlayer = true 
					local ac = AC:Clone() 
					ac.Transparency = 0.0 	
					ac.CanCollide = true 

					ac.Size = Vector3.new(4, 2.5, 4) 

					local fire = Instance.new('Fire')
					fire.Color = Color3.new(0, 0, 0.7)
					fire.Parent = ac 

					local pLight = Instance.new('PointLight')
					pLight.Color = Color3.new(0, 0, 0.7)
					pLight.Parent = ac

					ac.CFrame = targetTorso.CFrame + Vector3.new(0, 100, 0)
					ac.Velocity = (targetTorso.Position - ac.Position).unit * 20.0 
					ac.Parent = Game.Workspace 
					Debris:AddItem(ac, 5.0)

					local cSound = CSB_Sound:Clone()
					cSound.Parent = ac 
					local eScript = script:WaitForChild('ExplodeScript'):Clone()
					eScript.Parent = ac 
					eScript.Disabled = false
				end 
			end 
		end 
		wait(0.25)
	end 

	
	wait(2)
	ShowCSB()
	
	Targeted_Players = {} 
end 

local function CreateFakeClone()
	AC.Transparency = 1.0 
	local ac = AC:Clone() 
	ac.Transparency = 0.0 

	ac.CFrame = AC.CFrame 

	local bForce = Instance.new('BodyForce')
	bForce.force = Vector3.new(0, ac:GetMass() * 201, 0)
	bForce.Parent = ac 

	local fire = Instance.new('Fire')
	fire.Color = Color3.new(0, 0, 0.7)
	fire.Parent = ac 

	local pLight = Instance.new('PointLight')
	pLight.Color = Color3.new(0, 0, 0.7)
	pLight.Parent = ac

	ac.Parent = Game.Workspace 
	Debris:AddItem(ac, 1.5) 
end 

local function OnActivated()
	if not Tool.Enabled then 
		return 
	end 
	if not Torso or not Humanoid then 
		return 
	end 
	Tool.Enabled = false 	
	if PlayAnim and PlayAnim.Value == false then 
		PlayAnim.Value = true 
	end 
	wait(0.5)
	CreateFakeClone() 
	wait(1.0) 
	DropAC()			 
	wait(7.0)	
	Tool.Enabled = true 
	AC.Transparency = 0.0 
end

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character)

	Torso = Character:WaitForChild('Torso')
	Humanoid = Character:WaitForChild('Humanoid')
end 

local function OnUnequipped()
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated) 