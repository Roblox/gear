local Tool = script.Parent;

enabled = true


local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,.5,0), Color3.new(0,.5,1)}

function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local spark = Tool.Handle:FindFirstChild("Sparkle")
	if (spark == nil) then
		local spark = Instance.new("Sparkles")

		spark.Color = colors[math.random(1,#colors)]
		spark.Name = "Sparkle"
		spark.Parent = Tool.Handle
		Tool.Handle.DrinkSound.Looped = true
		Tool.Handle.DrinkSound:Play()
		
	else
		spark:Remove()
		Tool.Handle.DrinkSound.Looped = false
		Tool.Handle.DrinkSound:Stop()
	end



	wait(1)
	






	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


