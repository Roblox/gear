shaft = script.Parent




note = script.Parent.chord
note:play()

wait(5)

-- at max range
--script.Parent.Explosion.PlayOnRemove = false
note:stop()
shaft:remove()