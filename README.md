# vim-executer

Select and run executables in tmux session from Vim

## Requirements

  * [fzf](https://github.com/junegunn/fzf)
  
## Installation

### Vundle

Add the following line to ```.vimrc```

    Plugin 'gogoprog/vim-executer'

## Commands

| Name                  | Description                             |
|-----------------------|-----------------------------------------|
| ExecuterSelectExecutable | Select the executable using `fzf`         |
| ExecuterSelectWorkingDirectory   | Select the working directory using `fzf`  |
| ExecuterRun | Run the executable from the working directory in a tmux session |
