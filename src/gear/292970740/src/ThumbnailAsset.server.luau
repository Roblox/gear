local tool = script.Parent
local assets = tool:WaitForChild'Handle':WaitForChild'ThumbnailAssets'

assets:Destroy()

tool.Handle.Transparency = 0