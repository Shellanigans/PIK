If($Host.Name -match 'Console'){
    [Console]::Title = 'PIK'
    #[Void][GUI.Window]::ShowWindow([Cons.Wind]::GetConsoleWindow(), 0)
    [GUI.Style]::Enable()
}

If(!(Test-Path ($env:APPDATA+'\Macro'))){[Void](MKDIR ($env:APPDATA+'\Macro') -Force)}
If(!(Test-Path ($env:APPDATA+'\Macro\Profiles'))){[Void](MKDIR ($env:APPDATA+'\Macro\Profiles') -Force)}

$CommandLine = $False

$Tab = ([String][Char][Int]9)
$NL = [System.Environment]::NewLine

$Script:Refocus = $False

$Script:Inside_If = $False
$Script:IfElDepth = 0
$Script:IfElEval = $False
$Script:Inside_While = $False

$Script:WhileDepth = 0
$Script:WhileEval = $False

$Script:BufferedCommandsIfEl = ''
$Script:BufferedCommandsWhile = ''

$Script:LoadedProfile = $Null
$Script:Saved = $True
#$Script:Cons = $True
$UndoHash = @{KeyList=[String[]]@()}

$Script:VarsHash = @{}
$Script:FuncHash = @{}

$Script:HiddenWindows = @{}

$SyncHash = [HashTable]::Synchronized(@{Stop=$False;Kill=$False;Restart=$False;SrvPort=42069;SrvIP='0.0.0.0';ShowMouse=$False;MouseIndPid=0})

$ClickHelperParent = [HashTable]::Synchronized(@{})

$AutoChange = $False
$MutexPow = [Powershell]::Create()
$MutexRun = [RunspaceFactory]::CreateRunspace()
$MutexRun.ApartmentState = [System.Threading.ApartmentState]::STA
$MutexRun.Open()
$MutexPow.Runspace = $MutexRun
$MutexPow.AddScript({
    Param($SyncHash)
    Add-Type -Name KeyState -Namespace Keyboard -IgnoreWarnings -MemberDefinition '
    [DllImport("C:\\Windows\\System32\\user32.dll")]
    public static extern short GetAsyncKeyState(int KCode);
    '

    Add-Type -Name e -Namespace N -MemberDefinition '
    public static Object w (Type type, params Object[] args){
        return System.Activator.CreateInstance(type, args);
    }
    '
    $PHCMDS = '{CMDS_START}'+($NL*2)+'{SERVERSTOP}'+($NL*2)+'{CMDS_END}'
    $SSrv = [Text.Encoding]::UTF8.GetBytes($PHCMDS)
    While(!$SyncHash.Kill){
        [System.Threading.Thread]::Sleep(10)
	    Try{
            If([Keyboard.KeyState]::GetAsyncKeyState(145)){
                $SyncHash.Stop = $True
                $SyncHash.Restart = $False
                $IP = [String]$SyncHash.SrvIP
                If($IP -match '0\.0\.0\.0'){
                    $IP = '127.0.0.1'
                }
                $Port = [Int]$SyncHash.SrvPort
                $TmpCli = ([N.e]::w([System.Net.Sockets.TCPClient],@($IP,$Port)))
                
                $TmpStr = $TmpCli.GetStream()
                $TmpStr.Write($SSrv,0,$SSrv.Count)
                $TmpStr.Close()
                $TmpStr.Dispose()
                
                $TmpCli.Close()
                $TmpCli.Dispose()
                [System.Threading.Thread]::Sleep(500)
            }
        }Catch{}
    }
}) | Out-Null

$MutexPow.AddParameter('SyncHash', $SyncHash) | Out-Null
$MutexHandle = $MutexPow.BeginInvoke()
$MouseIndPow = [Powershell]::Create()
$MouseIndRun = [RunspaceFactory]::CreateRunspace()
$MouseIndRun.ApartmentState = [System.Threading.ApartmentState]::STA
$MouseIndRun.Open()
$MouseIndPow.Runspace = $MouseIndRun
$MouseIndPow.AddScript({
    Param($SyncHash)
    $SyncHash.MouseIndPid = $PID
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -Name e -Namespace N -MemberDefinition '
    public static Object w (Type type, params Object[] args){
        return System.Activator.CreateInstance(type, args);
    }
    '
    $MouseForm = [N.e]::w([System.Windows.Forms.Form],@())
    $MouseForm.Size = [N.e]::w([System.Drawing.Size],@(50,50))
    #$MouseForm.Text = 'Mouse Indicator'
    $Red = [System.Drawing.Color]::Red
    $DarkRed = [System.Drawing.Color]::DarkRed
    $Pointer = [N.e]::w([System.Windows.Forms.Label],@())
    $Pointer.Size = [N.e]::w([System.Drawing.Size],@(50,50))
    $Pointer.Location = [N.e]::w([System.Drawing.Size],@(-10,0))
    $Pointer.BackColor = $DarkRed
    $Pointer.ForeColor = $Red
    $Pointer.Font = [N.e]::w([System.Drawing.Font],@('Lucida Console',50,[System.Drawing.FontStyle]::Bold))
    $Pointer.Text = [Char][Int]8592
    $Pointer.Parent = $MouseForm
    $MouseForm.BackColor = $DarkRed
    $MouseForm.TransparencyKey = $DarkRed
    $MouseForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $MouseForm.TopMost = $True
    $MouseForm.Add_Closing({[system.Windows.Forms.Application]::Exit()})
    [System.Action[System.Windows.Forms.Form,HashTable]]$Act = {
        Param($F,$Sync)
        #$Activated = $False
        $PrevMouseShow = $False
        While(!$Sync.Kill){
            Try{
	        If($Sync.ShowMouse){
                If($Sync.ShowMouse -ne $PrevShowMouse){
                    $F.Show()
                    $F.Update()
			        #If(!$Activated){$F.Activate();$Activated = $True}
                }
                $Loc = [System.Windows.Forms.Cursor]::Position
                $Loc.X+=5
                $Loc.Y-=35
                $F.Location = $Loc
                $PrevMouseShow = $Sync.ShowMouse
            }Else{
                If($Sync.ShowMouse -ne $PrevShowMouse){
                    $F.Hide()
                }
            }
	    }Catch{}
            [System.Threading.Thread]::Sleep(10)
        }
        $F.Close()
	    $F.Dispose()
    }
    $MouseForm.Show()
    $MouseForm.Hide()
    $MouseFormHandle = $MouseForm.BeginInvoke($Act,$MouseForm,$SyncHash)
    $MouseAppContext = [N.e]::w([System.Windows.Forms.ApplicationContext],@())
    [System.Windows.Forms.Application]::Run($MouseAppContext)
}) | Out-Null
$MouseIndPow.AddParameter('SyncHash', $SyncHash) | Out-Null
$MouseIndHandle = $MouseIndPow.BeginInvoke()

#If($Host.Name -match 'Console'){Cls}

If(Test-Path ($env:APPDATA+'\Macro\LegacySendKeys.txt')){[GUI.Send]::SetConfig()}

$Config = ('' | Select `
    @{NAME='DelayTimeVal';EXPRESSION={0}},`
    @{NAME='DelayChecked';EXPRESSION={$False}},`
    @{NAME='DelayRandVal';EXPRESSION={0}},`
    @{NAME='CommTimeVal';EXPRESSION={0}},`
    @{NAME='CommChecked';EXPRESSION={$False}},`
    @{NAME='CommRandVal';EXPRESSION={0}},`
    @{NAME='ShowConsCheck';EXPRESSION={$False}},`
    @{NAME='OnTopCheck';EXPRESSION={$False}},`
    @{NAME='PrevProfile';EXPRESSION={$Null}},`
    @{NAME='LastLoc';EXPRESSION={$Null}},`
    @{NAME='Bolded';EXPRESSION={$False}},`
    @{NAME='ShowMousePos';EXPRESSION={$False}},`
    @{NAME='SavedSize';EXPRESSION={$Null}}
)
Try{
    Try{
        $LoadedConfig = (Get-Content -RAW ($env:APPDATA+'\Macro\_Config_.json') -ErrorAction Stop | ConvertFrom-JSON)
    }Catch{
        $LoadedConfig = (Get-Content -Raw ($env:APPDATA+'\Macro\_Config_.csv') -ErrorAction Stop | ConvertFrom-CSV)
    }
    $DelayTimer.Value        = $LoadedConfig.DelayTimeVal
    $DelayCheck.Checked      = $(If([String]$LoadedConfig.DelayChecked -eq 'False')  {$False}Else{[Boolean]$LoadedConfig.DelayChecked})
    $DelayRandTimer.Value    = $LoadedConfig.DelayRandVal
    $CommandDelayTimer.Value = $LoadedConfig.CommTimeVal
    $CommDelayCheck.Checked  = $(If([String]$LoadedConfig.CommChecked -eq 'False')   {$False}Else{[Boolean]$LoadedConfig.CommChecked})
    $CommRandTimer.Value     = $LoadedConfig.CommRandVal
    $ShowCons.Checked        = $(If([String]$LoadedConfig.ShowConsCheck -eq 'False') {$False}Else{[Boolean]$LoadedConfig.ShowConsCheck})
    #$Script:Cons             = $ShowCons.Checked
    $OnTop.Checked           = $(If([String]$LoadedConfig.OnTopCheck -eq 'False')    {$False}Else{[Boolean]$LoadedConfig.OnTopCheck})
    $Bold.Checked            = $(If([String]$LoadedConfig.Bolded -eq 'False')        {$False}Else{[Boolean]$LoadedConfig.Bolded})
    $MousePosCheck.Checked   = $(If([String]$LoadedConfig.ShowMousePos -eq 'False')  {$False}Else{[Boolean]$LoadedConfig.ShowMousePos})
    $ShowCons.Checked = !$ShowCons.Checked
    Sleep -Milliseconds 40
    $ShowCons.Checked = !$ShowCons.Checked
    $OnTop.Checked = !$OnTop.Checked
    Sleep -Milliseconds 40
    $OnTop.Checked = !$OnTop.Checked
    If($Bold.Checked){
        $Form.Controls | %{$_.Font = [N.e]::w([System.Drawing.Font],@('Lucida Console',9,[System.Drawing.FontStyle]::Bold))}
    }Else{
	    $Form.Controls | %{$_.Font = [N.e]::w([System.Drawing.Font],@('Lucida Console',9,[System.Drawing.FontStyle]::Regular))}
    }
    $MousePosCheck.Checked = $False
    #Something fucky is going on here, when the form starts with this property set, there's like a three second pause and a copy of the indicator gets like "stamped" onto the screen. This doesn't happen if the form is made visible AFTER the parent form though
    $MousePosCheck.Checked = $LoadedConfig.ShowMousePos
    $SyncHash.ShowMouse = $False
    $SyncHash.ShowMouse = $MousePosCheck.Checked
    If($LoadedConfig.PrevProfile -OR $Macro -OR $CLICMD){
        If($Macro){
            If(Test-Path ($env:APPDATA+'\Macro\Profiles\'+$Macro)){
                $Profile.Text = ('Working Profile: ' + $Macro)
                $Form.Text = ('PIK - ' + $Macro)
                $SavedProfiles.SelectedIndex = $SavedProfiles.Items.IndexOf($Macro)
            }Else{
                [System.Console]::WriteLine('No macro by that name!')
            }
            $CommandLine = $True
        }ElseIf($CLICMD){
            $CommandLine = $True
        }Else{
            If(Test-Path ($env:APPDATA+'\Macro\Profiles\'+$LoadedConfig.PrevProfile+'\'+$LoadedConfig.PrevProfile+'.pik')){
                $Profile.Text = ('Working Profile: ' + $LoadedConfig.PrevProfile)
                $Form.Text = ('PIK - ' + $LoadedConfig.PrevProfile)
                $Script:LoadedProfile = $LoadedConfig.PrevProfile
                $SavedProfiles.SelectedIndex = $SavedProfiles.Items.IndexOf($LoadedConfig.PrevProfile)
                $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem+'\')
                #$Commands.Text = ((Get-Content ($TempDir+'\Commands.txt')).Split($NL) -join $NL).TrimEnd($NL)
                #$FunctionsBox.Text = ((Get-Content ($TempDir+'\Functions.txt')).Split($NL) -join $NL).TrimEnd($NL)
                $Commands.Text = Try{
                    ((Get-Content ($TempDir+$SavedProfiles.SelectedItem+'.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Commands | Out-String).TrimEnd($NL)# -join $NL
                }Catch{
                    Try{
                        ((Get-Content ($TempDir+$SavedProfiles.SelectedItem+'.pik') -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Commands | Out-String).TrimEnd($NL)# -join $NL
                    }Catch{
                        ''
                    }
                }
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
    }
    If($LoadedConfig.LastLoc){
        $Form.StartPosition = 'Manual'
        $Form.Location = [GUI.SP]::PO($LoadedConfig.LastLoc.Split(',')[0],$LoadedConfig.LastLoc.Split(',')[1])
    }
    If($LoadedConfig.SavedSize){
        $Form.Size = [GUI.SP]::SI($LoadedConfig.SavedSize.Split(',')[0],$LoadedConfig.SavedSize.Split(',')[1])
    }
}Catch{
    [System.Console]::WriteLine('NO CONFIG FILE FOUND, OR FILE COULD NOT BE LOADED!'+$NL)
}
If($CommandLine){
    If($CLICMD -AND !$Macro){
        GO -InlineCommand $CLICMD
    }ElseIf($Macro -AND !$CLICMD){
        GO
    }Else{
        [System.Console]::WriteLine('INVALID ARGS!')
    }
}Else{
    $Form.Show()
    $TabController.SelectedTab.GetChildAtPoint([GUI.SP]::PO(0,0)).SelectedIndex = 0
    $TempTextBox = $TabController.SelectedTab.GetChildAtPoint([GUI.SP]::PO(0,0)).SelectedTab.GetChildAtPoint([GUI.SP]::PO(0,0))
    [Void]$TempTextBox.Focus()
    $TempTextBox.SelectionStart = $TempTextBox.Text.Length   
    $Form.Add_Closing({
        $Config.ShowConsCheck = $ShowCons.Checked
        $Config.OnTopCheck    = $OnTop.Checked
        If($Script:LoadedProfile -ne $Null){
            $Config.PrevProfile = $Script:LoadedProfile
            
            $TempName = [DateTime]::Now.ToFileTimeUtc().ToString()
            If(!$Script:Saved){
                $result = [System.Windows.Forms.MessageBox]::Show('Save before exiting?' , "Info" , 4)
                If($result -eq 'Yes'){
                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')
                    [Void](MKDIR $TempDir -ErrorAction SilentlyContinue)
                    $Script:Saved = $True
                    Try{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 10000 -Force
                    }
                }
            }
        }Else{
            $Config.PrevProfile = $Null
        }
	    $Config.DelayTimeVal  = $DelayTimer.Value
	    $Config.DelayChecked  = $DelayCheck.Checked
	    $Config.DelayRandVal  = $DelayRandTimer.Value
	    $Config.CommTimeVal   = $CommandDelayTimer.Value
	    $Config.CommChecked   = $CommDelayCheck.Checked
	    $Config.CommRandVal   = $CommRandTimer.Value
	
	    $Config.Bolded        = $Bold.Checked
        $Config.ShowMousePos  = $MousePosCheck.Checked

        If($this.WindowState.ToString() -eq 'Normal'){
            $Config.LastLoc   = ([String]$Form.Location.X + ',' + [String]$Form.Location.Y)
            $Config.SavedSize = ([String]$Form.Size.Width + ',' + [String]$Form.Size.Height)
        }Else{
            $Config.LastLoc   = $LoadedConfig.LastLoc
            $Config.SavedSize = $LoadedConfig.SavedSize
        }
        Try{
            $Config | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\_Config_.json') -Width 10000 -Force
        }Catch{
            Try{
                $Config | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\_Config_.csv') -Width 10000 -Force
            }Catch{
                [System.Console]::WriteLine('COULD NOT SAVE CONFIG FILE!')
                [System.Threading.Thread]::Sleep(3000)
            }
        }
	
	[System.Windows.Forms.Application]::Exit()
    })
    #$Form.Show()
    $Form.Activate()
    
    $AppContext = ([N.e]::w([System.Windows.Forms.ApplicationContext],@()))
    [System.Windows.Forms.Application]::Run($AppContext)
}

$UndoHash.KeyList | %{
    If($_ -notmatch 'MOUSE'){
        [GUI.Events]::keybd_event(([String]$_), 0, '&H2', 0)
    }Else{
        [GUI.Events]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
    }
}

$SyncHash.Kill = $True

$MutexPow.EndInvoke($MutexHandle)
$MutexRun.Close()
$MutexPow.Dispose()

$MouseIndPow.EndInvoke($MouseIndHandle)
$MouseIndRun.Close()
$MouseIndPow.Dispose()

[Void][GUI.Window]::ShowWindow([Cons.Wind]::GetConsoleWindow(), 1)

#If($Host.Name -match 'Console'){Exit}
