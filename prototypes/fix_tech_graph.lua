-- prototypes/fix_tech_graph.lua
-- Global cleanup of nuclear science usage and uranium-processing behavior.

local h = require("prototypes.nuclear_helpers")
local nuclear_pack = h.nuclear_pack

local uranium = data.raw.technology["uranium-processing"]

local pack = data.raw.technology["nuclear-science-pack"]

if not uranium then
    log("[NUCLEAR FIX][GRAPH] uranium-processing not found!")
    return
end

-- 1) Iterate over ALL technologies and clean invalid nuclear-science usage
for tech_name, tech in pairs(data.raw.technology) do
    if h.tech_uses_pack(tech, nuclear_pack) then

        -- Only remove nuclear science if:
        --  - tech uses nuclear science
        --  - tech does NOT require nuclear science
        --  - tech does NOT depend on uranium-processing
        --  - tech is NOT uranium-processing itself
        if not h.has_prereq(tech, nuclear_pack)
            and not h.tech_depends_on(tech_name, "uranium-processing")
            and tech_name ~= "uranium-processing"
        then
            local removed = h.remove_science_pack(tech, nuclear_pack)
            if removed then
                log("[NUCLEAR FIX][GRAPH] Removed nuclear-science-pack from " .. tech_name)
            end
        end
    end
end

-- 2) Special handling for uranium-processing
-- It must ALWAYS come before nuclear science.
local removed_up = h.remove_science_pack(uranium, nuclear_pack)

if removed_up then
    log("[NUCLEAR FIX][GRAPH] Removed nuclear-science-pack from uranium-processing (ingredients)")
end

if h.has_prereq(uranium, nuclear_pack) then
    h.remove_prereq(uranium, nuclear_pack)
    log("[NUCLEAR FIX][GRAPH] Removed nuclear-science-pack as prerequisite of uranium-processing")
end

if pack and pack.unit and pack.unit.ingredients then
  -- remove auto-loop
  local removed_self = h.remove_science_pack(pack, nuclear_pack)
  if removed_self then
    log("[NUCLEAR FIX][EI] Removed nuclear-science-pack from nuclear-science-pack (ingredients)")
  end

  h.ensure_science_pack(pack, "ei-dark-age-tech")
  h.ensure_science_pack(pack, "ei-steam-age-tech")
  log("[NUCLEAR FIX][EI] Ensured EI packs in nuclear-science-pack tech: dark + steam")

  if h.has_prereq(pack, nuclear_pack) then
    h.remove_prereq(pack, nuclear_pack)
    log("[NUCLEAR FIX][EI] Removed nuclear-science-pack as prerequisite of nuclear-science-pack")
  end
else
  log("[NUCLEAR FIX][EI] nuclear-science-pack tech missing or has no unit.ingredients")
end