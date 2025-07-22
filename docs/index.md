# Документация SimpleItemTags

## Импортирование и пример

```lua
local api = require "simpleitemtags:init";

local blocks = api.get_blocks_by_tags("lamps");
  
for _, blockid in ipairs(blocks) do
  print(string.format("Привет, %s!", block.name(blockid))); -- Привет всем лампам!
end
```

## Методы

### Общие

```lua
-- Получает все теги.
function api.get_all_tags(): string[]

-- Получает копию регистра тегов.
function api.get_registry(): { items: table<string, integer[]>, blocks: table<string, integer[]>, tags: string[] }
```

### Предметы

```lua
-- Получает идентификаторы предметов, у которых есть один из тегов.
function api.get_items_by_tag(...: string): integer[]

-- Получает теги по идентификатору предмета.
function module.get_tags_by_itemid(itemid: integer): string[]

-- Получает идентификаторы предметов, у которых есть все перечисленные теги.
function module.get_items_have_tags(...: string): integer[]
```

### Блоки

```lua
-- Получает идентификаторы блоков, у которых есть один из тегов.
function module.get_blocks_by_tags(...: string): integer[]

-- Получает теги по идентификатору блока.
function module.get_tags_by_blockid(blockid: integer): string[]

-- Получает идентификаторы блоков, у которых есть все перечисленные теги.
function module.get_blocks_have_tags(...: string): integer[]
```

## Добавление своих тегов

Для задуманного создайте блок и впишите туда следующее

```json
{
  "simpleitemtags:tags@append": [ "Уже здесь указывайте новые теги" ]
}
```
