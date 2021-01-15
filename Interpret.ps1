Function Interpret{
    Param([String]$X,[Switch]$SuppressConsole)
    #Do the really basic parsing
    #Write-Host 'NEW LINE IN INTERPRET FUNC'
    $X = [Parse]::KeyWord($X)
    #Write-Host 'NEW LINE IN INTERPRET POST FUNC'
    #[System.Console]::WriteLine('INSIDE INTERPRET')
    #Reset the depth overflow (useful for finding bad logic with infinite loops)
    $DepthOverflow = 0
    #Don't exit until we see no more matches to any of the following substitution keywords or we hit the depth overflow
    While(
            $DepthOverflow -lt 500 -AND `
            !$SyncHash.Stop -AND `
            (($X -match '{VAR ') -OR `
            ($X -match '{LEN ') -OR `
            ($X -match '{ABS ') -OR `
            ($X -match '{POW ') -OR `
            ($X -match '{SIN ') -OR `
            ($X -match '{COS ') -OR `
            ($X -match '{TAN ') -OR `
            ($X -match '{RND ') -OR `
            ($X -match '{FLR ') -OR `
            ($X -match '{SQT ') -OR `
            ($X -match '{CEI ') -OR `
            ($X -match '{MOD ') -OR `
            ($X -match '{EVAL ') -OR `
            ($X -match '{VAR \S*\+\+}') -OR `
            ($X -match '{VAR \S*\+=') -OR `
            ($X -match '{VAR \S*--}') -OR `
            ($X -match '{VAR \S*-=') -OR `
            ($X -match '{PWD') -OR `
            ($X -match '{MANIP ') -OR `
            ($X -match '{GETCON ') -OR `
            ($X -match '{FINDVAR ') -OR `
            ($X -match '{GETPROC ') -OR `
            ($X -match '{GETPIX ') -OR `
            ($X -match '{FINDIMG ') -OR `
            ($X -match '{GETWIND ') -OR `
            ($X -match '{GETWINDTEXT ') -OR `
            ($X -match '{GETFOCUS') -OR `
            ($X -match '{GETSCREEN') -OR `
            ($X -match '{TESTPATH') -OR `
            ($X -match '{READIN '))
        ){
        
        $PHSplitX = $X.Split('{}')
        
        #Perform all the var substitutions now that are not for var setting, by replacing the string with the value stored in the VarHash
        While($X -match '{VAR [\w\d_:]*?}' -AND !$SyncHash.Stop){
            $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -notmatch '=' -AND $_ -notmatch '\+\+$' -AND $_ -notmatch '--$' -AND $_ -notmatch '\+=' -AND $_ -notmatch '-='} | %{
                $PH = $_.Split(' ')[1]
                $PHFound = $True
                If($Script:VarsHash.ContainsKey($PH)){
                    $X = $X.Replace(('{'+$_+'}'),($Script:VarsHash.$PH))
                }ElseIf($Script:VarsHash.ContainsKey(($PH+'_ESCAPED'))){
                    $X = $X.Replace(('{'+$_+'}'),($Script:VarsHash.($PH+'_ESCAPED')))
                    $Esc = $True
                }Else{
                    $X = ''
                    $PHFound = $False
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
                }
                If($PHFound){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab + 'INTERPRETED VALUE: ' + $X)}}
            }
            $PHSplitX = $X.Split('{}')
        }
        
        #Replace the keyword with the content from a file
        $PHSplitX | ?{$_ -match 'GETCON \S+'} | %{
            $X = ($X.Replace(('{'+$_+'}'),((GC $_.Substring(7)) | Out-String)))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the path with a result for Test-Path
        $PHSplitX | ?{$_ -match 'TESTPATH \S+'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(Test-Path ($_.Substring(9))).ToString().ToUpper()))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'TESTPATH RESULT: '+$X)}
        }
        #Replace the keyword with the dimension of all screens separated by semi-colons
        $PHSplitX | ?{$_ -match 'GETSCREEN'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(([GUI.ScreenInfo]::All | %{$PH = $_.Bounds; [String]$PH.X+','+$PH.Y+','+$PH.Width+','+$PH.Height}) -join ';').TrimEnd(';')))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the keyword with the present working directory
        $PHSplitX | ?{$_ -match '^PWD$'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(PWD).Path))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the keyword with the names of all variables matching the regex in the keyword (e.g. {FINDVAR Temp.*})
        $PHSplitX | ?{$_ -match 'FINDVAR \S+'} | %{
            $X = (($Script:VarsHash.Keys | ?{$_ -match ($X -replace '^{FINDVAR ' -replace '}$')} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort}) -join ',')
        }
    
        $PHSplitX | ?{
                ($_ -match 'GETPROC ((?!-(ID|HAND) )\S+|-ID \d+|-HAND \d+)') -OR `
                ($_ -match 'GETWIND ((?!-(ID|HAND) )\S+|-ID \d+|-HAND \d+)') -OR `
                ($_ -match 'GETWINDTEXT ((?!-(ID|HAND) )\S+|-ID \d+|-HAND \d+)') -OR `
                ($_ -match 'GETFOCUS( -ID| -HAND)?')
        } | %{
            $PHProc = $_
            $PHSel = $PHProc.Split(' ')[0]
            $TrueHand = $False
            If($_ -notmatch 'GETFOCUS'){
                $PHProc = $PHProc.Split(' ')[-1]
            }
            $PHID = $False
            If($_ -match ' -ID '){
                $PHID = $True
                If(($Script:HiddenWindows.Keys -join '')){
                    $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProc+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                    $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProc+'_'+$LastHiddenTime+'$')})
                }
                $PHProc = @(PS -Id $PHProc | ?{$_.MainWindowHandle -ne 0})
            }ElseIf($_ -match ' -HAND '){
                $PHProcHand = $PHProc
                #If(($Script:HiddenWindows.Keys -join '')){
                #    $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                #    $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_'+$LastHiddenTime+'$')})
                #}
                $PHProc = @(PS | ?{[String]($_.MainWindowHandle) -eq $PHProcHand})
                If($PHProc){
                    $PHHidden = ''
                }Else{
                    $TrueHand = $True
                    $PHProcHand = [IntPtr][Int]$PHProcHand
                    Try{
                        $PHTextLength = [GUI.Window]::GetWindowTextLength($PHProcHand)
                        $PHString = ([N.e]::w([System.Text.StringBuilder],@(($PHTextLength + 1))))
                        [Void]([GUI.Window]::GetWindowText($PHProcHand, $PHString, $PHString.Capacity))
                        If(!$PHString){
                            $PHProc = ''
                            $PHHidden = ''
                        }Else{
                            $PHHidden = $PHProcHand
                        }
                    }Catch{$PHProc = ''; $PHHidden = ''}
                }
            }ElseIf($_ -notmatch 'GETFOCUS'){
                If(($Script:HiddenWindows.Keys -join '')){
                    $PHHidden = (($Script:HiddenWindows.Keys | ?{$_ -match ('^'+$PHProc+'_')}) | %{$Script:HiddenWindows.$_})
                }
                $PHProc = @(PS $PHProc | ?{$_.MainWindowHandle -ne 0})
            }
            If($PHHidden){$PHProc+=$PHHidden}
            $PHOut = ''
            If($PHProc.Count -OR $PHProc -match 'GETFOCUS'){
                $PHProc | %{
                    If($TrueHand){
                        $PHTMPProcHand = $_
                    }Else{
                        $PHTMPProc = $_
                        $PHTMPProcHand = $_.MainWindowHandle
                    }
                    $PHTMPProcHand = [IntPtr][Int]$PHTMPProcHand
                    Switch($PHSel){
                        'GETPROC'     {
                            If(!$TrueHand){
                                If($PHID){
                                    $PHOut = $PHTMPProc.Name
                                }Else{
                                    $PHOut+=([String]$PHTMPProc.Id+','+$PHTMPProcHand+';')
                                }
                            }Else{
                                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'COULD NOT PULL PROC, HANDLE IS VALID THOUGH')}
                            }
                        }
                        'GETWINDTEXT' {
                            $PHTextLength = [GUI.Window]::GetWindowTextLength($PHTMPProcHand)
                            $PHString = ([N.e]::w([System.Text.StringBuilder],@(($PHTextLength + 1))))
                            [Void]([GUI.Window]::GetWindowText($PHTMPProcHand, $PHString, $PHString.Capacity))
                            $PHOut+=($PHString.ToString()+';')
                        }
                        'GETWIND'     {
                            $PHRect = [GUI.Rect]::E
                            [Void]([GUI.Window]::GetWindowRect($PHTMPProcHand,[Ref]$PHRect))
                            $PHOut+=(([String]$PHRect.X+','+[String]$PHRect.Y+','+[String]$PHRect.Width+','+[String]$PHRect.Height)+';')
                        }
                        default{
                            If($PHTMPProc -match 'GETFOCUS'){
                                $PHFocussedHandle = [GUI.Window]::GetForegroundWindow()
                                If($PHProc -match '-ID'){
                                    $PHOut = [String](PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle}).Id
                                }ElseIf($PHProc -match '-HAND'){
                                    $PHOut = [String]$PHFocussedHandle
                                }Else{
                                    $PHOut = [String](PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle}).Name
                                }
                            }
                        }
                    }
                }
            }
            
            $PHOut = $PHOut.ToString().Trim(';')
            
            If(!$PHProc -OR !$PHOut){If($ShowCons.Checked -AND !$SuppressConsole){
                [System.Console]::WriteLine($Tab+'PROCESS NOT FOUND!')}
            }
            
            $X = ($X.Replace(('{'+$_+'}'),$PHOut.Trim(';')))
        }
        #Replace the keyword with the input supplied to either the message box or the console prompt
        $PHSplitX | ?{$_ -match 'READIN \S+'} | %{
            If($CommandLine -OR ($X -match '{READIN -C')){
                $PH = $_.Substring(9)
            }Else{
                $PH = [Microsoft.VisualBasic.Interaction]::InputBox(($_.Substring(7)),'READIN')
            }
            $X = ($X.Replace(('{'+$_+'}'),($PH)))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the keyword with simple math function results (e.g. {SIN 0} returns 0)
        $PHSplitX | ?{
            ($_ -match '^LEN \S+') -OR `
            ($_ -match '^ABS \S+') -OR `
            ($_ -match '^SIN \S+') -OR `
            ($_ -match '^COS \S+') -OR `
            ($_ -match '^TAN \S+') -OR `
            ($_ -match '^RND \S+') -OR `
            ($_ -match '^FLR \S+') -OR `
            ($_ -match '^CEI \S+') -OR `
            ($_ -match '^SQT \S+') -OR `
            ($_ -match '^MOD \S+') -OR `
            ($_ -match '^POW \S+')
        } | %{
            $PH = $_.Substring(4)
            #If(($_.Split(' ')[0] -notmatch 'LEN') -AND ($PH -match 'E-')){$PH = 0}
            
            Switch($_.Split(' ')[0]){
                'LEN'{$PH = $PH.Length}
                'ABS'{$PH = [Math]::Abs([Double]$PH)}
                'SIN'{$PH = [Math]::Sin([Double]$PH)}
                'COS'{$PH = [Math]::Cos([Double]$PH)}
                'TAN'{$PH = [Math]::Tan([Double]$PH)}
                'RND'{$PH = [Math]::Round([Double]$PH)}
                'FLR'{$PH = [Math]::Floor([Double]$PH)}
                'CEI'{$PH = [Math]::Ceiling([Double]$PH)}
                'SQT'{$PH = [Math]::Sqrt([Double]$PH)}
                'MOD'{$PH = $PH.Split(',');$PH = [Double]$PH[0] % [Double]$PH[1]}
                'POW'{$PH = $PH.Split(',');$PH = [Math]::Pow([Double]$PH[0],[Double]$PH[1])}
            }
    
            $X = ($X.Replace(('{'+$_+'}'),$PH))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replaces the keyword with the evaluation of the arithmetic
        $PHSplitX | ?{$_ -match '^EVAL \S+.*\d$'} | %{
            ($_.SubString(5) -replace ' ') | %{
                #Preparse
                $PHOut = ($_ -replace '\+-','-')
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Pre:'+$PHOut)}
                $PHOut
            } | %{
                #Division
                $PHOut = $_
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Div:'+$PHOut)}
                While($PHOut -match '/'){
                    (($_ -replace '-','+-' -replace '\*','+*' -replace '/\+','/').Split('+*') | ?{$_ -match '/' -AND $_ -ne ''}) | Select -Unique | %{
                        $PHArr =  $_.Split('/')
                        $PHTotal = [Double]$PHArr[0]
                        $PHArr | Select -Skip 1 | %{$PHTotal = $PHTotal / [Double]$_}
                        If($PHTotal -ge 0){$PHTotal = '+' + $PHTotal}
                        $PHOut = $PHOut.Replace($_,$PHTotal)
                    }
                }
                $PHOut
            } | %{
                #Multiplication
                $PHOut = $_ -replace '\*\+','*'
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Mul:'+$PHOut)}
                While($PHOut -match '\*'){
                    (($_ -replace '-','+-' -replace '\*\+','*').Split('+') | ?{$_ -match '\*' -AND $_ -ne ''}) | Select -Unique | %{
                        $PHArr =  $_.Split('*')
                        $PHTotal = 1
                        $PHArr | %{$PHTotal = $PHTotal * [Double]$_}
                        If($PHTotal -ge 0){$PHTotal = '+' + $PHTotal}
                        $PHOut = $PHOut.Replace($_,$PHTotal)
                    }
                }
                $PHOut
            }  | %{
                #Subtraction
                $PHOut = $_
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Sub:'+$PHOut)}
                $PHOut = $PHOut -replace '-','+-'
                While($PHOut -match '\+\+'){$PHOut = $PHOut.Replace('++','+')}
                $PHOut
            }  | %{
                #Addition
                $PHOut = $_
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Add:'+$PHOut)}
                $PHTotal = 0
                While($PHOut -match '\+'){
                    ($_.Split('+') | ?{$_ -ne ''}) | %{
                        $PHTotal = $PHTotal + [Double]$_
                    }
                    $PHOut = $PHOut.Replace($_,$PHTotal)
                }
            }
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Out:'+$PHOut)}
            $X = ($X.Replace(('{'+$_+'}'),($PHOut)))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        $PHSplitX | ?{$_ -match 'GETPIX [0-9]*,[0-9]*'} | %{
            $PH = ($_ -replace 'GETPIX ')
            #$PH = $PH.Substring(0,($PH.Length - 1))
            $PH = $PH.Split(',')
            $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH[0],$PH[1],($PH[0]+1),($PH[1]+1))
            $BMP = ([N.e]::w([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
            
            $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
            $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
            $X = $X.Replace(('{'+$_+'}'),($BMP.GetPixel(0,0).Name.ToUpper()))
            
            $Graphics.Dispose()
            $BMP.Dispose()
        }
        $PHSplitX | ?{$_ -match 'FINDIMG \S+'} | %{
            $PHCoords = ($_ -replace '^FINDIMG ')
            $PHCoords = ($PHCoords.Split(',')[0,1,2,3] | %{[Int]$_})
            $PHIndex = 0
            $PHFile = ($_.Split(',') | ?{$_ -match '\.bmp'})
            If($_ -match '\.bmp,[0-9]+'){
                $PHIndex = ($_.Split(',')[-1] -replace '\D')
            }
            $Bounds = [GUI.Rect]::R($PHCoords[0],$PHCoords[1],$PHCoords[2],$PHCoords[3])
            $BMP1 = ([N.e]::w([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
            
            $Graphics = [System.Drawing.Graphics]::FromImage($BMP1)
            $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.size)
            $BMP2 = [System.Drawing.Bitmap]::FromFile($PHFile)
            $PHOut = [GUI.FindImg]::GetSubPositions($BMP1,$BMP2)[$PHIndex]
            If($PHOut -ne $Null){
                $PHOut = ([String]$PHOut.X + ',' + $PHOut.Y)
                If($ShowCons.Checked -AND !$SuppressConsole){
                    [System.Console]::WriteLine($Tab+'IMAGE FOUND WITH INDEX ' + $PHIndex + ' AT COORDINATES ' + $PHOut)
                }
            }ElseIf(!$SuppressConsole){
                [System.Console]::WriteLine($Tab+'IMAGE NOT FOUND!')
            }
            $X = ($X.Replace(('{'+$_+'}'),$PHOut))
        }
        $PHSplitX | ?{$_ -match '^MANIP \S+'} | %{
            $PH = ($_.Substring(6))
            $Operator = $PH.Split(' ')[0]
            $Operands = [String[]]($PH.Substring(4).Split(','))
            $Operands | %{$Index = 0}{If($_){$Operands[$Index] = ($_.Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',$NL).Replace('(NULL)','').Replace('(LBRACE)','{').Replace('(RBRACE)','}'))}; $Index++}
            
            $Output = ''
            Switch($Operator){
                'CNT'{
                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('^([0-9]*_)?'+$Operands[0]+'$')}).Count
                }
                'APP'{
                    If($Operands.Count -gt 2){
                        $Output = [String]($Operands[0..($Operands.Count - 2)] -join ',')+[String]$Operands[-1]
                    }Else{
                        $Output = $Operands -join ''
                    }
                }
                'RPL'{
                    If($Operands.Count -gt 3){
                        $Output = ($Operands[0..($Operands.Count - 3)] -join ',') -replace $Operands[-2],$Operands[-1]
                    }Else{
                        $Output = $Operands[0] -replace $Operands[1],$Operands[2]
                    }
                }
                'TRS'{
                    If($Operands.Count -gt 2){
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimStart($Operands[-1])
                    }Else{
                        $Output = $Operands[0].TrimStart($Operands[1])
                    }
                }
                'TRE'{
                    If($Operands.Count -gt 2){
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimEnd($Operands[-1])
                    }Else{
                        $Output = $Operands[0].TrimEnd($Operands[1])
                    }
                }
                'JOI'{
                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('^([0-9]*_)?'+$Operands[0]+'$')} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{$Script:VarsHash.$_}) -join $Operands[1]
                }
                'SPL'{
                    ($Script:VarsHash.($Operands[0])).ToString().Split($Operands[-1]) | %{$Count = 0}{
                        $Script:VarsHash.Remove(([String]$Count+'_'+$Operands[0]))
                        $Script:VarsHash.Add(([String]$Count+'_'+$Operands[0]),$(If($_ -eq $Null){''}Else{$_}))
                        $Count++
                    }
                }
                'TCA'{
                    ($Script:VarsHash.($Operands[0])).ToString().ToCharArray() | %{$Count = 0}{
                        $Script:VarsHash.Remove(([String]$Count+'_'+$Operands[1]))
                        $Script:VarsHash.Add(([String]$Count+'_'+$Operands[1]),$_)
                        $Count++
                    }
                }
                'REV'{
                    $CountF = 0
                    $CountR = (($Script:VarsHash.Keys | ?{$_ -match ('[0-9]*_'+$Operands[0]+'$')}).Count - 1)
                    0..[Math]::Ceiling($CountR / 2) | %{
                        If($CountR -ge $CountF){
                            $PH = $Script:VarsHash.([String]$CountR+'_'+$Operands[0])
                            $Script:VarsHash.([String]$CountR+'_'+$Operands[0]) = $Script:VarsHash.([String]$CountF+'_'+$Operands[0])
                            $Script:VarsHash.([String]$CountF+'_'+$Operands[0]) = $PH
                            If($Script:VarsHash.([String]$CountR+'_'+$Operands[0]) -eq $Null){$Script:VarsHash.([String]$CountR+'_'+$Operands[0]) = ''}
                            If($Script:VarsHash.([String]$CountF+'_'+$Operands[0]) -eq $Null){$Script:VarsHash.([String]$CountF+'_'+$Operands[0]) = ''}
                            $CountF++
                            $CountR--
                        }
                    }
                }
            }
            
            $X = $X.Replace(('{'+$_+'}'),$Output)
            If($Output){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}}
        }
        $PHSplitX = $X.Split('{}')
        $PHSplitX | ?{(($_ -match '^VAR \S*\+\+') -AND ($_ -notmatch '=')) -OR (($_ -match '^VAR \S*--') -AND ($_ -notmatch '=')) -OR ($_ -match '^VAR \S*?\+=\S+') -OR ($_ -match '^VAR \S+-=\d*')} | %{
            $PH = ((($_ -replace '\+=',' ' -replace '-=',' ' -replace '\+\+',' ' -replace '--',' ').Split(' ') | ?{$_ -ne ''})[1])
            If($Script:VarsHash.ContainsKey($PH)){
                Try{
                    If($_ -match '--'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - 1)
                        If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([Double]$Script:VarsHash.$PH)+'"')}
                        $X = ''
                    }ElseIf($_ -match '\+\+'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + 1)
                        If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([Double]$Script:VarsHash.$PH)+'"')}
                        $X = ''
                    }ElseIf($_ -match '-='){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - ($_.Split('=')[-1]))
                        If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([Double]$Script:VarsHash.$PH)+'"')}
                        $X = ''
                    }ElseIf($_ -match '\+='){
                        $PHInterpret = ($_.Split('=')[-1])
                        If(
                            [String]($Script:VarsHash.$PH -replace '\D') -AND `
                            $(Try{[Double]$Script:VarsHash.$PH;$True}Catch{$False}) -AND `
                            [String]($PHInterpret -replace '\D') -AND `
                            $(Try{[Double]$PHInterpret;$True}Catch{$False})
                        ){
                            $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + [Double]$PHInterpret)
                            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO '+([Double]$Script:VarsHash.$PH)+'"')}
                        }Else{
                            $Script:VarsHash.$PH = ([String]$Script:VarsHash.$PH + [String]$PHInterpret)
                            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([String]$Script:VarsHash.$PH)+'"')}
                        }
                        $X = ''
                    }
                }Catch{
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+$PH+' BAD DATA TYPE!')}
                }
            }Else{
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
            }
        }
        $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -match '=.+' -AND $_ -notmatch 'VAR \S*?\+='} | %{
            $PH = $_.Substring(4)
            $PHName = $PH.Split('=')[0]
            If($PHName -match '_ESCAPED$'){
               If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'THE NAME '+$PHName+' IS INVALID, _ESCAPED IS A RESERVED SUFFIX. THIS LINE WILL BE IGNORED...')}
                $X = ''
            }Else{
                $PHValue = $PH.Replace(($PHName+'='),'')
                If(!([String]$PHValue)){
                    $PHValue = ($X -replace '.*?{VAR .*?=')
                    $PHCount = ($X.Split('{') | %{$VarCheck = $False}{If($VarCheck){$_};If($_ -match 'VAR .*?='){$VarCheck = $True}}).Count
                    $PHValue = $PHValue.Split('}')[0..$PHCount] -join '}'
                    $X = $X.Replace(('{VAR '+$PHName+'='+$PHValue+'}'),'')
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'ABOVE VAR CONTAINS BRACES "{}" AND NO VALID VARS TO SUBSTITUTE.')}
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'PLEASE CONSIDER CHANGING LOGIC TO USE DIFFERENT DELIMITERS.')}
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'THIS WILL BE PARSED AS RAW TEXT AND NOT AS COMMANDS.')}
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'IF YOU NEED TO ALIAS COMMANDS, USE A FUNCTION INSTEAD.')}
                    $PHName+='_ESCAPED'
                }Else{
                    $X = $X.Replace(('{'+$_+'}'),'').Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',$NL).Replace('(NULL)','').Replace('(LBRACE)','{').Replace('(RBRACE)','}')
                }
                $Script:VarsHash.Remove($PHName)
                $Script:VarsHash.Add($PHName,$PHValue)
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PHName+' TO "'+$PHValue+'"')}
            }
        }
        $X.Split('{') | ?{$_ -match 'VAR \S+=}' -AND $_ -notmatch 'VAR \S*?\+='} | %{
            $PHName = ($_.Split('=')[0] -replace '^VAR ')
            $Script:VarsHash.Remove($PHName)
            $Script:VarsHash.Add($PHName,'')
            $X = $X.Replace('{'+$_,'')
        }
        $DepthOverflow++
    }
    
    If($DepthOverflow -ge 500){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'OVERFLOW DEPTH REACHED! POSSIBLE INFINITE LOOP!')}}
    
    Return $X,$Esc
}