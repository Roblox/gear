function Leap()

	script.Parent.Parent.Humanoid.Jump = false

end

script.Parent.Parent.Humanoid.Jumping:connect(Leap)