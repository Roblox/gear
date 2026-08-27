local Damage  = 5

local HatAwarded = false

function onTouched(hit)
	if (hit.Parent:findFirstChild("Humanoid") ~= nil and not HatAwarded) and game.Players:GetPlayerFromCharacter(hit.Parent)~=script:WaitForChild('creator').Value then
		HatAwarded = true
		for _,i in pairs(hit.Parent:GetChildren()) do
			if i:IsA('Hat') then
				i:Destroy()
			end
		end
		
		local h = Instance.new("Hat")
		local p = script.Parent
		h.Name = "Hat"   
		p.Parent = h
		p.Name = "Handle" 
		p.formFactor = 0
		p.Size = Vector3.new(-0,-0,-1) 
		p.BottomSurface = 0 
		p.TopSurface = 0 
		p.Locked = true 
		script.Parent.Mesh:clone().Parent = p
		h.Parent = hit.Parent
		h.AttachmentPos = Vector3.new(0,-0.6,0) 
		
		
		
		while h.Parent:FindFirstChild('Humanoid') do
			h.Parent.Humanoid:TakeDamage(Damage)
			wait(.5)
		end
		h:Destroy()
	end
end

script.Parent.Touched:connect(onTouched)
