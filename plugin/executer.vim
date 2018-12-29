
command! -bar ExecuterRun :lua Executer_run()

let g:Executer_executable = ''
let g:Executer_terminal = 'urxvtc -e'
let g:Executer_args = ''

lua <<EOF
function Executer_run()
  local termApp = vim.eval("g:Executer_terminal")
  local findCmd = "ls -1t `find . -executable -type f`"
  local executable = vim.eval("g:Executer_executable")
  local args = vim.eval("g:Executer_args")

  if executable == '' then
    for line in io.popen(findCmd):lines() do
      executable = line
      break
    end
  end

  if executable ~= '' then
    local sessionName = string.gsub(executable, "(.*/)(.*)", "%2")
    local sessionExists = os.execute("tmux has-session -t " .. sessionName)

    if not sessionExists then
      os.execute("tmux new-session -d -s " .. sessionName)
      os.execute(termApp .. " tmux attach-session -t " .. sessionName.. " &")
    end

    os.execute("tmux send-keys -t " .. sessionName .. " '" .. executable .. " " .. args .. "' Enter")
  end
end
EOF

