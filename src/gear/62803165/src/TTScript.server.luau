local Tool = script.Parent 
local Bag = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true 

local bagSound

local flyBV

local characterMass

local assets = {36913598, 36107470, 36042821}

local sg 
local frame 
local textLabel

function computeWeight(object) 
	local totalMass = 0
	local ch
	if object == nil then return end
	if type(object) == "table" then 
		ch = object
	else
		ch = object:GetChildren()	
	end
	for i = 1, #ch do 
		if ch[i]:IsA("BasePart") then 
			totalMass = totalMass + ch[i]:GetMass()
		end		
		totalMass = totalMass + computeWeight(ch[i])		
	end	
	return totalMass
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	
	if myHumanoid == nil or myTorso == nil then
		return 
	end

	Tool.Enabled = false 
		
	tick()

	local effect = math.random(1, 6)
	print(effect)
	if effect == 1 then
		myHumanoid.WalkSpeed = 10.0
		if textLabel then textLabel.Text = "Oh noes.. its a trick! You are slowed!" end
		wait(5.0)
		if textLabel then textLabel.Text = "" end
		myHumanoid.WalkSpeed = 16.0
	elseif effect == 2 then 
		if textLabel then textLabel.Text = "Oh noes... its a trick! You are confused!" end
		myHumanoid.WalkSpeed = -16.0
		wait(5.0)
		if textLabel then textLabel.Text = "" end
		myHumanoid.WalkSpeed = 16.0
	elseif effect == 3 then 
		if textLabel then textLabel.Text = "Its a great treat! Your health and movement speed are tremendously increased!" end
		myHumanoid.WalkSpeed = 30 
		local ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 250 
		while myHumanoid.Health < ratio * 250 do 
			wait()
			myHumanoid.Health = ratio * 250 
		end
		wait(9.0)
		if textLabel then textLabel.Text = "" end
		myHumanoid.WalkSpeed = 16.0
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.MaxHealth = 100
		myHumanoid.Health = ratio * 100
	elseif effect == 4 or effect == 6 then 
		if textLabel then textLabel.Text = "Its a treat! Have fun with this item" end
		tick()
		local asset = game:GetService("InsertService"):LoadAsset(assets[math.random(1, #assets)])
		if asset then 
			asset = asset:GetChildren() 
			if asset then 
				asset = asset[1] 
				asset.Parent = game.Workspace
				asset.Handle.CFrame = myTorso.CFrame + myTorso.CFrame.lookVector * 5.0 
			end
		end
		wait(6.0)
		if textLabel then textLabel.Text = "" end
	else 	
		if textLabel then textLabel.Text = "YAY! Its a treat, now Fly!" end
		if myTorso:FindFirstChild("FlyBV") == nil then
			flyBV = Instance.new("BodyVelocity")
			flyBV.P = 50000
			flyBV.maxForce = Vector3.new(0, flyBV.P, 0)
			flyBV.Name = "FlyBV"
			flyBV.velocity = Vector3.new(0, characterMass/4.0, 0)
			flyBV.Parent = myTorso
		end
		wait(7.0)
		if textLabel then textLabel.Text = "" end
		if flyBV then flyBV:Remove() end
	end	
	wait(1.0)
	Tool.Enabled = true 	
end

function onEquipped()
	vCharacter = Tool.Parent 
	characterMass = computeWeight(vCharacter)
	print(characterMass)
	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then 
		sg = Instance.new("ScreenGui")
		sg.Parent = vPlayer.PlayerGui
			
		frame = Instance.new("Frame")
		frame.Parent = sg
		frame.Size = UDim2.new(0.2, 0, 0.2, 0)
		frame.Position = UDim2.new(0.4, 0, 0, 0)
		frame.BackgroundTransparency = 1.0
		
		textLabel = Instance.new("TextLabel")
		textLabel.Parent = frame
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Position = UDim2.new(0, 0, 0.5, 0)
		textLabel.Text = ""
		textLabel.BackgroundTransparency = 1.0	
		textLabel.FontSize = Enum.FontSize.Size18
		textLabel.TextColor3 = Color3.new(153/255, 0, 0)
	end	
end

function onUnequipped()
	if myHumanoid then
		myHumanoid.WalkSpeed = 16.0
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.MaxHealth = 100
		myHumanoid.Health = ratio * 100
	end

	coroutine.resume(coroutine.create(function() wait(2.0) if flyBV then flyBV:Remove() end end))
	if sg then sg:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
