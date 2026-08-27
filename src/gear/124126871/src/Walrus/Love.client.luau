--math.randomseed(tick())
-- I'm putting the randomseed call in the EventsAndAnims script instead. Otherwise the first
-- message from each walrus is always the same, since the ticks are so similar.
local MESSAGE_TIME = 10
local NUMBER_OF_MESSAGES = 5
local STEP_TIME = 0.1
local NUM_STEPS = 10
local SMOKE_TIME = 1
local A_LITTLE_EXTRA = 5
local HEALING_DAMAGE = -1

local MESSAGES = {
	"I am the walrus. Goo goo g'joob.",
	"I love you unconditionally.",
	"You are my best friend in the whole wide world.",
	"<3",
	"Every time you do a good deed, a walrus gets its tusks.",
	"^_^",
	":P",
	"This is the happiest moment of my life.",
	"I believe in you.",
	"Don't lose faith! Trust in yourself, as I trust in you.",
	"To quote a wise walrus, 'Ooooooooooooooooghhhh.'",
	"Shoot for the moon. Even if you miss, you'll land among the stars.",
	"Today is the first day of the rest of your life.",
	"I just want you to know that I'll always be here for you.",
	"You make my heart smile.",
	"I just wanted you to know I think you're pretty cool.",
	"You are my favorite person.",
	"I hope you are enjoying my hug.",
	"If you were ice cream, what flavor would you be?",
	"Wanna go to the zoo? I'm visiting my aunt Bertha later today.",
	"I am feeling especially tusky today.",
	"You inspire me.",
	"Thank you for being you!",
	"You wouldn't happen to be a carpenter, would you?",
	"Be the change that you want to see in the world!",
	"I like you just the way you are.",
	"Have you hugged your walrus today?",
	"You're my best friend!",
	"Nice outfit!",
	"It takes 3.4 walruses to change a lightbulb, on average.",
	"How are you doing today?",
	"You're the kindest person I know!",
	"Am I your favorite walrus?",
	"My favorite song is 'Another Brick in the Walrus, Part 2!'",
	"My second-favorite song is 'Wonderwalrus!'",
	"You can do whatever you set your mind to!",
	"What's up?",
	"I weigh 2500 pounds! You must be pretty strong!",
	"You're a great person!",
	"I tell all of my friends about how cool you are.",
	"All of Walrustopia will know of your good deeds!",
	"Back in Walrustopia, I was a humble mollusk merchant!",
	"You make me happy when skies are gray.",
	"I love you.",
	"My blubber keeps me both warm AND cuddly!",
	"Just look at how sweet these mystacial vibrissae are!",
	"My voice is meant only for you.",
	"You light up my life!",
	"You're a true hero, friend!",
	"Hanging out with you is the most fun thing I do!",
	"You can do it!",
	"You're the best around.",
	"Sea cucumbers are tastier than land cucumbers.",
	":3=",	-- the emoticon wiki says this is the walrus emoticon
	"I don't know what I'd do without you.",
	"I just met you, but I know we'll be lifelong friends!",
	"Let's hug! I like hugging.",
	"You know who's great? YOU ARE.",
	":)",
	":D",
	"B)",
	"Do you like clams? I LOVE clams.",
	"I once saw the Great Walrus of China! From space!",
	"You're so sweet!",
	"Watch out for polar bears.",
	"I really respect you.",
	"I'm honored to call you my friend.",
	
	
}
local FAREWELL_MESSAGES = {
	"Farewell, friend! I will never forget you.",
	"The time we shared together has been the happiest of my life.",
	"See you in another life!",
	"Bye!",
	"Nice meeting you!",
	"Have a good day!",
	"Goodbye!",
	"So long!",
	"Ta ta for now!",
	"TTFN!",
	"cya!",
	"Ciao!",
	"Auf wiedersehen!",
	"Tschuss!",
	"Have a nice life!",
	"Thanks for the talk!",
	"Alas, I must away.",
}

local SOUND_NAMES = {
	'WalrusSound1',
	'WalrusSound2',
	'WalrusSound3',
	'WalrusSound4',
	'WalrusSound5',
	'WalrusSound6',
}

local walrus = script.Parent
local smoke = walrus:WaitForChild('Smoke')
local character = walrus.Parent
local humanoid = character:FindFirstChild('Humanoid')
local player = game.Players:GetPlayerFromCharacter(character)
local Debris = game:GetService('Debris')
local ChatService = game:GetService('Chat')
local Sound

local function PlayRandomSound()
	Sound = walrus:FindFirstChild(SOUND_NAMES[math.random(#SOUND_NAMES)])
	if Sound then Sound:Play() end
end

if player then
	smoke.Enabled = true
	local smokeSound = walrus:FindFirstChild('SmokeSound')
	if smokeSound then smokeSound:Play() end
	Delay(SMOKE_TIME, function() smoke.Enabled = false end)
	wait(SMOKE_TIME)
	for i=1, NUM_STEPS do
		walrus.Transparency = (NUM_STEPS - i)/NUM_STEPS
		wait(STEP_TIME)
	end

	
	for i = 1, NUMBER_OF_MESSAGES - 1 do
		ChatService:Chat(walrus, MESSAGES[math.random(#MESSAGES)], Enum.ChatColor.Green)
		if humanoid then humanoid:TakeDamage(HEALING_DAMAGE) end
		PlayRandomSound()
		wait(MESSAGE_TIME)
	end

	ChatService:Chat(walrus, FAREWELL_MESSAGES[math.random(#FAREWELL_MESSAGES)], Enum.ChatColor.Green)
	if humanoid then humanoid:TakeDamage(HEALING_DAMAGE) end
	PlayRandomSound()
	wait(MESSAGE_TIME/2)
	
	for i = 1, NUM_STEPS do
		wait(STEP_TIME)
		walrus.Transparency = i / NUM_STEPS
	end
end

if Sound then Sound:Stop() end
walrus:Destroy()
