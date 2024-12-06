-- Initialize saved variables
AzerothPacerSaved  = AzerothPacerSaved or {
    minimap = { hide = false, minimapPos = 0 },
    debugMode = false,
    movement = {
        distance = 0,
        lastX = 0,
        lastY = 0,
        lastZ = 0,
        steps = 0,
        jumpDistance = 0,
        ridingDistance = 0,
        swimmingDistance = 0,
        walkingDistance = 0
    },
    windowSize = {
        width = Config.displayFrameWidth.default,
        height = Config.displayFrameHeight.default,
        debugWidth = Config.displayFrameDebugWidth.default,
        debugHeight = Config.displayFrameDebugHeight.default,
        isResizable = true
    },
    isMovable = true
}

-- Create the display frame
local displayFrame = CreateFrame("Frame", "AzerothPacerFrame", UIParent, "BackdropTemplate")
displayFrame:SetSize(Config.displayFrameWidth.default, Config.displayFrameHeight.default)
displayFrame:SetPoint("CENTER")
displayFrame:SetResizable(AzerothPacerSaved.windowSize.isResizable)
displayFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background", --"Interface/TutorialFrame/TutorialFrameBackground",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",   --Interface/DialogFrame/UI-DialogBox-Border", --"Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,                                       --32,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
displayFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
displayFrame:SetMovable(AzerothPacerSaved.isMovable)
displayFrame:EnableMouse(AzerothPacerSaved.isMovable)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart", displayFrame.StartMoving)
displayFrame:SetScript("OnDragStop", displayFrame.StopMovingOrSizing)

displayFrame:SetScript("OnSizeChanged", function(self, width, height)
    -- Enforce minimum size during resizing
    local maxWidth = Config.displayFrameWidth.max
    local maxHeight = Config.displayFrameHeight.max
    local minHeight = Config.displayFrameHeight.min
    local minWidth = Config.displayFrameWidth.min

    if (AzerothPacerSaved.debugMode) then
        maxWidth = Config.displayFrameDebugWidth.max
        minWidth = Config.displayFrameDebugWidth.min
        maxHeight = Config.displayFrameDebugHeight.max
        minHeight = Config.displayFrameDebugHeight.min
    end

    if width < minWidth then
        self:SetWidth(minWidth)
    end

    if height < minHeight then
        self:SetHeight(minHeight)
    end

    if width > maxWidth then
        self:SetWidth(maxWidth)
    end

    if height > maxHeight then
        self:SetHeight(maxHeight)
    end

    Utils.AdjustRowsWidth(width)
end)


-- Title FontString
local titleString = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
titleString:SetPoint("TOP", 0, -10)
titleString:SetText("Azeroth Pacer")
titleString:SetTextHeight(12)

-- Add a resize button
local resizeButton = CreateFrame("Button", nil, displayFrame)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
resizeButton:EnableMouse(true)
resizeButton:RegisterForDrag("LeftButton")

resizeButton:SetScript("OnDragStart", function()
    if AzerothPacerSaved.windowSize.isResizable then
        displayFrame:StartSizing("BOTTOMRIGHT")
    end
end)

resizeButton:SetScript("OnDragStop", function()
    displayFrame:StopMovingOrSizing()

    -- Get the new dimensions
    local width, height = displayFrame:GetWidth(), displayFrame:GetHeight()
    local minWidth = Config.displayFrameWidth.min
    local maxWidth = Config.displayFrameWidth.max
    local maxHeight = Config.displayFrameHeight.max
    local minHeight = Config.displayFrameHeight.min

    if (AzerothPacerSaved.debugMode) then
        minWidth = Config.displayFrameDebugWidth.min
        maxWidth = Config.displayFrameDebugWidth.max
        minHeight = Config.displayFrameDebugHeight.min
        maxHeight = Config.displayFrameDebugHeight.max
    end

    if width < minWidth then
        width = minWidth
        displayFrame:SetWidth(minWidth)
    end
    if width > maxWidth then
        width = maxWidth
        displayFrame:SetWidth(maxWidth)
    end
    if height < minHeight then
        height = minHeight
        displayFrame:SetHeight(minHeight)
    end
    if height > maxHeight then
        height = maxHeight
        displayFrame:SetHeight(maxHeight)
    end

    if (AzerothPacerSaved.debugMode) then
        AzerothPacerSaved.windowSize.debugWidth = width
        AzerothPacerSaved.windowSize.debugHeight = height
        print(string.format("Azeroth Pacer: New size saved - Width: %.2f, Height: %.2f", width, height))
    else
        AzerothPacerSaved.windowSize.width = width
        AzerothPacerSaved.windowSize.height = height
    end
end)



-- Rows for Overview Info
local overviewOffsetY = -25
local stepsRow, stepsValue = Utils.CreateRow(displayFrame, "Steps:", "0", 10, overviewOffsetY, displayFrame:GetWidth())
local totalDistanceRow, totalDistanceValue = Utils.CreateRow(displayFrame, "Total Distance:", "0.00 yards", 10,
    overviewOffsetY - 16, displayFrame:GetWidth())
local jumpDistanceRow, jumpDistanceValue = Utils.CreateRow(displayFrame, "Jump Distance:", "0.00 yards", 10,
    overviewOffsetY - 32, displayFrame:GetWidth())
local ridingDistanceRow, ridingDistanceValue = Utils.CreateRow(displayFrame, "Riding Distance:", "0.00 yards", 10,
    overviewOffsetY - 64, displayFrame:GetWidth())
local swimmingDistanceRow, swimmingDistanceValue = Utils.CreateRow(displayFrame, "Swimming Distance:", "0.00 yards", 10,
    overviewOffsetY - 80, displayFrame:GetWidth())
local walkingDistanceRow, walkingDistanceValue = Utils.CreateRow(displayFrame, "Walking Distance:", "0.00 yards", 10,
    overviewOffsetY - 96, displayFrame:GetWidth())

local debugHeader = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
debugHeader:SetPoint("TOPLEFT", 10, overviewOffsetY - 180)
debugHeader:SetText("Debug Info")
debugHeader:Hide()

local debugInfo = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
debugInfo:SetPoint("TOPLEFT", 10, overviewOffsetY - 200)
debugInfo:SetJustifyH("LEFT")
debugInfo:SetWidth(displayFrame:GetWidth() - 20)
debugInfo:Hide()


-- Update Movement Arrow Dynamically
local movementTexture = displayFrame:CreateTexture(nil, "ARTWORK")
movementTexture:SetTexture("Interface\\AddOns\\AzerothPacer\\assets\\arrow.png")
movementTexture:SetPoint("BOTTOM", 0, 20)
movementTexture:SetSize(32, 32)
movementTexture:Hide()

local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local characterRace = nil
local characterSex = nil
local characterClass = nil

-- Update Display Function
local function UpdateDisplay()
    stepsValue:SetText(tostring(AzerothPacerSaved.movement.steps))
    totalDistanceValue:SetText(string.format("%.2f yards", AzerothPacerSaved.movement.distance))
    jumpDistanceValue:SetText(string.format("%.2f yards", AzerothPacerSaved.movement.jumpDistance))
    ridingDistanceValue:SetText(string.format("%.2f yards", AzerothPacerSaved.movement.ridingDistance))
    swimmingDistanceValue:SetText(string.format("%.2f yards", AzerothPacerSaved.movement.swimmingDistance))
    walkingDistanceValue:SetText(string.format("%.2f yards", AzerothPacerSaved.movement.walkingDistance))
end

local eventFrame = CreateFrame("EventFrame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "AzerothPacerClassic" then
        -- Check saved variables and restore minimap position
        AzerothPacerSaved = AzerothPacerSaved or {}
        AzerothPacerSaved.debugMode = AzerothPacerSaved.debugMode or false
        AzerothPacerSaved.minimap = AzerothPacerSaved.minimap or { hide = false, minimapPos = 0 }
        AzerothPacerSaved.minimap.minimapPos = AzerothPacerSaved.minimap.minimapPos or 0 -- Ensure it is not nil
        AzerothPacerSaved.movement = AzerothPacerSaved.movement or {}
        AzerothPacerSaved.movement.distance = AzerothPacerSaved.movement.distance or 0
        AzerothPacerSaved.movement.lastX = AzerothPacerSaved.movement.lastX or 0
        AzerothPacerSaved.movement.lastY = AzerothPacerSaved.movement.lastY or 0
        AzerothPacerSaved.movement.lastZ = AzerothPacerSaved.movement.lastZ or 0
        AzerothPacerSaved.movement.steps = AzerothPacerSaved.movement.steps or 0
        AzerothPacerSaved.movement.jumpDistance = AzerothPacerSaved.movement.jumpDistance or 0
        AzerothPacerSaved.movement.ridingDistance = AzerothPacerSaved.movement.ridingDistance or 0
        AzerothPacerSaved.movement.swimmingDistance = AzerothPacerSaved.movement.swimmingDistance or 0
        AzerothPacerSaved.movement.walkingDistance = AzerothPacerSaved.movement.walkingDistance or 0

        AzerothPacerSaved.windowSize = AzerothPacerSaved.windowSize or {}
        AzerothPacerSaved.windowSize.width = AzerothPacerSaved.windowSize.width or Config.displayFrameWidth.default
        AzerothPacerSaved.windowSize.height = AzerothPacerSaved.windowSize.height or Config.displayFrameHeight.default
        AzerothPacerSaved.windowSize.debugWidth = AzerothPacerSaved.windowSize.debugWidth or
            Config.displayFrameDebugWidth.default
        AzerothPacerSaved.windowSize.debugHeight = AzerothPacerSaved.windowSize.debugHeight or
            Config.displayFrameDebugHeight.default

        AzerothPacerSaved.windowSize.isResizable = AzerothPacerSaved.windowSize.isResizable or true
        displayFrame:SetResizable(AzerothPacerSaved.windowSize.isResizable)

        AzerothPacerSaved.isMovable = AzerothPacerSaved.isMovable or true

        -- Enable or disable resize button
        if AzerothPacerSaved.windowSize.isResizable then
            resizeButton:Enable()
        else
            resizeButton:Disable()
        end

        characterRace = UnitRace("player")
        characterSex = UnitSex("player")
        print('loading class...')
        local localizedClass, englishClass, classIndex = UnitClass("player");
        print(englishClass)
        characterClass = englishClass

        UpdateDisplay()

        if (AzerothPacerSaved.debugMode) then
            print(string.format("Azeroth Pacer: Loaded minimap position: %.2f", AzerothPacerSaved.minimap.minimapPos))
        end
        -- Refresh to apply the saved position
        if LDBIcon then
            LDBIcon:Refresh("AzerothPacer", AzerothPacerSaved.minimap)
        end
    end
end)

-- FUNCTIONALITY --

local timeSinceLastUpdate = 0
local updateInterval = 0.1 -- seconds
local accumulatedDistance = 0
local baseRunSpeed = 7       -- yards per second
local backwardRunspeed = 4.5 -- yards per second unaffected by movement speed buffs
local walkSpeed = 2.5        -- yards per second in both directions (unaffected by movement speed buffs)
local isMovingForward = false
local isMovingBackward = false
local isRunning = true
local TurnOrActionStart = false
local isJumping = false
local jumpTime = 0.9 -- seconds
local jumpTimer = 0
local shapeshiftForm = 0
local shapeshiftSpellID = 0

hooksecurefunc("JumpOrAscendStart", function()
    if (AzerothPacerSaved.debugMode) then
        print("Jump started!")
    end
    isJumping = true
end);

hooksecurefunc("MoveBackwardStart", function()
    if (AzerothPacerSaved.debugMode) then
        print("Move backward start!")
    end
    isMovingBackward = true
end);

hooksecurefunc("MoveBackwardStop", function()
    if (AzerothPacerSaved.debugMode) then
        print("Move backward stop!")
    end
    isMovingBackward = false
end);

hooksecurefunc("MoveForwardStart", function()
    if (AzerothPacerSaved.debugMode) then
        print("Move forward start!")
    end
    isMovingForward = true
end);

hooksecurefunc("MoveForwardStop", function()
    if (AzerothPacerSaved.debugMode) then
        print("Move forward stop!")
    end
    isMovingForward = false
end);

hooksecurefunc("ToggleRun", function()
    isRunning = not isRunning
    if (AzerothPacerSaved.debugMode) then
        print(string.format("Is running: %s", isRunning and "true" or "false"))
    end
end);

hooksecurefunc("TurnOrActionStart", function()
    if (AzerothPacerSaved.debugMode) then
        print("Turning or action start!")
    end
    TurnOrActionStart = true
end);

hooksecurefunc("TurnOrActionStop", function()
    if (AzerothPacerSaved.debugMode) then
        print("Turning or action stop!")
    end
    TurnOrActionStart = false
end);

local function IsPlayerSwimming()
    local isSwimming = IsSwimming("player")
    return isSwimming
end


local function UpdateDebugDisplay(playerSpeed)
    if AzerothPacerSaved.debugMode then
        debugInfo:SetText(string.format(
            "Character race/sex: %s - %s - %s\n" ..
            "Is moving forward: %s\n" ..
            "Is moving backward: %s\n" ..
            "Is running: %s\n" ..
            "Turn or action start: %s\n" ..
            "Is jump started: %s\n" ..
            "Is swimming: %s\n" ..
            "Is riding: %s\n" ..
            "Player speed: %.2f",
            characterRace,
            characterSex,
            characterClass,
            tostring(isMovingForward),
            tostring(isMovingBackward),
            tostring(isRunning),
            tostring(TurnOrActionStart),
            tostring(isJumping),
            tostring(IsPlayerSwimming()),
            tostring(Utils.IsPlayerRiding(shapeshiftSpellID)),
            playerSpeed or 0
        ))
        debugHeader:Show()
        debugInfo:Show()
    else
        debugHeader:Hide()
        debugInfo:Hide()
    end
end



eventFrame:SetScript("OnUpdate", function(self, elapsed)
    if (isJumping) then
        jumpTimer = jumpTimer + elapsed
        if jumpTimer >= jumpTime then
            if (AzerothPacerSaved.debugMode) then
                print("Jump ended!")
            end
            isJumping = false
            jumpTimer = 0
        end
    end

    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate > updateInterval then
        local playerSpeed = GetUnitSpeed("player")
        characterRace = UnitRace("player")
        characterSex = UnitSex("player")

        UpdateDebugDisplay(playerSpeed)

        if (AzerothPacerSaved.debugMode) then
            movementTexture:Show()
        else
            movementTexture:Hide()
        end

        shapeshiftForm = GetShapeshiftForm()

        if (shapeshiftForm > 0) then
            _, _, _, shapeshiftSpellID = GetShapeshiftFormInfo(shapeshiftForm);
        else
            shapeshiftSpellID = 0
        end

        local x, y, z, instanceId = UnitPosition("player")

        local distance = 0

        distance = Utils.CalculateDistance(timeSinceLastUpdate, false, movementTexture)

        if (distance == 0) then
            return
        end

        local levitate = AuraUtil.FindAuraByName("Levitate", "player")

        if (playerSpeed >= baseRunSpeed and not Utils.IsPlayerRiding(shapeshiftSpellID) and shapeshiftSpellID ~= 783) then
            -- player is running forward
            local baseRunningStepLength = Config.raceStepLength[characterRace][tostring(characterSex)].run or
                2 -- yards

            if (characterClass == "DRUID") then
                if (shapeshiftSpellID == 768) then
                    baseRunningStepLength = 4.5
                elseif (shapeshiftSpellID == 5487) then
                    baseRunningStepLength = 5
                elseif (shapeshiftSpellID == 114282) then
                    baseRunningStepLength = 1.5
                end
            elseif characterClass == "SHAMAN" then
                if (shapeshiftForm == 1) then
                    baseRunningStepLength = 3.5
                end
            end

            if (levitate == "Levitate") then
                baseRunningStepLength = 0
            end

            accumulatedDistance = accumulatedDistance + distance

            if not isJumping then
                if accumulatedDistance >= baseRunningStepLength and baseRunningStepLength ~= 0 then
                    AzerothPacerSaved.movement.steps = AzerothPacerSaved.movement.steps + 1
                    AzerothPacerSaved.movement.walkingDistance = AzerothPacerSaved.movement.walkingDistance +
                        accumulatedDistance
                    accumulatedDistance = 0
                end
            else
                AzerothPacerSaved.movement.jumpDistance = AzerothPacerSaved.movement.jumpDistance + distance
            end
        elseif (playerSpeed == backwardRunspeed and shapeshiftSpellID ~= 783) then
            -- player is running backward
            local backwardRunningStepLength = Config.raceStepLength[characterRace][tostring(characterSex)]
                .backwardRun or
                1.1 -- yards

            if (characterClass == "DRUID") then
                if (shapeshiftSpellID == 768) then
                    backwardRunningStepLength = 1
                elseif (shapeshiftSpellID == 5487) then
                    backwardRunningStepLength = 1
                elseif (shapeshiftSpellID == 114282) then
                    backwardRunningStepLength = 1
                end
            elseif (characterClass == "SHAMAN") then
                if (shapeshiftForm == 1) then
                    backwardRunningStepLength = 0.8
                end
            end

            if (levitate == "Levitate") then
                backwardRunningStepLength = 0
            end

            accumulatedDistance = accumulatedDistance + distance

            if not isJumping and backwardRunningStepLength ~= 0 then
                if accumulatedDistance >= backwardRunningStepLength then
                    AzerothPacerSaved.movement.steps = AzerothPacerSaved.movement.steps + 1
                    AzerothPacerSaved.movement.walkingDistance = AzerothPacerSaved.movement.walkingDistance +
                        accumulatedDistance
                    accumulatedDistance = 0
                end
            else
                AzerothPacerSaved.movement.jumpDistance = AzerothPacerSaved.movement.jumpDistance + distance
            end
        elseif (playerSpeed == walkSpeed and shapeshiftSpellID ~= 783) then
            -- player is walking forward or backward
            local forwardWalkingStepLength = Config.raceStepLength[characterRace][tostring(characterSex)].walk or
                1 -- yards
            local backwardWalkingStepLength = Config.raceStepLength[characterRace][tostring(characterSex)]
                .backwardWalk or
                1 -- yards
            

            if (levitate == "Levitate") then
                forwardWalkingStepLength = 0
                backwardWalkingStepLength = 0
            end

            accumulatedDistance = accumulatedDistance + distance

            if not isJumping and forwardWalkingStepLength ~= 0 and backwardWalkingStepLength ~= 0 then
                if (isMovingBackward) then
                    if accumulatedDistance >= backwardWalkingStepLength then
                        AzerothPacerSaved.movement.steps = AzerothPacerSaved.movement.steps + 1
                        AzerothPacerSaved.movement.walkingDistance = AzerothPacerSaved.movement.walkingDistance +
                            accumulatedDistance
                        accumulatedDistance = 0
                    end
                else
                    if accumulatedDistance >= forwardWalkingStepLength then
                        AzerothPacerSaved.movement.steps = AzerothPacerSaved.movement.steps + 1
                        AzerothPacerSaved.movement.walkingDistance = AzerothPacerSaved.movement.walkingDistance +
                            accumulatedDistance
                        accumulatedDistance = 0
                    end
                end
            else
                AzerothPacerSaved.movement.jumpDistance = AzerothPacerSaved.movement.jumpDistance + distance
            end
        end

        -- update saved variables
        AzerothPacerSaved.movement.distance = AzerothPacerSaved.movement.distance + distance

        if IsPlayerSwimming() then
            AzerothPacerSaved.movement.swimmingDistance = AzerothPacerSaved.movement.swimmingDistance + distance
        end

        if Utils.IsPlayerRiding(shapeshiftSpellID) then
            AzerothPacerSaved.movement.ridingDistance = AzerothPacerSaved.movement.ridingDistance + distance
        end

        UpdateDisplay()

        timeSinceLastUpdate = 0
    end
end)


-- CONFIGURATION --
local AzerothPacerLauncher = LDB:NewDataObject("AzerothPacer", {
    type = "launcher",
    text = "AzerothPacer",
    icon = "Interface\\AddOns\\AzerothPacerClassic\\assets\\azerothpacerlogo.png", -- Choose an appropriate icon
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Toggle the addon panel
            if displayFrame:IsShown() then
                displayFrame:Hide()
            else
                displayFrame:Show()
            end
        elseif button == "RightButton" then
            AzerothPacerSaved.windowSize.isResizable = not AzerothPacerSaved.windowSize.isResizable
            if AzerothPacerSaved.windowSize.isResizable then
                resizeButton:Enable()
                AzerothPacerSaved.isMovable = true
                displayFrame:SetMovable(true)
                displayFrame:EnableMouse(true)
                if (AzerothPacerSaved.debugMode) then
                    print("Azeroth Pacer: Resizing enabled.")
                end
            else
                resizeButton:Disable()
                AzerothPacerSaved.isMovable = false
                displayFrame:SetMovable(false)
                displayFrame:EnableMouse(false)
                if (AzerothPacerSaved.debugMode) then
                    print("Azeroth Pacer: Resizing disabled.")
                end
            end
            displayFrame:SetResizable(AzerothPacerSaved.windowSize.isResizable)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("AzerothPacer")
        tooltip:AddLine("Left-click to toggle the addon panel.")
        tooltip:AddLine("Right-click to lock the addon panel.")
        if (AzerothPacerSaved.debugMode) then
            print(string.format("Azeroth Pacer: Minimap location: %d", AzerothPacerSaved.minimap.minimapPos))
        end
    end
})

-- Initialize the minimap icon
if LDBIcon then
    if (AzerothPacerSaved.debugMode) then
        print("Azeroth Pacer: Registering minimap button.")
    end
    LDBIcon:Register("AzerothPacer", AzerothPacerLauncher, AzerothPacerSaved.minimap)
    LDBIcon:Refresh("AzerothPacer", AzerothPacerSaved.minimap)
    if (AzerothPacerSaved.debugMode) then
        print(string.format("Azeroth Pacer: Initial minimap position: %.2f", AzerothPacerSaved.minimap.minimapPos or 0))
    end
else
    print("Azeroth Pacer: Failed to initialize LDBIcon.")
end

local minimapButton = LDBIcon:GetMinimapButton("AzerothPacer")
if minimapButton then
    minimapButton:HookScript("OnDragStop", function()
        local point, relativeTo, relativePoint, xOffset, yOffset = minimapButton:GetPoint()
        local angle = math.atan2(yOffset, xOffset) * (180 / math.pi)
        angle = angle < 0 and angle + 360 or angle -- Normalize to 0-360 degrees
        AzerothPacerSaved.minimap.minimapPos = angle
        if (AzerothPacerSaved.debugMode) then
            print(string.format("Azeroth Pacer: Updated minimap position: %.2f", AzerothPacerSaved.minimap.minimapPos))
        end

        -- Refresh the icon position
        LDBIcon:Refresh("AzerothPacer", AzerothPacerSaved.minimap)
    end)
else
    print("Azeroth Pacer: Failed to retrieve AzerothPacer minimap button.")
end


-- Slash commands
SLASH_AZEROTHPACER1 = '/azerothpacer'
SLASH_AZEROTHPACER2 = '/ap'

SlashCmdList["AZEROTHPACER"] = function(msg)
    if msg == 'destroy' then
        AzerothPacerSaved = {
            minimap = {
                hide = AzerothPacerSaved.minimap.hide,     -- Preserve minimap settings
                minimapPos = AzerothPacerSaved.minimapPos, -- Preserve minimap settings
            },
            debugMode = AzerothPacerSaved.debugMode,
            movement = {
                distance = 0,
                lastX = 0,
                lastY = 0,
                lastZ = 0,
                steps = 0,
                jumpDistance = 0,
                ridingDistance = 0,
                swimmingDistance = 0,
                walkingDistance = 0
            },
            windowSize = {
                width = AzerothPacerSaved.windowSize.width,
                height = AzerothPacerSaved.windowSize.height,
                debugWidth = AzerothPacerSaved.windowSize.debugWidth,
                debugHeight = AzerothPacerSaved.windowSize.debugHeight,
                isResizable = AzerothPacerSaved.windowSize.isResizable
            },
            isLocked = AzerothPacerSaved.isMovable
        }

        UpdateDisplay()
        print("AzerothPacer: All data reset.")
    elseif msg == 'total' then
        -- output
    elseif msg == 'debug' then
        AzerothPacerSaved.debugMode = not AzerothPacerSaved.debugMode

        -- resize the frame to default debug size
        if AzerothPacerSaved.debugMode then
            displayFrame:SetSize(AzerothPacerSaved.windowSize.debugWidth, AzerothPacerSaved.windowSize.debugHeight)
        else
            displayFrame:SetSize(AzerothPacerSaved.windowSize.width, AzerothPacerSaved.windowSize.height)
        end

        print(string.format("Azeroth Pacer: Debug mode %s.", AzerothPacerSaved.debugMode and "enabled" or "disabled"))

    -- else if message starts with spell split the message and get the spell id which is 2nd part of the message
    elseif string.match(msg, "spell") then
        local _, spellID = strsplit(" ", msg)
        if spellID then
            spellID = tonumber(spellID)
            if (AzerothPacerSaved.debugMode and spellID) then
                local spell = Spell:CreateFromSpellID(spellID)
                if spell then
                    spell:ContinueOnSpellLoad(function()
                        local name = spell:GetSpellName()
                        print(name)
                    end)
                end
            end
        end
    else
        -- output
    end
end
