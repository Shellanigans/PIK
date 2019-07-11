Remove-Variable * -EA SilentlyContinue

$MainBlock = {
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

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

    public class NUD : SWF.NumericUpDown{
        public NUD (int sx, int sy, int lx, int ly){
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

public class Parser{
    public static string ActiveKeys(string X)
    {
        X = X.ToUpper();

        if(Regex.IsMatch(X, "NUM") && X.Length == 4)
        {
            return ("&H6"+X.Replace("NUM",""));
        }
        else if(X.Length == 1)
        {
            return ("&H"+Convert.ToString(Convert.ToInt32(Convert.ToChar(X)), 16)).ToUpper();
        }
        else if(Regex.IsMatch(X, "^F[0-9][0-6]?"))
        {
            return ("&H7"+Convert.ToString((Convert.ToInt32(X.Replace("F","")) - 1), 16)).ToUpper();
        }
        else
        {
            switch(X)
            {
                case "CLEAR":
	                return "&HC";
                case "ENTER":
	                return "&HD";
                case "CANCEL":
	                return "&H03";
                case "BACKSPACE":
	                return "&H08";
                case "TAB":
	                return "&H09";
                case "SHIFT":
	                return "&H10";
                case "CTRL":
	                return "&H11";
                case "ALT":
	                return "&H12";
                case "PAUSE":
	                return "&H13";
                case "CAPSLOCK":
	                return "&H14";
                case "ESC":
	                return "&H1B";
                case "SPACEBAR":
	                return "&H20";
                case "PAGEUP":
	                return "&H21";
                case "PAGEDOWN":
	                return "&H22";
                case "END":
	                return "&H23";
                case "HOME":
	                return "&H24";
                case "LEFTARROW":
	                return "&H25";
                case "UPARROW":
	                return "&H26";
                case "RIGHTARROW":
	                return "&H27";
                case "DOWNARROW":
	                return "&H28";
                case "SELECT":
	                return "&H29";
                case "EXECUTE":
	                return "&H2B";
                case "PRINTSCREEN":
	                return "&H2C";
                case "INS":
	                return "&H2D";
                case "DEL":
	                return "&H2E";
                case "HELP":
	                return "&H2F";
                case "NUMLOCK":
	                return "&H90";
                case "NUMMULT":
	                return "&H6A";
                case "NUMPLUS":
	                return "&H6B";
                case "NUMENTER":
	                return "&H6C";
                case "NUMMINUS":
	                return "&H6D";
                case "NUMPOINT":
	                return "&H6E";
                case "NUMDIV":
	                return "&H6F";
                case "WINDOWS":
	                return "&H5B";
                default:
                    return "&H60";
            }
        }
    }
}
'@

Function Interpret
{
    Param([String]$X)

    $X = ($X.Replace('{COPY}','(^c)'))
    $X = ($X.Replace('{PASTE}','(^v)'))
    $X = ($X.Replace('{SELECTALL}','(^a)'))
        
    $X = ($X.Replace('{DATETIME}',([DateTime]::Now).ToString()))

    $X = ($X.Replace('{GETCLIP}',([Cons.Clip]::GetT())))

    $X = ($X.Replace('{GETMOUSE}',$($PH = [Cons.Curs]::GPos(); [String]$PH.X+','+[String]$PH.Y)))
    
    If($X -match '^{POWER .*}$')
    {
        $X = ([ScriptBlock]::Create(($X -replace '^{POWER ' -replace '}$'))).Invoke()
    }

    While($X -match '{SPACE')
    {
        $X.Split('{}') | ?{$_ -match 'SPACE'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(' ' * [Int](($_ -replace '^SPACE$',' 1').Split(' '))[1])))
            [System.Console]::WriteLine($X)
        }
    }

    While($X -match '{RAND ')
    {
        $X.Split('{}') | ?{$_ -match 'RAND ' -AND $_ -match ','} | %{
                $X = $X -replace ('{'+$_+'}'),(([Random]::New()).Next(($_.Split(' ')[1].Split(',')[0]),($_.Split(' ')[1].Split(',')[1])))
        }
            
        [System.Console]::WriteLine($X)
    }

    While($X -match '{GETCON ')
    {
        $X.Split('{}') | ?{$_ -match 'GETCON '} | %{
            $X = ($X.Replace(('{'+$_+'}'),(Get-Content $_.Substring(7))))
            [System.Console]::WriteLine($X)
        }
    }

    If($X -match '^{GETPIX .*,.*}$')
    {
        $PH = ($X -replace '{GETPIX ')
        $PH = $PH.Substring(0,($PH.Length - 1))
        $PH = $PH.Split(',')

        $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH[0],$PH[1],($PH[0]+1),($PH[1]+1))

        $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
        $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
        $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

        $X = $BMP.GetPixel(0,0).Name.ToUpper()
            
        $Graphics.Dispose()
        $BMP.Dispose()
    }
    
    While($X -match '{VAR ' -OR $X -match '{MANIP ')
    {
        $X.Split('{}') | ?{$_ -match 'VAR ' -AND $_ -notmatch '='} | %{
            $PH = $_.Split(' ')[1]

            $X = $X.Replace(('{'+$_+'}'),($Script:VarsHash.$PH))

            [System.Console]::WriteLine($X)
        }

        $X.Split('{}') | ?{$_ -match 'MANIP '} | %{
            $PH = ($_.Substring(6))

            $Operator = $PH.Split(' ')[0]
            $Operands = [String[]]($PH.Substring(4).Split(','))
            $Operands[-1] = $Operands[-1].Substring(0, ($Operands[-1].Length))

            $Operands | %{$Index = 0}{If($_){$Operands[$Index] = ($_.Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',[N]::L).Replace('(NULL)',''))}; $Index++}
            
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
                'CNT'
                {
                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('[0-9]*_'+$Operands[0]+'$')}).Count
                }
                'APP'
                {
                    If($Operands.Count -gt 2)
                    {
                        $Output = [String]($Operands[0..($Operands.Count - 2)] -join ',')+[String]$Operands[-1]
                    }
                    Else
                    {
                        $Output = $Operands -join ''
                    }
                }
                'RPL'
                {
                    If($Operands.Count -gt 3)
                    {
                        $Output = ($Operands[0..($Operands.Count - 3)] -join ',') -replace $Operands[-2],$Operands[-1]
                    }
                    Else
                    {
                        $Output = $Operands[0] -replace $Operands[1],$Operands[2]
                    }
                }
                'TRS'
                {
                    If($Operands.Count -gt 2)
                    {
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimStart($Operands[-1])
                    }
                    Else
                    {
                        $Output = $Operands[0].TrimStart($Operands[1])
                    }
                }
                'TRE'
                {
                    If($Operands.Count -gt 2)
                    {
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimEnd($Operands[-1])
                    }
                    Else
                    {
                        $Output = $Operands[0].TrimEnd($Operands[1])
                    }
                }
                'JOI'
                {
                    If($Operands.Count -gt 2)
                    {
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimEnd($Operands[-1])
                    }
                    Else
                    {
                        $Output = $Operands[0].TrimEnd($Operands[1])
                    }

                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('[0-9]*_'+$Operands[0]+'$')} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{$Script:VarsHash.$_}) -join $Operands[1]
                }
                'SPL'
                {
                    ($Script:VarsHash.($Operands[0])).ToString().Split($Operands[1]) | %{$Count = 0}{
                        $Script:VarsHash.Remove(([String]$Count+'_'+$Operands[0]))
                        $Script:VarsHash.Add(([String]$Count+'_'+$Operands[0]),$(If($_ -eq $Null){''}Else{$_}))
                        $Count++
                    }
                }
                'TCA'
                {
                    ($Script:VarsHash.($Operands[0])).ToString().ToCharArray() | %{$Count = 0}{
                        $Script:VarsHash.Remove(([String]$Count+'C_'+$Operands[0]))
                        $Script:VarsHash.Add(([String]$Count+'C_'+$Operands[0]),$_)
                        $Count++
                    }
                }
                'REV'
                {
                    $CountF = 0
                    $CountR = (($Script:VarsHash.Keys | ?{$_ -match ('[0-9]*_'+$Operands[0]+'$')}).Count - 1)
                    0..[Math]::Ceiling($CountR / 2) | %{
                        If($CountR -ge $CountF)
                        {
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
            If($Output){[System.Console]::WriteLine($X)}
        }

        $X.Split('{}') | ?{$_ -match 'VAR ' -AND $_ -match '='} | %{
            $PH = $_.Substring(4)
            $PHName = $PH.Split('=')[0]
            $PHValue = $PH.Replace(($PHName+'='),'')

            $Script:VarsHash.Add($PHName,$PHValue)
            
            $X = $X.Replace(('{'+$_+'}'),'')
        }
    }

    Return $X
}

Function Interact
{
    Param([String]$X)

    If(!$SyncHash.Stop)
    {
        [System.Console]::WriteLine($X)

        $X = (Interpret $X)

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

                If(!$SyncHash.Stop){[System.Threading.Thread]::Sleep($PH % 3000)}
                For($i = 0; $i -lt [Int]([Math]::Floor($PH / 3000)) -AND !$SyncHash.Stop; $i++)
                {
                    [System.Threading.Thread]::Sleep(3000)
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
                $Temp = ([Parser]::ActiveKeys(($X.Split()[-1] -replace '}')))
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
                '{WINDOWS}'  {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5B', 0, $(If($_){'&H2'}Else{0}), 0)}; [System.Threading.Thread]::Sleep(40)}
                '{LWINDOWS}' {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5B', 0, $(If($_){'&H2'}Else{0}), 0)}; [System.Threading.Thread]::Sleep(40)}
                '{RWINDOWS}' {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5C', 0, $(If($_){'&H2'}Else{0}), 0)}; [System.Threading.Thread]::Sleep(40)}
            }
        }
        ElseIf($X -match '^{RESTART}$')
        {
            $SyncHash.Restart = $True
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
        ElseIf($IfElHash.ContainsKey($X.Trim('{}')) -AND ($X -match '^{.*}'))
        {
            $IfElName = $X.Trim('{}')

            $Op1 = $IfElHash.($IfElName+'OP1')
            $Op2 = $IfElHash.($IfElName+'OP2')

            $Op1 = (Interpret $Op1)
            $Op2 = (Interpret $Op2)

            If($Op1 -eq '(NULL)'){$Op1 = ''}
            If($Op2 -eq '(NULL)'){$Op2 = ''}

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
        ElseIf($FuncHash.ContainsKey($X.Trim('{}').Split()[0]) -AND ($X -match '^{.*}'))
        {
            $(If($X -match ' '){1..([Int]($X.Split()[-1] -replace '\D'))}Else{1}) | %{$FuncHash.($X.Trim('{}').Split()[0]).Split([N]::L) | ?{$_ -ne ''} | %{Interact $_}}
        }
        Else
        {
            If($X -match '{.*}' -OR $X -match '\(.*\)' -OR $X -match '\[.*\]' -OR $X -match '{.*}')
            {
                [Cons.Send]::Keys($X)
            }
            Else
            {
                If($DelayTimer.Value -ne 0 -OR ($DelayCheck.Checked -AND ($DelayRandTimer.Value -gt 0)))
                {
                    $X.ToCharArray() | %{
                        [Cons.Send]::Keys($_)
                        
                        
                        If($DelayCheck.Checked)
                        {
                            $PH = (([Random]::New()).Next((-1*$DelayRandTimer.Value),($DelayRandTimer.Value)))
                        }
                        Else
                        {
                            $PH = 0
                        }
                        
                        [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($DelayTimer.Value + $PH))))
                    }
                }
                Else
                {
                    [Cons.Send]::Keys($X)
                }
            }
        }

        If($CommandDelayTimer.Value -ne 0 -OR ($CommDelayCheck.Checked -AND ($CommRandTimer.Value -gt 0)))
        {
            If($CommDelayCheck.Checked)
            {
                $PH = (([Random]::New()).Next((-1*$CommRandTimer.Value),($CommRandTimer.Value)))
            }
            Else
            {
                $PH = 0
            }

            [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($CommandDelayTimer.Value + $PH))))
        }
    }
}

Function GO
{
    $Script:Vars = [String[]]@()

    $Script:VarsHash = @{}
    $Script:IfElHash = @{}
    $Script:FuncHash = @{}
    $UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False

    $Commands.ReadOnly     = $True
    $FunctionsBox.ReadOnly = $True
    $StatementsBox.ReadOnly = $True

    $Form.Refresh()

    $StatementsBox.Text.Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9)) -replace '{_}',' '} | %{
        $StatementStart = $False
    }{
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
                $Script:IfElHash.Add($NameState,($NameState+'_NAME'))
            }
            ElseIf($_ -match '^{NUMERIC}')
            {
                $Script:IfElHash.Add($NameState+'NUMERIC','NUMERIC_COMPARISON')
            }
            ElseIf($_ -match '^{OP1 ')
            {
                $PH = $_.Substring(5)
                $PH = $PH.Substring(0, ($PH.Length - 1))
                    
                $Script:IfElHash.Add($NameState+'OP1',$PH)
            }
            ElseIf($_ -match '^{CMP ')
            {
                $PH = $_.Substring(5)
                $PH = $PH.Substring(0, ($PH.Length - 1))
                $Script:IfElHash.Add($NameState+'CMP',$PH)
            }
            ElseIf($_ -match '^{OP2 ')
            {
                $PH = $_.Substring(5)
                $PH = $PH.Substring(0, ($PH.Length - 1))
                    
                $Script:IfElHash.Add($NameState+'OP2',$PH)
            }
            ElseIf($_ -match '^{ELSE}')
            {
                $TF = $False
            }
            ElseIf($_ -match '^{STATEMENT END}')
            {
                $StatementStart = $False
                $Script:IfElHash.Add($NameState+'TComm',($StatementTText -join [N]::L))
                $Script:IfElHash.Add($NameState+'FComm',($StatementFText -join [N]::L))
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

    $FunctionsBox.Text.Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9)) -replace '{_}',' '} | %{
        $FunctionStart = $False

        $FunctionText = @()
    }{
        If(!$FunctionStart -AND $_ -match '^{FUNCTION NAME '){$FunctionStart = $True}
        If($FunctionStart)
        {
            If($_ -match '^{FUNCTION NAME ')
            {
                $NameFunc = [String]($_ -replace '{FUNCTION NAME ' -replace '}')
            }
            ElseIf($_ -match '^{FUNCTION END}')
            {
                $FunctionStart = $False
                $Script:FuncHash.Add($NameFunc,($FunctionText -join [N]::L))
                $FunctionText = @()
            }
            Else
            {
                $FunctionText+=$_
            }
        }
    }

    Do
    {
        $SyncHash.Restart = $False
        
        ($Commands.Text -replace ('`'+[N]::L),'').Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9))} | %{$Commented = $False}{
            If(!$SyncHash.Stop)
            {
                If($_ -match '^<\\\\#'){$Commented = $True}
                If($_ -match '^\\\\#>'){$Commented = $Flase}
                
                If($_ -notmatch '^\\\\#' -AND !$Commented)
                {
                    Interact $_
                }
            }
        }
    }While($SyncHash.Restart)

    $UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False
    
    $Commands.ReadOnly     = $False
    $FunctionsBox.ReadOnly = $False
    $StatementsBox.ReadOnly = $False

    $Form.Refresh()
}

If($Host.Name -match 'Console')
{
    [Console]::Title = 'KeyMouseMacro'

    [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
    [Void][Cons.WindowDisp]::Visual()
}

If(!(Test-Path ($env:APPDATA+'\Macro'))){MKDIR ($env:APPDATA+'\Macro') -Force}

$Vars = [String[]]@()

$UndoHash = @{KeyList=[String[]]@()}
$Script:VarsHash = @{}
$Script:IfElHash = @{}
$Script:FuncHash = @{}
$SyncHash = [HashTable]::Synchronized(@{Stop=$False;Kill=$False;Restart=$False})

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
        [System.Threading.Thread]::Sleep(50)
        If([API.Win32]::GetAsyncKeyState(145))
        {
            $SyncHash.Stop = $True
        }
    }
}) | Out-Null
$Pow.AddParameter('SyncHash', $SyncHash) | Out-Null
$Pow.BeginInvoke() | Out-Null

$Form = [GUI.F]::New(365, 495, 'Pickle')
$Form.MinimumSize = [GUI.SP]::SI(365,495)

$TabController = [GUI.TC]::New(300, 400, 25, 7)
    $TabPageCommLists = [GUI.TP]::New(0, 0, 0, 0,'Comm/Lists')
        $TabContCommLists = [GUI.TC]::New(0, 0, 0, 0)
        $TabContCommLists.Dock = 'Fill'
            $TabPageComm = [GUI.TP]::New(0, 0, 0, 0,'Commands')
                $Commands = [GUI.RTB]::New(0, 0, 0, 0, '')
                $Commands.Dock = 'Fill'
                $Commands.Multiline = $True
                $Commands.WordWrap = $False
                $Commands.ScrollBars = 'Vertical'
                $Commands.AcceptsTab = $True
                $Commands.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\PrevCmds.txt') -Width 1000 -Force})
                $Commands.Text = (Get-Content ($env:APPDATA+'\Macro\PrevCmds.txt') -ErrorAction SilentlyContinue) -join [N]::L
                $Commands.Parent = $TabPageComm
                $Commands.Add_KeyDown({
                    If($_.KeyCode.ToString() -eq 'F1')
                    {
                        $This.SelectionLength = 0
                        $This.SelectedText = '<\\#'
                    }
                    ElseIf($_.KeyCode.ToString() -eq 'F2')
                    {
                        $This.SelectionLength = 0
                        $This.SelectedText = '\\#>'
                    }
                    ElseIf($_.KeyCode.ToString() -eq 'F3')
                    {
                        $This.SelectionLength = 0
                        $This.SelectedText = '\\#'
                    }
                })
            $TabPageComm.Parent = $TabContCommLists
            
            $TabPageLists = [GUI.TP]::New(0, 0, 0, 0,'Listeners')
                $ListsBox = [GUI.RTB]::New(260, 200, 10, 10, '')
                $ListsBox.ReadOnly = $True
                $ListsBox.Multiline = $True
                $ListsBox.Parent = $TabPageLists

                $GetLists = [GUI.B]::New(125, 25, 10, 220, 'Get Listeners')
                $GetLists.Add_Click({
                    #GET THE RUNSPACES AND DISPLAY THE HOTKEY AND COMMANDS FOR EACH 
                })
                $GetLists.Parent = $TabPageLists
            $TabPageLists.Parent = $TabContCommLists
        $TabContCommLists.Parent = $TabPageCommLists
    $TabPageCommLists.Parent = $TabController

    $TabPageFunctions = [GUI.TP]::New(0, 0, 0, 0,'Funct')
        $FunctionsBox = [GUI.RTB]::New(0, 0, 0, 0, '')
        $FunctionsBox.Multiline = $True
        $FunctionsBox.WordWrap = $False
        $FunctionsBox.Scrollbars = 'Vertical'
        $FunctionsBox.AcceptsTab = $True
        $FunctionsBox.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 1000 -Force})
        $FunctionsBox.Text = (Get-Content ($env:APPDATA+'\Macro\Functions.txt') -ErrorAction SilentlyContinue) -join [N]::L
        $FunctionsBox.Dock = 'Fill'
        $FunctionsBox.Parent = $TabPageFunctions
    $TabPageFunctions.Parent = $TabController

    $TabPageStatements = [GUI.TP]::New(0, 0, 0, 0,'State')
        $StatementsBox = [GUI.RTB]::New(0, 0, 0, 0, '')
        $StatementsBox.Multiline = $True
        $StatementsBox.WordWrap = $False
        $StatementsBox.Scrollbars = 'Vertical'
        $StatementsBox.AcceptsTab = $True
        $StatementsBox.Add_TextChanged({$This.Text | Out-File ($env:APPDATA+'\Macro\Statements.txt') -Width 1000 -Force})
        $StatementsBox.Text = (Get-Content ($env:APPDATA+'\Macro\Statements.txt') -ErrorAction SilentlyContinue) -join [N]::L
        $StatementsBox.Dock = 'Fill'
        $StatementsBox.Parent = $TabPageStatements
    $TabPageStatements.Parent = $TabController

    $TabPageAdvanced = [GUI.TP]::New(0, 0, 0, 0,'Adv')
        $TabControllerAdvanced = [GUI.TC]::New(0, 0, 10, 10)
        $TabControllerAdvanced.Dock = 'Fill'
            $TabPageDebug = [GUI.TP]::New(0, 0, 0, 0,'Debug/Helper')
                $GetMouseCoords = [GUI.B]::New(110, 25, 10, 25, 'Get Mouse Inf')
                $GetMouseCoords.Add_Click({
                    $InitialText = $This.Text
                    $This.Text = '3s'
                    [System.Threading.Thread]::Sleep(1000)
                    $This.Text = '2s'
                    [System.Threading.Thread]::Sleep(1000)
                    $This.Text = '1s'
                    [System.Threading.Thread]::Sleep(1000)
                    $This.Text = $InitialText

                    $PH = [Cons.Curs]::GPos()

                    $XCoord.Value = $PH.X
                    $YCoord.Value = $PH.Y

                    $Position = ('{MOUSE '+((($PH).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}')
    
                    $MouseCoordsBox.Text = $Position

                    $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH.X,$PH.Y,($PH.X+1),($PH.Y+1))

                    $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
                    $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
                    $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
    
                    $PixColorBox.Text = $BMP.GetPixel(0,0).Name.ToUpper()

                    $Graphics.Dispose()
                    $BMP.Dispose()
                })
                $GetMouseCoords.Parent = $TabPageDebug

                $MouseCoordLabel = [GUI.L]::New(100, 10, 130, 10, 'Mouse Coords:')
                $MouseCoordLabel.Parent = $TabPageDebug

                $MouseCoordsBox = [GUI.TB]::New(120, 25, 130, 25, '')
                $MouseCoordsBox.ReadOnly = $True
                $MouseCoordsBox.Multiline = $True
                $MouseCoordsBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                $MouseCoordsBox.Parent = $TabPageDebug

                $MouseManualLabel = [GUI.L]::New(100, 10, 10, 60, 'Manual Mouse:')
                $MouseManualLabel.Parent = $TabPageDebug

                $XCoord = [GUI.NUD]::New(50, 25, 10, 75)
                $XCoord.Maximum = 99999
                $XCoord.Minimum = -99999
                $XCoord.Add_ValueChanged({[Cons.Curs]::SPos($This.Value,$YCoord.Value)})
                $XCoord.Add_KeyUp({
                    If($_.KeyCode -eq 'Return')
                    {
                        $PH = [Cons.Curs]::GPos()

                        $Position = ('{MOUSE '+((($PH).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}')
    
                        $MouseCoordsBox.Text = $Position

                        $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH.X,$PH.Y,($PH.X+1),($PH.Y+1))

                        $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
                        $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
                        $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
    
                        $PixColorBox.Text = $BMP.GetPixel(0,0).Name.ToUpper()

                        $Graphics.Dispose()
                        $BMP.Dispose()
                    }
                })
                $XCoord.Parent = $TabPageDebug
                
                $YCoord = [GUI.NUD]::New(50, 25, 70, 75)
                $YCoord.Maximum = 99999
                $YCoord.Minimum = -99999
                $YCoord.Add_ValueChanged({[Cons.Curs]::SPos($XCoord.Value,$This.Value)})
                $YCoord.Add_KeyUp({
                    If($_.KeyCode -eq 'Return')
                    {
                        $PH = [Cons.Curs]::GPos()

                        $Position = ('{MOUSE '+((($PH).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}')
    
                        $MouseCoordsBox.Text = $Position

                        $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH.X,$PH.Y,($PH.X+1),($PH.Y+1))

                        $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
                        $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
                        $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
    
                        $PixColorBox.Text = $BMP.GetPixel(0,0).Name.ToUpper()

                        $Graphics.Dispose()
                        $BMP.Dispose()
                    }
                })
                $YCoord.Parent = $TabPageDebug

                $PixColorLabel = [GUI.L]::New(100, 10, 130, 60, 'HexVal (ARGB):')
                $PixColorLabel.Parent = $TabPageDebug

                $PixColorBox = [GUI.TB]::New(120, 25, 130, 75, '')
                $PixColorBox.ReadOnly = $True
                $PixColorBox.Multiline = $True
                $PixColorBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                $PixColorBox.Parent = $TabPageDebug

                $GetFuncts = [GUI.B]::New(110, 25, 10, 125, 'Get Functs')
                $GetFuncts.Add_Click({
                    $Script:FuncHash.Keys | Sort | %{
                        [System.Console]::WriteLine([N]::L + $_ + [N]::L + '-------------------------' + [N]::L + $Script:FuncHash.$_ + [N]::L + [N]::L)

                        [System.Console]::WriteLine([N]::L * 3)
                    }
                })
                $GetFuncts.Parent = $TabPageDebug

                $GetStates = [GUI.B]::New(110, 25, 130, 125, 'Get States')
                $GetStates.Add_Click({
                    $Script:IfElHash.Keys | ?{$IfElHash.$_ -eq ($_+'_NAME')} | %{
                        $PH = $_
                        $PH = [String[]]($IfElHash.Keys | ?{$_ -match $PH} | Sort)
                        $(If($PH.Contains(($_+'NUMERIC'))){$PH[0,3,4,1,5,6,2]}Else{$PH[0,3,1,4,5,2]}) | %{
                            [System.Console]::WriteLine([N]::L + $_ + [N]::L + '-------------------------' + [N]::L + $Script:IfElHash.$_ + [N]::L + [N]::L)
                        }

                        [System.Console]::WriteLine([N]::L * 3)
                    }
                })
                $GetStates.Parent = $TabPageDebug

                $GetVars = [GUI.B]::New(110, 25, 10, 160, 'Get Vars')
                $GetVars.Add_Click({
                    $Script:VarsHash.Keys | Sort -Unique | %{
                        [System.Console]::WriteLine([N]::L + $_ + [N]::L + '-------------------------' + [N]::L + $Script:VarsHash.$_ + [N]::L + [N]::L)

                        [System.Console]::WriteLine([N]::L * 3)
                    }
                })
                $GetVars.Parent = $TabPageDebug

                $ClearCons = [GUI.B]::New(230, 25, 10, 195, 'Clear Console')
                $ClearCons.Add_Click({Cls})
                $ClearCons.Parent = $TabPageDebug
            $TabPageDebug.Parent = $TabControllerAdvanced

            $TabPageConfig = [GUI.TP]::New(0, 0, 0, 0,'Config')
                $DelayLabel = [GUI.L]::New(150, 25, 10, 10, 'Keystroke Delay (ms):')
                $DelayLabel.Parent = $TabPageConfig

                $DelayTimer = [GUI.NUD]::New(150, 25, 10, 30)
                $DelayTimer.Maximum = 999999999
                $DelayTimer.Parent = $TabPageConfig
                $DelayTimer.BringToFront()

                $DelayCheck = [GUI.ChB]::New(150, 25, 170, 25, 'Randomize')
                $DelayCheck.Parent = $TabPageConfig

                $DelayRandLabel = [GUI.L]::New(200, 25, 10, 60, 'Key Random Weight (ms):')
                $DelayRandLabel.Parent = $TabPageConfig

                $DelayRandTimer = [GUI.NUD]::New(75, 25, 180, 55)
                $DelayRandTimer.Maximum = 999999999
                $DelayRandTimer.Parent = $TabPageConfig
                $DelayRandTimer.BringToFront()

                $CommDelayLabel = [GUI.L]::New(150, 25, 10, 90, 'Command Delay (ms):')
                $CommDelayLabel.Parent = $TabPageConfig

                $CommandDelayTimer = [GUI.NUD]::New(150, 25, 10, 110)
                $CommandDelayTimer.Maximum = 999999999
                $CommandDelayTimer.Parent = $TabPageConfig
                $CommandDelayTimer.BringToFront()

                $CommDelayCheck = [GUI.ChB]::New(150, 25, 170, 105, 'Randomize')
                $CommDelayCheck.Parent = $TabPageConfig

                $CommRandLabel = [GUI.L]::New(200, 25, 10, 140, 'Comm Random Weight (ms):')
                $CommRandLabel.Parent = $TabPageConfig

                $CommRandTimer = [GUI.NUD]::New(75, 25, 180, 135)
                $CommRandTimer.Maximum = 999999999
                $CommRandTimer.Parent = $TabPageConfig
                $CommRandTimer.BringToFront()

                $ShowCons = [GUI.ChB]::New(150, 25, 10, 160, 'Show Console')
                $ShowCons.Add_CheckedChanged({
                    If($Host.Name -match 'Console'){
                        If($This.Checked)
                        {
                            [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 1)
                        }
                        Else
                        {
                            [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
                        }
                    }
                })
                $ShowCons.Parent = $TabPageConfig
            $TabPageConfig.Parent = $TabControllerAdvanced
        $TabControllerAdvanced.Parent = $TabPageAdvanced
    $TabPageAdvanced.Parent = $TabController
$TabController.Parent = $Form

$GO = [GUI.B]::New(300, 25, 25, 415, 'Start!')
$GO.Add_Click({GO})
$GO.Parent = $Form

$Form.Add_SizeChanged({
    $TabController.Size         = [GUI.SP]::SI((([Int]$This.Width)-65),(([Int]$This.Height)-95))
    $TabControllerAdvanced.Size = [GUI.SP]::SI((([Int]$TabController.Width)-30),(([Int]$TabController.Height)-50))
    $TabContCommLists.Size      = [GUI.SP]::SI((([Int]$TabController.Width)-30),(([Int]$TabController.Height)-50))
    $ListsBox.Size              = [GUI.SP]::SI((([Int]$TabController.Width)-40),(([Int]$TabController.Height)-200))
    $GetLists.Location          = [GUI.SP]::PO(10,(([Int]$TabController.Height)-180))
    $GO.Location                = [GUI.SP]::PO(25,(([Int]$This.Height)-80))
    $GO.Size                    = [GUI.SP]::SI((([Int]$This.Width)-65),25)
})

$Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',8.25,[System.Drawing.FontStyle]::Regular)}

If($Host.Name -match 'Console'){Cls}

$Form.ShowDialog()
$UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}

$SyncHash.Kill = $True

If($Host.Name -match 'Console'){Exit}
}

If($PSVersionTable.CLRVersion.Major -le 2)
{
    $MainBlock = [ScriptBlock]::Create(($MainBlock.toString().Split([System.Environment]::NewLine) | %{$FlipFlop = $True}{If($FlipFLop){$_}; $FlipFlop = !$FlipFlop} | %{If($_ -match '::New\('){($_.Split('[')[0]+'(New-Object '+$_.Split('[')[-1]+')') -replace ']::New',' -ArgumentList '}Else{$_}}) -join [System.Environment]::NewLine)
}

$MainBlock.Invoke()
