function MakeLightning(ray,atime)
	local startTime = tick()
	while tick()-startTime<atime do
		local points = {}		
		for i=0,10,1 do
			if i==0 then
				table.insert(points,ray.Origin)
			else
				table.insert(points,ray.Origin+(ray.Direction.Unit*(ray.Direction.magnitude/10)*i)+(Vector3.new(math.random(),math.random(),math.random())*2))
			end		
		end
		local parts = {}
		for index,i in pairs(points) do
			if index >1 then
				local npart = Instance.new('Part')
				npart.CanCollide = false
				npart.FormFactor='Custom'
				npart.Size= Vector3.new(.2,.2,(points[index]-points[index-1]).magnitude)
				npart.Archivable = false
				npart.Anchored = true
				npart.CFrame = CFrame.new((points[index]+points[index-1])/2,points[index])
				npart.Transparency=.5
				npart.BrickColor = BrickColor.new('Lime green')
				npart.Parent = game.Workspace
				
				npart.Touched:connect(function(npart)
					if npart.Parent:FindFirstChild('Humanoid') then
						npart.Parent.Humanoid:TakeDamage(1)
					end
				end)
				
				table.insert(parts,npart)
			end
		end
		wait(.5)
		for _,i in pairs(parts) do
			i.Parent =nil	
		end
		
	end
end

local cframeValue = script:WaitForChild('cframe')

local Handle = Instance.new("Part")
Handle.Anchored = true
Handle.TopSurface = Enum.SurfaceType.Smooth
Handle.Name = "Handle"
Handle.Size = Vector3.new(1, 1, 1.2)
Handle.BottomSurface = Enum.SurfaceType.Smooth
Handle.Locked = true
Handle.CanCollide = false
Handle.Archivable = false

	local Mesh = Instance.new("SpecialMesh")
	Mesh.Scale = Vector3.new(2, 2, 2)
	Mesh.MeshId = "http://www.roblox.com/asset/?id=82326541"
	Mesh.TextureId = "http://www.roblox.com/asset/?id=82327419"
	Mesh.Parent = Handle
	Mesh.MeshType = Enum.MeshType.FileMesh

	local Sound = Instance.new('Sound')
	Sound.Parent = Handle
	Sound.SoundId = "http://www.roblox.com/asset/?id=127410465"
	Sound.Looped = true

	local Light = Instance.new('PointLight')
	Light.Color = Color3.new(128/255,255/255,49/255)
	Light.Parent = Handle
	
Handle.Parent = game.Workspace
Handle.CFrame=cframeValue.Value
Sound:Play()

MakeLightning(Ray.new(cframeValue.Value.p,cframeValue.Value.lookVector*(15+(math.random()*10))) ,6+(math.random()*2))


Sound:Stop()
Handle.Parent=nil
cframeValue.Parent = nil