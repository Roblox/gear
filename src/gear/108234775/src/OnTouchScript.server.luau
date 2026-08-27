local arrow = script.Parent
		

local damage = 33

local activated = false

function onTouch(hit)
	if hit.Parent and hit.Name ~= 'arrow' then
		vChar = hit.Parent
		humanoid = vChar:FindFirstChild("Humanoid")
		if humanoid ~= nil then 
			tag = arrow:FindFirstChild("creator")
			if tag then tag.Parent = humanoid end
			if hit.Name == "Head" then damage = 45 end
			if activated then return end
			humanoid:TakeDamage(damage)
			print('Damaged guy')
			activated = true
		end
		arrow:Destroy()
	end
end

arrow.Touched:connect(onTouch)

wait(0.25)

local arrowSound = arrow:FindFirstChild('ArrowSound')
if arrowSound then
	arrowSound:Play()
else
	print('No Arrow Sound')
end