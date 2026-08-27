--The beast has been slain!(Server-crashing bug fixed)
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

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

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

local MyCharacter=script.Parent
local Creator = script:WaitForChild("creator")
local LeadSound=script.BearLead
local HitSound=script.BearHit
local Bear1=script.Bear1
local Bear2=script.Bear2
local target= (Bear1.Value.CFrame.p+Bear2.Value.CFrame.p)/2.0
local distance=(Bear1.Value.CFrame.p-Bear2.Value.CFrame.p).magnitude
local soundLength=1.45
local speed=distance/(soundLength*2)
local exploding=false
Bear1.Value.CFrame=CFrame.new(Bear1.Value.CFrame.p,Bear2.Value.CFrame.p)
Bear1.Value.bearGyro.cframe=Bear1.Value.CFrame
Bear2.Value.CFrame=CFrame.new(Bear2.Value.CFrame.p,Bear1.Value.CFrame.p)
Bear2.Value.bearGyro.cframe=Bear2.Value.CFrame

local BThrust1= Instance.new('BodyVelocity')
BThrust1.maxForce=Vector3.new(math.huge,50,math.huge)
BThrust1.velocity=(target-Bear1.Value.CFrame.p).unit*speed
BThrust1.Parent=Bear1.Value

local temptag=Instance.new('StringValue')
	temptag.Name="BEAR_TAG"
	temptag.Value=Bear1.Value.Name
	temptag.Parent=Bear1.Value


local BThrust2= Instance.new('BodyVelocity')
BThrust2.maxForce=Vector3.new(math.huge,50,math.huge)
BThrust2.velocity=(target-Bear2.Value.CFrame.p).unit*speed
BThrust2.Parent=Bear2.Value

temptag=Instance.new('StringValue')
	temptag.Name="BEAR_TAG"
	temptag.Value=Bear2.Value.Name
	temptag.Parent=Bear2.Value

local LeadSound1=script.BearLead:Clone()
LeadSound1.Parent=Bear1.Value
LeadSound1:Play()

local LeadSound2=script.BearLead:Clone()
LeadSound2.Parent=Bear2.Value
LeadSound2:Play()

local TouchEvents = {}
function DoAwesomeness()
	if exploding then return end
	exploding=true
	for _,events in pairs(TouchEvents) do
		if events then 
			events:Disconnect()
		end
	end
	BThrust1:Destroy()
	BThrust2:Destroy()
	Bear1.Value.Anchored=true
	Bear2.Value.Anchored=true
	local explosion= Instance.new('Explosion')
	explosion.Position=Bear1.Value.CFrame.p
	explosion.BlastPressure=0
	explosion.DestroyJointRadiusPercent = 0
	explosion.BlastRadius=25
	explosion.ExplosionType='CratersAndDebris'
	explosion.Parent=workspace
	explosion.Hit:Connect(function(hit)
		local hum = hit.Parent and hit.Parent:FindFirstChildOfClass('Humanoid')
		if hum and hum.Health ~= 0 and not IsTeamMate(Services.Players:GetPlayerFromCharacter(hum.Parent),Services.Players:GetPlayerFromCharacter(Creator.Value)) then
			UntagHumanoid(hum)
			TagHumanoid(hum,Services.Players:GetPlayerFromCharacter(MyCharacter))
			hum:TakeDamage(hum.MaxHealth)
		end
	end)
	local explosionSound= script.BearHit:Clone()
	explosionSound.Parent=Bear1.Value
	wait()
	explosionSound:Play()
	
	local startPos=Vector3.new(0, -7, -20)
	local endPos=Vector3.new(0, 50, -20)

	local bearGuis= {}
	local iter = 0
	for _, player in pairs(game.Players:GetPlayers()) do
		iter=iter+1 
		local billGui=script.AmericaGui:Clone()
		billGui.Name='BearMericaGui'
		billGui.Adornee=Bear1.Value
		billGui.StudsOffset = startPos
		billGui.Parent=player.PlayerGui
		billGui.ImageLabel.Visible = true
		bearGuis[iter]=billGui
		Services.Debris:AddItem(billGui,5)
	end
	local startTime=time()
	local waitTime=4.5

	while time()-startTime<waitTime do
		for i=1,iter,1 do
			bearGuis[i].StudsOffset=startPos:Lerp(endPos,(time()-startTime)/waitTime)
		end
		if math.random(5)==1 then
			local explosion2= Instance.new('Explosion')
			explosion2.Position=Bear1.Value.CFrame.p+Vector3.new(math.random(100)-50,math.random(50),math.random(5))
			explosion2.DestroyJointRadiusPercent = 0
			explosion2.BlastPressure = 0
			explosion2.Parent=workspace
			
			explosion2.Hit:Connect(function(hit)
				local hum = hit.Parent and hit.Parent:FindFirstChildOfClass('Humanoid')
				if hum and not IsTeamMate(Services.Players:GetPlayerFromCharacter(hum.Parent),Services.Players:GetPlayerFromCharacter(Creator.Value)) and hum.Health ~= 0 then
					UntagHumanoid(hum)
					TagHumanoid(hum,Services.Players:GetPlayerFromCharacter(MyCharacter))
					hum:TakeDamage(hum.MaxHealth)
				end
			end)
		end
		
		wait()
	end
	wait(2)
	Bear1.Value:Destroy()
	Bear2.Value:Destroy()
	script:Destroy()
	for i=1,iter-1,1 do
			bearGuis[i]:Destroy()
		end
end

local CaughtParts = {}

function OnTouched(origin, myPart, hit)
	if not hit or not hit.Parent or hit.Anchored then return end
	
	if hit:FindFirstChild("BEAR_TAG") and hit.BEAR_TAG.Value~=origin.Name then
			DoAwesomeness()
		return
	end

	if hit.Parent:FindFirstChild("BEAR_TAG") and hit.Parent.BEAR_TAG.Value~=origin.Name then
			DoAwesomeness()
		return
	end
	
	--[[local tweld = Instance.new("Weld")
	tweld.Part0 = hit
	tweld.Part1 = myPart
	tweld.C0 = CFrame.new()
	tweld.C1 = origin.CFrame:inverse() * hit.CFrame
	tweld.Parent = origin]]
if not IsInTable(CaughtParts,hit) and hit.Parent:FindFirstChildOfClass("Humanoid") and not IsTeamMate(Services.Players:GetPlayerFromCharacter(hit.Parent),Services.Players:GetPlayerFromCharacter(Creator.Value)) and not hit.Parent:IsA("Accoutrement") and not hit.Parent:IsA("Tool") and not hit.Parent:FindFirstChildOfClass("ForceField") then
		CaughtParts[#CaughtParts+1] = hit
		local tweld = Create("WeldConstraint"){
			Name = "BearWeld",
			Part0 = hit,
			Part1 = myPart,
			Parent = origin,
			Enabled = true
		}
		TouchEvents[#TouchEvents+1] = hit.Touched:Connect(function(hit2) OnTouched(myPart,myPart,hit2) end)
end
	
	
	
	
	if not hit:FindFirstChild("BEAR_TAG") or hit.Parent:FindFirstChild("BEAR_TAG") then
		local tag=Instance.new('StringValue')
		tag.Name="BEAR_TAG"
		tag.Value=origin.Name
		if hit.Parent:FindFirstChildOfClass('Humanoid') then
			tag.Parent=hit.Parent
		else
			tag.Parent=hit
		end
		game.Debris:AddItem(tag,15)
	end
	
end

TouchEvents[#TouchEvents+1] = Bear1.Value.Touched:Connect(function(hit) OnTouched(Bear1.Value,Bear1.Value,hit) end)
TouchEvents[#TouchEvents+1] = Bear2.Value.Touched:Connect(function(hit) OnTouched(Bear2.Value,Bear2.Value,hit) end)
