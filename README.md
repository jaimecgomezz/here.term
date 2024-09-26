# here.term

Use a single terminal instance as any other buffer. Toggle between the file you're editing and the terminal with a single command (`<C-;>`) and kill it just as easily (`<C-S-;>`).


## Installation

With [lazy](https://github.com/folke/lazy.nvim):
```lua
{
    "jaimecgomezz/here.term",
    opts = {}
}
```

Please make sure you have set the `hidden` option in your config file, or the terminals will be discarded when toggled. 
```lua
vim.opt.hidden = true
```


## Configuration

Here are the default options:
```lua
require("here-term").setup({
    -- The command we run when exiting the terminal and no other buffers are listed. An empty
    -- buffer is shown by default
    startup_command = "enew", -- Startify, Dashboard, etc...

    -- Mappings
    -- Every mapping bellow can be customized by providing your prefered combo, or disabled
    -- entirely by setting them to `nil`.
    --
    -- The minimal mappings used to toggle and kill the terminal. Available in
    -- `normal` and `terminal` mode.
    mappings = {
        toggle = "<C-;>",
        kill = "<C-S-;>",
    },
    -- Additional mappings that I consider useful since you won't have to escape (<C-\><C-n>)
    -- the terminal each time. Available in `terminal` mode.
    extra_mappings = {
        enable = true, -- Disable them entirely
        escape = "<C-x>", -- Escape terminal mode
        left = "<C-w>h", -- Move to the left window
        down = "<C-w>j", -- Move to the window down
        up = "<C-w>k", -- Move to the window up
        right = "<C-w>l", -- Move to right window
    },
})
```

## Workflow

1. Open any file you wish to edit.
2. Press `<C-;>` in `normal` mode. A terminal instance will replace the file you're editing.
3. Start typing your commands, you'll be on `terminal` mode by default.
4. Press `<C-;>` within the terminal. The buffer you were editing will replace the terminal.
5. Continue editing your file.
6. If the terminal is no longer useful to you, kill it with `<C-S-;>`.
7. If you ever need the terminal again, press `<C-;>`.


## Why

I've used most of the terminal solutions out there, tempted by the next shiny plugin that I could add to my neovim config, but I'd always ended up using a single terminal instance and barely scratching their full potential.

I now realize that that's ok, even ideal. Most of the complex stuff, like running local servers, compiling your code or any other background process can be perfectly handled by any of the incredible task runner solutions out there, like [overseer.nvim](https://github.com/stevearc/overseer.nvim), which is my goto. So, for the remaining everyday stuff, a single terminal instance that can be easily toggled, without needing to switch between windows or escaping it, or any other shenanigans, has come to be my favorite solution.

If you decide to use `here.term` you can still spawn new terminals if you like, it won't interfere, you'll just have a special one that you can access at speed of light (: