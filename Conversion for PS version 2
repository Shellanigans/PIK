(GC .\Untitled1.txt) | %{If($_ -match '::New\('){($_.Split('[')[0]+'(New-Object '+$_.Split('[')[-1]+')') -replace ']::New',' -ArgumentList '}Else{$_}} | Out-File Test2.ps1 -width 10000
