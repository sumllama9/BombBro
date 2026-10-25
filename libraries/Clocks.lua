local C = {}

local clocks = {}

local sfx = love.audio.newSource("sounds/clock.mp3", "static")
sfx:setVolume(0.3)

local hitboxesOn = false

function C.props (map)

    for i, v in pairs(map.layers["Clocks"].objects) do 

        local clock = {
            x = v.x * 5, 
            y = v.y * 5,
            width = 50,
            height = 50,
            bool = false
        }

        table.insert(clocks, clock)
    end
end

function C.draw ()
    for i, v in pairs(clocks) do 

        if hitboxesOn == true then
            love.graphics.setColor(0,0.7,0.3)
            love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
            love.graphics.setColor(1,1,1,1)
        end
        
        love.graphics.setColor(1,1,1,1)
        if v.bool == false then
            anim.clock:draw(clock.img, v.x, v.y, nil, 1.7)
        end

    end
end


function C.upd (cx, cy, time)
    for i, v in pairs(clocks) do 

        if collision.AABB(v.x + 25, v.y + 25, v.width, v.height, cx, cy, 35, 100) and v.bool == false then
            v.bool = true
            sfx:play()

            timer = time + 15

        end


    end
end





return C