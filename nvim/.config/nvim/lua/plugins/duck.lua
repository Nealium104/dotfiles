-- Pets that wander around the window while you work. <leader>p is the pet
-- group (which-key.lua): a letter hatches that animal, <leader>pC cooks the
-- newest one and <leader>pX cooks them all.

-- key, emoji, name, speed (steps per second; the plugin's default is 10)
local pets = {
   { "c", "🦀", "crab", 8 },
   { "t", "🐢", "turtle", 2 },
   { "p", "🎃", "pumpkin", 4 },
   { "g", "👻", "ghost", 6 },
   { "o", "🦦", "otter", 12 },
   { "d", "🦆", "duck", 10 },
   { "s", "🦑", "squid", 6 },
   { "f", "🐈", "feline", 8 },
   { "h", "🦔", "hedgehog", 6 },
   { "r", "🦝", "raccoon", 10 },
   { "b", "🐝", "bee", 20 },
   { "a", "🤖", "android", 12 },
   { "m", "🐁", "mouse", 18 },
}

local keys = {
   { "<leader>pC", function() require("duck").cook() end, desc = "Cook the newest pet" },
   { "<leader>pX", function() require("duck").cook_all() end, desc = "Cook every pet" },
}
for _, pet in ipairs(pets) do
   local key, emoji, name, speed = unpack(pet)
   table.insert(keys, {
      "<leader>p" .. key,
      function() require("duck").hatch(emoji, speed) end,
      desc = emoji .. " " .. name,
   })
end

return {
   "tamton-aquib/duck.nvim",
   keys = keys,
}
