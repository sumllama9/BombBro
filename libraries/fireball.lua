F = {}


local timers = {}

local hitboxOn = false

local destroyers = {}

function F.fbd (map)

    for i, v in pairs(map.layers["firbDelete"].objects) do 


        local props = {
            x = v.x * 5,
            y = v.y * 5,
            width = v.width * 5,
            height = v.height * 5

        }

        table.insert(destroyers, props)

    end
end


function F.spawnersDRAW (tbl)

    if not tbl then
        print('no table found')
    end

    for i, v in pairs(tbl) do
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle('fill', v.x - 15, v.y - 16.5, v.width * 4, v.height * 2.3)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('line', v.x - 15, v.y - 16.5, v.width * 4, v.height * 2.3)

        


    end

    --[[for i, v in pairs(destroyers) do -- comment this out if not using hitbox

        love.graphics.setColor(1,0.5,0)
        love.graphics.rectangle('line', v.x, v.y, v.width, v.height) --hitbox
        love.graphics.setColor(1,1,1,1)
    end]]

end

function F.spawnersLOAD (tbl)

    for i, v in pairs(tbl) do
        
        local t = Chrono()
        
        table.insert(timers, {
            timer = t, 
            bool = false, 
            num = love.math.random(5, 10), 
            x = v.x,
            y = v.y,
            width = v.width,
            height = v.height,
            tstarted = false,
            props = {x = v.x - 12, y = v.y - 15},
            tweenstart = false
        })

        

    end
end


function F.update (dt)
    
    for i, v in pairs(timers) do

        if v.tstarted == false then
            v.tstarted = true

            v.timer:after(v.num, function()
                v.bool = true
            end)

        end
        v.timer:update(dt)

    end
end

function F.fireUpd (cx, cy, IFtmr)

    for i, v in pairs(timers) do

            if v.bool == true and v.tstarted == true and v.tweenstart == false then
            v.tweenstart = true
            tween = v.timer:tween(
            1, 
            v.props,
            {y = v.props.y + 350},
            'linear', 
            function() 
                v.bool = false
                v.tstarted = false 

                v.props.x = v.x
                v.props.y = v.y
                v.tweenstart = false
            end)

        end

        for a, des in pairs(destroyers) do

            if collision.AABB(v.props.x + 17.5, v.props.y + 17.5, v.width, v.height, cx, cy, 35, 100) then

                v.bool = false
                v.tstarted = false

                if plr.Iframes == false then
                    Health = Health - 1
                    plr.Iframes = true
                    IFtmr:after(5, function() plr.Iframes = false end)
                end

            elseif collision.AABB(v.props.x + 17.5, v.props.y + 17.5, v.width, v.height, des.x, des.y, des.width, des.height) then
                
                v.bool = false
                v.tstarted = false
        
            end

        end
    end
end



function F.drawB ()
    love.graphics.setColor(1,1,1,1)
    for i, v in pairs(timers) do

        if v.bool == true then

            anim.fireball:draw(fireBallimg, v.props.x - 12, v.props.y - 17, 0, 2, 2)
            
            if hitboxOn == true then
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle('line', v.props.x, v.props.y, 35, 35)
                love.graphics.setColor(1,1,1,1)
            end
            
        end
    end

end

function F.test ()
    local num = 3
    local num2 = 3
    for i, v in pairs(timers) do

        local prin = nil

        if v.bool == true then
            prin = "true"
        elseif v.bool == false then
            prin = "false"
        end
        love.graphics.print(prin, num)
        love.graphics.print(v.x, num, 10)
        love.graphics.print(v.props.y, num, 20)

        --[[for a, b in pairs(destroyers) do 

            love.graphics.print(b.y, num2, 0)

            num2 = num2 + 50
        end]]

        num = num + 50
   



    end

    hitboxOn = true

end


return F