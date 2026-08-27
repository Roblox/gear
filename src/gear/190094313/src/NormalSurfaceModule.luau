--Normal Surface Retrieval by xXxMoNkEyMaNxXx

Terrain = game:GetService("Workspace").Terrain
GetCell = Terrain.GetCell
CellCenterToWorld = Terrain.CellCenterToWorld
WorldToCellPreferSolid = Terrain.WorldToCellPreferSolid

IdentityVector = Vector3.new()
IdentityCFrame = CFrame.new()

--Returns:
--Index of closest plane to p
--Distance to surface from p
function ClosestNormalVector(p, planes)
	local best_d = -math.huge
	local best_i
	for i = 1, #planes do
		local plane = planes[i]
		local d = IdentityVector.Dot(plane[1], (p - plane[2]))
		if d > best_d then
			best_i, best_d = i, d
		end
	end
	return best_i, best_d
end

--Part geometry data
UnitaryConvexPlaneMeshes = { --Each component of the normal vector dependent on every component of the size using matrices
	WedgePart = {{Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, 1), Vector3.new(0, 0, 0.5)}, {CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1, 0), Vector3.new(0, 0, 0)}, {Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(-1, 0, 0), Vector3.new(-0.5, 0, 0)}}, 
	CornerWedgePart = {{Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}, {CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0), Vector3.new(0, 0, 0)}, {CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0), Vector3.new(0, 0, 0)}}, 
	Part = {{Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(0, 1, 0), Vector3.new(0, 0.5, 0)}, {Vector3.new(0, 0, 1), Vector3.new(0, 0, 0.5)}, {Vector3.new(-1, 0, 0), Vector3.new(-0.5, 0, 0)}, {Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}}
}

--Terrain geometry data
TerrainCellSize = Vector3.new(4, 4, 4) --Arbitrary size input
TerrainCellOrientations = {
	[0] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), 
	CFrame.new(0, 0, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), 
	CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1), 
	CFrame.new(0, 0, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
}
TerrainCellBlockUnitaryConvexPlaneMeshes = {
	[0] = {{Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(0, 1, 0), Vector3.new(0, 0.5, 0)}, {Vector3.new(0, 0, 1), Vector3.new(0, 0, 0.5)}, {Vector3.new(-1, 0, 0), Vector3.new(-0.5, 0, 0)}, {Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}}, 
	{{Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(-1, 0, 0), Vector3.new(-0.5, 0, 0)}, {Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}, {CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0), Vector3.new(0, 0, 0)}}, 
	{{Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}, {CFrame.new(0, 0, 0, 0, -1, -1, 1, 0, 1, 1, 1, 0), Vector3.new(0.5, -0.5, -0.5)/3}}, 
	{{Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(0, 1, 0), Vector3.new(0, 0.5, 0)}, {Vector3.new(0, 0, 1), Vector3.new(0, 0, 0.5)}, {Vector3.new(-1, 0, 0), Vector3.new(-0.5, 0, 0)}, {Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}, {CFrame.new(0, 0, 0, 0, -1, -1, 1, 0, 1, 1, 1, 0), Vector3.new(-0.5, 0.5, 0.5)/3}}, 
	{{Vector3.new(1, 0, 0), Vector3.new(0.5, 0, 0)}, {Vector3.new(0, 1, 0), Vector3.new(0, 0.5, 0)}, {Vector3.new(0, -1, 0), Vector3.new(0, -0.5, 0)}, {Vector3.new(0, 0, -1), Vector3.new(0, 0, -0.5)}, {CFrame.new(0, 0, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0), Vector3.new(0, 0, 0)}}
}

function NormalVector(part, point)
	if part.ClassName == "Part" and (part.Shape == Enum.PartType.Ball or part.Shape == Enum.PartType.Cylinder) then
		return IdentityCFrame.vectorToWorldSpace(part.CFrame, IdentityCFrame.pointToObjectSpace(part.CFrame, point).unit)
	else
		local partCFrame, partSize = part.CFrame, part.Size
		local UCPM
		if part.ClassName == "Terrain" then
			local CellGridLocation = WorldToCellPreferSolid(part, Vector3.new(point.x, (point.y - 1e-5), point.z))--Ugly floating point fix
			local CellMaterial, CellBlock, CellOrientation = GetCell(part, CellGridLocation.x, CellGridLocation.y, CellGridLocation.z)
			partCFrame = (TerrainCellOrientations[CellOrientation.Value] + CellCenterToWorld(part, CellGridLocation.x, CellGridLocation.y, CellGridLocation.z))
			partSize = TerrainCellSize
			UCPM = TerrainCellBlockUnitaryConvexPlaneMeshes[CellBlock.Value]
		else
			UCPM = UnitaryConvexPlaneMeshes[part.ClassName] or UnitaryConvexPlaneMeshes.Part --Trusses, SpawnLocations, etc.
		end
		local CPM = {}
		for i = 1, #UCPM do
			local plane = UCPM[i]
			CPM[i] = {(plane[1] * partSize).unit, plane[2] * partSize}
		end
		local PlaneIndex, DistanceToSurface = ClosestNormalVector(IdentityCFrame.pointToObjectSpace(partCFrame, point), CPM)
		if PlaneIndex then
			return IdentityCFrame.vectorToWorldSpace(partCFrame, CPM[PlaneIndex][1])
		else
			return IdentityVector --Dead code unless the tables are tampered with
		end
	end
end

return NormalVector