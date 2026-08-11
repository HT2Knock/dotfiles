return {
  'kristijanhusak/vim-dadbod-ui',
  version = '*',
  cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    {
      'kristijanhusak/vim-dadbod-completion',
      ft = { 'sql', 'mysql', 'plsql' },
      lazy = true,
    },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
    vim.g.db_ui_tmp_query_location = vim.fn.stdpath 'data' .. '/db_ui/tmp'
    vim.g.db_ui_winwidth = 30
    vim.g.db_ui_execute_on_save = 1
    vim.g.db_ui_auto_execute_table_helpers = 1
    vim.g.db_ui_table_helpers = {
      postgres = {
        Count = 'SELECT count(*) FROM "{table}";',
      },
      mysql = {
        Count = 'SELECT count(*) FROM `{table}`;',
      },
      sqlite = {
        Count = 'SELECT count(*) FROM "{table}";',
      },
      duckdb = {
        List = 'SELECT * FROM "{table}" LIMIT 100;',
        Describe = 'DESCRIBE "{table}";',
        Count = 'SELECT count(*) FROM "{table}";',
      },
    }
  end,
  keys = {
    { '<leader>D', '<cmd>DBUIToggle<CR>', desc = 'DB [D]adbod UI' },
  },
  config = function()
    local function parse_env(path)
      local env = {}
      if not path or not vim.uv.fs_stat(path) then
        return env
      end
      for line in io.lines(path) do
        if not line:match '^%s*#' then
          local key, value = line:match '^%s*([%w_]+)%s*=%s*(.-)%s*$'
          if key and value ~= '' then
            env[key] = value:gsub('^["\'](.*)["\']$', '%1')
          end
        end
      end
      return env
    end

    local function find_env_file()
      if vim.env.DADBOD_ENV_FILE then
        return vim.env.DADBOD_ENV_FILE
      end
      local cwd = vim.fn.getcwd()
      for _, file in ipairs(vim.fs.find('.env', { path = cwd, upward = true, limit = 3 })) do
        if parse_env(file).DB_HOST then
          return file
        end
      end
    end

    local function percent_encode(value)
      return vim.uri_encode(value or '', 'RFC2396')
    end

    local function pg_uri(env, prefix)
      local host = env[prefix .. 'DB_HOST']
      if not host then
        return nil
      end
      return ('postgresql://%s:%s@%s:%s/%s?sslmode=%s'):format(
        env[prefix .. 'DB_USER'],
        percent_encode(env[prefix .. 'DB_PASSWORD']),
        host,
        env[prefix .. 'DB_PORT'] or '5432',
        env[prefix .. 'DB_NAME'],
        env[prefix .. 'DB_SSLMODE'] or 'prefer'
      )
    end

    local function mysql_uri(env, prefix)
      local host = env[prefix .. 'DB_HOST']
      if not host then
        return nil
      end
      return ('mysql://%s:%s@%s:%s/%s'):format(
        env[prefix .. 'DB_USER'],
        percent_encode(env[prefix .. 'DB_PASSWORD']),
        host,
        env[prefix .. 'DB_PORT'] or '3306',
        env[prefix .. 'DB_NAME']
      )
    end

    local function setup()
      local dbs = {
        sqlite_dev = 'sqlite:' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p') .. 'dev.db',
        duckdb_memory = 'duckdb:',
      }

      local env = parse_env(find_env_file())
      for name, prefix in pairs { pim_pg = '', pim_afn = 'AFN_', pim_oms = 'OMS_', pim_singlestore = 'SINGLESTORE_' } do
        if env[prefix .. 'DB_HOST'] then
          dbs[name] = name == 'pim_singlestore' and mysql_uri(env, prefix) or pg_uri(env, prefix)
        end
      end

      vim.g.dbs = dbs
    end
    setup()
  end,
}
