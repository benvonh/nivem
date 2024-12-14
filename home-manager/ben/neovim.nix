{ inputs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    colorscheme = "catppuccin";

    colorschemes = {
      gruvbox.enable = true;
      onedark.enable = true;
      tokyonight.enable = true;
      catppuccin = {
        enable = true;
        settings.integrations.telescope.style = "nvchad";
      };
    };

    ###########################################
    #                 OPTIONS                 #
    ###########################################
    opts = {
      # tabs
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      expandtab = true;
      # indents
      autoindent = true;
      # smart options
      smarttab = true;
      smartcase = true;
      smartindent = true;
      # show numbers
      number = true;
      # highlight cursor row
      cursorline = true;
      # offset scrolling
      scrolloff = 12;
      # pop-up menu
      pumheight = 8;
      pumwidth = 16;
      # remove bottom space
      cmdheight = 0;
      # column options
      signcolumn = "yes";
      colorcolumn = "120";
      # dark theme
      background = "dark";
      # no wrapping
      wrap = false;
      # no swap file
      swapfile = false;
      # track undo
      undofile = true;
      # split direction
      splitbelow = true;
      splitright = true;
      # prompt confirmation
      confirm = true;
      # neovide font
      guifont = "monospace:h12";
      # recommended session options
      sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";
    };

    autoCmd = [
      {
        event = "FileType";
        pattern = [ "c" "cpp" "nix" ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2";
      }
    ];

    ################################################
    #                 KEY BINDINGS                 #
    ################################################
    globals.mapleader = " ";

    keymaps = [
      { mode = "i"; key = "<c-c>"; action = "<esc>"; }

      { mode = "v"; key = "<"; action = "<gv"; }
      { mode = "v"; key = ">"; action = ">gv"; }
      { mode = "v"; key = "J"; action = ":m '>+1<cr>gv=gv"; }
      { mode = "v"; key = "K"; action = ":m '<-2<cr>gv=gv"; }
      { mode = "v"; key = "p"; action = "\"_dP"; }

      { mode = "n"; key = "n"; action = "nzz"; }
      { mode = "n"; key = "N"; action = "Nzz"; }
      { mode = "n"; key = "<a-h>"; action = "<c-w>H"; }
      { mode = "n"; key = "<a-j>"; action = "<c-w>J"; }
      { mode = "n"; key = "<a-k>"; action = "<c-w>K"; }
      { mode = "n"; key = "<a-l>"; action = "<c-w>L"; }
      { mode = "n"; key = "<c-u>"; action = "<c-u>zz"; }
      { mode = "n"; key = "<c-d>"; action = "<c-d>zz"; }
      { mode = "n"; key = "H"; action = "<cmd>bprev<cr>"; }
      { mode = "n"; key = "L"; action = "<cmd>bnext<cr>"; }

      { mode = ""; key = "<leader>y"; action = "\"+y"; options.desc = "Copy to clipboard"; }
      { mode = ""; key = "<leader>Y"; action = "\"+Y"; options.desc = "Copy line to clipboard"; }
      { mode = ""; key = "<leader>p"; action = "\"+p"; options.desc = "Paste from clipboard"; }
      { mode = ""; key = "<leader>P"; action = "\"+P"; options.desc = "Paste above from clipboard"; }
      { mode = ""; key = "<leader>d"; action = "\"_d"; options.desc = "Delete without copy"; }
      { mode = ""; key = "<leader>D"; action = "\"_D"; options.desc = "Delete without copy to end of line"; }

      { mode = "n"; key = "<leader>q"; action = "<cmd>q<cr>"; options.desc = "Quit buffer"; }
      { mode = "n"; key = "<leader>w"; action = "<cmd>w<cr>"; options.desc = "Write buffer"; }
      { mode = "n"; key = "<leader>a"; action = "<cmd>qa<cr>"; options.desc = "Quit all"; }
      { mode = "n"; key = "<leader>s"; action = "<cmd>wa<cr>"; options.desc = "Save all"; }
      { mode = "n"; key = "<leader>v"; action = "<cmd>vsplit<cr>"; options.desc = "Split pane"; }
      { mode = "n"; key = "<leader>t"; action = "<cmd>vsplit<bar>terminal<cr>"; options.desc = "Open terminal"; }
      { mode = "n"; key = "<leader>c"; action = "<cmd>bp<bar>sp<bar>bn<bar>bd<cr>"; options.desc = "Close buffer"; }

      # TODO: More telescope commands that I can add :)
      { mode = "n"; key = "<leader>o"; action = "<cmd>TodoTelescope<cr>"; options.desc = "Search TODO"; }
      { mode = "n"; key = "<leader>."; action = "<cmd>SessionSearch<cr>"; options.desc = "Search session"; }
      { mode = "n"; key = "<leader>l"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>f"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>h"; action = "<cmd>Noice history<cr>"; options.desc = "Show message history"; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<cr>"; options.desc = "Toggle file explorer"; }
      { mode = "n"; key = "<leader>m"; action = "<cmd>MarkdownPreviewToggle<cr>"; options.desc = "Toggle markdown preview"; }
      { mode = "n"; key = "<leader>z"; action = "<cmd>set laststatus=0 ruler<cr>"; options.desc = "Hide status bar"; }
      { mode = "n"; key = "<leader>u"; action = "<cmd>lua require('lualine').hide({unhide=true})<cr>"; options.desc = "Show status bar"; }
      { mode = "n"; key = "<leader>xd"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Workspace Diagnostics"; }
      { mode = "n"; key = "<leader>xb"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; options.desc = "Buffer Diagnostics"; }
      { mode = "n"; key = "<leader>xl"; action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>"; options.desc = "LSP"; }
      { mode = "n"; key = "<leader>xs"; action = "<cmd>Trouble symbols toggle focus=false<cr>"; options.desc = "Symbols"; }

      { mode = "t"; key = "<esc>"; action = "<c-\\><c-n>"; }
    ];

    ############################################
    #                 PLUG-INS                 #
    ############################################
    plugins.comment.enable = true;
    plugins.fugitive.enable = true;
    plugins.lastplace.enable = true;
    plugins.markdown-preview.enable = true;
    plugins.nix.enable = true;
    plugins.notify.enable = true;
    plugins.nvim-colorizer.enable = true;
    plugins.rainbow-delimiters.enable = true;
    plugins.scrollview.enable = true;
    plugins.tmux-navigator.enable = true;
    plugins.todo-comments.enable = true;
    plugins.treesitter.enable = true;
    plugins.trouble.enable = true;
    plugins.web-devicons.enable = true;
    plugins.which-key.enable = true;

    plugins.auto-session = {
      enable = true;
      settings = {
        enabled = true;
        auto_save = true;
        auto_create = false;
        auto_restore = true;
        auto_restore_last_session = false;
      };
    };

    plugins.bufferline = {
      enable = true;
      settings.options.offsets = [
        {
          filetype = "NvimTree";
          text = "File Explorer";
          text_align = "center";
          separator = true;
        }
      ];
    };

    plugins.dashboard = {
      enable = true;
      settings.config = {
        project.enable = false;
        footer = [ " neovim powered by nix  " ];
        header = [
          "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
          "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
          "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
          "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
          "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
          "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
        ];
      };
    };

    plugins.lualine = {
      enable = true;
      settings.options = {
        globalstatus = true;
        section_separators.left = "";
        section_separators.right = "";
        component_separators.left = "";
        component_separators.right = "";
      };
    };

    plugins.noice = {
      enable = true;
      settings.lsp = {
        progress.enabled = false;
        override = {
          "cmp.entry.get_documentation" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
        };
      };
    };

    plugins.nvim-autopairs = {
      enable = true;
      settings = {
        map_c_w = true;
        check_ts = true;
        enable_abbr = true;
      };
    };

    plugins.nvim-tree = {
      enable = true;
      git.ignore = false;
      hijackCursor = true;
      diagnostics.enable = true;
      diagnostics.showOnDirs = true;
      updateFocusedFile.enable = true;
      renderer = {
        icons.gitPlacement = "after";
        icons.show.folderArrow = false;
        indentMarkers.enable = false;
      };
    };

    plugins.indent-blankline = {
      enable = true;
      settings = {
        indent.char = "▏";
        scope.show_end = false;
        scope.show_start = false;
        exclude.filetypes = [ "dashboard" ];
      };
    };

    plugins.telescope = {
      enable = true;
      settings = {
        defaults = {
          prompt_prefix = "  ";
          selection_caret = "󰓾 ";
          sorting_strategy = "ascending";
          layout_config.prompt_position = "top";
        };
      };
    };

    #######################################
    #                 LSP                 #
    #######################################
    plugins.lsp = {
      enable = true;
      keymaps = {
        diagnostic = {
          "<leader>j" = "goto_next";
          "<leader>k" = "goto_prev";
        };
        lspBuf = {
          K = "hover";
          gd = "definition";
          gD = "declaration";
          gi = "implementation";
          gt = "type_definition";
          gr = "references";
          gs = "signature_help";
          "<F2>" = "rename";
          "<F3>" = "format";
          "<F4>" = "code_action";
        };
      };
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        cmake.enable = true;
        csharp_ls.enable = true;
        cssls.enable = true;
        dockerls.enable = true;
        html.enable = true;
        htmx.enable = true;
        java_language_server.enable = true;
        jsonls.enable = true;
        ltex.enable = true;
        lua_ls.enable = true;
        nixd.enable = true;
        pyright.enable = true;
        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
        yamlls.enable = true;
      };
    };

    plugins.cmp = {
      enable = true;
      settings = {
        sources = [
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "nvim_lsp_document_symbol"; }
        ];
        mapping = {
          "<cr>" = "cmp.mapping.confirm()";
          "<c-e>" = "cmp.mapping.abort()";
          "<c-u>" = "cmp.mapping.scroll_docs(4)";
          "<c-d>" = "cmp.mapping.scroll_docs(-4)";
          "<tab>" = "cmp.mapping.select_next_item()";
          "<s-tab>" = "cmp.mapping.select_prev_item()";
        };
      };
    };
  };
}
