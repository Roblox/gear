if script.Parent.Parent.Name == "PlayerGui" then

	script.Parent.TextBox.Visible = false

	local f1 = "Always ask yourself, would a noob do this?"
	local f2 = "Yes"
	local f3 = "No"
	local f4 = "Looks like it!"
	local f5 = "Maybe"
	local f6 = "Signs point to yes"
	local f7 = "As I see it, yes"
	local f8 = "It is certain"
	local f9 = "It is decidedly so"
	local f10 = "Reply hazy, try again"
	local f11 = "Better not tell you..."
	local f12 = "Very doubtful"
	local f13 = "Don't count on it"
	local f14 = "Sources say no..."
	local f15 = "The future is uncertain right now"
	local f16 = "I have no idea"
	local f17 = "j00R PhU7UR3 15 L337"
	local f18 = "I'm pretty tired"
	local f19 = "Blame John"
	local f20 = "ZOMG HAX!"
	local f21 =  "it's OVAR 9000!!!111"

	local sayings = {f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20,f21}

	script.Parent.TextBox.Text = sayings[math.random(1,#sayings)]

	script.Parent.TextBox.Visible = true

	wait(3)

	script.Parent:remove()

end
