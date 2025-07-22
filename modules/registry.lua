local logger = require "logger";
local module = {};

---@type { items: table<str, int[]>, blocks: table<str, int[]> }
local registry = {
  items = {},
  blocks = {}
};

local tags_prop = "simpleitemtags:tags";

events.on("simpleitemtags:first_tick", function()
  logger.println("I", "Читаем теги блоков...")
  for blockid, value in ipairs(block.properties) do
    local prop = value[tags_prop]
    if prop and type(prop) == "table" then
      for _, tag in ipairs(prop) do
        registry.blocks[tag] = registry.blocks[tag] or {};

        table.insert(registry.blocks[tag], blockid);
      end
    elseif prop then
      logger.println("E", string.format("Ошибка чтения тегов блока: %s", block.name(blockid)));
    end
  end

  logger.println("I", "Читаем теги предметов...")
  for itemid, value in ipairs(item.properties) do
    local prop = value[tags_prop]
    if prop and type(prop) == "string" then
      for _, tag in ipairs(prop) do
        registry.items[tag] = registry.items[tag] or {};

        table.insert(registry.items[tag], itemid);
      end
    elseif prop then
      logger.println("E", string.format("Ошибка чтения тегов предмета: %s", block.name(itemid)));
    end
  end

  logger.println("I", "Все доступные теги прочитаны.")
end)

---@param list "items" | "blocks"
---@param ... str
---@return int[]
local function get_elements_by_tags(list, ...)
  local elements = {};
  for _, tag in ipairs({ ... }) do
    local tmp = (registry[list][tag] or {})
    for _, id in ipairs(tmp) do
      table.insert(elements, id);
    end
  end

  return elements;
end

---@param list table<str, any>[]
---@param id int
---@return str[]
local function get_tags_by_elementid(list, id)
  local prop = list[id][tags_prop]
  return prop or {};
end

---@param list table<str, any>[]
---@param ... str
---@return int[]
local function get_elements_have_tags(list, ...)
  local elements = {};
  local tags = { ... };

  for id, value in ipairs(list) do
    local prop = value[tags_prop];
    if prop then
      local flag = true;
      for _, tag in ipairs(prop) do
        if not table.has(tags, tag) then
          flag = false;
        end
      end

      if flag then
        table.insert(elements, id);
      end
    end
  end

  return elements;
end

---@param ... str
function module.get_blocks_by_tags(...)
  return get_elements_by_tags("blocks", ...);
end

---@param ... str
function module.get_items_by_tag(...)
  return get_elements_by_tags("items", ...);
end

---@param blockid int
function module.get_tags_by_blockid(blockid)
  return get_tags_by_elementid(block.properties, blockid);
end

---@param itemid int
function module.get_tags_by_itemid(itemid)
  return get_tags_by_elementid(item.properties, itemid);
end

---@param ... str
function module.get_blocks_have_tags(...)
  return get_elements_have_tags(block.properties, ...);
end

---@param ... str
function module.get_items_have_tags(...)
  return get_elements_have_tags(item.properties, ...);
end

return module;
