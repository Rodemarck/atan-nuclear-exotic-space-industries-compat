-- prototypes/fix_tech_dependency.lua
-- Forces specific technologies to require nuclear-science-pack properly.

local h = require("prototypes.nuclear_helpers")
local nuclear_pack = h.nuclear_pack

-- uranium-ammo
do
    local tech = data.raw.technology["uranium-ammo"]
    if tech then
        h.ensure_prereq(tech, nuclear_pack)
        h.ensure_science_pack(tech, nuclear_pack)
        log("[NUCLEAR FIX][DEP] uranium-ammo now requires nuclear-science-pack (prereq + ingredient)")
    else
        log("[NUCLEAR FIX][DEP] uranium-ammo not found")
    end
end

-- kovarex-enrichment-process
do
    local tech = data.raw.technology["kovarex-enrichment-process"]
    if tech then
        h.ensure_prereq(tech, nuclear_pack)
        h.ensure_science_pack(tech, nuclear_pack)
        log("[NUCLEAR FIX][DEP] kovarex-enrichment-process now requires nuclear-science-pack (prereq + ingredient)")
    else
        log("[NUCLEAR FIX][DEP] kovarex-enrichment-process not found")
    end
end