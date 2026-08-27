--Rescripted by StarWars

local Tool = script.Parent
local ScreenGui = Tool.ScreenGui
local Player = nil
local Gui = nil
local TryingToReset = false

local WordCount = 1

local AdjectiveText = "Please type an adjective here and press enter" 
local NameText = "Please type your name here and press enter"
local ReasonText = "Please type a reason here and press enter"
local NounText = "Please type a noun here and press enter"
local VerbText = "Please type a verb here and press enter"

ScreenGui.Entry.EnterBox.Text = AdjectiveText

local function ResetGui()
	Gui.Card.MomIs.Text = ""
	Gui.Card.Visible = false
	Gui.Card.BackgroundTransparency = 0.2
	Gui.Card.ImageLabel.Visible = true
	Gui.Card.Love.TextTransparency = 0
	Gui.Card.MomIs.TextTransparency = 0
	Gui.Card:FindFirstChild("Name").TextTransparency = 0

	Gui.Entry.Visible = true
	Gui.Entry.EnterWord.Text = "Adjective"	
	Gui.Entry.EnterBox.Text = AdjectiveText
end

local function Fader()
	TryingToReset = true
	local Fading = true
	while Fading do
		
		if Gui.Card.BackgroundTransparency < 1 then
			Gui.Card.BackgroundTransparency = Gui.Card.BackgroundTransparency + 0.025
		end
		if Gui.Card.MomIs.TextTransparency < 1 then
			Gui.Card.MomIs.TextTransparency = Gui.Card.MomIs.TextTransparency + 0.025
		end
		if Gui.Card.Love.TextTransparency < 1 then
			Gui.Card.Love.TextTransparency = Gui.Card.Love.TextTransparency + 0.025
		end
		if Gui.Card:FindFirstChild("Name").TextTransparency < 1 then
			Gui.Card:FindFirstChild("Name").TextTransparency = Gui.Card:FindFirstChild("Name").TextTransparency + 0.025
		else
			Fading = false
		end
		
		wait(0.025)
	end
	Gui.Card.ImageLabel.Visible = false
	
	wait(2)
	
	ResetGui()
	
	TryingToReset = false
end

local function OnFocusLost(enterPressed, inputCaused)
	if enterPressed and not TryingToReset then
		if WordCount == 1 then
			local Adjective = Gui.Entry:FindFirstChild("EnterBox").Text
			Gui.Card.MomIs.Text = "My Mom is " .. Adjective .. "."
			Gui.Entry.EnterBox.Text = VerbText			
			
			Gui.Entry.EnterWord.Text = "Verb"
		elseif WordCount == 2 then
			local Verb = Gui.Entry:FindFirstChild("EnterBox").Text
			Gui.Card.MomIs.Text = Gui.Card.MomIs.Text .. " She likes to " .. Verb .. "."
			Gui.Entry.EnterBox.Text = NounText			
			
			Gui.Entry.EnterWord.Text = "Noun"
		elseif WordCount == 3 then
			local Noun = Gui.Entry:FindFirstChild("EnterBox").Text
			Gui.Card.MomIs.Text = Gui.Card.MomIs.Text .. " My favorite thing about my mom is her " .. Noun .. "."
			Gui.Entry.EnterBox.Text = ReasonText			
			
			Gui.Entry.EnterWord.Text = "Reason"
		elseif WordCount == 4 then
			local Reason = Gui.Entry:FindFirstChild("EnterBox").Text
			Reason = string.gsub(Reason, "because", "")
			Reason = string.gsub(Reason, "Because", "")
			Gui.Card.MomIs.Text = Gui.Card.MomIs.Text .. " I love her because " .. Reason .. "."
			Gui.Entry.EnterBox.Text = NameText			
			
			Gui.Entry.EnterWord.Text = "Name"
		elseif WordCount == 5 then
			local Namer = Gui.Entry:FindFirstChild("EnterBox").Text
			Gui.Card:FindFirstChild("Name").Text = Namer

			Gui.Entry.Visible = false
			Gui.Card.Visible = true			
			wait(9)
			Fader()
			WordCount = 0
		end		
		
		WordCount = WordCount + 1
	end
end

local function OnEquipped()
	Player = game.Players:GetPlayerFromCharacter(Tool.Parent)	
	Gui = ScreenGui:Clone()
	Gui.Entry.EnterBox.FocusLost:connect(OnFocusLost)	
	Gui.Entry.EnterBox.Visible = true	
	
	Gui.Parent = Player:WaitForChild("PlayerGui")
end

local function OnUnequipped()
	WordCount = 1
	Gui:Destroy()
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)