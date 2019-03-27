Remove-Variable * -EA SilentlyContinue

Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

using DR = System.Drawing;
using SWF = System.Windows.Forms;

namespace Cons{
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

    public class App{
        public static void Act (string AppTitle){
            Microsoft.VisualBasic.Interaction.AppActivate(AppTitle);
        }
    }

    public class Clip{
        public static string GetT (){
            return SWF.Clipboard.GetText();
        }

        public static void SetT (string Text){
            SWF.Clipboard.SetText(Text);
        }
    }

    public class Curs{
        public static DR.Point GPos (){
            return SWF.Cursor.Position;
        }

        public static void SPos (int x, int y){
            SWF.Cursor.Position = new DR.Point(x, y);
        }
    }

    public class Send{
        public static void Keys (string Keys){
            SWF.SendKeys.SendWait(Keys);
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

public class N{
    public static string L = System.Environment.NewLine;
}
'@

Function ActiveKeys
{
    Param([String]$X)
    
    If(($X -match 'NUM') -AND ($X.Length -eq 4))
    {
        Return [String]('&H6'+($X -replace 'Num'))
    }
    ElseIf($X.Length -eq 1)
    {
        Return [String]('&H'+[Convert]::ToString(([Int][Char]([String]$X).ToUpper()), 16))
    }
    ElseIf($X -like 'F*')
    {
        Return [String]('&H7'+[Convert]::ToString(([Int]($X -replace 'F') - 1), 16))
    }
    Else
    {
        Switch($X)
        {
            'CANCEL'      {Return '&H03'}
            'BACKSPACE'   {Return '&H08'}
            'TAB'         {Return '&H09'}
            'CLEAR'       {Return '&HC'}
            'ENTER'       {Return '&HD'}
            'SHIFT'       {Return '&H10'}
            'CTRL'        {Return '&H11'}
            'ALT'         {Return '&H12'}
            'PAUSE'       {Return '&H13'}
            'CAPSLOCK'    {Return '&H14'}
            'ESC'         {Return '&H1B'}
            'SPACEBAR'    {Return '&H20'}
            'PAGEUP'      {Return '&H21'}
            'PAGEDOWN'    {Return '&H22'}
            'END'         {Return '&H23'}
            'HOME'        {Return '&H24'}
            'LEFTARROW'   {Return '&H25'}
            'UPARROW'     {Return '&H26'}
            'RIGHTARROW'  {Return '&H27'}
            'DOWNARROW'   {Return '&H28'}
            'SELECT'      {Return '&H29'}
            'EXECUTE'     {Return '&H2B'}
            'PRINTSCREEN' {Return '&H2C'}
            'INS'         {Return '&H2D'}
            'DEL'         {Return '&H2E'}
            'HELP'        {Return '&H2F'}
            'NUMLOCK'     {Return '&H90'}
            'NUMMULT'     {Return '&H6A'}
            'NUMPLUS'     {Return '&H6B'}
            'NUMENTER'    {Return '&H6C'}
            'NUMMINUS'    {Return '&H6D'}
            'NUMPOINT'    {Return '&H6E'}
            'NUMDIV'      {Return '&H6F'}
            'WINDOWS'     {Return '&H5B'}
        }
    }
}

Function Parser
{
    Param([String]$X)

    $X = ($X -replace '{GETCLIP}',([Cons.Clip]::GetT()))

    While($X -match '{RAND ')
    {
        $X.Split('{}') | ?{$_ -match 'RAND ' -AND $_ -match ','} | %{
                $X = $X -replace ('{'+$_+'}'),(Get-Random -Minimum $_.Split(' ')[1].Split(',')[0] -Maximum $_.Split(' ')[1].Split(',')[1])
        }
            
        Write-Host $X
    }

    While($X -match '{GETCON ')
    {
        $X.Split('{}') | ?{$_ -match 'GETCON '} | %{
            $X = ($X.Replace(('{'+$_+'}'),(GC $_.Substring(7))))
            Write-Host $X
        }
    }
    
    While($X -match '{VAR ' -OR $X -match '{MANIP ')
    {
        $X.Split('{}') | ?{$_ -match 'VAR ' -AND $_ -notmatch '='} | %{
            $PH = $_.Split(' ')[1]
                
            $X = $X.Replace(('{'+$_+'}'),((Get-Variable -Name $PH -Scope Script).Value))
            Write-Host $X
        }

        $X.Split('{}') | ?{$_ -match 'MANIP ' -AND $_ -match ','} | %{
            $PH = ($_.Substring(6))

            $Operator = $PH.Split(' ')[0]
            $Operands = $PH.Substring(4).Split(',')
            $Operands[-1] = $Operands[-1].Substring(0, ($Operands[-1].Length))
            $Operands+=''
            $Operands+=''

            $Operands[0] = ($Operands[0].Replace('(COMMA)',',')).Replace('(SPACE)',' ').Replace('(NEWLINE)',[N]::L).Replace('(NULL)','')
            $Operands[1] = ($Operands[1].Replace('(COMMA)',',')).Replace('(SPACE)',' ').Replace('(NEWLINE)',[N]::L).Replace('(NULL)','')
            $Operands[2] = ($Operands[2].Replace('(COMMA)',',')).Replace('(SPACE)',' ').Replace('(NEWLINE)',[N]::L).Replace('(NULL)','')

            $Output = ''

            Switch($Operator)
            {
                'ADD'
                {
                    $Output = ([Double]$Operands[0] + [Double]$Operands[1])
                }
                'SUB'
                {
                    $Output = ([Double]$Operands[0] - [Double]$Operands[1])
                }
                'MUL'
                {
                    $Output = ([Double]$Operands[0] * [Double]$Operands[1])
                }
                'DIV'
                {
                    $Output = ([Double]$Operands[0] / [Double]$Operands[1])
                }
                'POW'
                {
                    $Output = [Math]::Pow([Double]$Operands[0],[Double]$Operands[1])
                }
                'MOD'
                {
                    $Output = ([Double]$Operands[0] % [Double]$Operands[1])
                }
                'SIN'
                {
                    $Output = [Math]::Sin([Double]$Operands[0])
                }
                'COS'
                {
                    $Output = [Math]::Cos([Double]$Operands[0])
                }
                'TAN'
                {
                    $Output = [Math]::Tan([Double]$Operands[0])
                }
                'FLR'
                {
                    $Output = [Math]::Floor([Double]$Operands[0])
                }
                'CEI'
                {
                    $Output = [Math]::Ceiling([Double]$Operands[0])
                }
                'LEN'
                {
                    $Output = $Operands[0].Length
                }
                'APP'
                {
                    $Output = $Operands -join ''
                }
                'RPL'
                {
                    $Output = $Operands[0] -replace $Operands[1],$Operands[2]
                }
                'TRS'
                {
                    $Output = $Operands[0].TrimStart($Operands[1])
                }
                'TRE'
                {
                    $Output = $Operands[0].TrimEnd($Operands[1])
                }
                'CNT'
                {
                    $Output = (Get-Variable -Name ('*_'+$Operands[0])).Count
                }
                'SPL'
                {
                    Remove-Variable ('*_'+$Operands[0]) -Scope Script -Force
                    (Get-Variable -Name $Operands[0]).Value.ToString().Split($Operands[1]) | %{$Count = 0}{
                        Set-Variable -Name ([String]$Count+'_'+$Operands[0]) -Value $(If($_ -eq $Null){''}Else{$_}) -Scope Script
                        $Count++
                    }
                }
                'TCA'
                {
                    Remove-Variable ('*_'+$Operands[0]) -Scope Script -Force
                    (Get-Variable -Name $Operands[0]).Value.ToString().ToCharArray() | %{$Count = 0}{
                        Set-Variable -Name ([String]$Count+'_'+$Operands[0]) -Value $_ -Scope Script
                        $Count++
                    }
                }
                'JOI'
                {
                    $Vars = @(GV ('*_'+$Operands[0]) | %{$_.Name} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort})
                    $Output = (@($Vars | %{Get-Variable -Name $_ -ValueOnly}) -join $Operands[1])
                }
                'REV'
                {
                    (Get-Variable -Name ('*_'+$Operands[0])) | %{$CountF = 0; $CountR = ((Get-Variable -Name ('*_'+$Operands[0])).Count - 1)}{
                        If($CountR -ge $CountF)
                        {
                            $PH = (Get-Variable -Name ([String]$CountR+'_'+$Operands[0]) -ValueOnly)
                            Set-Variable -Name ([String]$CountR+'_'+$Operands[0]) -Value (Get-Variable -Name ([String]$CountF+'_'+$Operands[0]) -ValueOnly) -Force
                            Set-Variable -Name ([String]$CountF+'_'+$Operands[0]) -Value $PH -Scope Script -Force
                            (Get-Variable -Name ([String]$CountR+'_'+$Operands[0])) | %{If($_.Value -eq $Null){Set-Variable -Name $_.Name -Value '' -Scope Script -Force}}
                            (Get-Variable -Name ([String]$CountF+'_'+$Operands[0])) | %{If($_.Value -eq $Null){Set-Variable -Name $_.Name -Value '' -Scope Script -Force}}
                            $CountF++
                            $CountR--
                        }
                    }
                }
            }
            
            $X = $X.Replace(('{'+$_+'}'),$Output)
            If($Output){Write-Host $X}
        }

        $X.Split('{}') | ?{$_ -match 'VAR ' -AND $_ -match '='} | %{
            $PH = $_.Substring(4)
                
            Set-Variable -Name $PH.Split('=')[0] -Value $PH.Split('=')[1] -Scope Script -Force
            $X = $X.Replace(('{'+$_+'}'),'')
        }
    }

    Return $X
}

Function Interact
{
    Param([String]$X)

    Write-Host $X

    If(!$SyncHash.Stop)
    {
        If($X.Length -ge 3 -AND $X.SubString(0,3) -match '^\\\\#'){$X = ''}
        
        $X = ($X -replace '{COPY}','^c')
        $X = ($X -replace '{PASTE}','^v')
        $X = ($X -replace '{SELECTALL}','^a')

        $X = ($X -replace '{SPACE}',' ')
        $X = ($X -replace '{DATETIME}',(Get-Date).ToString())

        $X = (Parser $X)

        If($X -match '^{SETCON')
        {
            $PH = ($X.Substring(8)).Split(',')
            $PH[0] = ($PH[0].Replace('(COMMA)',','))
            $PH[1] = ($PH[1].Replace('(COMMA)',','))

            If($X -notmatch '^{SETCONA ')
            {
                ($PH[0].TrimStart(' ')) | Out-File ($PH[1].Substring(0,($PH[1].Length - 1))) -Force
            }
            Else
            {
                ($PH[0].TrimStart(' ')) | Out-File ($PH[1].Substring(0,($PH[1].Length - 1))) -Append -Force
            }
        }
        ElseIf($X -match '{FOCUS')
        {
            Try{[Cons.App]::Act($X -replace '{FOCUS ' -replace '}')}Catch{}
        }
        ElseIf($X -match '{SETCLIP ')
        {
            $X.Split('{}') | ?{$_ -match 'SETCLIP '} | %{
                [Cons.Clip]::SetT($_.Substring(8))
                $X = ($X -replace ('{'+$_+'}'))
            }
        }
        ElseIf($X -match '{WAIT')
        {
            $X -replace '{WAIT' -replace '}' | %{
                If($_ -ne '{WAIT')
                {
                    If($_ -match 'M')
                    {
                        $PH = [Int]($_ -replace 'M ')
                    }
                    Else
                    {
                        $PH = [Int]($_)*1000
                    }
                }
                Else
                {
                    $PH = 1000
                }

                If(!$SyncHash.Stop){Sleep -Milliseconds ($PH % 3000)}
                For($i = 0; $i -lt [Int]([Math]::Floor($PH / 3000)) -AND !$SyncHash.Stop; $i++)
                {
                    Sleep 3
                }
            }
        }
        ElseIf($X -match '{[/\\]?HOLD')
        {
            $Rel = ($X -match '[/\\]')

            If($X -match 'MOUSE')
            {
                [Int]($X.Split()[-1] -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{[Cons.MouseEvnt]::mouse_event(($(If($Rel){$_*2}Else{$_})), 0, 0, 0, 0)}
            }
            Else
            {
                $Temp = (ActiveKeys ($X.Split()[-1] -replace '}'))
                $UndoHash.KeyList+=([String]$Temp)
                [Cons.KeyEvnt]::keybd_event($Temp, 0, $(If($Rel){'&H2'}Else{0}), 0)
            }
        }
        ElseIf($X -match '^{[LRM]?MOUSE')
        {
            If($X -match ',')
            {
                $X -replace '{MOUSE ' -replace '}' | %{[Cons.Curs]::SPos($_.Split(',')[0], $_.Split(',')[-1])}
            }
            ElseIf($X -match ' ')
            {
                0..([Int](($X -replace '}').Split(' ')[-1])) | %{[Int]($X.Split(' ')[0] -replace '{' -replace 'MOUSE' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{[Cons.MouseEvnt]::mouse_event($_, 0, 0, 0, 0)}}
            }
            Else
            {
                [Int]($X -replace '{' -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{[Cons.MouseEvnt]::mouse_event($_, 0, 0, 0, 0)}
            }
        }
        ElseIf($X -match 'WINDOWS}')
        {
            Switch($X)
            {
                '{WINDOWS}'  {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5B', 0, $(If($_){'&H2'}Else{0}), 0)}; Sleep -Milliseconds 40}
                '{LWINDOWS}' {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5B', 0, $(If($_){'&H2'}Else{0}), 0)}; Sleep -Milliseconds 40}
                '{RWINDOWS}' {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5C', 0, $(If($_){'&H2'}Else{0}), 0)}; Sleep -Milliseconds 40}
            }
        }
        ElseIf($X -match '^{SCRNSHT ')
        {
            $PH = ($X -replace '{SCRNSHT ')
            $PH = $PH.Substring(0,($PH.Length - 1))
            $PH = $PH.Split(',')

            $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH[0],$PH[1],$PH[2],$PH[3])

            $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
            $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
            $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.size)
            
            $BMP.Save($PH[4])
            
            $Graphics.Dispose()
            $BMP.Dispose()
        }
        ElseIf($IfElHash.ContainsKey($X.Trim('{}')))
        {
            $IfElName = $X.Trim('{}')

            $Op1 = $IfElHash.($IfElName+'OP1')
            $Op2 = $IfElHash.($IfElName+'OP2')

            $Op1 = (Parser $Op1)
            $Op2 = (Parser $Op2)

            If($Op1 -eq '(NULL)'){$Op1 = $Null}
            If($Op2 -eq '(NULL)'){$Op2 = $Null}

            If($IfElHash.ContainsKey($IfElName+'NUMERIC'))
            {
                $Op1 = [Double]$Op1
                $Op2 = [Double]$Op2
            }

            $TComm = $IfElHash.($IfElName+'TComm').Replace('(NULL)','')
            $FComm = $IfElHash.($IfElName+'FComm').Replace('(NULL)','')

            Switch($IfElHash.($IfElName+'CMP'))
            {
                'MATCH'    {If($Op1 -match $Op2)       {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'EQ'       {If($Op1 -eq $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'LIKE'     {If($Op1 -like $Op2)        {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'LT'       {If($Op1 -lt $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'LE'       {If($Op1 -le $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'GT'       {If($Op1 -gt $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'GE'       {If($Op1 -ge $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'NOTMATCH' {If($Op1 -notmatch $Op2)    {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'NE'       {If($Op1 -ne $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
                'NOTLIKE'  {If($Op1 -notlike $Op2)     {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}}
            }
        }
        ElseIf($FuncHash.ContainsKey($X.Trim('{}').Split()[0]))
        {
            $(If($X -match ' '){1..([Int]($X.Split()[-1] -replace '\D'))}Else{1}) | %{$FuncHash.($X.Trim('{}').Split()[0]).Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}
        }
        Else
        {
            [Cons.Send]::Keys($X)
        }
    }
}

[Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
[Void][Cons.WindowDisp]::Visual()

If(!(Test-Path ($env:APPDATA+'\Macro'))){MKDIR ($env:APPDATA+'\Macro') -Force}

$UndoHash = @{KeyList=[String[]]@()}
$IfElHash = @{}
$FuncHash = @{}
$SyncHash = [HashTable]::Synchronized(@{Stop=$False;Kill=$False})

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

    While(!$SyncHash.Kill)
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
$Commands.AcceptsTab = $True
$Commands.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\PrevCmds.txt') -Width 1000 -Force})
Try{$Commands.Text = (Get-Content ($env:APPDATA+'\Macro\PrevCmds.txt') -ErrorAction Stop) -join [N]::L}Catch{}
$TabPageCmds.Controls.Add($Commands)
$TabController.Controls.Add($TabPageCmds)

$TabPageFunctions = [GUI.TP]::New(0, 0, 0, 0,'Functions')
$FunctionsBox = [GUI.TB]::New(290, 345, 0, 0, '')
$FunctionsBox.Multiline = $True
$FunctionsBox.WordWrap = $False
$FunctionsBox.Scrollbars = 'Vertical'
$FunctionsBox.AcceptsTab = $True
$FunctionsBox.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 1000 -Force})
Try{$FunctionsBox.Text = (Get-Content ($env:APPDATA+'\Macro\Functions.txt') -ErrorAction Stop) -join [System.Environment]::NewLine}Catch{}
$TabPageFunctions.Controls.Add($FunctionsBox)
$TabController.Controls.Add($TabPageFunctions)

$GO = [GUI.B]::New(100, 50, 25, 390, 'Start!')
$GO.Add_Click({
    $IfElHash = @{}
    $FuncHash = @{}
    $UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False

    $Form.Controls.Remove($GO)
    $Form.Controls.Remove($GetMouseCoords)

    $Commands.ReadOnly     = $True
    $FunctionsBox.ReadOnly = $True

    $Form.Refresh()

    $FunctionsBox.Text.Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9)) -replace '{_}',' '} | %{
        $Statements     = $False
        $StatementStart = $False
    }{
        If($Statements)
        {
            If(!$StatementStart -AND $_ -match '^{STATEMENT NAME ')
            {
                $StatementStart = $True
                $Numeric = $False

                $TF = $True

                $StatementTText = [String[]]@()
                $StatementFText = [String[]]@()
            }

            If($StatementStart)
            {
                If($_ -match '^{STATEMENT NAME ')
                {
                    $NameState = [String]($_ -replace '^{STATEMENT NAME ' -replace '}')
                    $IfElHash.Add($NameState,'')
                }
                ElseIf($_ -match '^{NUMERIC}$')
                {
                    $IfElHash.Add($NameState+'NUMERIC','')
                }
                ElseIf($_ -match '^{OP1 ')
                {
                    $PH = $_.Substring(5)
                    $PH = $PH.Substring(0, ($PH.Length - 1))
                    
                    $IfElHash.Add($NameState+'OP1',$PH)
                }
                ElseIf($_ -match '^{CMP ')
                {
                    $PH = $_.Substring(5)
                    $PH = $PH.Substring(0, ($PH.Length - 1))
                    $IfElHash.Add($NameState+'CMP',$PH)
                }
                ElseIf($_ -match '^{OP2 ')
                {
                    $PH = $_.Substring(5)
                    $PH = $PH.Substring(0, ($PH.Length - 1))
                    
                    $IfElHash.Add($NameState+'OP2',$PH)
                }
                ElseIf($_ -match '^{ELSE}$')
                {
                    $TF = $False
                }
                ElseIf($_ -match '^{STATEMENT END}$')
                {
                    $StatementStart = $False
                    $IfElHash.Add($NameState+'TComm',($StatementTText -join [N]::L))
                    $IfElHash.Add($NameState+'FComm',($StatementFText -join [N]::L))
                }
                Else
                {
                    If($TF)
                    {
                        $StatementTText+=$_
                    }
                    Else
                    {
                        $StatementFText+=$_
                    }
                }
            }
        }
        If($_ -match '^{STATEMENTS}$'){$Statements = $True}ElseIf($_ -match '^{STATEMENTS END}$'){$Statements = $False}
    }

    $FunctionsBox.Text.Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9)) -replace '{_}',' '} | %{
        $Functions     = $False
        $FunctionStart = $False

        $FunctionText = @()
    }{
        If($Functions)
        {
            If(!$FunctionStart -AND $_ -match '^{FUNCTION NAME '){$FunctionStart = $True}
            If($FunctionStart)
            {
                If($_ -match '^{FUNCTION NAME ')
                {
                    $NameFunc = [String]($_ -replace '{FUNCTION NAME ' -replace '}')
                }
                ElseIf($_ -match '^{FUNCTION END}$')
                {
                    $FunctionStart = $False
                    $FuncHash.Add($NameFunc,($FunctionText -join [N]::L))
                    $FunctionText = @()
                }
                Else
                {
                    $FunctionText+=$_
                }
            }
        }
        If($_ -match '^{FUNCTIONS}$'){$Functions = $True}ElseIf($_ -match '^{FUNCTIONS END}$'){$Functions = $False}
    }

    ($Commands.Text -replace ('`'+[N]::L),'').Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9))} | %{
        If(!$SyncHash.Stop)
        {
            Interact $_
        }
    }

    $UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False

    $Form.Controls.AddRange(@($GO,$GetMouseCoords))
    
    $Commands.ReadOnly     = $False
    $FunctionsBox.ReadOnly = $False

    $Form.Refresh()
})

$GetMouseCoords = [GUI.B]::New(100, 50, 225, 390, 'Mouse X,Y')
$GetMouseCoords.Add_Click({
    $Form.Controls.Remove($GO)
    $Form.Controls.Remove($GetMouseCoords)

    $Commands.ReadOnly     = $True
    $FunctionsBox.ReadOnly = $True
    
    Sleep 3
    
    $Position = ([N]::L+'{MOUSE '+((([Cons.Curs]::GPos()).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}')
    
    [Cons.Clip]::SetT($Position)
    $Commands.Text+=($Position)
    
    $Commands.ReadOnly     = $False
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
$Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',8.25,[System.Drawing.FontStyle]::Regular)}

$Form.ShowDialog()
$UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}

$SyncHash.Kill = $True
