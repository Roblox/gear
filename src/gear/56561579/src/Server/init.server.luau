--Rescripted by TakeoHonorable

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

Handle:WaitForChild("Smoke").Enabled = true

local SpellGui = Tool:WaitForChild("SpellGui"):Clone()

local EffectsFolder = Tool:WaitForChild("Effects")

local BookSound = Handle:WaitForChild("BookSound")

local Remote = Tool:WaitForChild("ClientInput")
local MouseLoc = Tool:WaitForChild("MouseLoc")

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
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	TweenService = game:FindService("TweenService") or game:GetService("TweenService")
}

local MyPlayer,MyCharacter,MyHumanoid,MyTorso

local spikePart = Instance.new("Part")
spikePart.Size = Vector3.new(20, 4.5, 22)
spikePart.Shape = "Block"
spikePart.FormFactor = 3
spikePart.CanCollide = false 
spikePart.CFrame = spikePart.CFrame 

local spikeMesh = Instance.new("SpecialMesh")
spikeMesh.MeshId = "http://www.roblox.com/asset/?id=56440892"
spikeMesh.TextureId = "http://www.roblox.com/asset/?id=56441142"
spikeMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
spikeMesh.Offset = Vector3.new(0,0,-2.5)
spikeMesh.Parent = spikePart


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
		Icon.Image = BaseUrl.."56508337"
		spawn(function()
			local MousePos = MouseLoc:InvokeClient(MyPlayer)
			
			local Orb = Instance.new("Part")
			Orb.TopSurface = Enum.SurfaceType.Smooth
			Orb.BottomSurface = Enum.SurfaceType.Smooth
			Orb.Color = Color3.fromRGB(170, 0, 255)
			Orb.Material = Enum.Material.Neon
			Orb.Transparency = 0.4
			Orb.Shape = Enum.PartType.Ball
			Orb.Size = Vector3.new(2,2,2)
			Orb.Anchored = false
			Orb.CanCollide = false
			Orb.CFrame = CFrame.new(Handle.CFrame.p)
			Orb.Velocity = (MousePos-Handle.CFrame.p).unit*100
			
			local Light = Instance.new("PointLight")
			Light.Color = Orb.Color
			Light.Range = 7
			Light.Brightness = 10
			Light.Parent = Orb
			Light.Enabled = true
			
			local Aura = EffectsFolder:WaitForChild("Smoke"):Clone()
			Aura.Parent = Orb
			Aura.Enabled = true
			
			local Force = Instance.new("BodyForce")
			Force.Force = Vector3.new(0,Orb:GetMass()*workspace.Gravity,0)
			Force.Parent = Orb
			
			Orb.Parent = workspace
			
			Orb:SetNetworkOwner(MyPlayer) -- no lagging visuals
			
			Services.Debris:AddItem(Orb,4)
			
			Orb.Touched:Connect(function(hit) Blow(Orb, hit, Properties.OrbDamage) end)
		end)
			
		for timer=5,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."56465749"
		Spell1 = true
		end,
		
	["Root"] = function()
		if not Spell2 then return end
		Spell2 = false
		
		Handle:WaitForChild("BookSound"):Play()
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
			
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."56508353"
		spawn(function()
			local TorsoCFrame = MyTorso.CFrame 
			
			spikeClone = spikePart:Clone()						
			spikeClone.CanCollide = false
			spikeClone.Anchored = true
			local StartCFrame = (TorsoCFrame *CFrame.new(0,-5,0))* CFrame.Angles(0, 0, math.pi)
			local FinishCFrame = (TorsoCFrame *CFrame.new(0,-.5,0))* CFrame.Angles(0, math.rad(-90), math.pi)
			spikeClone.CFrame = StartCFrame
			spikeClone.Parent = workspace
			
			spikeClone.Touched:Connect(function(hit) Blow(spikeClone, hit, Properties.SpikeDamage) end)
			
			Services.Debris:AddItem(spikeClone,10)
			
			local SpinTweenInfo = TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0)
			
			local SpinTween = Services.TweenService:Create(spikeClone,SpinTweenInfo,{CFrame = FinishCFrame})
			SpinTween:Play();SpinTween.Completed:Wait()
			
			wait(4)
			
			SpinTween = Services.TweenService:Create(spikeClone,SpinTweenInfo,{CFrame = StartCFrame})
			SpinTween:Play();SpinTween.Completed:Wait()
			
			if spikeClone then spikeClone:Destroy() end
			
			
		end)
		for timer=12,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."56465796"
		Spell2 = true
	end,
	["Stun"] = function()
		if not Spell3 then return end
		Spell3 = false
		
		Handle:WaitForChild("BookSound"):Play()
		
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
		
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."56508371"
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
						local VineScript = script:WaitForChild("RootScript"):Clone()
						VineScript.Parent = Hum.Parent
						VineScript.Disabled = false
					end
				end
		end)
		for timer=15,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."56465831"
		Spell3 = true
	end
}

function Equipped()
	MyCharacter = Tool.Parent;
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid");
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter);
	MyTorso = MyCharacter:WaitForChild("HumanoidRootPart")
	SpellGui.Parent = MyPlayer:WaitForChild("PlayerGui")
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Orb").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Orb"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Root").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Root"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Stun").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Stun"),SpellGui)
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
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Root"),SpellGui)
	elseif KeyCode == Enum.KeyCode.R then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Stun"),SpellGui)
	end
end)