local Tool = script.Parent 
local Chocobox = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 
local vPlayer

local chocoGui
local chocoFrame 
local chocoButton

local fire

local floatForce
local bv

Tool.Enabled = true 

local inCooldown = false 

local debris = game:GetService("Debris")

function lunge(humanoid, torso) 	
	local holdAnim = humanoid:LoadAnimation(Tool.HoldAnim)
	if holdAnim then 
		holdAnim:Play() 
	else 
		Tool.Enabled = true
		return 
	end
	local target = humanoid.TargetPoint 
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1) 
	bv = nil 
	swordOut()
	if direction.magnitude > .01 then            
		direction = direction.unit 
		bv = Instance.new("BodyVelocity") 
		bv.P = 100000 
		bv.maxForce = Vector3.new(bv.P, 0, bv.P) 
		bv.velocity = direction * 50 
		bv.Parent = torso 
		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0)) 
	end 
	wait(.75)       
	if bv ~= nil then bv:remove() end 
	wait(.5) 
	swordUp()
end 

function tagHumanoid(humanoid, player)
	if humanoid then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(hit)
	if hit == nil or hit.Parent == nil or vCharacter == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	
	if humanoid~=nil and humanoid ~= myHumanoid and myHumanoid ~= nil and fire and fire.Parent then			
		tagHumanoid(humanoid, vPlayer)				
		humanoid:TakeDamage(11)	
	end
end


function onEquipped(mouse)

	fire = Instance.new("Fire")
	fire.Parent = firePart 
	fire.Color = Color3.new(165/255, 0, 33/255)
	fire.SecondaryColor = Color3.new(1, 1, 0)
	fire.Heat = 25
	fire.Size = 6

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then 
		local playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui then 
			chocoGui = Instance.new("ScreenGui")
			chocoGui.Name = "ChocoGui" 
			chocoGui.Parent = playerGui

			chocoFrame = Instance.new("Frame")
			chocoFrame.Name = "ChocoFrame"
			chocoFrame.Parent = chocoGui
			chocoFrame.BackgroundTransparency = 1.0
			chocoFrame.Size = UDim2.new(0, 300, 0, 300)
			chocoFrame.Position = UDim2.new(0, 10, 0.5, 0)

			chocoButton = Instance.new("ImageButton")
			chocoButton.Name = "ChocoButton"
			chocoButton.BackgroundTransparency = 1.0
			chocoButton.Image = "http://www.roblox.com/asset/?id=72075838"
			chocoButton.Size = UDim2.new(1, 0, 1, 0)
			chocoButton.Position = UDim2.new(0, 0, 0, 0)
			chocoButton.Parent = chocoFrame 

			frame = Instance.new("Frame")
			frame.Parent = chocoGui
			frame.Size = UDim2.new(0, 260, 0, 30)
			frame.Position = UDim2.new(0.5, -130, 1, -130) 
			frame.Style = Enum.FrameStyle.RobloxRound

			local helpText = Instance.new("TextLabel")
			helpText.BackgroundTransparency = 1.0
			helpText.Size = UDim2.new(1, 0, 1, 0)
			helpText.Visible = true 
			helpText.ZIndex = 10 
			helpText.FontSize = Enum.FontSize.Size10 
			helpText.Font = Enum.Font.Legacy
			helpText.TextColor3 = Color3.new(1, 127/255, 0)
			helpText.TextXAlignment = Enum.TextXAlignment.Center
			helpText.TextYAlignment = Enum.TextYAlignment.Top
			helpText.Parent = frame 
			helpText.Text = "Click on the chocobox to see your luck!" 

			chocoButton.MouseButton1Click:connect(function()
				if Chocobox.Transparency == 0.0 and myHumanoid and myTorso then 
					Chocobox.Transparency = 1.0
					local effect = math.random()
					if effect < 0.4 then 
						myHumanoid.WalkSpeed = 29.0 
						helpText.Text = "You are faster!"
						wait(5.0)
						helpText.Text = "Click on the chocobox to see your luck!" 
						myHumanoid.WalkSpeed = 16.0
					elseif effect >= 0.4  and effect < 0.75 then 	
					
						local ratio = myHumanoid.Health/myHumanoid.MaxHealth
						while myHumanoid.MaxHealth < 250 do 
							myHumanoid.MaxHealth = 250 
						end			

						while myHumanoid.Health < ratio * myHumanoid.MaxHealth do 
							myHumanoid.Health = ratio * myHumanoid.MaxHealth
						end		
						helpText.Text = "You are stronger!"
						wait(5.0)
						helpText.Text = "Click on the chocobox to see your luck!" 
						local ratio = myHumanoid.Health/myHumanoid.MaxHealth
						myHumanoid.Health = ratio * 100
						myHumanoid.MaxHealth = 100

					elseif effect >= 0.75 and effect < 0.8 then 
						floatForce = Instance.new("BodyForce")
						floatForce.Name = "Float"
						floatForce.force = Vector3.new(0, 3 * myTorso:GetMass() * 196.1, 0)
						floatForce.Parent = myTorso
						helpText.Text = "You can glide!"
						wait(5.0)
						helpText.Text = "Click on the chocobox to see your luck!" 
						if floatForce then floatForce:Destroy() end 
					else 
						fire.Parent = myTorso
						myTorso.Touched:connect(blow)
						lunge(myHumanoid, myTorso)
						helpText.Text = "You are Buuuuuuuuuuuuurning!"
						wait(6.0)
						helpText.Text = "Click on the chocobox to see your luck!" 
						if fire then fire:Destroy() end 
					end 
					wait(2.0)
					Chocobox.Transparency = 0.0
				end  
			end)
		end 
	end 
end

function onUnequipped()
	Chocobox.Transparency = 0.0 
	if chocoGui then chocoGui:Destroy() end 
	myHumanoid.WalkSpeed = 16.0
	local ratio = myHumanoid.Health/myHumanoid.MaxHealth 
	myHumanoid.MaxHealth = 100.0 
	myHumanoid.Health = ratio * 100.0
	if fire then fire:Destroy() end 
	if floatForce then floatForce:Remove() end
	if bv then bv:Destroy() end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)