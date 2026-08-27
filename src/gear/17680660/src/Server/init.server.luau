function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Cframe,Angles,Vec3,rad = CFrame.new,CFrame.Angles,Vector3.new,math.rad

local Remote = (Tool:FindFirstChildOfClass("RemoteEvent") or Create("RemoteEvent"){
	Name = "Remote",
	Parent = Tool
})

local Grips = {
	Up = Cframe(0, 0, -2.29999995, -0.587933838, 0, 0.808908999, 0.808908999, -0, 0.587933838, 0, 1, 0),
}
local Events = {}
local Animations = {}
local Deletables = {}
local Player,Character,Humanoid,Torso

local Region = require(script:WaitForChild("RegionModule"))

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge")
}

local BatParticles = Handle:WaitForChild("Bats")
BatParticles.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

local function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
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
				Services.Debris:AddItem(LoggedScripts[s],(Duration or 1)+1)
			end
		end
		LoggedScripts = {} -- Clear the Memory
	end
	
	Clean()
	
end

local function HasFinisher(Hum) -- Quick check to see if they're not stunned
	local Children = Services.ServerScriptService:GetChildren()
	for i=1, #Children do
		if Children[i]:IsA("Script") and Children[i].Name == "Finisher" and Children[i]:FindFirstChild("Target") and Children[i]:FindFirstChild("Target").Value == Hum.Parent then
			return true
		end
	end
	return false
end

--[[local function VisualizeRay(ray,RayLength,Color)
	local RayCast = Create("Part"){
		Material = Enum.Material.Neon,
		Color = Color or Color3.new(0,1,0),
		Size = Vector3.new(0.3,0.3,(RayLength or 5)),
		CFrame = CFrame.new(ray.Origin, ray.Origin+ray.Direction) * CFrame.new(0, 0, -(RayLength or 5) / 2),
		Anchored = true,
		CanCollide = false,
		Parent = workspace
	}
	game:GetService("Debris"):AddItem(RayCast,0.5)
end]]


local ray = Ray.new
local Abilities = {
	[Enum.KeyCode.Q] = {
		Ready = true,
		Reload = 30,
		Function = function()
			--print("Executing bat transform ability")
			local BatTransform = script:WaitForChild("BatTransform"):Clone()
			delay(30,function()
				BatParticles.Enabled = true
			end)
			BatParticles.Enabled = false
			Create("ObjectValue"){
				Name = "Target",
				Value = Character,
				Parent = BatTransform
			}
			Create("NumberValue"){
				Name = "Duration",
				Value = 5,
				Parent = BatTransform
			}
			BatTransform.Parent = Services.ServerScriptService
			BatTransform.Disabled = false
		end
	},
	[Enum.KeyCode.E] = {
		Ready = true,
		Reload = 3.5,
		Function = function()
			--print("Executing Dash ability")
			--wait(.3)
			if not Tool:IsDescendantOf(Character) then return end
			Sounds.Lunge:Play()
			Tool.Grip = Grips.Up*Angles(math.rad(90),0,0)
			--print("Lunge")
			Create("StringValue"){
			Name = "toolanim",
			Value = "Lunge",
			Parent = Tool
			}
			wait(1/10)
			local cframe = Torso.CFrame
			local MaxDistance = 55
			local DashRay = ray(cframe.p,(cframe.lookVector).Unit * MaxDistance)
			local hit,pos = workspace:FindPartOnRayWithIgnoreList(DashRay,{Character},false,true)
			local ModifiedDistance = ((pos-cframe.p).Magnitude ~= MaxDistance and (pos-cframe.p).Magnitude - 5) or MaxDistance
			local final = Cframe((cframe * Cframe(0,0,-(ModifiedDistance)).p))*(cframe-cframe.p)--CFrame.new(pos)*(cframe-cframe.p)
			
			if Character.PrimaryPart then
				Character:SetPrimaryPartCFrame(final)
				Character.PrimaryPart.Velocity = Vec3(0,0,0)
			else
				Torso.CFrame = final
				Torso.Velocity = Vec3(0,0,0)
			end
			

			--VisualizeRay(DashRay,(pos-cframe.p).Magnitude+(2),Color3.new(0,1,0))
			local DashClient = script:WaitForChild("Dash"):Clone()
			Create("ObjectValue"){
				Name = "Torso",
				Value = Torso,
				Parent = DashClient
			}
			Create("Vector3Value"){
				Name = "EndPosition",
				Value = final.p,
				Parent = DashClient
			}
			Create("CFrameValue"){
				Name = "Begin",
				Value = cframe,
				Parent = DashClient
			}
			CastScripts(2,{DashClient})
			
			local HitHumanoids = {}
			local Cast = Region.new(cframe,Vec3(Torso.Size.X*3.5,Torso.Size.Y*3.5,(pos-cframe.p).Magnitude)):Cast({Character})
			for i=1,#Cast do
				if Cast[i] and Cast[i].Parent then
					local Hum,FF =  Cast[i].Parent:FindFirstChildOfClass("Humanoid"),Cast[i].Parent:FindFirstChildOfClass("ForceField")
					if Hum and not IsInTable(HitHumanoids,Hum) and not FF and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
						HitHumanoids[#HitHumanoids+1] = Hum
						if Services.Players:GetPlayerFromCharacter(Hum.Parent) then
							local Tool = Hum.Parent:FindFirstChildOfClass("Tool")
							if Tool then
								Tool.Parent = Player:WaitForChild("Backpack") -- Swipe their current tool
							end
						end
						Humanoid.Health = Humanoid.Health + 35 -- Gain heals from the as well
						Touched(Cast[i],35)
					end
				end
				--warn(Cast[i])
			end
			wait(1/2)
			Tool.Grip = Grips.Up
		end
	}
}

local stamp = 0
function Activated()
	if not Tool.Enabled then return end
	local Tick = tick()
	if (Tick-stamp) > .2 then
		--Slash
		--print("Slash")
		Sounds.Slash:Play()
		 Create("StringValue"){
			Name = "toolanim",
			Value = "Slash",
			Parent = Tool
		}
	
	else
		Tool.Enabled = false
		Sounds.Lunge:Play()
		Tool.Grip = Grips.Up*Angles(rad(90),0,0)
		--print("Lunge")
		Create("StringValue"){
		Name = "toolanim",
		Value = "Lunge",
		Parent = Tool
		}
		wait(.5)
		Tool.Grip = Grips.Up
		wait(.6)
		Tool.Enabled = true
		--Lunge
		
	end
	stamp = Tick
end

function Touched(hit,damage)
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if Hum and Hum ~= Humanoid and Hum.Health > 0 and not FF and not IsTeamMate(Player, Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		if (Hum.Health/Hum.MaxHealth)*100 <= 30 then
			if not HasFinisher(Hum)  then
				--Cue the finisher instead
				local Finisher = script:WaitForChild("Finisher"):Clone()
				Create("ObjectValue"){
					Name = "Target",
					Value = Hum.Parent,
					Parent = Finisher
				}
				Create("ObjectValue"){
					Name = "Creator",
					Value = Player,
					Parent = Finisher
				}
				Finisher.Parent = Services.ServerScriptService
				Finisher.Disabled = false
			end
		else
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Player)
			Hum:TakeDamage(damage or 0)
			
		end 
	end
end


function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
	if not Humanoid or Humanoid.Health <= 0 or not Character or not Torso then return end
	
	--[[Animations = Tool:WaitForChild("Animations")
	Animations = {
		EquipAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("EquipAnim")),
		ExecuteAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("ExecuteAnim")),
		IdleAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("IdleAnim")),
		SwingAnim = Humanoid:LoadAnimation(Animations:WaitForChild(Humanoid.RigType.Name):WaitForChild("SwingAnim"))
	}]]
	Events[#Events+1] = Tool.Activated:Connect(Activated)
	Events[#Events+1] = Remote.OnServerEvent:Connect(function(client,Key)
		if not Tool.Enabled or client ~= Player or not Key or Humanoid.Health <= 0 then return end
		if not Abilities[Key].Ready then return end
		Tool.Enabled = false
		Abilities[Key].Ready = false
		delay(Abilities[Key].Reload,function() Abilities[Key].Ready = true end)
		Abilities[Key].Function()--Execute the respective ability
		Tool.Enabled = true
	end)
	Events[#Events+1] = Handle.Touched:Connect(function(hit)
		Touched(hit,14)
	end)
	Sounds.Equip:Play()
end

function Unequipped()
		
	for _,anim in pairs(Animations) do
		if anim then
			anim:Stop()
		end
	end
	Animations = {}
	
	for i=1,#Events do
		if Events[i] then Events[i]:Disconnect();Events[i] = nil end
	end
	Events = {}
	
	for i=1,#Deletables do
		if Deletables[i] then Deletables[i]:Destroy() end
	end
	Deletables = {}
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)