--Stickmasterluke was here last


--Making boards and uploading models is frustrating


local skateboardId=140984100

local Tool=script.Parent;


function insert()
	--This call will cause a "wait" until the data comes back
	local root=game:GetService("InsertService"):LoadAsset(skateboardId)
	local instances=root:GetChildren()
	if #instances==0 then
		root:Remove()
		return
	end
	--Continue the insert process
	root.Name="Snowboard"
	--game:GetService("InsertService"):Insert(root)
	root.Parent=Workspace
	local t=game.Players.LocalPlayer.Character:FindFirstChild("Torso")
	root:MoveTo(t.Position+t.CFrame.lookVector*8)
	Tool.Handle.Drop:Play()
end

enabled=true
function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled=false
	insert()
	wait(.01)
	Tool:Remove()
end

function onEquippedLocal(mouse)
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon="http://www.roblox.com/asset/?id=22858207"
	mouse.Button1Down:connect(function()
		onButton1Down(mouse)
	end)
end

Tool.Equipped:connect(onEquippedLocal)



