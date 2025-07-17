# Flutter Development Keybindings

This document contains all keybindings for the Flutter development environment in Neovim.

## Basic Vim Operations

### Movement
| Key | Function |
|-----|----------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |
| `w` | Move to beginning of next word |
| `b` | Move to beginning of previous word |
| `e` | Move to end of word |
| `0` | Move to beginning of line |
| `$` | Move to end of line |
| `gg` | Move to beginning of file |
| `G` | Move to end of file |

### Editing
| Key | Function |
|-----|----------|
| `i` | Insert mode (at cursor) |
| `a` | Insert mode (after cursor) |
| `o` | Create new line below and insert |
| `O` | Create new line above and insert |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Copy (yank) line |
| `p` | Paste after cursor |
| `P` | Paste before cursor |

### Line Copying (Yank)
| Key | Function |
|-----|----------|
| `yy` or `Y` | Copy (yank) entire current line |
| `3yy` | Copy 3 lines starting from current line |
| `p` | Paste copied line(s) after current line |
| `P` | Paste copied line(s) before current line |
| `yyp` | Copy current line and paste immediately after (duplicate line) |
| `3yyp` | Copy 3 lines and paste them immediately after |

#### Visual Mode Line Copying
1. Press `Shift+v` to enter line-based visual mode
2. Select desired lines with `j`/`k` or other movement commands
3. Press `y` to copy (yank) the selected lines
4. Move cursor to desired location and press `p` to paste

**Note**: In Vim, "yank" (やんく) is the term for copying. This allows efficient text duplication without using the mouse.

### Visual Mode
| Key | Function |
|-----|----------|
| `v` | Visual mode (character) |
| `V` | Visual line mode |
| `Ctrl+v` | Visual block mode |

### File Operations
| Command | Function |
|---------|----------|
| `:w` | Save file |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |
| `:qa` | Quit all windows |
| `:qa!` | Force quit all windows |
| `:wqa` | Save all and quit |
| `<leader>w` | Save file |
| `<leader>Q` | Quit |
| `<leader>wq` | Save and quit |
| `<leader>qq` | Quit all windows (IDE exit) |
| `<leader>qa` | Force quit all windows |
| `<leader>wqa` | Save all and quit |

## Flutter Development

| Key | Function |
|-----|----------|
| `<leader>fr` | Flutter run |
| `<leader>fh` | Hot reload |
| `<leader>fR` | Hot restart |
| `<leader>fq` | Flutter quit |
| `<leader>fd` | List devices |
| `<leader>fe` | Start emulator |
| `<leader>fl` | Flutter logs |
| `<leader>fc` | Flutter clean |

## LSP (Language Server Protocol)

| Key | Function |
|-----|----------|
| `gD` | Go to declaration |
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>f` | Format code (LSP) |
| `<leader>=` | Format code (Vim) |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>de` | Show diagnostic float |
| `<leader>dl` | Diagnostics to loclist |
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |
| `<leader>D` | Type definition |
| `<leader>th` | Toggle inlay hints |
| `<leader>li` | LSP information |
| `<leader>lr` | Restart LSP |
| `<leader>ls` | Start LSP |
| `<leader>lS` | Stop LSP |

## Search and Navigation

### Basic Search
| Key | Function |
|-----|----------|
| `/` | Forward search |
| `?` | Backward search |
| `n` | Next search result |
| `N` | Previous search result |
| `*` | Search word under cursor (no jump) |
| `#` | Search word under cursor backward (no jump) |
| `<ESC><ESC>` | Clear search highlights |
| `<leader>r` | Replace word under cursor |

### Flash.nvim Enhanced Search
| Key | Function |
|-----|----------|
| `s` | Flash jump (2-char search) |
| `S` | Flash Treesitter (structural jump) |
| `f` | Enhanced forward character search |
| `F` | Enhanced backward character search |
| `t` | Enhanced "till" forward search |
| `T` | Enhanced "till" backward search |

### Telescope
| Key | Function |
|-----|----------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find help |
| `<leader>fs` | Find document symbols |
| `<leader>fw` | Find workspace symbols |
| `<leader>fr` | Find recent files |
| `<leader>fc` | Find commands |
| `<leader>fd` | Find diagnostics |
| `<leader>fk` | Find keymaps |
| `<leader>ft` | Find telescope builtin |
| `<leader>fR` | Resume last search |

## Git Integration (Gitsigns)

### Navigation
| Key | Function |
|-----|----------|
| `]c` | Next hunk |
| `[c` | Previous hunk |

### Actions
| Key | Function |
|-----|----------|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>tb` | Toggle blame |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff this ~ |
| `<leader>td` | Toggle deleted |

### Visual Mode Git Actions
| Key | Function |
|-----|----------|
| `<leader>hs` | Stage selected lines |
| `<leader>hr` | Reset selected lines |

### Text Objects
| Key | Function |
|-----|----------|
| `ih` | Inner hunk (text object) |

## GitHub Copilot

| Key | Function |
|-----|----------|
| `Alt+l` | Accept suggestion |
| `Alt+]` | Next suggestion |
| `Alt+[` | Previous suggestion |
| `Alt+\` | Dismiss suggestion |
| `<leader>cc` | Copilot chat |
| `<leader>Ce` | Enable Copilot |
| `<leader>Cd` | Disable Copilot |
| `<leader>Cp` | Panel |
| `<leader>Cs` | Status |

## Markdown Rendering

| Key | Function |
|-----|----------|
| `<leader>mr` | Toggle markdown rendering |
| `<leader>me` | Enable markdown rendering |
| `<leader>md` | Disable markdown rendering |

## Debugging (DAP)

| Key | Function |
|-----|----------|
| `<F5>` | Start/Continue debugging |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<leader>b` | Toggle breakpoint |

## File Explorer

### NvimTree
| Key | Function |
|-----|----------|
| `<leader>e` | Toggle NvimTree |
| `<leader>ef` | Find current file in tree |
| `l` | Open file/folder |
| `h` | Close directory |
| `v` | Open in vertical split |
| `a` | Create file/directory |
| `d` | Delete |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |
| `y` | Copy name |
| `Y` | Copy relative path |
| `gy` | Copy absolute path |
| `[c` | Previous git item |
| `]c` | Next git item |
| `-` | Navigate up directory |
| `s` | Open in system |
| `<CR>` | Open |
| `<Tab>` | Preview |
| `R` | Refresh |
| `W` | Collapse all |
| `S` | Search |

### Netrw (Vim Explorer)
| Key | Function |
|-----|----------|
| `<leader>v` | Toggle Lexplore |
| `<leader>V` | Open Explorer |

## Buffer Management

| Key | Function |
|-----|----------|
| `<Tab>` | Next buffer (Bufferline) |
| `<S-Tab>` | Previous buffer (Bufferline) |
| `<leader>b[` | Previous buffer |
| `<leader>b]` | Next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bl` | List buffers |
| `<leader>bc` | Pick buffer to close |
| `<leader>bo` | Close other buffers |

## Window Management

| Key | Function |
|-----|----------|
| `ss` | Split horizontally |
| `sv` | Split vertically |
| `<leader><space>` | Switch window |
| `sh` | Move to left window |
| `sj` | Move to bottom window |
| `sk` | Move to top window |
| `sl` | Move to right window |
| `<C-w><left>` | Decrease window width |
| `<C-w><right>` | Increase window width |
| `<C-w><up>` | Increase window height |
| `<C-w><down>` | Decrease window height |

## Tab Management

| Key | Function |
|-----|----------|
| `<leader>tn` | New tab |
| `<leader>tc` | Close tab |
| `<leader>t[` | Previous tab |
| `<leader>t]` | Next tab |

## Terminal

| Key | Function |
|-----|----------|
| `<leader>T` | Open terminal |
| `<ESC>` | Exit terminal mode |

## Claude Code Integration

| Key | Function |
|-----|----------|
| `<leader>clc` | Toggle Claude |
| `<leader>clo` | Open Claude |
| `<leader>cll` | Show Claude sessions |
| `<leader>clm` | Monitor Claude sessions |
| `<leader>clw` | Switch Claude worktree |

## Clipboard Operations

All yank, delete, and change operations are automatically synced with the system clipboard. This means:
- `y` copies to system clipboard
- `d` cuts to system clipboard
- `c` changes and copies to system clipboard
- `p` pastes from system clipboard

For explicit clipboard operations:
- `"+y` - Explicitly copy to system clipboard
- `"+p` - Explicitly paste from system clipboard

## Utility Commands

| Key | Function |
|-----|----------|
| `<leader>cp` | Copy file path |
| `<leader>cl` | Copy current line |
| `<leader>n` | New file |
| `<leader>wf` | Save and format (prettier) |
| `<leader>d` | Duplicate line |
| `<leader>a` | Select all |

## QuickFix

| Key | Function |
|-----|----------|
| `<leader>qo` | Open quickfix |
| `<leader>qc` | Close quickfix |
| `<leader>qn` | Next quickfix item |
| `<leader>qp` | Previous quickfix item |

## IDE Layout

| Key | Function |
|-----|----------|
| `<leader>ide` | Start smart IDE layout |
| `<leader>I` | Start full IDE layout |
| `<leader>is` | Start simple IDE layout (3-panel) |
| `<leader>if` | Start Flutter IDE layout |
| `<leader>ir` | Reset window layout |

### Three-Panel IDE Window Management
| Key | Function |
|-----|----------|
| `<leader>w1` | Go to window 1 (file tree) |
| `<leader>w2` | Go to window 2 (main editor) |
| `<leader>w3` | Go to window 3 (second editor) |
| `<leader>w=` | Rebalance windows |
| `<leader>wd` | Duplicate buffer to right window |
| `<C-h>` | Move to left window |
| `<C-j>` | Move to lower window |
| `<C-k>` | Move to upper window |
| `<C-l>` | Move to right window |
| `<C-Up>` | Increase window height |
| `<C-Down>` | Decrease window height |
| `<C-Left>` | Decrease window width |
| `<C-Right>` | Increase window width |

## VSCode Tasks Integration

| Key | Function |
|-----|----------|
| `<leader>vt` | VSCode Tasks Info |
| `<leader>vr` | Run VSCode Task |

## Special Notes

- **Leader Key**: The leader key is set to `<Space>`
- **Flash.nvim**: Enhanced character search with jump labels
- **Undo/Redo**: Based on Vim's standard undo system (not undo tree)
- **Buffer vs Tab**: We use bufferline for buffer management with `<Tab>`/`<S-Tab>`, and separate tab commands with `<leader>t*`
- **Keybinding Conflicts**: All keybindings have been organized to avoid conflicts between plugins