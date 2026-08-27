--Rescripted by TakeoHonorable

--Motorizes grip for better looking sword animations

local Properties = {
	MaxShieldDurability = 400,
	ShieldRegenerationIncrement = 5,
	ShieldRegenerationTime = .5,
	Damage = 15
}

local Self = script

local Tool = Self.Parent

local Handle = Tool:WaitForChild("Handle")

local ShieldUI = Self:WaitForChild("ShieldUI"):Clone()

local Character,Humanoid,Player

local Game = game

local FindService,GetService = Game.FindService,Game.GetService
local function ObtainService(ServiceName)
	return FindService(Game,ServiceName) or GetService(Game,ServiceName)
end


local Services = {
	Players = ObtainService("Players"),
	Debris = ObtainService("Debris"),
	RunService = ObtainService("RunService")
}

local Instant,Pairs,Type,sign,abs,wrap,Wait,Pcall,clamp,Delay = Instance.new,pairs,type,math.sign,math.abs,coroutine.wrap,wait,pcall,math.clamp,delay

local Cframe,Vec3 = CFrame.new,Vector3.new

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
	Name = "creator",
	Value = player,
	}
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in Pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CastScripts(Duration,ScriptEntries) -- Could be used for ServerScripts, but we'll use LocalScripts in this case
	local LoggedScripts = {} -- Keeps track of the current scripts
	local Players = Services.Players:GetPlayers()
	for p=1,#Players do
		if Players[p] then
			for i=1,#ScriptEntries do
				if ScriptEntries[i] and ScriptEntries[i]:IsA("LocalScript") and Players[p]:FindFirstChild("PlayerGui")then
					local Clone = ScriptEntries[i]:Clone()
					Clone.Parent = Players[p]:FindFirstChild("PlayerGui") -- The best spot to place it at
					Clone.Disabled = false
					LoggedScripts[#LoggedScripts+1] = Clone
				end
			end
		end
	end
	
	local function Clean()
		--print("CLEANING")
		for s=1,#LoggedScripts do
			
			if LoggedScripts[s] then
				--LoggedScripts[s]:Destroy()
				Services.Debris:AddItem(LoggedScripts[s],(Duration or 1))
			end
		end
		LoggedScripts = {} -- Clear the Memory
	end
	
	Clean()
	
end

local Deletables = {}

local Connections = {}

local Sounds = {	
	Equip = Handle:WaitForChild("Equip"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	ShieldHit = Self:WaitForChild("ShieldHit")
}

local Shield = Create'Part'{
	Name = 'Shield';
	Size = Vec3(2.8,1,3.8);
	Massless = true,
	Anchored = false,
	Locked = true,
	CanCollide = false;
	Create'SpecialMesh'{
		Scale = Vec3(2, 1.2, 2);
		TextureId = 'http://www.roblox.com/asset/?id=73012518';
		MeshId = 'http://www.roblox.com/asset/?id=73012430';
	};
}

local ShieldHealth = Tool:FindFirstChild("ShieldHealth") or Create("DoubleConstrainedValue"){
	Name = "ShieldHealth",
	MaxValue = Properties.MaxShieldDurability,
	MinValue = 0,
	Value = Properties.MaxShieldDurability,
	Parent = Tool
}
ShieldHealth.MaxValue = Properties.MaxShieldDurability
ShieldHealth.MinValue = 0
ShieldHealth.Value = Properties.MaxShieldDurability

local EffectRemote = Tool:FindFirstChild("PlaySound") or Create("RemoteEvent"){
	Name = "PlayEffect",
	Parent = Tool
}

local EffectAction = {
	["RapidSlash"] = {
		Ready = true,
		Cooldown = .45,
		Function = function()
			wrap(function()
				local DashEffect = Self:WaitForChild("DashEffect"):Clone()
				Create("ObjectValue"){
					Name = "Character",
					Value = Character,
					Parent = DashEffect
				}
				CastScripts(.5,{DashEffect})
			end)()
			Sounds.Lunge:Play()
			Wait(.1)
			Sounds.Slash:Play()
			Wait(.2)
			Sounds.Lunge:Play()
		end
	},
	["Slash"] = {
		Ready = true,
		Cooldown = 0,
		Function = function()
			Sounds.Slash:Play()
		end
	}
}

function Equipped()
	
	Character = Tool.Parent
	
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	Player = Services.Players:GetPlayerFromCharacter(Character)
	
	local RightLimb = (Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"))
	
	local LeftLimb = (Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftUpperArm"))
	
	if not Humanoid or Humanoid.Health <= 0 or not RightLimb or not RightLimb.Parent  or not Handle or not Handle.Parent then return end
	
	local ShieldClone = Shield:Clone()
	Deletables[#Deletables+1] = ShieldClone
	
	local ShieldMotor = Create("Motor6D"){
		--Name = "Shield",
		Part0 = LeftLimb,
		Part1 = ShieldClone,
		Parent = ShieldClone
	}
	Deletables[#Deletables+1] = ShieldMotor
	
	local SwordMotor = Create("Motor6D"){
		Name = "RightGrip_Motor",
		Part0 = RightLimb,
		Part1 = Handle
	
	}
	Deletables[#Deletables+1] = SwordMotor
	
	wrap(function()
		Services.RunService.Heartbeat:Wait()
		local RightGrip = RightLimb:FindFirstChild("RightGrip")
		
		if RightGrip then
			--Motor.C0 = RightGrip.C0
			--Motor.C1 = RightGrip.C1
			RightGrip.Part0 = nil
			RightGrip.Part1 = nil
		end
		
	end)()

	SwordMotor.Parent = RightLimb
	--ShieldMotor.Parent = ShieldClone
	ShieldClone.Parent = LeftLimb
	
	Sounds.Equip:Play()
	
	local CurrentHealth = Humanoid.Health
	local IgnoreDamage = false
	Connections[#Connections+1] = Humanoid.HealthChanged:Connect(function(NewHealth)
		
		local Damage = (CurrentHealth - NewHealth)
		
		if not IgnoreDamage and sign(Damage) > -1 then
				
			local Remainder = (ShieldHealth.Value - Damage)
			
			if sign(Damage) > -1 then
				ShieldHealth.Value = Remainder
				
				local ShieldHitClone = Sounds.ShieldHit:Clone()
				
				ShieldHitClone.Volume = clamp((Damage/Properties.MaxShieldDurability) * 5,.5,10)
				ShieldHitClone.Parent = ShieldClone
				--print(Damage)
				ShieldHitClone:Play()
				Delay(ShieldHitClone.TimeLength,function()
					if ShieldHitClone then
						ShieldHitClone:Destroy()
					end
				end)
				
			end
				
			--print(Remainder)
			IgnoreDamage = true
			Humanoid.Health = CurrentHealth
			if sign(Remainder) < 0 then
				Humanoid:TakeDamage(abs(Remainder))
			end
			IgnoreDamage = false
		
		end 
		
		CurrentHealth = Humanoid.Health
		--IgnoreDamage = false
	end)
	
	--Display the current health of the shield to other players
	wrap(function()
		
		local function ModifyUITransparency(Alpha)
			for _,obj in Pairs(ShieldUI:GetChildren()) do
				if obj:IsA("ImageLabel") then
					obj.ImageTransparency = Alpha
				elseif obj:IsA("TextLabel") then
					obj.TextTransparency = Alpha
					obj.TextStrokeTransparency = Alpha
				end
			end
		end
		ShieldUI.PlayerToHideFrom = Player
		local Center,Head = (Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")),Character:WaitForChild("Head")
		ShieldUI.Adornee = Center
		ShieldUI.Status.Text = ShieldHealth.Value.."/"..ShieldHealth.MaxValue
		ShieldUI.Parent = Center
		ShieldUI.Enabled = true
		
		Connections[#Connections+1] = ShieldHealth.Changed:Connect(function()
			ShieldUI.Status.Text = ShieldHealth.Value.."/"..ShieldHealth.MaxValue
		end)
		
		ModifyUITransparency(Head.Transparency)
		Connections[#Connections+1] = Head:GetPropertyChangedSignal("Transparency"):Connect(function()
			ModifyUITransparency(Head.Transparency)
		end)
		
		Connections[#Connections+1] = EffectRemote.OnServerEvent:Connect(function(client,ActionName)
			if client ~= Player then return end
			
			wrap(function()
				Pcall(function()
					if EffectAction[ActionName].Ready then
						EffectAction[ActionName].Ready = false
						Delay(EffectAction[ActionName].Cooldown,function()
							EffectAction[ActionName].Ready = true
						end)
						EffectAction[ActionName].Function()
					end
				end)
			end)()
			
		end)
		
		Connections[#Connections+1] = Handle.Touched:Connect(function(hit)
			if not hit or not hit.Parent then return end
			
			local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
			
			if not Hum or Hum.Health <= 0 or FF or Hum == Humanoid then return end
			
			if IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
			
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum:TakeDamage(Properties.Damage)
			
		end)
		
	end)()
	
	
end


function Unequipped()
	
	ShieldUI.Adornee = nil
	ShieldUI.Enabled = false
	ShieldUI.Parent = nil
	
	for i=1,#Deletables,1 do
		if Deletables[i] then
			Deletables[i]:Destroy()
		end
	end
	Deletables = {}
	
	for i=1,#Connections,1 do
		if Connections[i] then
			Connections[i]:Disconnect()
		end
	end
	Connections = {}
	
end


Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

wrap(function()
	repeat
		Wait(Properties.ShieldRegenerationTime)
		ShieldHealth.Value = ShieldHealth.Value + Properties.ShieldRegenerationIncrement
	until not ShieldHealth
end)()


