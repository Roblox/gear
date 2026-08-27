--Made by Luckymaxer

wait()

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players.LocalPlayer
PlayerGui = Player:FindFirstChild("PlayerGui")

UnluckyText = script:WaitForChild("UnluckyText")

function TweenNumber(Current, Goal, Time)
	return ((Goal - Current) / Time)
end

function TweenNumber9(Object, Property, Goal, Time)
	Time = (Time * 30)
	local Increment = ((Goal - Object[Property]) / Time)
	for i = 1, Time do
		Object[Property] = (Object[Property] + Increment)
		wait()
	end
	return true
end

if PlayerGui and UnluckyText then
	local Messages = {
		"You are unlucky!",
		"Bad luck is upon you...",
		"Oh no! You have bad luck!",
		"Not so lucky anymore...",
		"Just your luck!",
		"You have run out of luck!",
		"Looks like your luck has run out!",
	}
	local Message = Messages[math.random(1, #Messages)]
	local Colors = {
		{Front = Vector3.new(170, 0, 255), Back = Vector3.new(170, 170, 255)},
		{Front = Vector3.new(0, 255, 0), Back = Vector3.new(0, 170, 0)},	
		{Front = Vector3.new(255, 170, 0), Back = Vector3.new(255, 85, 0)},	
	}
	for i, v in pairs(Colors) do
		for ii, vv in pairs(v) do
			local Color = (vv / 255)
			Colors[i][ii] = Color3.new(Color.X, Color.Y, Color.Z)
		end
	end
	local Color = Colors[math.random(1, #Colors)]
	local UnluckyTextCopy = UnluckyText:Clone()
	local Text = UnluckyTextCopy.Text
	Text.Text = Message
	Text.Background.Text = Message
	Text.TextColor3 = Color.Front
	Text.TextStrokeColor3 = Color.Back
	Text.Background.TextColor3 = Text.TextStrokeColor3
	Text.Background.TextStrokeColor3 = Text.Background.TextColor3
	Text.Visible = true
	Text.Position = UDim2.new(0.25, 0, -Text.Size.Y.Scale, -36, 0)
	for ii, vv in pairs({Text, Text.Background}) do
		vv.TextTransparency = 1
		vv.TextStrokeTransparency = 1
	end
	Debris:AddItem(UnluckyTextCopy, 10)
	UnluckyTextCopy.Parent = PlayerGui 
	Spawn(function()
		local Time = 3.5
		Time = (Time * 30)
		local TextIncrement = TweenNumber(Text.TextTransparency, 0, Time)
		local TextStrokeIncrement = TweenNumber(Text.TextStrokeTransparency, 0.3, Time)
		for i = 1, Time do
			for ii, vv in pairs({Text, Text.Background}) do
				vv.TextTransparency = (vv.TextTransparency + TextIncrement)
				vv.TextStrokeTransparency = (vv.TextStrokeTransparency + TextStrokeIncrement)
			end
			wait()
		end
	end)
	Text:TweenPosition(
		UDim2.new(Text.Position.X.Scale, Text.Position.X.Offset, 0.15, 0),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		1,
		true,
		(function()
		end)
	)
	wait(5)
	Spawn(function()
		local Time = 1.5
		Time = (Time * 30)
		local TextIncrement = TweenNumber(Text.TextTransparency, 1, Time)
		local TextStrokeIncrement = TweenNumber(Text.TextStrokeTransparency, 1, Time)
		for i = 1, Time do
			for ii, vv in pairs({Text, Text.Background}) do
				vv.TextTransparency = (vv.TextTransparency + TextIncrement)
				vv.TextStrokeTransparency = (vv.TextStrokeTransparency + TextStrokeIncrement)
			end
			wait()
		end
	end)
end