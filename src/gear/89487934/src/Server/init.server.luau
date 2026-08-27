--Rescripted by TakeoHonorable

--local Angle = math.acos(Facing:Dot(Vector)) (Is in radians)

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

local Properties = {
	Detection_Distance = 175,
	Field_Of_View = 90,--Medusa's capture view (Measured in degrees)
	Target_Field_Of_View = 50, --Maximum angle to freeze targets (Measured in degrees)
}

local Self = script

local world = workspace

local Region = require(Self:WaitForChild("RegionModule"))

local Tool = Self.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local ray,Reg3,Vec3,Cframe,acos,Wait,huge,deg = Ray.new,Region3.new,Vector3.new,CFrame.new,math.acos,wait,math.huge,math.deg

local wrap,Pairs = coroutine.wrap,pairs

local FindPartOnRay = world.FindPartOnRayWithWhitelist

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Sounds = {
	Scream = Handle:WaitForChild("Scream")
}

local Eyes = {Handle:WaitForChild("RightEye"),Handle:WaitForChild("LeftEye")}

function IsInTable(Table,Value)
	for _,v in Pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

local function IsFrozen(Hum) -- Quick check to see if they're not stunned
	local Children = Services.ServerScriptService:GetChildren()
	for i=1, #Children do
		if Children[i]:IsA("Script") and Children[i].Name == "Freeze" and Children[i]:FindFirstChild("Target") and Children[i]:FindFirstChild("Target").Value == Hum.Parent then
			return true
		end
	end
	return false
end

function Activated()
	if not Tool.Enabled then return end
	
	local Character = Tool.Parent
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Player = Services.Players:GetPlayerFromCharacter(Character)
	
	if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health == huge or Humanoid.MaxHealth == huge then return end
	Tool.Enabled = false
	
	wrap(function()
		Sounds.Scream:Play()
	end)()
	
	wrap(function()
		for i=1,#Eyes,1 do
			local children = Eyes[i]:GetChildren()
			for p=1,#children,1 do
				if children[p] and children[p]:IsA("ParticleEmitter") then
					children[p]:Emit(children[p].Rate)
				end
			end
		end
	end)()
	
	local Capture = Region.new( Handle.CFrame * Cframe(0,0,-( ( Handle.Size.Z*.5 ) + ( Properties.Detection_Distance * .5 ) ) ), Vec3(1,1,1) * Properties.Detection_Distance ):Cast(Character)
	local CapHumanoids = {}
	
	
	for i=1,#Capture,1 do
		
		if Capture[i] and Capture[i].Parent then
			
			local Hum,FF,Head = Capture[i].Parent:FindFirstChildOfClass("Humanoid"), Capture[i].Parent:FindFirstChildOfClass("ForceField"), Capture[i].Parent:FindFirstChild("Head")
			
			if Hum and Hum.Health > 0 and not FF and Head and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(CapHumanoids,Hum)  then
				
				CapHumanoids[#CapHumanoids+1] = Hum
				
				local MedusaCFrame = Cframe(Handle.Position.X,Head.Position.Y,Handle.Position.Z) * (Handle.CFrame - Handle.Position)
				
				local MedusaAngle = acos(MedusaCFrame.LookVector:Dot((Head.Position - MedusaCFrame.Position).Unit))
				
				local TargetAngle = acos(Head.CFrame.LookVector:Dot((MedusaCFrame.Position - Head.Position).Unit))
				
				--warn(deg(MedusaAngle) <= Properties.Field_Of_View, deg(TargetAngle), deg(TargetAngle) <= Properties.Target_Field_Of_View )
				
				if deg(MedusaAngle) <= Properties.Field_Of_View  and deg(TargetAngle) <= Properties.Target_Field_Of_View  then
					
					
					local hit,pos,nor = FindPartOnRay(world,ray( Handle.Position , ( Head.Position - Handle.Position ).Unit * Properties.Detection_Distance ),Capture,false)
					
					if hit then
						
						local Directory = hit.Parent
						
						if Directory:IsA("Accoutrement") then
							
							Directory = Directory.Parent
							
						end
						
						if Directory == Head.Parent and not Head.Anchored and not IsFrozen(Hum) then
							
							--This is the target!
							
							local MedusaFreeze = Self:WaitForChild("Freeze"):Clone()
							
							Create("ObjectValue"){
								Name = "Target",
								Value = Hum.Parent,
								Parent = MedusaFreeze
							}
							
							MedusaFreeze.Parent = Services.ServerScriptService
							MedusaFreeze.Disabled = false
							
						end
						
					end
					
				end
				
				
				
			end
			
		end
	
	end
	
	Wait(6)
	
	Tool.Enabled = true
end

Tool.Activated:Connect(Activated)