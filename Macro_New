#Add-Type -AssemblyName System.Drawing | Out-Null
Add-Type -AssemblyName System.Windows.Forms | Out-Null
Add-Type -AssemblyName Microsoft.VisualBasic | Out-Null

Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

using SWF = System.Windows.Forms;
using DR = System.Drawing;

namespace Console{
    public class MouseEvnt{
        [DllImport("user32.dll")]
        public static extern void mouse_event(Int64 dwFlags, Int64 dx, Int64 dy, Int64 cButtons, Int64 dwExtraInfo);
    }

    public class KeyEvnt{
        [DllImport("user32.dll")]
        public static extern void keybd_event(Byte bVk, Byte bScan, Int64 dwFlags, Int64 dwExtraInfo);
    }

    public class WindowDisp{
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);

        public static void Visual (){
            SWF.Application.EnableVisualStyles();
        }
    }
}

namespace GUI{
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

    public class SP{
        public static DR.Point PO (int sx, int sy){
            return (new DR.Point(sx, sy));
        }
        
        public static DR.Size SI (int sx, int sy){
            return (new DR.Size(sx, sy));
        }
    }
}
'@

Function NL
{
    Param($X)

    Return $(If($X -AND ($X -ne 0)){(1..([Math]::Abs([Int]$X)) | %{[System.Environment]::NewLine}) -join ''}Else{[System.Environment]::NewLine})
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

    If(!$SyncHash.Stop -AND $(Try{$X.SubString(0,3) -notmatch '^\\\\#'}Catch{$True}))
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
        
        While($X -match '{VAR ')
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
                [Int]($X.Split()[-1] -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{[Console.MouseEvnt]::mouse_event(($(If($Rel){$_*2}Else{$_})), 0, 0, 0, 0)}
            }
            Else
            {
                $Temp = (ActiveKeys ($X.Split()[-1] -replace '}'))
                $UndoHash.KeyList+=([String]$Temp)
                [Console.KeyEvnt]::keybd_event($Temp, 0, $(If($Rel){'&H2'}Else{0}), 0)
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
                0..([Int](($X -replace '}').Split(' ')[-1])) | %{[Int]($X.Split(' ')[0] -replace '{' -replace 'MOUSE' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{[Console.MouseEvnt]::mouse_event($_, 0, 0, 0, 0)}}
            }
            Else
            {
                [Int]($X -replace '{' -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{[Console.MouseEvnt]::mouse_event($_, 0, 0, 0, 0)}
            }
        }
        ElseIf($FuncHash.ContainsKey($X.Trim('{}').Split()[0]))
        {
            $(If($X -match ' '){1..([Int]($X.Split()[-1] -replace '\D'))}Else{1}) | %{$FuncHash.($X.Trim('{}').Split()[0]).Split((NL)) | ?{$_ -ne ''} | %{Interact $_}}
        }
        Else
        {
            [System.Windows.Forms.SendKeys]::SendWait($X)
        }
    }
}

#[Void][Console.WindowDisp]::ShowWindow([Console.WindowDisp]::GetConsoleWindow(), 0)
[Void][Console.WindowDisp]::Visual()

If(!(Test-Path ($env:APPDATA+'\Macro'))){MKDIR ($env:APPDATA+'\Macro') -Force}

$UndoHash = @{KeyList=[String[]]@()}
$FuncHash = @{}
$SyncHash = [HashTable]::Synchronized(@{Stop=$False})

$Pow = [Powershell]::Create()
$Run = [RunspaceFactory]::CreateRunspace()
$Run.Open()
$Pow.Runspace = $Run
$Pow.AddScript({
    Param($SyncHash)

    Add-Type -Name Win32 -Namespace API -MemberDefinition '
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int virtualKeyCode);
    ' -ErrorAction SilentlyContinue

    While($True)
    {
        Sleep -Milliseconds 50
        If([API.Win32]::GetAsyncKeyState(145))
        {
            $SyncHash.Stop = $True
        }
    }
}) | Out-Null
$Pow.AddParameter('SyncHash', $SyncHash) | Out-Null
$Pow.BeginInvoke() | Out-Null

$Form = [GUI.F]::New(365, 490, 'KeyMouseMacro')
$Form.MinimumSize = [GUI.SP]::SI(357,485)

$TabController = [GUI.TC]::New(300, 375, 25, 7)

$TabPageCmds = [GUI.TP]::New(0, 0, 0, 0,'Commands')
$Commands = [GUI.TB]::New(290, 345, 0, 0, '')
$Commands.Multiline = $True
$Commands.WordWrap = $False
$Commands.ScrollBars = 'Vertical'
$Commands.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\PrevCmds.txt') -Width 1000 -Force})
Try{$Commands.Text = (Get-Content ($env:APPDATA+'\Macro\PrevCmds.txt') -ErrorAction Stop) -join (NL)}Catch{}
$TabPageCmds.Controls.Add($Commands)
$TabController.Controls.Add($TabPageCmds)

$TabPageFunctions = [GUI.TP]::New(0, 0, 0, 0,'Functions')
$FunctionsBox = [GUI.TB]::New(290, 345, 0, 0, '')
$FunctionsBox.Multiline = $True
$FunctionsBox.WordWrap = $False
$FunctionsBox.Scrollbars = 'Vertical'
$FunctionsBox.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 1000 -Force})
Try{$FunctionsBox.Text = (Get-Content ($env:APPDATA+'\Macro\Functions.txt') -ErrorAction Stop) -join [System.Environment]::NewLine}Catch{}
$TabPageFunctions.Controls.Add($FunctionsBox)
$TabController.Controls.Add($TabPageFunctions)

$GO = [GUI.B]::New(100, 50, 25, 390, 'Start!')
$GO.Add_Click({
    $FuncHash = @{}
    $UndoHash.KeyList | %{[Console.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False

    $Form.Controls.Remove($GO)
    $Form.Controls.Remove($GetMouseCoords)

    $Commands.ReadOnly = $True
    $FunctionsBox.ReadOnly = $True

    $Form.Refresh()

    $FunctionsBox.Text.Split((NL)) | ?{$_ -ne ''} | %{
        $Functions = $False
        $FunctionStart = $False

        $FunctionText = @()
    }{
        If($Functions)
        {
            If(!$FunctionStart -AND $_ -match '{FUNCTION NAME '){$FunctionStart = $True}
            If($FunctionStart)
            {
                If($_ -match '{FUNCTION NAME ')
                {
                    $Name = [String]($_ -replace '{FUNCTION NAME ' -replace '}')
                }
                ElseIf($_ -match '^{FUNCTION END}$')
                {
                    $FunctionStart = $False
                    $FuncHash.Add($Name,($FunctionText -join (NL)))
                    $FunctionText = @()
                }
                Else
                {
                    $FunctionText+=$_
                }
            }
        }
        If($_ -match '{FUNCTIONS}'){$Functions = $True}
    }

    $Commands.Text.Split((NL)) | ?{$_ -ne ''} | %{
        If(!$SyncHash.Stop)
        {
            Interact $_
        }
    }

    $UndoHash.KeyList | %{[Console.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False

    $Form.Controls.AddRange(@($GO,$GetMouseCoords))
    
    $Commands.ReadOnly = $False
    $FunctionsBox.ReadOnly = $False

    $Form.Refresh()
})

$GetMouseCoords = [GUI.B]::New(100, 50, 225, 390, 'Mouse X,Y')
$GetMouseCoords.Add_Click({
    $Form.Controls.Remove($GO)
    $Form.Controls.Remove($GetMouseCoords)

    $Commands.ReadOnly = $True
    $FunctionsBox.ReadOnly = $True
    
    Sleep 3
   
    [System.Windows.Forms.ClipBoard]::SetText('{MOUSE '+((([System.Windows.Forms.Cursor]::Position).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}')

    $Commands.ReadOnly = $False
    $FunctionsBox.ReadOnly = $False

    $Form.Controls.AddRange(@($GO,$GetMouseCoords))
})

$Form.Add_SizeChanged({
    $TabController.Size      = [GUI.SP]::SI((([Int]$This.Width)-57),(([Int]$This.Height)-110))
    $Commands.Size           = [GUI.SP]::SI((([Int]$TabController.Width)-10),(([Int]$TabController.Height)-30))
    $FunctionsBox.Size       = [GUI.SP]::SI((([Int]$TabController.Width)-10),(([Int]$TabController.Height)-30))
    $GO.Location             = [GUI.SP]::PO(25,(([Int]$This.Height)-95))
    $GetMouseCoords.Location = [GUI.SP]::PO((([Int]$This.Width)-132),(([Int]$This.Height)-95))
})

$Form.Controls.AddRange(@($TabController,$GO,$GetMouseCoords))

$Form.ShowDialog()
$UndoHash.KeyList | %{[Console.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
