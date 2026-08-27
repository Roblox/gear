local destroyObject = function(object)
	if object and object.Value then
		object.Value:Destroy()
		object:Destroy()
	end
end

script.ChildAdded:connect(function(child)
	if child:IsA("ObjectValue") and child.Name == "ObjectToDestroy" then
		destroyObject(child)
	end
end)