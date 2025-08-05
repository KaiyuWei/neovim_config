if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- DAP (Debug Adapter Protocol) configuration
-- This file configures debuggers for various languages

---@type LazySpec
return {
  -- Core DAP plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",           -- UI for DAP
      "theHamsta/nvim-dap-virtual-text", -- Virtual text showing variable values
      "nvim-neotest/nvim-nio",          -- Required for dap-ui
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI
      dapui.setup()

      -- Setup virtual text
      require("nvim-dap-virtual-text").setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- DAP Keybindings
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "Debug: Toggle UI" })

      -- ===========================================
      -- LANGUAGE-SPECIFIC DEBUGGER CONFIGURATIONS
      -- ===========================================

      -- PHP Debugger (Xdebug)
      -- Install: php-debug-adapter via Mason
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { 
          vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" 
        }
      }

      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          pathMappings = {
            ["/app"] = "${workspaceFolder}", -- Adjust for Docker if needed
          },
        },
        {
          type = "php",
          request = "launch", 
          name = "Launch currently open script",
          program = "${file}",
          cwd = "${fileDirname}",
          port = 0,
          runtimeArgs = {
            "-dxdebug.start_with_request=yes"
          },
          env = {
            XDEBUG_MODE = "debug,develop",
            XDEBUG_CONFIG = "client_port=${port}"
          }
        },
      }

      -- Python Debugger (debugpy)
      -- Install: debugpy via Mason
      dap.adapters.python = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file with arguments",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " ", true)
          end,
          pythonPath = function()
            return "/usr/bin/python3"
          end,
        },
      }

      -- Node.js/JavaScript Debugger
      -- Install: js-debug-adapter via Mason
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}"
          },
        }
      }

      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- TypeScript configuration (same as JavaScript)
      dap.configurations.typescript = dap.configurations.javascript

      -- Go Debugger (Delve)
      -- Install: delve via Mason
      dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        }
      }

      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}"
        },
        {
          type = "delve",
          name = "Debug test",
          request = "launch",
          mode = "test",
          program = "${file}"
        },
        {
          type = "delve",
          name = "Debug test (go.mod)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}"
        }
      }

      -- Lua Debugger (local-lua-debugger-vscode)
      -- Install: local-lua-debugger-vscode via Mason
      dap.adapters["local-lua"] = {
        type = "executable",
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/extension/debugAdapter.js"
        },
        enrich_config = function(config, on_config)
          if not config["extensionPath"] then
            local c = vim.deepcopy(config)
            c.extensionPath = vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/"
            on_config(c)
          else
            on_config(config)
          end
        end,
      }

      dap.configurations.lua = {
        {
          type = "local-lua",
          request = "launch",
          name = "Debug current file (local-lua-dbg, lua)",
          program = {
            lua = "lua",
            file = "${file}",
          },
          args = {},
        },
      }

      -- C/C++ Debugger (codelldb)
      -- Install: codelldb via Mason
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb",
          args = { "--port", "${port}" },
        }
      }

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- C configuration (same as C++)
      dap.configurations.c = dap.configurations.cpp

      -- Rust Debugger (uses codelldb)
      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- DAP Signs (breakpoint indicators)
      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "💬", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "❌", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
    end,
  },
}