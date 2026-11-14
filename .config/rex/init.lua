-- Rex configuration.
-- Apply a change with: rex config reload
-- Check a change first with: rex config check
--
-- keys.lua holds the prefix, the keys that enter each mode, and every global
-- binding. Each module in actions/ holds one custom action. A module that
-- declares a mode also holds that mode's own keys.

require 'actions.session'
require 'actions.copy_mode'
require 'actions.scroll'
require 'keys'
