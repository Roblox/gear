--Made by Stickmasterluke


sp=script.Parent


followdistance=1.618


function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end


followtag=waitfor(sp,"FollowTag")
bg=waitfor(sp,"BodyGyro")
bp=waitfor(sp,"BodyPosition")


while true do
	wait(.1+(math.random()*.1))
	if followtag and followtag.Value~=nil and followtag.Value:IsDescendantOf(game.Workspace) then
		if (sp.Position-followtag.Value.Position).magnitude>followdistance+.1 then
			local vec=(followtag.Value.Position-sp.Position).unit
			local vec2d=(vec*Vector3.new(1,0,1)).unit
			bp.position=followtag.Value.Position-(vec2d*followdistance)
			if followtag.Value.Name=="Torso" or followtag.Value.Name=="UpperTorso" then
				bg.cframe=CFrame.new(Vector3.new(0,0,0),(followtag.Value.Position+Vector3.new(0,-2.5,0))-sp.Position)
			else
				bg.cframe=CFrame.new(Vector3.new(0,0,0),vec)
			end
		end
	else
		break
	end
end


sp:remove()
