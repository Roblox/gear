wait(2.5)

function onTouched(hit)
	local human = hit.Parent:findFirstChild("Humanoid")
	if (human ~= nil) and (human.Parent.Name ~= script.Parent.Owner.Value) then
		print(hit.Parent.Name)
		human:TakeDamage(100)
	end
end

script.Parent.Touched:connect(onTouched)