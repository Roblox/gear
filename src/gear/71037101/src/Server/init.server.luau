--Rescripted by TakeoHonorable

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

local Remote = (Tool:FindFirstChildOfClass("RemoteEvent") or Create("RemoteEvent"){
	Name = "Remote",
	Parent = Tool
})

local MouseInput = (Tool:FindFirstChild("MousePos") or Create("RemoteFunction"){
	Name = "MousePos",
	Parent = Tool
})

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Player,Character,Root,Humanoid

local Animations = {}

local Particle = Handle:WaitForChild("Particle"):WaitForChild("Flare")
Particle.Enabled = true

local Sounds = {
	Lunge = Handle:WaitForChild("Lunge"),
}

local Events = {}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function daggerUp()	
	Tool.GripUp = Vector3.new(0, 0, 1)	
	Tool.GripForward = Vector3.new(-1, 0, 0)		
	Tool.GripRight = Vector3.new(0, 1, 0)				
	Tool.GripUp = Vector3.new(0, 0, 1)	
end

function daggerOut()
	Tool.Grip = Tool.Grip * CFrame.Angles(math.rad(90),math.rad(20),0)
end

local CurrentTime,LastTime = tick(),tick()
function Activated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	CurrentTime = tick()
	if (CurrentTime-LastTime) <= 0.2 then
		--Lunge
		daggerOut()
		Sounds.Lunge:Play()
		if Animations["Lunge"] then
			Animations.Lunge:Play()
		end
		--Components.PeriTrail.Enabled = true
		local sucess,MousePosition = pcall(function() return MouseInput:InvokeClient(Player) end)
		MousePosition = (sucess and MousePosition) or Vector3.new(0,0,0)
		
		local Direction = CFrame.new(Root.Position, Vector3.new(MousePosition.X, Root.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 75
		Services.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Root
		delay(.5,function()
			--Components.PeriTrail.Enabled = false
		end)
		Root.CFrame = CFrame.new(Root.CFrame.p,Root.CFrame.p+Direction.lookVector)
		coroutine.wrap(function()
			wait(.7)
			daggerUp()
		end)()
		wait(1)
		
		
	else
		--Swing
		if Animations["Stab"] then
			Animations.Stab:Play(nil,nil,5)
		end
		
	end
	LastTime = CurrentTime
	Tool.Enabled = true
end

function Touched(hit)
	if not hit or not hit.Parent then return end
	local Hum,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	if not Hum or Hum.Health <= 0 or FF  or Hum == Humanoid then return end
	if IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
	UntagHumanoid(Hum)
	TagHumanoid(Hum,Player)
	Hum:TakeDamage(15)
	
	if not Hum.Parent:FindFirstChild("SlowScript") then
		local Slow = script:WaitForChild("SlowScript"):Clone()
		Slow.Parent = Hum.Parent
		Slow.Disabled = false
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:FindFirstChild("HumanoidRootPart")
	
	if not Humanoid or Humanoid.Health <= 0 or not Root then return end
	Animations = {
		Lunge = Humanoid:LoadAnimation(Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name):WaitForChild("Lunge")),
		Stab = Humanoid:LoadAnimation(Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name):WaitForChild("Stab")),
		TimeStop = Humanoid:LoadAnimation(Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name):WaitForChild("TimeStop")),
	}
	
	Events[#Events+1] = Handle.Touched:Connect(Touched)
end

function Unequipped()
	for _,anim in pairs(Animations) do
		if anim then
			anim:Stop()
		end
	end
	for _,sound in pairs(Sounds) do
		if sound then
			sound:Stop()
		end
	end
	for i=1,#Events do
		if Events[i] then
			Events[i]:Disconnect()
		end
	end
	Events = {}
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

Remote.OnServerEvent:Connect(function(Client,Key)
	if not Player or not Client or Client ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.Q and Particle.Enabled then
		local function IsStoppingTime()
			local TimeScripts = Services.ServerScriptService:GetChildren()
			
			for i=1,#TimeScripts do
				if TimeScripts[i] and TimeScripts[i].Name == tostring(script:FindFirstChild("TimeStop")) and TimeScripts[i]:IsA("Script") and TimeScripts[i]:FindFirstChild("Creator") and TimeScripts[i]:FindFirstChild("Creator").Value == Player then
					return true
				end
			end
			
			return false
		end
		
		if IsStoppingTime() then return end
		Particle.Enabled = false
		delay(30,function()
			Particle.Enabled = true
		end)
		--print("Time Stops now!")
		Animations.TimeStop:Play()
		local TimeStopScript = script:FindFirstChild("TimeStop")
		if TimeStopScript then
			TimeStopScript = TimeStopScript:Clone()
			
			Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = TimeStopScript
			}
			Create("ObjectValue"){
				Name = "CenterPart",
				Value = Root,
				Parent = TimeStopScript
			}
			
			TimeStopScript.Parent = Services.ServerScriptService
			TimeStopScript.Disabled = false
		end
	end	
end)


