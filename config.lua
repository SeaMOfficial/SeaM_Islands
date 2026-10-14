--- SeaM_Islands :: configuration
---
--- Island names appear in the sky above them once you are close enough to care
--- and fade out again once you have arrived. Entirely client side: there is
--- nothing here the server needs to know about.

Config = {}

--- Rendering ----------------------------------------------------------------
Config.Render = {
    --- Metres. Past this nothing is drawn at all and the loop sleeps.
    MaxDistance = 3000.0,

    --- The name fades in over the last stretch of this, rather than snapping
    --- on the moment you cross the line.
    FadeInOver = 400.0,

    --- Close enough that you can see the place yourself. The name fades out
    --- again over this distance so it is not sitting on top of the island.
    HideWithin = 250.0,
    FadeOutOver = 150.0,

    --- How much the marker is scaled at the near and far ends of the range.
    --- 1.0 is the size the stylesheet draws it at, so these multiply that.
    --- Distant islands read smaller, which is what makes the horizon feel deep.
    ScaleNear = 1.0,
    ScaleFar = 0.42,

    --- A thin line from the label down to the island, so a name in the sky has
    --- something to belong to.
    Beam = true,

    --- Seconds between distance checks while nothing is in range. Once
    --- something is, drawing happens every frame regardless.
    IdleInterval = 2,

    --- How many names can be on screen at once. Beyond this the nearest win,
    --- so an archipelago does not turn into a wall of text.
    MaxVisible = 4,
}

--- Discovery ----------------------------------------------------------------
--- No message is shown. This only decides when an island counts as found, for
--- the SeaM_Islands:client:discovered event and the IsDiscovered export.
Config.Discovery = {

    --- How close you have to get for it to count as found.
    Distance = 900.0,
}

--- Islands ------------------------------------------------------------------
--- Per island:
---   id       used by the exports and by /islands
---   name     what is written in the sky
---
--- Optional:
---   subtitle a smaller line under the name, before the distance
---   coords   the middle of it. The label floats above this
---   height   metres above `coords` the label sits. Tall enough to clear the
---            terrain, low enough that it does not look detached
---   beamDrop extra metres the beam continues below `coords`, for somewhere
---            whose marked point sits above the ground it stands on
---   colour   hex, defaults to Config.Colour
---   distance overrides Config.Render.MaxDistance for this one, for somewhere
---            big enough to be seen from much further out

Config.Colour = '#c7923e'

Config.Islands = {
    {
        id = 'cayo_perico',
        name = 'Cayo Perico',
        subtitle = 'Private Island',
        coords = vector3(4840.0, -5174.0, 2.0),
        height = 260.0,
        distance = 4000.0,
    },
    {
        id = 'north_yankton',
        name = 'North Yankton',
        coords = vector3(3217.0, -4834.0, 111.0),
        height = 240.0,
    },
    {
        id = 'mount_chiliad',
        name = 'Mount Chiliad',
        subtitle = 'The Summit',
        coords = vector3(501.0, 5604.0, 797.0),
        height = 180.0,
        distance = 3500.0,
    },
    {
        id = 'paleto_cove',
        name = 'Paleto Cove',
        coords = vector3(-345.0, 6635.0, 1.0),
        height = 120.0,
    },
    {
        id = 'del_perro_pier',
        name = 'Del Perro Pier',
        coords = vector3(-1850.0, -1245.0, 8.0),
        height = 90.0,
        distance = 1200.0,
    },
}
