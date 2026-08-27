--Rescripted by TakeoHonorable
--This script doesn't really initiate until the Motor6D has been sucessfully added

local Game = game

local FindService,GetService = Game.FindService,Game.GetService

local wrap,udim2,floor,Pairs,Tick,Instant,Type,Vec3,huge,Wait = coroutine.wrap,UDim2.new,math.floor,pairs,tick,Instance.new,type,Vector3.new,math.huge,wait

local function ObtainService(ServiceName)
	return FindService(Game,ServiceName) or GetService(Game,ServiceName)
end

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

local Services = {
	RunService = ObtainService("RunService"),
	Players = ObtainService("Players"),
	Debris = ObtainService("Debris")
}

local Self = script

local ShieldUI = Self:WaitForChild("ShieldUI"):Clone()

local Tool = Self.Parent

local Player = Services.Players.LocalPlayer

local Character,Humanoid

local Animations = {}

local Connections = {}

local Ready = true
local Activate,Deactivate 

function Equipped()
	
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	local SoundRemote = Tool:FindFirstChild("PlayEffect")
	
	if not Humanoid or Humanoid.Health <= 0 then return end
	
	Animations = Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name)
	Animations = {
		Equip = Humanoid:LoadAnimation(Animations:WaitForChild("Equip")),
		Idle = Humanoid:LoadAnimation(Animations:WaitForChild("Idle")),
		WindUp = Humanoid:LoadAnimation(Animations:WaitForChild("WindUp")),
		MultiSlash = Humanoid:LoadAnimation(Animations:WaitForChild("MultiSlash")),
		Slash = Humanoid:LoadAnimation(Animations:WaitForChild("Slash"))
	}
	
	local RightLimb = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	
	repeat
		Services.RunService.RenderStepped:Wait()
	until RightLimb:FindFirstChild("RightGrip_Motor") --Found it!
	
	--print("Found the Motor!")
	
	wrap(function()
		
		local ProgressFrame,Status = ShieldUI:FindFirstChild("Progress",true),ShieldUI:FindFirstChild("Status",true)
		
		local ShieldHealth = Tool:WaitForChild("ShieldHealth")
		
		local function UpdateShieldInfo(CurrentHealth,MaxHealth)
			
			ProgressFrame.Size = udim2(ProgressFrame.Size.X.Scale,ProgressFrame.Size.X.Offset,CurrentHealth/MaxHealth ,ProgressFrame.Size.Y.Offset)
			Status.Text = floor(CurrentHealth).."/"..floor(MaxHealth)
		
		end
		
		ShieldUI.Parent = Player:WaitForChild("PlayerGui")
		ShieldUI.Enabled = true
		UpdateShieldInfo(ShieldHealth.Value,ShieldHealth.MaxValue)
		Connections[#Connections+1] = ShieldHealth.Changed:Connect(function()
			UpdateShieldInfo(ShieldHealth.Value,ShieldHealth.MaxValue)
		end)
		
	end)()
	
	--Initiate Client Animations
	
	Animations.Equip:Play(0,nil,3)
	Animations.Idle:Play()
	--Animations.Slash:Play()
	local WindUpTime = 0
	if Activate then Activate:Disconnect();Activate=nil end
	if Deactivate then Deactivate:Disconnect();Deactivate=nil end
	Activate = Tool.Activated:Connect(function()
		
		if not Humanoid or Humanoid.Health <= 0 or not Ready then return end
		
		WindUpTime = Tick()
		Animations.WindUp:Play(.25,nil,3.5)
		
		if Deactivate then Deactivate:Disconnect();Deactivate=nil end
		Deactivate = Tool.Deactivated:Connect(function()
			if Deactivate then Deactivate:Disconnect();Deactivate=nil end
			if not Humanoid or Humanoid.Health <= 0 or not Ready then return end
			Ready = false
			Animations.WindUp:Stop(nil,nil,2)
			
			if (Tick()-WindUpTime) >= .3 then
				
				if SoundRemote then
					SoundRemote:FireServer("RapidSlash")
				end
				--print("Dashing")
				
				Animations.MultiSlash:Play(nil,nil,4)
				
				local Dash = Create("BodyVelocity"){
					MaxForce = Vec3(1,1,1) * huge,
					Velocity = (Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")).CFrame.LookVector * 200,
					Parent = (Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso"))
				}
				Services.Debris:AddItem(Dash,.1)
				Wait(.5)
			else
				Animations.Slash:Play(0,1,4)
				if SoundRemote then
					SoundRemote:FireServer("Slash")
				end
			end
			Ready = true
		
		end)
		
	end)
	

	
end

function Unequipped()
	if Activate then Activate:Disconnect();Activate = nil end
	if Deactivate then Deactivate:Disconnect();Deactivate = nil end
	for i=1,#Connections,1 do
		if Connections[i] then
			Connections[i]:Disconnect()
		end
	end
	Connections = {}
	
	for _,anim in Pairs(Animations) do
		if anim then
			anim:Stop(.2,nil,1)
		end
	end
	
	ShieldUI.Parent = nil
	
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)