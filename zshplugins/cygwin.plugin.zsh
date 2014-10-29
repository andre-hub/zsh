
CYGWIN="${CYGWIN} nodosfilewarning"; export CYGWIN

alias browse='explorer .'
alias build='cmd.exe /c "msbuild.exe /consoleloggerparameters:Verbosity=minimal;Summary .\src\bld\master.msbuild"'
alias sln='cygstart `find . -type f -name "*.sln"`'

function _start_sublime() {
  /cygdrive/c/Program\ Files/SublimeText3/sublime_text.exe -a . "$1" &
}
