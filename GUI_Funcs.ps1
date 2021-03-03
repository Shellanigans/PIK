Function GO{
    Param([Switch]$SelectionRun,[Switch]$Server,[Switch]$WhatIf,[String]$InlineCommand,$Stream=$Null)
    #[System.Console]::WriteLine('INSIDE GO')
    #Any lines with #Ignore are there for regex purposes when exporting scripts
    [System.Console]::WriteLine($NL+'Initializing:')                                             #Ignore
    [System.Console]::WriteLine('-------------------------')                                     #Ignore
    $Script:Refocus = $False
    $Script:Inside_If = $False
    $Script:IfElDepth = 0
    $Script:IfElEval = $False
    $Script:Inside_While = $False
    $Script:WhileDepth = 0
    $Script:WhileEval = $False
    $Script:BufferedCommandsIfEl = ''
    $Script:BufferedCommandsWhile = ''
    $Script:FuncRegex = '{}'
    $Script:VarsHash = @{}
    $Script:FuncHash = @{}
    #$Script:HiddenWindows = @{}
    $UndoHash.KeyList | %{
        If($_ -notmatch 'MOUSE'){
            [GUI.Events]::keybd_event(([String]$_), 0, '&H2', 0)
        }Else{
            [GUI.Events]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
        }
    }
    $UndoHash = @{KeyList=[String[]]@()}
    $Commands.ReadOnly      = $True
    $FunctionsBox.ReadOnly  = $True
    $Form.Refresh()
    #The below if statement is split for the regex as well
    If(
        $FunctionsBox.Text -replace '\s*' -AND `
        !$InlineCommand
    ){
        [System.Console]::WriteLine($Tab+'Parsing Functions:')                                   
        [System.Console]::WriteLine($Tab+'-------------------------')                            
        $FunctionsBox.Text.Split($NL) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart($Tab)} | %{ 
            $FunctionStart = $False                                                              
            $FunctionText = @()                                                                  
        }{                                                                                       
            If(!$FunctionStart -AND $_ -match '^{FUNCTION NAME '){$FunctionStart = $True}        
            If($FunctionStart){                                                                  
                If($_ -match '^{FUNCTION NAME '){                                                
                    $NameFunc = [String]($_ -replace '^.*{FUNCTION NAME ' -replace '}\s*$')      
                }ElseIf($_ -match '{FUNCTION END}'){                                             
                    $FunctionStart = $False                                                      
                    $Script:FuncHash.Add($NameFunc,($FunctionText -join $NL))                    
                    $FunctionText = @()                                                          
                }Else{                                                                           
                    $FunctionText+=$_                                                            
                }                                                                                
            }                                                                                    
        }                                                                                        
        $Script:FuncHash.Keys | Sort | %{                                                        
            [System.Console]::WriteLine(($Tab*2) + $_ + $NL + ($Tab*2) + '-------------------------' + $NL + (($Script:FuncHash.$_.Split($NL) | ?{$_ -ne ''} | %{($Tab*2)+($_ -replace '^\s*')}) -join $NL) + $NL)
        }

        $Script:FuncRegex = ('{'+($Script:FuncHash.Keys -join ' \d+|{')+' \d+|{'+($Script:FuncHash.Keys -join '}|{')+'}')
    }
    [System.Console]::WriteLine($NL+'---------------'+$NL+'Starting Macro!'+$NL+'---------------'+$NL)
    
    $Results = (Measure-Command {
        [GUI.Window]::ShowWindow($Form.Handle,0)
            
        If($InlineCommand){
            $PHText = $InlineCommand
        }Else{
            If($SelectionRun){
                $(Switch($TabControllerComm.SelectedTab.Text)
                {
                    'Commands'{$Commands}
                    'Functions'{$FunctionsBox}
                    default{''}
                }) | %{$PHText = $_.SelectedText}
            }Else{
                $PHText = $Commands.Text
            }
        }
        $PHText = (($PHText -replace ('`'+$NL),'').Split($NL) | %{$_ -replace '^\s*'} | ?{$_ -ne ''} | %{$Commented = $False}{
            If($_ -match '^<\\\\#'){$Commented = $True}
            If($_ -match '^\\\\#>'){$Commented = $False}
            If($_ -notmatch '^\\\\#' -AND !$Commented){$_}
        })
        
           
        Do{
            $SyncHash.Stop = $False
            $SyncHash.Restart = $False
                
            $PHText | %{$InlineFunction = $False}{
                If(!$SyncHash.Stop){
                    Try{
                        $Line = $_
                        If($Line -match '{FUNCTION NAME '){
                            $InlineFunction = $True
                            $NewFuncName = ($Line -replace '^.*{FUNCTION NAME ' -replace '}\s*$').Trim(' ')
                            $NewFuncName,$FuncEsc = (Interpret $NewFuncName)
                            If(!$FuncEsc){
                                $Line = ''
                                $NewFuncBody = ''
                            }Else{
                                $InlineFunction = $False
                            }
                        }
                        If($InlineFunction){
                            If($Line -notmatch '{FUNCTION END}'){
                                $NewFuncBody+=($Line+$NL)
                            }Else{
                                $InlineFunction = $False
                                Try{
                                    $Script:FuncHash.Remove($NewFuncName)
                                }Catch{
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'NO FUNCTION WITH THE NAME '+$NewFuncName+' FOUND, THIS MAY BE INTENDED BEHAVIOR')}
                                }
                                Try{
                                    $Script:FuncHash.Add($NewFuncName,$NewFuncBody)
                                    
                                    $Script:FuncRegex+=('|{'+$NewFuncName+' \d+|{'+$NewFuncName+'}')
                                    
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Parsing New Function:')}
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'-------------------------')}
                                    If($ShowCons.Checked){[System.Console]::WriteLine(($Tab*2) + $NewFuncName + $NL + ($Tab*2) + '-------------------------' + $NL + (($Script:FuncHash.$NewFuncName.Split($NL) | ?{$_ -ne ''} | %{($Tab*2)+($_ -replace '^\s*')}) -join $NL) + $NL)}
                                }Catch{}
                            }
                        }Else{
                            If($Line -match '{SERVERSTOP}'){
                                [System.Console]::WriteLine('{SERVERSTOP}')
                                [System.Console]::WriteLine($Tab+'KILLING SERVER!')
                                $Server = $False
                                $SyncHash.Stop = $True
                                $SyncHash.Restart = $False
                            }Else{
                                If($Line -match '{KEEPALIVE}'){
                                    [Void]$Stream.Write([Text.Encoding]::UTF8.GetBytes('{KEEPALIVE}'),0,11)
                                }Else{
                                    If(!$WhatIf){
                                        #Write-Host 'NEW LINE IN GO'
                                        [Void](Parse-While $Line)
                                    }Else{
                                        [Void](Parse-While $Line -WhatIf)
                                    }
                                }
                            }
                        }
                    }Catch{
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'UNHANDLED ERROR: '+$Error[0])}
                    }
                }
            }
        }While($SyncHash.Restart)
        $UndoHash.KeyList | %{
            If($_ -notmatch 'MOUSE'){
                [GUI.Events]::keybd_event(([String]$_), 0, '&H2', 0)
            }Else{
                [GUI.Events]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
            }
        }
        If($Server){$SyncHash.Stop = $False}
        [System.Console]::WriteLine($NL+'---------'+$NL+'Complete!'+$NL+'---------'+$NL)
        If(!$CommandLine -AND !$Server){    
            $Commands.ReadOnly     = $False
            $FunctionsBox.ReadOnly = $False
            [GUI.Window]::ShowWindow($Form.Handle,4)
            $Form.Refresh()
            If($Script:Refocus){
                $Form.Activate()
                $Commands.Focus()
            }
        }
    })
    [System.Console]::WriteLine('Stats'+$NL+'-------------------------')
    [System.Console]::WriteLine((($Results | Select Hours,Minutes,Seconds,Milliseconds,Ticks | Out-String) -replace '^\s*'))
}

Function Handle-RMenuExit($MainObj){
    $PHObj = $MainObj
    
    If($MainObj.Parent.GetType().BaseType.ToString() -eq 'System.Windows.Forms.Panel'){
        $PHObj = $PHObj.Parent
    }
    $L = $PHObj.Location
    $S = $PHObj.Size
    $M = [GUI.Cursor]::GetPos()
    $M.X = ($M.X - $Form.Location.X)
    $M.Y = ($M.Y - $Form.Location.Y)
    If(($M.X -lt ($L.X + 10)) -OR ($M.Y -lt ($L.Y + 35)) -OR ($M.X -gt ($S.Width + $L.X + 4)) -OR ($M.Y -gt ($S.Height + $L.Y + 29))){
        $PHObj.Visible = $False
    }
}

Function Handle-RMenuClick($MainObj){
    $RightClickMenu.Visible = $False
    
    $(Switch($TabControllerComm.SelectedTab.Text)
    {
        'Commands'{$Commands}
        'Functions'{$FunctionsBox}
    }) | %{
        $PHObj = $_
        $PHObj.Focus()
        Switch($MainObj.Text)
        {
            'Cut'              {[GUI.Clip]::SetTxt($PHObj.SelectedText);$PHObj.SelectedText = ''}
            'Copy'             {[GUI.Clip]::SetTxt($PHObj.SelectedText)}
            'Paste'            {$PHObj.Paste()}
            'Select All'       {$PHObj.SelectAll()}
            'Select Line'      {
                $PHObj.SelectionStart = $PHObj.GetFirstCharIndexOfCurrentLine()
                $PHObj.SelectionLength = $PHObj.Lines[$PHObj.GetLineFromCharIndex($PHObj.SelectionStart)].Length
            }
            'Delete'           {$PHObj.SelectedText = ''}
            'Highlight Syntax' {Handle-TextBoxKey -KeyCode 'F10' -MainObj $PHObj -BoxType $TabController.SelectedTab.Text -Shift $_.Shift -Control $_.Control -Alt $_.Alt}
            'Undo'             {$PHObj.Undo()}
            'Redo'             {$PHObj.Redo()}
            'WhatIf Selection' {GO -SelectionRun -WhatIf}
            'WhatIf'           {GO -WhatIf}
            'Goto Top'         {$PHObj.SelectionStart = 0}
            'Goto Bottom'      {$PHObj.SelectionStart = $PHObj.Text.Length}
            'Find/Replace'     {
                $FindForm.Visible = $True
                $FindForm.BringToFront()
                $Form.Refresh()
            }
            'Run Selection'    {GO -SelectionRun}
            'Run'              {GO}
        }
    }
}

Function Handle-MousePosGet{
    $PH = [GUI.Cursor]::GetPos()
    
    $XCoord.Value = $PH.X
    $YCoord.Value = $PH.Y
    $MouseCoordsBox.Text = ('{MOUSE '+$PH.X+','+$PH.Y+'}')
            
    $Bounds = [GUI.Rect]::R($PH.X-8,$PH.Y-8,16,16)
    $BMP = ([N.e]::w([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
    ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
    
    $PHPix = $BMP.GetPixel(8,8)
    $PixColorBox.Text = $PHPix.Name.ToUpper()
    $PixColorBox.BackColor = $PHPix
    $PHLum = [Math]::Sqrt(
        $PHPix.R * $PHPix.R * 0.299 +
        $PHPix.G * $PHPix.G * 0.587 +
        $PHPix.B * $PHPix.B * 0.114
    )
    If($PHLum -gt 130){
        $PixColorBox.ForeColor = [System.Drawing.Color]::Black
        $CenterDot.BackColor = [System.Drawing.Color]::Black
    }Else{
        $PixColorBox.ForeColor = [System.Drawing.Color]::White
        $CenterDot.BackColor = [System.Drawing.Color]::White
    }
    $BMPBig = ([N.e]::w([System.Drawing.Bitmap],@(120, 106)))
    $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
    $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $GraphicsBig.DrawImage($BMP,0,0,120,106)
    $ZoomPanel.BackgroundImage = $BMPBig
}

Function Handle-TextBoxKey($KeyCode, $MainObj, $BoxType, $Shift, $Control, $Alt){
    If($KeyCode -eq 'F1'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '<\\# '
    }ElseIf($KeyCode -eq 'F2'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '\\#> '
    }ElseIf($KeyCode -eq 'F3'){
        $PrevStart = $MainObj.SelectionStart
        $PrevLength = $MainObj.SelectionLength
        
        $MainObj.SelectionStart = $MainObj.GetFirstCharIndexOfCurrentLine()
        $MainObj.SelectionLength = 4
        If($MainObj.SelectedText -eq '\\# '){
            $MainObj.SelectedText = ''
            $MainObj.SelectionStart = $PrevStart-4
        }Else{
            $MainObj.SelectionLength = 0
            $MainObj.SelectedText = '\\# '
            $MainObj.SelectionStart = $PrevStart+4
        }
        $MainObj.SelectionLength = $PrevLength
    }ElseIf($KeyCode -eq 'F4' -AND !$Alt){
        Switch($BoxType){
            'Commands'{
                $MainObj.SelectedText = ('{IF ()}'+$NL+'{ELSE}'+$NL+'{FI}')
            }
            'Functions'{
                $MainObj.Text+=($NL+'{FUNCTION NAME RENAMETHIS}'+$NL+$Tab+$NL+'{FUNCTION END}'+$NL)
                $MainObj.SelectionStart = ($MainObj.Text.Length - 1)
            }
        }
    }ElseIf($KeyCode -eq 'F5'){
        GO
    }ElseIf($KeyCode -eq 'F6'){
        $PH = [GUI.Cursor]::GetPos()
        $XCoord.Value = $PH.X
        $YCoord.Value = $PH.Y
        #$MainObj.SelectionLength = 0
        $MainObj.SelectedText = ('{MOUSE '+((($PH).ToString().Substring(3) -replace 'Y=').TrimEnd('}'))+'}'+$NL)
    }ElseIf($KeyCode -eq 'F7'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '{WAIT -M 100}'
    }ElseIf($KeyCode -eq 'F8'){
        GO -SelectionRun
    }ElseIf($KeyCode -eq 'F10'){
        Try{$_.SuppressKeyPress = $True}Catch{}
        $Form.Enabled = $False
        #$PrevFormText = (($Form.Text -replace '\*$')+'*')
        $PrevFormText = $Form.Text
        #$PrevFormText = $Form.Text
        
        $PrevSaved = $Script:Saved
        #$Script:Saved = $False
        $Form.Text = 'PARSING'
        $Form.Refresh()
        #[Void][GUI.Window]::ShowWindow($Form.Handle, 0)
        #$Script:Saved = $False
        $TempSelectionIndex = $MainObj.SelectionStart
        $TempSelectionLength = $MainObj.SelectionLength
        $MainObj.SelectionStart = 0
        $MainObj.SelectionLength = $MainObj.Text.Length
        $MainObj.SelectionColor = [System.Drawing.Color]::Black
        
        $DetectedFunctions = @()
        #$Commands.Text.Split($NL).Where({$_ -match '{FUNCTION NAME '}) | %{$DetectedFunctions+=$_.Replace('FUNCTION NAME ','').Trim()}
        ForEach($Func in $Commands.Text.Split($NL).Where({$_ -match '{FUNCTION NAME '})){
            $DetectedFunctions+=$Func.Replace('FUNCTION NAME ','').Trim()
        }
        ForEach($Func in $FunctionsBox.Text.Split($NL).Where({$_ -match '{FUNCTION NAME '})){
            $DetectedFunctions+=$Func.Replace('FUNCTION NAME ','').Trim()
        }
        
        $LineCount = 0
        $Commented = $False
        ForEach($Line in $MainObj.Lines){
            If($Line -match '<\\\\#'){$Commented = $True}
            If($Line -match '\\\\#>'){$Commented = $False}
            $PreviousLineStart = $MainObj.GetFirstCharIndexFromLine($LineCount)
            $MainObj.SelectionStart = $PreviousLineStart
            
            $PreviousLength = $Line.Length
            $MainObj.SelectionLength = $PreviousLength
            $TrimmedLine = $Line.Trim()
            If($Commented -OR (($Line -replace '^\s*?') -match '\\\\#')){
                $MainObj.SelectionColor = [System.Drawing.Color]::DarkGray
            }ElseIf(!$Commented){
                If($TrimmedLine -match '{VAR \S*?='){
                    $MainObj.SelectionColor = [System.Drawing.Color]::FromArgb([Convert]::ToInt32("0xFFFF4500", 16))
                }ElseIf(($TrimmedLine -match '{IF \(') -OR ($TrimmedLine -match '{ELSE}') -OR ($TrimmedLine -match '{FI}') -OR ($TrimmedLine -match '{WHILE \(') -OR ($TrimmedLine -match '{END WHILE}')){
                    $MainObj.SelectionColor = [System.Drawing.Color]::DarkBlue
                }ElseIf($DetectedFunctions.Contains(($TrimmedLine -replace ' \d*')) -OR ($TrimmedLine -match 'FUNCTION NAME ') -OR ($TrimmedLine -match 'FUNCTION END')){
                    $MainObj.SelectionColor = [System.Drawing.Color]::Blue
                }ElseIf(
                    ($TrimmedLine -match '^{POWER ') -OR `
                    ($TrimmedLine -match '^{CMD ') -OR `
                    ($TrimmedLine -match '^{PAUSE') -OR `
                    ($TrimmedLine -match '^{FOREACH ') -OR `
                    ($TrimmedLine -match '^{SETCON') -OR `
                    ($TrimmedLine -match '^{SETCLIP ') -OR `
                    ($TrimmedLine -match '^{BEEP ') -OR `
                    ($TrimmedLine -match '^{FLASH') -OR `
                    ($TrimmedLine -match '^{WAIT ?(M )?\d*') -OR `
                    ($TrimmedLine -match '^{[/\\]?HOLD') -OR `
                    ($TrimmedLine -match '^{MOUSE ') -OR `
                    ($TrimmedLine -match '^{[LRM]?MOUSE') -OR `
                    ($TrimmedLine -match '^{RESTART') -OR `
                    ($TrimmedLine -match '^{REFOCUS') -OR `
                    ($TrimmedLine -match '^{REMOTE ') -OR `
                    ($TrimmedLine -match '^{CLEARVAR') -OR `
                    ($TrimmedLine -match '^{QUIT') -OR `
                    ($TrimmedLine -match '^{EXIT') -OR `
                    ($TrimmedLine -match '^{CD ') -OR `
                    ($TrimmedLine -match '^{SCRNSHT ') -OR `
                    ($TrimmedLine -match '^{FOCUS ') -OR `
                    ($TrimmedLine -match '^{SETWIND ') -OR `
                    ($TrimmedLine -match '^{MIN ') -OR `
                    ($TrimmedLine -match '^{MAX ') -OR `
                    ($TrimmedLine -match '^{HIDE ') -OR `
                    ($TrimmedLine -match '^{SHOW ') -OR `
                    ($TrimmedLine -match '^{SETWINDTEXT ') -OR `
                    ($TrimmedLine -match '^{ECHO .*?')
                ){
                    $MainObj.SelectionColor = [System.Drawing.Color]::DarkRed
                }
                $DepthCount = 0
                $StartedParse = $False

                $CurrentCount = 0
                $StrBldr = ''
                ForEach($Char in $Line.ToCharArray()){
                    $CurrentCount++
                    $StrBldr+=$Char
                    If($_ -match '{' -AND !$StartedParse){$StrBldr = '{'}
                    If($StartedParse){
                        $MainObj.SelectionLength++
                        If($Char -match '{'){
                            $DepthCount++
                        }ElseIf($_ -match '}'){
                            $DepthCount--
                        }
                    }
                    If(
                        !$StartedParse -AND `
                        (($StrBldr -match '^{LEN ') -OR `
                        ($StrBldr -match '^{ABS ') -OR `
                        ($StrBldr -match '^{POW ') -OR `
                        ($StrBldr -match '^{SIN ') -OR `
                        ($StrBldr -match '^{COS ') -OR `
                        ($StrBldr -match '^{TAN ') -OR `
                        ($StrBldr -match '^{RND ') -OR `
                        ($StrBldr -match '^{FLR ') -OR `
                        ($StrBldr -match '^{SQT ') -OR `
                        ($StrBldr -match '^{CEI ') -OR `
                        ($StrBldr -match '^{MOD ') -OR `
                        ($StrBldr -match '^{EVAL ') -OR `
                        ($StrBldr -match '^{PWD') -OR `
                        ($StrBldr -match '^{MANIP ') -OR `
                        ($StrBldr -match '^{GETCON ') -OR `
                        ($StrBldr -match '^{FINDVAR ') -OR `
                        ($StrBldr -match '^{GETPROC ') -OR `
                        ($StrBldr -match '^{FINDIMG ') -OR `
                        ($StrBldr -match '^{GETWIND ') -OR `
                        ($StrBldr -match '^{GETWINDTEXT ') -OR `
                        ($StrBldr -match '^{GETFOCUS') -OR `
                        ($StrBldr -match '^{GETSCREEN') -OR `
                        ($StrBldr -match '^{READIN ') -OR `
                        ($StrBldr -match '^{PID') -OR `
                        ($StrBldr -match '^{WHOAMI') -OR `
                        ($StrBldr -match '^{DATETIME') -OR `
                        ($StrBldr -match '^{RAND ') -OR `
                        ($StrBldr -match '^{GETCLIP') -OR `
                        ($StrBldr -match '^{GETMOUSE') -OR `
                        ($StrBldr -match '^{GETPIX '))
                    ){
                        $StartedParse = $True
                        $DepthCount = 1
                        $MainObj.SelectionStart=($PreviousLineStart+$CurrentCount-$StrBldr.Length)
                        $MainObj.SelectionLength = ($StrBldr.Length)
                        $StrBldr = ''
                    }
                    If($StartedParse -AND ($DepthCount -le 0)){
                        $DepthCount = 0
                        $StartedParse = $False
                        $MainObj.SelectionColor = [System.Drawing.Color]::FromArgb([Convert]::ToInt32("0xFF008080", 16))
                    }
                }
                $CharCount = $PreviousLineStart
                ForEach($SplitLine in $Line.Split('{}')){
                    $CharCount+=($SplitLine.Length+1)
                    $MainObj.SelectionStart = $PreviousLineStart
                    $MainObj.SelectionLength = $PreviousLength
                    If(
                        ($SplitLine -match 'VAR [\w\d_:]*?$') -OR `
                        ($SplitLine -match 'VAR [\w\d_:]*?\+\+$') -OR `
                        ($SplitLine -match 'VAR [\w\d_:]*?--$')
                    ){
                        $MainObj.SelectionStart=($CharCount-($SplitLine.Length+2))
                        $MainObj.SelectionLength=($SplitLine.Length+2)
                        $MainObj.SelectionColor = [System.Drawing.Color]::FromArgb([Convert]::ToInt32("0xFFFF4500", 16))
                    }
                }
            }
            $LineCount++
        }
                    
        $MainObj.SelectionStart = $TempSelectionIndex
        $MainObj.SelectionLength = $TempSelectionLength
        $Form.Enabled = $True
        #[Void][GUI.Window]::ShowWindow($Form.Handle, 1)
        
        $Form.Text = $PrevFormText
        $Script:Saved = $PrevSaved
        #$Form.Text+='*'
        $Form.Refresh()
    }ElseIf($KeyCode -eq 'F11'){
        Save-Profile
    }ElseIf($KeyCode -eq 'TAB'){
        If($MainObj.SelectionLength -gt 0){
            $Start = $MainObj.GetLineFromCharIndex($MainObj.SelectionStart)
            $End = $MainObj.GetLineFromCharIndex($MainObj.SelectionStart + $MainObj.SelectionLength)
            $TempSelectionIndex = $MainObj.GetFirstCharIndexFromLine($Start)
            $TempSelectionLength = $MainObj.SelectionLength
            If($_.Shift -AND ($MainObj.SelectedText -match ($Tab))){
                $TempLines = $MainObj.Lines
                $Start..$End | %{
                    If($TempLines[$_].Length -gt 1 -AND [Int][Char]$TempLines[$_].Substring(0,1) -eq 9){
                        $TempLines[$_] = $TempLines[$_].Substring(1, ($TempLines[$_].Length - 1))
                        $TempSelectionLength--
                    }ElseIf($TempLines[$_].Length -eq 1 -AND [Int][Char]$TempLines[$_].Substring(0,1) -eq 9){
                        $TempLines[$_] = ''
                        $TempSelectionLength--
                    }
                }
                $MainObj.Lines = $TempLines
            }ElseIf(!$_.Shift){
                $TempLines = $MainObj.Lines
                $Start..($End - 1) | %{$TempLines[$_] = ($Tab + $TempLines[$_]); $TempSelectionLength++}
                $MainObj.Lines = $TempLines
            }
            If($TempSelectionLength -lt 0){$TempSelectionLength = 0}
            $MainObj.SelectionStart = $TempSelectionIndex
            $MainObj.SelectionLength = $TempSelectionLength
            $_.SuppressKeyPress = $True
        }
    }ElseIf($KeyCode -eq 'S' -AND $Control){
        Save-Profile
    }
}

Function Check-Saved{
    $Response = 'No'
    If(!$Script:Saved -OR ($Script:LoadedProfile -eq $Null -AND ($Commands.Text -OR $FunctionsBox.Text))){
        If($Script:LoadedProfile){
            $Response = [System.Windows.Forms.MessageBox]::Show('You have not saved. Would you like to save now?','Save?','YesNoCancel')
            If($Response -eq 'Yes'){
                $Form.Text = ($Form.Text -replace '\*$')
                #$TempName = ($Profile.Text -replace '^Working Profile: ')
                $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')
                [Void](MKDIR $TempDir)
                $Script:Saved = $True
                #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                Try{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                }Catch{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                }
                #$SaveAsProfText.Text = ''
            }
        }Else{
            $Response = [System.Windows.Forms.MessageBox]::Show('You have not saved this profile yet. Would you like to create a new save?','Create New Save?','YesNoCancel')
            If($Response -eq 'Yes'){
                $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
                If($PH){
                    $Form.Text = ('PIK - ' + $PH)
                    $Profile.Text = ('Working Profile: ' + $PH)
                    $Script:LoadedProfile = $PH
                    #$TempName = $SaveAsProfText.Text
                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')
                    [Void](MKDIR $TempDir)
                    $Script:Saved = $True
                    #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                    #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                    Try{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                    }
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                    $SavedProfiles.SelectedItem = $Script:LoadedProfile
                    #$SaveAsProfText.Text = ''
                }
            }
        }
    }
    Return $Response
}

Function Save-Profile{
    If($Script:LoadedProfile){
        $Form.Text = ($Form.Text -replace '\*$')
        #$TempName = ($Profile.Text -replace '^Working Profile: ')
        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')
        [Void](MKDIR $TempDir)
        $Script:Saved = $True
        #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
        #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
        Try{
            '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
        }Catch{
            '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
        }
        #$SaveAsProfText.Text = ''
    }Else{
        If([System.Windows.Forms.MessageBox]::Show('You have not saved this profile yet. Would you like to create a new save?','Create New Save?','YesNoCancel') -eq 'Yes'){
            $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
            If($PH){
                $Form.Text = ('PIK - ' + $PH)
                $Profile.Text = ('Working Profile: ' + $PH)
                $Script:LoadedProfile = $PH
                #$TempName = $SaveAsProfText.Text
                $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')
                [Void](MKDIR $TempDir)
                $Script:Saved = $True
                #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                Try{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                }Catch{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                }
                $SavedProfiles.Items.Clear()
                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                $SavedProfiles.SelectedItem = $Script:LoadedProfile
                #$SaveAsProfText.Text = ''
            }
        }
    }
}
