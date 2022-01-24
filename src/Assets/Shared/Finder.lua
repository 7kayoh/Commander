export type Condition = (index: any, object: Instance) -> (boolean)
export type Behavior = (result: {Instance}) -> ()

local Finder = { Templates = {} }

local function dummyTemplate(): boolean
    return false
end

function Finder.find(target: {Instance}, condition: Condition, behavior: Behavior?): {Instance}|any?
    local result = {}
    for index: any, value: Instance in pairs(target) do
        local status: boolean, response: boolean|string = pcall(condition, index, value)
        if status and response then
            result[index] = value
        elseif not status then
            warn("Finder can not perform find on object " .. value:GetFullName() .. " due to " .. tostring(response))
        end
    end

    if behavior then
        return behavior(result)
    else
        return result
    end
end

function Finder.addTemplate(category: string, name: string, condition: Condition): boolean
    if not Finder.Templates[category] then
        Finder.Templates[category] = {}
    end

    if Finder.Templates[category][name] then
        warn("This Finder template already exists: " .. name)
        return false
    else
        Finder.Templates[category][name] = condition
        return true
    end
end

function Finder.getTemplate(category: string, name: string): Condition|boolean
    if not Finder.Templates[category] then
        warn("Category " .. category .. " does not exist")
        return dummyTemplate
    end
    if not Finder.Templates[category][name] then
        warn("Condition " .. name .. " does not exist in category " .. category)
        return dummyTemplate
    end

    return Finder.Templates[category][name]
end

return Finder