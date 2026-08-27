local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

local MyHumanoid,MyCharacter,MyPlayer

local Fire = Tool:WaitForChild("Remote")

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService"))
}

local Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	ReloadSound = Handle:WaitForChild("ReloadSound"),
	HoldLock =  Handle:WaitForChild("holdlock"),
	LockOn = Handle:WaitForChild("lockon")
}

local DoTrackLock = false

local MyBillboard = Tool:WaitForChild("AimUI"):Clone()
local lockonImg = MyBillboard:WaitForChild("lockon")
local holdlockImg = MyBillboard:WaitForChild("lockonHeld")
local MyDistText = MyBillboard:WaitForChild("Distance")

local TrackTime = 0
local LockedPlayer
local Selected

local ClickConnection,TimerConnection

function TrackLock(mouse)
	if not MyCharacter then return end
	local myHead = MyCharacter:FindFirstChild("Head")
	if ClickConnection then ClickConnection:Disconnect() end
	ClickConnection = Tool.Activated:Connect(function()
		Fire:FireServer(Services.Players.LocalPlayer:GetMouse().Hit.p,LockedPlayer)
	end)
	while DoTrackLock do
		--local closestPlayer	 = nil
		
		local mousePos = mouse.Hit
		local minOffset
		local foundPlayer = false
		
		--TrackTime = tick()
		for _,i in pairs(game.Players:GetPlayers()) do			
			if i.Character and i.Character:FindFirstChild("HumanoidRootPart") and i~= MyPlayer then
				
				local torsoPos = i.Character.HumanoidRootPart.CFrame
				local dist = (myHead.CFrame.p-torsoPos.p).magnitude
				local mouseDirection = (mouse.hit.p-myHead.CFrame.p).unit
				local offset = (((mouseDirection*dist)+myHead.CFrame.p)-torsoPos.p).magnitude
				if offset<9 and (not minOffset or offset<minOffset) then
					foundPlayer = true
					MyDistText.Text = tostring(math.floor(dist*100)/100)
					if LockedPlayer~=i then	
						if not Selected and i and not Sounds.LockOn.IsPlaying and not Sounds.HoldLock.IsPlaying then
							Sounds.LockOn:Play()
							lockonImg.Visible = true
							MyDistText.Visible = true
							TrackTime = tick()
						end			
						Selected = i
						--print('TRACKING'..i.Name)
						MyBillboard.Parent = MyPlayer.PlayerGui
						MyBillboard.Adornee =  i.Character.HumanoidRootPart
						lockonImg.Visible = true
					end
				end
			end
		end
		
		if (tick()-TrackTime)>1.1 and Selected and not LockedPlayer and not Sounds.HoldLock.IsPlaying and Tool.Enabled then
			LockedPlayer = Selected
			Sounds.HoldLock:Play()
			lockonImg.Visible = false
			holdlockImg.Visible = true
		end
		
		if not foundPlayer and Selected then
			LockedPlayer=nil
			Selected = nil
			Sounds.LockOn:Stop()
			--print('UnTracking')
			if Sounds.HoldLock.IsPlaying then
				Sounds.HoldLock:Stop()
			end
			lockonImg.Visible = false
			holdlockImg.Visible = false
			MyDistText.Visible = false
			MyBillboard.Parent = nil
			MyBillboard.Adornee = nil
		end	
		if not Tool.Enabled then
			TrackTime = tick()
			LockedPlayer=nil
			Selected = nil
			Sounds.LockOn:Stop()
			Sounds.HoldLock:Stop()
			lockonImg.Visible = false
			holdlockImg.Visible = false
			MyDistText.Visible = false
			MyBillboard.Parent = nil
			MyBillboard.Adornee = nil
		end	
		wait(1/30)
	end
	
	LockedPlayer=nil
	Sounds.LockOn:Stop()
	--print('escaped loop')
	if Sounds.HoldLock.IsPlaying then
		Sounds.HoldLock:Stop()
	end
	lockonImg.Visible = false
	holdlockImg.Visible = false
	MyDistText.Visible = false
	MyBillboard.Parent = nil
	MyBillboard.Adornee = nil
	
end
	
function Equipped()
	MyCharacter = Tool.Parent
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter)
	DoTrackLock = true
	
	local Start = tick()
	
	TimerConnection = Services.RunService.RenderStepped:Connect(function()
		local Current = tick()
		if (Current-Start) >= 1 then
			TimerConnection:Disconnect()
			ClickConnection = Tool.Activated:Connect(function()
				Fire:FireServer(Services.Players.LocalPlayer:GetMouse().Hit.p,LockedPlayer)
			end)
			TrackLock(Services.Players.LocalPlayer:GetMouse())
		end
	end)
	
end

function Unequipped()
	TrackTime = tick()
	LockedPlayer=nil
	Selected = nil
	if TimerConnection then TimerConnection:Disconnect() end
	if ClickConnection then ClickConnection:Disconnect() end
	MyCharacter,MyHumanoid,MyPlayer = nil,nil,nil
	DoTrackLock = false
	Sounds.ReloadSound:Stop()
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

