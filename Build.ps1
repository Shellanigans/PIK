$NL = [System.Environment]::NewLine
(
    (GC -ReadCount 0 .\Actions.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\Interpret.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\IF_While.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\GUI_Funcs.ps1 | Out-String)+$NL+
    "`$CSharpCode = @'"+$NL+
    (GC -ReadCount 0 .\Wrapper.cs | Out-String)+$NL+
    "'@"+$NL+
    (GC -ReadCount 0 .\GUI.ps1 | Out-String)+$NL+
    (GC -ReadCount 0 .\Commands.ps1 | Out-String)
) | Out-File .\pik.ps1 -Encoding UTF8
Try{
    [ScriptBlock]::Create((GC -ReadCount 0 .\pik.ps1 | Out-String)).Invoke()
}Catch{
    Write-Host $Error[0]
}

#Sleep 30