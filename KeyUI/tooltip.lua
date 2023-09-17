local name, addon = ...
function addon:CreateTooltip()
  local KBTooltip = CreateFrame("Frame", "KeyBindTooltip", addon.controlsFrame, BackdropTemplateMixin and "BackdropTemplate") --tooltip to show the name of the macro/spell/action
  KBTooltip:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                              edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                                              tile = true, tileSize = 16, edgeSize = 16,
                                              insets = { left = 4, right = 4, top = 4, bottom = 4 }});

  KBTooltip:SetBackdropColor(0,0,0,1);
  KBTooltip:SetWidth(200)
  KBTooltip:SetHeight(25)
  KBTooltip:SetFrameStrata("TOOLTIP")
  KBTooltip.title = KBTooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  KBTooltip.title:SetPoint("TOPLEFT", KBTooltip, "TOPLEFT", 5, -5)
  addon.tooltip = KBTooltip
  return KBTooltip
end
