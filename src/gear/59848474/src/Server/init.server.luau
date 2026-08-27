--Rescripted by TakeoHonorable

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

Handle:WaitForChild("Smoke").Enabled = true

local SpellGui = Tool:WaitForChild("SpellGui"):Clone()

local EffectsFolder = Tool:WaitForChild("Effects")

local BookSound = Handle:WaitForChild("BookSound")

local Remote = Tool:WaitForChild("ClientInput")
--local MouseLoc = Tool:WaitForChild("MouseLoc")

local ChosenSpellTag -- Dosen't do anything until a spell is chosen

local BaseUrl = "http://www.roblox.com/asset/?id="

local Properties = {
	CurrentRadius = 45,
	SpikeDamage = 30,
	OrbDamage = 30,
	MaxVineStunTime = 3.5
}

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Players = (game:FindService("Players") or game:GetService("Players")),
}

local MyPlayer,MyCharacter,MyHumanoid,MyTorso

local spikePart = Instance.new("Part")
spikePart.Size = Vector3.new(1, 2, 1)*2
spikePart.Shape = "Block"
spikePart.Name = "Spike"
spikePart.CanCollide = false

local spikeMesh = Instance.new("SpecialMesh")
spikeMesh.MeshId = "http://www.roblox.com/asset/?id=59092052"
spikeMesh.TextureId = "http://www.roblox.com/asset/?id=59801821"
spikeMesh.Scale = spikeMesh.Scale*3
spikeMesh.Parent = spikePart

local SmokeParticles = EffectsFolder:WaitForChild("Smoke"):Clone()
SmokeParticles.Parent = spikePart
SmokeParticles.Enabled = true

local ropePart = Instance.new("Part")
ropePart.Size = Vector3.new(1,1,1)*3
ropePart.Shape = Enum.PartType.Ball
ropePart.Material = Enum.Material.Glass
ropePart.Transparency = 0.8
ropePart.Name = "rope"
ropePart.CanCollide = false

local SmokeParticles = EffectsFolder:WaitForChild("Smoke"):Clone()
SmokeParticles.Parent = ropePart
SmokeParticles.Enabled = true


local float = Instance.new("BodyForce")
--float.force = Vector3.new(0.0, ropePart:GetMass() * 196.1, 0.0)
float.Name = "Floating" 


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end
	
function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function Blow(Part,hit,DamageCount)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not Hum or Hum == MyHumanoid then return end
	local Char = Hum.Parent
	if IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Char)) then return end
	UntagHumanoid(Hum)
	TagHumanoid(Hum)
	--print("Damaging")
	Hum:TakeDamage(DamageCount)
end

local IconConnections = {}

local function SelectSpell(ChosenSpell,SpellUI)
	--print("Choosing Spell")
	if not SpellGui or not ChosenSpell then return end
	for _,v in pairs(SpellUI:GetDescendants()) do
		if v.Name == "Flavor" then
			v.Visible = v.Parent == ChosenSpell
		end
	end
	ChosenSpellTag = ChosenSpell.Name
end


local Spell1,Spell2,Spell3 = true,true,true -- Allows for consecutive reloads

local SpellFunctions = {
	["Orb"] = function()
		if not Spell1 then return end
		Spell1 = false
		
		Handle:WaitForChild("BookSound"):Play()
		
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
		
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."59791874"
		spawn(function()
			for i=1,2,1 do
				if not MyTorso then break end
				local fireballs = {}
				local offset = 4.0
				for i = 1, 12 do
					fireballs[i] = ropePart:Clone()
					fireballs[i].Parent = workspace          		
					if i < 4 then
						fireballs[i].Position = MyTorso.Position + Vector3.new(i * offset, 20.0, 0.0)
					elseif i < 7 then
						fireballs[i].Position = MyTorso.Position + Vector3.new(0.0, 20.0, (i - 3)* offset)
					elseif i < 10 then
						fireballs[i].Position = MyTorso.Position + Vector3.new(0.0, 20.0, (i-6) * -offset)
					else
						fireballs[i].Position = MyTorso.Position + Vector3.new((i-9) * -offset, 20.0, 0.0)
					end
					local floatForce = Instance.new("BodyForce")
					floatForce.Force = Vector3.new(0, fireballs[i]:GetMass() * 100.0, 0) 
					floatForce.Parent = fireballs[i]
			
					Services.Debris:AddItem(fireballs[i], 3.5)          
					fireballs[i].Anchored = true
					fireballs[i].Touched:Connect(function(hit) Blow(fireballs[i], hit, Properties.OrbDamage) end)		
				end
					
				wait(0.3)
				
				for i = 1, #fireballs do 
					fireballs[i].Anchored = false 
					fireballs[i]:SetNetworkOwner(MyPlayer)
				end
				wait(1.5)
			end	
		end)
			
		for timer=5,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."59791591"
		Spell1 = true
		end,
		
	["Spike"] = function()
		if not Spell2 then return end
		Spell2 = false
		
		Handle:WaitForChild("BookSound"):Play()
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
			
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."59802033"
		spawn(function()
			for i = 1, 12 do
				local pos = CFrame.Angles(0, i * math.pi/6, 0) * MyTorso.CFrame.lookVector

				local spawnPos = MyTorso.CFrame.p
				spawnPos = spawnPos + (pos * 5.0)
		
				local spikeProjectile = spikePart:Clone()
				spikeProjectile.Name = "rope"
				spikeProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0)
				local floatForce = float:Clone()
				floatForce.Force = Vector3.new(0, spikeProjectile:GetMass() * workspace.Gravity, 0)
				floatForce.Parent = spikeProjectile
				spikeProjectile.Velocity = pos * 75.0
				spikeProjectile.Parent = workspace
				spikeProjectile:SetNetworkOwner(MyPlayer)
				spikeProjectile.Touched:Connect(function(hit) Blow(spikeProjectile, hit, Properties.SpikeDamage) end)
				Services.Debris:AddItem(spikeProjectile, 4)
			end
		end)
		for timer=10,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."59791072"
		Spell2 = true
	end,
	["Prison"] = function()
		if not Spell3 then return end
		Spell3 = false
		
		Handle:WaitForChild("BookSound"):Play()
		
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
		
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."59791906"
		spawn(function()
			local NegativeRegion = (MyTorso.Position - Vector3.new(Properties.CurrentRadius, Properties.CurrentRadius, Properties.CurrentRadius))
			local PositiveRegion = (MyTorso.Position + Vector3.new(Properties.CurrentRadius, Properties.CurrentRadius, Properties.CurrentRadius))
				local Region = Region3.new(NegativeRegion, PositiveRegion)
				local Parts = workspace:FindPartsInRegion3(Region,MyCharacter,math.huge)
				local TaggedHumanoids = {}
				for _,hit in pairs(Parts) do
					local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
					local Center = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("HumanoidRootPart") or hit.Parent:FindFirstChild("UpperTorso")
					if Hum and Hum.Health ~= 0 and Hum ~= MyHumanoid and not IsInTable(TaggedHumanoids,Hum) and Center and not IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
						table.insert(TaggedHumanoids,Hum)
						local VineScript = script:WaitForChild("PrisonScript"):Clone()
						VineScript.Parent = Hum.Parent
						VineScript:WaitForChild("creator").Value = MyPlayer
						VineScript:WaitForChild("Duration").Value = math.clamp(((1-(Center.CFrame.p-MyTorso.CFrame.p).magnitude/Properties.CurrentRadius)),0,1)*Properties.MaxVineStunTime
						VineScript.Disabled = false
					end
				end
		end)
		for timer=15,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."59791781"
		Spell3 = true
	end
}

function Equipped()
	MyCharacter = Tool.Parent;
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid");
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter);
	MyTorso = MyCharacter:WaitForChild("HumanoidRootPart")
	SpellGui.Parent = MyPlayer:WaitForChild("PlayerGui")
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Spike").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Spike"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Prison").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Prison"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Orb").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Orb"),SpellGui)
	end)
end

function Unequipped()
	--MyCharacter,MyHumanoid,MyPlayer,MyTorso = nil,nil,nil,nil
	SpellGui.Parent = nil
	for _,v in pairs(IconConnections) do
		if v then
			v:Disconnect()
		end
	end
end

function Activated()
	if (MyCharacter and MyHumanoid) and MyHumanoid.Health ~= 0 and ChosenSpellTag then
		if ChosenSpellTag then
			--if not Tool.Enabled then return end
			--Tool.Enabled = false
			--print("Activated")

			SpellFunctions[ChosenSpellTag]()
			--Handle:WaitForChild("Smoke").Enabled = true
			--Tool.Enabled = true
		end
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

Remote.OnServerEvent:Connect(function(Player,KeyCode)
	if Player ~= MyPlayer or not MyCharacter or not MyHumanoid then return end
	
	if KeyCode == Enum.KeyCode.Q then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Orb"),SpellGui)
	elseif KeyCode == Enum.KeyCode.E then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Spike"),SpellGui)
	elseif KeyCode == Enum.KeyCode.R then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Prison"),SpellGui)
	end
end)