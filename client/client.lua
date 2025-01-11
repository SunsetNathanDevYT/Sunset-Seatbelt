local isSeatbeltOn = false
local isFlashing = false
local warningSoundPlaying = false
local prevSpeed = 0

-- Seatbelt sounds
local sounds = {
    buckle = "buckle",
    unbuckle = "unbuckle",
    warning = "warning"
}

-- Animation dictionary
local animDict = "anim@mp_player_intmenu@key_fob@"

-- Helper function to load animation dictionaries
local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(100)
    end
end

-- Play warning sound (looped while moving without a seatbelt)
local function playWarningSound()
    if not warningSoundPlaying then
        warningSoundPlaying = true
        SendNUIMessage({ action = "playLoopedWarning" })
    end
end

-- Stop warning sound
local function stopWarningSound()
    if warningSoundPlaying then
        warningSoundPlaying = false
        SendNUIMessage({ action = "stopLoopedWarning" })
    end
end

-- Toggle seatbelt function
local function toggleSeatbelt()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 and not IsThisModelABike(GetEntityModel(veh)) then
        isSeatbeltOn = not isSeatbeltOn

        -- Play animations and sounds
        loadAnimDict(animDict)
        TaskPlayAnim(ped, animDict, "fob_click", 8.0, 1.0, 1000, 49, 0, false, false, false)

        TriggerEvent("seatbelt:playSound", isSeatbeltOn and sounds.buckle or sounds.unbuckle)

        -- Update the NUI to hide or show the UI
        SendNUIMessage({
            action = isSeatbeltOn and 'hideUI' or 'showUI' -- Hide UI when seatbelt is on
        })

        if isSeatbeltOn then
            stopWarningSound() -- Stop warning sound if seatbelt is buckled
        end
    end
end

-- Keybinding for seatbelt toggle
RegisterCommand('toggleSeatbelt', toggleSeatbelt, false)
RegisterKeyMapping('toggleSeatbelt', 'Toggle Seatbelt', 'keyboard', 'Y')

-- Event to play sounds
RegisterNetEvent("seatbelt:playSound")
AddEventHandler("seatbelt:playSound", function(sound)
    SendNUIMessage({
        action = 'playSound',
        sound = sound
    })
end)

-- Monitor vehicle state, speed, and UI visibility
CreateThread(function()
    local wasInVehicle = false

    while true do
        Wait(100)

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 then
            -- Player has entered a vehicle
            if not wasInVehicle then
                wasInVehicle = true
                local isBike = IsThisModelABike(GetEntityModel(veh))

                if not isBike then
                    -- Show UI when entering a vehicle (but not for bikes or motorcycles)
                    SendNUIMessage({ action = 'showUI' })
                end
            end

            -- Determine if the vehicle is a motorcycle or bicycle
            local isBike = IsThisModelABike(GetEntityModel(veh))

            if not isBike then
                -- Flash warning UI and play sound if seatbelt is off and speed exceeds limit
                local speed = GetEntitySpeed(veh) * 3.6 -- Convert m/s to km/h
                if not isSeatbeltOn and speed > Config.WarningSpeed then
                    if not isFlashing then
                        isFlashing = true
                        SendNUIMessage({ action = 'flashWarning' })
                    end
                    playWarningSound()
                else
                    if isFlashing then
                        isFlashing = false
                        SendNUIMessage({ action = 'stopWarning' })
                    end
                    stopWarningSound()
                end

                -- Handle ejection logic for crashes
                if not isSeatbeltOn and (prevSpeed - speed) > Config.MinImpactSpeed then
                    if math.random() < Config.EjectionChance then
                        local coords = GetEntityCoords(veh)
                        SetEntityCoords(ped, coords.x, coords.y, coords.z - 1.0)
                        SetEntityVelocity(ped, prevSpeed * 0.5, 0, 0)
                    end
                end

                prevSpeed = speed
            else
                -- Hide UI and stop warning for bicycles or motorcycles
                SendNUIMessage({ action = 'hideUI' })
                stopWarningSound()
            end
        else
            -- Player is not in a vehicle
            if wasInVehicle then
                wasInVehicle = false
                -- Hide UI when leaving the vehicle
                SendNUIMessage({ action = 'hideUI' })
                isFlashing = false
                prevSpeed = 0
                stopWarningSound()
            end
        end
    end
end)

-- Prevent exiting the vehicle if the seatbelt is on
CreateThread(function()
    while true do
        Wait(0) -- Run every frame

        if isSeatbeltOn then
            local ped = PlayerPedId()
            if IsControlJustPressed(0, 75) then -- Detect exit attempt
                DisableControlAction(0, 75, true) -- Disable the 'exit vehicle' key
                DisableControlAction(27, 75, true) -- Disable for controller as well

                -- Notify the player
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("You cannot exit the vehicle while your seatbelt is on.")
                EndTextCommandDisplayHelp(0, false, true, 2000)
            end
        end
    end
end)
