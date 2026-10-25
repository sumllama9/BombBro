--quick note to anyone reading this
--the code here is a mess so I wouldn't recommend reading it

function love.load ()

    started = false
    paused = false
    graphics = love.graphics
    dead = false
    won = false

    love.graphics.setDefaultFilter("nearest", "nearest") -- prevents blur on images
    sti = require 'libraries/sti' -- for tiled
    wf = require 'libraries/windfield' -- for physics
    anim8 = require 'libraries/anim8' -- for spritesheet
    collision = require 'libraries/CollisionDetection' -- for collisions
    shaders = require("libraries/shaders")
    cameraScript = require("libraries/camera")

    Chrono = require("libraries/Timer")

    numbers = {}
    anim = {}

    numbers.width = love.graphics:getWidth()
    numbers.height = love.graphics:getHeight()

    --Physics

    phys = {}

    phys.gravity = 300

    world = wf.newWorld(0, phys.gravity)


    --camera

    cam = cameraScript()


    --plr

    plrscript = require 'libraries/Plr'

    plr = {}
    plr.x = 300 --100
    plr.y = 0--1750

    plr.scale = 3

    exploaded = false

    heart = {}
    Health = 3

    plr.Iframes = false

    heart.animspeed = 0.15
    heart.size = 2.75

    heart.img = love.graphics.newImage('sprites/heart.png')
    heart.grid = anim8.newGrid(32, 32, heart.img:getWidth(), heart.img:getHeight())
    anim.heart = anim8.newAnimation(heart.grid('1-31', 1), heart.animspeed)

    plr.sprite = love.graphics.newImage('sprites/plr.png')
    plr.grid = anim8.newGrid(32, 32, plr.sprite:getWidth(), plr.sprite:getHeight())

    anim.animspeed = 0.1

    anim.rightIdle = anim8.newAnimation(plr.grid('1-7', 1), anim.animspeed)
    anim.leftIdle = anim8.newAnimation(plr.grid('1-7', 2), anim.animspeed)
    anim.rightrun = anim8.newAnimation(plr.grid('1-7', 3), anim.animspeed)
    anim.leftrun = anim8.newAnimation(plr.grid('1-7', 4), anim.animspeed)
    anim.rightjump = anim8.newAnimation(plr.grid('1-7', 5), anim.animspeed)
    anim.leftjump = anim8.newAnimation(plr.grid('1-7', 6), anim.animspeed)
    
    plr.currentAnim = anim.rightIdle

    plr.col = world:newBSGRectangleCollider(plr.x, plr.y, 35, 100, 10)
    plr.col:setFixedRotation(true)


    plr.jumpDebounce = 0

    plr.maxjumps = 2
    plr.Direction = ''


    --startscreen

    startscreen = {}

    startscreen.buttonimg = love.graphics.newImage('sprites/bomb.png')
    startscreen.grid = anim8.newGrid(32, 32, startscreen.buttonimg:getWidth(), startscreen.buttonimg:getHeight())
    anim.startbutton = anim8.newAnimation(startscreen.grid('1-3', 1), 0.75)

    font = love.graphics.newFont("fonts/retro.ttf")
    love.graphics.setFont(font)

    timer = 20


    --sounds fx

    sounds = {}

    sounds.beep = love.audio.newSource("sounds/beep.wav", "static")
    sounds.beep:setVolume(0.1)

    sounds.expload = love.audio.newSource("sounds/expload.mp3", "static")

    sounds.hurt = love.audio.newSource("sounds/Hurt.mp3", "static")
    sounds.hurt:setVolume(0.6)

    sounds.coin = love.audio.newSource("sounds/coin.mp3", "static")
    sounds.coin:setVolume(0.6)    

    sounds.step = love.audio.newSource("sounds/step.mp3", "static")
    sounds.step:setVolume(0.3)
    sounds.step:setPitch(1.5)

    sounds.jump = love.audio.newSource("sounds/jump.mp3", "static")
    sounds.jump:setVolume(0.6)

    sounds.expl = love.audio.newSource("sounds/expload.mp3", "static")

    --fireballs

    fireBallimg = love.graphics.newImage('sprites/fireball.png')
    fireBallgrid = anim8.newGrid(32, 32, fireBallimg:getWidth(), fireBallimg:getHeight())
    anim.fireball = anim8.newAnimation(fireBallgrid('1-5', 1), 0.1)

    FBspawn = {}
    newFB = {}

    firb = require 'libraries/fireball'

    -- images

    images = {}

    images.city = love.graphics.newImage('sprites/city.png')
    images.sewer = love.graphics.newImage('sprites/sewer.png')

    images.bg = images.sewer

    images.spike = love.graphics.newImage('sprites/spike.png')

    images.shop = love.graphics.newImage('sprites/shop.png')

    maps = {}
    HB = {}

    HitboxesDrawn = false
    maps.lvl1 = sti('map/lvl1.lua')
    maps.lvl1.width = maps.lvl1.width * maps.lvl1.tilewidth
    maps.lvl1.height = maps.lvl1.height * maps.lvl1.tilewidth

    -- clocks

    clock = {}

    clock.img = love.graphics.newImage('sprites/clock.png')
    clock.grid = anim8.newGrid(32, 32, clock.img:getWidth(), clock.img:getHeight())
    anim.clock = anim8.newAnimation(clock.grid('1-8', 1), 0.2)

    clk = require 'libraries/Clocks'

    --levels

    currentLvl = 1
    

    if currentLvl == 1 then

        walls = {}

        for i, v in pairs(maps.lvl1.layers["Hitboxes"].objects) do

            --Cant use polygon because the max verticies in wf is 8

           --[[ if v.shape == "polygon" then
                local verts = {}

                for _, a in ipairs(v.polygon) do
                    table.insert(verts, v.x + a.x)
                    table.insert(verts, v.y + a.y)
                end
                
                
                local PhysWallbox = world:newPolygonCollider(verts)

                PhysWallbox:setType('static')
                table.insert(walls, PhysWallbox)

            else]]
                
                love.graphics.scale(5, 5)

                local hitbox = world:newRectangleCollider(v.x * 5, v.y * 5, v.width * 5 + 1, v.height * 5 + 1)
                hitbox:setType('static')
                table.insert(walls, hitbox)
            --end
        end

        for i, v in pairs(maps.lvl1.layers["Spikes"].objects) do  

            --local spike = love.graphics.rectangle('line', v.x * 5 + 13, v.y * 5 + 18, 10, 20)
            
            --local spike = world:newRectangleCollider(v.x * 5, v.y * 5, v.width * 5 + 1, v.height * 5 + 1)
            if v.rotation == 0 then
                local spike = {
                    x = v.x * 5 + 13,
                    y = v.y * 5 + 18,
                    width = 10,
                    height = 20,
                    rotation = 0
                }
                table.insert(HB, spike)

            elseif v.rotation == 180 then
                local spike = {
                    x = v.x * 5 - 23,
                    y = v.y * 5 - 28,
                    width = 10,
                    height = 20,
                    rotation = 180
                }
                table.insert(HB, spike)
            end
        end

        for i, v in pairs(maps.lvl1.layers["Fireball"].objects) do  

             local spawner = {
                    x = v.x * 5 + 13,
                    y = v.y * 5 + 18,
                    width = 10,
                    height = 20
            }

            table.insert(FBspawn, spawner)
        end

        firb.fbd(maps.lvl1)
        clk.props(maps.lvl1)
        endobj = maps.lvl1.layers["End"].objects[1]

        endobj.width = endobj.width * 3
        endobj.height = endobj.height * 7
  
    end

    firb.spawnersLOAD(FBspawn)

    --Timer

    Timers = {}

    Timers.fall = Chrono()
    Timers.death = Chrono()
    Timers.If = Chrono()
    Timers.exp = Chrono()
    Timers.IfFall = Chrono()

    --explosion 

    exp = {}
    exp.img = love.graphics.newImage("sprites/explosion.png")
    exp.grid = anim8.newGrid(32, 32, exp.img:getWidth(), exp.img:getHeight())
    anim.expl = anim8.newAnimation(exp.grid('1-12', 1), 0.035)
    exp.deb = false





end

function love.update (dt)





    if started == false then
        anim.startbutton:update(dt)
    end



    if started == true then

        local plrMoving = false

        local velx, vely = plr.col:getLinearVelocity()

        local latestHealth = Health


        --timer
        if dead == false and won == false then
        timer = timer - dt

        timerRounded = math.floor(timer)

        sounds.beep:play()
            exp.deb = false
        end
        --plr movement

        if love.keyboard.isDown('a') then
            plrscript:move('left', plr.col, velx)

            plr.currentAnim = anim.leftrun
            plr.Direction = 'left'

            if vely == 0 then
            sounds.step:play()
            end
        elseif love.keyboard.isDown('d') then
            plrscript:move('right', plr.col, velx)
            
            plr.currentAnim = anim.rightrun
            plr.Direction = 'right'

            if vely == 0 then
            sounds.step:play()
            end
    
        end
    
        if velx == 0 then
           plrMoving = false
        end


        if vely == 0 then
            plr.jumpDebounce = 0
        
        end

        if velx >= 10 or velx <= -10 then
            plrMoving = true
        end



        if plrMoving == false then

            if plr.Direction == 'left' then

                plr.currentAnim = anim.leftIdle

            elseif plr.Direction == 'right' then

                plr.currentAnim = anim.rightIdle

            end

        end

        if vely >= 10 or vely <= -10 then

            if plr.Direction == 'left' then
            plr.currentAnim = anim.leftjump
            elseif plr.Direction == 'right' then
            plr.currentAnim = anim.rightjump
            end
        end

        --if HitboxesDrawn == true then 
            for i, v in pairs(HB) do
                if collision.AABB(plr.x - 17.5, plr.y - 50, 35, 100, v.x, v.y, v.width, v.height) then
                    if plr.Iframes == false then
                        Health = Health - 1
                    end
                    plr.Iframes = true
                    
                    if v.rotation == 0 then 
                        plr.col:setY(colY - 50)
                        plr.col:setLinearVelocity(0, 0)
                        plr.col:applyForce(0, -125000)
                        
                    elseif v.rotation == 180 then
                        plr.col:setY(colY + 50)
                        plr.col:setLinearVelocity(0, 0)
                        plr.col:applyForce(0, 125000)
                    
                    end


                    plr.jumpDebounce = 0
                    
                    Timers.IfFall:after(5, function() plr.Iframes = false end)


                end

                

            end
        --end

        if plr.y > 1900 then
            if plr.Iframes == false then
                Health = Health - 1 
            end
            plr.Iframes = true

            plr.col:setX(628)
            plr.col:setY(1710)

            plr.col:setType('static')

            
            Timers.fall:after(1, function()

                plr.col:setType('dynamic')

                plr.jumpDebounce = 0

            end)

            Timers.IfFall:after(5, function() plr.Iframes = false end)
        end


        if collision.AABB(endobj.x, endobj.y - 100, endobj.width, endobj.height, plr.x, plr.y, 35, 100) and not paused then 

            won = true

        end




        if plr.y <= 460 then
            images.bg = images.city
        else 
            images.bg = images.sewer
        end

        --updates (nothing should come after these)

        colX = plr.col:getX()
        colY = plr.col:getY()

        plr.x = plr.col:getX()
        plr.y = plr.col:getY()
        plr.currentAnim:update(dt)
        world:update(dt)
        anim.heart:update(dt)
        anim.clock:update(dt)
        anim.fireball:update(dt)
        Timers.fall:update(dt)
        Timers.death:update(dt)
        Timers.If:update(dt)
        firb.update(dt)
        firb.fireUpd(plr.x, plr.y, Timers.If)
        clk.upd(colX, colY, timer)
        anim.expl:update(dt)
        Timers.exp:update(dt)
        Timers.IfFall:update(dt)
        
        
        cam:lookAt(plr.x, plr.y)

        if cam.x < numbers.width then
            cam.x =  numbers.width / 2
        end
        if cam.y < numbers.height -500 then
            cam.y =  (numbers.height - 500)
        end
        if cam.x > (maps.lvl1.width + 2800) then
            cam.x = (maps.lvl1.width + 2800)
        end
        if cam.y > (maps.lvl1.height + 1300) then
           cam.y = (maps.lvl1.height + 1300)
        end

        --keep this after other plr code
        if Health < latestHealth then
            sounds.hurt:play()
        end

        if Health <= 0 then
            dead = true
            plr.col:setType('static')
        end


        if dead == true and not paused then
            paused = true
            sounds.expl:play()

            Timers.death:after(5, function()

            currentLvl = 1
            Health = 3

            plr.col:setX(100)
            plr.col:setY(1750)
            
            started = false

            dead = false           
            timer = 20
            paused = false

            
                plr.col:setType('dynamic')
            end)    
        end

        if won == true and not paused then
            paused = true
            sounds.expl:play()

            plr.col:setType('static')
            
                        Timers.death:after(6, function()
            won = false

            currentLvl = 1
            Health = 3
            
            plr.col:setX(100)
            plr.col:setY(1750)

            started = false

            timer = 20
                
                Timers.death:after(0.1, function()

                paused = false
        
                plr.col:setType('dynamic')
                end)
            end)    

        end
    end
end

function love.draw ()

   
    --love.graphics.print(plr.Direction)


    love.graphics.setColor(1,1,1,1)

    --keep this outside of cam:attatch()

    love.graphics.draw(images.bg, 400, 300, nil, 30, 20, images.bg:getWidth() / 2, images.bg:getHeight() / 2)
    love.graphics.setColor(0,0,0, 0.4)
    love.graphics.rectangle('fill', 0, 0, 1000, 1000)
    love.graphics.setColor(1,1,1,1)

    if started == false then
        anim.startbutton:draw(startscreen.buttonimg, 160, 30, nil, 15)

        love.graphics.setColor(0,1,0)

        love.graphics.print("Click to start", numbers.width / 2 - 100, numbers.height / 2 - 40, 0, 3, 3)
    end


    --love.graphics.rectangle("fill", numbers.width, 1600, 20, 20) --position measure

    if started == true then


        cam:attach()

        if currentLvl == 1 then

            love.graphics.setColor(1,1,1,1)

            love.graphics.push()



                love.graphics.scale(5, 5)
                
                local l1 = maps.lvl1
                l1:drawLayer((l1.layers["tiles"]))
                love.graphics.scale(1, 1)


            love.graphics.pop()




            for i, v in pairs(maps.lvl1.layers["Spikes"].objects) do

                if v.rotation == 0 then
                    love.graphics.draw(images.spike, v.x * 5 + 18, v.y * 5 + 16, nil, 1.5, 1.5, images.spike:getWidth() / 2, images.spike:getHeight() / 2)
               elseif v.rotation == 180 then
                    love.graphics.draw(images.spike, v.x * 5 - 18, v.y * 5 - 16, 3.15, 1.5, 1.5, images.spike:getWidth() / 2, images.spike:getHeight() / 2)
                end
            end

            --[[for i, v in pairs(HB) do -- Show Hitbox
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
                love.graphics.setColor(1,1,1,1)
                
            end]]
            if won == true then
                love.graphics.setColor(0,0,0)
            end
            love.graphics.draw(images.shop, endobj.x, endobj.y - 120, nil, 10, 10)
            love.graphics.setColor(1,1,1,1)

            HitboxesDrawn = true

            firb.spawnersDRAW(FBspawn)
            clk.draw()
        end

        love.graphics.setColor(1,1,1,1)

        

        firb.drawB()

        --love.graphics.rectangle('line', endobj.x, endobj.y - 100, endobj.width, endobj.height)

            love.graphics.setColor(0,0,0,0.2)
            love.graphics.rectangle('fill', 0, -2500, 0, 200000, 20000)
            love.graphics.setColor(1,1,1,1)

                 -----COLLIDER AND PLR POSITION CHECKER-----
        --[[
        (DEBUGGING TOOL)
        --when on, the positions should be the same and they both should be at the plrs x
        and y. 

        Red - collider, white - plr
        ]]
        --[[
        love.graphics.rectangle('fill', plr.col:getX(), plr.col:getY(), 20, 20)
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle('fill', plr.x, plr.y, 10, 10)
        love.graphics.setColor(1,1,1,1)
        ]]


        if dead == true then
            love.graphics.setColor(0,0,0)
        end

        plrscript:drawPlr(plr.sprite, plr.currentAnim, plr.x, plr.y, plr.scale, plr.scale)
        love.graphics.setColor(1,1,1,1)

        if dead == true then
            if exp.deb == false then
                anim.expl:draw(exp.img, colX - 200, colY - 200, nil, 15)
                
                Timers.exp:after(0.4, function() exp.deb = true end)
                

            end
        end



        if won == true then

            if exp.deb == false then
                anim.expl:draw(exp.img, endobj.x - 200, endobj.y - 390, nil, 25)
                
                Timers.exp:after(0.4, function() exp.deb = true end)
                

            end

        end

        if plr.Iframes == true then
            love.graphics.setColor(0.5,0.5,1, 0.4)
            love.graphics.circle("fill", plr.x, plr.y, 50)
            love.graphics.setColor(1,1,1,1)

        end

        --world:draw() -- for debugging

        cam:detach()

        --More debugging for plr x and y
        --[[
        love.graphics.print(colX, 300, 0, 0, 2)
        love.graphics.print(colY, 500, 0, 0, 2)
        love.graphics.print(plr.x, 300, 50, 0, 2)
        love.graphics.print(plr.y, 500, 50, 0, 2)
        ]]

    
    
        love.graphics.print(timerRounded, 400, 30, nil, 3, 3)

                    --hearts
        if Health >= 1 then
            anim.heart:draw(heart.img, 0, 3, nil, heart.size)

            if Health >= 2 then
            anim.heart:draw(heart.img, 65, 3, nil, heart.size)

            if Health == 3 then
            anim.heart:draw(heart.img, 130, 3, nil, heart.size)
        
        end
        end
        end

        --firb.test() --debbugging

        if dead == true then

            graphics.print("Game Over", numbers.width / 2 - 100, numbers.height / 2 - 40, 0, 5, 5)

              
        end

        if won == true then
            
            
            love.graphics.setColor(0.75,0.75,0)
            
            love.graphics.rectangle('fill', 185, 200, 520, 170)

            love.graphics.setColor(0,0,0)
            love.graphics.print("Congratulations", 240, 200, 0, 5, 5)
            love.graphics.print("You Won", 350, 250, 0, 5, 5)
            love.graphics.print("Thanks For Playing!", 200, 300, 0, 5, 5)

        end


    end
end


function love.keypressed (key)

    if started == true then



        if key == "space" and plr.jumpDebounce < plr.maxjumps then
            plrscript:jump(plr.col, plr.jumpDebounce)
            plr.jumpDebounce = plr.jumpDebounce + 1
            sounds.jump:play()
        end

        --[[if key == "r" then

            Health = 0

        end]]

    end
end

function love.mousepressed(x, y, button)

    if x < 530 and x > 250 and y > 195 and y < 325 and started == false then -- detects if the click is within the start button
        started = true
    end


end


 ------------ NOTES ------------

--[[

Issue:

players collider is moving right but player is not. doesn't move like anything else
set to the players x or y

something to do with camera

Resolution: scale value was affecting world:draw


Issue:

-plrs collider is off of where it should be (wrong x and y) but is moving correctly

Resolution: just readjust

Issue:hitboxes were affected positively by the scale but now they are messed up

res - made the hitboxes get scaled up in every value during creation




]]