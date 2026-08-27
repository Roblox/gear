-- Made by Stickmasterluke
 -- edited by fusroblox

function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
	end
	return obj:FindFirstChild(name)
end

local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		if subject:FindFirstChild('Humanoid') then
			return subject
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

local Tool = script.Parent

local GunObj ={
	Reloading = "http://www.roblox.com/asset/?id=94155503",
	
	Cursors = {
		"http://www.roblox.com/asset/?id=113254097", -- black
		"http://www.roblox.com/asset/?id=113254097", -- red
		"http://www.roblox.com/asset/?id=113253212", 
		"http://www.roblox.com/asset/?id=113253598"
	},
	
	ClipSize = 8,
	Equipped = false,
	
	Player = game.Players.localPlayer,
	Ammo = WaitForChild(script.Parent,"Ammo"),
	Clips,
	Gui = WaitForChild(Tool,"AmmoHud"),
	NumberImages={},
	IdleAni, FireAni, ReloadAni
	
	
}

local ChestWeld

local initialized=false

function GunObj:Initialize()
	if initialized then return end
	initialized=true
	self.Ammo.Changed:connect(function()self:UpdateGui()end)

	WaitForChild(Tool, "Reloading")
	
	
	Tool.Reloading.Changed:connect(function() if Tool.Reloading.Value then PlayReloadAni() end end)
	
	Tool.Reloading.Changed:connect(function() self:UpdateGui() end)
	
	Tool.DoFireAni.Changed:connect(PlayFireAni)
	self.NumberImages['0']=94128401
	self.NumberImages['1']=94128421
	self.NumberImages['2']=94128434
	self.NumberImages['3']=94128446
	self.NumberImages['4']=94128466
	self.NumberImages['5']=94128485
	self.NumberImages['6']=94128496
	self.NumberImages['7']=94128523
	self.NumberImages['8']=94128538
	self.NumberImages['9']=94128538

	local bar=WaitForChild(self.Gui,'Bar')
	self:UpdateNumbers(self.ClipSize..'', WaitForChild(bar,'TotalAmmo'))
	
	Tool.Unequipped:connect(function() GunObj:OnUnequipped() end)
	Tool.Equipped:connect(function(mouse) GunObj:OnEquipped(mouse) end)
end

function GunObj:UpdateNumbers(data,frame)
	if string.len(data)==0 then
		data= '0'..data
	end
	if string.len(data)==1 then
		data= '0'..data
	end

	local digit=WaitForChild(WaitForChild(frame,'1'),'digit')
	if digit.Image ~='http://www.roblox.com/asset/?id='..self.NumberImages[string.sub(data,1,1)] then
		local ndigit=digit:Clone()
		ndigit.Position=UDim2.new(ndigit.Position.X.Scale,ndigit.Position.X.Offset,ndigit.Position.Y.Scale,ndigit.Position.Y.Offset-65)
		ndigit.Image='http://www.roblox.com/asset/?id='..self.NumberImages[string.sub(data,1,1)]
		ndigit.Parent=digit.Parent
		ndigit:TweenPosition(digit.Position, "Out", "Quad", .1)
		digit.Name='oldDigit'
		digit:TweenPosition(UDim2.new(digit.Position.X.Scale,digit.Position.X.Offset,digit.Position.Y.Scale,digit.Position.Y.Offset+65), "Out", "Quad", .25)
		game.Debris:AddItem(digit,1)
	end
	digit=WaitForChild(WaitForChild(frame,'2'),'digit')
	if digit.Image ~='http://www.roblox.com/asset/?id='..self.NumberImages[string.sub(data,2,2)] then
		ndigit=digit:Clone()
		ndigit.Position=UDim2.new(ndigit.Position.X.Scale,ndigit.Position.X.Offset,ndigit.Position.Y.Scale,ndigit.Position.Y.Offset-65)
		ndigit.Image='http://www.roblox.com/asset/?id='..self.NumberImages[string.sub(data,2,2)]
		ndigit.Parent=digit.Parent
		ndigit:TweenPosition(UDim2.new(digit.Position.X.Scale,digit.Position.X.Offset,digit.Position.Y.Scale,0), "Out", "Quad", .25)
		digit.Name='oldDigit'
		digit:TweenPosition(UDim2.new(digit.Position.X.Scale,digit.Position.X.Offset,digit.Position.Y.Scale,digit.Position.Y.Offset+65), "Out", "Quad", .25)
		game.Debris:AddItem(digit,1)
	end
end

function GunObj:UpdateGui()
	if self.Equipped then
		local Player = game.Players.localPlayer
		if Player ~= nil then
			if self.Ammo == nil then
				--self.Gui.Bar.GunLabel.Text ="Futuro Heavy Pistol"
				--self.Gui.Bar.AmmoLabel.Text = ""
			else
				--self.Gui.Bar.GunLabel.Text ="Futuro Heavy Pistol"
				--self.Gui.Bar.AmmoLabel.Text = tostring(self.Ammo.Value).."/"..tostring(self.ClipSize)
				self:UpdateNumbers(tostring(self.Ammo.Value),WaitForChild(self.Gui.Bar,'AmmoLeft'))
			end
			if Tool.Reloading.Value then
				--self.Gui.Bar.AmmoLabel.Text = "Reloading"
			end
		end
	end
end

function GunObj:CursorUpdate(mouse)
	local reloadCounter=0
	while self.Equipped do
		if Tool.Reloading.Value then
			reloadCounter=reloadCounter+1
			if reloadCounter%20<10 then
				mouse.Icon = self.Cursors[3]
			else
				mouse.Icon = self.Cursors[4]
			end
		elseif mouse.Target and FindCharacterAncestor(mouse.Target) then
			mouse.Icon = self.Cursors[2]
		else 
			mouse.Icon = self.Cursors[1]
		end
		wait(1/30)
	end
end

function GunObj:AimLoop(torso,mouse)
	if torso:FindFirstChild('BodyGyro') then torso.BodyGyro.Parent = nil end
	local gyro = Instance.new('BodyGyro')
	gyro.cframe = CFrame.Angles(-math.pi/2,0,0)
	gyro.maxTorque= Vector3.new(math.huge,math.huge,math.huge)
	gyro.Parent = torso
	local human = torso.Parent:FindFirstChild'Humanoid'
	human.AutoRotate = false
	while self.Equipped do
		local diff = -(mouse.Hit.p - torso.CFrame.p)
		gyro.cframe = CFrame.Angles(-math.pi/2,0,math.atan2(diff.x,diff.z))
		wait()
	end
	gyro.Parent = nil
	human.AutoRotate = true
	human:ChangeState(Enum.HumanoidStateType.GettingUp)
end

function GunObj:OnEquipped(mouse)
	Spawn(function()
		if self.Equipped then self:OnUnequipped() end
		if mouse ~= nil and not self.Equipped then
			self.Equipped = true
			local Player = game.Players.LocalPlayer
			if Player ~= nil then
				if Player.Character:FindFirstChild('Torso') then
					Spawn(function() self:AimLoop(Player.Character.Torso,Player:GetMouse()) end)
				end
				local humanoid=WaitForChild(Player.Character,'Humanoid')
				if self.IdleAni then self.IdleAni:Stop() end
				--if not self.IdleAni then
					self.IdleAni = humanoid:LoadAnimation(WaitForChild(script.Parent,'idle'))
					self.IdleAni:Play()
				--end
				local plrgui = WaitForChild(Player,"PlayerGui")
				self.Gui.Parent = plrgui
				local down = false
				mouse.Button1Down:connect(function()
					if not down then
						down = true
						Tool.MousePos:FireServer(mouse.Hit.p)
						Tool.MouseDown:FireServer()
						while down do
							wait()
							Tool.MousePos:FireServer(mouse.Hit.p)
						end
					end
				end)
				mouse.Button1Up:connect(function()
					down = false
					Tool.MouseUp:FireServer()
				end)
				--mouse.Icon = self.Cursors[1]
				Tool.Reloading.Changed:connect(function(val)
					if mouse ~= nil and self.Equipped then
						if val then
							--mouse.Icon = self.Cursors.Reloading
						else
							--mouse.Icon = self.Cursors[1]
						end
						local Player = game.Players.LocalPlayer
						if Player ~= nil then
							local gui = WaitForChild(Player.PlayerGui, "AmmoHud")
							local humanoid=WaitForChild(Player.Character,'Humanoid')
							self:UpdateGui()
							if Tool.Reloading.Value then
								--gui.Bar.AmmoLabel.Text = "Reloading"
							end
						end
					end
				end)
				self:UpdateGui()
	
				Spawn(function() self:CursorUpdate(mouse) end)
			end
		end
	end)
end

function GunObj:OnUnequipped()
		--JUST FREAKING STOP PLEAAASE
		--I'm almost crying, this is insane.
		if self.IdleAni then
			self.IdleAni:Stop()
			self.IdleAni=nil
		end
		if self.FireAni then
			self.FireAni:Stop()
			self.FireAni=nil
		end
		if self.ReloadAni then
			self.ReloadAni:Stop()
			self.ReloadAni=nil
		end

		self.Gui.Parent = Tool
		
		local Player = game.Players.localPlayer
		if Player ~= nil then
			local gui = Player.PlayerGui:FindFirstChild("AmmoHud")
			if gui then
				gui.Parent =nil
			end
		end
		self.Equipped = false
	--end)
end

function PlayFireAni() if true then return end
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.FireAni)
	GunObj.FireAni = aniTrack
	aniTrack:Play(0,1,3)
end

local function weldBetween(a, b)
    local weld = Instance.new("Weld")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse() * a.CFrame
    weld.Parent = a
    return weld;
end


function PlayReloadAni() if true then return end
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.Reload)
	GunObj.ReloadAni = aniTrack
	local torso=WaitForChild(Tool.Parent,'Torso')
	--[[
	local oldWeld
	for _,i in pairs(WaitForChild(Tool.Parent,'Right Arm'):GetChildren()) do
		if i:IsA('Weld') and i.Part1==Tool.Handle then
			oldWeld=i
		end
	end
	--]]
	--ChestWeld= weldBetween(torso,Tool.Handle)
	--oldWeld.Part1=nil
	aniTrack:Play(0,1,1)
	--wait(4)
	--oldWeld.Part1=Tool.Handle
	--ChestWeld:Destroy()
	--ChestWeld=nil
	
end


wait(1)
GunObj:Initialize()