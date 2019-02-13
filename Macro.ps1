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

$NoteForm = (GUI -SX 600 -SY 605 -TE 'Notes')
$NoteForm.MinimumSize = New-Object System.Drawing.Size(600,605)

$HeaderLabel = (GUI -L -SX 535 -SY 17 -LX 25 -LY 7 -TE 'Useful Info:')

$HeaderBox = (GUI -TB -SX 535 -SY 190 -LX 25 -LY 25)
$HeaderBox.ScrollBars = 'Vertical'
$HeaderBox.ReadOnly = $True

$Header=('The purpose of this program is to simulate keystrokes and ')
$Header+=('mouse input to the windows operating system.'+(NL 2))
$Header+=('Each key is represented by one or more characters. To specify a single ')
$Header+=('keyboard character, use the character itself. For example, to represent ')
$Header+=('the letter A, pass in the string "A" to the method. To represent more ')
$Header+=('than one character, append each additional character to the one ')
$Header+=('preceding it. To represent the letters A, B, and C, specify the ')
$Header+=('parameter as "ABC".'+(NL 2))
$Header+=('The plus sign (+), caret (^), percent sign (%), tilde (~), and ')
$Header+=('parentheses () have special meanings. To specify one of these characters, ')
$Header+=('enclose it within braces ({}). For example, to specify the plus sign, use ')
$Header+=('"{+}". To specify brace characters, use "{{}" and "{}}". Brackets ([ ]) ')
$Header+=('have no special meaning to SendKeys, but you must enclose them in braces. '+(NL 2))
$Header+=('The following are other special keys you can specify:'+(NL 2))
$Header+=('BACKSPACE        {BACKSPACE}, {BS}, or {BKSP}'+(NL))
$Header+=('BREAK            {BREAK}'+(NL))
$Header+=('CAPS LOCK        {CAPSLOCK}'+(NL))
$Header+=('DEL or DELETE    {DELETE} or {DEL}'+(NL))
$Header+=('END              {END}'+(NL))
$Header+=('ENTER            {ENTER} or ~'+(NL))
$Header+=('ESC              {ESC}'+(NL))
$Header+=('HELP             {HELP}'+(NL))
$Header+=('HOME             {HOME}'+(NL))
$Header+=('INS or INSERT    {INSERT} or {INS}'+(NL))
$Header+=('PAGE DOWN        {PGDN}'+(NL))
$Header+=('PAGE UP          {PGUP}'+(NL))
$Header+=('NUM LOCK         {NUMLOCK}'+(NL))
$Header+=('TAB              {TAB}'+(NL))
$Header+=('UP ARROW         {UP}'+(NL))
$Header+=('DOWN ARROW       {DOWN}'+(NL))
$Header+=('RIGHT ARROW      {RIGHT}'+(NL))
$Header+=('LEFT ARROW       {LEFT}'+(NL))
$Header+=('F#               {F#} (Can be from 1 - 16)'+(NL))
$Header+=('Keypad add       {ADD}'+(NL))
$Header+=('Keypad subtract  {SUBTRACT}'+(NL))
$Header+=('Keypad multiply  {MULTIPLY}'+(NL))
$Header+=('Keypad divide    {DIVIDE}'+(NL 2))
$Header+=('SCROLL LOCK is reserved for cancelling the macros. Simply press and hold ')
$Header+=('until the macro stops on its own.'+(NL 2))
$Header+=('To specify keys combined with any combination of the SHIFT, CTRL, and ')
$Header+=('ALT keys, precede the key code with one or more of the following codes.'+(NL 2))
$Header+=('SHIFT (+)'+(NL))
$Header+=('CTRL  (^)'+(NL))
$Header+=('ALT   (%)'+(NL 2))
$Header+=('To specify that any combination of SHIFT, CTRL, and ALT should be held ')
$Header+=('down while several other keys are pressed, enclose the code for those ')
$Header+=('keys in parentheses. For example, to specify to hold down SHIFT while E ')
$Header+=('and C are pressed, use "+(EC)". To specify to hold down SHIFT while E is ')
$Header+=('pressed, followed by C without SHIFT, use "+EC".'+(NL 2))
$Header+=('To specify repeating keys, use the form {key number}. You must put a ')
$Header+=('space between key and number. For example, {LEFT 42} means press the LEFT ')
$Header+=('ARROW key 42 times; {h 10} means press H 10 times.'+(NL 2))
$Header+=('Do nothing {WAIT} (Nullifies entire line. I.e. putting {WAIT} anywhere on ')
$Header+=('a line turns that line into a delay with a default value of one second. ')
$Header+=('More time can be specified like the others. So {WAIT 5} is a 5 second ')
$Header+=('delay and {WAIT M 300} is a 300 millisecond delay)'+(NL 2))
$Header+=('You can also specify that you want to focus on the specified window by ')
$Header+=('using {FOCUS APPLICATION TITLE} on its own line. (e.g. {FOCUS Untitled - ')
$Header+=('Notepad})'+(NL 2))
$Header+=('You can specify mouse locations for the cursor by putting {MOUSE 10,10} ')
$Header+=('(The numbers are in pixels with 0,0 being the top left) and clicking with ')
$Header+=('{LMOUSE}, {RMOUSE}, or {MMOUSE}. This will do left, right, and middle ')
$Header+=('click respectively. You must place all mouse functions on independent ')
$Header+=('lines.'+(NL 2))
$Header+=('If you need to figure out the X and Y coordinates of your cursor at a ')
$Header+=('specific position, you can click "Get Mouse X,Y" and you will be given 3 ')
$Header+=('seconds to place your cursor where you would like it and you will get a ')
$Header+=('notification of the coordinates of your cursor at that position. The ')
$Header+=('command to place the mouse at the specified coords will be copied to your ')
$Header+=('clipboard for you to simply paste into the main window.'+(NL 2))
$Header+=('You may also specify to HOLD certain keys or mouse clicks down using ')
$Header+=('{HOLD KEY} remember to replace "KEY" with the actual key or mouse button ')
$Header+=('you want from the specified keys below. You must specify when to let go ')
$Header+=('using {/HOLD KEY} or {\HOLD KEY}. This will ensure that the key is not ')
$Header+=('continuously held down. As with LOOP, WAIT, FOCUS, and MOUSE functions, ')
$Header+=('the HOLD function requires a dedicated line in the keystrokes. Your ')
$Header+=('possible options for this function are as follows:'+(NL 2))
$Header+=('LMOUSE             RMOUSE             MMOUSE             CANCEL'+(NL))
$Header+=('BACKSPACE          TAB                CLEAR              ENTER'+(NL))
$Header+=('SHIFT              CTRL               ALT                PAUSE'+(NL))
$Header+=('CAPSLOCK           ESC                SPACEBAR           PAGEUP'+(NL))
$Header+=('PAGEDOWN           END                HOME               LEFTARROW'+(NL))
$Header+=('UPARROW            RIGHTARROW         DOWNARROW          SELECT'+(NL))
$Header+=('EXECUTE            PRINTSCREEN        INS                DEL'+(NL))
$Header+=('HELP               NUMLOCK            NUM# (0-9)         NUMMULT'+(NL))
$Header+=('NUMPLUS            NUMENTER           NUMMINUS           NUMPOINT'+(NL))
$Header+=('NUMDIV             All letters        All numbers        F(1-16)'+(NL 2))
$Header+=('You can loop the entire thing by checking the "Loop" checkbox. Then ')
$Header+=('specifying the number of time you want the program to run through ')
$Header+=('completely. (The default is 10)'+(NL 2))
$Header+=('If you want to get really fancy then you can actually create shorthand ')
$Header+=('for yourself to repeate specific parts multiple times. In the "Notes" ')
$Header+=('window add a line {FUNCTIONS} below all of your notes. Then create a ')
$Header+=('functions by starting a line below that with {FUNCTION NAME THING} like ')
$Header+=('so:'+(NL 2))
$Header+=('{FUNCTIONS}'+(NL))
$Header+=('{FUNCTION NAME THING}'+(NL 2))
$Header+=('Then type out the keystrokes just like you would in the main window and ')
$Header+=('end it with {FUNCTION END}. This allows you to specify the function in ')
$Header+=('the main window as {THING}. Just make sure to call each function on their ')
$Header+=('own line. You can specify multiple functions and you can even nest them ')
$Header+=('together. A complete example would look like this:'+(NL 2))
$Header+=('{FUNCTIONS}'+(NL))
$Header+=('{FUNCTION NAME THING1}'+(NL))
$Header+=('Thing 1{ENTER}'+(NL))
$Header+=('{FUNCTION END}'+(NL 2))
$Header+=('{FUNCTION NAME THING2}'+(NL))
$Header+=('Thing 2{ENTER}'+(NL))
$Header+=('{FUNCTION END}'+(NL 2))
$Header+=('{FUNCTION NAME THING3}'+(NL))
$Header+=('Thing 3{ENTER}'+(NL))
$Header+=('{FUNCTION END}'+(NL 2))
$Header+=('The above would allow you to type into the main window the following:'+(NL 2))
$Header+=('{THING1}'+(NL))
$Header+=('{THING2}'+(NL))
$Header+=('{THING3}'+(NL 2))
$Header+=('Which gets interpreted as:'+(NL 2))
$Header+=('Thing 1{ENTER}'+(NL))
$Header+=('Thing 2{ENTER}'+(NL))
$Header+=('Thing 3{ENTER}'+(NL 2))
$Header+=('Which would give the output:'+(NL 2))
$Header+=('Thing 1'+(NL))
$Header+=('Thing 2'+(NL))
$Header+=('Thing 3'+(NL 2))
$Header+=('(Without the {ENTER}s they would all be on the same line)'+(NL 2))
$Header+=('You can even specify number like with the other functions like so:'+(NL 2))
$Header+=('{THING 5}'+(NL 2))
$Header+=('FINAL NOTE: It is probably NOT a good idea to use the macro to enter data ')
$Header+=('into the notes. This causes some stability issues.')

$HeaderBox.Text = $Header

$TextBox = (GUI -TB -SX 535 -SY 310 -LX 25 -LY 225)
$TextBox.Scrollbars = 'Vertical'
$TextBox.TexCh({$This.Text | Out-File ($env:APPDATA+'\Macro\Notes.txt') -Width 1000 -Force})

Try{$TextBox.Text = (Get-Content ($env:APPDATA+'\Macro\Notes.txt') -ErrorAction Stop) -join (NL)}Catch{}

$OK = (GUI -B -SX 50 -SY 23 -LX 275 -LY 540 -TE "OK")
$OK.Cl({$NoteForm.Close()})

$TextBox.TabIndex = 0
$OK.TabIndex = 1
$HeaderLabel.TabIndex = 2
$HeaderBox.TabIndex = 3
$NoteForm.TabIndex = 4

$NoteForm.InsArr(@($HeaderLabel,$HeaderBox,$TextBox,$OK))

$NoteForm.Add_SizeChanged({
    $HeaderBox.Size = New-Object System.Drawing.Size((([Int]$This.Width)-65),(([Int]$This.Height)*0.314))
    $TextBox.Size = New-Object System.Drawing.Size((([Int]$This.Width)-65),(([Int]$This.Height)-([Int]$HeaderBox.Height)-105))
    $TextBox.Location = New-Object System.Drawing.Size(25,(([Int]$HeaderBox.Height)+35))
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

    If(!(Test-Path ($env:APPDATA+'\Macro\Stop.txt')) -AND ($X -notmatch '^\\\\#'))
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
