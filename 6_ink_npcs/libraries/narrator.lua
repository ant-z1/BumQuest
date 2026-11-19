
--
-- narrator.lua
--
-- Connects the Narrator ink interpreter to the Talkies dialogue UI.
-- Handles NPC dialogue and notifies main.lua when dialogue finishes.
--

local narrator = {}

local Talkies
local NarratorLib


-- Complete an NPC conversation
local function completeState(state)

    -- Prevent the completion callback from running more than once
    if state.completed then
        return
    end

    state.completed = true

    if state.npc then
        state.npc.isTalking = false

        -- Notify main.lua that NPC dialogue has finished
        if narrator.onDialogueComplete then
            narrator.onDialogueComplete(state.npc)
        end
    end
end


--
-- INIT
--

function narrator:init()

    love.filesystem.setRequirePath(
        love.filesystem.getRequirePath()
        .. ';libraries/?.lua;libraries/?/init.lua'
    )

    package.path = package.path
        .. ';libraries/?.lua;libraries/?/init.lua'

    -- Load LPeg or use lulpeg
    if not pcall(require, 'lpeg') then
        local lulpeg = require('libraries.lulpeg')
        package.loaded['lpeg'] = lulpeg.new({
            factorize = false
        })
    end

    NarratorLib = require('libraries.narrator.narrator')
    Talkies = require('libraries.talkies')

    Talkies.font = love.graphics.newFont(16)
    Talkies.padding = 12
    Talkies.rounding = 4
    Talkies.thickness = 2

    self._boundNPCs = {}
end


--
-- CHARACTER + NPC BINDING
--

function narrator:newCharacter(name, avatarPath)

    local image = nil

    if avatarPath then
        image = love.graphics.newImage(avatarPath)
    end

    return {
        name = name,
        image = image
    }
end


function narrator:bindNPC(npc, character, scriptName)

    npc.character = character
    npc.script = scriptName
    npc.isTalking = false

    -- Save the original NPC update function
    if not npc._origUpdate then

        npc._origUpdate = npc.update

        npc.update = function(self_, dt)

            if self_.isTalking then

                if self_.anim and self_.anim.gotoFrame then
                    self_.anim:gotoFrame(2)
                end

                return
            end

            self_:_origUpdate(dt)
        end
    end

    table.insert(self._boundNPCs, npc)

    return npc
end


--
-- RUNNING INK SCRIPTS
--

function narrator:_pump(state)

    local story = state.story

    -- Get the next dialogue paragraphs
    local lines = {}

    while story:can_continue() do

        local batch = story:continue()

        for _, paragraph in ipairs(batch) do

            local text = paragraph.text or ""

            if text ~= "" then
                table.insert(lines, text)
            end
        end
    end

    local config = {}

    if state.character and state.character.image then
        config.image = state.character.image
    end

    -- Check for dialogue choices
    if story:can_choose() then

        local choices = story:get_choices()
        local options = {}

        for i, choice in ipairs(choices) do

            options[i] = {
                choice.text,

                function()

                    story:choose(i)

                    narrator:_pump(state)
                end
            }
        end

        config.options = options

        if #lines == 0 then
            lines = { "..." }
        end

    else

        -- Dialogue has reached its end
        config.oncomplete = function()

            completeState(state)

        end

        -- Handle scripts that end immediately
        if #lines == 0 then

            completeState(state)

            return
        end
    end

    local title = (state.character and state.character.name) or ""

    Talkies.say(title, lines, config)
end


--
-- START SCRIPT
--

function narrator:startScript(npcOrScriptName)

    local npc, scriptName, character

    if type(npcOrScriptName) == "string" then

        scriptName = npcOrScriptName
        character = {
            name = "",
            image = nil
        }

    else

        npc = npcOrScriptName
        scriptName = npc.script
        character = npc.character or {
            name = "",
            image = nil
        }

        assert(
            scriptName,
            "narrator:startScript - This NPC has no bound script."
        )
    end

    -- Load the Ink script
    local path = "scripts/" .. scriptName .. ".ink"

    local content, err = love.filesystem.read(path)

    assert(
        content,
        "narrator: could not load " .. path .. " (" .. tostring(err) .. ")"
    )

    local book = NarratorLib.parse_content(content)
    local story = NarratorLib.init_story(book)

    story:begin()

    if npc then
        npc.isTalking = true
    end

    local state = {
        story = story,
        npc = npc,
        character = character,
        completed = false
    }

    self:_pump(state)
end


--
-- TALKIES FUNCTIONS
--

function narrator:update(dt)
    Talkies.update(dt)
end


function narrator:draw()
    Talkies.draw()
end


function narrator:onAction()
    Talkies.onAction()
end


function narrator:prevOption()
    Talkies.prevOption()
end


function narrator:nextOption()
    Talkies.nextOption()
end


function narrator:isOpen()
    return Talkies.isOpen()
end


return narrator
