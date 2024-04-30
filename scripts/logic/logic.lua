function has(item)
    local count = Tracker:ProviderCountForCode(item)
    return count > 0
end

-- LAKE ACCESS:
-- lake key, *or* Front + Office Elevator + Office
function has_lake_access()
    return has("LakeKey") or (has("FrontKey") and has("OfficeKey") and has("OfficeElKey"))
end

-- LOBBY ACCESS:
-- Front Door key, *or* Lake + Office Elevator + Office keys
function has_lobby_access()
    return has("FrontKey") or lobby_from_lake()
end
function lobby_from_lake()
    return has("LakeKey") and has("OfficeElKey") and has("OfficeKey")
end

-- OFFICE ACCESS:
-- from lobby: Office key
-- from lake: Lake key + Office Elevator key
function has_office_access()
    return office_from_lobby() or office_from_lake()
end
function office_from_lobby()
    return has("FrontKey") and has("OfficeKey")
end
function office_from_lake()
    return has("LakeKey") and has("OfficeElKey")
end

-- BEDROOM ACCESS:
-- take crawlspace from office, use elevator and enter bedroom
function has_bedroom_access()
    return has_office_access() and has("Crawling") and has("BedElKey") and has("BedKey")
end

-- WORKSHOP ACCESS:
-- door directly from office
function has_workshop_access()
    return has_office_access() and has("WorkshopKey")
end

-- LIBRARY ACCESS:
-- from lobby: direct door
-- from back corridor: direct door
function has_library_access()
    return library_from_lobby() or library_from_corridor()
end
function library_from_lobby()
    return has_lobby_access() and has("LibraryKey")
end

-- CORRIDOR ACCESS:
-- from library: directly from lobby
-- from theater: take crawlspace near GEOFFREY puzzle
-- from maze: take elevator to first level
function has_back_corridor_access()
    return library_from_lobby() or corridor_from_theater() or corridor_from_maze()
end
function corridor_from_theater()
    return has_lobby_access() and has("Crawling")
end
function corridor_from_maze()
    return maze_from_egypt() and has("ThreeElKey")
end

-- GENERATOR ACCESS:
-- direct door in back corridor
function has_generator_access()
    return has_back_corridor_access() and has("MechKey")
end

-- MAZE ACCESS:
-- from corridor: take 3-way elevator up
-- from Egypt: crawlspace near Tomb of the Ixupi
function has_maze_access()
    return maze_from_corridor() or maze_from_egypt() or inventions_from_planets()
end
function maze_from_corridor()
    return has_back_corridor_access() and has("ThreeElKey")
end
function maze_from_egypt()
    return egypt_from_lobby() and has("Crawling")
end

-- PROJECTOR ACCESS:
-- direct door from theater back hall
function has_projector_access()
    return has_lobby_access() and has("ProjKey")
end

-- EGYPT ACCESS:
-- from lobby: direct door
-- from maze: crawlspace
function has_egypt_access()
    return egypt_from_lobby() or egypt_from_maze()
end
function egypt_from_lobby()
    return has_lobby_access() and has("EgyptKey")
end
function egypt_from_maze()
    return maze_from_corridor() and has("Crawling")
end

-- SHAMAN ACCESS:
-- direct door from burial room, no additional requirements from Egypt room
function has_shaman_access()
    return has_egypt_access() and has("ShamanKey")
end

-- MYTHS ACCESS:
-- from gods: red door, no additional requirements past Shaman room
-- from planetarium: "backwards" access through stairs
function has_myth_access()
    return has_shaman_access() or myths_from_planets()
end
function myths_from_planets()
    return planets_from_inventions() and has("PlanetKey")
end

-- BATHROOM ACCESS:
-- from myths room: direct path
-- from planetarium: direct door
function has_bathroom_access() -- from myths room or from planetarium
    return (has_shaman_access() or has_planets_access()) and has("BathKey")
end

-- PLANETS ACCESS:
-- from myths room: direct path, no key needed
-- from Inventions: Planet door
function has_planets_access() -- from myths room or from Strange Inventions
    return has_myth_access() or planets_from_inventions()
end
function planets_from_inventions()
    return has_maze_access() and has("PlanetKey")
end

-- INVENTIONS ACCESS:
-- from maze: direct path, no key needed
-- from planetarium: exit door
function has_inventions_access()
    return has_maze_access() or inventions_from_planets()
end
function inventions_from_planets()
    return has_myth_access() and has("PlanetKey")
end

-- TORTURE ACCESS:
-- direct door from Inventions
function has_torture_access()
    return has_inventions_access() and has("TortureKey")
end

-- PUZZLE ACCESS:
-- direct door from Torture
function has_puzzle_access()
    return has_torture_access() and has("PuzzleKey")
end

-- BEAST ACCESS:
-- direct door from lobby
function has_beast_access()
    return has_lobby_access() and has("BeastKey")
end

-- PLANTS ACCESS:
-- direct door from Beasts
function has_plant_access()
    return has_beast_access() and has("PlantKey")
end

-- OCEAN ACCESS:
-- direct door from Beasts
function has_ocean_access()
    return has_beast_access() and has("OceanKey")
end


function can_capture_ash() -- OFFICE, BURIAL
    return has_office_access() or has_egypt_access()
end

function can_capture_cloth() -- EGYPT, BATHROOM, BURIAL
    return has_egypt_access() or has_bathroom_access()
end

function can_capture_crystal() -- LOBBY, OCEAN
    return has_lobby_access()
end

function can_capture_lightning() -- GENERATOR; currently assumes Early Lightning
    return  has_generator_access()
end

function can_capture_metal() -- BEDROOM, PROJECTOR, BEASTS
    return has_bedroom_access() or has_projector_access() or has_beast_access()
end

function can_capture_oil() -- BEASTS, SUBTERRANEAN
    return has_beast_access()
end

function can_capture_sand() -- OCEAN, PLANTS
    return has_ocean_access() or has_plant_access()
end

function can_capture_water() -- LOBBY, BATHROOM
    return has_lobby_access()
end

function can_capture_wax() -- LIBRARY, SHAMAN, MYTHS
    return has_library_access() or has_shaman_access() or has_myth_access()
end

function can_capture_wood() -- MAZE, MYTHS, GODS, WORKSHOP
    return has_workshop_access() or has_maze_access() or has_myth_access() or has_shaman_access() 
end