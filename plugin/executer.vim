
command! -bar ExecuterRun :luado Executer_run()

lua <<EOF

local termApp = "urxvtc -e"

function Executer_run()
  local findCmd = "find . -executable -type f -printf \"%T@ %Tc %p\\n\" | sort -rn | awk '{ print $NF }'"
  local executable

  for line in io.popen(findCmd):lines() do
    executable = line
    break
  end

  if executable then
    local sessionName = string.gsub(executable, "(.*/)(.*)", "%2")
    local sessionExists = os.execute("tmux has-session -t " .. sessionName)

    if not sessionExists then
      os.execute("tmux new-session -d -s " .. sessionName)
      os.execute(termApp .. " tmux attach-session -t " .. sessionName.. " &")
    end

    os.execute("tmux send-keys -t " .. sessionName .. " '" .. executable .. "' Enter")
  end
end
EOF

