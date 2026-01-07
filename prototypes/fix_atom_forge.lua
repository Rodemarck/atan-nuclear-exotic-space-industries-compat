-- prototypes/fix_atom_forge.lua
-- Adjusts Atom Forge recipe, research cost and prerequisites.
local h = require("prototypes.nuclear_helpers")

--------------------------------------------------
-- Detect recipe name (Atom Forge)
--------------------------------------------------

local candidates = {"atan-atom-forge", -- ATAN-style name
"ei_atom-forge", "atom-forge", "ei-atom-forge"}

local recipe_name = nil

for _, name in pairs(candidates) do
    if data.raw.recipe[name] then
        recipe_name = name
        break
    end
end

if not recipe_name then
    log(
        "[ATOM FORGE FIX] Atom Forge recipe not found (checked atan-atom-forge / ei_atom-forge / atom-forge / ei-atom-forge)")
    return
end

local recipe = data.raw.recipe[recipe_name]

--------------------------------------------------
-- 1) Apply your new custom recipe ingredients
--    Using DICTIONARY style for RECIPE ingredients
--------------------------------------------------

local function apply_atom_forge_ingredients(target)
    target.enabled = false
    target.ingredients = {{
        type = "item",
        name = "ei-uranium-test-fuel",
        amount = 50
    }, {
        type = "item",
        name = "ei-fission-facility",
        amount = 200
    }, {
        type = "item",
        name = "ei-energy-crystal",
        amount = 400
    }, {
        type = "item",
        name = "ei-fission-tech",
        amount = 100
    }, {
        type = "item",
        name = "ei-steel-beam",
        amount = 100
    }, {
        type = "item",
        name = "steel-plate",
        amount = 300
    }, {
        type = "item",
        name = "centrifuge",
        amount = 4
    } -- 4 centrífugas
    }
end

if recipe.normal or recipe.expensive then
    recipe.normal = recipe.normal or {}
    recipe.expensive = recipe.expensive or {}

    apply_atom_forge_ingredients(recipe.normal)
    apply_atom_forge_ingredients(recipe.expensive)
else
    apply_atom_forge_ingredients(recipe)
end

log("[ATOM FORGE FIX] Updated Atom Forge recipe for: " .. recipe_name)

--------------------------------------------------
-- 2) Locate the technology that unlocks Atom Forge
--------------------------------------------------

local atom_forge_tech = nil

for _, tech in pairs(data.raw.technology) do
    if tech.effects then
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                atom_forge_tech = tech
                break
            end
        end
    end
    if atom_forge_tech then
        break
    end
end

if not atom_forge_tech then
    log("[ATOM FORGE FIX] No technology found that unlocks Atom Forge recipe: " .. recipe_name)
    return
end

--------------------------------------------------
-- 3) Reset prerequisites: keep ONLY nuclear-science-pack
--------------------------------------------------

atom_forge_tech.prerequisites = {}

if data.raw.technology["nuclear-science-pack"] then
    h.ensure_prereq(atom_forge_tech, "nuclear-science-pack")
    log("[ATOM FORGE FIX] Atom Forge tech prerequisites set to only nuclear-science-pack")
else
    log("[ATOM FORGE FIX] nuclear-science-pack technology not found, no prerequisites set for Atom Forge tech")
end

--------------------------------------------------
-- 4) Update the research ingredients (tech cost)
--    Using LIST style for TECHNOLOGY ingredients
--------------------------------------------------

atom_forge_tech.unit = atom_forge_tech.unit or {}

atom_forge_tech.unit.ingredients = {{"ei-dark-age-tech", 1}, {"ei-steam-age-tech", 1}, {"ei-electricity-age-tech", 1},
                                    {"nuclear-science-pack", 1}}

log("[ATOM FORGE FIX] Updated Atom Forge tech research ingredients for: " .. atom_forge_tech.name)

--------------------------------------------------
-- Done
--------------------------------------------------

log("[ATOM FORGE FIX] Atom Forge tech update complete (recipe + cost + prereqs)")
