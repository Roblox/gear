--Made by Luckymaxer

Gui = script.Parent
Frame = Gui:WaitForChild("Frame")

Debris = game:GetService("Debris")

Image = Frame:WaitForChild("Image")
Button = Image:WaitForChild("Button")
Clicked = Button:WaitForChild("Clicked")

MouseHovering = false
MouseDown = false
Closed = false

Clicked.Visible = false

Button.MouseEnter:connect(function()
	if Closed then
		return
	end
	MouseHovering = true
end)

Button.MouseLeave:connect(function()
	if Closed then
		return
	end
	MouseHovering = false
	MouseDown = false
	Clicked.Visible = false
end)

Button.MouseButton1Down:connect(function()
	if not MouseHovering or MouseDown or Closed then
		return
	end
	MouseDown = true
	Clicked.Visible = true
end)

Button.MouseButton1Up:connect(function()
	if Closed then
		return
	end
	Clicked.Visible = false
	if MouseHovering and MouseDown then
		Closed = true
		wait(0.1)
		Gui:Destroy()
	end
	MouseDown = false
end)