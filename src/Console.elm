port module Console exposing (log)


log : String -> Cmd msg
log message =
    consoleLog message


port consoleLog : String -> Cmd msg
