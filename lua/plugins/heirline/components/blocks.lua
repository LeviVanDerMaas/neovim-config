local utils = require "heirline.utils"

-- A table that contains building blocks for other components, e.g.
-- basic components and functions that spice up other components and utiltiy functions.
local M = {}

M.Aligner = { provider = "%=" }
M.Space = { provider = " " }
M.truncPos = { provider = "%<" }

-- Returns a component that's `n` spaces
function M.spaces (n)
  return { provider = string.rep(" ", n) }
end

--- Wraps a copy of `component` in an itemgroup as defined by `:h
--- 'statusline'`. All properties accepted by `fields` may also be functins
--- that return the required type instead, these will be evaluated everytime
--- the component gets reevaluated and take the surrounding component (NOT
--- `component` itself) as an argument.
---
--- **BEWARE** of the stipulation that when all items (that is, "%"-sequences) in a
--- group evaluate to empty strings, the entire group becomes empty when no
--- minwid is set. This includes items like "%*" (which only resets highlights and
--- so is always empty), so this is quite likely to happen when the component uses
--- any heirline feature that inserts items implicitly (like the `hl` property).
---
--- @param component table component to wrap
--- @param fields? table dict of fields for itemgroup:
---  - ljustify (boolean) optional: the `-` field; left justifies group contents
---  - l0s (boolean) optional: the `0` field; adds leading 0s to numeric items
---  - minwid (number) optional: the `minwid` field, minimum width of the group (max 50).
---  - maxwid (number) optional: the `maxwid` field, maximum width of the group.
function M.itemGroup (component, fields)
  fields = fields or {}

  local field_providers = {}

  local function boolFieldToStr (field, str)
    local f = fields[field]
    if type(f) == "function" then
      field_providers[field] = function (self)
        return f(self) and str
      end
    else
      field_providers[field] = f and str or nil
    end
  end
  boolFieldToStr("ljustify", "-")
  boolFieldToStr("l0s", "0")

  field_providers.minwid = fields.minwid
  local maxwid = fields.maxwid
  if type(maxwid) == "function" then
    field_providers.maxwid = function(self)
      return "." .. maxwid(self)
    end
  else
    field_providers.maxwid = maxwid and "." .. maxwid or nil
  end

  -- WARNING: The `hl = { [true] = true }' funny business is to prevent strings
  -- for highlight strings being inserted around providers as that breaks with
  -- fields. This is an undocumented feature that seems to have been explicitly
  -- programmed in heirline/highlights.lua's eval_hl function. As it is undocumented,
  -- I should probably make an issue about it and not continue using it this way.
  local parent = {}
  local function insertFieldIfPresent (field)
    local f = field_providers[field]
    if f then table.insert(parent, { provider = f, hl = { [true] = true }}) end
  end

  table.insert(parent, { provider = "%", hl = { [true] = true } })
  insertFieldIfPresent("ljustify")
  insertFieldIfPresent("l0s")
  insertFieldIfPresent("minwid")
  insertFieldIfPresent("maxwid")
  table.insert(parent, { provider = "(", hl = { [true] = true } })
  table.insert(parent, component)
  table.insert(parent, { provider = "%)", hl = { [true] = true }})

  parent.hl = { force = true }
  return parent
end

--- Returns a component in which a copy of `component` is preceded by a copy of
--- `affixes.prefix` and followed by a copy `affixes.suffix` (if one is given).
--- The affixes are evaluated only when `component` is, and their own
--- `conditions` are still respected.
function M.affix(component, affixes)
  local main = utils.clone(component)
  local main_condition = main.condition
  main.condition = nil

  local parent = { condition = main_condition }
  if affixes.prefix then table.insert(parent, utils.clone(affixes.prefix)) end
  table.insert(parent, main)
  if affixes.suffix then table.insert(parent, utils.clone(affixes.suffix)) end

  return parent
end
-- Shorthand for `M.affix(component, { prefix = prefix })`. Not specifying prefix defaults to a single space
function M.prefix(component, prefix)
  return M.affix(component, { prefix = prefix or { provider = " " } })
end
-- Shorthand for `M.affix(component, { suffix = suffix })`. Not specifying suffix defaults to a single space
function M.suffix(component, suffix)
  return M.affix(component, { suffix = suffix or { provider = " " } })
end

--- Returns a component whose children are a deep copy of `components`, with
--- `separator` inserted between each child. A `separator` instance is
--- evaluated only when a preceding child was, and its own `condition` is also
--- respected.
---
--- @param components table[] Components to separate
--- @param opts? table Options dict:
---  - separator (table) optional: Component to use as separator, defaults to 
---    a single space.
---  - leading (boolean) optional: Whether to have a separator before the first
---    evaluated component from `components`
---  - trailing (boolean) optional: As above, but after last evaluated component
---  - separator_on_empty (boolean) optional: If true, still evaluate a single
---    separator when none of the components from `components` get evaluated
function M.separate(components, opts)
  opts = opts or {}
  opts.separator = opts.separator or M.Space

  -- Internal table shared between components, to track evaluations.
  local _shared = {}

  local leading = opts.leading
  local parent = {
    init = function()
      -- If we want a leading separator, then just eval separators from the get-go.
      _shared.eval_separators = leading
      _shared.child_evaluated = false
    end,
  }

  local separator_condition = opts.separator.condition
  local separator = utils.clone(opts.separator)
  if separator_condition then
    separator.condition = function()
      return _shared.eval_separators and separator_condition(separator)
    end
  else
    separator.condition = function()
      return _shared.eval_separators
    end
  end

  -- We prefix each component with an instance of the separator that will only
  -- evaluate if `_shared.eval_separators` is true and if the originally
  -- passed separator's condition passes. Then we "move" the condition of the
  -- component to a parent that contains both the separator and the component; 
  -- and we have the child then set `_shared.eval_separators` to true if it gets evaluated.
  local preChildInit = function ()
    -- Be careful not to set these until after evaluating the separator!
    _shared.eval_separators = true;
    _shared.child_evaluated = true;
  end
  local childAddPreInit = function (child)
    return { init = preChildInit, child }
  end
  for i, c in ipairs(components) do
    local child = utils.clone(c)
    local child_condition = child.condition
    child.condition = nil
    parent[i] = {
      condition = child_condition,
      separator,
      childAddPreInit(child)
    }
  end
  if not leading and parent[1] then
    -- Do not prefix separator on first child unless we have leading separator
    table.remove(parent[1], 1)
  end

  if opts.trailing then
    table.insert(parent, {
      condition = function()
        return _shared.child_evaluated
      end,
      separator
    })
  end

  if opts.separator_on_empty then
    -- Note that this separator instace should not use the same logic as the
    -- oher separators (after all this one is not actually prefixed to another
    -- component), because we actually want to render this only when no other
    -- components are rendered instead of with them
    local separator_empty = utils.clone(separator)
    if separator_condition then
      separator_empty.condition = function()
        return not _shared.child_evaluated and separator_condition()
      end
    else
      separator_empty.condition = function()
        return not _shared.child_evaluated
      end
    end
    table.insert(parent, separator_empty)
  end

  return parent
end

-- Computes the minimum number of colums needed to cover at least `n` percent of the screen.
function M.width_percent_to_columns(p)
  return math.ceil(p * vim.api.nvim_win_get_width(0))
end

-- Like `M.width_percent_to_columns` but clamps the returned value.
-- By default `min` is 1 and `max` is 50.
function M.clamp_width_percent_to_columns(p, min, max)
  min = min or 1
  max =  max or 50

  local cols = math.ceil(p * vim.api.nvim_win_get_width(0))
  cols = cols >= min and cols or min
  cols = cols <= max and cols or max
  return cols
end

-- Returns the value of the largest prefix of a string `k` for which there
-- is an index in `t`. `nil` if there is no index that is a prefix of `k`.
function M.mapLargestPrefix (t, k)
  for i = #k - 1, 1, -1 do
    local prefix = k:sub(1, i)
    local value = rawget(t, prefix)
    if value then
      return value
    end
  end
  return nil
end

return M
