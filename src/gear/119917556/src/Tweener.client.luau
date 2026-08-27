local Frame = script.Parent

game.Debris:AddItem(Frame.Parent, 2)

Frame:TweenPosition(UDim2.new(0.2, 0, 0.8, -128), 'Out', 'Quad', 0.5, true, function()
	wait(1)
	Frame:TweenPosition(UDim2.new(0, -150, 1, 20), 'Out', 'Quad', 0.5, true)
end)
