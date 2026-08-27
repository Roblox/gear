--Rescripted by Luckymaxer

Configuration = {
	GunDamage = 25, --Base output damage per shot.
	FireRate = 0.3, --How often the weapon can fire.
	Automatic = false, --hold down to continue firing
	Range = 250, --Max Distance that the weapon can fire.
	Spread = 1, --The bigger the spread, the more inaccurate the shots will be.
	ClipSize = 10, --Shots in a clip
	ReloadTime = 3.4, --Time it takes to reload the tool.
	StartingClips = 10, --If you want infinit clips, remove the IntValue named "Clips" from the tool.
	SegmentLength = 40, --How long the shot Segments are, or the speed of the shot.
	FadeDelayTime = (1 / 60),
	BarrelPosition = CFrame.new(0, 0, -1.2), --L, F, U
	Rate = (1 / 30),
	Colors = {
		BrickColor.new("Bright yellow"),
		BrickColor.new("Mid gray"),
		BrickColor.new("Medium stone grey"),
		BrickColor.new("Dark stone grey")
	},
	FlashColors = {"Medium red", "Dusty Rose", "Bright red", "Really red"},
}

return Configuration