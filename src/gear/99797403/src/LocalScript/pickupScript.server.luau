function waitforchild(parent,child)
	while not parent:FindFirstChild(child) do wait() print(parent.Name .. " Waiting for " .. child) end
	return parent[child]
end


local Handle=script.Parent


function OnTouched(Part)
	HitHumanoid = Part.Parent:FindFirstChild("Humanoid")
	myHumanoid = Handle.Parent.Parent:FindFirstChild("Humanoid")
	myPlayer = game.Players:GetPlayerFromCharacter(Handle.Parent.Parent)

	if HitHumanoid and myHumanoid and myHumanoid ~= HitHumanoid then
		waitforchild(Handle,'pickupSound'):Play()
		Handle.Transparency = 1
		wait(1)
		Handle:Destroy()
	end
end


script.Parent.Touched:connect(OnTouched)
