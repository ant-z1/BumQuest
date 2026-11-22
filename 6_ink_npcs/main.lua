
function love.load()

    
    gameState = "mainMenu"


    math.randomseed(os.time())

    love.window.setTitle("Inky Project - 6_ink_npcs")

    camera = require 'libraries/camera'
    NPC = require 'libraries/npc'
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    narrator = require 'libraries/narrator'

    cam = camera()

    love.graphics.setDefaultFilter("nearest", "nearest")

    gameMap = sti('maps/testMap.lua')
    gameMap:resize(love.graphics.getWidth()*2, love.graphics.getHeight())

    -- Player
    player = {}
    player.x = 400
    player.y = 200
    player.speed = 5

    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')

    player.grid = anim8.newGrid(
        12,
        18,
        player.spriteSheet:getWidth(),
        player.spriteSheet:getHeight()
    )

    player.animations = {}

    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    -- NPCs
    myNPC = NPC.new('sprites/player-sheet.png', 1595, 1065, 80, 0)
    drNPC = NPC.new('sprites/player-sheet.png', 1700, 230, 50, 50)

    -- Narrator setup
    narrator:init()

    characterDumbledore = narrator:newCharacter(
        "Dumbledore",
        "sprites/Dumbledore_avatar.png"
    )

    characterDoc = narrator:newCharacter(
        "Doctor",
        "sprites/doctor_avatar.png"
    )

    narrator:bindNPC(myNPC, characterDumbledore, "DumbledoreSaysHello")
    narrator:bindNPC(drNPC, characterDoc, "DrSaysHello")

    -- Interaction settings
    interactRange = 80
    nearbyNPC = nil

    promptFont = love.graphics.newFont(14)

    -- Battle settings
    playerHP = 100
    enemyHP = 100
    playerPotions = 3

    battleNPC = nil
    playerDefending = false
    battleMessage = ""

end




function treeAt(x, y)

    local layer = gameMap.layers["Trees"]

    local tx = math.floor(x / gameMap.tilewidth) + 1
    local ty = math.floor(y / gameMap.tileheight) + 1

    return layer.data[ty] and layer.data[ty][tx]

end




function findNearbyNPC()

    local closest, closestDist = nil, interactRange

    for _, npc in ipairs(narrator._boundNPCs) do

        local dx = npc.x - player.x
        local dy = npc.y - player.y

        local dist = math.sqrt(dx * dx + dy * dy)

        if dist <= closestDist then

            closest = npc
            closestDist = dist

        end
    end

    return closest

end




function startBattle(npc)

    gameState = "battle"

    battleNPC = npc

    playerHP = 100
    enemyHP = 100

    playerPotions = 3

    playerDefending = false

    battleMessage = "A battle has started!"

    nearbyNPC = nil

end




function enemyTurn()

    if enemyHP <= 0 or playerHP <= 0 then
        return
    end

    local damage = math.random(8, 16)

    -- Check if player is defending
    if playerDefending then

        damage = math.floor(damage / 2)

        playerDefending = false

        battleMessage = "You defended! The NPC dealt "
            .. damage .. " damage!"

    else

        battleMessage = battleNPC.character.name
            .. " attacked! You took "
            .. damage .. " damage!"

    end

    playerHP = playerHP - damage

    -- Player loses
    if playerHP <= 0 then

        playerHP = 0

        gameState = "gameOver"

        battleMessage = "You lost the battle!"

    end

end




function playerAttack()

    local damage = math.random(12, 22)

    enemyHP = enemyHP - damage

    -- Check if enemy loses
    if enemyHP <= 0 then

        enemyHP = 0

        gameState = "victory"

        battleMessage = "You defeated "
            .. battleNPC.character.name .. "!"

        return

    end

    battleMessage = "You attacked for "
        .. damage .. " damage!"

    enemyTurn()

end




function playerDefend()

    playerDefending = true

    battleMessage = "You prepared to defend!"

    enemyTurn()

end




function playerHeal()

    if playerPotions <= 0 then

        battleMessage = "You have no potions left!"

        return

    end

    if playerHP >= 100 then

        battleMessage = "Your health is already full!"

        return

    end

    local healing = 25

    playerHP = math.min(playerHP + healing, 100)

    playerPotions = playerPotions - 1

    battleMessage = "You healed yourself!"

    enemyTurn()

end




function love.update(dt)

    -- Only update the world while playing
    if gameState ~= "playing" then
        return
    end

    local dialogueOpen = narrator:isOpen()

    -- Player movement
    if not dialogueOpen then

        local isMoving = false

        local oldX, oldY = player.x, player.y

        if love.keyboard.isDown("right") then

            player.x = player.x + player.speed
            player.anim = player.animations.right
            isMoving = true

        end

        if love.keyboard.isDown("left") then

            player.x = player.x - player.speed
            player.anim = player.animations.left
            isMoving = true

        end

        if love.keyboard.isDown("down") then

            player.y = player.y + player.speed
            player.anim = player.animations.down
            isMoving = true

        end

        if love.keyboard.isDown("up") then

            player.y = player.y - player.speed
            player.anim = player.animations.up
            isMoving = true

        end

        -- Tree collision
        if treeAt(player.x, oldY) then
            player.x = oldX
        end

        if treeAt(player.x, player.y) then
            player.y = oldY
        end

        if not isMoving then
            player.anim:gotoFrame(2)
        end

    else

        player.anim:gotoFrame(2)

    end

    player.anim:update(dt)

    -- Camera
    cam:lookAt(player.x, player.y)

    local w, h = love.graphics.getDimensions()

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    cam.x = math.max(w/2, math.min(cam.x, mapW - w/2))
    cam.y = math.max(h/2, math.min(cam.y, mapH - h/2))

    -- NPC updates
    myNPC:update(dt)
    drNPC:update(dt)

    -- Find nearby NPC
    if dialogueOpen then

        nearbyNPC = nil

    else

        nearbyNPC = findNearbyNPC()

    end

    narrator:update(dt)

end




function drawInteractPrompt(npc)

    love.graphics.setColor(1, 1, 1)

    love.graphics.print(
        "Press E to fight",
        npc.x - 40,
        npc.y - 60
    )

end




function love.draw()

    love.graphics.setColor(1, 1, 1)

    
    if gameState == "mainMenu" then

        love.graphics.printf(
            "MY GAME",
            0,
            150,
            love.graphics.getWidth(),
            "center"
        )

        love.graphics.printf(
            "Press ENTER to start",
            0,
            250,
            love.graphics.getWidth(),
            "center"
        )


    
    elseif gameState == "playing" then

        cam:attach()

            gameMap:drawLayer(gameMap.layers["Ground"])

            player.anim:draw(
                player.spriteSheet,
                player.x,
                player.y,
                nil,
                6,
                nil,
                6,
                9
            )

            myNPC:draw()
            drNPC:draw()

            gameMap:drawLayer(gameMap.layers["Trees"])

            if nearbyNPC then
                drawInteractPrompt(nearbyNPC)
            end

        cam:detach()

        love.graphics.setColor(1, 1, 1)

        love.graphics.print(
            "x = " .. math.floor(player.x)
            .. " y = " .. math.floor(player.y),
            10,
            10
        )

        narrator:draw()


   
    elseif gameState == "battle" then

        local screenWidth = love.graphics.getWidth()

        love.graphics.printf(
            "BATTLE!",
            0,
            50,
            screenWidth,
            "center"
        )

       
        love.graphics.printf(
            "PLAYER",
            100,
            120,
            200,
            "center"
        )

        love.graphics.printf(
            "HP: " .. playerHP .. " / 100",
            100,
            150,
            200,
            "center"
        )

        
        love.graphics.printf(
            battleNPC.character.name,
            screenWidth - 300,
            120,
            200,
            "center"
        )

        love.graphics.printf(
            "HP: " .. enemyHP .. " / 100",
            screenWidth - 300,
            150,
            200,
            "center"
        )

        
        love.graphics.printf(
            battleMessage,
            20,
            220,
            screenWidth - 40,
            "center"
        )

        
        love.graphics.printf(
            "1 - Attack",
            0,
            300,
            screenWidth,
            "center"
        )

        love.graphics.printf(
            "2 - Defend",
            0,
            340,
            screenWidth,
            "center"
        )

        love.graphics.printf(
            "3 - Heal (" .. playerPotions .. " potions left)",
            0,
            380,
            screenWidth,
            "center"
        )


    
    elseif gameState == "gameOver" then

        love.graphics.printf(
            "GAME OVER",
            0,
            150,
            love.graphics.getWidth(),
            "center"
        )

        love.graphics.printf(
            "You lost the battle!",
            0,
            220,
            love.graphics.getWidth(),
            "center"
        )

        love.graphics.printf(
            "Press ENTER to return to the main menu",
            0,
            280,
            love.graphics.getWidth(),
            "center"
        )


    
    elseif gameState == "victory" then

        love.graphics.printf(
            "YOU WIN!",
            0,
            150,
            love.graphics.getWidth(),
            "center"
        )

        love.graphics.printf(
            "You defeated " .. battleNPC.character.name .. "!",
            0,
            220,
            love.graphics.getWidth(),
            "center"
        )

        love.graphics.printf(
            "Press ENTER to continue",
            0,
            280,
            love.graphics.getWidth(),
            "center"
        )

    end

end




function love.keypressed(key)

    if key == "escape" then
        love.event.quit()
    end

    -- MAIN MENU
    if gameState == "mainMenu" then

        if key == "return" then

            gameState = "playing"

        end


   
    elseif gameState == "battle" then

        if key == "1" then

            playerAttack()

        elseif key == "2" then

            playerDefend()

        elseif key == "3" then

            playerHeal()

        end


    
    elseif gameState == "gameOver" then

        if key == "return" then

            gameState = "mainMenu"

        end


    
    elseif gameState == "victory" then

        if key == "return" then

            gameState = "playing"
            nearbyNPC = nil

        end


    
    elseif gameState == "playing" then

        if key == "e" and nearbyNPC then

            startBattle(nearbyNPC)

        end

    end

end
