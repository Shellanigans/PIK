Add-Type -AssemblyName System.Drawing | Out-Null
Add-Type -AssemblyName System.Windows.Forms | Out-Null

[Void] [System.Windows.Forms.Application]::EnableVisualStyles()

Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using SWF = System.Windows.Forms;
using DR = System.Drawing;

namespace GUI
{
    public class F : SWF.Form{
        public F (int sx, int sy, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Text = tx;
        }
    }

    public class TC : SWF.TabControl{
        public TC (int sx, int sy, int lx, int ly){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
        }
    }

    public class TP : SWF.TabPage{
        public TP (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class L : SWF.Label{
        public L (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class TB : SWF.TextBox{
        public TB (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class RTB : SWF.RichTextBox{
        public RTB (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class MTB : SWF.MaskedTextBox{
        public MTB (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class B : SWF.Button{
        public B (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class RB : SWF.RadioButton{
        public RB (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class ChB : SWF.CheckBox{
        public ChB (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }

    public class P : SWF.Panel{
        public P (int sx, int sy, int lx, int ly){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
        }
    }

    public class LB : SWF.ListBox{
        public LB (int sx, int sy, int lx, int ly){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
        }
    }

    public class CoB : SWF.ComboBox{
        public CoB (int sx, int sy, int lx, int ly){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
        }
    }

    public class GB : SWF.GroupBox{
        public GB (int sx, int sy, int lx, int ly, string tx){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
            this.Text = tx;
        }
    }
}
'@

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
    #[Void][Console.Window]::ShowWindow($Hide, 0)
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
Add-Type -AssemblyName System.Drawing | Out-Null
Add-Type -AssemblyName System.Windows.Forms | Out-Null

[Void] [System.Windows.Forms.Application]::EnableVisualStyles()

$NoteForm = New-Object System.Windows.Forms.Form
$NoteForm.Size = New-Object System.Drawing.Size(600,608)
$NoteForm.Text = 'Functions'
$NoteForm.MinimumSize = New-Object System.Drawing.Size(600,608)

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Size = New-Object System.Drawing.Size(535,510)
$TextBox.Location = New-Object System.Drawing.Size(25,25)
$TextBox.Multiline = $True
$TextBox.WordWrap = $False
$TextBox.Scrollbars = 'Vertical'
$TextBox.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\Notes.txt') -Width 1000 -Force})

Try{$TextBox.Text = (Get-Content ($env:APPDATA+'\Macro\Notes.txt') -ErrorAction Stop) -join (NL)}Catch{}

$OK = New-Object System.Windows.Forms.Button
$OK.Size = New-Object System.Drawing.Size(50,25)
$OK.Location = New-Object System.Drawing.Size(275,540)
$OK.Text = 'OK'
$OK.Add_Click({$NoteForm.Close()})

$NoteForm.Controls.AddRange(@($TextBox,$OK))

$NoteForm.Add_SizeChanged({
    $TextBox.Size = New-Object System.Drawing.Size((([Int]$This.Width)-65),(([Int]$This.Height)-([Int]$HeaderBox.Height)-105))
    $OK.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-25),(([Int]$This.Height)-65))
})

$NoteForm.ShowDialog()
}

    If((Get-Job -Name 'Notes' | ?{$_.State -match 'Running'}).Count -le 0)
    {
        Start-Job -ScriptBlock $NoteScript -Name 'Notes'
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

    If(!(Test-Path ($env:APPDATA+'\Macro\Stop.txt')) -AND $(Try{$X.SubString(0,3) -notmatch '^\\\\#'}Catch{$True}))
    {
        $X = ($X -replace '{COPY}','^c')
        $X = ($X -replace '{PASTE}','^v')
        $X = ($X -replace '{SELECTALL}','^a')
        
        $X = ($X -replace '{GETCLIP}',([System.Windows.Forms.Clipboard]::GetText()))

        While($X -match '{RAND ')
        {
            $X.Split('{}') | ?{$_ -match 'RAND ' -AND $_ -match ','} | %{
                    $X = $X -replace '{'+$_+'}',(Get-Random -Minimum $_.Split(',')[0] -Maximum $_.Split(',')[1])
            }
            
            Write-Host $X
        }
        
        while($X -match '{VAR ')
        {
            $X.Split('{}') | ?{$_ -match 'VAR '} | %{
                If($_ -match '=')
                {
                    Set-Variable -Name $_.Split(' ')[1].Split('=')[0] -Value $_.Split(' ')[1].Split('=')[1] -Scope Global
                    $X = ($X -replace ('{'+$_+'}'))
                }
                Else
                {
                    $X = ($X -replace ('{'+$_+'}')),((Get-Variable -Name $_.Split(' ')[1].Split('=')[0] -Scope Global).Value)
                }
            }
        }

        If($X -match '{FOCUS')
        {
            $([Void] [Microsoft.VisualBasic.Interaction]::AppActivate($X -replace '{FOCUS ' -replace '}')) 2> $Null
        }
        ElseIf($X -match '{SETCLIP ')
        {
            $X.Split('{}') | ?{$_ -match 'SETCLIP '} | %{
                [System.Windows.Forms.Clipboard]::SetText($_.Substring(8))
                $X = ($X -replace ('{'+$_+'}'))
            }
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

$Form = [GUI.F]::New(365, 490, 'Macro Builder')
$Form.MinimumSize = New-Object System.Drawing.Size(357,485)

$CommandsLabel = [GUI.L]::New(100, 20, 25, 15, 'Key Strokes:')

$GetMouseCoords = [GUI.B]::New(125, 20, 200, 7, 'Get Mouse X,Y')
$GetMouseCoords.Add_Click({
    Sleep 3
    
    $Mouse = [String]([Windows.Forms.Cursor]::Position | %{($_.X,$_.Y) -join ','})

    [Windows.Forms.ClipBoard]::SetText('{MOUSE '+$Mouse+'}')
    
    [Windows.Forms.MessageBox]::Show([String]$Mouse, 'X & Y Coords', [Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information, [System.Windows.Forms.MessageBoxDefaultButton]::Button1) | Out-Null
})

$Commands = [GUI.TB]::New(300, 345, 25, 35, '')
$Commands.Multiline = $True
$Commands.WordWrap = $False
$Commands.ScrollBars = 'Vertical'
$Commands.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\PrevCmds.txt') -Width 1000 -Force})

Try{$Commands.Text = (Get-Content ($env:APPDATA+'\Macro\PrevCmds.txt') -ErrorAction Stop) -join (NL)}Catch{}

$GO = [GUI.B]::New(100, 50, 25, 390, 'GO')
$GO.Add_Click({
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

$Form.Controls.AddRange(@($GO,$Notes,<#$Loop,#>$GetMouseCoords))
    
$Commands.ReadOnly = $False
#$Iteration.ReadOnly = $False

Try{Del ($env:APPDATA+'\Macro\Stop.txt') -ErrorAction Stop -Force}Catch{}

Get-Job -ErrorAction SilentlyContinue | ?{$_.Name -notmatch 'Notes'} | Stop-Job -ErrorAction SilentlyContinue -Force
Get-Job -ErrorAction SilentlyContinue | ?{$_.Status -notmatch 'Running'} | Remove-Job -ErrorAction SilentlyContinue -Force

#$Iteration.Text = $PrevIt

$Form.Refresh()
})

#$Loop = [GUI.C]::New(50, 15, 131, 392, 'Loop')

#$IterationLabel = [GUI.L]::New(95, 12, 129, 407, 'No. of Loops')
#$Iteration = [GUI.TB]::New(85, 20, 130, 420)
#$Iteration.Text = '10'
#$Iteration.Add_TextChanged({$This.Text = $This.Text -replace '\D'})

$Notes = [GUI.B]::New(100, 50, 225, 390, 'Functions')
$Notes.Add_Click({Note})

$Form.Controls.AddRange(@($CommandsLabel,$GetMouseCoords,$Commands,$GO,<#$Loop,$IterationLabel,$Iteration,#>$Notes))

$Form.Add_SizeChanged({
    $GetMouseCoords.Location = New-Object System.Drawing.Size((([Int]$This.Width)-157),11)
    $Commands.Size = New-Object System.Drawing.Size((([Int]$This.Width)-57),(([Int]$This.Height)-140))
    $GO.Location = New-Object System.Drawing.Size(25,(([Int]$This.Height)-95))
    #$Loop.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-47.5),(([Int]$This.Height)-93))
    #$IterationLabel.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-49.5),(([Int]$This.Height)-78))
    #$Iteration.Location = New-Object System.Drawing.Size((([Int]$This.Width/2)-48.5),(([Int]$This.Height)-65))
    $Notes.Location = New-Object System.Drawing.Size((([Int]$This.Width)-132),(([Int]$This.Height)-95))
})

$Form.ShowDialog()

@(Try{Get-Content ($env:APPDATA+'\Macro\Undo.txt') -ErrorAction Stop}Catch{Break}) | %{[KeyBD.Event]::keybd_event(([String]$_), 0, '&H2', 0)}
Del ($env:APPDATA+'\Macro\Undo.txt') -Force -ErrorAction SilentlyContinue
