$NL = [System.Environment]::NewLine
(
    (GC -ReadCount 0 .\Actions.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\Interpreter.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\IF_While.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\GUI_Funcs.ps1 | Out-String)+$NL+
    "`$CSharpCode = @'"+$NL+
    (GC -ReadCount 0 .\Wrapper.cs | Out-String)+$NL+
    "'@"+$NL+
    (GC -ReadCount 0 .\GUI.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\Commands.ps1 | Out-String)
) | Out-File .\pik.ps1 -Encoding UTF8
