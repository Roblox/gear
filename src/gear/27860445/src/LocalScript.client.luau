enabled = true

function onActivatedLocal()	

	if not enabled  then
		return
	end

	enabled = false

	local humanoid = script.Parent.Parent:FindFirstChild("Humanoid", false)

	local anim = humanoid:LoadAnimation(script.Parent.staffup)
	anim:Play(0.1,1,1)
	spark = Instance.new("Sparkles")
	spark.Parent = script.Parent.Parent:FindFirstChild("Torso",false)

	wait(1.5)

	anim:Stop()
	anim:remove()
	anim = humanoid:LoadAnimation(script.Parent.staffout)
	anim.KeyframeReached:connect(function(string)

		if string == "end" then

			wait(0.4)
			anim:Stop()
			anim:remove()

		end

	end)

	spark:remove()

	wait(4)

	enabled = true

end

script.Parent.Activated:connect(onActivatedLocal)
