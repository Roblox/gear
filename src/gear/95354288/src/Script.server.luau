-- Made by Stickmasterluke
 -- edited by fusroblox
--[[
	Fixed by ArceusInator 2/25/2015
	- Now works with FE
	- Should no longer lock up occasionally when you shoot an NPC
	- Gibs are now properly colored + Characters now spew gory gibs just like other bricks
	- No longer teamkills
	- Now registers KOs to the site
--]]

function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
		--print("1waiting for " .. name)
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

local MouseObj = {
	Hit = CFrame.new()
}
local GunObj ={
	Reloading = "http://www.roblox.com/asset/?id=94155503",
	
	Cursors = {
		"http://www.roblox.com/asset/?id=94154683", -- black
		"http://www.roblox.com/asset/?id= 94154829", -- red
		"http://www.roblox.com/asset/?id=94155503", 
		"http://www.roblox.com/asset/?id=94155569"
	},
	
	ClipSize = 8,
	Equipped = false,
	
	Player = nil,
	Ammo = WaitForChild(script.Parent,"Ammo"),
	Clips,
	Gui = WaitForChild(Tool,"AmmoHud"),
	NumberImages={},
	IdleAni,
	MyMouse
	
}

local ChestWeld
Tool.Equipped:connect(function() GunObj:OnEquipped() end)
local initialized=false

function GunObj:Initialize()
	if initialized then return end
	initialized=true
	self.Ammo.Changed:connect(function()self:UpdateGui()end)

	WaitForChild(Tool, "Reloading")
	print('got to connections!!!!! ')
	Tool.Reloading.Changed:connect(function() self:UpdateGui() end)
	Tool.Unequipped:connect(function() self:OnUnequipped() end)
	
	Tool.DoFireAni.Changed:connect(PlayFireAni)
	self.NumberImages['0']=94105090
	self.NumberImages['1']=94099941
	self.NumberImages['2']=94105282
	self.NumberImages['3']=94105353
	self.NumberImages['4']=94105393
	self.NumberImages['5']=94105402
	self.NumberImages['6']=94105413
	self.NumberImages['7']=94105478
	self.NumberImages['8']=94105560
	self.NumberImages['9']=94105576

	local bar=WaitForChild(self.Gui,'Bar')
	self:UpdateNumbers(self.ClipSize..'', WaitForChild(bar,'TotalAmmo'))
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
		local Player = GunObj.Player
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

function GunObj:CursorUpdate()
	local reloadCounter=0
	while self.Equipped do
		wait(1/30)
	end
end

local InReload=false

script.Parent.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == script.Parent.Parent then
		if action == 'Mouse1' then
			local down, hit, target = ...
			
			if down then
				if not Tool.Down.Value then
					Tool.Aim.Value = hit
					Tool.Down.Value = true
					while Tool.Down.Value do
						Tool.Aim.Value = hit
						wait()
					end
				end
			else
				Tool.Down.Value = false
			end
			
			MouseObj.Hit, MouseObj.Target = hit, target
		elseif action == 'MouseMove' then
			MouseObj.Hit, MouseObj.Target = ...
		elseif action == 'Key' then
			local down, key = ...
			
			if down then
				if key=='r' and not Tool.Reloading.Value and not Tool.Down.Value and GunObj.Ammo.Value ~=8 and GunObj.Ammo.Value ~=0 and not InReload then
					Tool.Reloading.Value=true
				end
			end
		end
	end
end)

function GunObj:OnEquipped()
	self:Initialize()
	self.Equipped = true
	GunObj.Player = game:GetService'Players':GetPlayerFromCharacter(Tool.Parent)
	local Player = GunObj.Player
	if Player ~= nil then
		local humanoid=WaitForChild(Player.Character,'Humanoid')
		if not self.IdleAni then
			self.IdleAni = humanoid:LoadAnimation(WaitForChild(script.Parent,'idle'))
			self.IdleAni:Play()
		end
		local plrgui = WaitForChild(Player,"PlayerGui")
		self.Gui.Parent = plrgui
		Tool.Reloading.Changed:connect(function(val)
			if self.Equipped then
				if val then
				else
				end
				local Player = GunObj.Player
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
		Spawn(function() self:CursorUpdate() end )
	end
end

function GunObj:OnUnequipped()
	if self.IdleAni then
		self.IdleAni:Stop()
		self.IdleAni:Destroy()
		self.IdleAni=nil
	end
	self.Gui.Parent = Tool
	self.Equipped = false
	print('in unequipp')
	if ChestWeld then
		print('chestweldexists')
		ChestWeld:Destroy()
	end
	local Player = GunObj.Player
	if Player ~= nil then
		local gui = WaitForChild(Player.PlayerGui,"AmmoHud")
		--gui.Bar.GunLabel.Text = ""
		--gui.Bar.AmmoLabel.Text = ""
	end
end

function PlayFireAni()
	wait(.1)
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.FireAni)
	aniTrack:Play(0,1,1)
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


function PlayReloadAni()
	InReload=true
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.Reload)
	local torso=WaitForChild(Tool.Parent,'Torso')
	local oldWeld
	for _,i in pairs(WaitForChild(Tool.Parent,'Right Arm'):GetChildren()) do
		if i:IsA('Weld') and i.Part1==Tool.Handle then
			oldWeld=i
		end
	end
	if not oldWeld then 
		print('What... no old weld!')
		return
	end
	ChestWeld= weldBetween(torso,Tool.Handle)
	oldWeld.Part1=nil
	aniTrack:Play(0,1,2)
	wait(4)
	oldWeld.Part1=Tool.Handle
	ChestWeld:Destroy()
	ChestWeld=nil
	InReload=false
end

Tool.Reloading.Changed:connect(function() if Tool.Reloading.Value then PlayReloadAni() end end)
