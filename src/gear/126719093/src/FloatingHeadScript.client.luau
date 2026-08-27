local HEAD_IDENTIFIER = "FloatingHeadGear"

--
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Player, Character, Humanoid, Torso, Head;

--
local function ConstructHead()
	local head = Handle:Clone()
	--
	local force = Instance.new('BodyPosition')
	force.Name = 'Mover'
	force.Parent = head
	force.P = 20000
	force.maxForce = Vector3.new(10000, 10000, 10000)
	local gyro = Instance.new('BodyGyro')
	gyro.Name = 'Gyro'
	gyro.Parent = head
	gyro.P = 20000
	gyro.maxTorque = Vector3.new(400000, 400000, 400000)
	--
	head.Name = HEAD_IDENTIFIER
	head.CanCollide = false
	--
	head.HeadScript.Disabled = false
	head.Parent = Character
	--
	return head
end

--
Tool.Equipped:connect(function(mouse)
	-- Get basic vars
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:WaitForChild('Humanoid')
	Torso = Character:WaitForChild('Torso')
	Head = Character:WaitForChild('Head')
	
	-- Usage
	mouse.Button1Down:connect(function()
		-- Do we already have a head
		if Character:FindFirstChild(HEAD_IDENTIFIER) then return end
		
		-- No? Make the head
		local floatingHead = ConstructHead()
		floatingHead.CFrame = Head.CFrame
	end)
end)

Tool.Unequipped:connect(function()
	-- Nothing to do.
end)