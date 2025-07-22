local function format_name(name)
  local len = 20;
  local spaces_count = len - #name;

  local spaces = string.rep(" ", spaces_count);

  return string.format("[%s%s]", spaces, name);
end

---@param logLevel sit_api.logger.levels
local function prefix(logLevel)
  local date = os.date("%Y/%m/%d %H:%M:%S%z    ");
  local log_prefix = string.format("[%s] %s %s ", logLevel, date, format_name("simpleitemtags"));
  return log_prefix
end

local module = {};

---@enum sit_api.logger.levels
module.levels = {
  ---Silent
  S = "S",
  ---Info
  I = "I",
  ---Warn
  W = "W",
  ---Error
  E = "E"
}

---@param logLevel sit_api.logger.levels
function module.println(logLevel, ...)
  print(prefix(logLevel) .. table.concat({ ... }, " "))
end

return module;
