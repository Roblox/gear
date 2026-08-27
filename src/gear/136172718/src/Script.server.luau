---------------------------------
	-- scripted by jmargh --
---------------------------------

---------------------------------
		-- Tool Variables --
---------------------------------

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local DebrisService = game:GetService('Debris')
local InsertService = game:GetService('InsertService')
local IsOnCoolDown = false
local IsOnCoolDownValue = Tool:WaitForChild('IsOnCoolDown')

---------------------------------
		-- Constants --
---------------------------------

local COOLDOWN = 5

local Presents = {
	[1] = '136213778',	-- yeti club
	[2] = '99119261',	-- winter snow sled
	[3] = '87361662',	-- ice breaker
	[4] = '19704064',	-- ice staff
	[5] = '40811356',	-- Frosted Santa, Harbinger of Christmas Creep
	[6] = '42845853',	-- Super Freeze Ray 2011
	[7] = '43567614',	-- Santa Grapple Gun
	[8] = '67319408',	-- santa jetpack
	[9] = '67755192',	-- santa sleigh
	[10] = '19396450',	-- santa
	[11] = '22971409',	-- nuclear winter ice gun
}

local function onActivated()
	if IsOnCoolDown then
		return
	end
	IsOnCoolDown = true
	
	local randomIndicator = math.random(1, 3)
	magicSound = Handle:FindFirstChild("MagicSound"..tostring(randomIndicator))

	if magicSound then
		magicSound:Play()
	end
	
	if #Presents > 0 then
		local presentIndex = nil
		numLoops = math.random(0,math.floor(1000*time()))
		numLoops = numLoops - (math.floor(numLoops / 10000)*10000)
		for i = 1,numLoops do
			presentIndex = math.random(1,#Presents)
		end

		local item = InsertService:LoadAsset(Presents[presentIndex])
		if item then
			local tool = nil
			for _,item in pairs(item:GetChildren()) do
				if item:IsA('Tool') then
					tool = item:Clone()
					break
				end
			end
			if tool then
				local handle = tool:FindFirstChild('Handle')
				if handle then
					handle.CFrame = CFrame.new(Handle.CFrame.p + Handle.CFrame.lookVector * 5)
				end
				tool.Parent = game.Workspace
				IsOnCoolDownValue.Value = true
				wait(COOLDOWN)
			end
		end
	end
	
	IsOnCoolDown = false
	IsOnCoolDownValue.Value = false
end

local function onEquipped()
	magicSound = Handle:FindFirstChild("MagicSound1")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Handle
		magicSound.Volume = .5
		magicSound.SoundId = "http://www.roblox.com/asset/?id=19358641"
		magicSound.Name = "MagicSound1"
	end

	magicSound = Tool.Handle:FindFirstChild("MagicSound2")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=19259975"
		magicSound.Name = "MagicSound2"
	end

	magicSound = Tool.Handle:FindFirstChild("MagicSound3")
	if magicSound == nil then
		magicSound = Instance.new("Sound")
		magicSound.Parent = Handle
		magicSound.Volume = 1
		magicSound.SoundId = "http://www.roblox.com/asset/?id=19260023"
		magicSound.Name = "MagicSound3"
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
