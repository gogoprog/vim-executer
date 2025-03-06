
command! -bar ExecuterRun :lua Executer_run()
command! -bar ExecuterSelectExecutable :call Executer_iselect_executable()
command! -bar ExecuterSelectWorkingDirectory :call Executer_iselect_wd()
command! -bar ExecuterSave :call Executer_save()

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
  local executable = vim.g.Executer_executable

  if executable == '' then
  local findCmd = "ls -1t `find . -executable -type f`"
    for line in io.popen(findCmd):lines() do
      executable = line
      break
    end
  end

  if executable ~= '' then
    local cwd = vim.g.Executer_workingDirectory
    local args = vim.g.Executer_args

    local sessionName = "vim-executer"
    local sessionExists = os.execute("tmux has-session -t " .. sessionName)

    if sessionExists == 256 then
      local termApp = vim.g.Executer_terminal
      os.execute("tmux new-session -d -s " .. sessionName)
      os.execute(termApp .. " tmux attach-session -t " .. sessionName.. " &")
    end

    local command = executable .. " " .. args
    if cwd ~= '' then
      command = "cd " .. cwd .. " && " .. command
    end

    os.execute("tmux send-keys -t " .. sessionName .. " C-c")

    os.execute("tmux send-keys -t " .. sessionName .. " '" .. command .. "' Enter")
  end
end
EOF

function Executer_iselect_executable()
  call fzf#run({'source': 'find -type f -executable -not -path "*/\\.*"', 'sink': function('Executer_select_executable')})
endfunction

function Executer_select_executable(file)
  :let g:Executer_executable=fnamemodify(a:file, ':p')
endfunction

function Executer_iselect_wd()
  call fzf#run({'source': 'find -type d -not -path "*/\\.*"', 'sink': function('Executer_select_wd')})
endfunction

function Executer_select_wd(file)
  :let g:Executer_workingDirectory=fnamemodify(a:file, ':p')
endfunction

function Executer_save_var(name, value)
  if empty(a:value)
  else
    let line="let " . a:name . "=\"" . a:value . "\""
    call writefile([line], ".vimrc", "a")
  end
endfunction

function Executer_save()
  :call Executer_save_var("g:Executer_executable", g:Executer_executable)
  :call Executer_save_var("g:Executer_workingDirectory", g:Executer_workingDirectory)
  :call Executer_save_var("g:Executer_terminal", g:Executer_terminal)
  :call Executer_save_var("g:Executer_args", g:Executer_args)
endfunction
