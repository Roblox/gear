--Rescripted by TakeoHonorable
local Seed --Randomness

local Tool = script.Parent

local Grips = {Normal = CFrame.new(0, -0.899999976, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1)}

Tool.Grip = Grips.Normal

Tool.Enabled = true --Ensure the tool wouldn't break easy

local Handle = Tool:WaitForChild("Handle",10)
Handle.Transparency = 0

local ThrowAxe = Tool:WaitForChild("ThrowAxe",10)

local MouseLoc = Tool:WaitForChild("MouseLoc",10)

local MyPlayer,MyCharacter,MyHumanoid,MyTorso

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Players = (game:FindService("Players") or game:GetService("Players")),
}

local Sounds = {
	Unsheath = Handle:WaitForChild("UnsheathSound"),
	Slash = Handle:WaitForChild("SlashSound"),
}

local Properties = {
	BaseDamage = 5,
	SlashDamage = 10,
	SwingDamage = 15,
	CurrentDamage = 0,
}

local ProjectileScript = script:WaitForChild("ProjectileScript",10)

local Directory,Animations

local TouchConnection

local AxeThrown = false

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function TagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	CreatorTag.Parent = humanoid
	Services.Debris:AddItem(CreatorTag, 3)
end

function Blow(Hit)
	if not Hit or not Hit.Parent then return end
	
	local Hum = Hit.Parent:FindFirstChildOfClass("Humanoid")
	
	if Hum and Hum ~= MyHumanoid and Hum.Health > 0 and not AxeThrown then  
		if IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
		UntagHumanoid(Hum)
		TagHumanoid(Hum,MyPlayer)
		Hum:TakeDamage(Properties.CurrentDamage)
	end
end

function SpinSword(SpinTime)
	spawn(function()
		local StartSpin = tick()
		local EndSpin = StartSpin + SpinTime
		while tick() < EndSpin do
			Tool.Grip = Grips.Normal * CFrame.Angles(math.pi * 2 * ((tick() - StartSpin) / SpinTime), 0, 0)
			wait()
		end
		Tool.Grip = Grips.Normal
	end)
end

function Equipped()
	Properties.CurrentDamage = Properties.BaseDamage
	Seed = Random.new(tick())
	MyCharacter = Tool.Parent
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
	MyTorso = MyCharacter:FindFirstChild("HumanoidRootPart") or MyCharacter:FindFirstChild("Torso")
	if not MyHumanoid or MyHumanoid.Health <=0 then return end
	
	Directory = Tool:WaitForChild(MyHumanoid.RigType.Name)
	
	Animations = {
		LeftSlash = Directory:WaitForChild("LeftSlash"),
		LeftSwingFast = Directory:WaitForChild("LeftSwingFast"),
		OverHeadSwing = Directory:WaitForChild("OverHeadSwing"),
		RightSlash = Directory:WaitForChild("RightSlash"),
		RightSwingFast = Directory:WaitForChild("RightSwingFast"),
		Throw = Directory:WaitForChild("Throw")
	}
	for AnimName,Anim in pairs(Animations) do
		Animations[AnimName] = MyHumanoid:LoadAnimation(Anim)
	end
	
	Sounds.Unsheath:Play()
	
	TouchConnection = Handle.Touched:Connect(Blow)
end

function Unequipped()
	Properties.CurrentDamage = 0
	
	for AnimName,Anim in pairs(Animations) do
		Anim:Stop()
	end
	if TouchConnection then TouchConnection:Disconnect() end
end

function Activated()
	if not MyHumanoid or MyHumanoid.Health <=0 or not Tool.Enabled or AxeThrown then return end
	
	Tool.Enabled = false
	local AnimBank = {Animations.LeftSlash,Animations.OverHeadSwing,Animations.RightSlash,Animations.RightSwingFast,Animations.LeftSwingFast}
	
	local ChosenAnim = AnimBank[Seed:NextInteger(1,#AnimBank)]
	ChosenAnim:Play()
	
	if ChosenAnim.Animation.Name == "RightSlash" or ChosenAnim.Animation.Name == "LeftSlash" or ChosenAnim.Animation.Name == "OverHeadSwing" then
		SpinSword(.5)
	end
	
	if ChosenAnim.Animation.Name == "OverHeadSwing" then
		Properties.CurrentDamage = Properties.SwingDamage
	else
		Properties.CurrentDamage = Properties.SlashDamage
	end
	print(ChosenAnim.Animation.Name)
	Sounds.Slash:Play()
	
	wait(0.7)
	Properties.CurrentDamage = Properties.BaseDamage
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

function ThrowAxe.OnServerInvoke(Player,Key)
	if not Tool.Enabled or not Player or Player ~= MyPlayer or not Key or AxeThrown then return end
	if Key == Enum.KeyCode.Q then
		if MyHumanoid and MyHumanoid.Health > 0 then
			AxeThrown = true
			Animations.Throw:Play();Animations.Throw.Stopped:Wait()
			if Tool.Parent ~= MyCharacter then AxeThrown = false return end
			local TargetPoint = MouseLoc:InvokeClient(Player)
					
			local ProjectileScriptClone = ProjectileScript:Clone()
			ProjectileScriptClone.TargetPos.Value = TargetPoint
			ProjectileScriptClone.Disabled = false
			ProjectileScriptClone.Parent = Tool
			Handle.Transparency = 1
			Properties.CurrentDamage = 0
			repeat
				Services.RunService.Heartbeat:Wait()
			until not ProjectileScriptClone or not ProjectileScriptClone.Parent
			Handle.Transparency = 0
			AxeThrown = false
		end
	end
end
