local RbxUtility = LoadLibrary('RbxUtility')
local Create = RbxUtility.Create

script.Parent.DropBomb.OnServerEvent:connect(function(client)
	if client.Character == script.Parent.Parent then
		local bomb = Create'Part'{
			Size = Vector3.new(1,2,1);
			TopSurface = 'Smooth';
			BottomSurface = 'Smooth';
			Archivable = false;
			Position = (client.Character['Left Arm'].CFrame*CFrame.new(0,-1,0)).p - Vector3.new(0,2,0);
			--
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=90793198';
				TextureId = 'http://www.roblox.com/asset/?id=90793278';
			};
			--
			Create'Sound'{
				Name = 'ExplodeSound';
				SoundId = 'rbxasset://sounds//Rocket shot.wav';
			};
		}
		--
		local sc = script.Parent.MineScript:Clone()
		sc.Disabled = false
		sc.creator.Value = client
		sc.Parent = bomb
		--
		bomb.Parent = game.Workspace
	end
end)