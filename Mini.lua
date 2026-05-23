-- ===================================================================
-- MINI WAR CLOUD-BYPASS (ORIGINAL RESTRUCTURED)
-- Features: Remote Crop Auto-Harvest + Instant Time Flattening (Zero-Clock)
-- Instructions: Run script, place building, wait for timer to hit 0, then re-log!
-- ===================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local MiniWarBypass = {
    Interval = 0.4,
    TargetTime = 0
}

-- 1. UNIVERSAL CROP AND HARVEST COLLECTOR
local function autoHarvestCrops()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            -- Simulate clicking the floating crop/harvest icons natively
            if obj:IsA("ClickDetector") then
                local parentName = string.lower(obj.Parent.Name)
                if string.find(parentName, "farm") or string.find(parentName, "crop") or string.find(parentName, "harvest") or string.find(parentName, "resource") or string.find(parentName, "collect") or string.find(parentName, "mine") then
                    fireclickdetector(obj, 0)
                end
            end
            
            -- Trigger ProximityPrompts for gathering systems
            if obj:IsA("ProximityPrompt") then
                local promptName = string.lower(obj.ObjectText or obj.ActionText)
                if string.find(promptName, "harvest") or string.find(promptName, "collect") or string.find(promptName, "gather") or string.find(promptName, "claim") then
                    obj:InputHoldBegin()
                    task.wait()
                    obj:InputHoldEnd()
                end
            end
        end
    end)
end

-- 2. INSTANT TIME FLATTENING ENGINE (FORCES ZERO UNTIL RE-LOG)
local function runTimeFlattener()
    pcall(function()
        -- Target all attributes managing build times
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") then
                local attributes = model:GetAttributes()
                for name, value in pairs(attributes) do
                    local nameLower = string.lower(name)
                    if type(value) == "number" and value > 0 then
                        if string.find(nameLower, "time") or string.find(nameLower, "duration") or string.find(nameLower, "build") or string.find(nameLower, "progress") or string.find(nameLower, "cooldown") then
                            model:SetAttribute(name, MiniWarBypass.TargetTime)
                        end
                    end
                end
                
                -- Target Int/Number instances inside the building models
                for _, child in ipairs(model:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local childName = string.lower(child.Name)
                        if string.find(childName, "time") or string.find(childName, "timer") or string.find(childName, "duration") or string.find(childName, "remaining") then
                            child.Value = MiniWarBypass.TargetTime
                        end
                    end
                end
            end
        end
        
        -- Target table variables via Garbage Collector
        local garbage = getgc(true)
        for _, t in ipairs(garbage) do
            if type(t) == "table" then
                for k, v in pairs(t) do
                    if type(k) == "string" and type(v) == "number" and v > 0 then
                        local keyLower = string.lower(k)
                        if string.find(keyLower, "timer") or string.find(keyLower, "buildtime") or string.find(keyLower, "cooldown") or string.find(keyLower, "remaining") then
                            t[k] = MiniWarBypass.TargetTime
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- NATIVE BACKGROUND RUNTIME
-- ===================================================================
task.spawn(function()
    print("[RGG Mini War Cloud-Bypass] Original speed-run method loaded successfully.")
    while true do
        autoHarvestCrops()
        runTimeFlattener()
        task.wait(MiniWarBypass.Interval)
    end
end)
