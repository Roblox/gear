humanoid = script.Parent

if humanoid then
	for i = 1, 15 do
		if humanoid.Health > 0 then 			
			humanoid:TakeDamage(6)
		end	
		wait(1.0)
	end
end


wait(2.0)
script:Remove()