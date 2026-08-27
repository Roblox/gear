--Made by Luckymaxer

ContentProvider = game:GetService("ContentProvider")

Gui = script.Parent
Frame = Gui:WaitForChild("Frame")
Next = Frame:WaitForChild("Next")

Pages = {}

CurrentPage = 1

for i, v in pairs(Frame:GetChildren()) do
	if ((v:IsA("ImageButton") or v:IsA("ImageLabel")) and tonumber(v.Name)) then
		table.insert(Pages, v)
		ContentProvider:Preload(v.Image)
		v.Visible = false
	end
end

table.sort(Pages, (function(a, b)
	return tonumber(a.Name) < tonumber(b.Name)
end))

if Pages[1] then
	Pages[1].Visible = true
end

Next.MouseButton1Click:connect(function()
	if not Pages[1] then
		return
	end
	CurrentPage = (CurrentPage + 1)
	if not Pages[CurrentPage] then
		CurrentPage = 1
	end
	for ii, vv in pairs(Pages) do
		if ii == CurrentPage then
			vv.Visible = true
		else
			vv.Visible = false
		end
	end
end)