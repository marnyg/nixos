-- luafile llm_load.lua
dofile('./llm_tree2.lua').setup({
  llm_provider = function(input, prompt)
    return { "Response 1", "Response 2" }
  end,
  window = {
    width = 100,
    border = 'single'
  }
})
