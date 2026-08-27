-- Made by Stickmasterluke
 -- edited by fusroblox
--[[
	Fixed by ArceusInator 3/2/2015
	- Now works with FE
	- Gibs are now properly colored + Characters now spew gory gibs just like other bricks
	- No longer teamkills
	- Now registers KOs to the site
--]]

function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
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
	Gui = script.Parent:WaitForChild'AmmoHud',
	NumberImages={},
	IdleAni,
	
	
}
local reloadani, fireani = nil ,nil

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

function GunObj:CursorUpdate()
	local reloadCounter=0
end


script.Parent.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == script.Parent.Parent then
		if action == 'Mouse1' then
			local down, pos = ...
			
			if down then
				if not Tool.Down.Value then
					Tool.Aim.Value = pos
					Tool.Down.Value = true
					while Tool.Down.Value do
						Tool.Aim.Value = pos
						wait()
					end
				end
			else
				Tool.Down.Value = false
			end
		end
	end
end)


function GunObj:OnEquipped()
	self:Initialize()
		self.Equipped = true
		local Player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
		if Player ~= nil then
			local humanoid=WaitForChild(Player.Character,'Humanoid')
			if self.IdleAni then
				self.IdleAni:Stop()
			end
			self.IdleAni = humanoid:LoadAnimation(WaitForChild(script.Parent,'idle'))
			self.IdleAni:Play()
			local plrgui = WaitForChild(Player,"PlayerGui")
			self.Gui.Parent = plrgui
			Tool.Reloading.Changed:connect(function(val)
				if self.Equipped then
					if val then
					else
					end
					if Player ~= nil then
						self.Gui.Parent = Player:WaitForChild'PlayerGui'
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
		self.IdleAni=nil
	end
	if reloadani then reloadani:Stop() reloadani=nil end
	if fireani then fireani:Stop() fireani=nil end
	self.Gui.Parent = Tool
	self.Equipped = false
	print('in unequipp')
	if ChestWeld then
		print('chestweldexists')
		ChestWeld:Destroy()
	end
end

function PlayFireAni()
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.FireAni)
	aniTrack:Play(0,1,3)
	fireani = aniTrack
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
	local aniTrack = WaitForChild(Tool.Parent,"Humanoid"):LoadAnimation(Tool.Reload)
	reloadani = aniTrack
	local torso=WaitForChild(Tool.Parent,'Torso')
	local oldWeld
	for _,i in pairs(WaitForChild(Tool.Parent,'Right Arm'):GetChildren()) do
		if i:IsA('Weld') and i.Part1==Tool.Handle then
			oldWeld=i
		end
	end
	ChestWeld= weldBetween(torso,Tool.Handle)
	oldWeld.Part1=nil
	aniTrack:Play(0,1,2)
	wait(4)
	oldWeld.Part1=Tool.Handle
	ChestWeld:Destroy()
	ChestWeld=nil
	
end

Tool.Reloading.Changed:connect(function() if Tool.Reloading.Value then PlayReloadAni() end end)
