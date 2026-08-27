--Rescripted by TakeoHonorable

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local MouseLoc = Tool:WaitForChild("MouseLoc")

local Animations = Tool:WaitForChild("Animations")

local Player,Character,Humanoid,Root

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Sounds = {
	Explosion = Handle:WaitForChild("ExplosionSound"),
	FiveSecondCountdown = Handle:WaitForChild("FiveSecondCountdown"),
	Yell1 = Handle:WaitForChild("Yell1"),
	Yell2 = Handle:WaitForChild("Yell2"),
	Yell3 = Handle:WaitForChild("Yell3")
}


function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Animations = Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name)
	Animations = {
		Pullback = Humanoid:LoadAnimation(Animations:WaitForChild("PullBack")),
		Throw = Humanoid:LoadAnimation(Animations:WaitForChild("Throw"))
	}
end

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

local Hold = false -- imitates holding click
local DownTime,UpTime = 0,0
function Unequipped()
	Hold = false
	for _,anim in pairs(Animations) do
		if anim then
			anim:Stop()
		end
	end
	Handle:WaitForChild("Fuse"):WaitForChild("Fire").Enabled = false
end

function Activated()
	if Hold or not Tool.Enabled or not Humanoid or Humanoid.Health == 0 then return end
	Tool.Enabled = false
	Hold = true
	Handle:WaitForChild("Fuse"):WaitForChild("Fire").Enabled = true
	Sounds.FiveSecondCountdown:Play()
	DownTime = tick()
	Animations.Pullback:Play()
	repeat
		UpTime = tick()
		Services.RunService.Heartbeat:Wait()
	until not Hold or (UpTime-DownTime) > 5 or not Tool:IsDescendantOf(Character)
	if not Tool:IsDescendantOf(Character) then 
		Sounds.FiveSecondCountdown:Stop() 
		wait(2.5)
		Tool.Enabled = true 
		return
	end
	if (UpTime-DownTime) > 5 then -- Held the bomb for too long
		
		local Explosion = Create("Explosion"){
			Position = Handle.CFrame.p,
			BlastRadius = 10,
			DestroyJointRadiusPercent = 0,
			Visible = true,
			BlastPressure = 100000,
			Parent = workspace
		}
		--print("Held it for too long")
		Character:BreakJoints()
		local Seed = Random.new()
		local NinjaSounds = {Sounds.Yell1,Sounds.Yell2,Sounds.Yell3}
		NinjaSounds[Seed:NextInteger(1,#NinjaSounds)]:Play()
		Sounds.Explosion:Play()
		Handle:WaitForChild("Fuse"):WaitForChild("Fire").Enabled = false
		wait(2.5)
		Tool.Enabled = true
		return
	end
	Animations.Pullback:Stop()
	Animations.Throw:Play()
	
	Handle.Transparency = 1
	Handle:WaitForChild("Fuse"):WaitForChild("Fire").Enabled = false
	local NewBomb = Handle:Clone()
	NewBomb.Anchored = false
	NewBomb.CanCollide = true
	NewBomb.Locked = true
	NewBomb.Massless = true
	NewBomb.CFrame = Handle.CFrame
	NewBomb.Transparency = 0
	NewBomb.Name = "NinjaStickyBomb"
	NewBomb:WaitForChild("Fuse"):WaitForChild("Fire").Enabled = true
	
	local SemtexScript = script:WaitForChild("Semtex"):Clone()
	SemtexScript:WaitForChild("Creator").Value = Player
	SemtexScript.Parent = NewBomb
	SemtexScript.Disabled = false
	
	Sounds.FiveSecondCountdown:Stop()
	
	local LaunchPower = math.sqrt(UpTime-DownTime) * 80
	
	local Sucess,MousePos = pcall(function() return MouseLoc:InvokeClient(Player) end)
	MousePos = (Sucess and MousePos) or Vector3.new(0,0,0)
	
	local Direction = (MousePos - Handle.CFrame.p).Unit
	
	--NewBomb.Velocity = Direction * LaunchPower
	
	local Velo = Create("BodyVelocity"){
		Name = "JumpForce",
		MaxForce = Vector3.new(1,1,1)*math.huge,
		Velocity = Direction * LaunchPower,
		Parent = NewBomb
	}
	Services.Debris:AddItem(Velo,.2)
	
	NewBomb.Parent = workspace
	NewBomb:SetNetworkOwner(nil)
	
	wait(2.5)
	Handle.Transparency = 0
	Tool.Enabled = true
	
end

function Deactivated()
	Hold = false
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)
Tool.Deactivated:Connect(Deactivated)