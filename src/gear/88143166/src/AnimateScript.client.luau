-- For the purpose of animations

local Tool = script.Parent 
local Handle = Tool.Handle 

local vCharacter
local vPlayer
local vTorso
local vHumanoid 

local VaultAnim

local OnRunConn

local OnJumpConn

local LastStoppedTime = nil

local AnimStartTime = nil

local origCameraType

local RBX_Debris = game:GetService('Debris')

local speedUp = 1.5

local bg 
local equipped = false

function onEquipped()
	if equipped then return end
	equipped = true
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vTorso = vCharacter:FindFirstChild("Torso")
	
	-- GUI STUFF

	bg = Instance.new("BillboardGui")
	bg.Parent = vCharacter--.PlayerGui--game.Workspace
	bg.Adornee = vCharacter.Head
	bg.Size = UDim2.new(10, 0, 3, 0)
	-- Above (defaults to inside)
	bg.StudsOffset = Vector3.new(0, 4, 0)


	-- END GUI


	if not VaultAnim then
		VaultAnim = vHumanoid:LoadAnimation(Tool.VaultAnim)
	end
	if VaultAnim then
		VaultAnim:Play()
	end
	OnRunConn = vHumanoid.Running:connect(onRun)
	OnJumpConn = vHumanoid.Jumping:connect(onJump)
end 

function onUnequipped()
	equipped = false	
	if VaultAnim then
		VaultAnim:Stop()
		VaultAnim = nil
	end
	if OnRunConn then
		--print('Disconnecting on run')
		OnRunConn:disconnect()
		OnRunConn = nil
	end
	if OnJumpConn then
		OnJumpConn:disconnect()
		OnJumpConn = nil
	end
end


function fadeTxtGuiElement(mesg)
	local frame = Instance.new("Frame")
	frame.Parent = bg
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1.0
	frame.BackgroundColor3 = Color3.new(1, 1, 1)

	local text = Instance.new('TextLabel')
	text.Parent = frame
	text.Font=Enum.Font.ArialBold
	text.Position = UDim2.new(0, 0, 0, 0)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.TextScaled=true
	text.Text=mesg
	
	local fadetime = 0.8 / speedUp
	--text:TweenPosition(UDim2.new(0, 0, 0, 0))
	RBX_Debris:AddItem(frame, fadetime)
	--wait(fadetime)
	--frame:Destroy()
end

function onJump(active)
	if AnimStartTime ~= nil then 
		local deltaTime = time() - AnimStartTime 
		--print('Jumped at ' .. deltaTime)
		if deltaTime < (2.1 / speedUp) and deltaTime > (1.55 / speedUp) then
			local bf = Instance.new('BodyForce')
			bf.force = Vector3.new(0, 6000, 0)
			if vTorso then
				bf.Parent = vTorso
			end
			RBX_Debris:AddItem(bf, 0.5)
			if vTorso then
				vTorso.Velocity = vTorso.Velocity + vTorso.CFrame.lookVector * 80
			end
			Tool.playVault.Value = not Tool.playVault.Value
			wait(0.2)
			local explosion = Instance.new('Explosion', Workspace)
			explosion.BlastPressure = 0
			explosion.Position = vTorso.CFrame.p - Vector3.new(0, 8, 0)
			wait(2.1)
			Tool.playCheer.Value = not Tool.playCheer.Value
		end
	end
end

function showJumpNow()
	wait(1.35 / speedUp)
	if AnimStartTime and time() - AnimStartTime > (1.3 / speedUp) then
		--print('Making GUI')
		fadeTxtGuiElement('Jump Now!')
	end
end

function onRun(speed)

	if not VaultAnim then
		VaultAnim = vHumanoid:LoadAnimation(Tool.VaultAnim)
		
	end
	if VaultAnim then
		if speed == 0 then
			if LastStoppedTime == nil then
				LastStoppedTime = time()
			end
			-- make sure they have been stopped for 0.2 seconds before stopping the anim
			if time() - LastStoppedTime > 0.2 then
				LastStoppedTime = time()
				--print('Stopping')
				VaultAnim:Stop()
				if Tool.stopRun then
					--print('stopping run')
					Tool.stopRun.Value = not Tool.stopRun.Value
				end
				AnimStartTime = nil
			end
		else
			LastStoppedTime = nil
			if not AnimStartTime or time() - AnimStartTime > (2.5 / speedUp) then
				--print('Playing')
				AnimStartTime = time()
				--firstStoppedTime = nil
				VaultAnim:Play()
				VaultAnim:AdjustSpeed(speedUp)
				if Tool.playRun then
					Tool.playRun.Value = not Tool.playRun.Value
				end
				showJumpNow()
			end
		end
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
