local name, addon = ...

-- ============================================================================
-- Version Compatibility Layer
-- ============================================================================
-- Centralized version detection to avoid duplicate GetBuildInfo() calls
-- throughout the codebase. This module provides runtime detection of WoW
-- version and available APIs.
--
-- Usage:
--   if addon.VERSION.USE_ATLAS then
--       -- Use Retail Atlas API
--   else
--       -- Use Classic texture paths
--   end
-- ============================================================================

local build = select(4, GetBuildInfo())

-- WoW Forever (1.60.x, interface 16001) has a Classic-looking build number but
-- runs the Mainline client: the 12.x API with secret values, atlases and the
-- Mainline templates. Anything that follows the client rather than the game
-- belongs on isModern, not isRetail.
local isRetail = build >= 100000
local isForever = build >= 16000 and build < 17000
local isModern = isRetail or isForever

addon.VERSION = {
    -- Raw build number (e.g., 120000 for Retail, 20505 for Anniversary)
    build = build,

    -- Version flags for quick checks
    isRetail = isRetail,             -- Retail (Dragonflight 10.0+, Midnight 12.0+)
    isForever = isForever,           -- WoW Forever (1.60.x)
    isModern = isModern,             -- Mainline client family: Retail and Forever
    isClassic = not isModern,        -- Classic Era, Anniversary, MoP, Wrath

    -- Specific version ranges
    isVanilla = build >= 11500 and build < 16000,      -- Classic Era (1.15.x)
    isAnniversary = build >= 20500 and build < 30000,  -- Anniversary (2.5.x)
    isMoP = build >= 50500 and build < 60000,          -- MoP Classic (5.5.x)

    -- Atlas system availability (Mainline clients only)
    -- Retail and Forever use SetAtlas() with atlas names
    -- Classic uses SetTexture() with file paths
    USE_ATLAS = isModern,
}

-- Version info string for debugging
addon.VERSION.string = string.format(
    "%s (Build %d)",
    addon.VERSION.isRetail and "Retail" or
    addon.VERSION.isForever and "Forever" or
    addon.VERSION.isMoP and "MoP Classic" or
    addon.VERSION.isAnniversary and "Anniversary" or
    addon.VERSION.isVanilla and "Classic Era" or
    "Unknown",
    build
)
