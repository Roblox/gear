local Tool = script.Parent
local debris = game:GetService("Debris")

function onActivated()

	if not Tool.Enabled then
		return
	end
	
	Tool.Enabled = false

	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(26596372)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	Tool.Handle.Shoot:Play()

	--Continue the insert process
	Post = root:FindFirstChild("Post")
	Post.Position = Tool.Handle.Position
	Post.CanCollide = true

	welder = Instance.new("Weld")
	welder.Part0 = Post
	welder.Part1 = Tool.Handle
	welder.C0 = CFrame.new(0,0,2.3)
	welder.Parent = Post
	

	Post.Parent = Tool

	root:remove()
	
	wait(3)

	Tool.Handle.Fail:Play()

	welder.Parent = nil
	Post.Parent = game.Workspace
	debris:AddItem(Post, 25)

	Tool.Enabled = true

end

function onEquipped()

	Tool.Handle.Shoot:Stop()
	Tool.Handle.Fail:Stop()

end

function onUnequipped()

	Tool.Handle.Fail:Stop()

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)

