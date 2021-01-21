Function Actions{
    Param([String]$X,[Switch]$WhatIf)
    #[System.Console]::WriteLine('INSIDE ACTIONS')
    If(!$SyncHash.Stop){
        If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        $Escaped = $False
        $X,$Escaped = (Interpret $X)
        #Write-Host 'NEW LINE IN ACTIONS'
        $TempX = $Null
        If($Escaped){
            $TempX = $X
            $X = ''
        }
        $X = $X.Replace('{FI}','').Replace('{END WHILE}','').Replace('{ELSE}','')
        
        Switch -regex ($X){
            '^{POWER .*}$'{
                If(!$WhatIf){
                    [Void]([ScriptBlock]::Create(($X -replace '^{POWER ' -replace '}$'))).Invoke()
                    $X = ''
                }Else{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'WHATIF: CREATE A SCRIPTBLOCK OF '+($X -replace '^{POWER ' -replace '}$'))
                    }
                }
            }
            
            '^{CMD .*}$'{
                If(!$WhatIf){
                    [Void]([ScriptBlock]::Create('CMD /C'+($X -replace '^{CMD ' -replace '}$'))).Invoke()
                    $X = ''
                }Else{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'WHATIF: CREATE A SCRIPTBLOCK OF '+($X -replace '^{CMD ' -replace '}$'))
                    }
                }
            }
        
            '{PAUSE'{
                If($CommandLine -OR ($ShowCons.Checked -AND ($X -notmatch '{PAUSE -GUI}'))){
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine('PRESS ANY KEY TO CONTINUE...')
                    }
                    [Void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                }Else{
                    [Void][System.Windows.Forms.MessageBox]::Show('PAUSED - Close this box to continue...','PAUSED',0,64)
                }
            
                $X = $X.Replace('{PAUSE}','').Replace('{PAUSE -GUI}','')
            }
        
            '^{FOREACH '{
                $PH = ($X -replace '^{FOREACH ').Split(',')
                
                $Keys = ($Script:VarsHash.Keys | ?{$_ -match ('^[0-9]+_' + $PH[1])})
                $Keys = ($Keys | Group Length | Sort {[Int]$_.Name} | %{$_.Group | Sort})
                
                ForEach($Key in $Keys){
                    $Script:VarsHash.Remove($PH[0])
                    $Script:VarsHash.Add($PH[0],$Script:VarsHash.$Key)
                    
                    If(!$WhatIf){
                        [Void](Parse-While $PH[2])
                    }Else{
                        [Void](Parse-While $PH[2] -WhatIf)
                    }
                }
                $Script:VarsHash.Remove($PH[0])
            }
        
            '^{SETCON'{
                $PHFileName = ($X.Substring(8)).Split(',')[0].TrimStart(' ')
                $PHFileContent = (($X -replace '^{SETCONA? ').Replace(($PHFileName+','),'') -replace '}$')
                
                If($ShowCons.Checked){
                    [System.Console]::WriteLine($Tab+'WRITING "'+$PHFileContent+'" TO FILE '+$PHFileName)
                }
                If(!$WhatIf){
                    If($X -notmatch '^{SETCONA '){
                        $PHFileContent | Out-File $PHFileName -Encoding UTF8 -Force
                    }Else{
                        $PHFileContent | Out-File $PHFileName -Encoding UTF8 -Append -Force
                    }
                }Else{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'WHATIF: WRITE "'+$PHFileContent+'" TO FILE '+$PHFileName)
                    }
                }
            }
        
            '{SETCLIP '{
                $X.Split('{}') | ?{$_ -match 'SETCLIP '} | %{
                    If(!$WhatIf){
                        [GUI.Clip]::SetTxt($_.Substring(8))
                    }Else{
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'WHATIF: SET CLIPBOARD TO "'+$_.Substring(8)+'"')
                        }
                    }
                    $X = ($X -replace ('{'+$_+'}'))
                }
            }
        
            '{BEEP '{
                $X.Split('{}') | ?{$_ -match 'BEEP '} | %{
                    $Tone = [Int](($_ -replace 'BEEP ').Split(',')[0])
                    $Time = [Int](($_ -replace 'BEEP ').Split(',')[1])
                    
                    If(!$WhatIf){
                        [System.Console]::Beep($Tone,$Time)
                    }Else{
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'WHATIF: BEEP FOR '+$Time+' AT '+$Tone)
                        }
                    }
                    $X = ($X -replace ('{'+$_+'}'))
                }
            }
        
            '{FLASH'{
                $X.Split('{}') | ?{$_ -match 'FLASH$' -OR $_ -match 'FLASH '} | %{
                    $Flashes  = $(If($_ -match ' '){[Int]($_ -replace 'FLASH ')}Else{3})
                    If(!$WhatIf){
                        [System.Console]::WriteLine('')
                        1..$Flashes | %{
                            $Coords = $Host.UI.RawUI.WindowSize
                            $Origin = $Host.UI.RawUI.CursorPosition
    
                            $Blank = (' '*($Coords.Width*$Coords.Height))
                            [System.Console]::WriteLine($Blank)
                        }{
                            If($_ % 2){
                                $Host.UI.RawUI.CursorPosition = $Origin
                                Write-Host -BackgroundColor White $Blank -NoNewline
                                [System.Threading.Thread]::Sleep(100)
                            }Else{
                                $Host.UI.RawUI.CursorPosition = $Origin
                                Write-Host -BackgroundColor Black $Blank -NoNewline
                                [System.Threading.Thread]::Sleep(100)
                            }
                        }{
                            $Host.UI.RawUI.CursorPosition = $Origin
                            [System.Console]::WriteLine($Blank)
                            $Host.UI.RawUI.CursorPosition = $Origin
                        }
                    }Else{
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'WHATIF: FLASH '+$Flashes+' TIMES')
                        }
                    }
                    $X = ($X -replace ('{'+$_+'}'))
                }
            }
        
            '{WAIT ?(-M )?\d*}'{
                $X -replace '{WAIT' -replace '}' | %{
                    If($_ -match '-M'){
                        $PH = [Int]($_ -replace ' -M ')
                    }ElseIf($_ -match ' '){
                        $PH = [Int]($_ -replace ' ')*1000
                    }Else{
                        $PH = 1000
                    }
                    If(!$SyncHash.Stop -AND ($PH % 3000)){
                        $PHMsg = ('WAITING: '+[Double]($PH / 1000)+' SECONDS REMAIN...')
                        If($ShowCons.Checked){
                            If($Host.Name -match 'Console'){
                                [System.Console]::CursorLeft = 4
                                [System.Console]::Write($PHMsg)
                            }Else{
                                [System.Console]::WriteLine($Tab+$PHMsg)
                            }
                        }
                        [System.Threading.Thread]::Sleep($PH % 3000)
                    }
                
                    $MaxWait = [Int]([Math]::Floor($PH / 3000))
                    $PH = ($PH - ($PH % 3000))
                    For($i = 0; $i -lt $MaxWait -AND !$SyncHash.Stop; $i++){
                        $PHMsg = ('WAITING: '+[Double](($PH - (3000 * $i)) / 1000)+' SECONDS REMAIN...')
                        If($ShowCons.Checked){
                            If($Host.Name -match 'Console'){
                                [System.Console]::CursorLeft = 4
                                [System.Console]::Write((' '*$PHMsg.Length))
                                [System.Console]::CursorLeft = 4
                                [System.Console]::Write($PHMsg)
                            }Else{
                                [System.Console]::WriteLine($Tab+$PHMsg)
                            }
                        }
                        [System.Threading.Thread]::Sleep(3000)
                    }
                }
                [System.Console]::WriteLine('')
            }
        
            '{[/\\]?HOLD'{
                $Rel = ($X -match '[/\\]')
                If(!$WhatIf){
                    If($X -match 'MOUSE'){
                        $Temp = ($X.Split()[-1].Replace('}',''))

                        $UndoHash.KeyList+=([String]$Temp)
                        
                        [Int]$X.Split()[-1].Replace('MOUSE}','').Replace('L','2').Replace('R','8').Replace('M','32') | %{
                            If($Rel){
                                [GUI.Events]::mouse_event(($_*2), 0, 0, 0, 0)
                            }Else{
                                [GUI.Events]::mouse_event($_, 0, 0, 0, 0)
                            }
                        }
                    }Else{
                        $Temp = ([Parse]::HoldKeys(($X.Split()[-1] -replace '}')))
                        
                        $UndoHash.KeyList+=([String]$Temp)
                        
                        If($Rel){
                            [GUI.Events]::keybd_event($Temp, 0, '&H2', 0)
                        }Else{
                            [GUI.Events]::keybd_event($Temp, 0, 0, 0)
                        }
                    }
                }Else{
                    If($ShowCons.Checked){
                        If($Rel){
                            $Rel = 'RELEASE'
                        }ELSE{
                            $Rel = 'HOLD'
                        }
                        [System.Console]::WriteLine(($Tab+'WHATIF: '+$Rel+' '+($X.Split()[-1] -replace '}')))
                    }
                }
            }
        
            '^{[LRM]?MOUSE'{
                #Write-Host 'INSIDE MOUSE'
                #Write-Host $X
                If(!$WhatIf){
                    If($X -match ','){
                        $PHX = $X
                        $PHMoveType = 'NONE'
                        If($PHX -match ' -LINEAR'){
                            $PHX = ($PHX -replace '-LINEAR')
                            $PHMoveType = 'LINEAR'
                        }ElseIf($PHX -match ' -SINE'){
                            $PHX = ($PHX -replace '-SINE')
                            $PHMoveType = 'SINE'
                        }ElseIf($PHX -match ' -RANDOM'){
                            $PHX = ($PHX -replace '-RANDOM')
                            $PHMoveType = 'RANDOM'
                        }
                        $MoveCoords = (($PHX -replace '}$').Split(' ') | ?{$_ -ne ''})[-1].Split(',')[-2,-1]
                        #Write-Host 'TEST1'
                        $Coords = [GUI.Cursor]::GetPos()
                        #Write-Host 'TEST2'
                        $PHTMPCoords = $Coords
                            
                        If(($PHX -match '\+') -OR ($PHX -match '-\d+')){
                            $MoveCoords[0] = [Int]($MoveCoords[0])+$Coords.X
                            $MoveCoords[1] = [Int]($MoveCoords[1])+$Coords.Y
                        }
                        If($X -match '\(.*\)'){
                            If($X -match '\(.*,.*\)'){
                                $PHDelay = [Int]($X -replace '^.*?\(' -replace '\).*$' -replace '-').Split(',')[0]
                                $Weight = [Int]($X -replace '^.*?\(' -replace '\).*$' -replace '-').Split(',')[-1]
                            }Else{
                                $PHDelay = [Int]($X -replace '^.*?\(' -replace '\).*$' -replace '-')
                                $Weight = 1
                            }
                        }Else{
                            $PHDelay = 0
                            $Weight = 1
                        }
                        If($PHMoveType -notmatch 'NONE'){
                            $Right = $True
                            $Down = $True
                            $DistX = ($MoveCoords[0]-$Coords.X)
                            $DistY = ($MoveCoords[1]-$Coords.Y)
                            If($DistX -lt 0){$DistX = ($Coords.X-$MoveCoords[0]);$Right = $False}
                            If($DistY -lt 0){$DistY = ($Coords.Y-$MoveCoords[1]);$Down = $False}
                            
                            $Dist = [Math]::Sqrt(([Math]::Pow($DistX,2)+[Math]::Pow($DistY,2)))
                            $Dist = [Math]::Round($Dist)
                            $Random = ([N.e]::w([System.Random],@()))
                            
                            $RemainderX = 0
                            $RemainderY = 0
                            For($i = 0; $i -lt $Dist -AND !$SyncHash.Stop; $i+=[Math]::Sqrt([Math]::Pow($OffsetX,2)+[Math]::Pow($OffsetY,2))){
                                If($DistX -eq 0){$DistX = 1}
                                If($DistY -eq 0){$DistY = 1}
                                
                                Switch($PHMoveType){
                                    'LINEAR'{
                                        $OffsetX = $Dist/$DistY + $RemainderX
                                        $OffsetY = $Dist/$DistX + $RemainderY
                                    }
                                    'SINE'{
                                        $OffsetX = $Dist*($Weight*[Math]::Sin(([Math]::PI*$i)/$Dist) + 1)/$DistY
                                        $OffsetY = $Dist*($Weight*[Math]::Sin(([Math]::PI*$i)/$Dist) + 1)/$DistX
                                    }
                                    'RANDOM'{
                                        $OffsetX = $Dist*$Random.Next(1,($Weight+1))/$DistY
                                        $OffsetY = $Dist*$Random.Next(1,($Weight+1))/$DistX
                                    }
                                }
                                $Coords = [GUI.Cursor]::GetPos()
                                $PHTMPCoords = $Coords
                            
                                If($Right){
                                    $PHTMPCoords.X = ($PHTMPCoords.X+$OffsetX)
                                }Else{
                                    $PHTMPCoords.X = ($PHTMPCoords.X-$OffsetX)
                                }

                                If($Down){
                                    $PHTMPCoords.Y = ($PHTMPCoords.Y+$OffsetY)
                                }Else{
                                    $PHTMPCoords.Y = ($PHTMPCoords.Y-$OffsetY)
                                }
                                
                                $j = $Coords.X
                                $k = $Coords.Y
                                While(($j -ne $PHTMPCoords.X -OR $k -ne $PHTMPCoords.Y) -AND !$SyncHash.Stop){
                                    If($j -lt $PHTMPCoords.X){$j++}ElseIf($j -gt $PHTMPCoords.X){$j--}
                                    If($k -lt $PHTMPCoords.Y){$k++}ElseIf($k -gt $PHTMPCoords.Y){$k--}
                                    [GUI.Cursor]::SetPos($j,$k)
                                }
                                $RemainderX = $OffsetX - [Math]::Round($OffsetX)
                                $RemainderY = $OffsetY - [Math]::Round($OffsetY)
                                If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                            }
                            If(!$SyncHash.Stop){
                                While(($j -ne [Math]::Round($MoveCoords[0]) -OR $k -ne [Math]::Round($MoveCoords[1])) -AND !$SyncHash.Stop){
                                    
                                    If($j -lt [Math]::Round($MoveCoords[0])){
                                        $j++
                                    }ElseIf($j -gt [Math]::Round($MoveCoords[0])){
                                        $j--
                                    }

                                    If($k -lt [Math]::Round($MoveCoords[1])){
                                        $k++
                                    }ElseIf($k -gt [Math]::Round($MoveCoords[1])){
                                        $k--
                                    }
                                    
                                    [GUI.Cursor]::SetPos($j,$k)
                                }
                                If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                            }
                        }Else{
                            [GUI.Cursor]::SetPos($MoveCoords[0],$MoveCoords[1])
                        }
                    }Else{
                        $ClickCount = 1
                        
                        If($X -match 'MOUSE \d+}'){
                            $ClickCount = [Int](($X.Replace('}','')).Split(' ')[-1])
                        }
                        
                        1..$ClickCount | %{
                            [Int]($X.Replace('LM','2').Replace('RM','8').Replace('MM','32').Split(' ')[0] -replace '\D') | %{
                                If($_ -eq 2 -OR $_ -eq 8 -OR $_ -eq 32){
                                    [GUI.Events]::mouse_event($_, 0, 0, 0, 0)
                                    [System.Threading.Thread]::Sleep(40)
                                    [GUI.Events]::mouse_event(($_*2), 0, 0, 0, 0)
                                }Else{
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'INVALID MOUSE VALUE!')
                                    }
                                }
                            }
                        }
                    }
                }Else{
                    If($ShowCons.Checked){
                        If($X -match ','){
                            [System.Console]::WriteLine($Tab+'WHATIF: MOVE MOUSE TO '+($X.Replace('{MOUSE ','').Replace('}','')))
                        }Else{
                            [System.Console]::WriteLine($Tab+'WHATIF: CLICK '+$X)
                        }
                    }
                }
            }
        
            '^{RESTART}$'{
                $SyncHash.Restart = $True
            }
        
            '^{REFOCUS}$'{
                $Script:Refocus = $True
            }
        
            '^{CLEARVAR'{
                If($X -match '^{CLEARVARS}$'){
                    $Script:VarsHash = @{}
                }Else{
                    $Script:VarsHash.Remove($X.Replace('{CLEARVAR ').Replace('}'))
                }
            }
        
            '^{QUIT}$'{
                $SyncHash.Stop = $True
            }
        
            '^{EXIT}$'{
                $SyncHash.Stop = $True
            }

            '^{CD '{
                CD ($X -replace '{CD ' -replace '}$')
                
                If($ShowCons.Checked){
                    [System.Console]::WriteLine($Tab+'CHANGING DIRECTORY TO '+($X -replace '{CD ' -replace '}$'))
                }
            }

            '^{REMOTE '{
                Try{
                    If(!$WhatIf){
                        $PH = ($X -replace '{REMOTE ' -replace '}$')
                        $PHIP = [String]($PH.Split(',')[0].Split(':')[0])
                        $PHPort = [Int]($PH.Split(',')[0].Split(':')[-1])
                        $PHSendString = (($PH.Split(',') | Select -Skip 1) -join ',')
                        
                        If($Script:FuncHash.($PHSendString -replace '^{' -replace '}$')){
                            $PHSendString = $Script:FuncHash.($PHSendString -replace '^{' -replace '}$')
                        }
                        
                        $PHCMDS = '{CMDS_START}'+($NL*2)+$PHSendString+($NL*2)+'{CMDS_END}'
                        $Buffer = [Text.Encoding]::UTF8.GetBytes($PHCMDS)
                        
                        If($X -match '{REMOTE -R '){
                            $PHListener = ([N.e]::w([System.Net.Sockets.TcpListener],@($PHIP,$PHPort)))
                            $PHListener.Start()
                            $PHClient = $PHListener.AcceptTCPClient()
                            $PHListener.Stop()
                        }Else{
                            $PHClient = ([N.e]::w([System.Net.Sockets.TcpClient],@($PHIP,$PHPort)))
                        }
                        
                        $PHStream = $PHClient.GetStream()
                        $PHStream.Write($Buffer, 0, $Buffer.Length)
                        
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'SENT THE FOLLOWING TO '+$PHIP+':'+$PHPort)
                        }
                        If($ShowCons.Checked){
                            $PHSendString.Split($NL) | %{$FlipFlop = $True}{
                                If($FlipFlop){
                                    [System.Console]::WriteLine(($Tab*2)+$_)
                                }

                                $FlipFlop=!$FlipFlop
                            }
                        }
                        
                        $MaxTime = [Int]$CliTimeOut.Value
                        $PHResp = ''
                        $Timeout = 1
                        
                        While(
                            ($PHResp -notmatch '{COMPLETE}') -AND `
                            !$SyncHash.Stop -AND `
                            ($Timeout -lt $MaxTime) -AND `
                            ($PHSendString -ne '{SERVERSTOP}') -AND `
                            $PHClient.Connected
                        ){
                            $PHMsg = ('WAITING FOR REMOTE END COMPLETION... '+$Timeout+'/'+$MaxTime)
                            If($ShowCons.Checked -AND !($Timeout % 3)){
                                If($Host.Name -match 'Console'){
                                    [System.Console]::CursorLeft = 4
                                    [System.Console]::Write($PHMsg)
                                }Else{
                                    [System.Console]::WriteLine($Tab+$PHMsg)
                                }
                            }
                            $Buff = [N.e]::w([Byte[]],@(1024))
                            While($PHStream.DataAvailable){
                                $Buff = [N.e]::w([Byte[]],@(1024))
                                [Void]$PHStream.Read($Buff, 0, 1024)
                                $PHResp+=([System.Text.Encoding]::UTF8.GetString($Buff))
                            }
                            [System.Threading.Thread]::Sleep(1000)
                            $Timeout++
                            If($PHResp -eq '{KEEPALIVE}'){$Timeout = 0}
                        }
                        [System.Console]::WriteLine('')
                        If($PHResp -match '{COMPLETE}'){
                            If($ShowCons.Checked){
                                [System.Console]::WriteLine($Tab+'COMPLETED!')
                            }
                        }
                        If($Timeout -ge $MaxTime){
                            If($ShowCons.Checked){
                                [System.Console]::WriteLine($Tab+'TIMED OUT WAITING FOR REMOTE END!')
                            }
                        }
                        
                        $PHStream.Close()
                        $PHStream.Dispose()
                        $PHClient.Close()
                        $PHClient.Dispose()
                    }Else{
                        If($ShowCons.Checked){
                            If($X -match '{REMOTE -R '){
                                [System.Console]::WriteLine($Tab+'WHATIF: WOULD LISTEN FOR INCOMING TCP CONNECTION ON '+$PHIP+':'+$PHPort+' THEN SEND THE FOLLOWING TO THE REMOTE END')
                            }Else{
                                [System.Console]::WriteLine($Tab+'WHATIF: WOULD SEND THE FOLLOWING TO '+$PHIP+':'+$PHPort)
                            }
                        }
                        If($ShowCons.Checked){
                            $PHSendString.Split($NL) | %{$FlipFlop = $True}{
                                If($FlipFlop){
                                    [System.Console]::WriteLine($Tab+$_)
                                }
                                $FlipFlop=!$FlipFlop
                            }
                        }
                    }
                }Catch{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'ERROR! FAILED SEND TO '+$PHIP+':'+$PHPort)
                    }
                }
            }

            '^{LISTEN '{
                Try{
                    If(!$WhatIf){
                        $PH = ($X -replace '{REMOTE ' -replace '}$')
                        $PHIP = [String]($PH.Split(',')[0].Split(':')[0])
                        $PHPort = [Int]($PH.Split(',')[0].Split(':')[-1])

                        $PHPort = [Int]$ServerPort.Text
                        $SyncHash.SrvPort = $PHPort
                        
                        $Reverse = ($X -match '{LISTEN -R ')

                        If($Reverse){
                            $MaxTime = [Int]$CliTimeOut.Value
                        }Else{
                            $MaxTime = [Int]$SrvTimeOut.Value
                            $Listener = ([N.e]::w([System.Net.Sockets.TcpListener],@($PHIP,$PHPort)))
                        }

                        [GUI.Window]::ShowWindow($Form.Handle,0)
                    
                        While(!$SyncHash.Stop){
                            $Buff = [N.e]::w([Byte[]],@(1024))
                            $CMDsIn = ''
                            $Timeout = 1

                            Try{
                                [Void][IPAddress]$PHIP
                                If($Reverse){
                                    If($SyncHash.SrvIP -ne '0.0.0.0'){
                                        $Client = ([N.e]::w([System.Net.Sockets.TcpClient],@($PHIP,$PHPort)))
                                        $Stream = $Client.GetStream()
                                        [System.Console]::WriteLine($NL+'---------------'+$NL+'Successful Remote Connect!'+$NL+'---------------'+$NL)
                                        [System.Console]::WriteLine($Tab+'Waiting for incoming commands...')
                                    }Else{[System.Console]::WriteLine($Tab+'ERROR! '+$SyncHash.SrvIP+' IS AN INVALID REMOTE IP!')}
                                }Else{
                                    $Listener.Start()
                                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Waiting for Commands!'+$NL+'---------------'+$NL)
                                    $Client = $Listener.AcceptTCPClient()
                                    $Listener.Stop()

                                    $Stream = $Client.GetStream()
                                }
                            }Catch{
                                [System.Console]::WriteLine($Tab+'ERROR! IN LISTENER!')
                                [System.Console]::WriteLine($Error[0])
                            }

                            While(!(($CMDsIn -match '{CMDS_START}') -AND ($CMDsIn -match '{CMDS_END}')) -AND ($Timeout -lt $MaxTime) -AND $Client.Connected){
                                While($Stream.DataAvailable){
                                    $Buff = [N.e]::w([Byte[]],@(1024))
                                    [Void]$Stream.Read($Buff, 0, 1024)
                                    $CMDsIn+=([System.Text.Encoding]::UTF8.GetString($Buff))
                                }
                                [System.Threading.Thread]::Sleep(500)
                                $Timeout++
                            }
                            If($Timeout -lt $MaxTime){
                                $CMDsIn = ($CMDsIn -replace '{CMDS_START}' -replace '{CMDS_END}')
                                GO -InlineCommand $CMDsIn -Server -Stream $Stream
                            
                                Try{
                                    $Stream.Write([System.Text.Encoding]::UTF8.GetBytes('{COMPLETE}'),0,10)

                                    $Stream.Close()
                                    $Stream.Dispose()
                                    $Client.Close()
                                    $Client.Dispose()
                                }Catch{
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'ERROR! COULD NOT RETURN COMPLETE MESSAGE TO REMOTE END!')
                                        [System.Console]::WriteLine($Error[0])
                                    }
                                }
                            }
                        }
                        If(!$Reverse){$Listener.Stop()}
                        [GUI.Window]::ShowWindow($Form.Handle,4)
                    
                        [System.Console]::WriteLine($NL+'---------------'+$NL+'Server stopped!'+$NL+'---------------'+$NL)
                        $Form.Refresh()
                        $SyncHash.Stop = $False
                        $SyncHash.Restart = $False
                    }Else{
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'WHATIF: WOULD SEND THE FOLLOWING TO '+$PHIP+':'+$PHPort)
                        }
                        If($ShowCons.Checked){
                            $PHSendString.Split($NL) | %{$FlipFlop = $True}{
                                If($FlipFlop){
                                    [System.Console]::WriteLine($Tab+$_)
                                }
                                $FlipFlop=!$FlipFlop
                            }
                        }
                    }
                }Catch{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'ERROR! FAILED SEND TO '+$PHIP+':'+$PHPort)
                    }
                }
            }

            '^{SCRNSHT '{
                $PH = ($X -replace '{SCRNSHT ')
                $PH = $PH.Substring(0,($PH.Length - 1))
                $PH = $PH.Split(',')
                If(!$WhatIf){
                    $Bounds = [GUI.Rect]::R($PH[0],$PH[1],$PH[2],$PH[3])
                    $BMP = ([N.e]::w([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
            
                    $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
                    $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.size)
            
                    $BMP.Save($PH[4])
            
                    $Graphics.Dispose()
                    $BMP.Dispose()
                }Else{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'WHATIF: TAKE SCREENSHOT AT TOP-LEFT ('+$PH[0]+','+$PH[1]+') TO BOTTOM-RIGHT ('+$PH[2]+','+$PH[3]+')')
                    }
                }
            }
        
            $Script:FuncRegex{
                If($Script:FuncRegex -ne '{ \d+|{}' -AND $X -notmatch '^{REMOTE '){
                    $FuncCount = 1
                    If($X -match ' '){
                        $FuncCount = [Int]($X.Split()[-1] -replace '\D')
                    }
                    1..$FuncCount | %{
                        $Script:FuncHash.($X.Trim('{}').Split()[0]).Split($NL) | %{
                            ($_ -replace ('`'+$NL),'' -replace '^\s*' | ?{$_ -ne ''})
                        } | %{$Commented = $False}{
                            If($_ -match '^<\\\\#'){$Commented = $True}
                            If($_ -match '^\\\\#>'){$Commented = $False}

                            If($_ -notmatch '^\\\\#' -AND !$Commented){
                                $_
                            }Else{
                                If($ShowCons.Checked){
                                    [System.Console]::WriteLine($Tab+$_)
                                }
                            }
                        } | %{
                            If(!$SyncHash.Stop){
                                If(!$WhatIf){
                                    [Void](Parse-While $_)
                                }Else{
                                    [Void](Parse-While $_ -WhatIf)
                                }
                            }
                        }
                    }
                }
            }
        
            '{FOCUS |{SETWIND |{MIN |{MAX |{HIDE |{SHOW |{SETWINDTEXT '{
                $ProcSearchTerm = ($_ -replace '}\s*$' -replace ',.*')
                $ProcSearchTerm = ($ProcSearchTerm.Replace(' -ID ',' ').Replace(' -HAND ',' '))
                $ProcSearchTerm = ($ProcSearchTerm.Split() | ?{$_})
                $ProcSearchTerm = (($ProcSearchTerm | Select -Skip 1) -join ' ' -replace ' \d*$')
                
                $PHProc = $Null
                $PHHidden = $Null
                
                $ChildHandles = $False
                If($X -match ' -ID '){
                    Try{
                        $PHProc = @(PS -Id $ProcSearchTerm -ErrorAction Stop | ?{$_.MainWindowHandle -ne 0})
                        If(!$PHProc.Count){
                            If($Script:HiddenWindows.Keys.Count){
                                $LastHiddenTime = ($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$ProcSearchTerm+'_')})
                                $LastHiddenTime = ($LastHiddenTime | %{[String]($_.Split('_')[-1])} | Sort | Select -Last 1)
                                $LastHiddenSearchTerm = ('_'+$ProcSearchTerm+'_.*?_'+$LastHiddenTime+'$')
                                $KeyNameOfLastHidden = ($Script:HiddenWindows.Keys | ?{$_ -match $LastHiddenSearchTerm})
                                
                                $PHHidden = @($Script:HiddenWindows.$KeyNameOfLastHidden)
                            }
                        }
                    }Catch{
                        $PHProc = $Null
                        $PHHidden = $Null
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'ERROR: FAILED DURING FIND PROC, KILLING MACRO TO AVOID CAUSING DAMAGE')
                            [System.Console]::WriteLine($Error[0])
                        }
                        
                        $SyncHash.Stop = $True
                        Break
                    }
                }ElseIf($X -match ' -HAND '){
                    Try{
                        $PHProc = @(PS -ErrorAction Stop | ?{$_.MainWindowHandle -eq $ProcSearchTerm})
                        If(!$PHProc.Count){
                            If($Script:HiddenWindows.Keys.Count){
                                $LastHiddenTime = ($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$ProcSearchTerm+'_')})
                                $LastHiddenTime = ($LastHiddenTime | %{[String]($_.Split('_')[-1])} | Sort | Select -Last 1)
                                $LastHiddenSearchTerm = ('_'+$ProcSearchTerm+'_'+$LastHiddenTime+'$')
                                $KeyNameOfLastHidden = ($Script:HiddenWindows.Keys | ?{$_ -match $LastHiddenSearchTerm})
                                
                                $PHHidden = @($Script:HiddenWindows.$KeyNameOfLastHidden)
                            }
                            
                            If(!$PHHidden){
                                $ChildHandles = $True
                                Try{
                                    $ProcSearchTerm = [IntPtr][Int]$ProcSearchTerm
                                    $PHTextLength = [GUI.Window]::GetWindowTextLength($ProcSearchTerm)
                                    $PHString = ([N.e]::w([System.Text.StringBuilder],@(($PHTextLength + 1))))
                                    [Void]([GUI.Window]::GetWindowText($ProcSearchTerm, $PHString, $PHString.Capacity))
                                    If(!$PHString){
                                        $PHProc = $Null
                                        $PHHidden = $Null
                                    }Else{
                                        $PHHidden = @($ProcSearchTerm)
                                    }
                                }Catch{
                                    $PHProc = $Null
                                    $PHHidden = $Null
                                }
                            }
                        }
                    }Catch{
                        $PHProc = $Null
                        $PHHidden = $Null
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'ERROR: FAILED DURING FIND PROC, KILLING MACRO TO AVOID CAUSING DAMAGE')
                            [System.Console]::WriteLine($Error[0])
                        }
                        
                        $SyncHash.Stop = $True
                        Break
                    }
                }Else{
                    Try{
                        $PHProc = @(PS $ProcSearchTerm | ?{$_.MainWindowHandle -ne 0})
                        If(!$PHProc.Count){
                            $PHProc = @(PS | ?{$_.Id -notmatch $SyncHash.MouseIndPid} | ?{$_.MainWindowTitle -match $ProcSearchTerm})
                        }
                        If($Script:HiddenWindows.Keys.Count){
                            $PHHidden = @(($Script:HiddenWindows.Keys | ?{$_ -match ('^'+$ProcSearchTerm+'_')}) | %{$Script:HiddenWindows.$_})
                        }
                    }Catch{
                        $PHProc = $Null
                        $PHHidden = $Null
                        If($ShowCons.Checked){
                            [System.Console]::WriteLine($Tab+'ERROR: FAILED DURING FIND PROC, KILLING MACRO TO AVOID CAUSING DAMAGE')
                            [System.Console]::WriteLine($Error[0])
                        }
                        
                        $SyncHash.Stop = $True
                        Break
                    }
                }
                
                If($PHHidden.Count){$PHProc+=$PHHidden}
                If($PHProc.Count){
                    If(!$WhatIf){
                        $PHProc | %{
                            If($ChildHandles){
                                $PHTMPProcHand = $_
                            }Else{
                                $PHTMPProc = $_
                                $PHTMPProcTitle = $_.MainWindowTitle
                                $PHTMPProcHand = $_.MainWindowHandle
                            }
                            $PHTMPProcHand = [IntPtr][Int]$PHTMPProcHand
                            $PHAction = $X.Split(' ')[0].Replace('{','')
                            
                            Switch($PHAction){
                                'FOCUS'       {
                                    Try{
                                        If(!$ChildHandles){
                                            [Void][GUI.Window]::Act($PHTMPProcTitle)
                                        }Else{
                                            [Void][GUI.Window]::ShowWindow($PHTMPProcHand,9)
                                        }
                                    }Catch{
                                        If($ShowCons.Checked){
                                            [System.Console]::WriteLine(`
                                                $Tab+`
                                                'COULD NOT FIND HANDLES: '+`
                                                ([Boolean]$ChildHandles).ToString().ToUpper()+`
                                                ', PROC TITLE: '+`
                                                $PHTMPProcTitle+`
                                                ', HANDLE: '+`
                                                $PHTMPProcHand
                                            )
                                            
                                            [System.Console]::WriteLine($Error[0])
                                        }
                                    }
                                }
                                'MIN'         {[Void][GUI.Window]::ShowWindow($PHTMPProcHand,6)}
                                'MAX'         {[Void][GUI.Window]::ShowWindow($PHTMPProcHand,3)}
                                'SHOW'        {[Void][GUI.Window]::ShowWindow($PHTMPProcHand,9)}
                                'HIDE'        {
                                    [Void][GUI.Window]::ShowWindow($PHTMPProcHand,0)
                                    If(!$ChildHandles){
                                        $Script:HiddenWindows.Add(
                                            ($PHTMPProc.Name+'_'+$PHTMPProc.Id+'_'+$PHTMPProcHand+'_'+[DateTime]::Now.ToFileTimeUtc()),
                                            $PHTMPProc
                                        )
                                    }
                                }
                                'SETWIND'     {
                                    $PHCoords = (($X -replace '{SETWIND ' -replace '}$').Split(',') | Select -Skip 1)
                                    [Void][GUI.Window]::MoveWindow(
                                        $PHTMPProcHand,
                                        [Int]$PHCoords[0],
                                        [Int]$PHCoords[1],
                                        ([Int]$PHCoords[2]-[Int]$PHCoords[0]),
                                        ([Int]$PHCoords[3]-[Int]$PHCoords[1]),
                                        $True
                                    )
                                }
                                'SETWINDTEXT' {
                                    $PHWindText = ($X -replace ('^\s*{.*?,') -replace '}$')
                                    [Void][GUI.Window]::SetWindowText($PHTMPProcHand,$PHWindText)
                                }
                            }
                            If($PHAction -match 'MIN|MAX|SHOW'){
                                $PHKey = @($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHTMPProcHand+'_')})
                                If($PHKey.Count){$PHKey = (($PHKey | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)}
                                
                                If($PHKey){
                                    Try{
                                        $Script:HiddenWindows.Remove($PHKey)
                                    }Catch{
                                        If($ShowCons.Checked){
                                            [System.Console]::WriteLine($Tab+'COULD NOT DELETE PROC KEY ('+$PHKey+'), THIS MAY NOT BE AN ISSUE')
                                            [System.Console]::WriteLine($Error[0])
                                        }
                                    }
                                }
                            }
                        }
                    }Else{
                        $PHProc | %{
                            Switch($X.Split(' ')[0].Replace('{','')){
                                'FOCUS'       {
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'WHATIF: FOCUS ON '+($X -replace '{FOCUS ' -replace '}'))
                                    }
                                }
                                'MIN'         {
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'WHATIF: MIN WINDOW '+($X -replace '{MIN ' -replace '}' -replace '-ID'))
                                    }
                                }
                                'MAX'         {
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'WHATIF: MAX WINDOW '+($X -replace '{MAX ' -replace '}' -replace '-ID'))
                                    }
                                }
                                'SHOW'        {
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'WHATIF: SHOW WINDOW '+($X -replace '{SHOW ' -replace '}' -replace '-ID'))
                                    }
                                }
                                'HIDE'        {
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine($Tab+'WHATIF: HIDE WINDOW '+($X -replace '{HIDE ' -replace '}' -replace '-ID'))
                                    }
                                }
                                'SETWIND'     {
                                    $PHCoords = (($X -replace '{SETWIND ' -replace '}$').Split(',') | Select -Skip 1)
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine(
                                            $Tab+`
                                            'WHATIF: RESIZE WINDOW '+`
                                            ($X -replace '{SETWIND ' -replace '}' -replace '-ID ')+`
                                            ' TO TOP-LEFT ('+`
                                            $PHCoords[0]+`
                                            ','+`
                                            $PHCoords[1]+`
                                            ') AND BOTTOM-RIGHT ('+`
                                            $PHCoords[2]+`
                                            ','+`
                                            $PHCoords[3]+`
                                            ')'
                                        )
                                    }
                                }
                                'SETWINDTEXT' {
                                    $PHWindText = ($X -replace ('^\s*{.*?,') -replace '}$')
                                    If($ShowCons.Checked){
                                        [System.Console]::WriteLine(
                                            $Tab+`
                                            'WHATIF: SET WINDOW TEXT FOR '+`
                                            ($X -replace '{SETWINDTEXT ' -replace '}' -replace '-ID ').Split(',')[0]+`
                                            ' TO '+`
                                            $PHWindText
                                        )
                                    }
                                }
                            }
                        }
                    }
                }Else{
                    If($ShowCons.Checked){
                        [System.Console]::WriteLine($Tab+'PROCESS NOT FOUND!')
                    }
                }
            }
            '{ECHO .*?}'{
                If($X -match '{ECHO -GUI \S+'){
                    [Void][Microsoft.VisualBasic.Interaction]::MsgBox(($X -replace '^{ECHO ' -replace '^-GUI ' -replace '}$'), [Microsoft.VisualBasic.MsgBoxStyle]::OkOnly, 'ECHO GUI')
                }Else{
                    [System.Console]::WriteLine($Tab+'ECHO: '+($X -replace '^{ECHO ' -replace '}$'))
                }
            }
            Default{
                If($Escaped){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'THIS LINE WAS ESCAPED. ABOVE MAY APPEAR AS COMMANDS,')}
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'BUT HAS BEEN CONVERTED TO KEYSTROKES!')}
                    $X = (($TempX.ToCharArray() | %{If($_ -eq '{'){'{{}'}ElseIf($_ -eq '}'){'{}}'}Else{[String]$_}}) -join '')
                    $X = (($X.ToCharArray() | %{If($_ -eq '('){'{(}'}ElseIf($_ -eq ')'){'{)}'}Else{[String]$_}}) -join '')
                    $X = (($X.ToCharArray() | %{If($_ -eq '['){'{[}'}ElseIf($_ -eq ']'){'{]}'}Else{[String]$_}}) -join '')
                }
                If(($X -notmatch '^\(.*\)$' -AND $X -notmatch '^{.*}$' -AND $X -notmatch '^\[.*\]$') -AND ($DelayTimer.Value -ne 0 -OR ($DelayCheck.Checked -AND ($DelayRandTimer.Value -gt 0)))){
                    $X.ToCharArray() | %{
                        $PHX = $(
                            Switch([String]$_){
                                '{'{'{{}'}
                                '}'{'{}}'}
                                '('{'{(}'}
                                ')'{'{)}'}
                                '['{'{[}'}
                                ']'{'{]}'}
                                default{$_}
                            }
                        )
                    
                        If(!$WhatIf){
                            [GUI.Send]::Keys([String]$PHX)
                        }Else{
                            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SEND KEYS '+$PHX)}
                        }
                    
                        If($DelayCheck.Checked){
                            $PH = ((([N.e]::w([Random],@()).Next((-1*$DelayRandTimer.Value),($DelayRandTimer.Value)))))
                        }Else{
                            $PH = 0
                        }
                        
                        [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($DelayTimer.Value + $PH))))
                    }
                }Else{
                    Try{
                        If(!$WhatIf){
                            [GUI.Send]::Keys([String]$X)
                        }Else{
                            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SEND KEYS '+$X)}
                        }
                    }
                    Catch{
                        If(!$Escaped){
                            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'POTENTIAL UNCLOSED OR BAD BRACES, POSSIBLE NON-VALID COMMAND. RE-ATTEMPTING AS KEYSTROKES...')}
                            $X = (($X.ToCharArray() | %{If($_ -eq '{'){'{{}'}ElseIf($_ -eq '}'){'{}}'}Else{[String]$_}}) -join '')
                            $X = (($X.ToCharArray() | %{If($_ -eq '('){'{(}'}ElseIf($_ -eq ')'){'{)}'}Else{[String]$_}}) -join '')
                            $X = (($X.ToCharArray() | %{If($_ -eq '['){'{[}'}ElseIf($_ -eq ']'){'{]}'}Else{[String]$_}}) -join '')
                            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
                        }
                    
                        Try{
                            If(!$WhatIf){
                                [GUI.Send]::Keys([String]$X)
                            }Else{
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SEND KEYS '+$X)}
                            }
                        }Catch{
                            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'FAILED!')}
                        }
                    }
                }
            }
        }

        If($CommandDelayTimer.Value -ne 0 -OR ($CommDelayCheck.Checked -AND ($CommRandTimer.Value -gt 0))){
            If($CommDelayCheck.Checked){
                $PH = ((([N.e]::w([Random],@()).Next((-1*$CommRandTimer.Value),($CommRandTimer.Value)))))
            }Else{
                $PH = 0
            }
            [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($CommandDelayTimer.Value + $PH))))
        }
    }
}
