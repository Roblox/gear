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
	"Hi."}

local debris = game:GetService("Debris") 

function saySomething()

	local m = Instance.new("Message")
	m.Text = noobSayings[math.random(1,#noobSayings)]

	if script.Parent.PersonToPester.Value ~= nil then
		local player = game.Players:GetPlayerFromCharacter(script.Parent.PersonToPester.Value.Parent)
		m.Parent = player
		debris:AddItem(m,5)
	end

end

while true do

	wait(5)
	saySomething()

end

