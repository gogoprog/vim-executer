
command! -bar ExecuterRun :lua Executer_run()
command! -bar ExecuterSelectExecutable :lua Executer_selectExecutable()
command! -bar ExecuterSelectWorkingDirectory :lua Executer_selectWorkingDirectory()

let g:Executer_executable = get(g:, 'Executer_executable', "")
let g:Executer_workingDirectory = get(g:, 'Executer_workingDirectory', "")
let g:Executer_terminal = get(g:, 'Executer_terminal', 'urxvtc -e')
let g:Executer_args = get(g:, 'Executer_args', "")

lua <<EOF
local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

local function run_and_get_stdout(command)
    for line in io.popen(command):lines() do
      return line
    end
end

local function quote(str) 
  return "\"" .. str .. "\""
end

local tmpfilepath = "/tmp/vim-executer"

function Executer_run()
  local executable = vim.eval("g:Executer_executable")

  if executable == '' then
  local findCmd = "ls -1t `find . -executable -type f`"
    for line in io.popen(findCmd):lines() do
      executable = line
      break
    end
  end

  if executable ~= '' then
    local cwd = vim.eval("g:Executer_workingDirectory")
    local args = vim.eval("g:Executer_args")

    local sessionName = "vim-executer"
    local sessionExists = os.execute("tmux has-session -t " .. sessionName)

    if not sessionExists then
      local termApp = vim.eval("g:Executer_terminal")
      os.execute("tmux new-session -d -s " .. sessionName)
      os.execute(termApp .. " tmux attach-session -t " .. sessionName.. " &")
    end

    local command = executable .. " " .. args
    if cwd ~= '' then

      command = "cd " .. cwd .. " && " .. command
    end

    os.execute("tmux send-keys -t " .. sessionName .. " '" .. command .. "' Enter")
  end
end

function Executer_selectExecutable()
  vim.command(":silent !find -type f -executable -not -path '*/\\.*' | fzf --header=\"Executer: Select executable file...\" > " .. tmpfilepath)
  local result = read_file(tmpfilepath)
  local absolute_executable = run_and_get_stdout("readlink -f " .. result)
  vim.command(":let g:Executer_executable=" .. quote(absolute_executable))
end

function Executer_selectWorkingDirectory()
  vim.command(":silent !find -type d -not -path '*/\\.*' | fzf --header=\"Executer: Select working directory...\" > " .. tmpfilepath)
  local result = read_file(tmpfilepath)
  local absolute_directory = run_and_get_stdout("readlink -f " .. result)
  vim.command(":let g:Executer_workingDirectory=" .. quote(absolute_directory))
end
EOF
