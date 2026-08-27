local Tool = script.Parent

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = nil
local tryingToReset = false

local wordCount = 1
local unequipper = true

function textChanged(enterPressed, changer)
	
	if enterPressed and tryingToReset == false then
		if wordCount == 1 then

			local adjective = gui.Entry:FindFirstChild("AdjectiveBox").Text
			gui.Card.MomIs.Text = "My Dad is " .. adjective .. ". "

			gui.Entry:FindFirstChild("AdjectiveBox").Active = false
			gui.Entry:FindFirstChild("AdjectiveBox").Visible = false

			gui.Entry:FindFirstChild("VerbBox").Active = true
			gui.Entry:FindFirstChild("VerbBox").Visible = true
			gui.Entry.VerbBox:CaptureFocus()

			gui.Entry.EnterWord.Text = "Verb"

		elseif wordCount == 2 then

			local verb = gui.Entry:FindFirstChild("VerbBox").Text
			gui.Card.MomIs.Text = gui.Card.MomIs.Text .. "He likes to " .. verb .. ". "

			gui.Entry:FindFirstChild("VerbBox").Active = false
			gui.Entry:FindFirstChild("VerbBox").Visible = false

			gui.Entry:FindFirstChild("NounBox").Active = true
			gui.Entry:FindFirstChild("NounBox").Visible = true
			gui.Entry.NounBox:CaptureFocus()

			gui.Entry.EnterWord.Text = "Noun"

		elseif wordCount == 3 then

			local noun = gui.Entry.NounBox.Text
			gui.Card.MomIs.Text = gui.Card.MomIs.Text .. " My favorite thing about my dad is his " .. noun .. ". "

			gui.Entry:FindFirstChild("NounBox").Active = false
			gui.Entry:FindFirstChild("NounBox").Visible = false

			gui.Entry:FindFirstChild("ReasonBox").Active = true
			gui.Entry:FindFirstChild("ReasonBox").Visible = true
			gui.Entry.ReasonBox:CaptureFocus()

			gui.Entry.EnterWord.Text = "Reason"

		elseif wordCount == 4 then

			local reason = gui.Entry.ReasonBox.Text
			reason = string.gsub(reason, "because", "")
			reason = string.gsub(reason, "Because", "")
			gui.Card.MomIs.Text = gui.Card.MomIs.Text .. " I love my dad because " .. reason .. ". "

			gui.Entry.ReasonBox.Active = false
			gui.Entry.ReasonBox.Visible = false

			gui.Entry.NameBox.Active = true
			gui.Entry.NameBox.Visible = true
			gui.Entry.NameBox:CaptureFocus()	

			gui.Entry.EnterWord.Text = "Name"
			
			
		elseif wordCount == 5 then

			local namer = gui.Entry.NameBox.Text
			gui.Card:FindFirstChild("Name").Text = namer

			gui.Entry.Visible = false
			gui.Card.Visible = true
			wait(9)
			fader()
			wordCount = 0
		end

		wordCount = wordCount + 1
	end

end

Tool.ScreenGui.Entry.AdjectiveBox.FocusLost:connect(textChanged)
Tool.ScreenGui.Entry.NameBox.FocusLost:connect(textChanged)
Tool.ScreenGui.Entry.VerbBox.FocusLost:connect(textChanged)
Tool.ScreenGui.Entry.NounBox.FocusLost:connect(textChanged)
Tool.ScreenGui.Entry.ReasonBox.FocusLost:connect(textChanged)

function onEquipped()
	gui = Tool.ScreenGui:clone()

	gui.Entry.AdjectiveBox.FocusLost:connect(textChanged)
	gui.Entry.NameBox.FocusLost:connect(textChanged)
	gui.Entry.VerbBox.FocusLost:connect(textChanged)
	gui.Entry.NounBox.FocusLost:connect(textChanged)
	gui.Entry.ReasonBox.FocusLost:connect(textChanged)
	
	gui.Entry.AdjectiveBox:CaptureFocus()

	gui.Parent = playerGui

end

function onUnequipped()

	if unequipper then
		unequipper = false

		wordCount = 1
		gui.Parent = nil

		unequipper = true
	end

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

function fader()

	tryingToReset = true
	local fading = true
	while fading do
		
		if gui.Card.BackgroundTransparency < 1 then
			gui.Card.BackgroundTransparency = gui.Card.BackgroundTransparency + 0.025
		end
		if gui.Card.MomIs.TextTransparency < 1 then
			gui.Card.MomIs.TextTransparency = gui.Card.MomIs.TextTransparency + 0.025
		end
		if gui.Card.Love.TextTransparency < 1 then
			gui.Card.Love.TextTransparency = gui.Card.Love.TextTransparency + 0.025
		end
		if gui.Card:FindFirstChild("Name").TextTransparency < 1 then
			gui.Card:FindFirstChild("Name").TextTransparency = gui.Card:FindFirstChild("Name").TextTransparency + 0.025
		else
			fading = false
		end
		
		wait(0.025)
	end
	gui.Card.ImageLabel.Visible = false

	wait(2)

	resetGUI()

	tryingToReset = false

end

function resetGUI()

	gui.Card.MomIs.Text = ""

	gui.Card.Visible = false
	gui.Card.BackgroundTransparency = 0.2
	gui.Card.ImageLabel.Visible = true
	gui.Card.Love.TextTransparency = 0
	gui.Card.MomIs.TextTransparency = 0
	gui.Card:FindFirstChild("Name").TextTransparency = 0

	gui.Entry.Visible = true
	gui.Entry.EnterWord.Text = "Adjective"

	gui.Entry.AdjectiveBox.Text = "Please type an adjective here and press enter"
	gui.Entry.AdjectiveBox.Visible = true
	gui.Entry.AdjectiveBox.Active = true

	gui.Entry.NameBox.Text = "Please type your name here and press enter"
	gui.Entry.NameBox.Visible = false
	gui.Entry.NameBox.Active = false

	gui.Entry.ReasonBox.Text = "Please type a reason here and press enter"
	gui.Entry.ReasonBox.Visible = false
	gui.Entry.ReasonBox.Active = false

	gui.Entry.NounBox.Text = "Please type a noun here and press enter"
	gui.Entry.NounBox.Visible = false
	gui.Entry.NounBox.Active = false

	gui.Entry.VerbBox.Text = "Please type a verb here and press enter"
	gui.Entry.VerbBox.Visible = false
	gui.Entry.VerbBox.Active = false

end
