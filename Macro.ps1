Function GUI
{
    Param
    (
        [Switch]$L,[Switch]$TB,[Switch]$B,[Switch]$C,[Int]$SX,[Int]$SY,[Int]$LX,[Int]$LY,[String]$TE
    )

    If(@([AppDomain]::CurrentDomain.GetAssemblies() | Select FullName | ?{($_ -match 'System.Drawing') -OR ($_ -match 'System.Windows.Forms')}).Count -lt 2)
    {
        [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
        [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

        [Void] [System.Windows.Forms.Application]::EnableVisualStyles()
    }

    If($L)
    {
        $Temp = New-Object System.Windows.Forms.Label
    }
    ElseIf($TB)
    {
        $Temp = New-Object System.Windows.Forms.TextBox

        $Temp.Multiline = $True
        
        If(($Temp | Get-Member | ?{($_.Name -eq 'TexCh')}).Count -lt 1)
        {
            [Void] ($Temp | Add-Member -PassThru -MemberType ScriptMethod -Name 'TexCh' -Value {Param($Add) $This.Add_TextChanged($Add)} -Force)
        }
    }
    ElseIf($B)
    {
        $Temp = New-Object System.Windows.Forms.Button

        If(($Temp | Get-Member | ?{($_.Name -eq 'Cl')}).Count -lt 1)
        {
            [Void] ($Temp | Add-Member -PassThru -MemberType ScriptMethod -Name 'Cl' -Value {Param($Add) $This.Add_Click($Add)} -Force)
        }
    }
    ElseIf($C)
    {
        $Temp = New-Object System.Windows.Forms.CheckBox
    }
    Else
    {
        $Temp = New-Object System.Windows.Forms.Form

        If(($Temp | Get-Member | ?{($_.Name -eq 'Start')}).Count -lt 1)
        {
            [Void] ($Temp | Add-Member -PassThru -MemberType ScriptMethod -Name 'Start' -Value {[Void] $This.ShowDialog()} -Force)
        }

        $F = $True
    }

    If($F)
    {
        If(($Temp | Get-Member | ?{($_.Name -eq 'InsArr')}).Count -lt 1)
        {
            [Void] ($Temp | Add-Member -PassThru -MemberType ScriptMethod -Name 'InsArr' -Value {Param($Add) [Void] ($Add | %{$This.Controls.Add($_)})} -Force)
        }
    }

    $Temp.Font = New-Object System.Drawing.Font('Lucida Console',8.25,[System.Drawing.FontStyle]::Regular)
    
    $Temp.Location = New-Object System.Drawing.Size($LX,$LY)
    $Temp.Size = New-Object System.Drawing.Size($SX,$SY)
    
    If($TE)
    {
        $Temp.Text = $TE
    }

    Return $Temp
}

Function NL
{
    Param($X)

    Return $(If($X){(1..([Math]::Abs([Int]$X)) | %{[Environment]::NewLine}) -join ''}Else{[Environment]::NewLine})
}

If(!(Test-Path ($env:APPDATA+'\Macro')))
{
    MKDIR ($env:APPDATA+'\Macro') -Force
}

If(!(Test-Path ($env:APPDATA+'\Macro\Functs')))
{
    MKDIR ($env:APPDATA+'\Macro\Functs') -Force
}

If(Test-Path ($env:APPDATA+'\Macro\Undo.txt'))
{
    Del ($env:APPDATA+'\Macro\Undo.txt') -Force
}

If(Test-Path ($env:APPDATA+'\Macro\Stop.txt'))
{
    Del ($env:APPDATA+'\Macro\Stop.txt') -Force
}

Try
{
    Add-Type -Name Window -NameSpace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '

    $Hide = [Console.Window]::GetConsoleWindow()
    [Void][Console.Window]::ShowWindow($Hide, 0)
}Catch{}

[void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

Add-Type -NameSpace KeyBD -Name Event -MemberDefinition '
    [DllImport("user32.dll")]
    public static extern void keybd_event(Byte bVk, Byte bScan, Int64 dwFlags, Int64 dwExtraInfo);
'

Add-Type -NameSpace Mouse -Name Event -MemberDefinition '
    [DllImport("user32.dll")]
    public static extern void mouse_event(Int64 dwFlags, Int64 dx, Int64 dy, Int64 cButtons, Int64 dwExtraInfo);
'

Function Note
{
    $NoteScript = {
. ($env:APPDATA+'\Macro\PseudoProf.ps1')

$NoteForm = (GUI -SX 600 -SY 605 -TE 'Functions')
$NoteForm.MinimumSize = New-Object System.Drawing.Size(600,605)

$TextBox = (GUI -TB -SX 535 -SY 510 -LX 25 -LY 25)
$TextBox.Scrollbars = 'Vertical'
$TextBox.TexCh({$This.Text | Out-File ($env:APPDATA+'\Macro\Notes.txt') -Width 1000 -Force})

Try{$TextBox.Text = (Get-Content ($env:APPDATA+'\Macro\Notes.txt') -ErrorAction Stop) -join (NL)}Catch{}

$OK = (GUI -B -SX 50 -SY 23 -LX 275 -LY 540 -TE "OK")
$OK.Cl({$NoteForm.Close()})

$TextBox.TabIndex = 0
$OK.TabIndex = 1
#$HeaderLabel.TabIndex = 2
#$HeaderBox.TabIndex = 3
#$NoteForm.TabIndex = 4

$NoteForm.InsArr(@($TextBox,$OK))

$NoteForm.Add_SizeChanged({
    #$HeaderBox.Size = New-Object System.Drawing.Size((([Int]$This.Width)-65),(([Int]$This.Height)*0.314))
    $TextBox.Size = New-Object System.Drawing.Size((([Int]$This.Width)-65),(([Int]$This.Height)-([Int]$HeaderBox.Height)-105))
    #$TextBox.Location = New-Object System.Drawing.Size(25,(([Int]$HeaderBox.Height)+35))
    $OK.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-25),(([Int]$This.Height)-65))
})

$NoteForm.Start()
}
    $NoteScript | Out-File ($env:APPDATA+'\Macro\MacroNotes.ps1') -Width 1000 -Force

    If((Get-Job -Name 'Notes' | ?{$_.State -match 'Running'}).Count -le 0)
    {
        Start-Job -FilePath ($env:APPDATA+'\Macro\MacroNotes.ps1') -Name 'Notes'
    }
}

Function ActiveKeys
{
    Param([String]$X)
    
    If(($X -match 'NUM') -AND ($X.Length -eq 4))
    {
        Return [String]('&H6'+($X -replace 'Num'))
    }
    ElseIf($X.Length -eq 1)
    {
        Return [String]([Convert]::ToInt32([Char]$X))
    }
    ElseIf($X -like 'F*')
    {
        Return [String]('&H7'+('{0:x}' -f ([Int]($X -replace 'F') - 1)))
    }
    Else
    {
        Switch($X)
        {
            'CANCEL'{Return '&H03'}
            'BACKSPACE'{Return '&H08'}
            'TAB'{Return '&H09'}
            'CLEAR'{Return '&HC'}
            'ENTER'{Return '&HD'}
            'SHIFT'{Return '&H10'}
            'CTRL'{Return '&H11'}
            'ALT'{Return '&H12'}
            'PAUSE'{Return '&H13'}
            'CAPSLOCK'{Return '&H14'}
            'ESC'{Return '&H1B'}
            'SPACEBAR'{Return '&H20'}
            'PAGEUP'{Return '&H21'}
            'PAGEDOWN'{Return '&H22'}
            'END'{Return '&H23'}
            'HOME'{Return '&H24'}
            'LEFTARROW'{Return '&H25'}
            'UPARROW'{Return '&H26'}
            'RIGHTARROW'{Return '&H27'}
            'DOWNARROW'{Return '&H28'}
            'SELECT'{Return '&H29'}
            'EXECUTE'{Return '&H2B'}
            'PRINTSCREEN'{Return '&H2C'}
            'INS'{Return '&H2D'}
            'DEL'{Return '&H2E'}
            'HELP'{Return '&H2F'}
            'NUMLOCK'{Return '&H90'}
            'NUMMULT'{Return '&H6A'}
            'NUMPLUS'{Return '&H6B'}
            'NUMENTER'{Return '&H6C'}
            'NUMMINUS'{Return '&H6D'}
            'NUMPOINT'{Return '&H6E'}
            'NUMDIV'{Return '&H6F'}
            'WINDOWS'{Return '&H5B'}
        }
    }
}

Function Interact
{
    Param([String]$X)

    Write-Host $X

    If(!(Test-Path ($env:APPDATA+'\Macro\Stop.txt')))
    {
        $X = ($X -replace '{COPY}','^c')
        $X = ($X -replace '{PASTE}','^v')
        $X = ($X -replace '{SELECTALL}','^a')

        While($X -match '{RAND ')
        {
            $X.Split('{}') | ?{$_ -match 'RAND ' -AND $_ -match ','} | %{'{'+$_+'}'} | %{$X = $X -replace $_,(Get-Random -Minimum $_.Split(' ')[1].Split(',')[0] -Maximum ($_.Split(' ')[1].Split(',')[1] -replace '}'))}
            Write-Host $X
        }

        If($X -match '{FOCUS')
        {
            $([Void] [Microsoft.VisualBasic.Interaction]::AppActivate($X -replace '{FOCUS ' -replace '}')) 2> $Null
        }
        ElseIf($X -match '{WAIT')
        {
            $X -replace '{WAIT ' -replace '}' | %{If($_ -ne '{WAIT'){If($_ -match 'M'){[Int]($_ -replace 'M ')}Else{[Int]($_)*1000}}Else{1000}} | %{Sleep -Milliseconds $_}
        }
        ElseIf($X -match '{[/\\]?HOLD')
        {
            $Rel = ($X -match '[/\\]')

            If($X -match 'MOUSE')
            {
                [Int]($X.Split()[-1] -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{[Mouse.Event]::mouse_event(($(If($Rel){$_*2}Else{$_})), 0, 0, 0, 0)}
            }
            Else
            {
                $Temp = (ActiveKeys ($X.Split()[-1] -replace '}'))
                ([String]$Temp) >> ($env:APPDATA+'\Macro\Undo.txt')
                [KeyBD.Event]::keybd_event($Temp, 0, $(If($Rel){'&H2'}Else{0}), 0)
            }
        }
        ElseIf($X -match '^{[LRM]?MOUSE')
        {
            If($X -match ',')
            {
                [Windows.Forms.Cursor]::Position = [String]($X -replace '{MOUSE ' -replace '}')
            }
            ElseIf($X -match ' ')
            {
                0..([Int](($X -replace '}').Split(' ')[-1])) | %{[Int]($X.Split(' ')[0] -replace '{' -replace 'MOUSE' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{[Mouse.Event]::mouse_event($_, 0, 0, 0, 0)}}
            }
            Else
            {
                [Int]($X -replace '{' -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{[Mouse.Event]::mouse_event($_, 0, 0, 0, 0)}
            }
        }
        ElseIf((ls ($env:APPDATA+'\Macro\Functs')) -AND (ls ($env:APPDATA+'\Macro\Functs') | %{$_.Name -replace '.txt'}).Contains(@($X.Split('{ }') | ?{$_ -ne ''})[0]))
        {
            $(If($X -match ' '){1..([Int]($X.Split()[-1] -replace '\D'))}Else{1}) | %{Get-Content ($env:APPDATA+'\Macro\Functs\'+@($X.Split('{ }') | ?{$_ -ne ''})[0]+'.txt' | ?{$_ -ne ''}) | %{Interact $_}}
        }
        Else
        {
            [System.Windows.Forms.SendKeys]::SendWait($X)
        }
    }
}

$Form = (GUI -SX 365 -SY 485 -TE 'Macro Builder 3: Electric Avenue')
$Form.MinimumSize = New-Object System.Drawing.Size(357,485)

$CommandsLabel = (GUI -L -SX 100 -SY 20 -LX 25 -LY 15 -TE 'Key Strokes:')

$GetMouseCoords = (GUI -B -SX 125 -SY 20 -LX 200 -LY 11 -TE 'Get Mouse X,Y')
$GetMouseCoords.Cl({
    Sleep 3
    
    $Mouse = [String]([Windows.Forms.Cursor]::Position | %{($_.X,$_.Y) -join ','})

    [Windows.Forms.ClipBoard]::SetText('{MOUSE '+$Mouse+'}')
    
    [Windows.Forms.MessageBox]::Show([String]$Mouse, 'X & Y Coords', [Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information, [System.Windows.Forms.MessageBoxDefaultButton]::Button1) | Out-Null
})

$Commands = (GUI -TB -SX 300 -SY 345 -LX 25 -LY 35)
$Commands.ScrollBars = 'Vertical'
$Commands.TexCh({$This.Text | Out-File ($env:APPDATA+'\Macro\PrevCmds.txt') -Width 1000 -Force})

Try{$Commands.Text = (Get-Content ($env:APPDATA+'\Macro\PrevCmds.txt') -ErrorAction Stop) -join (NL)}Catch{}

$GO = (GUI -B -SX 100 -SY 50 -LX 25 -LY 390 -TE 'GO')
$GO.Cl({
    Start-Job -ScriptBlock {
    Try
    {
        Add-Type -Name Win32 -Namespace API -MemberDefinition '
        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int virtualKeyCode);
        '
    }Catch{}

    While(!(Test-Path ($env:APPDATA+'\Macro\Stop.txt')))
    {
        Sleep -Milliseconds 100
        If([API.Win32]::GetAsyncKeyState(145))
        {
            '' >> ($env:APPDATA+'\Macro\Stop.txt')
        }
    }
}

#$PrevIt = [Int]($Iteration.Text)

$Form.Controls.Remove($GO)
$Form.Controls.Remove($Notes)
#$Form.Controls.Remove($Loop)
$Form.Controls.Remove($GetMouseCoords)

$Commands.ReadOnly = $True
#$Iteration.ReadOnly = $True

$Form.Refresh()

GCI ($env:APPDATA+'\Macro\Functs\') | Del -Force

$Functions = $False
$FunctionStart = $False

$FunctionText = @()

(Get-Content ($env:APPDATA+'\Macro\Notes.txt')) | %{If($Functions){$_}; If($_ -match '{FUNCTIONS}'){$Functions = $True}} | %{
    If($_ -match '{FUNCTION NAME ')
    {
        $FunctionStart = $True
    }
    If($_ -match '{FUNCTION END}')
    {
        $FunctionStart = $False
        ($FunctionText -join (NL)) | Out-File ($env:APPDATA+'\Macro\Functs\'+[String]$Name+'.txt') -Encoding UTF8
        $FunctionText = @()
    }

    If($FunctionStart)
    {
        If($_ -match '{FUNCTION NAME ')
        {
            $Name = [String]($_ -replace '{FUNCTION NAME ' -replace '}')
        }
        Else
        {
            $FunctionText+=$_
        }
    }
}

Do
{
    $Commands.Text.Split((NL)) | ?{$_ -ne ''} | %{
        
        If(!(Test-Path ($env:APPDATA+'\Macro\Stop.txt')))
        {
            Interact $_
        }
    }

    <#If($Loop.Checked)
    {
        $Iteration.Text = ([Int]($Iteration.Text) - 1)
        $Form.Refresh()
    }#>
}While($Loop.Checked -AND !(Test-Path ($env:APPDATA+'\Macro\Stop.txt'))<# -AND ([Int]($Iteration.Text) -gt 0)#>)

$Form.InsArr(@($GO,$Notes,<#$Loop,#>$GetMouseCoords))
    
$Commands.ReadOnly = $False
#$Iteration.ReadOnly = $False

Try{Del ($env:APPDATA+'\Macro\Stop.txt') -ErrorAction Stop -Force}Catch{}

Get-Job | ?{$_.Name -notmatch 'Notes'} | Stop-Job
Get-Job | ?{$_.Status -notmatch 'Running'} | Remove-Job

#$Iteration.Text = $PrevIt

$Form.Refresh()
})

#$Loop = (GUI -C -SX 50 -SY 15 -LX 131 -LY 392 -TE 'Loop')

#$IterationLabel = (GUI -L -SX 95 -SY 12 -LX 129 -LY 407 -TE 'No. of Loops')
#$Iteration = (GUI -TB -SX 85 -SY 20 -LX 130 -LY 420)
#$Iteration.Text = '10'
#$Iteration.Add_TextChanged({$This.Text = $This.Text -replace '\D'})

$Notes = (GUI -B -SX 100 -SY 50 -LX 225 -LY 390 -TE 'Notes')
$Notes.Cl({Note})

$Form.InsArr(@($CommandsLabel,$GetMouseCoords,$Commands,$GO,<#$Loop,$IterationLabel,$Iteration,#>$Notes))

$Form.Add_SizeChanged({
    $GetMouseCoords.Location = New-Object System.Drawing.Size((([Int]$This.Width)-157),11)
    $Commands.Size = New-Object System.Drawing.Size((([Int]$This.Width)-57),(([Int]$This.Height)-140))
    $GO.Location = New-Object System.Drawing.Size(25,(([Int]$This.Height)-95))
    #$Loop.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-47.5),(([Int]$This.Height)-93))
    #$IterationLabel.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-49.5),(([Int]$This.Height)-78))
    #$Iteration.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-48.5),(([Int]$This.Height)-65))
    $Notes.Location = New-Object System.Drawing.Size((([Int]$This.Width)-132),(([Int]$This.Height)-95))
})

$Form.Start()

@(Try{Get-Content ($env:APPDATA+'\Macro\Undo.txt') -ErrorAction Stop}Catch{Break}) | %{[KeyBD.Event]::keybd_event(([String]$_), 0, '&H2', 0)}
Del ($env:APPDATA+'\Macro\Undo.txt') -Force
