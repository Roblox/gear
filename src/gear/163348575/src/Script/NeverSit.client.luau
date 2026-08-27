local humanoid = script.Parent.Humanoid

humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
humanoid.StateChanged:connect(function(from, to)
	if to == Enum.HumanoidStateType.Seated then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)