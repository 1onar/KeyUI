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

addon.VERSION = {
    -- Raw build number (e.g., 120000 for Retail, 20505 for Anniversary)
    build = build,

    -- Version flags for quick checks
    isRetail = build >= 100000,      -- Retail (Dragonflight 10.0+, Midnight 12.0+)
    isClassic = build < 100000,      -- Classic Era, Anniversary, Cata, Wrath

    -- Specific version ranges
    isVanilla = build >= 11500 and build < 20000,      -- Classic Era (1.15.x)
    isAnniversary = build >= 20500 and build < 30000,  -- Anniversary (2.5.x)
    isCata = build >= 50500 and build < 60000,         -- Cata Classic (5.5.x)

    -- Atlas system availability (Retail only)
    -- Retail uses SetAtlas() with atlas names
    -- Classic uses SetTexture() with file paths
    USE_ATLAS = build >= 100000,
}

-- Version info string for debugging
addon.VERSION.string = string.format(
    "%s (Build %d)",
    addon.VERSION.isRetail and "Retail" or
    addon.VERSION.isCata and "Cata Classic" or
    addon.VERSION.isAnniversary and "Anniversary" or
    addon.VERSION.isVanilla and "Classic Era" or
    "Unknown",
    build
)

-- Log version detection at addon load
if addon.debug then
    print("KeyUI: " .. addon.VERSION.string)
end
