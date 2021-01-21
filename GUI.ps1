$Asms = @(
    'System.Windows.Forms',
    'System.Drawing',
    'Microsoft.VisualBasic',
    'System.Configuration',
    'System.Reflection'
)
Add-Type -ReferencedAssemblies $Asms -IgnoreWarnings -TypeDefinition $CSharpCode

$Form = ([N.e]::w([GUI.F],@(470, 500, 'PIK')))
$Form.MinimumSize = [GUI.SP]::SI(470,500)
$TabController = ([N.e]::w([GUI.TC],@(405, 400, 25, 7)))
    $TabPageComm = ([N.e]::w([GUI.TP],@(0, 0, 0, 0,'Main')))
        $TabControllerComm = ([N.e]::w([GUI.TC],@(0, 0, 0, 0)))
        $TabControllerComm.Dock = 'Fill'
        $TabControllerComm.Add_SelectedIndexChanged({
            Switch($This.SelectedTab.Text){
                'Commands'  {$Commands.Focus()}
                'Functions' {$FunctionsBox.Focus()}
            }
        })
            $TabPageCommMain = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Commands')))
                $Commands = ([N.e]::w([GUI.RTB],@(0, 0, 0, 0, '')))
                $Commands.Dock = 'Fill'
                $Commands.Multiline = $True
                $Commands.WordWrap = $False
                $Commands.ScrollBars = 'Both'
                $Commands.AcceptsTab = $True
                $Commands.DetectUrls = $False
                $Commands.Add_TextChanged({
                    If($Script:Saved){
                        $Form.Text+='*'
                        $Script:Saved = $False
                    }
                    
                    #$This.Text | Out-File ($env:APPDATA+'\Macro\Commands.txt') -Width 10000 -Force
                    Try{
                        '' | Select @{Name='Commands';Expression={$This.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 10000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$This.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 10000 -Force
                    }
                })
                $Commands.Add_MouseDown({
                    If([String]$_.Button -eq 'Right'){
                        $RightClickMenu.Visible = $True
                        $XBound = ($Form.Location.X + $Form.Size.Width - $RightClickMenu.Size.Width)
                        $YBound = ($Form.Location.Y + $Form.Size.Height - $RightClickMenu.Size.Height)
                        $M = [GUI.Cursor]::GetPos()
                        If($M.X -gt $XBound){$PHXCoord = ($Form.Size.Width - $RightClickMenu.Size.Width - 17)}Else{$PHXCoord = ($_.Location.X+30)}
                        If($M.Y -gt $YBound){$PHYCoord = ($Form.Size.Height - $RightClickMenu.Size.Height - 40)}Else{$PHYCoord = ($_.Location.Y+45)}
                        $RightClickMenu.Location = [GUI.SP]::PO($PHXCoord,$PHYCoord)
                        $RightClickMenu.BringToFront()
                    }
                })
                $Commands.Text = Try{
                    ((Get-Content ($env:APPDATA+'\Macro\AutoSave.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Commands | Out-String).TrimEnd($NL)# -join $NL
                }Catch{
                    Try{
                        ((Get-Content ($env:APPDATA+'\Macro\AutoSave.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Commands | Out-String).TrimEnd($NL)# -join $NL
                    }Catch{
                        ''
                    }
                }
                $Commands.Parent = $TabPageCommMain
                $Commands.Add_KeyDown({Handle-TextBoxKey -KeyCode ($_.KeyCode.ToString()) -MainObj $This -BoxType 'Commands' -Shift $_.Shift -Control $_.Control -Alt $_.Alt})
            $TabPageCommMain.Parent = $TabControllerComm
            $TabPageFunctMain = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Functions')))
                $FunctionsBox = ([N.e]::w([GUI.RTB],@(0, 0, 0, 0, '')))
                $FunctionsBox.Multiline = $True
                $FunctionsBox.WordWrap = $False
                $FunctionsBox.Scrollbars = 'Both'
                $FunctionsBox.AcceptsTab = $True
                $FunctionsBox.DetectUrls = $False
                $FunctionsBox.Add_TextChanged({
                    If($Script:Saved){
                        $Form.Text+='*'
                        $Script:Saved = $False
                    }
                    
                    #$This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 10000 -Force
                    Try{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$This.Text}} | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 10000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$This.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 10000 -Force
                    }
                })
                $FunctionsBox.Add_MouseDown({
                    If([String]$_.Button -eq 'Right'){
                        $RightClickMenu.Visible = $True
                        $XBound = ($Form.Location.X + $Form.Size.Width - $RightClickMenu.Size.Width)
                        $YBound = ($Form.Location.Y + $Form.Size.Height - $RightClickMenu.Size.Height)
                        $M = [GUI.Cursor]::GetPos()
                        If($M.X -gt $XBound){$PHXCoord = ($Form.Size.Width - $RightClickMenu.Size.Width - 17)}Else{$PHXCoord = ($_.Location.X+30)}
                        If($M.Y -gt $YBound){$PHYCoord = ($Form.Size.Height - $RightClickMenu.Size.Height - 40)}Else{$PHYCoord = ($_.Location.Y+45)}
                        $RightClickMenu.Location = [GUI.SP]::PO($PHXCoord,$PHYCoord)
                        $RightClickMenu.BringToFront()
                    }
                })
                $FunctionsBox.Text = Try{
                    ((Get-Content ($env:APPDATA+'\Macro\AutoSave.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Functions | Out-String).TrimEnd($NL)# -join $NL
                }Catch{
                    Try{
                        ((Get-Content ($env:APPDATA+'\Macro\AutoSave.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Functions | Out-String).TrimEnd($NL)# -join $NL
                    }Catch{
                        ''
                    }
                }
                $FunctionsBox.Dock = 'Fill'
                $FunctionsBox.Parent = $TabPageFunctMain
                $FunctionsBox.Add_KeyDown({Handle-TextBoxKey -KeyCode ($_.KeyCode.ToString()) -MainObj $This -BoxType 'Functions' -Shift $_.Shift -Control $_.Control -Alt $_.Alt})
            $TabPageFunctMain.Parent = $TabControllerComm
            $TabPageHelper = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Helpers')))
                $TabHelperSub = ([N.e]::w([GUI.TC],@(0, 0, 0, 0)))
                $TabHelperSub.Dock = 'Fill'
                $TabHelperSub.SizeMode = 'Fixed'
                $TabHelperSub.DrawMode = 'OwnerDrawFixed'
                $TabHelperSub.Add_DrawItem({
                    $PHText = $This.TabPages[$_.Index].Text
                    
                    $PHRect = $This.GetTabRect($_.Index)
                    $PHRect = ([N.e]::w([System.Drawing.RectangleF],@($PHRect.X,$PHRect.Y,$PHRect.Width,$PHRect.Height)))
                    $PHBrush = ([N.e]::w([System.Drawing.SolidBrush],@([System.Drawing.Color]::Black)))
                    $PHStrForm = ([N.e]::w([System.Drawing.StringFormat],@()))
                    $PHStrForm.Alignment = [System.Drawing.StringAlignment]::Center
                    $PHStrForm.LineAlignment = [System.Drawing.StringAlignment]::Center
                    $_.Graphics.DrawString($PHText, $This.Font, $PHBrush, $PHRect, $PHStrForm)
                })
                $TabHelperSub.ItemSize = [GUI.SP]::SI(25,75)
                $TabHelperSub.Alignment = [System.Windows.Forms.TabAlignment]::Left
                    $TabHelperSubMouse = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Mouse/Pix')))
                        $GetMouseCoords = ([N.e]::w([GUI.B],@(110, 25, 10, 25, 'Mouse Inf')))
                        $GetMouseCoords.Add_MouseDown({$This.Text = 'Drag Mouse'})
                        $GetMouseCoords.Add_MouseUp({$This.Text = 'Mouse Inf'})
                        $GetMouseCoords.Add_MouseMove({
                            If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){
                                Handle-MousePosGet; $Form.Refresh()
                            }
                        })
                        $GetMouseCoords.Parent = $TabHelperSubMouse
                        $MouseCoordLabel = ([N.e]::w([GUI.L],@(110, 10, 130, 10, 'Mouse Coords:')))
                        $MouseCoordLabel.Parent = $TabHelperSubMouse
                        $MouseCoordsBox = ([N.e]::w([GUI.TB],@(140, 25, 130, 25, '')))
                        $MouseCoordsBox.ReadOnly = $True
                        $MouseCoordsBox.Multiline = $True
                        $MouseCoordsBox.Add_DoubleClick({If($This.Text){[GUI.Clip]::SetTxt($This.Text); $This.SelectAll()}})
                        $MouseCoordsBox.Parent = $TabHelperSubMouse
                        $MouseManualLabel = ([N.e]::w([GUI.L],@(100, 10, 10, 60, 'Manual Move:')))
                        $MouseManualLabel.Parent = $TabHelperSubMouse
                        $XCoord = ([N.e]::w([GUI.NUD],@(50, 25, 10, 75)))
                        $XCoord.Maximum = 99999
                        $XCoord.Minimum = -99999
                        $XCoord.Add_ValueChanged({[GUI.Cursor]::SetPos($This.Value,$YCoord.Value);Handle-MousePosGet})
                        $XCoord.Add_KeyUp({
                            If($_.KeyCode -eq 'Return'){
                                [GUI.Cursor]::SetPos($This.Value,$YCoord.Value)
                                Handle-MousePosGet
                            }
                        })
                        $XCoord.Parent = $TabHelperSubMouse
                
                        $YCoord = ([N.e]::w([GUI.NUD],@(50, 25, 70, 75)))
                        $YCoord.Maximum = 99999
                        $YCoord.Minimum = -99999
                        $YCoord.Add_ValueChanged({[GUI.Cursor]::SetPos($XCoord.Value,$This.Value);Handle-MousePosGet})
                        $YCoord.Add_KeyUp({
                            If($_.KeyCode -eq 'Return'){
                                [GUI.Cursor]::SetPos($XCoord.Value,$This.Value)
                                Handle-MousePosGet
                            }
                        })
                        $YCoord.Parent = $TabHelperSubMouse
                        $PixColorLabel = ([N.e]::w([GUI.L],@(110, 10, 130, 60, 'HexVal (ARGB):')))
                        $PixColorLabel.Parent = $TabHelperSubMouse
                        $PixColorBox = ([N.e]::w([GUI.TB],@(140, 25, 130, 75, '')))
                        $PixColorBox.ReadOnly = $True
                        $PixColorBox.Multiline = $True
                        $PixColorBox.Add_DoubleClick({If($This.Text){[GUI.Clip]::SetTxt($This.Text); $This.SelectAll()}})
                        $PixColorBox.Parent = $TabHelperSubMouse
                        $LeftMouseBox = ([N.e]::w([GUI.B],@(135,25,10,110,'Left Click')))
                        $LeftMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [GUI.Events]::mouse_event(2, 0, 0, 0, 0)
                                [GUI.Events]::mouse_event(4, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $LeftMouseBox.Parent = $TabHelperSubMouse
                        $MiddleMouseBox = ([N.e]::w([GUI.B],@(135,25,10,152,'Middle Click')))
                        $MiddleMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [GUI.Events]::mouse_event(32, 0, 0, 0, 0)
                                [GUI.Events]::mouse_event(64, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $MiddleMouseBox.Parent = $TabHelperSubMouse
                        $RightMouseBox = ([N.e]::w([GUI.B],@(135,25,10,194,'Right Click')))
                        $RightMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [GUI.Events]::mouse_event(8, 0, 0, 0, 0)
                                [GUI.Events]::mouse_event(16, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $RightMouseBox.Parent = $TabHelperSubMouse
                        $ZoomPanel = ([N.e]::w([GUI.GB],@(115,115,155,105,'')))
                        $ZoomPanel.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
                        $ZoomPanel.Parent = $TabHelperSubMouse
                        $GraphicFixPanel = ([N.e]::w([GUI.P],@(115,5,155,105)))
                        $GraphicFixPanel.BackColor = $Form.BackColor
                        $GraphicFixPanel.Parent = $TabHelperSubMouse
                        $GraphicFixPanel.BringToFront()
                        
                        $CenterDot = ([N.e]::w([GUI.P],@(8,8,209,159)))
                        $CenterDot.BackColor = [System.Drawing.Color]::Black
                        $CenterDot.Parent = $TabHelperSubMouse
                        $CenterDot.BringToFront()
                        $Tape = ([N.e]::w([GUI.B],@(260, 25, 10, 240, 'Measuring Tape')))
                        $Tape.Add_Click({
                            $TapePow = [Powershell]::Create()
                            $TapeRun = [RunspaceFactory]::CreateRunspace()
                            $TapeRun.ApartmentState = [System.Threading.ApartmentState]::STA
                            $TapeRun.Open()
                            $TapePow.Runspace = $TapeRun
                            $TapePow.AddScript({
                                Add-Type -AssemblyName System.Windows.Forms
                                Add-Type -AssemblyName System.Drawing
                                Add-Type -Name e -Namespace N -MemberDefinition '
                                public static Object w (Type type, params Object[] args){
                                    return System.Activator.CreateInstance(type, args);
                                }
                                '
                                $TapeForm = [N.e]::w([System.Windows.Forms.Form],@())
                                $TapeForm.Size = [N.e]::w([System.Drawing.Size],@(5000,5000))
                                $TapeForm.Text = 'Measuring Tape'
                                $TapeForm.TopMost = $True
                                $TapeForm.TopMost = $False
                                $TapeForm.TopMost = $True
                                $Black = [System.Drawing.Color]::Black
                                $Red = [System.Drawing.Color]::Red
                                $Blue = [System.Drawing.Color]::Blue
                                $Green = [System.Drawing.Color]::LimeGreen
                                $DarkGray = [System.Drawing.Color]::DarkGray
                                $BlackPen = [N.e]::w([System.Drawing.Pen],@($Black))
                                $RedPen = [N.e]::w([System.Drawing.Pen],@($Red))
                                $BluePen = [N.e]::w([System.Drawing.Pen],@($Blue))
                                $GreenBrush = [N.e]::w([System.Drawing.SolidBrush],@($Green))
                                $Graphics = [System.Drawing.Graphics]::FromHwnd($TapeForm.Handle)
                                $TapeForm.Add_Paint({$Graphics.FillRectangle($GreenBrush, 70, 70, 5000, 5000)})
                                #$TapeForm.Add_Paint({$Graphics.DrawLine($BlackPen, 40, 40, 5000, 40)})
                                #$TapeForm.Add_Paint({$Graphics.DrawLine($BlackPen, 40, 40, 40, 5000)})
                                $OriginLabel = [N.e]::w([System.Windows.Forms.Label],@())
                                $OriginLabel.Size = [N.e]::w([System.Drawing.Size],@(70,25))
                                $OriginLabel.Location = [N.e]::w([System.Drawing.Size],@(10,10))
                                $OriginLabel.BackColor = [System.Drawing.Color]::Transparent
                                $OriginLabel.Text = '0x0 Loc:'+[System.Environment]::NewLine+([String]($TapeForm.Location.X+83)+','+[String]($TapeForm.Location.Y+106))
                                $OriginLabel.Parent = $TapeForm
                                $OffSet = 50
                                0..5000 | ?{!($_ % ($OffSet)) -OR !($_ % (($OffSet)/2)) -OR !($_ % (($OffSet)/10))} | %{
                                    $PH = ($_+75)
                                    If(!($_ % ($OffSet))){
                                        $LocationLabel = [N.e]::w([System.Windows.Forms.Label],@())
                                        $LocationLabel.Size = [N.e]::w([System.Drawing.Size],@(30,15))
                                        $LocationLabel.Location = [N.e]::w([System.Drawing.Size],@(($PH-5),40))
                                        #$LocationLabel.BackColor = [System.Drawing.Color]::Transparent
                                        $LocationLabel.Text = $_
                                        $LocationLabel.Parent = $TapeForm
                                        $LocationLabel = [N.e]::w([System.Windows.Forms.Label],@())
                                        $LocationLabel.Size = [N.e]::w([System.Drawing.Size],@(30,15))
                                        $LocationLabel.Location = [N.e]::w([System.Drawing.Size],@(22,($PH-5)))
                                        $LocationLabel.RightToLeft  = [System.Windows.Forms.RightToLeft]::Yes
                                        $LocationLabel.Text = $_
                                        $LocationLabel.Parent = $TapeForm
                                        $TapeForm.Add_Paint({$Graphics.DrawLine($BlackPen, $PH, 55, $PH, 5000)}.GetNewClosure())
                                        $TapeForm.Add_Paint({$Graphics.DrawLine($BlackPen, 55, $PH, 5000, $PH)}.GetNewClosure())
                                    }ElseIf(!($_ % ($OffSet/2))){
                                        $TapeForm.Add_Paint({$Graphics.DrawLine($RedPen, $PH, 63, $PH, 5000)}.GetNewClosure())
                                        $TapeForm.Add_Paint({$Graphics.DrawLine($RedPen, 63, $PH, 5000, $PH)}.GetNewClosure())
                                    }Else{
                                        #$TapeForm.Add_Paint({$Graphics.DrawLine($BluePen, $PH, 67, $PH, 5000)}.GetNewClosure())
                                        #$TapeForm.Add_Paint({$Graphics.DrawLine($BluePen, 67, $PH, 5000, $PH)}.GetNewClosure())
                                    }
                                }
                                $TapeForm.Size = [N.e]::w([System.Drawing.Size],@(500,500))
                                
                                $Box = [N.e]::w([System.Windows.Forms.Panel],@())
                                $Box.Size = [N.e]::w([System.Drawing.Size],@(25,25))
                                $Box.Location = [N.e]::w([System.Drawing.Size],@(($TapeForm.Width-41),($TapeForm.Height-64)))
                                $Box.BackColor = $DarkGray
                                $Box.Parent = $TapeForm
                                $TapeForm.Add_SizeChanged({
                                    $Box.Location = [N.e]::w([System.Drawing.Size],@(($This.Width-41),($This.Height-64)))
                                })
                                $TapeForm.Add_LocationChanged({
                                    $OriginLabel.Text = '0x0 Loc:'+[System.Environment]::NewLine+([String]($This.Location.X+83)+','+[String]($This.Location.Y+106))
                                })
                                $TapeForm.TransparencyKey = $Green
                                $TapeForm.BackColor = $DarkGray
                                #$TapeForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::SizableToolWindow
                                [System.Windows.Forms.Application]::Run($TapeForm)
                            })
                            $TapePow.BeginInvoke() | Out-Null
                        })
                        $Tape.Parent = $TabHelperSubMouse
                    $TabHelperSubMouse.Parent = $TabHelperSub
                    $TabHelperSubSystem = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Sys/Proc')))
                        $ScreenInfoLabel = ([N.e]::w([GUI.L],@(110, 15, 10, 8, 'Display Info:')))
                        $ScreenInfoLabel.Parent = $TabHelperSubSystem
                        $ScreenInfoBox = ([N.e]::w([GUI.RTB],@(285, 95, 10, 25, '')))
                        $ScreenInfoBox.Multiline = $True
                        $ScreenInfoBox.ScrollBars = 'Both'
                        $ScreenInfoBox.WordWrap = $False
                        $ScreenInfoBox.ReadOnly = $True
                        $ScreenInfoBox.Text = (([GUI.ScreenInfo]::All | %{$Count = 1}{
                            $PH = $_.Bounds
                            'DISPLAY '+$Count+':'+$NL+'----------------'+$NL+'TOP LEFT     (x,y) : '+$PH.X+','+$PH.Y+$NL+'WIDTH/HEIGHT (w,h) : '+$PH.Width+','+$PH.Height+$NL+$NL
                            $Count++
                        }) -join $NL).TrimEnd($NL)
                        $ScreenInfoBox.Parent = $TabHelperSubSystem
                        $ProcInfoLabel = ([N.e]::w([GUI.L],@(110,15,10,136,'Process Info:')))
                        $ProcInfoLabel.Parent = $TabHelperSubSystem
                        $GetProcInfo = ([N.e]::w([GUI.B],@(140, 23, 125, 129, 'Get Proc Inf')))
                        $GetProcInfo.Add_MouseDown({If($_.Button.ToString() -eq 'Left'){$This.Text = 'Click on Proc'}ElseIf($_.Button.ToString() -eq 'Right'){$ProcInfoBox.Text = ''}})
                        $GetProcInfo.Add_LostFocus({
                            If($This.Text -ne 'Get Proc Inf'){
                                $This.Text = 'Get Proc Inf'
                                $PHFocussedHandle = [GUI.Window]::GetForegroundWindow()
                                $PHProcInfo = (PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle})
                                $PHTextLength = [GUI.Window]::GetWindowTextLength($PHFocussedHandle)
                                $PHString = ([N.e]::w([System.Text.StringBuilder],@(($PHTextLength + 1))))
                                [Void]([GUI.Window]::GetWindowText($PHFocussedHandle, $PHString, $PHString.Capacity))
                                $PHRect = [GUI.Rect]::E
                                [Void]([GUI.Window]::GetWindowRect($PHFocussedHandle,[Ref]$PHRect))
                                $ProcInfoBox.Text = ('ProcName:       '+$PHProcInfo.Name)
                                $ProcInfoBox.Text+=($NL+'ProcId:         '+$PHProcInfo.Id)
                                $ProcInfoBox.Text+=($NL+'WindowText:     '+$PHString)
                                $ProcInfoBox.Text+=($NL+'FocussedHandle: '+$PHFocussedHandle)
                                $ProcInfoBox.Text+=($NL+'WindowTopLeft:  '+$PHRect.X+','+$PHRect.Y)
                                $ProcInfoBox.Text+=($NL+'WindowBotRight: '+$PHRect.Width+','+$PHRect.Height)
                                $ProcInfoBox.Text+=($NL+'WindowWidth:    '+[String]($PHRect.Width-$PHRect.X))
                                $ProcInfoBox.Text+=($NL+'WindowHeight:   '+[String]($PHRect.Height-$PHRect.Y))
                                $ProcInfoBox.Text+=(($NL*2)+'Misc Proc Info:')
                                $ProcInfoBox.Text+=($NL+'---------------')
                                $ProcInfoBox.Text+=($PHProcInfo | Select * | Out-String)
                                $This.Parent.Focus()
                            }
                        })
                        $GetProcInfo.Parent = $TabHelperSubSystem
                        $ProcInfoBox = ([N.e]::w([GUI.RTB],@(285, 160, 10, 155, '')))
                        $ProcInfoBox.Multiline = $True
                        $ProcInfoBox.ScrollBars = 'Both'
                        $ProcInfoBox.WordWrap = $False
                        $ProcInfoBox.ReadOnly = $True
                        $ProcInfoBox.Text = ''
                        $ProcInfoBox.Parent = $TabHelperSubSystem
                    $TabHelperSubSystem.Parent = $TabHelperSub
                    $TabPageDebug = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Debug')))
                        $GetFuncts = ([N.e]::w([GUI.B],@(150, 25, 10, 10, 'Display Functions')))
                        $GetFuncts.Add_Click({
                            $Script:FuncHash.Keys | Sort | %{
                                [System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:FuncHash.$_ + $NL + $NL)
                                [System.Console]::WriteLine($NL * 3)
                            }
                        })
                        $GetFuncts.Parent = $TabPageDebug
                        $GetVars = ([N.e]::w([GUI.B],@(150, 25, 10, 35, 'Display Variables')))
                        $GetVars.Add_Click({
                            $Script:VarsHash.Keys | Sort -Unique | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{
                                [System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:VarsHash.$_ + $NL + $NL)
                                [System.Console]::WriteLine($NL * 3)
                            }
                        })
                        $GetVars.Parent = $TabPageDebug
                        $ClearCons = ([N.e]::w([GUI.B],@(150, 25, 10, 60, 'Clear Console')))
                        $ClearCons.Add_Click({Cls; $PseudoConsole.Text = ''})
                        $ClearCons.Parent = $TabPageDebug
                        $PseudoConsole = ([N.e]::w([GUI.RTB],@(285, 165, 10, 110, '')))
                        $PseudoConsole.ReadOnly = $True
                        $PseudoConsole.ScrollBars = 'Both'
                        #$PseudoConsole.ForeColor = [System.Drawing.Color]::FromArgb(0xFFF5F5F5)
                        #$PseudoConsole.BackColor = [System.Drawing.Color]::FromArgb(0xFF012456)
                        $pseudoConsole.Parent = $TabPageDebug
                        $SingleCMD = ([N.e]::w([GUI.RTB],@(185, 20, 10, 300, '')))
                        $SingleCMD.AcceptsTab = $True
                        $SingleCMD.Parent = $TabPageDebug
                        $SingleGO = ([N.e]::w([GUI.B],@(90, 22, 205, 298, 'Run Line')))
                        $SingleGO.Add_Click({
                            If(!$WhatIfCheck.Checked -AND $SingleCMD.Text){
                                $PrevConsCheck = $ShowCons.Checked
                                $ShowCons.Checked = $True
                                GO -InlineCommand $SingleCMD.Text
                                $ShowCons.Checked = $PrevConsCheck
                            }Else{
                                $PrevConsCheck = $ShowCons.Checked
                                $ShowCons.Checked = $True
                                GO -InlineCommand $SingleCMD.Text -WhatIf
                                $ShowCons.Checked = $PrevConsCheck
                            }
                        })
                        $SingleGO.Parent = $TabPageDebug
                    $TabPageDebug.Parent = $TabHelperSub
                $TabHelperSub.Parent = $TabPageHelper
            $TabPageHelper.Parent = $TabControllerComm
        $TabControllerComm.Parent = $TabPageComm
    $TabPageComm.Parent = $TabController
    $TabPageAdvanced = ([N.e]::w([GUI.TP],@(0, 0, 0, 0,'File')))
        $TabControllerAdvanced = ([N.e]::w([GUI.TC],@(0, 0, 10, 10)))
        $TabControllerAdvanced.Dock = 'Fill'
        $TabControllerAdvanced.SizeMode = 'Fixed'
        $TabControllerAdvanced.DrawMode = 'OwnerDrawFixed'
        $TabControllerAdvanced.Add_DrawItem({
            $PHText = $This.TabPages[$_.Index].Text
                    
            $PHRect = $This.GetTabRect($_.Index)
            $PHRect = ([N.e]::w([System.Drawing.RectangleF],@($PHRect.X,$PHRect.Y,$PHRect.Width,$PHRect.Height)))
            $PHBrush = ([N.e]::w([System.Drawing.SolidBrush],@([System.Drawing.Color]::Black)))
            $PHStrForm = ([N.e]::w([System.Drawing.StringFormat],@()))
            $PHStrForm.Alignment = [System.Drawing.StringAlignment]::Center
            $PHStrForm.LineAlignment = [System.Drawing.StringAlignment]::Center
            $_.Graphics.DrawString($PHText, $This.Font, $PHBrush, $PHRect, $PHStrForm)
        })
        $TabControllerAdvanced.ItemSize = [GUI.SP]::SI(25,75)
        $TabControllerAdvanced.Alignment = [System.Windows.Forms.TabAlignment]::Left
            $TabPageProfiles = ([N.e]::w([GUI.TP],@(0, 0, 0, 0,'Save/Load')))
                $Profile = ([N.e]::w([GUI.L],@(275, 15, 10, 10, 'Working Profile: None/Prev Text')))
                $Profile.Parent = $TabPageProfiles
                $SavedProfilesLabel = ([N.e]::w([GUI.L],@(75, 15, 85, 36, 'Profiles:')))
                $SavedProfilesLabel.Parent = $TabPageProfiles
                $RefreshProfiles = ([N.e]::w([GUI.B],@(75, 21, 10, 33, 'Refresh')))
                $RefreshProfiles.Add_Click({
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                    $SavedProfiles.SelectedItem = $Script:LoadedProfile})
                $RefreshProfiles.Parent = $TabPageProfiles
                $LoadProfile = ([N.e]::w([GUI.B],@(75, 21, 10, 54, 'Load')))
                $LoadProfile.Add_Click({
                    If((Get-ChildItem ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem)).Count -gt 0 -AND $SavedProfiles.SelectedIndex -ne -1){
                        $PHChosenLoad = $SavedProfiles.SelectedItem
                        If((Check-Saved) -ne 'Cancel'){
                            $SavedProfiles.SelectedItem = $PHChosenLoad
                            $Profile.Text = ('Working Profile: ' + $(If($SavedProfiles.SelectedItem -ne $Null){$SavedProfiles.SelectedItem}Else{'None/Prev Text'}))
                            $Script:LoadedProfile = $SavedProfiles.SelectedItem
                            $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem+'\')
                            $Commands.Text = ' '
                            $Commands.SelectionStart = 0
                            $Commands.SelectionLength = $Commands.Text.Length
                            $Commands.SelectionColor = [System.Drawing.Color]::Black
                            $Commands.Text = Try{
                                ((Get-Content ($TempDir+$SavedProfiles.SelectedItem+'.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Commands | Out-String).TrimEnd($NL)# -join $NL
                            }Catch{
                                Try{
                                    ((Get-Content ($TempDir+$SavedProfiles.SelectedItem+'.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Commands | Out-String).TrimEnd($NL)# -join $NL
                                }Catch{
                                    ''
                                }
                            }
                            $FunctionsBox.Text = ' '
                            $FunctionsBox.SelectionStart = 0
                            $FunctionsBox.SelectionLength = $FunctionsBox.Text.Length
                            $FunctionsBox.SelectionColor = [System.Drawing.Color]::Black
                            $FunctionsBox.Text = Try{
                                ((Get-Content ($TempDir+$SavedProfiles.SelectedItem+'.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Functions | Out-String).TrimEnd($NL)# -join $NL
                            }Catch{
                                Try{
                                    ((Get-Content ($TempDir+$SavedProfiles.SelectedItem+'.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Functions | Out-String).TrimEnd($NL)# -join $NL
                                }Catch{
                                    ''
                                }
                            }
                            $Script:Saved = $True
                            $Form.Text = ('PIK - ' + $SavedProfiles.SelectedItem)
                        }
                    }
                })
                $LoadProfile.Parent = $TabPageProfiles
                $SavedProfiles = ([N.e]::w([GUI.CoB],@(175, 21, 85, 55)))
                $SavedProfiles.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                $SavedProfiles.Parent = $TabPageProfiles
                $QuickSave = ([N.e]::w([GUI.B],@(75, 21, 10, 75, 'Save')))
                $QuickSave.Add_Click({[Void](Save-Profile)})
                $QuickSave.Parent = $TabPageProfiles
                $SaveProfile = ([N.e]::w([GUI.B],@(75, 21, 10, 96, 'Save As')))
                $SaveProfile.Add_Click({
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
                })
                $SaveProfile.Parent = $TabPageProfiles
                $BlankProfile = ([N.e]::w([GUI.B],@(75, 21, 10, 150, 'New/Blank')))
                $BlankProfile.Add_Click({
                    If((Check-Saved) -ne 'Cancel'){
                        $Profile.Text = 'Working Profile: None/Prev Text'
                        $Script:LoadedProfile = $Null
                    
                        $SavedProfiles.SelectedIndex = -1
                        $Commands.Text = ''
                        $FunctionsBox.Text = ''
                        $Script:Saved = $True
                        $Form.Text = 'PIK'
                    }
                })
                $BlankProfile.Parent = $TabPageProfiles
                $ImportProfile = ([N.e]::w([GUI.B],@(75,21,186,75,'Import')))
                $ImportProfile.Add_Click({
                    If((Check-Saved) -ne 'Cancel'){
                        $DialogO = ([N.e]::w([System.Windows.Forms.OpenFileDialog],@()))
                        $DialogO.InitialDirectory = (PWD).Path
                        $DialogO.Filter = 'pik files (*.pik)|*.pik|ps1 files (*.ps1)|*.ps1'
                        $DialogO.MultiSelect = $True
                        $DialogO.ShowHelp = $True
                        $DialogO.RestoreDirectory = $True
 
                        If($DialogO.ShowDialog() -eq 'OK'){
                            $PIK_PS1 = ($DialogO.FileName -match '\.ps1$')
                            If($PIK_PS1){
                                $PH = ((GC $DialogO.FileName | Out-String).Split($NL) | ?{$_ -ne ''} | %{$Started = $False}{
                                    If($_ -match 'GO -InlineCommand \$ScriptedCMDs'){
                                        $Started = $False
                                    }
                            
                                    If($Started){$_}
                                    If($_ -match '\$ScriptedCMDs = @'){
                                        $Started = $True
                                    }
                                })
                                $PH[-1] = ''
                                $Profile.Text = 'Working Profile: None/Prev Text'
                                $Script:LoadedProfile = $Null
                    
                                $SavedProfiles.SelectedIndex = -1
                                $Commands.Text = ($PH -join $NL)
                                $FunctionsBox.Text = ''
                                $Script:Saved = $False
                                $Form.Text = 'PIK*'
                            }Else{
                                $ImportedName = ($DialogO.FileName.Split('\')[-1] -replace '\.pik$')
                                $Profile.Text = ('Working Profile: ' + $ImportedName)
                                $Script:LoadedProfile = $ImportedName
                                $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$ImportedName+'\')
                                [Void](MKDIR $TempDir)
                                $Commands.Text = ' '
                                $Commands.SelectionStart = 0
                                $Commands.SelectionLength = $Commands.Text.Length
                                $Commands.SelectionColor = [System.Drawing.Color]::Black
                                $Commands.Text = Try{
                                    ((Get-Content $DialogO.FileName -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Commands | Out-String).TrimEnd($NL)# -join $NL
                                }Catch{
                                    Try{
                                        ((Get-Content $DialogO.FileName -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Commands | Out-String).TrimEnd($NL)# -join $NL
                                    }Catch{
                                        ''
                                    }
                                }
                                $FunctionsBox.Text = ' '
                                $FunctionsBox.SelectionStart = 0
                                $FunctionsBox.SelectionLength = $FunctionsBox.Text.Length
                                $FunctionsBox.SelectionColor = [System.Drawing.Color]::Black
                                $FunctionsBox.Text = Try{
                                    ((Get-Content $DialogO.FileName -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Functions | Out-String).TrimEnd($NL)# -join $NL
                                }Catch{
                                    Try{
                                        ((Get-Content $DialogO.FileName -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Functions | Out-String).TrimEnd($NL)# -join $NL
                                    }Catch{
                                        ''
                                    }
                                }
                                Try{
                                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$ImportedName+'.pik') -Width 10000 -Force
                                }Catch{
                                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$ImportedName+'.pik') -Width 10000 -Force
                                }
                                $SavedProfiles.Items.Clear()
                                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                                $SavedProfiles.SelectedItem = $Script:LoadedProfile
                                #$SaveAsProfText.Text = ''
                                $Script:Saved = $True
                                $Form.Text = ('PIK - ' + $ImportedName)
                            }
                        }
                    }
                })
                $ImportProfile.Parent = $TabPageProfiles
                $ExportProfile = ([N.e]::w([GUI.B],@(75,21,186,95,'Export')))
                $ExportProfile.Add_Click({
                    $PIK_PS1 = ([System.Windows.Forms.MessageBox]::Show('Export as executable script? Select "No" or close to save as a PIK file instead.','Export Type','YesNo') -eq 'Yes')
                    
                    $DialogS = ([N.e]::w([System.Windows.Forms.SaveFileDialog],@()))
                    $DialogS.InitialDirectory = (PWD).Path
                    If($PIK_PS1){
                        $DialogS.Filter = 'ps1 files (*.ps1)|*.ps1'
                    }Else{
                        $DialogS.Filter = 'pik files (*.pik)|*.pik'
                    }
                    #$DialogS.MultiSelect = $True
                    $DialogS.ShowHelp = $True
                    $DialogS.RestoreDirectory = $True
 
                    If($DialogS.ShowDialog() -eq 'OK'){
                        #$SavePath = $DialogS.FileName
                        If($PIK_PS1){
                            $Temp+=('$ScriptedCMDs = '+[Char]64+"'"+$NL)
                            $Temp+=($FunctionsBox.Text+$NL)
                            $Temp+=($Commands.Text+$NL)
                            $Temp+=("'"+[Char]64+$NL)
                            $Temp+=('$CSharpDef = '+[Char]64+"'"+$NL)
                            $Temp+=($CSharpDef+$NL)
                            $Temp+=("'"+[Char]64+$NL)
                            $Temp+=('Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic -IgnoreWarnings -TypeDefinition $CSharpDef'+$NL)
                            $Temp+=('Function Interpret{'+$NL)
                            $Temp+=(((GCI Function:Interpret).Definition)+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('Function Actions{'+$NL)
                            $Temp+=((GCI Function:Actions).Definition)
                            $Temp+=('}'+$NL)
                            $Temp+=('Function Parse-IfEl{'+$NL)
                            $Temp+=((GCI Function:Parse-IfEl).Definition)
                            $Temp+=('}'+$NL)
                            $Temp+=('Function Parse-While{'+$NL)
                            $Temp+=((GCI Function:Parse-While).Definition)
                            $Temp+=('}'+$NL)
                            $Temp+=('Function GO{'+$NL)
                            $Temp+=((((GCI Function:GO).Definition.Split($NL) | ?{($_ -ne '') -AND ($_ -notmatch '\$Commands') -AND ($_ -notmatch '\$Form') -AND ($_ -notmatch '\$FunctionsBox') -AND ($_ -notmatch '#Ignore')}) -join $NL)+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('$Tab = ([String][Char][Int]9)'+$NL)
                            $Temp+=('$NL = [System.Environment]::NewLine'+$NL)
                            $Temp+=('$Script:Refocus = $False'+$NL)
                            $Temp+=('$Script:Inside_If = $False'+$NL)
                            $Temp+=('$Script:IfElDepth = 0'+$NL)
                            $Temp+=('$Script:IfElEval = $False'+$NL)
                            $Temp+=('$Script:Inside_While = $False'+$NL)
                            $Temp+=('$Script:WhileDepth = 0'+$NL)
                            $Temp+=('$Script:WhileEval = $False'+$NL)
                            $Temp+=('$Script:BufferedCommandsIfEl = ""'+$NL)
                            $Temp+=('$Script:BufferedCommandsWhile = ""'+$NL)
                            $Temp+=('$UndoHash = @{KeyList=[String[]]@()}'+$NL)
                            $Temp+=('$Script:VarsHash = @{}'+$NL)
                            $Temp+=('$Script:FuncHash = @{}'+$NL)
                            $Temp+=('$Script:HiddenWindows = @{}'+$NL)
                            $Temp+=('$SyncHash = [HashTable]::Synchronized(@{Stop=$False;Kill=$False;Restart=$False;SrvPort=42069;SrvIP="0.0.0.0"})'+$NL)
                            $Temp+=('$ClickHelperParent = [HashTable]::Synchronized(@{})'+$NL)
                            $Temp+=('$AutoChange = $False'+$NL)
                            $Temp+=('$MutexPow = [Powershell]::Create()'+$NL)
                            $Temp+=('$MutexRun = [RunspaceFactory]::CreateRunspace()'+$NL)
                            $Temp+=('$MutexRun.ApartmentState = [System.Threading.ApartmentState]::STA'+$NL)
                            $Temp+=('$MutexRun.Open()'+$NL)
                            $Temp+=('$MutexPow.Runspace = $MutexRun'+$NL)
                            $Temp+=('$MutexPow.AddScript({'+$NL)
                            $Temp+=('    Param($SyncHash)'+$NL)
                            $Temp+=('    Add-Type -Name KeyState -Namespace Keyboard -IgnoreWarnings -MemberDefinition '+"'"+$NL)
                            $Temp+=('    [DllImport("C:\\Windows\\System32\\user32.dll")]'+$NL)
                            $Temp+=('    public static extern short GetAsyncKeyState(int KCode);'+$NL)
                            $Temp+=('    '+"'"+$NL)
                            $Temp+=('    Add-Type -Name e -Namespace N -MemberDefinition '+"'"+$NL)
                            $Temp+=('    public static Object w (Type type, params Object[] args){'+$NL)
                            $Temp+=('        return System.Activator.CreateInstance(type, args);'+$NL)
                            $Temp+=('    }'+$NL)
                            $Temp+=('    '+"'"+$NL)
                            $Temp+=('    $PHCMDS = '+"'"+'{CMDS_START}'+"'"+'($NL*2)'+"'"+'{SERVERSTOP}'+"'"+'($NL*2)'+"'"+'{CMDS_END}'+"'"+$NL)
                            $Temp+=('    $SSrv = [Text.Encoding]::UTF8.GetBytes($PHCMDS)'+$NL)
                            $Temp+=('    While(!$SyncHash.Kill){'+$NL)
                            $Temp+=('        [System.Threading.Thread]::Sleep(10)'+$NL)
                            $Temp+=('        Try{'+$NL)
                            $Temp+=('            If([Keyboard.KeyState]::GetAsyncKeyState(145)){'+$NL)
                            $Temp+=('                $SyncHash.Stop = $True'+$NL)
                            $Temp+=('                $SyncHash.Restart = $False'+$NL)
                            $Temp+=('                $IP = [String]$SyncHash.SrvIP'+$NL)
                            $Temp+=('                If($IP -match '+"'"+'0\.0\.0\.0'+"'"+'){'+$NL)
                            $Temp+=('                    $IP = '+"'"+'127.0.0.1'+"'"+$NL)
                            $Temp+=('                }'+$NL)
                            $Temp+=('                $Port = [Int]$SyncHash.SrvPort'+$NL)
                            $Temp+=('                $TmpCli = ([N.e]::w([System.Net.Sockets.TCPClient],@($IP,$Port)))'+$NL)
                            $Temp+=('                $TmpStr = $TmpCli.GetStream()'+$NL)
                            $Temp+=('                $TmpStr.Write($SSrv,0,$SSrv.Count)'+$NL)
                            $Temp+=('                $TmpStr.Close()'+$NL)
                            $Temp+=('                $TmpStr.Dispose()'+$NL)   
                            $Temp+=('                $TmpCli.Close()'+$NL)
                            $Temp+=('                $TmpCli.Dispose()'+$NL)
                            $Temp+=('                [System.Threading.Thread]::Sleep(500)'+$NL)
                            $Temp+=('            }'+$NL)
                            $Temp+=('        }Catch{}'+$NL)
                            $Temp+=('    }'+$NL)
                            $Temp+=('}) | Out-Null'+$NL)
                            $Temp+=('$MutexPow.AddParameter('+"'"+'SyncHash'+"'"+', $SyncHash) | Out-Null'+$NL)
                            $Temp+=('$MutexHandle = $MutexPow.BeginInvoke()'+$NL)
                            $Temp+=('$ShowCons = @{Checked=$True}'+$NL)
                            $Temp+=('GO -InlineCommand $ScriptedCMDs'+$NL)
                            $Temp+=('$UndoHash.KeyList | %{'+$NL)
                            $Temp+=('    If($_ -notmatch '+"'"+'MOUSE'+"'"+'){'+$NL)
                            $Temp+=('        [GUI.Events]::keybd_event(([String]$_), 0, '+"'"+'&H2'+"'"+', 0)'+$NL)
                            $Temp+=('    }Else{'+$NL)
                            $Temp+=('        [GUI.Events]::mouse_event(([Int]($_.Replace('+"'"+'MOUSE'+"'"+','+"'"+''+"'"+').Replace('+"'"+'L'+"'"+',4).Replace('+"'"+'R'+"'"+',16).Replace('+"'"+'M'+"'"+',64))), 0, 0, 0, 0)'+$NL)
                            $Temp+=('    }'+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('$SyncHash.Kill = $True'+$NL)
                            $Temp+=('$MutexPow.EndInvoke($MutexHandle)'+$NL)
                            $Temp+=('$MutexRun.Close()'+$NL)
                            $Temp+=('$MutexPow.Dispose()'+$NL)
                            $Temp | Out-File $DialogS.FileName -Width 10000 -Encoding UTF8
                        }Else{
                            Try{
                                '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File $DialogS.FileName -Width 10000 -Force
                            }Catch{
                                '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File $DialogS.FileName -Width 10000 -Force
                            }
                        }
                    }
                })
                $ExportProfile.Parent = $TabPageProfiles
                #$SaveNewProfLabel = ([N.e]::w([GUI.L],@(170, 20, 10, 190, 'Save Current Profile As:')))
                #$SaveNewProfLabel.Parent = $TabPageProfiles
                #$SaveAsProfText = ([N.e]::w([GUI.TB],@(165, 25, 10, 210, '')))
                #$SaveAsProfText.Parent = $TabPageProfiles
                <#$DelProfLabel = ([N.e]::w([GUI.L],@(170, 20, 10, 260, 'Delete Profile:')))
                $DelProfLabel.Parent = $TabPageProfiles
                $DelProfile = ([N.e]::w([GUI.B],@(75, 20, 186, 279, 'Delete')))
                $DelProfile.Add_Click({
                    If($Script:LoadedProfile -eq $DelProfText.Text){
                        $Profile.Text = ('Working Profile: None/Prev Text')
                        $SavedProfiles.SelectedItem = $Null
                        $Script:LoadedProfile = $Null
                        $Form.Text = ('PIK')
                        $Script:Saved = $True
                    }
                    (Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | ?{$_.Name -eq $DelProfText.Text} | Remove-Item -Recurse -Force
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                    $DelProfText.Text = ''
                })
                $DelProfile.Parent = $TabPageProfiles
                $DelProfText = ([N.e]::w([GUI.TB],@(165, 25, 10, 280, '')))
                $DelProfText.Parent = $TabPageProfiles#>
                $OpenFolder = ([N.e]::w([GUI.B],@(250, 25, 10, 330, 'Open Profile Folder')))
                $OpenFolder.Add_Click({Explorer ($env:APPDATA+'\Macro\Profiles')})
                $OpenFolder.Parent = $TabPageProfiles
            $TabPageProfiles.Parent = $TabControllerAdvanced
            $TabPageServer = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Comms')))
                $ListenerLabel = ([N.e]::w([GUI.L],@(300,15,22,10,'Listening IP/Port:')))
                $ListenerLabel.Parent = $TabPageServer
                $ServerIPOct1 = ([N.e]::w([GUI.TB],@(30,25,25,25,'0')))
                $ServerIPOct1.Add_GotFocus({$This.SelectAll()})
                $ServerIPOct1.Add_LostFocus({If(!$This.Text){$This.Text = '0'}})
                $ServerIPOct1.Add_TextChanged({
                    $This.Text = ($This.Text -replace '\D')
                    If($This.Text -match '^0\d'){$This.Text = ($This.Text -replace '^0')}
                    If([Int]$This.Text -gt 255){
                        $This.Text = '255'
                        $ServerIPOct2.Focus()
                    }ElseIf($This.Text.Length -eq 3){
                       $ServerIPOct2.Focus()
                    }
                    $This.SelectionStart = ($This.Text.Length)
                })
                $ServerIPOct1.Add_KeyUp({
                    If($_.KeyCode -match 'OemPeriod' -OR $_.KeyCode -match 'Decimal'){$ServerIPOct2.Focus()}
                })
                $ServerIPOct1.Parent = $TabPageServer
                $ServerIPOct2 = ([N.e]::w([GUI.TB],@(30,25,65,25,'0')))
                $ServerIPOct2.Add_GotFocus({$This.SelectAll()})
                $ServerIPOct2.Add_LostFocus({If(!$This.Text){$This.Text = '0'}})
                $ServerIPOct2.Add_TextChanged({
                    $This.Text = ($This.Text -replace '\D')
                    If($This.Text -match '^0\d'){$This.Text = ($This.Text -replace '^0')}
                    If([Int]$This.Text -gt 255){
                        $This.Text = '255'
                        $ServerIPOct3.Focus()
                    }ElseIf($This.Text.Length -eq 3){
                        $ServerIPOct3.Focus()
                    }
                    $This.SelectionStart = ($This.Text.Length)
                })
                $ServerIPOct2.Add_KeyUp({
                    If($_.KeyCode -match 'OemPeriod' -OR $_.KeyCode -match 'Decimal'){$ServerIPOct3.Focus()}
                })
                $ServerIPOct2.Add_KeyDown({
                    If($_.KeyCode -match 'Back' -AND !$This.Text){$_.SuppressKeyPress = $True; $This.Text = '0'; $ServerIPOct1.Focus()}
                })
                $ServerIPOct2.Parent = $TabPageServer
                $ServerIPOct3 = ([N.e]::w([GUI.TB],@(30,25,105,25,'0')))
                $ServerIPOct3.Add_GotFocus({$This.SelectAll()})
                $ServerIPOct3.Add_LostFocus({If(!$This.Text){$This.Text = '0'}})
                $ServerIPOct3.Add_TextChanged({
                    $This.Text = ($This.Text -replace '\D')
                    If($This.Text -match '^0\d'){$This.Text = ($This.Text -replace '^0')}
                    If([Int]$This.Text -gt 255){
                        $This.Text = '255'
                        $ServerIPOct4.Focus()
                    }ElseIf($This.Text.Length -eq 3){
                        $ServerIPOct4.Focus()
                    }
                    $This.SelectionStart = ($This.Text.Length)
                })
                $ServerIPOct3.Add_KeyUp({
                    If($_.KeyCode -match 'OemPeriod' -OR $_.KeyCode -match 'Decimal'){$ServerIPOct4.Focus()}
                })
                $ServerIPOct3.Add_KeyDown({
                    If($_.KeyCode -match 'Back' -AND !$This.Text){$_.SuppressKeyPress = $True; $This.Text = '0'; $ServerIPOct2.Focus()}
                })
                $ServerIPOct3.Parent = $TabPageServer
                $ServerIPOct4 = ([N.e]::w([GUI.TB],@(30,25,145,25,'0')))
                $ServerIPOct4.Add_GotFocus({$This.SelectAll()})
                $ServerIPOct4.Add_LostFocus({If(!$This.Text){$This.Text = '0'}})
                $ServerIPOct4.Add_TextChanged({
                    $This.Text = ($This.Text -replace '\D')
                    If($This.Text -match '^0\d'){$This.Text = ($This.Text -replace '^0')}
                    If([Int]$This.Text -gt 255){
                        $This.Text = '255'
                        $ServerPort.Focus()
                    }ElseIf($This.Text.Length -eq 3){
                        $ServerPort.Focus()
                    }
                    $This.SelectionStart = ($This.Text.Length)
                })
                $ServerIPOct4.Add_KeyDown({
                    If($_.KeyCode -match 'Back' -AND !$This.Text){$_.SuppressKeyPress = $True; $This.Text = '0'; $ServerIPOct3.Focus()}
                })
                $ServerIPOct4.Parent = $TabPageServer
                $ServerPort = ([N.e]::w([GUI.TB],@(75,25,190,25,'42069')))
                $ServerPort.Add_TextChanged({
                    $This.Text = ($This.Text -replace '\D')
                    If($This.Text -match '^0\d'){$This.Text = ($This.Text -replace '^0')}
                    If([Int]$This.Text -gt 65535){
                        $This.Text = '65535'
                    }
                    $This.SelectionStart = ($This.Text.Length)
                })
                $ServerPort.Add_KeyDown({
                    If($_.KeyCode -match 'Back' -AND !$This.Text){$_.SuppressKeyPress = $True; $This.Text = '42069'; $ServerIPOct4.Focus()}
                })
                $ServerPort.Parent = $TabPageServer
                $ServerStart = ([N.e]::w([GUI.B],@(150, 25, 25, 50, 'Start Listener')))
                $ServerStart.Add_Click({
                    $PHPort = [Int]$ServerPort.Text
                    $SyncHash.SrvPort = $PHPort
                    $SyncHash.SrvIP = ($ServerIPOct1.Text+'.'+$ServerIPOct2.Text+'.'+$ServerIPOct3.Text+'.'+$ServerIPOct4.Text)
                    $Reverse = $False

                    If($Reverse){
                        $MaxTime = [Int]$CliTimeOut.Value
                    }Else{
                        $MaxTime = [Int]$SrvTimeOut.Value
                        $Listener = ([N.e]::w([System.Net.Sockets.TcpListener],@($SyncHash.SrvIP,$PHPort)))
                    }

                    [GUI.Window]::ShowWindow($Form.Handle,0)
                    
                    While(!$SyncHash.Stop){
                        $Buff = [N.e]::w([Byte[]],@(1024))
                        $CMDsIn = ''
                        $Timeout = 1

                        Try{
                            [Void][IPAddress]$SyncHash.SrvIP
                            If($Reverse){
                                If($SyncHash.SrvIP -ne '0.0.0.0'){
                                    $Client = ([N.e]::w([System.Net.Sockets.TcpClient],@($SyncHash.SrvIP,$PHPort)))
                                    $Stream = $Client.GetStream()
                                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Successful Remote Connect!'+$NL+'---------------'+$NL)
                                    [System.Console]::WriteLine($Tab+'Waiting for incoming commands...')
                                }Else{
					[System.Console]::WriteLine($Tab+'ERROR! '+$SyncHash.SrvIP+' IS AN INVALID REMOTE IP!')
				}
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
                })
                $ServerStart.Parent = $TabPageServer
                $RevServerStart = ([N.e]::w([GUI.B],@(150, 25, 25, 75, 'Connect and Listen')))
                $RevServerStart.Add_Click({
                    $PHPort = [Int]$ServerPort.Text
                    $SyncHash.SrvPort = $PHPort
                    $SyncHash.SrvIP = ($ServerIPOct1.Text+'.'+$ServerIPOct2.Text+'.'+$ServerIPOct3.Text+'.'+$ServerIPOct4.Text)
                    $Reverse = $True

                    If($Reverse){
                        $MaxTime = [Int]$CliTimeOut.Value
                    }Else{
                        $MaxTime = [Int]$SrvTimeOut.Value
                        $Listener = ([N.e]::w([System.Net.Sockets.TcpListener],@($SyncHash.SrvIP,$PHPort)))
                    }

                    [GUI.Window]::ShowWindow($Form.Handle,0)
                    
                    While(!$SyncHash.Stop){
                        $Buff = [N.e]::w([Byte[]],@(1024))
                        $CMDsIn = ''
                        $Timeout = 1

                        Try{
                            [Void][IPAddress]$SyncHash.SrvIP
                            If($Reverse){
                                If($SyncHash.SrvIP -ne '0.0.0.0'){
                                    $Client = ([N.e]::w([System.Net.Sockets.TcpClient],@($SyncHash.SrvIP,$PHPort)))
                                    $Stream = $Client.GetStream()
                                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Successful Remote Connect!'+$NL+'---------------'+$NL)
                                    [System.Console]::WriteLine($Tab+'Waiting for incoming commands...')
                                }Else{
					[System.Console]::WriteLine($Tab+'ERROR! '+$SyncHash.SrvIP+' IS AN INVALID REMOTE IP!')
				}
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
                })
                $RevServerStart.Parent = $TabPageServer
                $CliTimeOutLabel = ([N.e]::w([GUI.L],@(172, 15, 25, 200, 'Sender Timeout (s):')))
                $CliTimeOutLabel.Parent = $TabPageServer
                $CliTimeOut = ([N.e]::w([GUI.NUD],@(150, 25, 25, 220)))
                $CliTimeOut.Maximum = 999999999
                $CliTimeOut.Minimum = 1
                $CliTimeOut.Value = 3600
                $CliTimeOut.Parent = $TabPageServer
                $SrvTimeOutLabel = ([N.e]::w([GUI.L],@(172, 15, 25, 275, 'Listener Timeout (s):')))
                $SrvTimeOutLabel.Parent = $TabPageServer
                $SrvTimeOut = ([N.e]::w([GUI.NUD],@(150, 25, 25, 295)))
                $SrvTimeOut.Maximum = 999999999
                $SrvTimeOut.Minimum = 1
                $SrvTimeOut.Value = 3600
                $SrvTimeOut.Parent = $TabPageServer
                $IPFormattingLabel1 = ([N.e]::w([GUI.L],@(50,20,25,32,'    .')))
                $IPFormattingLabel1.Parent = $TabPageServer
                $IPFormattingLabel2 = ([N.e]::w([GUI.L],@(50,20,65,32,'    .')))
                $IPFormattingLabel2.Parent = $TabPageServer
                $IPFormattingLabel3 = ([N.e]::w([GUI.L],@(50,20,105,32,'    .')))
                $IPFormattingLabel3.Parent = $TabPageServer
                $IPFormattingLabel4 = ([N.e]::w([GUI.L],@(50,20,147,28,'    :')))
                $IPFormattingLabel4.Parent = $TabPageServer
            $TabPageServer.Parent = $TabControllerAdvanced
            $TabPageConfig = ([N.e]::w([GUI.TP],@(0, 0, 0, 0, 'Config')))
                $DelayLabel = ([N.e]::w([GUI.L],@(175, 22, 10, 8, 'Keystroke Delay (ms):')))
                $DelayLabel.Parent = $TabPageConfig
                $DelayTimer = ([N.e]::w([GUI.NUD],@(150, 25, 10, 30)))
                $DelayTimer.Maximum = 999999999
                $DelayTimer.Parent = $TabPageConfig
                $DelayTimer.BringToFront()
                $DelayCheck = ([N.e]::w([GUI.ChB],@(150, 25, 170, 25, 'Randomize')))
                $DelayCheck.Parent = $TabPageConfig
                $DelayRandLabel = ([N.e]::w([GUI.L],@(200, 25, 25, 60, 'Random Weight (ms):')))
                $DelayRandLabel.Parent = $TabPageConfig
                $DelayRandTimer = ([N.e]::w([GUI.NUD],@(75, 25, 180, 55)))
                $DelayRandTimer.Maximum = 999999999
                $DelayRandTimer.Parent = $TabPageConfig
                $DelayRandTimer.BringToFront()
                $CommDelayLabel = ([N.e]::w([GUI.L],@(175, 22, 10, 108, 'Command Delay (ms):')))
                $CommDelayLabel.Parent = $TabPageConfig
                $CommandDelayTimer = ([N.e]::w([GUI.NUD],@(150, 25, 10, 130)))
                $CommandDelayTimer.Maximum = 999999999
                $CommandDelayTimer.Parent = $TabPageConfig
                $CommandDelayTimer.BringToFront()
                $CommDelayCheck = ([N.e]::w([GUI.ChB],@(150, 25, 170, 125, 'Randomize')))
                $CommDelayCheck.Parent = $TabPageConfig
                $CommRandLabel = ([N.e]::w([GUI.L],@(200, 25, 25, 160, 'Random Weight (ms):')))
                $CommRandLabel.Parent = $TabPageConfig
                $CommRandTimer = ([N.e]::w([GUI.NUD],@(75, 25, 180, 155)))
                $CommRandTimer.Maximum = 999999999
                $CommRandTimer.Parent = $TabPageConfig
                $CommRandTimer.BringToFront()
                $ShowCons = ([N.e]::w([GUI.ChB],@(150, 25, 10, 200, 'Show Console')))
                $ShowCons.Add_CheckedChanged({
                    If($Host.Name -match 'Console'){
                        If($This.Checked){
                            [Void][GUI.Window]::ShowWindow([Cons.Wind]::GetConsoleWindow(), 1)
                        }Else{
                            [Void][GUI.Window]::ShowWindow([Cons.Wind]::GetConsoleWindow(), 0)
                        }
                    }
                })
                $ShowCons.Parent = $TabPageConfig
                $OnTop = ([N.e]::w([GUI.ChB],@(150, 25, 10, 225, 'Always On Top')))
                $OnTop.Add_CheckedChanged({
                    $Form.TopMost = !$Form.TopMost
                })
		        $OnTop.Parent = $TabPageConfig
		
		        $Bold = ([N.e]::w([GUI.ChB],@(150, 25, 10, 250, 'Bold Font')))
                $Bold.Add_CheckedChanged({
                    If($This.Checked){
		    	        $Form.Controls | %{$_.Font = [N.e]::w([System.Drawing.Font],@('Lucida Console',9,[System.Drawing.FontStyle]::Bold))}
		            }Else{
		    	        $Form.Controls | %{$_.Font = [N.e]::w([System.Drawing.Font],@('Lucida Console',9,[System.Drawing.FontStyle]::Regular))}
		            }
                })
                $Bold.Parent = $TabPageConfig
                $MousePosCheck = ([N.e]::w([GUI.ChB],@(175, 25, 10, 275, 'Show Mouse Position')))
                $MousePosCheck.Add_CheckedChanged({
                    $SyncHash.ShowMouse = $This.Checked
                })
                $MousePosCheck.Parent = $TabPageConfig
            $TabPageConfig.Parent = $TabControllerAdvanced
        $TabControllerAdvanced.Parent = $TabPageAdvanced
    $TabPageAdvanced.Parent = $TabController
$TabController.Parent = $Form
$Help = ([N.e]::w([GUI.B],@(25, 25, 430, -1, '?')))
$Help.Add_Click({Notepad ($env:APPDATA+'\Macro\Help.txt')})
$Help.Parent = $Form
$GO = ([N.e]::w([GUI.B],@(200, 25, 25, 415, 'Run')))
$GO.Add_Click({If(!$WhatIfCheck.Checked){GO}Else{GO -WhatIf}})
$GO.Parent = $Form
$GOSel = ([N.e]::w([GUI.B],@(125, 25, 230, 415, 'Run Selection')))
$GOSel.Add_Click({
    If(!$WhatIfCheck.Checked){
        GO -Selection
    }Else{
        GO -Selection -WhatIf
    }
})
$GOSel.Parent = $Form
$WhatIfCheck = ([N.e]::w([GUI.ChB],@(80,27,365,415,'WhatIf?')))
$WhatIfCheck.Parent = $Form
$Form.Add_SizeChanged({
    $TabController.Size         = [GUI.SP]::SI((([Int]$This.Width)-65),(([Int]$This.Height)-100))
    $TabControllerAdvanced.Size = [GUI.SP]::SI((([Int]$TabController.Width)-30),(([Int]$TabController.Height)-50))
    
    $ScreenInfoBox.Size         = [GUI.SP]::SI(($TabController.Width-120),95)
    $PseudoConsole.Size         = [GUI.SP]::SI(($TabController.Width-120),($TabController.Height-235))
    $SingleCMD.Location         = [GUI.SP]::PO(10,($TabController.Height-100))
    $SingleCMD.Size             = [GUI.SP]::SI(($TabController.Width-220),20)
    
    $SingleGO.Location          = [GUI.SP]::PO(($TabController.Width-200),($TabController.Height-102))
    $Help.Location              = [GUI.SP]::PO(($This.Width-40),-1)
    #$Help.Size                  = [GUI.SP]::SI(($SingleCMD.Width+$SingleGo.Width+10),25)
    $ProcInfoBox.Size           = [GUI.SP]::SI(($SingleCMD.Width+$SingleGo.Width+10),($TabController.Height-240))
    
    $GO.Location                = [GUI.SP]::PO(25,(([Int]$This.Height)-85))
    $GO.Size                    = [GUI.SP]::SI((([Int]$This.Width/2)-35),25)
    
    $GOSel.Location             = [GUI.SP]::PO(($GO.Width+30),(([Int]$This.Height)-85))
    $GOSel.Size                 = [GUI.SP]::SI(($GO.Width-75),25)
    
    $WhatIfCheck.Location       = [GUI.SP]::PO(($This.Width-105),(([Int]$This.Height)-85))
    
    $FindForm.Location          = [GUI.SP]::PO((($This.Width - 250) / 2),(($This.Height - 90) / 2))
})

$Height = 22
$RightClickMenu = ([N.e]::w([GUI.P],@(0,0,-1000,-1000)))
    $RClickMenuArr = (
        (
            'Cut',`
            'Copy',`
            'Paste',`
            'Select All',`
            'Select Line',`
            'Delete',`
            'Highlight Syntax',`
            'Undo',`
            'Redo',`
            'WhatIf Selection',`
            'WhatIf',`
            'Goto Top',`
            'Goto Bottom',`
            'Find/Replace',`
            'Run Selection',`
            'Run'
        ) | %{
            $Index = 0
        }{
            $Text = $_
            $Offset = ($Height*$Index)
            $PH = ([N.e]::w([GUI.B],@()))
            $PH.Size = [GUI.SP]::SI(135,$Height)
            $PH.Location = [GUI.SP]::PO(0,$Offset)
            $PH.Text = $Text
            $PH.Add_Click({Handle-RMenuClick $This})
            $PH.Add_MouseLeave({Handle-RMenuExit $This})
            $PH.FlatStyle = 'Flat'
            $PH.FlatAppearance.BorderSize = 0
            $PH.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
            $PH.Parent = $RightClickMenu
            $PH
            $Index++
        }
    )
$RightClickMenu.Size = [GUI.SP]::SI(137,(2+($Index*$Height)))
$RightClickMenu.Visible = $False
$RightClickMenu.BorderStyle = 'FixedSingle'
$RightClickMenu.Add_MouseLeave({Handle-RMenuExit $This})
$RightClickMenu.Parent = $Form
$FindForm = ([N.e]::w([GUI.P],@(250,110,(($Form.Width - 250) / 2),(($Form.Height - 90) / 2))))
$FindForm.BorderStyle = 'FixedSingle'
$FindForm.Visible = $False
    $FRTitle = ([N.e]::w([GUI.L],@(300,18,25,7,'Find and Replace (RegEx):')))
    $FRTitle.Parent = $FindForm
    $FLabel = ([N.e]::w([GUI.L],@(20,20,4,28,'F:')))
    $FLabel.Parent = $FindForm
    $Finder = ([N.e]::w([GUI.RTB],@(200,20,25,25,'')))
    $Finder.AcceptsTab = $True
    $Finder.Parent = $FindForm
    $RLabel = ([N.e]::w([GUI.L],@(20,20,4,53,'R:')))
    $RLabel.Parent = $FindForm
    $Replacer = ([N.e]::w([GUI.RTB],@(200,20,25,50,'')))
    $Replacer.AcceptsTab = $True
    $Replacer.Parent = $FindForm
    $FRGO = ([N.e]::w([GUI.B],@(95,25,25,75,'Replace All')))
        $FRGO.Add_Click({
            Switch($TabControllerComm.SelectedTab.Text){
                'Commands'  {$Commands.Text     = ($Commands.Text -replace $Finder.Text.Replace('(NEWLINE)',$NL),$Replacer.Text)}
                'Functions' {$FunctionsBox.Text = ($FunctionsBox.Text -replace $Finder.Text.Replace('(NEWLINE)',$NL),$Replacer.Text)}
            }
        })
    $FRGO.Parent = $FindForm
    $FRClose = ([N.e]::w([GUI.B],@(95,25,130,75,'Close')))
        $FRClose.Add_Click({$This.Parent.Visible = $False})
    $FRClose.Parent = $FindForm
$FindForm.Parent = $Form
