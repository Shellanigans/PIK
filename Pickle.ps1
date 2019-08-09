Remove-Variable * -EA SilentlyContinue

$MainBlock = {
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic -TypeDefinition @'
using System;
using System.IO;
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
    
    public class CB : SWF.ComboBox{
        public CB (int sx, int sy, int lx, int ly){
            this.Size = new DR.Size(sx,sy);
            this.Location = new DR.Point(lx,ly);
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
    public static string HoldKeys(string X){
        X = X.ToUpper();

        if(Regex.IsMatch(X, "NUM") && X.Length == 4){
            return ("&H6"+X.Replace("NUM",""));
        }
        else if(X.Length == 1){
            return ("&H"+Convert.ToString(Convert.ToInt32(Convert.ToChar(X)), 16)).ToUpper();
        }
        else if(Regex.IsMatch(X, "^F[0-9][0-6]?")){
            return ("&H7"+Convert.ToString((Convert.ToInt32(X.Replace("F","")) - 1), 16)).ToUpper();
        }
        else{
            switch(X){
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

    public static string Interpret(string X){
        if(Regex.IsMatch(X.ToUpper(), "{[CPSDGR]")){
            if(Regex.IsMatch(X, "{[CPS]")){
                X = (X.Replace("{COPY}","(^c)"));
                X = (X.Replace("{PASTE}","(^v)"));
                X = (X.Replace("{SELECTALL}","(^a)"));
            }
            else if(Regex.IsMatch(X, "{[DSR]A")){
                X = (X.Replace("{DATETIME}",DateTime.Now.ToString()));
                while(Regex.IsMatch(X, "{SPACE")){
                    foreach(string SubString in X.Split("{}".ToCharArray())){
                        if(Regex.IsMatch(SubString, "SPACE")){
                            X = X.Replace(("{"+SubString+"}"),(new string (' ', Convert.ToInt32(Regex.Replace(SubString, "^SPACE$", " 1").Split(' ')[1]))));
                            System.Console.WriteLine(X);
                        }
                    }
                }
                while(Regex.IsMatch(X, "{RAND ")){
                    foreach(string SubString in X.Split("{}".ToCharArray())){
                        if(Regex.IsMatch(SubString, "RAND ") && Regex.IsMatch(SubString, ",")){
                            X = X.Replace(("{"+SubString+"}"),(Convert.ToString((new Random()).Next(Convert.ToInt32(SubString.Split(' ')[1].Split(',')[0]),Convert.ToInt32(SubString.Split(' ')[1].Split(',')[1])))));
                            System.Console.WriteLine(X);
                        }
                    }
                }
            }
            else if(Regex.IsMatch(X, "{GET[CMP]")){
                X = X.Replace("{GETCLIP}",(Cons.Clip.GetT()));
                X = X.Replace("{GETMOUSE}",(Cons.Curs.GPos().X.ToString()+","+Cons.Curs.GPos().Y.ToString()));
                while(Regex.IsMatch(X, "{GETCON ")){
                    foreach(string SubString in X.Split("{}".ToCharArray())){
                        if(Regex.IsMatch(SubString, "GETCON ")){
                            X = X.Replace(("{"+SubString+"}"),File.ReadAllText(SubString.Substring(7)));
                            System.Console.WriteLine(X);
                        }
                    }
                }

                if(Regex.IsMatch(X, "^{GETPIX [0-9]*,[0-9]*}$"))
                {
                    string PH = (X.Replace("{GETPIX ",""));
                    PH = PH.Substring(0,(PH.Length - 1));
                    string[] PHA = PH.Split(',');

                    DR.Rectangle Bounds = DR.Rectangle.FromLTRB(Convert.ToInt32(PHA[0]),Convert.ToInt32(PHA[1]),(Convert.ToInt32(PHA[0])+1),(Convert.ToInt32(PHA[1])+1));

                    DR.Bitmap BMP = new DR.Bitmap(Bounds.Width, Bounds.Height);
            
                    DR.Graphics GR = DR.Graphics.FromImage(BMP);
                    GR.CopyFromScreen(Bounds.Location, DR.Point.Empty, Bounds.Size);

                    X = BMP.GetPixel(0,0).Name.ToUpper();
            
                    GR.Dispose();
                    BMP.Dispose();
                }
            }
        }
        return X;
    }
}
'@

Function Interpret
{
    Param([String]$X)

    $X = [Parser]::Interpret($X)
    
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

            $Operands | %{$Index = 0}{If($_){$Operands[$Index] = ($_.Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',[N]::L).Replace('(NULL)','').Replace('(LBRACE)','{').Replace('(RBRACE)','}'))}; $Index++}
            
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
                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('^[0-9]*_'+$Operands[0]+'$')}).Count
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

            $Script:VarsHash.Remove($PHName)
            $Script:VarsHash.Add($PHName,$PHValue)
            
            $X = $X.Replace(('{'+$_+'}'),'')
        }
    }

    Return $X
}

Function Actions
{
    Param([String]$X)

    If(!$SyncHash.Stop)
    {
        [System.Console]::WriteLine($X)

        $X = (Interpret $X)

        If($X -match '^{POWER .*}$')
        {
            $X = ([ScriptBlock]::Create(($X -replace '^{POWER ' -replace '}$'))).Invoke()
        }

        If($X -match '^{TESSERACT .*}$')
        {
            $X = ([ScriptBlock]::Create(($X -replace '^{TESSERACT ' -replace '}$'))).Invoke()
        }

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
                If($_ -match 'M')
                {
                    $PH = [Int]($_ -replace ' M ')
                }
                ElseIf($_ -match ' ')
                {
                    $PH = [Int]($_ -replace ' ')*1000
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
                $Temp = ([Parser]::HoldKeys(($X.Split()[-1] -replace '}')))
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
                'MATCH'    {If($Op1 -match $Op2)       {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'EQ'       {If($Op1 -eq $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'LIKE'     {If($Op1 -like $Op2)        {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'LT'       {If($Op1 -lt $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'LE'       {If($Op1 -le $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'GT'       {If($Op1 -gt $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'GE'       {If($Op1 -ge $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'NOTMATCH' {If($Op1 -notmatch $Op2)    {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'NE'       {If($Op1 -ne $Op2)          {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
                'NOTLIKE'  {If($Op1 -notlike $Op2)     {$TComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}Else{$FComm.Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}}
            }
        }
        ElseIf($FuncHash.ContainsKey($X.Trim('{}').Split()[0]) -AND ($X -match '^{.*}'))
        {
            $(If($X -match ' '){1..([Int]($X.Split()[-1] -replace '\D'))}Else{1}) | %{$FuncHash.($X.Trim('{}').Split()[0]).Split([N]::L) | ?{$_ -ne ''} | %{Actions $_}}
        }
        ElseIf($X -match '^{REFOCUS}$')
        {
            $Script:Refocus = $True
        }
        ElseIf($X -match '^{CLEARVARS}$')
        {
            $Script:VarsHash = @{}
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
    $Script:Refocus = $False

    $Script:Vars = [String[]]@()

    $Script:VarsHash = @{}
    $Script:IfElHash = @{}
    $Script:FuncHash = @{}
    $UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}
    $SyncHash.Stop = $False

    $Commands.ReadOnly      = $True
    $FunctionsBox.ReadOnly  = $True
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

    $FunctionsBox.Text.Split([N]::L) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart(([Char][Int]9)).Replace('(SPACE)',' ')} | %{
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
                If($_ -match '^\\\\#>'){$Commented = $False}
                
                If($_ -notmatch '^\\\\#' -AND !$Commented)
                {
                    Actions $_
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

    If($Script:Refocus)
    {
        [Cons.App]::Act($Form.Text)
        $Form.Focus()
        $Commands.Focus()
        $Commands.SelectionLength = 0
        $Commands.SelectionStart = $Commands.Text.Length
    }
}

If($Host.Name -match 'Console')
{
    [Console]::Title = 'Pickle'

    [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
    [Void][Cons.WindowDisp]::Visual()
}

If(!(Test-Path ($env:APPDATA+'\Macro'))){[Void](MKDIR ($env:APPDATA+'\Macro') -Force)}
If(!(Test-Path ($env:APPDATA+'\Macro\Profiles'))){[Void](MKDIR ($env:APPDATA+'\Macro\Profiles') -Force)}

$Vars = [String[]]@()

$Script:Refocus = $False

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
    $TabPageCommLists = [GUI.TP]::New(0, 0, 0, 0,'Commands')
        $Commands = [GUI.RTB]::New(0, 0, 0, 0, '')
        $Commands.Dock = 'Fill'
        $Commands.Multiline = $True
        $Commands.WordWrap = $False
        $Commands.ScrollBars = 'Both'
        $Commands.AcceptsTab = $True
        $Commands.DetectUrls = $False
        $Commands.Add_TextChanged({
            If($Form.Text -notmatch '\*$')
            {
                $Form.Text+='*'
            }
            $This.Text | Out-File ($env:APPDATA+'\Macro\Commands.txt') -Width 1000 -Force
                    
            $TempSelectionIndex = $This.SelectionStart
            $This.SelectionStart = 0
            $This.SelectionLength = $This.Text.Length
            $This.SelectionColor = [System.Drawing.Color]::Black
            ($This.Lines | %{$Count = 0}{If($_.TrimStart(' ').TrimStart([Char][Int]9) -match '^\\\\#'){$Count};$Count++}) | %{$This.SelectionStart = $This.GetFirstCharIndexFromLine($_); $This.SelectionLength = $This.Lines[$_].Length; $This.SelectionColor = [System.Drawing.Color]::DarkGreen}
            $This.SelectionStart = $TempSelectionIndex
            $This.SelectionLength = 0
        })
        $Commands.Text = Try{(Get-Content ($env:APPDATA+'\Macro\Commands.txt') -ErrorAction SilentlyContinue).TrimEnd([N]::L) -join [N]::L}Catch{''}
        $Commands.Parent = $TabPageCommLists
        $Commands.Add_KeyDown({
            If($_.KeyCode.ToString() -eq 'F1')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '<\\# '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F2')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '\\#> '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F3')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '\\# '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F5')
            {
                $PH = [Cons.Curs]::GPos()

                $XCoord.Value = $PH.X
                $YCoord.Value = $PH.Y

                $This.SelectionLength = 0
                $This.SelectedText = ('{MOUSE '+((($PH).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}'+[N]::L)
            }
            ElseIf($_.KeyCode.ToString() -eq 'F6')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '{WAIT M 100}'
            }
            ElseIf($_.KeyCode.ToString() -eq 'F11')
            {
                If($Profile.Text -ne 'Working Profile: None/Prev Text Vals')
                {
                    $Form.Text = ($Form.Text -replace '\*$')

                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

                    [Void](MKDIR $TempDir)

                    $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                    $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                    $StatementsBox.Text | Out-File ($TempDir+'\Statements.txt') -Width 10000 -Force

                    $SaveAsProfText.Text = ''
                }
            }
            ElseIf($_.KeyCode.ToString() -eq 'F12')
            {
                $GO.PerformClick()
            }
        })
    $TabPageCommLists.Parent = $TabController

    $TabPageFunctions = [GUI.TP]::New(0, 0, 0, 0,'Functions')
        $FunctionsBox = [GUI.RTB]::New(0, 0, 0, 0, '')
        $FunctionsBox.Multiline = $True
        $FunctionsBox.WordWrap = $False
        $FunctionsBox.Scrollbars = 'Both'
        $FunctionsBox.AcceptsTab = $True
        $FunctionsBox.DetectUrls = $False
        $FunctionsBox.Add_TextChanged({
            If($Form.Text -notmatch '\*$')
            {
                $Form.Text+='*'
            }
            $This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 1000 -Force

            $TempSelectionIndex = $This.SelectionStart
            $This.SelectionStart = 0
            $This.SelectionLength = $This.Text.Length
            $This.SelectionColor = [System.Drawing.Color]::Black
            ($This.Lines | %{$Count = 0}{If($_.TrimStart(' ').TrimStart([Char][Int]9) -match '^\\\\#'){$Count};$Count++}) | %{$This.SelectionStart = $This.GetFirstCharIndexFromLine($_); $This.SelectionLength = $This.Lines[$_].Length; $This.SelectionColor = [System.Drawing.Color]::DarkGreen}
            $This.SelectionStart = $TempSelectionIndex
            $This.SelectionLength = 0
        })
        $FunctionsBox.Text = Try{(Get-Content ($env:APPDATA+'\Macro\Functions.txt') -ErrorAction SilentlyContinue).TrimEnd([N]::L) -join [N]::L}Catch{''}
        $FunctionsBox.Dock = 'Fill'
        $FunctionsBox.Parent = $TabPageFunctions
        $FunctionsBox.Add_KeyDown({
            If($_.KeyCode.ToString() -eq 'F1')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '<\\# '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F2')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '\\#> '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F3')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '\\# '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F5')
            {
                $PH = [Cons.Curs]::GPos()

                $XCoord.Value = $PH.X
                $YCoord.Value = $PH.Y

                $This.SelectionLength = 0
                $This.SelectedText = ('{MOUSE '+((($PH).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}'+[N]::L)
            }
            ElseIf($_.KeyCode.ToString() -eq 'F6')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '{WAIT M 100}'
            }
            ElseIf($_.KeyCode.ToString() -eq 'F11')
            {
                If($Profile.Text -ne 'Working Profile: None/Prev Text Vals')
                {
                    $Form.Text = ($Form.Text -replace '\*$')

                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

                    [Void](MKDIR $TempDir)
                    
                    $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                    $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                    $StatementsBox.Text | Out-File ($TempDir+'\Statements.txt') -Width 10000 -Force

                    $SaveAsProfText.Text = ''
                }
            }
            ElseIf($_.KeyCode.ToString() -eq 'F12')
            {
                $GO.PerformClick()
            }
        })
    $TabPageFunctions.Parent = $TabController

    $TabPageStatements = [GUI.TP]::New(0, 0, 0, 0,'Statements')
        $StatementsBox = [GUI.RTB]::New(0, 0, 0, 0, '')
        $StatementsBox.Multiline = $True
        $StatementsBox.WordWrap = $False
        $StatementsBox.Scrollbars = 'Both'
        $StatementsBox.AcceptsTab = $True
        $StatementsBox.DetectUrls = $False
        $StatementsBox.Add_TextChanged({
            If($Form.Text -notmatch '\*$')
            {
                $Form.Text+='*'
            }
            $This.Text | Out-File ($env:APPDATA+'\Macro\Statements.txt') -Width 1000 -Force

            $TempSelectionIndex = $This.SelectionStart
            $This.SelectionStart = 0
            $This.SelectionLength = $This.Text.Length
            $This.SelectionColor = [System.Drawing.Color]::Black
            ($This.Lines | %{$Count = 0}{If($_.TrimStart(' ').TrimStart([Char][Int]9) -match '^\\\\#'){$Count};$Count++}) | %{$This.SelectionStart = $This.GetFirstCharIndexFromLine($_); $This.SelectionLength = $This.Lines[$_].Length; $This.SelectionColor = [System.Drawing.Color]::DarkGreen}
            $This.SelectionStart = $TempSelectionIndex
            $This.SelectionLength = 0
        })
        $StatementsBox.Text = Try{(Get-Content ($env:APPDATA+'\Macro\Statements.txt') -ErrorAction SilentlyContinue).TrimEnd([N]::L) -join [N]::L}Catch{''}
        $StatementsBox.Dock = 'Fill'
        $StatementsBox.Parent = $TabPageStatements
        $StatementsBox.Add_KeyDown({
            If($_.KeyCode.ToString() -eq 'F1')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '<\\# '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F2')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '\\#> '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F3')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '\\# '
            }
            ElseIf($_.KeyCode.ToString() -eq 'F5')
            {
                $PH = [Cons.Curs]::GPos()

                $XCoord.Value = $PH.X
                $YCoord.Value = $PH.Y

                $This.SelectionLength = 0
                $This.SelectedText = ('{MOUSE '+((($PH).ToString().SubString(3) -replace 'Y=').TrimEnd('}'))+'}'+[N]::L)
            }
            ElseIf($_.KeyCode.ToString() -eq 'F6')
            {
                $This.SelectionLength = 0
                $This.SelectedText = '{WAIT M 100}'
            }
            ElseIf($_.KeyCode.ToString() -eq 'F11')
            {
                If($Profile.Text -ne 'Working Profile: None/Prev Text Vals')
                {
                    $Form.Text = ($Form.Text -replace '\*$')

                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

                    [Void](MKDIR $TempDir)

                    $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                    $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                    $StatementsBox.Text | Out-File ($TempDir+'\Statements.txt') -Width 10000 -Force

                    $SaveAsProfText.Text = ''
                }
            }
            ElseIf($_.KeyCode.ToString() -eq 'F12')
            {
                $GO.PerformClick()
            }
        })
    $TabPageStatements.Parent = $TabController

    $TabPageAdvanced = [GUI.TP]::New(0, 0, 0, 0,'Adv')
        $TabControllerAdvanced = [GUI.TC]::New(0, 0, 10, 10)
        $TabControllerAdvanced.Dock = 'Fill'
            $TabPageProfiles = [GUI.TP]::New(0, 0, 0, 0,'Load/Save')
                $Profile = [GUI.L]::New(250, 20, 10, 10, 'Working Profile: None/Prev Text Vals')
                $Profile.Parent = $TabPageProfiles

                $SavedProfilesLabel = [GUI.L]::New(120, 20, 10, 36, 'Saved Profiles:')
                $SavedProfilesLabel.Parent = $TabPageProfiles

                $SavedProfiles = [GUI.CB]::New(250, 25, 10, 60)
                $SavedProfiles.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                $SavedProfiles.Parent = $TabPageProfiles

                $QuickSave = [GUI.B]::New(75, 25, 10, 85, 'SAVE')
                $QuickSave.Add_Click({
                    If($Profile.Text -ne 'Working Profile: None/Prev Text Vals')
                    {
                        $Form.Text = ($Form.Text -replace '\*$')

                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

                        [Void](MKDIR $TempDir)

                        $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                        $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                        $StatementsBox.Text | Out-File ($TempDir+'\Statements.txt') -Width 10000 -Force

                        $SaveAsProfText.Text = ''
                    }
                })
                $QuickSave.Parent = $TabPageProfiles

                $LoadProfile = [GUI.B]::New(75, 25, 99, 85, 'LOAD')
                $LoadProfile.Add_Click({
                    If((Get-ChildItem ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem)).Count -gt 2)
                    {
                        $Profile.Text = ('Working Profile: ' + $(If($SavedProfiles.SelectedItem -ne $Null){$SavedProfiles.SelectedItem}Else{'None/Prev Text Vals'}))

                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem)

                        $Commands.Text = (Get-Content ($TempDir+'\Commands.txt') -Raw).TrimEnd([N]::L)
                        $FunctionsBox.Text = (Get-Content ($TempDir+'\Functions.txt') -Raw).TrimEnd([N]::L)
                        $StatementsBox.Text = (Get-Content ($TempDir+'\Statements.txt') -Raw).TrimEnd([N]::L)

                        $Form.Text = ('Pickle - ' + $SavedProfiles.SelectedItem)
                    }
                })
                $LoadProfile.Parent = $TabPageProfiles

                $BlankProfile = [GUI.B]::New(75, 25, 186, 85, 'BLANK')
                $BlankProfile.Add_Click({
                    $Profile.Text = 'Working Profile: None/Prev Text Vals'
                    
                    $SavedProfiles.SelectedIndex = -1

                    $Commands.Text = ''
                    $FunctionsBox.Text = ''
                    $StatementsBox.Text = ''

                    $Form.Text = ('Pickle')
                })
                $BlankProfile.Parent = $TabPageProfiles

                $SaveNewProfLabel = [GUI.L]::New(170, 20, 10, 170, 'Save Current Profile As:')
                $SaveNewProfLabel.Parent = $TabPageProfiles

                $SaveProfile = [GUI.B]::New(75, 20, 186, 189, 'SAVE AS')
                $SaveProfile.Add_Click({
                    If($SaveAsProfText.Text)
                    {
                        $Form.Text = ('Pickle - ' + $SaveAsProfText.Text)
                        $Profile.Text = ('Working Profile: ' + $SaveAsProfText.Text)

                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$SaveAsProfText.Text)

                        [Void](MKDIR $TempDir)

                        $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                        $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                        $StatementsBox.Text | Out-File ($TempDir+'\Statements.txt') -Width 10000 -Force

                        $SavedProfiles.Items.Clear()
                        [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                        $SavedProfiles.SelectedItem = $SaveAsProfText.Text

                        $SaveAsProfText.Text = ''
                    }
                })
                $SaveProfile.Parent = $TabPageProfiles

                $SaveAsProfText = [GUI.TB]::New(165, 25, 10, 190, '')
                $SaveAsProfText.Parent = $TabPageProfiles

                $DelProfLabel = [GUI.L]::New(170, 20, 10, 240, 'Delete Profile:')
                $DelProfLabel.Parent = $TabPageProfiles

                $DelProfile = [GUI.B]::New(75, 20, 186, 259, 'DELETE')
                $DelProfile.Add_Click({
                    If($Profile.Text -eq ('Working Profile: ' + $DelProfText.Text))
                    {
                        $Profile.Text = ('Working Profile: None/Prev Text Vals')
                        $SavedProfiles.SelectedItem = $Null

                        $Form.Text = ('Pickle')
                    }

                    (Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | ?{$_.Name -eq $DelProfText.Text} | Remove-Item -recurse -Force
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})

                    $DelProfText.Text = ''
                })
                $DelProfile.Parent = $TabPageProfiles

                $DelProfText = [GUI.TB]::New(165, 25, 10, 260, '')
                $DelProfText.Parent = $TabPageProfiles
            $TabPageProfiles.Parent = $TabControllerAdvanced

            $TabPageConfig = [GUI.TP]::New(0, 0, 0, 0, 'Settings')
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

                $OnTop = [GUI.ChB]::New(150, 25, 10, 185, 'Always On Top')
                $OnTop.Add_CheckedChanged({
                    $Form.TopMost = !$Form.TopMost
                })
                $OnTop.Parent = $TabPageConfig
            $TabPageConfig.Parent = $TabControllerAdvanced

            $TabPageDebug = [GUI.TP]::New(0, 0, 0, 0,'Debug/Helper')
                $GetMouseCoords = [GUI.B]::New(110, 25, 10, 25, 'Get Mouse Inf')
                $GetMouseCoords.Add_Click({
                    $InitialText = $This.Text
                    $This.Text = '3s'
                    $Form.Refresh()
                    [System.Threading.Thread]::Sleep(1000)
                    $This.Text = '2s'
                    $Form.Refresh()
                    [System.Threading.Thread]::Sleep(1000)
                    $This.Text = '1s'
                    $Form.Refresh()
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

                $MouseCoordsBox = [GUI.TB]::New(140, 25, 130, 25, '')
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

                $PixColorBox = [GUI.TB]::New(140, 25, 130, 75, '')
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

                $ClearVars = [GUI.B]::New(110, 25, 130, 160, 'Clear Vars')
                $ClearVars.Add_Click({$Script:VarsHash = @{}})
                $ClearVars.Parent = $TabPageDebug

                $ClearCons = [GUI.B]::New(230, 25, 10, 195, 'Clear Console')
                $ClearCons.Add_Click({Cls})
                $ClearCons.Parent = $TabPageDebug

                $OpenFolder = [GUI.B]::New(230, 25, 10, 230, 'Open Data Folder')
                $OpenFolder.Add_Click({Explorer ($env:APPDATA+'\Macro')})
                $OpenFolder.Parent = $TabPageDebug
            $TabPageDebug.Parent = $TabControllerAdvanced
        $TabControllerAdvanced.Parent = $TabPageAdvanced
    $TabPageAdvanced.Parent = $TabController
$TabController.Parent = $Form

$GO = [GUI.B]::New(300, 25, 25, 415, 'Start!')
$GO.Add_Click({GO})
$GO.Parent = $Form

$Form.Add_SizeChanged({
    $TabController.Size         = [GUI.SP]::SI((([Int]$This.Width)-65),(([Int]$This.Height)-95))
    $TabControllerAdvanced.Size = [GUI.SP]::SI((([Int]$TabController.Width)-30),(([Int]$TabController.Height)-50))
    $GO.Location                = [GUI.SP]::PO(25,(([Int]$This.Height)-80))
    $GO.Size                    = [GUI.SP]::SI((([Int]$This.Width)-65),25)
})

$Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',8.25,[System.Drawing.FontStyle]::Regular)}

If($Host.Name -match 'Console'){Cls}

$Config = New-Object PSObject
$Config = ($Config | Select `
    @{NAME='DelayTimeVal';EXPRESSION={0}},`
    @{NAME='DelayChecked';EXPRESSION={$False}},`
    @{NAME='DelayRandVal';EXPRESSION={0}},`

    @{NAME='CommTimeVal';EXPRESSION={0}},`
    @{NAME='CommChecked';EXPRESSION={$False}},`
    @{NAME='CommRandVal';EXPRESSION={0}},`

    @{NAME='ShowConsCheck';EXPRESSION={$False}},`
    @{NAME='OnTopCheck';EXPRESSION={$False}},`
    @{NAME='PrevProfile';EXPRESSION={$Null}}
)

Try
{
    $LoadedConfig = (Get-Content ($env:APPDATA+'\Macro\_Config_.json') -ErrorAction Stop | ConvertFrom-Json)

    $DelayTimer.Value        = $LoadedConfig.DelayTimeVal
    $DelayCheck.Checked      = $LoadedConfig.DelayChecked
    $DelayRandTimer.Value    = $LoadedConfig.DelayRandVal

    $CommandDelayTimer.Value = $LoadedConfig.CommTimeVal
    $CommDelayCheck.Checked  = $LoadedConfig.CommChecked
    $CommRandTimer.Value     = $LoadedConfig.CommRandVal

    $ShowCons.Checked        = $LoadedConfig.ShowConsCheck
    $OnTop.Checked           = $LoadedConfig.OnTopCheck

    If($LoadedConfig.PrevProfile)
    {
        $Profile.Text = ('Working Profile: ' + $LoadedConfig.PrevProfile)
        $Form.Text = ('Pickle - ' + $LoadedConfig.PrevProfile)
        $SavedProfiles.SelectedIndex = $SavedProfiles.Items.IndexOf($LoadedConfig.PrevProfile)
    }

    $ShowCons.Checked = !$ShowCons.Checked
    Sleep -Milliseconds 40
    $ShowCons.Checked = !$ShowCons.Checked

    $OnTop.Checked = !$OnTop.Checked
    Sleep -Milliseconds 40
    $OnTop.Checked = !$OnTop.Checked
}
Catch
{
    [System.Console]::WriteLine('No config file found or file could not be loaded!')
}

$Form.ShowDialog()
$UndoHash.KeyList | %{[Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)}

$SyncHash.Kill = $True

$Config.DelayTimeVal  = $DelayTimer.Value
$Config.DelayChecked  = $DelayCheck.Checked
$Config.DelayRandVal  = $DelayRandTimer.Value

$Config.CommTimeVal   = $CommandDelayTimer.Value
$Config.CommChecked   = $CommDelayCheck.Checked
$Config.CommRandVal   = $CommRandTimer.Value

$Config.ShowConsCheck = $ShowCons.Checked
$Config.OnTopCheck    = $OnTop.Checked

If($Profile.Text -ne 'Working Profile: None/Prev Text Vals')
{
    $Config.PrevProfile = ($Profile.Text -replace '^Working Profile: ')
    
    $Form.Text = ($Form.Text -replace '\*$')

    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

    [Void](MKDIR $TempDir)

    $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
    $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
    $StatementsBox.Text | Out-File ($TempDir+'\Statements.txt') -Width 10000 -Force

    $SaveAsProfText.Text = ''
}
Else
{
    $Config.PrevProfile = $Null
}

$Config | ConvertTo-Json | Out-File ($env:APPDATA+'\Macro\_Config_.json') -Width 1000 -Force

If($Host.Name -match 'Console'){Exit}
}

If($PSVersionTable.CLRVersion.Major -le 2)
{
    $MainBlock = [ScriptBlock]::Create(($MainBlock.toString().Split([System.Environment]::NewLine) | %{$FlipFlop = $True}{If($FlipFLop){$_}; $FlipFlop = !$FlipFlop} | %{If($_ -match '::New\('){($_.Split('[')[0]+'(New-Object '+$_.Split('[')[-1]+')') -replace ']::New',' -ArgumentList '}Else{$_}}) -join [System.Environment]::NewLine)
}

$MainBlock.Invoke()