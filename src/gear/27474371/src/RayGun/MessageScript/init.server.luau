--Fixed by Luckymaxer

Figure = script.Parent

Players = game:GetService("Players")

PersonToPester = Figure:WaitForChild("PersonToPester")

local noobSayings = 
	{"Will you donate me? plz?",
	"THIS IS NOT FAKE BUILDERMAN TOLD ME HOW TO GET 1000000000 ROBUX AND TIX SO COPY THIS ON 10 HATS AND LOOK AT YOUR MONEY",
	"Come to my place to get on film!",
	"Can I friend you?",
	"What is a 'noob'?",
	"Plz join my group",
	"Why are you running away?",
	"I'm totally 1337",
	"How do I get Robux?",
	"Hi."
}

local Debris = game:GetService("Debris") 

Message = script:WaitForChild("Message"):Clone()

function saySomething(player, duration)
	if not player then
		return
	end
	local PlayerGui = player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	local NewMsg = Message:Clone()
	NewMsg.Frame.TextLabel.Text = noobSayings[math.random(1,#noobSayings)]
	Debris:AddItem(NewMsg, duration)
	NewMsg.Parent = PlayerGui
end

while true do
	wait(5)
	local Player = Players:GetPlayerFromCharacter(PersonToPester.Value)
	if Player then
		saySomething(Player, 5)
	end
end

