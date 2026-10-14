local discovered = {}
local visible = {}
local sent = false

local function reach(island)
    return island.distance or Config.Render.MaxDistance
end

local function alphaFor(island, distance)
    local render = Config.Render
    local far = reach(island)

    if distance > far then return 0.0 end

    if distance < render.HideWithin then return 0.0 end

    local fadingOut = render.HideWithin + render.FadeOutOver
    if distance < fadingOut then
        return (distance - render.HideWithin) / render.FadeOutOver
    end

    local fadingIn = far - render.FadeInOver
    if distance > fadingIn then
        return (far - distance) / render.FadeInOver
    end

    return 1.0
end

local function scaleFor(island, distance)
    local render = Config.Render
    local span = math.max(reach(island) - render.HideWithin, 1.0)
    local along = math.min(math.max((distance - render.HideWithin) / span, 0.0), 1.0)

    return render.ScaleNear + (render.ScaleFar - render.ScaleNear) * along
end

local function formatDistance(metres)
    if metres >= 1000.0 then return ('%.1fKM'):format(metres / 1000.0) end
    return ('%dM'):format(math.floor(metres))
end

local function project(x, y, z)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)
    if not onScreen then return nil end

    return screenX, screenY
end

local function payloadFor(island, distance, alpha)
    local coords = island.coords
    local top = coords.z + (island.height or 150.0)

    local x, y = project(coords.x, coords.y, top)
    if not x then return nil end

    local groundX, groundY

    if Config.Render.Beam then
        groundX, groundY = project(coords.x, coords.y, coords.z - (island.beamDrop or 0.0))
    end

    return {
        id = island.id,
        name = island.name:upper(),
        subtitle = island.subtitle and island.subtitle:upper() or nil,
        distance = formatDistance(distance),
        colour = island.colour or Config.Colour,
        x = x,
        y = y,
        gx = groundX,
        gy = groundY,
        alpha = alpha,
        scale = scaleFor(island, distance),
    }
end

local function announce(island, distance)
    if discovered[island.id] then return end
    if distance > Config.Discovery.Distance then return end

    discovered[island.id] = true

    TriggerEvent('SeaM_Islands:client:discovered', island.id, island.name)
end

CreateThread(function()
    local idle = math.max(Config.Render.IdleInterval, 1) * 1000

    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local found = {}

        for _, island in ipairs(Config.Islands) do
            local distance = #(coords - island.coords)

            if distance <= reach(island) then
                announce(island, distance)

                local alpha = alphaFor(island, distance)
                if alpha > 0.0 then
                    found[#found + 1] = { island = island, distance = distance, alpha = alpha }
                end
            end
        end

        table.sort(found, function(a, b) return a.distance < b.distance end)

        while #found > Config.Render.MaxVisible do table.remove(found) end

        local entering = #visible == 0 and #found > 0
        local leaving = #visible > 0 and #found == 0
        visible = found

        if entering then TriggerEvent('SeaM_Islands:client:entered') end
        if leaving then TriggerEvent('SeaM_Islands:client:left') end

        local payload = {}

        for _, entry in ipairs(visible) do
            local marker = payloadFor(entry.island, entry.distance, entry.alpha)
            if marker then payload[#payload + 1] = marker end
        end

        if #payload > 0 or sent then
            SendNUIMessage({ action = 'islands', data = payload })
            sent = #payload > 0
        end

        Wait(#visible > 0 and 0 or idle)
    end
end)

RegisterCommand('islands', function()
    local coords = GetEntityCoords(PlayerPedId())

    print(('[SeaM_Islands] vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
    print(('[SeaM_Islands] --- %d island(s) ---'):format(#Config.Islands))

    for _, island in ipairs(Config.Islands) do
        local distance = #(coords - island.coords)

        print(('[SeaM_Islands]   %-16s %-18s %9s  %s'):format(
            island.id, island.name, formatDistance(distance),
            distance <= reach(island) and 'in range' or 'out of range'))
    end
end, false)

exports('GetVisible', function()
    local out = {}
    for _, entry in ipairs(visible) do
        out[#out + 1] = { id = entry.island.id, name = entry.island.name, distance = entry.distance }
    end
    return out
end)

exports('GetNearest', function()
    local coords = GetEntityCoords(PlayerPedId())
    local best, bestDistance

    for _, island in ipairs(Config.Islands) do
        local distance = #(coords - island.coords)
        if not bestDistance or distance < bestDistance then best, bestDistance = island, distance end
    end

    if not best then return nil end
    return best.id, best.name, bestDistance
end)

exports('IsDiscovered', function(id) return discovered[id] == true end)
