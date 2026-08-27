--[[local oldMessages = 
{
	"IT'S A LIE",
	"YOU'LL NEVER MAKE IT",
	"YOU'RE JUST LIKE EVERYONE ELSE",
	"I DIDN'T EVEN BAKE IT",
	"YOU'RE WASTING YOUR TIME",
	"YOU NEVER APPRECIATE ME",
	"IT'S TOO LATE",
}--]]


local Messages = 
{
	"REPOST FOR FREE BC",
	"PLZ DONATE",
	"IM SUCH A HAXOR",
	"PLAY MY ESCAPE THE OBBY FOR FREE VIP/ADMIN",
	"WHAT A NOOB",
	"THIS IS SO EPIC!!",
	"F1RST",
	"WHY U SO MAD BRO",
	"YOLO",
}

local StartPositions =
{
	function() return UDim2.new(1,0,math.random(),0),'Right' end,
	function() return UDim2.new(-1,0,math.random(),0),'Left' end,
	function() return UDim2.new(math.random(),0,1,0),'Right' end,
	function() return UDim2.new(math.random(),0,-1,0),'Left' end,
}
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=107450062")
local TalkSound = Instance.new('Sound')
TalkSound.SoundId = 'http://www.roblox.com/asset/?id=107450062'
TalkSound.Parent = script.Parent
wait(1)
TalkSound:Play()

--game.Debris:AddItem(TalkSound,

local TemplateText = Instance.new('TextLabel')
TemplateText.Font = 'ArialBold'
TemplateText.FontSize = 'Size48'
TemplateText.TextXAlignment = 'Left'
TemplateText.TextYAlignment = 'Top'

local spawnedAll = false

for i=1,400,1 do
	Spawn(function()
		local text = TemplateText:Clone()
		text.Position, text.TextXAlignment = StartPositions[math.random(1,4)]()
		text.Text = Messages[math.random(#Messages)]
		if math.random(1,20)==1 then
			text.TextColor3 = Color3.new(1,1,1   )
			text.ZIndex = 2
		end
		text.Parent = script.Parent
		text:TweenPosition(UDim2.new((math.random()*.6)+.2,0,math.random(),0), "Out", "Quad", (math.random()*2)+1, true)
		while not spawnedAll do wait() end
		wait(3)
		for i = 1, 20,1 do
			text.TextTransparency = text.TextTransparency+(1/20)
			wait(1/20)
		end
	end)
		wait((math.random()+.1)/30)
end
spawnedAll=true
wait(3)
for i = 1, 20,1 do
	TalkSound.Volume = TalkSound.Volume-(.5*(1/20))
	wait(1/20)
end
wait(10)
TalkSound:Destroy()
script.Parent:Destroy()

