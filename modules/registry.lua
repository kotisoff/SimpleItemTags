local logger = require "logger";
local module = {};

---@alias simpleitemtags.registry.elements { items: table<str, int[]>, blocks: table<str, int[]> }

local registry = {
  ---@type simpleitemtags.registry.elements
  elements = {
    blocks = {},
    items = {},
  },
  ---@type table<str, true>
  tags = {}
};

---@param table table
---@param key str
---@param default any
local function use_or_create(table, key, default)
  table[key] = table[key] or default;
end

local tags_prop = "simpleitemtags:tags";

events.on("simpleitemtags:first_tick", function()
  local elements = registry.elements;

  logger.println("I", "Reading block tags...")
  for blockid, value in ipairs(block.properties) do
    local itemid = block.get_picking_item(blockid);

    local prop = value[tags_prop]
    if prop and type(prop) == "table" then
      for _, tag in ipairs(prop) do
        registry.tags[tag] = true;
        use_or_create(elements.blocks, tag, {});
        use_or_create(elements.items, tag, {});

        table.insert(elements.blocks[tag], blockid);
        table.insert(elements.items[tag], itemid);
      end
    elseif prop then
      logger.println("E", string.format("Unable to read tags of block: %s", block.name(blockid)));
    end
  end

  logger.println("I", "Reading item tags...")
  for itemid, value in ipairs(item.properties) do
    local prop = value[tags_prop]
    if prop and type(prop) == "string" then
      for _, tag in ipairs(prop) do
        registry.tags[tag] = true;
        use_or_create(elements.items, tag, {});

        table.insert(elements.items[tag], itemid);
      end
    elseif prop then
      logger.println("E", string.format("Unable to read tags of item: %s", block.name(itemid)));
    end
  end

  logger.println("I", "Done.")
end)

---@param list "items" | "blocks"
---@param ... str
---@return int[]
local function get_elements_by_tags(list, ...)
  local elements = {};
  for _, tag in ipairs({ ... }) do
    local tmp = registry.elements[list][tag] or {}

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


---@param list "items" | "blocks"
---@param elid int
---@param ... str
local function add_tags_to_element(list, elid, ...)
  local reg = registry.elements[list];

  local tags = { ... };

  for _, tag in ipairs(tags) do
    registry.tags[tag] = true;
    use_or_create(reg, tag, {});

    table.insert(reg[tag], elid);
  end
end

---@param ... str
function module.get_blocks_by_tags(...)
  return get_elements_by_tags("blocks", ...);
end

---@param ... str
function module.get_items_by_tags(...)
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

---@return str[]
function module.get_all_tags()
  local keys = {};
  for tag, _ in pairs(registry.tags) do
    table.insert(keys);
  end

  return keys;
end

---@return simpleitemtags.registry.elements
function module.get_registry()
  return table.deep_copy(registry.elements);
end

function module.add_tags_to_item(itemid, ...)
  add_tags_to_element("items", itemid, ...);
end

function module.add_tags_to_block(blockid, ...)
  add_tags_to_element("blocks", blockid, ...);
  add_tags_to_element("items", block.get_picking_item(blockid), ...);
end

return module;
