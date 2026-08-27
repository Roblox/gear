function FindAttachedHumanoid(part)
	local tpart = part
	while tpart.Parent do
		if tpart.Parent:FindFirstChild('Humanoid') then return tpart.Parent.Humanoid end
		tpart = tpart.Parent
	end
	return nil
end

script.ChildAdded:connect(function(nchild)
	local humanoid = FindAttachedHumanoid(script)
	local ani = Instance.new('Animation')
	ani.AnimationId= nchild.Value
	local aniTrack=humanoid:LoadAnimation(ani)
	aniTrack:Play()
end)