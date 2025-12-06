-- prototypes/nuclear_helpers.lua
-- Common reusable helper functions for nuclear tech adjustments.

local nuclear_pack = "nuclear-science-pack"

local helpers = {}

helpers.nuclear_pack = nuclear_pack

-- Returns true if a technology uses a specific science pack.
function helpers.tech_uses_pack(tech, pack)
    if not tech or not tech.unit or not tech.unit.ingredients then
        return false
    end
    for _, ingr in pairs(tech.unit.ingredients) do
        local name = ingr.name or ingr[1]
        if name == pack then return true end
    end
    return false
end

-- Removes a specific science pack from a tech's ingredient list.
function helpers.remove_science_pack(tech, pack)
    if not tech or not tech.unit or not tech.unit.ingredients then
        return false
    end

    local new = {}
    local removed = false

    for _, ingr in pairs(tech.unit.ingredients) do
        local name = ingr.name or ingr[1]
        if name ~= pack then
            table.insert(new, ingr)
        else
            removed = true
        end
    end

    tech.unit.ingredients = new
    return removed
end

-- Checks if a technology already has the given prerequisite.
function helpers.has_prereq(tech, prereq)
    if not tech or not tech.prerequisites then return false end
    for _, p in ipairs(tech.prerequisites) do
        if p == prereq then return true end
    end
    return false
end

-- Ensures a prerequisite exists for a technology.
function helpers.ensure_prereq(tech, prereq_name)
    if not tech then return end
    tech.prerequisites = tech.prerequisites or {}
    for _, p in ipairs(tech.prerequisites) do
        if p == prereq_name then return end
    end
    table.insert(tech.prerequisites, prereq_name)
end

-- Removes a prerequisite from a technology if present.
function helpers.remove_prereq(tech, prereq_name)
    if not tech or not tech.prerequisites then return end
    local new = {}
    for _, p in ipairs(tech.prerequisites) do
        if p ~= prereq_name then table.insert(new, p) end
    end
    tech.prerequisites = new
end

-- Ensures that a science pack is in the ingredient list.
function helpers.ensure_science_pack(tech, pack_name)
    if not tech or not tech.unit or not tech.unit.ingredients then return end

    for _, ingr in pairs(tech.unit.ingredients) do
        local name = ingr.name or ingr[1]
        if name == pack_name then return end
    end

    table.insert(tech.unit.ingredients, {pack_name, 1})
end

-- Recursively checks if tech_name depends on target_name (directly or indirectly).
-- Prevents cyclic graphs.
function helpers.tech_depends_on(tech_name, target_name, visited)
    visited = visited or {}

    if tech_name == target_name then return true end
    if visited[tech_name] then return false end

    visited[tech_name] = true
    local tech = data.raw.technology[tech_name]

    if not tech or not tech.prerequisites then return false end

    for _, prereq_name in ipairs(tech.prerequisites) do
        if prereq_name == target_name then return true end
        if helpers.tech_depends_on(prereq_name, target_name, visited) then return true end
    end

    return false
end

return helpers