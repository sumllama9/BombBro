
local H = {}


local speed = 3000
local jheight = 2000
local dblJpow = 2250
local maxspeed = 300

function H:move (k, obj, vel)

    if k == 'left' and vel > -maxspeed then
        obj:applyForce(-speed, 0)

    elseif k == 'right' and vel < maxspeed then
        obj:applyForce(speed, 0)

    end

    return moving
end

function H:jump (obj, numb)

    if numb == 0 then
        obj:applyLinearImpulse(0, -jheight)

    elseif numb == 1 then
        obj:applyLinearImpulse(0, -dblJpow)

    end

end


function H:drawPlr (sprite, curanim, x, y, size)
    curanim:draw(sprite, x, y, nil, size, size, 16, 16)
end









return H