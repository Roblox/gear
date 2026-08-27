--refocus the camera on the player if the tool is dropped (the localscript in the tool stoips working in the case, so this script must be in the character or backpack)

--avoid error, script runs before script.Tool and script.Target are added as children
wait()
script.Tool.Value.Changed:connect(function(pr)
	--print("Tool \"", script.Tool.Value, "\"s parent changed to ", script.Tool.Value.Parent)
	if pr == "Parent" then
		if script.Tool.Value.Parent == game.Workspace then
			game.Workspace.CurrentCamera.CameraType = 5	
			game.Workspace.CurrentCamera.CameraSubject = script.Target.Value
		end
	end
end)

script.Tool.Value.Unequipped:connect(function()
	wait(0.5)
	script:remove()
end)

print("PaperPlaneGear :: CamFocusFailsafe loaded")
