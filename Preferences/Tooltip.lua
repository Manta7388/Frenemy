--------------------------------------------------------------------------------
---- AddOn Namespace
--------------------------------------------------------------------------------

local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@type PrivateNamespace

local Preferences = private.Preferences
local Sorting = private.Sorting
local SortOrder = private.SortOrder

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

---@class Preferences.Tooltip
---@field NotesArrangement NotesArrangement
local TooltipPreferences = Preferences.Tooltip

--------------------------------------------------------------------------------
---- Constants
--------------------------------------------------------------------------------

---@class NotesArrangement
---@field Column integer
---@field Row integer
local NotesArrangement = {
    Column = 1,
    Row = 2,
}

Preferences.Tooltip.NotesArrangement = NotesArrangement

---@type Array<string>
local NotesArrangementValues = {
    [NotesArrangement.Column] = L.NOTES_ARRANGEMENT_COLUMN,
    [NotesArrangement.Row] = L.NOTES_ARRANGEMENT_ROW,
}

--------------------------------------------------------------------------------
---- Helpers
--------------------------------------------------------------------------------

---@param optionsTable table
---@param entryName string
---@param label string
---@param order number
local function BuildNotesEntry(optionsTable, entryName, label, order)
    local DB = private.DB

    optionsTable["notesArrangement" .. entryName] = {
        order = order,
        type = "select",
        style = "radio",
        name = label,
        values = NotesArrangementValues,
        get = function(info)
            return DB.Tooltip.NotesArrangement[entryName]
        end,
        set = function(info, value)
            DB.Tooltip.NotesArrangement[entryName] = value
        end,
    }
end

--------------------------------------------------------------------------------
---- Tooltip Options
--------------------------------------------------------------------------------

---@type AceConfig.OptionsTable
local Options

function TooltipPreferences:GetOptions()
    if not Options then
        local DB = private.DB

        Options = {
            order = 2,
            name = DISPLAY,
            type = "group",
            args = {
                hideDelay = {
                    order = 1,
                    type = "range",
                    width = "full",
                    name = L.TOOLTIP_HIDEDELAY_LABEL,
                    desc = L.TOOLTIP_HIDEDELAY_DESC,
                    min = 0.10,
                    max = 2,
                    step = 0.05,
                    get = function()
                        return DB.Tooltip.HideDelay
                    end,
                    set = function(info, value)
                        DB.Tooltip.HideDelay = value
                    end,
                },
                scale = {
                    order = 2,
                    type = "range",
                    width = "full",
                    name = L.TOOLTIP_SCALE_LABEL,
                    min = 0.5,
                    max = 2,
                    step = 0.01,
                    get = function()
                        return DB.Tooltip.Scale
                    end,
                    set = function(info, value)
                        DB.Tooltip.Scale = value
                    end,
                },
                notesArrangementHeader = {
                    name = LABEL_NOTE,
                    order = 3,
                    type = "header",
                    width = "full",
                },
            },
        }

        BuildNotesEntry(Options.args, "BattleNetApp", BATTLENET_OPTIONS_LABEL, 4)
        BuildNotesEntry(
            Options.args,
            "BattleNetGames",
            ("%s %s"):format(BATTLENET_OPTIONS_LABEL, PARENS_TEMPLATE:format(GAME)),
            5
        )
        BuildNotesEntry(Options.args, "Guild", GetGuildInfo("player") or GUILD, 6)
        BuildNotesEntry(
            Options.args,
            "GuildOfficer",
            ("%s %s"):format(GetGuildInfo("player") or GUILD, PARENS_TEMPLATE:format(OFFICER)),
            7
        )
        BuildNotesEntry(Options.args, "WoWFriends", FRIENDS, 8)
    end

    return Options
end

--------------------------------------------------------------------------------
---- Preferences Augmentation
--------------------------------------------------------------------------------

Preferences.DefaultValues.global.Tooltip = {
    CollapsedSections = {
        BattleNetApp = false,
        BattleNetGames = false,
        Guild = false,
        WoWFriends = false,
    },
    HideDelay = 0.25,
    NotesArrangement = {
        BattleNetApp = NotesArrangement.Row,
        BattleNetGames = NotesArrangement.Row,
        Guild = NotesArrangement.Row,
        GuildOfficer = NotesArrangement.Row,
        WoWFriends = NotesArrangement.Row,
    },
    SectionDisplayOrders = {
        "WoWFriends",
        "BattleNetGames",
        "BattleNetApp",
        "Guild",
    },
    Scale = 1,
    Sorting = {
        BattleNetApp = {
            Field = Sorting.FieldIDs.BattleNetApp.PresenceName,
            Order = SortOrder.Enum.Ascending,
        },
        BattleNetGames = {
            Field = Sorting.FieldIDs.BattleNetGames.PresenceName,
            Order = SortOrder.Enum.Ascending,
        },
        Guild = {
            Field = Sorting.FieldIDs.Guild.ToonName,
            Order = SortOrder.Enum.Ascending,
        },
        WoWFriends = {
            Field = Sorting.FieldIDs.WoWFriends.ToonName,
            Order = SortOrder.Enum.Ascending,
        },
    },
}
