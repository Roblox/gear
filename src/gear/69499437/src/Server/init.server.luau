--Rescripted by TakeoHonorable
--Revamped Periastrons: The Genesis Periastron

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

local Seed = Random.new(tick())

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle",10)

local PointLight = Handle:WaitForChild("PointLight",10)

local Sparkles = Handle:FindFirstChildOfClass("Sparkles")

local Animations = Tool:WaitForChild("Animations",10)

local VariablesFolder = Tool:WaitForChild("Variables",10)

local Variables = {
	ToolAnim = VariablesFolder:WaitForChild("ToolAnim",10)
}

local Deletables = {} --Send all deletables here

local InvincibleVisuals = Tool:WaitForChild("InvincibleVisuals",10):GetChildren()

local Sounds = {
	CounterReady = Handle:WaitForChild("CounterReady",10),
	LungeSound = Handle:WaitForChild("LungeSound",10),
	SlashSound = Handle:WaitForChild("SlashSound",10),
	CounterClash = Handle:WaitForChild("CounterClash",10),
	CounterSlash = Handle:WaitForChild("CounterSlash",10),
}

local AttackAnims
local Region = require(script:WaitForChild("RegionModule"))
local CounterAnimations

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

local Components = {
	PeriSparkle = Handle:WaitForChild("Sparkles",10),
	PeriTrail = Handle:WaitForChild("Trail",10),
	CounterParticles = Handle:WaitForChild("BottomTrail",10):GetChildren(),
	MouseInput = Tool:WaitForChild("MouseInput",10)
}

local Player,Character,Humanoid,Root,Torso,RightArm,RightWeld

Equipped = false

local SpecialActive = false
local SecondarySpecialActive = false
local SpecialCooldown = 10
LungeDamage = 27
ReloadTime = 1

Components.PeriSparkle.Enabled = true
Components.PeriTrail.Enabled = false
PointLight.Enabled = true

local Remote = (Tool:FindFirstChild("Remote") or Instance.new("RemoteEvent"));Remote.Name = "Remote";Remote.Parent = Tool

local Grips = {
	Normal = Tool:WaitForChild("NormalGrip").Value,
	BackR6 = Tool:WaitForChild("BackGrip").Value,
	BackR15 = Tool:WaitForChild("BackGrip").Value+Vector3.new(-.7,0,-.7)
}

function RayCast(Pos, Dir, Max, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

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

local function GetNearestTorso(MarkedPosition,TorsoPopulationTable)
	local ClosestDistance = math.huge
	local ClosestTorso
	for i=1,#TorsoPopulationTable do
		local distance = (TorsoPopulationTable[i].CFrame.p-MarkedPosition).magnitude
		if TorsoPopulationTable[i] and  distance < ClosestDistance then
			ClosestDistance = distance
			ClosestTorso = TorsoPopulationTable[i]
		end
	end
	--warn("The Closest Person is: "..ClosestTorso.Parent.Name)
	return ClosestTorso
end


local function LaunchCharacter(Center,Equation,DamageAmount)
	local Character = Center.Parent
	if not Character or Center:IsGrounded() then return end
	--More Damage = More Hit stun
	Character.PrimaryPart = Character.PrimaryPart or Center
	local Origin = Character.PrimaryPart.CFrame
	Character.PrimaryPart.Anchored = true
	for i=1,DamageAmount*.25 do
		if Character and Character.PrimaryPart then
			Character:SetPrimaryPartCFrame(Origin+Vector3.new(Seed:NextNumber(-DamageAmount*.025,DamageAmount*.025),Seed:NextNumber(-DamageAmount*.025,DamageAmount*.025)),Seed:NextNumber(-DamageAmount*.025,DamageAmount*.025))
			Services.RunService.Heartbeat:Wait()
		end
	end
	if not Character.PrimaryPart then return end
	Character.PrimaryPart.Anchored = false
	if Character and Character.PrimaryPart then
		Character:SetPrimaryPartCFrame(Origin)
	end
	if Services.Players:GetPlayerFromCharacter(Center.Parent) then
		local Launch = script:FindFirstChild("Launch"):Clone()
		Launch.Parent = Center
		Launch.Direction.Value = Equation
		Launch.Disabled = false
		Services.Debris:AddItem(Launch,2)
		--print("Player")
	else
		Center.Velocity = Equation
		--print("NPC")
	end
end


local Touch
local CounterCoroutine
local HealthConnection
local InvincibleConnection

local function PutSwordOnBack(Verdict,DrawSpeed)
	if Verdict and Tool.Grip == Grips["Back"..Humanoid.RigType.Name] or CounterAnimations.Stance.IsPlaying then return end
	if not Verdict and Tool.Grip == Grips.Normal then return end
	for _,v in pairs(AttackAnims) do
		v:Stop()
	end
	CounterAnimations.Stance:Play(nil,nil,DrawSpeed or 1)
	Equipped = false
	--print(CounterAnimations.Stance.Length)
	wait(0.3/(DrawSpeed or 1))
	if not Tool:IsDescendantOf(Character) or Character:FindFirstChildOfClass("Tool") ~= Tool then return end
	if Verdict then -- puts the sword on your back
		
		--RightWeld = RightArm:FindFirstChildWhichIsA("JointInstance")
		if not RightWeld then return end
		if Touch then Touch:Disconnect();Touch = nil end
		repeat
			RightWeld.Part0 = Torso
			Tool.Grip = Grips["Back"..Humanoid.RigType.Name]
			Services.RunService.Heartbeat:Wait()
		until Tool.Grip == Grips["Back"..Humanoid.RigType.Name]  and RightWeld.Part0 == Torso
		--print("Putting on back")
		Variables.ToolAnim.Value = false
		spawn(function()
			if not Tool:IsDescendantOf(Character) or not Components.PeriSparkle.Enabled then return end
			for _,particles in pairs(Components.CounterParticles) do
				if particles:IsA("ParticleEmitter") and particles.Name ~= "HeartRateLine" then
					particles:Emit(particles.Rate)
				end
			end
			Sounds.CounterReady:Play()
			RegisterCounter()
		end)
	else -- put the sword in your hand
		if HealthConnection then HealthConnection:Disconnect();HealthConnection = nil end
		--RightWeld = RightArm:FindFirstChildWhichIsA("JointInstance")
		if not RightWeld then return end
		repeat
			RightWeld.Part0 = RightArm
			Tool.Grip = Grips.Normal
			Services.RunService.Heartbeat:Wait()
		until Tool.Grip == Grips.Normal and RightWeld.Part0 == RightArm
		Tool.Grip = Grips.Normal
		--print("Putting in hand")
		Variables.ToolAnim.Value = true
	end
	Equipped = true
end

local Startup,End = tick(),tick()


function RegisterCounter()
	local CurrentHealth = Humanoid.Health
	if HealthConnection then HealthConnection:Disconnect();HealthConnection = nil end
	HealthConnection = Humanoid.HealthChanged:Connect(function(NewHealth)
				if NewHealth>= CurrentHealth then CurrentHealth = Humanoid.Health return end
					HealthConnection:Disconnect()
					Humanoid.Health = CurrentHealth
					--print(CurrentHealth,NewHealth)
					local Velo = Create("BodyVelocity"){
						MaxForce = Vector3.new(1,1,1)*math.huge,
						Velocity = Vector3.new(0,0,0),
						Parent = Torso
					}
					table.insert(Deletables,Velo)
					local Gyro = Create("BodyGyro"){
						MaxTorque = Vector3.new(1,1,1)*math.huge,
						P = 10^10
					}
					table.insert(Deletables,Gyro)
					InvincibleConnection = Humanoid.HealthChanged:Connect(function()
						Humanoid.Health = CurrentHealth
					end)
					Services.Debris:AddItem(Velo,5)
					Services.Debris:AddItem(Gyro,5)
					--warn("Attack!!")
					for _,particles in pairs(Components.CounterParticles) do
						if particles.Name == "HeartRateLine" then
							particles:Emit(particles.Rate)
						end
					end
					Sounds.CounterClash:Play()
					
					
					local PartGroup = Region.new(Root.CFrame,Character:GetExtentsSize()*4):Cast(Character)
				 	local TorsoList = {}
					local AnchoredParts = {} 
					for _,part in pairs(PartGroup) do
						
					if part and  part.Parent then 
						if not part.Anchored then
							part.Anchored = true
							table.insert(AnchoredParts,part)
						end
						if part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "HumanoidRootPart" then
							TorsoList[#TorsoList+1]=part
						end
						
						local Hum = part.Parent:FindFirstChildOfClass("Humanoid")
							if Hum then
								Hum:UnequipTools() --Stahp right there!!!
							end
						end
					end
					
					local IFrameAttachment = Create("Attachment"){
						Position = Vector3.new(0,0,0),
						Parent = Torso
					}
					Services.Debris:AddItem(IFrameAttachment,5)
					
					for _,visuals in pairs(InvincibleVisuals) do
						if visuals:IsA("ParticleEmitter") then
							local Clone = visuals:Clone()
							Clone.Parent = IFrameAttachment
							Clone.Enabled = true
						end
					end
					table.insert(Deletables,IFrameAttachment)
					
					wait(0.25)
					if not Tool:IsDescendantOf(Character) then
						Velo:Destroy()
						Gyro:Destroy()
						HealthConnection = nil
						CounterCoroutine = nil
						SpecialActive = false
						if InvincibleConnection then InvincibleConnection:Disconnect(); InvincibleConnection = nil end
						--not SpecialActive and not HealthConnection and not CounterCoroutine
						
						for _,parts in pairs(AnchoredParts) do
							if parts then
								parts.Anchored = false
							end
						end
						return
					end
					local Pos = GetNearestTorso(Root.CFrame.p,TorsoList)
					Pos = ((Pos and Pos.CFrame.p) or Root.CFrame.p+Root.CFrame.lookVector)
					Root.CFrame = CFrame.new((Root.CFrame.p+Root.CFrame.lookVector*3),Pos)
					Gyro.CFrame = Root.CFrame
					Gyro.Parent = Torso
					PutSwordOnBack(false,2)
					
					CounterAnimations.Attack:Play(nil,nil,2);
					
					Components.PeriSparkle.Enabled = false
					Components.PeriTrail.Enabled = true
					wait(.1)
					local TaggedHumanoids  = {}
					local Dmg = (CurrentHealth-NewHealth)*1.35
					
					for _,parts in pairs(AnchoredParts) do
						if parts then
							parts.Anchored = false
						end
					end
					for _,v in pairs(Region.new(Root.CFrame*CFrame.new(0,0,-8*.4),Vector3.new(10, 10, 8)):Cast(Character)) do
						
						local Hum = v.Parent:FindFirstChildOfClass("Humanoid")
						if not v.Anchored and not Hum and not v.Parent:IsA("Accoutrement") and not (Hum and not v:IsDescendantOf(Hum.Parent)) then
							for _,v in pairs(v:GetChildren()) do
								if v:IsA("BodyMover") then
									v:Destroy()
								end
							end
							if not v:IsGrounded() then
								v.Velocity = (Root.CFrame * CFrame.Angles(math.rad(50),0,0)).lookVector*Dmg
							end
						end
						
						if Hum and Hum.Health ~= 0 and Hum ~= Humanoid and not (Hum.Health <= 0) and not IsInTable(TaggedHumanoids,Hum) and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
							table.insert(TaggedHumanoids,Hum)
							spawn(function()
								UntagHumanoid(Hum)
								TagHumanoid(Hum,Player)
								CounterAnimations.Attack:AdjustSpeed(Seed:NextNumber(0.02,0.025))
								LaunchCharacter(v,(Root.CFrame * CFrame.Angles(math.rad(50),0,0)).lookVector*((Hum.MaxHealth-(Hum.Health-Dmg))+(Humanoid.MaxHealth-(Humanoid.Health-Dmg))),Dmg)	
								Hum:TakeDamage(Dmg)
								CounterAnimations.Attack:AdjustSpeed(2)
							end)
						end
					end
					if #TaggedHumanoids > 0 then
						CounterAnimations.Attack.TimePosition = .2
						Sounds.CounterSlash.TimePosition = 0.5
						Sounds.CounterSlash:Play()
					end
					Variables.ToolAnim.Value = true
					CounterAnimations.Attack.Stopped:Wait()
					CreateSwordTouch()
					Components.PeriTrail.Enabled = false
					wait(.1)
					Velo:Destroy()
					Gyro:Destroy()
					wait(1)
					IFrameAttachment:Destroy()
					if HealthConnection then HealthConnection:Disconnect();HealthConnection = nil end
					if InvincibleConnection then InvincibleConnection:Disconnect(); InvincibleConnection = nil end
					Startup,End = tick(),tick()
					CounterCoroutine = nil
					SpecialCooldown = 10
					SpecialActive = false
					--Counter-Attack sequence ends here
			end)
end

function SetupCounter(RightWeld,Right)
	if HealthConnection then HealthConnection:Disconnect();HealthConnection = nil end
	CounterCoroutine = Services.RunService.Heartbeat:Connect(function()
		if Components.PeriSparkle.Enabled then if CounterCoroutine then CounterCoroutine:Disconnect() return end end
		End = (Tool.Enabled and not CounterAnimations.Stance.IsPlaying and tick()) or End
		if ((End-Startup)>SpecialCooldown and not SpecialActive) then
			SpecialActive = true
			if CounterCoroutine then CounterCoroutine:Disconnect() end
			if Tool:IsDescendantOf(Character) then
				
			PutSwordOnBack(true,2)
			--wait(0.3)
			spawn(function()
				if not Tool:IsDescendantOf(Character) then return end
				for _,particles in pairs(Components.CounterParticles) do
					if particles:IsA("ParticleEmitter") and particles.Name ~= "HeartRateLine" then
						particles:Emit(particles.Rate)
					end
				end
				Sounds.CounterReady:Play()
				Components.PeriSparkle.Enabled = true
			end)
			--if not SpecialActive or not Equipped then if CounterCoroutine then CounterCoroutine:Disconnect();CounterCoroutine = nil end return end
	
			--warn("Counter Ready!")
			
			RegisterCounter()
			else
				Components.PeriSparkle.Enabled = true
			end
			
			
		
		end


	end)
	
end


local CurrentTime,LastTime = tick(),tick()
function Activated()
	if not Tool.Enabled  or CounterAnimations.Stance.IsPlaying then return end
	Tool.Enabled = false
	PutSwordOnBack(false,2)
	CreateSwordTouch()
	CurrentTime = tick()
	if (CurrentTime-LastTime) <= 0.2 then
		--print("Lunge")
		Sounds.LungeSound:Play()
		Components.PeriTrail.Enabled = true
		local MousePosition = Components.MouseInput:InvokeClient(Player)
		local Direction = CFrame.new(Root.Position, Vector3.new(MousePosition.X, Root.Position.Y, MousePosition.Z))
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Direction.lookVector * 100
		Services.Debris:AddItem(BodyVelocity, 0.5)
		BodyVelocity.Parent = Root
		delay(.5,function()
			Components.PeriTrail.Enabled = false
		end)
		Root.CFrame = CFrame.new(Root.CFrame.p,Root.CFrame.p+Direction.lookVector)
		wait(1.5)
	else
		local SwingAnims = {AttackAnims.Slash,AttackAnims.SlashAnim,AttackAnims.RightSlash}
		local AttackAnim = SwingAnims[Seed:NextInteger(1,#SwingAnims)]
		spawn(function()
			if AttackAnim ~= AttackAnims.SlashAnim then
				Sounds.SlashSound:Play()
				else
				Sounds.SlashSound:Play()
				wait(.5)
				Sounds.SlashSound:Play()
			end	
		end)

		AttackAnim:Play()
	--wait(.4)
	end
	LastTime = CurrentTime
	Tool.Enabled = true
end



function CreateSwordTouch()
	if Touch then Touch:Disconnect();Touch = nil end
	Touch = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not Hum or Hum == Humanoid or IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,Player)
		Hum:TakeDamage(LungeDamage)
	end)
end


function Equipped(Mouse)
	SpecialCooldown = 8
	Tool.Grip = Grips.Normal
	Equipped = true
	Startup = tick()
	End = tick()
	Seed = Random.new(tick())
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Root = Character:FindFirstChild("HumanoidRootPart")
	RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	RightWeld = RightArm:WaitForChild("RightGrip")
	if not Character or not Humanoid then
		return
	end
	AttackAnims = {
		Slash = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("Slash",10),
		RightSlash = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("RightSlash",10),
		SlashAnim = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("SlashAnim",10),
	}
	CounterAnimations = {
		Stance = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("SwordHolsterAnim",10),
		Attack = Animations:WaitForChild(Humanoid.RigType.Name,10):WaitForChild("CounterAttack",10)
	}
	for i,v in pairs(AttackAnims) do
		AttackAnims[i] = Humanoid:LoadAnimation(v)
	end
	for i,v in pairs(CounterAnimations) do
		CounterAnimations[i] = Humanoid:LoadAnimation(v)
	end
	
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	CreateSwordTouch()
--Counter activates
	repeat
	--rint(SpecialActive,HealthConnection,CounterCoroutine)
		if not SpecialActive and not HealthConnection and not CounterCoroutine then
			SetupCounter(RightWeld,RightArm)
		end
		Services.RunService.Heartbeat:Wait()
	until not Tool:IsDescendantOf(Character)
	--print("Loop ended")
end


function TwirlSpecial()
	if not Tool.Enabled or Tool.Grip ~= Grips.Normal or not Equipped or SecondarySpecialActive then return end
	SecondarySpecialActive = true
	Tool.Enabled = false
	Components.PeriTrail.Enabled = true
	Tool.Grip = Tool.Grip*CFrame.Angles(0,math.rad(90),0)
	Humanoid.WalkSpeed = 30
	for i=1,120*3,1 do
		if not Tool:IsDescendantOf(Character) then break end
		Tool.Grip = Tool.Grip*CFrame.Angles(0,0,math.rad(360/6))
		--Services.RunService.Stepped:Wait()
		Services.RunService.Heartbeat:Wait()
	end
	Tool.Enabled = true
	Tool.Grip = Grips.Normal
	Components.PeriTrail.Enabled = false
	Humanoid.WalkSpeed = 16
	wait(12)
	SecondarySpecialActive = false
end

function Unequipped()
	Components.PeriTrail.Enabled = false
	Components.PeriTrail:Clear()
	Tool.Grip = Grips.Normal
	Variables.ToolAnim.Value = true
	Equipped = false
	SpecialActive = false
	--Components.PeriSparkle.Enabled = false
	Sounds.CounterReady:Stop()
	for _,particles in pairs(Components.CounterParticles) do
		if particles:IsA("ParticleEmitter") then
			particles:Clear()
		end
	end
	if Touch then Touch:Disconnect() end
	for i,v in pairs(AttackAnims) do
		v:Stop()
	end
	for i,v in pairs(CounterAnimations) do
		v:Stop()
	end
	for index,garbage in pairs(Deletables) do
		garbage:Destroy()
		Deletables[index] = nil
	end
	if Touch then Touch:Disconnect();Touch = nil end
	if InvincibleConnection then InvincibleConnection:Disconnect(); InvincibleConnection = nil end
	if CounterCoroutine then CounterCoroutine:Disconnect(); CounterCoroutine = nil end
	if HealthConnection then 
		repeat
		HealthConnection:Disconnect();
		HealthConnection = nil 
		Services.RunService.Heartbeat:Wait()
		until not HealthConnection
	end
	
	
	--if CounterCoroutine then CounterCoroutine:Disconnect();CounterCoroutine = nil end
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

Remote.OnServerEvent:Connect(function(Client,Key)
	if not Player or not Client or Client ~= Player or not Key then return end
	if Key == Enum.KeyCode.E and not CounterAnimations.Stance.IsPlaying and Tool.Enabled and not InvincibleConnection then
		if Tool.Grip == Grips.Normal then
			PutSwordOnBack(true,2)
		else
			PutSwordOnBack(false,1)
			CreateSwordTouch()
		end
	elseif Key == Enum.KeyCode.Q and Tool.Enabled then
		PutSwordOnBack(false,1)
		CreateSwordTouch()
		TwirlSpecial()
	end
end)