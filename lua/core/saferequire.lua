-- Safely `require` the listed `modules`, such that an error in one module does
-- not prevent execution of other modules. Afterwards, if any error was encountered,
-- a list of all errors with corresponding stacktraces is printed.
return function (modules)
  local errors = {}

  for _, module in ipairs(modules) do
    local ok, err = pcall(require, module)
    if not ok then
      table.insert(errors, debug.traceback(
        "Caught error while loading module '" .. module .. "':\n" .. err, 2
      ))
    end
  end

  if #errors ~= 0 then
    vim.schedule(function ()
      vim.notify(table.concat(errors, "\n\n"), vim.log.levels.ERROR)
    end)
  end
end
