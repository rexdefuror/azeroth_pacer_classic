Utils = Utils or {}
Utils.rows = {} -- Table to keep track of created rows

function Utils.CreateRow(parent, labelText, valueText, offsetX, offsetY, displayFrameWidth)
    local rowFrame = CreateFrame("Frame", nil, parent)
    rowFrame:SetSize(displayFrameWidth - 40, 12) -- Adjust width and height
    rowFrame:SetPoint("TOPLEFT", offsetX, offsetY)

    local label = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", 10, 0)
    label:SetText(labelText)
    label:SetTextHeight(12)

    local value = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    value:SetPoint("RIGHT", 0, 0)
    value:SetText(valueText)
    value:SetTextHeight(12)

    -- Add row to the tracking table
    table.insert(Utils.rows, { rowFrame = rowFrame, label = label, value = value })

    return rowFrame, value
end

function Utils.AdjustRowsWidth(newWidth)
    for _, row in ipairs(Utils.rows) do
        row.rowFrame:SetWidth(newWidth - 40) -- Adjust width dynamically
    end
end

function Utils.IsPlayerRiding(shapeshift)
    local isRiding = IsMounted() or shapeshift == 783 or shapeshift == 210053
    return isRiding
end

function Utils.IsDragonriding()
    return UnitPowerBarID("player") == 631
end

-- facing
-- 0 = Forward
-- 1 = BackwardRun
-- 2 = Walk
function Utils.CalculatePlayerFacing(playerSpeed)
    if playerSpeed >= 7 or Utils.IsDragonriding() then
        -- Player is moving forward
        print("Player is moving forward")
        return 0
    elseif playerSpeed == 4.5 then
        print("Player is moving backward")
        -- Player is moving backward
        return 1
    elseif playerSpeed == 2.5 then
        -- player is walking
        print("Player is walking")
        return 2
    end
end

function Utils.UpdateArrowRotation(dx, dy, facingAngle, movementTexture)
    -- Calculate movement direction angle
    local movementAngle = math.atan2(dy, dx)

    -- Player's facing direction

    if movementAngle and facingAngle then
        -- Calculate relative movement angle
        local relativeAngle = movementAngle - facingAngle

        -- Normalize to range -π to π
        relativeAngle = math.atan2(math.sin(relativeAngle), math.cos(relativeAngle))

        -- Rotate the arrow texture
        if movementTexture then
            movementTexture:SetRotation(relativeAngle)
        end

        -- Debug log
        -- print(string.format("Movement Angle: %.2f, Facing Angle: %.2f, Relative Angle: %.2f", movementAngle, facingAngle, relativeAngle))
    end
end

local lastPosition = { x = 0, y = 0, z = 0, instanceId = 0 }

function Utils.CalculateDistance(elapsed, movementTexture, isFlying)
    local playerSpeed = GetUnitSpeed("player")
    local distance = 0
    local x, y, z, instanceId = UnitPosition("player")

    if isFlying and x and y and z and instanceId then
        local facing = GetPlayerFacing()
        -- Use UnitPosition when available
        if lastPosition.x and lastPosition.instanceId == instanceId then
            local dx = x - lastPosition.x
            local dy = y - lastPosition.y
            local dz = z - lastPosition.z
            distance = math.sqrt(dx * dx + dy * dy + dz * dz)

            if AzerothPacerSaved.debugMode then
                Utils.UpdateArrowRotation(dx, dy, facing, movementTexture)
            end
        end

        -- Save position for next update
        lastPosition.x = x
        lastPosition.y = y
        lastPosition.z = z
        lastPosition.instanceId = instanceId
    else
        distance = playerSpeed * elapsed
    end

    return distance
end
