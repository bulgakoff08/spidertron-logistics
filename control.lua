local NONE = "none"
local WALKING_TO_LOAD = "walkingToLoad"
local WALKING_TO_UNLOAD = "walkingToUnload"
local WAITING_LOAD = "waitingLoad"
local WAITING_UNLOAD = "waitingUnload"
local FINISHED_LOAD = "finishedLoad"
local FINISHED_UNLOAD = "finishedUnload"

local MIN_DISTANCE_TO_STATION = 5
local TICK_UPDATE_INTERVAL = 120
local TIMER_SECONDS_VALUE = 10

local function getSpidertronNetworkLetter (entity)
    if entity and entity.valid and entity.grid then
        local equipmentList = entity.grid.equipment
        for _, equipment in pairs(equipmentList) do
            local name = equipment.name
            if string.sub(name, 1, 24) == "sl-navigation-equipment-" then
                return string.sub(name, 25, 25)
            end
        end
    end
end

local function getSpidertronIdleTime (entity)
    local idleTime = TIMER_SECONDS_VALUE
    if entity and entity.valid and entity.grid then
        local equipmentList = entity.grid.equipment
        for _, equipment in pairs(equipmentList) do
            if equipment.name == "sl-timer-equipment" then
                idleTime = idleTime + TIMER_SECONDS_VALUE
            end
        end
    end
    return idleTime
end

local function changeLogisticRequests (entity, state)
    if entity and entity.valid then
        local logistic = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
        if logistic then
            local sections = logistic.sections
            if sections then
                for _, section in pairs(sections) do
                    section.active = state
                end
            end
        end
    end
end

local function changeTrashPolicy (entity, state)
    if entity and entity.valid then
        local logistic = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
        if logistic then
            logistic.trash_not_requested = state
        end
    end
end

local function sendSpidertronToLoad (spidertron, loadZone)
    if spidertron.entity and spidertron.entity.valid and loadZone and loadZone.valid then
        spidertron.state = WALKING_TO_LOAD
        spidertron.entity.autopilot_destination = loadZone.position
    end
end

local function sendSpidertronToUnload (spidertron, dropZone)
    if spidertron.entity and spidertron.entity.valid and dropZone and dropZone.valid then
        spidertron.state = WALKING_TO_UNLOAD
        spidertron.entity.autopilot_destination = dropZone.position
    end
end

local function stopSpidertron (spidertron)
    if spidertron.entity and spidertron.entity.valid then
        spidertron.state = NONE
        spidertron.entity.autopilot_destination = nil
    end
end

local function updateIdleTimer (spidertron)
    spidertron.idleTime = spidertron.idleTime + (TICK_UPDATE_INTERVAL / 60)
    local idleThreshold = getSpidertronIdleTime(spidertron.entity)
    if spidertron.idleTime > idleThreshold then
        spidertron.idleTime = 0
        if spidertron.state == WAITING_LOAD then
            spidertron.state = FINISHED_LOAD
        end
        if spidertron.state == WAITING_UNLOAD then
            spidertron.state = FINISHED_UNLOAD
        end
    end
end

local function isSpidertronNear (spidertron, zoneEntity)
    if spidertron.entity and spidertron.entity.valid and zoneEntity and zoneEntity.valid then
        local spiderPos = spidertron.entity.position
        local zonePos = zoneEntity.position
        local dx = spiderPos.x - zonePos.x
        local dy = spiderPos.y - zonePos.y
        local distance = math.sqrt(dx * dx + dy * dy)
        return distance <= MIN_DISTANCE_TO_STATION
    end
    return false
end


local function serveSpidertron (spidertron, surface)
    local letter = getSpidertronNetworkLetter(spidertron.entity)
    if letter then
        local dropZone = surface.dropZones[letter]
        local loadZone = surface.loadZones[letter]
        if spidertron.state == NONE then
            sendSpidertronToLoad(spidertron, loadZone)
            return
        end
        if spidertron.state == WALKING_TO_LOAD then
            if not loadZone then
                stopSpidertron(spidertron)
                return
            end
            if isSpidertronNear(spidertron, loadZone) then
                spidertron.state = WAITING_LOAD
                changeTrashPolicy(spidertron.entity, false)
                changeLogisticRequests(spidertron.entity, true)
                updateIdleTimer(spidertron)
            end
            return
        end
        if spidertron.state == WAITING_LOAD then
            updateIdleTimer(spidertron)
            return
        end
        if spidertron.state == FINISHED_LOAD then
            sendSpidertronToUnload(spidertron, dropZone)
            return
        end
        if spidertron.state == WALKING_TO_UNLOAD then
            if not dropZone then
                stopSpidertron(spidertron)
                return
            end
            if isSpidertronNear(spidertron, dropZone) then
                spidertron.state = WAITING_UNLOAD
                changeTrashPolicy(spidertron.entity, true)
                changeLogisticRequests(spidertron.entity, false)
                updateIdleTimer(spidertron)
            end
            return
        end
        if spidertron.state == WAITING_UNLOAD then
            updateIdleTimer(spidertron)
            return
        end
        if spidertron.state == FINISHED_UNLOAD then
            sendSpidertronToLoad(spidertron, loadZone)
            return
        end
    else
        spidertron.state = NONE
    end
end

script.on_nth_tick(TICK_UPDATE_INTERVAL, function()
    if storage.surfaces == nil then
        return
    end
    for _, surface in pairs(storage.surfaces) do
        for _, spidertron in pairs(surface.spidertrons) do
            serveSpidertron(spidertron, surface)
        end
    end
end)

local function getDropzoneLetter (entity)
    if string.sub(entity.name, 1, 13) == "sl-drop-zone-" then
        return string.sub(entity.name, 14, 15)
    end
end

local function getLoadZoneLetter (entity)
    if string.sub(entity.name, 1, 13) == "sl-load-zone-" then
        return string.sub(entity.name, 14, 15)
    end
end

local function isEntitySpidertron (entity)
    return entity.type == "spider-vehicle"
end

local function isWatchable (entity)
    return getDropzoneLetter(entity) or getLoadZoneLetter(entity) or isEntitySpidertron(entity)
end

local function entityPlacementHandler (entity)
    if entity ~= nil and entity.valid and isWatchable(entity) then
        local surfaceIndex = entity.surface.index
        if storage.surfaces == nil then
            storage.surfaces = {}
        end
        if storage.surfaces[surfaceIndex] == nil then
            storage.surfaces[surfaceIndex] = {
                spidertrons = {},
                dropZones = {},
                loadZones = {}
            }
        end
        local letter = getDropzoneLetter(entity)
        if letter ~= nil then
            storage.surfaces[surfaceIndex].dropZones[letter] = entity
            return
        end
        letter = getLoadZoneLetter(entity)
        if letter ~= nil then
            storage.surfaces[surfaceIndex].loadZones[letter] = entity
            return
        end
        if isEntitySpidertron(entity) then
            table.insert(storage.surfaces[surfaceIndex].spidertrons, {state = NONE, idleTime = 0, entity = entity})
            return
        end
    end
end

script.on_event(defines.events.on_built_entity, function(event) entityPlacementHandler(event.entity) end)
script.on_event(defines.events.on_robot_built_entity, function(event) entityPlacementHandler(event.entity) end)
script.on_event(defines.events.on_entity_cloned, function(event) entityPlacementHandler(event.destination) end)
script.on_event(defines.events.on_space_platform_built_entity, function(event) entityPlacementHandler(event.entity) end)
script.on_event(defines.events.script_raised_built, function(event) entityPlacementHandler(event.entity) end)
script.on_event(defines.events.script_raised_revive, function(event) entityPlacementHandler(event.entity) end)

local function removeSpidertronFromIndex (spidertrons, entity)
    if spidertrons then
        for counter = 1, #spidertrons do
            if spidertrons[counter].entity == entity then
                table.remove(spidertrons, counter)
                return
            end
        end
    end
end

local function entityRemovalHandler (event)
    if event.entity and event.entity.valid and isWatchable(event.entity) then
        local surfaceIndex = event.entity.surface.index
        if storage.surfaces == nil then
            return
        end
        if storage.surfaces[surfaceIndex] == nil then
            return
        end
        local letter = getDropzoneLetter(event.entity)
        if letter ~= nil then
            storage.surfaces[surfaceIndex].dropZones[letter] = nil
            return
        end
        letter = getLoadZoneLetter(event.entity)
        if letter ~= nil then
            storage.surfaces[surfaceIndex].loadZones[letter] = nil
            return
        end
        if isEntitySpidertron(event.entity) then
            removeSpidertronFromIndex(storage.surfaces[surfaceIndex].spidertrons, event.entity)
            return
        end
    end
end

script.on_event({
    defines.events.on_entity_died,
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_space_platform_mined_entity
}, entityRemovalHandler)