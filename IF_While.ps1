Function Parse-IfEl{
    Param([String]$X,[Switch]$WhatIf)
    #[System.Console]::WriteLine('INSIDE IFEL')
    If(!$SyncHash.Stop){
        If($X -match '{IF \(.*?\)}' -AND !$Script:Inside_If){
            If($ShowCons.Checked){[System.Console]::WriteLine($NL + 'BEGIN IF')}
            If($ShowCons.Checked){[System.Console]::WriteLine('--------')}
            
            $Script:Inside_If = $True
            $Script:IfElDepth = 0
            $Script:IfElEval = $False
            $X = $X.Replace('{IF (','')
            $X = $X.Substring(0,($X.Length - 2))
            $Comparator = ''
            $Script:BufferedCommandsIfEl = ''
            $PHEsc1 = $False
            $PHEsc2 = $False
            If($X -match '-'){
                $Comparator = $X.Split('-')[-1]
                $Comparator = $Comparator.Split(' ')[0]
                $Op1 = ($X -replace '-.*','').Trim(' ')
                $Op2 = ($X -replace ('.*-'+$Comparator),'').Trim(' ')
                
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND1: ' + $Op1)}
                $Op1,$PHEsc1 = (Interpret $Op1)
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND2: ' + $Op2)}
                $Op2,$PHEsc2 = (Interpret $Op2)
                If($ShowCons.Checked){[System.Console]::WriteLine('COMPARATOR: ' + $Comparator)}
            }Else{
                $Op1,$PHEsc1 = (Interpret $X)
                $Comparator = $Op1
                $Op2 = ''
            }
            $Caught = $False
            If(!$PHEsc1 -AND !$PHEsc2){
                Switch($Comparator){
                    'MATCH'    {If($Op1 -match $Op2)                       {$Script:IfElEval = $True}}
                    'EQ'       {If($Op1 -eq $Op2)                          {$Script:IfElEval = $True}}
                    'LIKE'     {If($Op1 -like $Op2)                        {$Script:IfElEval = $True}}
                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$Script:IfElEval = $True}}
                    'NE'       {If($Op1 -ne $Op2)                          {$Script:IfElEval = $True}}
                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$Script:IfElEval = $True}}
                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$Script:IfElEval = $True}}
                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$Script:IfElEval = $True}}
                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$Script:IfElEval = $True}}
                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$Script:IfElEval = $True}}
                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$Script:IfElEval = $True}}
                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$Script:IfElEval = $True}}
                }
                If($ShowCons.Checked -AND $Caught){[System.Console]::WriteLine($Tab + 'ERROR! COULD NOT CONVERT TO NUMERIC!')}
                If($Comparator -eq 'TRUE' -OR $Comparator -eq 'FALSE'){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'IF STATEMENT: {IF (' + $Comparator + ')}')}
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'IF STATEMENT: {IF (' + $OP1 + ' -' + $Comparator + ' ' + $OP2 + ')}')}
                }
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'EVALUATION: ' + $Script:IfElEval.ToString().ToUpper() + $NL)}
            }
            Else{
                If($ShowCons.Checked){[System.Console]::WriteLine('IF STATEMENT FAILED! CHECK PARAMS! AN ARGUMENT WAS ESCAPED FOR SOME REASON!')}
            }
        }ElseIf($Script:Inside_If){
            If($X -match '{IF \(.*?\)}'){
                $Script:IfElDepth++
            }
            If($X -match '{FI}'){
                If($Script:IfElDepth -gt 0){
                    $Script:BufferedCommandsIfEl+=($NL+$X)
                    $Script:IfElDepth--
                }Else{
                    $Script:Inside_If = $False
                    $Script:IfElDepth = 0
                    $PH = ($Script:BufferedCommandsIfEl.Split($NL) | ?{$_ -ne ''})
                    $Script:BufferedCommandsIfEl = ''
                    $PH | %{$TF = $True; $PHDepth = 0; $PHT=''; $PHF=''}{
                        $Temp = $_
                        If($Temp -match '{IF \(.*?\)}'){
                            $PHDepth++
                        }
                        If($Temp -match '{ELSE}'){
                            If($PHDepth -eq 0){
                                $TF = $False
                                $Temp = ''
                            }Else{
                                $PHDepth++
                            }
                        }
                        If($Temp -match '{FI}' -AND $PHDepth){
                            If(!($PHDepth % 2)){
                                $PHDepth--
                            }
                            $PHDepth--
                            #If(!$PHDepth){$Temp = ''}
                        }ElseIf($Temp -match '{FI}'){
                            $Temp = ''
                        }
                        If($TF){
                            $PHT+=($NL+$Temp)
                        }Else{
                            $PHF+=($NL+$Temp)
                        }
                    }
                    $PHOut = ($(If($Script:IfElEval){$PHT}Else{$PHF}).Split($NL) | ?{$_ -ne ''})
                
                    $Script:IfElEval = $False
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'FOLLOWING COMMANDS WILL BE RUN:')}
                    If($ShowCons.Checked){$PHOut | %{[System.Console]::WriteLine($Tab*2+$_)}}
                    If($ShowCons.Checked){[System.Console]::WriteLine('------')}
                    If($ShowCons.Checked){[System.Console]::WriteLine('END IF'+$NL)}
                    
                    $PHOut | %{
                        $_.Split($NL) | ?{$_ -ne ''} | %{$Break = $False}{
                            If(!$Break -AND !$SyncHash.Stop){
                                If($_ -notmatch '{BREAK}'){
                                    If(!$WhatIf){
                                       [Void](Parse-While $_)
                                    }Else{
                                       [Void](Parse-While $_ -WhatIf)
                                    }
                                }Else{$Break = $True}
                            }
                        }
                    }
                }
            }Else{
                $Script:BufferedCommandsIfEl+=($NL+$X)
            }
        }Else{
            If(!$WhatIf){
                #Write-Host 'NEW LINE IN ACTIONS'
                [Void](Actions $X)
            }Else{
                [Void](Actions $X -WhatIf)
            }
        }
    }
}

Function Parse-While{
    Param([String]$X,[Switch]$WhatIf)
    #[System.Console]::WriteLine('INSIDE WHILE')
    If(!$SyncHash.Stop){
        If($X -match '{WHILE \(.*?\)}' -AND !$Script:Inside_While -AND !$Script:Inside_If){
            If($ShowCons.Checked){[System.Console]::WriteLine($NL + 'BEGIN WHILE')}
            If($ShowCons.Checked){[System.Console]::WriteLine('--------')}
            
            $Script:Inside_While = $True
            $Script:WhileDepth = 1
            $Script:WhileEval = $False
            $Script:BufferedCommandsWhile = $X
            $X = $X.Replace('{WHILE (','')
            $X = $X.Substring(0,($X.Length - 2))
            $Comparator = ''
            $PHEsc1 = $False
            $PHEsc2 = $False
            If($X -match '-'){
                $Comparator = $X.Split('-')[-1]
                $Comparator = $Comparator.Split(' ')[0]
                $Op1 = ($X -replace '-.*','').Trim(' ')
                $Op2 = ($X -replace ('.*-'+$Comparator),'').Trim(' ')
                
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND1: ' + $Op1)}
                $Op1,$PHEsc1 = (Interpret $Op1)
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND2: ' + $Op2)}
                $Op2,$PHEsc2 = (Interpret $Op2)
                If($ShowCons.Checked){[System.Console]::WriteLine('COMPARATOR: ' + $Comparator)}
            }Else{
                $Op1,$PHEsc1 = (Interpret $X)
                $Comparator = $Op1
                $Op2 = ''
            }
            $Caught = $False
            If(!$PHEsc1 -AND !$PHEsc2){
                Switch($Comparator){
                    'MATCH'    {If($Op1 -match $Op2)                       {$Script:WhileEval = $True}}
                    'EQ'       {If($Op1 -eq $Op2)                          {$Script:WhileEval = $True}}
                    'LIKE'     {If($Op1 -like $Op2)                        {$Script:WhileEval = $True}}
                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$Script:WhileEval = $True}}
                    'NE'       {If($Op1 -ne $Op2)                          {$Script:WhileEval = $True}}
                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$Script:WhileEval = $True}}
                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$Script:WhileEval = $True}}
                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$Script:WhileEval = $True}}
                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$Script:WhileEval = $True}}
                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$Script:WhileEval = $True}}
                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$Script:WhileEval = $True}}
                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$Script:WhileEval = $True}}
                }
                If($ShowCons.Checked -AND $Caught){[System.Console]::WriteLine($Tab + 'ERROR! COULD NOT CONVERT TO NUMERIC!')}
                If($Comparator -eq 'TRUE' -OR $Comparator -eq 'FALSE'){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'WHILE STATEMENT: {WHILE (' + $Comparator + ')}')}
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'WHILE STATEMENT: {WHILE (' + $OP1 + ' -' + $Comparator + ' ' + $OP2 + ')}')}
                }
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'EVALUATION: ' + $Script:WhileEval.ToString().ToUpper() + $NL)}
            }
            Else{
                If($ShowCons.Checked){[System.Console]::WriteLine('WHILE STATEMENT FAILED! CHECK PARAMS! AN ARGUMENT WAS ESCAPED FOR SOME REASON!')}
            }
        }ElseIf($Script:Inside_While){
            If($X -match '{WHILE \(.*?\)}'){
                $Script:WhileDepth++
            }
            If($X -match '{END WHILE}'){
                If($Script:WhileDepth -gt 1){
                    $Script:BufferedCommandsWhile+=($NL+$X)
                    $Script:WhileDepth--
                }Else{
                    $Script:Inside_While = $False
                    $Script:WhileDepth = 1
                    #$Script:BufferedCommandsWhile+=($NL+$X)
                    $PH = ($Script:BufferedCommandsWhile.Split($NL) | ?{$_ -ne ''})
                    $Script:BufferedCommandsWhile = ''
                    $PH | %{$PHDepth = 1; $PHOut = ''}{
                        $Temp = $_
                        If($Temp -match '{WHILE \(.*?\)}'){
                            $PHDepth++
                        }
                        If($Temp -match '{END WHILE}' -AND ($PHDepth -gt 0)){
                            $PHDepth--
                        }ElseIf($Temp -match '{END WHILE}'){$Temp = ''}
                        $PHOut+=($NL+$Temp)
                    }
                    If($Script:WhileEval){
                        $PHOut = (($PHOut).Split($NL) | ?{$_ -ne ''})
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'FOLLOWING COMMANDS WILL BE RUN UNTIL '+$PHOut[0]+' IS FALSE:')}
                        If($ShowCons.Checked){$PHOut | Select -Skip 1 | %{[System.Console]::WriteLine($Tab*2+$_)}}
                        If($ShowCons.Checked){[System.Console]::WriteLine('------')}
                        If($ShowCons.Checked){[System.Console]::WriteLine('END WHILE'+$NL)}
                        $X = $PHOut[0]
                        $X = $X.Replace('{WHILE (','')
                        $X = $X.Substring(0,($X.Length - 2))
                    
                        Do{
                            $TempWhileEval = $False
                            $PHEsc1 = $False
                            $PHEsc2 = $False
                            If($X -match '-'){
                                $Comparator = $X.Split('-')[-1]
                                $Comparator = $Comparator.Split(' ')[0]
                                $Op1 = ($X -replace '-.*','').Trim(' ')
                                $Op2 = ($X -replace ('.*-'+$Comparator),'').Trim(' ')
                
                                $Op1,$PHEsc1 = (Interpret $Op1 -SuppressConsole)
                                $Op2,$PHEsc2 = (Interpret $Op2 -SuppressConsole)
                            }Else{
                                $Op1,$PHEsc1 = (Interpret $X -SuppressConsole)
                                $Comparator = $Op1
                                $Op2 = ''
                            }
                            $Caught = $False
                            If(!$PHEsc1 -AND !$PHEsc2){
                                Switch($Comparator){
                                    'MATCH'    {If($Op1 -match $Op2)                       {$TempWhileEval = $True}}
                                    'EQ'       {If($Op1 -eq $Op2)                          {$TempWhileEval = $True}}
                                    'LIKE'     {If($Op1 -like $Op2)                        {$TempWhileEval = $True}}
                                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$TempWhileEval = $True}}
                                    'NE'       {If($Op1 -ne $Op2)                          {$TempWhileEval = $True}}
                                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$TempWhileEval = $True}}
                                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$TempWhileEval = $True}}
                                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$TempWhileEval = $True}}
                                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$TempWhileEval = $True}}
                                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$TempWhileEval = $True}}
                                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$TempWhileEval = $True}}
                                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$TempWhileEval = $True}}
                                }
                            }
                            If($TempWhileEval){
                                $PHOut | Select -Skip 1 | ?{$_ -ne ''} | %{$Break = $False}{
                                    If(!$Break -AND !$SyncHash.Stop){
                                        If($_ -notmatch '{BREAK}'){
                                            If(!$WhatIf){
                                                [Void](Parse-While $_)
                                            }Else{
                                                [Void](Parse-While $_ -WhatIf)
                                            }
                                        }Else{$Break = $True; $TempWhileEval = $False}
                                    }
                                }
                            }
                        }While($TempWhileEval -AND !$SyncHash.Stop)
                    }Else{
                        If($ShowCons.Checked){[System.Console]::WriteLine('------')}
                        If($ShowCons.Checked){[System.Console]::WriteLine('END WHILE'+$NL)}
                    }
                }
            }Else{
                $Script:BufferedCommandsWhile+=($NL+$X)
            }
        }Else{
            If(!$WhatIf){
                #Write-Host 'NEW LINE IN WHILE'
                [Void](Parse-IfEl $X)
            }Else{
                [Void](Parse-IfEl $X -WhatIf)
            }
        }
    }
}