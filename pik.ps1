#Some C# code that I use as wrapper class for System.Windows.Forms (for easy instantiation) as well as a collection of imported functions from other dlls
#Eventually should move to entirely C# invoked by Powershell and some of the migration is done below (the interpret method in the parser class)
$CSharpDef = @'
using System;
using System.IO;
using System.Text;
using System.Reflection;
using System.Diagnostics;
using System.Configuration;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using DR = System.Drawing;
using SWF = System.Windows.Forms;

namespace Cons{
    public class Act{
        public static Object CrI (Type type, params Object[] args){
            return System.Activator.CreateInstance(type, args);
        }
    }

    public class MouseEvnt{
        [DllImport("user32.dll")]
        public static extern void mouse_event(Int64 dwFlags, Int64 dx, Int64 dy, Int64 cButtons, Int64 dwExtraInfo);
    }
    public class KeyEvnt{
        [DllImport("user32.dll")]
        public static extern void keybd_event(Byte bVk, Byte bScan, Int64 dwFlags, Int64 dwExtraInfo);
    }
    public class WindowMessages{
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
        public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
        public static extern IntPtr PostMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);
    }
    public class WindowDisp{
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out DR.Rectangle lpRect);
        [DllImport("User32.dll")]
        public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
        [DllImport("User32.dll")]
        public extern static bool SetWindowText(IntPtr handle, string text);
        [DllImport("User32.dll")]
        public extern static int GetWindowText(IntPtr handle, StringBuilder text, int length);
        [DllImport("User32.dll")]
        public extern static int GetWindowTextLength(IntPtr handle);
        
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
        public static string GetT ()           {return SWF.Clipboard.GetText();}
        public static void SetT (string Text)  {SWF.Clipboard.SetText(Text);}
    }
    public class Curs{
        public static DR.Point GPos ()         {return SWF.Cursor.Position;}
        public static void SPos (int x, int y) {SWF.Cursor.Position = new DR.Point(x, y);}
    }
    public class Send{
    	public static void SetConfig ()        {System.Configuration.ConfigurationManager.AppSettings.Set("SendKeys","SendInput");}
	public static string Check ()          {return System.Configuration.ConfigurationManager.AppSettings["SendKeys"].ToString();}
        public static void Keys (string Keys)  {SWF.SendKeys.SendWait(Keys);}
    }
    public class Writer{
        public static void WriteLine (string Line, System.ConsoleColor Back, System.ConsoleColor Fore){
            System.Console.BackgroundColor = Back;
            System.Console.ForegroundColor = Fore;
            System.Console.WriteLine(Line);
            System.Console.ResetColor();
        }
        public static void WriteLine (string Line){
            System.Console.WriteLine(Line);
        }
    }
}
namespace Img{
    public class Find{
        public static System.Collections.Generic.List<DR.Point> GetSubPositions(DR.Bitmap main, DR.Bitmap sub) {
            System.Collections.Generic.List<DR.Point> possiblepos = new System.Collections.Generic.List<DR.Point>();
            int mainwidth = main.Width;
            int mainheight = main.Height;
            int subwidth = sub.Width;
            int subheight = sub.Height;
            int movewidth = mainwidth - subwidth;
            int moveheight = mainheight - subheight;
            DR.Imaging.BitmapData bmMainData = main.LockBits(new DR.Rectangle(0, 0, mainwidth, mainheight), DR.Imaging.ImageLockMode.ReadWrite, DR.Imaging.PixelFormat.Format32bppArgb);
            DR.Imaging.BitmapData bmSubData = sub.LockBits(new DR.Rectangle(0, 0, subwidth, subheight), DR.Imaging.ImageLockMode.ReadWrite, DR.Imaging.PixelFormat.Format32bppArgb);
            int bytesMain = Math.Abs(bmMainData.Stride) * mainheight;
            int strideMain = bmMainData.Stride;
            System.IntPtr Scan0Main = bmMainData.Scan0;
            byte[] dataMain = new byte[bytesMain];
            System.Runtime.InteropServices.Marshal.Copy(Scan0Main, dataMain, 0, bytesMain);
            int bytesSub = Math.Abs(bmSubData.Stride) * subheight;
            int strideSub = bmSubData.Stride;
            System.IntPtr Scan0Sub = bmSubData.Scan0;
            byte[] dataSub = new byte[bytesSub];
            System.Runtime.InteropServices.Marshal.Copy(Scan0Sub, dataSub, 0, bytesSub);
            for (int y = 0; y < moveheight; ++y) {
                for (int x = 0; x < movewidth; ++x) {
                    MyColor curcolor = GetColor(x, y, strideMain, dataMain);
                    foreach (DR.Point item in possiblepos.ToArray()) {
                        int xsub = x - item.X;
                        int ysub = y - item.Y;
                        if (xsub >= subwidth || ysub >= subheight || xsub < 0)
                            continue;
                        MyColor subcolor = GetColor(xsub, ysub, strideSub, dataSub);
                        if (!curcolor.Equals(subcolor)) {
                            possiblepos.Remove(item);
                        }
                    }
                    if (curcolor.Equals(GetColor(0, 0, strideSub, dataSub)))
                        possiblepos.Add(new DR.Point(x, y));
                }
            }
            System.Runtime.InteropServices.Marshal.Copy(dataSub, 0, Scan0Sub, bytesSub);
            sub.UnlockBits(bmSubData);
            System.Runtime.InteropServices.Marshal.Copy(dataMain, 0, Scan0Main, bytesMain);
            main.UnlockBits(bmMainData);
            return possiblepos;
        }
        private static MyColor GetColor(DR.Point point, int stride, byte[] data) {
            return GetColor(point.X, point.Y, stride, data);
        }
        private static MyColor GetColor(int x, int y, int stride, byte[] data) {
            int pos = y * stride + x * 4;
            byte a = data[pos + 3];
            byte r = data[pos + 2];
            byte g = data[pos + 1];
            byte b = data[pos + 0];
            return MyColor.FromARGB(a, r, g, b);
        }
        struct MyColor {
            byte A;
            byte R;
            byte G;
            byte B;
            public static MyColor FromARGB(byte a, byte r, byte g, byte b) {
                MyColor mc = new MyColor();
                mc.A = a;
                mc.R = r;
                mc.G = g;
                mc.B = b;
                return mc;
            }
            public override int GetHashCode(){
                return this.GetHashCode();
            }
            public override bool Equals(object obj) {
                if (!(obj is MyColor))
                    return false;
                MyColor color = (MyColor)obj;
                if(color.A == this.A && color.R == this.R && color.G == this.G && color.B == this.B)
                    return true;
                return false;
            }
        }
    }
}
namespace GUI{
    public class SP{
        public static DR.Point PO (int sx, int sy) {return (new DR.Point(sx, sy));}
        public static DR.Size SI (int sx, int sy)  {return (new DR.Size(sx, sy));}
    }
    public class F : SWF.Form{
        public F (){}
        public F (int sx, int sy, string tx)                   {this.Size = new DR.Size(sx,sy);this.Text = tx;}
    }
    public class TC : SWF.TabControl{
        public TC (){}
        public TC (int sx, int sy, int lx, int ly)             {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class P : SWF.Panel{
        public P (){}
        public P (int sx, int sy, int lx, int ly)              {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class LB : SWF.ListBox{
        public LB (){}
        public LB (int sx, int sy, int lx, int ly)             {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class CoB : SWF.ComboBox{
        public CoB (){}
        public CoB (int sx, int sy, int lx, int ly)            {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class NUD : SWF.NumericUpDown{
        public NUD (){}
        public NUD (int sx, int sy, int lx, int ly)            {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class GB : SWF.GroupBox{
        public GB (){}
        public GB (int sx, int sy, int lx, int ly, string tx)  {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class TP : SWF.TabPage{
        public TP (){}
        public TP (int sx, int sy, int lx, int ly, string tx)  {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class L : SWF.Label{
        public L (){}
        public L (int sx, int sy, int lx, int ly, string tx)   {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class TB : SWF.TextBox{
        public TB (){}
        public TB (int sx, int sy, int lx, int ly, string tx)  {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class RTB : SWF.RichTextBox{
        public RTB (){}
        public RTB (int sx, int sy, int lx, int ly, string tx) {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class MTB : SWF.MaskedTextBox{
        public MTB (){}
        public MTB (int sx, int sy, int lx, int ly, string tx) {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class B : SWF.Button{
        public B (){}
        public B (int sx, int sy, int lx, int ly, string tx)   {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class RB : SWF.RadioButton{
        public RB (){}
        public RB (int sx, int sy, int lx, int ly, string tx)  {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class ChB : SWF.CheckBox{
        public ChB (){}
        public ChB (int sx, int sy, int lx, int ly, string tx) {this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class Rect{
        public static DR.Rectangle E = DR.Rectangle.Empty;
        public static DR.Rectangle R (int lx, int ly, int sx, int sy){
            return (new DR.Rectangle(lx, ly, sx, sy));
        }
    }
    public class ScreenInfo{
        public static SWF.Screen[] All = SWF.Screen.AllScreens;
    }
}
public class Parser{
    public static string HoldKeys(string X){
        X = X.ToUpper();
        if(Regex.IsMatch(X, "NUM") && X.Length == 4){
            return ("&H6"+X.Replace("NUM",""));
        }else if(X.Length == 1){
            return ("&H"+Convert.ToString(Convert.ToInt32(Convert.ToChar(X)), 16)).ToUpper();
        }else if(Regex.IsMatch(X, "^F[1-9]+[0-6]?")){
            return ("&H7"+Convert.ToString((Convert.ToInt32(X.Replace("F","")) - 1), 16)).ToUpper();
        }else{
            switch(X){
                case "CLEAR":       return "&H0C";
                case "ENTER":       return "&H0D";
                case "CANCEL":      return "&H03";
                case "BACKSPACE":   return "&H08";
                case "TAB":         return "&H09";
                case "SHIFT":       return "&H10";
                case "CTRL":        return "&H11";
                case "ALT":         return "&H12";
                case "PAUSE":       return "&H13";
                case "CAPSLOCK":    return "&H14";
                case "ESC":         return "&H1B";
                case "SPACEBAR":    return "&H20";
                case "PAGEUP":      return "&H21";
                case "PAGEDOWN":    return "&H22";
                case "END":         return "&H23";
                case "HOME":        return "&H24";
                case "LEFTARROW":   return "&H25";
                case "UPARROW":     return "&H26";
                case "RIGHTARROW":  return "&H27";
                case "DOWNARROW":   return "&H28";
                case "SELECT":      return "&H29";
                case "EXECUTE":     return "&H2B";
                case "PRINTSCREEN": return "&H2C";
                case "INS":         return "&H2D";
                case "DEL":         return "&H2E";
                case "HELP":        return "&H2F";
                case "NUMLOCK":     return "&H90";
                case "NUMMULT":     return "&H6A";
                case "NUMPLUS":     return "&H6B";
                case "NUMENTER":    return "&H6C";
                case "NUMMINUS":    return "&H6D";
                case "NUMPOINT":    return "&H6E";
                case "NUMDIV":      return "&H6F";
                case "WINDOWS":     return "&H5B";
                default:            return "&H60";
            }
        }
    }
    public static string Interpret(string X){
        if(Regex.IsMatch(X.ToUpper(), "{[CPSDGRMW]")){
            if(Regex.IsMatch(X, "{COPY}") || Regex.IsMatch(X, "{PASTE}") || Regex.IsMatch(X, "{SELECTALL}")){
                X = (X.Replace("{COPY}","(^c)"));
                X = (X.Replace("{PASTE}","(^v)"));
                X = (X.Replace("{SELECTALL}","(^a)"));
            }
            if(Regex.IsMatch(X, "{PID}")){
                X = (X.Replace("{PID}",(Process.GetCurrentProcess().Id.ToString())));
            }
            if(Regex.IsMatch(X, "{WHOAMI}")){
                X = (X.Replace("{WHOAMI}",(Environment.UserDomainName.ToString()+"\\"+Environment.UserName.ToString())));
            }
            if(Regex.IsMatch(X, "{DATETIME") || Regex.IsMatch(X, "{RAND") || Regex.IsMatch(X, "{SPACE")){
                X = (X.Replace("{DATETIME}",DateTime.Now.ToString()));
		        X = (X.Replace("{DATETIMEUTC}",DateTime.Now.ToFileTimeUtc().ToString()));
                while(Regex.IsMatch(X, "{SPACE")){
                    foreach(string SubString in X.Split("{}".ToCharArray())){
                        if(Regex.IsMatch(SubString, "SPACE")){
                            X = X.Replace(("{"+SubString+"}"),(new string (' ', Convert.ToInt32(Regex.Replace(SubString, "^SPACE$", "SPACE 1").Split(' ')[1]))));
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
            if(Regex.IsMatch(X, "{GETCLIP}") || Regex.IsMatch(X, "{GETMOUSE}")){
                DR.Point Coords = Cons.Curs.GPos();
                if(Regex.IsMatch(X, "{GETCLIP}")){X = X.Replace("{GETCLIP}",(Cons.Clip.GetT()));}
                if(Regex.IsMatch(X, "{GETMOUSE}")){X = X.Replace("{GETMOUSE}",(Coords.X.ToString()+","+Coords.Y.ToString()));}
            }
        }
        return X;
    }
}
'@
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic,System.Configuration,System.Reflection -IgnoreWarnings -TypeDefinition $CSharpDef
###########################################################################################
             #######                                                           
             #        #    #  #    #   ####   #####  #   ####   #    #   ####  
             #        #    #  ##   #  #    #    #    #  #    #  ##   #  #      
             #####    #    #  # #  #  #         #    #  #    #  # #  #   ####  
             #        #    #  #  # #  #         #    #  #    #  #  # #       # 
             #        #    #  #   ##  #    #    #    #  #    #  #   ##  #    # 
             #         ####   #    #   ####     #    #   ####   #    #   ####  
###########################################################################################
#Major functions are located here the all call each other and are organized like so:
<#
    "GO" is the main function called to action on button click or F-Key press, contains a lot of instancing and cleanup prior to each run as well as macro function parsing
     |
     ---> "Parse-While" used to look ahead to determine while loop behavior, which then feeds back into itself if a true condition is met, then hands the lines off to Parse-IfEl otherwise
           |
           ---> "Parse-IfEl" used to parse the IF statements and look ahead to determine behavior from there, this will loop back into Parse-While to handle nested while and if statements correctly before handing off to actions
                 |
                 ---> "[Parser]::Interpret" Ultimately where everything will reside, but for now a place where extremely simple find/replace keywords can get parsed and is completed first.
                       |
                       ---> "Interpret" Gets called before any actions (though if statetments and while true/false conditions take precedence). The purpose is to make substitutions such as var substitutions or getting content (i.e. values are known)
                             |
                             ---> "Actions" is called to check each line as it comes in and is the collection of keywords for performing actual actions on the machine (i.e. not just simple substitution or "Get" style keywords)
#>
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
        
        If($X -match '^{POWER .*}$'){
            If(!$WhatIf){
                [Void]([ScriptBlock]::Create(($X -replace '^{POWER ' -replace '}$'))).Invoke()
                $X = ''
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: CREATE A SCRIPTBLOCK OF '+($X -replace '^{POWER ' -replace '}$'))}
            }
        }ElseIf($X -match '^{CMD .*}$'){
            If(!$WhatIf){
                [Void]([ScriptBlock]::Create('CMD /C'+($X -replace '^{CMD ' -replace '}$'))).Invoke()
                $X = ''
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: CREATE A SCRIPTBLOCK OF '+($X -replace '^{CMD ' -replace '}$'))}
            }
        }ElseIf($X -match '{PAUSE'){
            If($CommandLine -OR ($ShowCons.Checked -AND ($X -notmatch '{PAUSE -GUI}'))){
                If($ShowCons.Checked){[System.Console]::WriteLine('PRESS ANY KEY TO CONTINUE...')}
                [Void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            }Else{
                [Void][System.Windows.Forms.MessageBox]::Show('PAUSED - Close this box to continue...','PAUSED',0,64)
            }
            
            $X = $X.Replace('{PAUSE}','').Replace('{PAUSE -GUI}','')
        }ElseIf($X -match '^{FOREACH '){
            $PH = ($X.Substring(0, $X.Length - 1) -replace '^{FOREACH ').Split(',')
            $Script:VarsHash.Keys.Clone() | ?{$_ -match ('^[0-9]*_' + $PH[1])} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{
                $Script:VarsHash.Remove($PH[0])
                $Script:VarsHash.Add($PH[0],$Script:VarsHash.$_)
                    
                If(!$WhatIf){
                    [Void](Parse-While $PH[2])
                }Else{
                    [Void](Parse-While $PH[2] -WhatIf)
                }
            }
            $Script:VarsHash.Remove($PH[0])
        }ElseIf($X -match '^{SETCON'){
            $PHFileName = ($X.Substring(8)).Split(',')[0].TrimStart(' ')
            $PHFileContent = (($X -replace '^{SETCONA? ').Replace(($PHFileName+','),'') -replace '}$')
            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WRITING '+$PHFileContent+' TO FILE '+$PHFileName)}
            If(!$WhatIf){
                If($X -notmatch '^{SETCONA '){
                    $PHFileContent | Out-File $PHFileName -Encoding UTF8 -Force
                }Else{
                    $PHFileContent | Out-File $PHFileName -Encoding UTF8 -Append -Force
                }
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: WRITE '+$PHFileContent+' TO FILE '+$PHFileName)}
            }
        }ElseIf($X -match '{SETCLIP '){
            $X.Split('{}') | ?{$_ -match 'SETCLIP '} | %{
                If(!$WhatIf){[Cons.Clip]::SetT($_.Substring(8))}Else{If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SET CLIPBOARD TO '+$_.Substring(8))}}
                $X = ($X -replace ('{'+$_+'}'))
            }
        }ElseIf($X -match '{BEEP '){
            $X.Split('{}') | ?{$_ -match 'BEEP '} | %{
                $Tone = [Int](($_ -replace 'BEEP ').Split(',')[0])
                $Time = [Int](($_ -replace 'BEEP ').Split(',')[1])
                If(!$WhatIf){[System.Console]::Beep($Tone,$Time)}Else{If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: BEEP FOR '+$Time+' AT '+$Tone)}}
                $X = ($X -replace ('{'+$_+'}'))
            }
        }ElseIf($X -match '{FLASH'){
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
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: FLASH '+$Flashes+' TIMES')}
                }
                $X = ($X -replace ('{'+$_+'}'))
            }
        }ElseIf($X -match '{WAIT ?(-M )?\d*}'){
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
        }ElseIf($X -match '{[/\\]?HOLD'){
            $Rel = ($X -match '[/\\]')
            If(!$WhatIf){
                If($X -match 'MOUSE'){
                    $Temp = ($X.Split()[-1] -replace '}')
                    $UndoHash.KeyList+=([String]$Temp)
                    [Int]($X.Split()[-1] -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{[Cons.MouseEvnt]::mouse_event(($(If($Rel){$_*2}Else{$_})), 0, 0, 0, 0)}
                }Else{
                    $Temp = ([Parser]::HoldKeys(($X.Split()[-1] -replace '}')))
                    $UndoHash.KeyList+=([String]$Temp)
                    [Cons.KeyEvnt]::keybd_event($Temp, 0, $(If($Rel){'&H2'}Else{0}), 0)
                }
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine(($Tab+'WHATIF: '+$(If($Rel){'RELEASE'}ELSE{'HOLD'})+' '+($X.Split()[-1] -replace '}')))}
            }
        }ElseIf($X -match '^{[LRM]?MOUSE'){
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
                    $Coords = [Cons.Curs]::GPos()
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
                        $Random = ([Cons.Act]::CrI([System.Random],@()))
                            
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
                            $Coords = [Cons.Curs]::GPos()
                            $PHTMPCoords = $Coords
                            
                            If($Right) {$PHTMPCoords.X = ($PHTMPCoords.X+$OffsetX)}Else{$PHTMPCoords.X = ($PHTMPCoords.X-$OffsetX)}
                            If($Down)  {$PHTMPCoords.Y = ($PHTMPCoords.Y+$OffsetY)}Else{$PHTMPCoords.Y = ($PHTMPCoords.Y-$OffsetY)}
                                
                            $j = $Coords.X
                            $k = $Coords.Y
                            While(($j -ne $PHTMPCoords.X -OR $k -ne $PHTMPCoords.Y) -AND !$SyncHash.Stop){
                                If($j -lt $PHTMPCoords.X){$j++}ElseIf($j -gt $PHTMPCoords.X){$j--}
                                If($k -lt $PHTMPCoords.Y){$k++}ElseIf($k -gt $PHTMPCoords.Y){$k--}
                                [Cons.Curs]::SPos($j,$k)
                            }
                            $RemainderX = $OffsetX - [Math]::Round($OffsetX)
                            $RemainderY = $OffsetY - [Math]::Round($OffsetY)
                            If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                        }
                        If(!$SyncHash.Stop){
                            While(($j -ne [Math]::Round($MoveCoords[0]) -OR $k -ne [Math]::Round($MoveCoords[1])) -AND !$SyncHash.Stop){
                                If($j -lt [Math]::Round($MoveCoords[0])){$j++}ElseIf($j -gt [Math]::Round($MoveCoords[0])){$j--}
                                If($k -lt [Math]::Round($MoveCoords[1])){$k++}ElseIf($k -gt [Math]::Round($MoveCoords[1])){$k--}
                                [Cons.Curs]::SPos($j,$k)
                            }
                            If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                        }
                    }Else{
                        [Cons.Curs]::SPos($MoveCoords[0],$MoveCoords[1])
                    }
                }ElseIf($X -match ' '){
                    0..([Int](($X -replace '}').Split(' ')[-1])) | %{
                        [Int]($X.Split(' ')[0] -replace '{' -replace 'MOUSE' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{
                            [Cons.MouseEvnt]::mouse_event($_, 0, 0, 0, 0)
                        }
                    }
                }Else{
                    [Int]($X -replace '{' -replace 'MOUSE}' -replace 'L',2 -replace 'R',8 -replace 'M',32) | %{$_,$($_*2)} | %{
                        [Cons.MouseEvnt]::mouse_event($_, 0, 0, 0, 0)
                    }
                }
            }Else{
                If($X -match ','){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: MOVE MOUSE TO '+($X -replace '{MOUSE ' -replace '}'))}
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: CLICK '+($X -replace '{MOUSE ' -replace '}'))}
                }
            }
        }ElseIf($X -match 'WINDOWS}'){
            If(!$WhatIf){
                Switch($X){
                    '{WINDOWS}'  {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5B', 0, $(If($_){'&H2'}Else{0}), 0)}; [System.Threading.Thread]::Sleep(40)}
                    '{LWINDOWS}' {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5B', 0, $(If($_){'&H2'}Else{0}), 0)}; [System.Threading.Thread]::Sleep(40)}
                    '{RWINDOWS}' {0..1 | %{[Cons.KeyEvnt]::keybd_event('&H5C', 0, $(If($_){'&H2'}Else{0}), 0)}; [System.Threading.Thread]::Sleep(40)}
                }
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: PRESS WINDOWS KEY')}
            }
        }ElseIf($X -match '^{RESTART}$'){
            $SyncHash.Restart = $True
        }ElseIf($X -match '^{REFOCUS}$'){
            $Script:Refocus = $True
        }ElseIf($X -match '^{CLEARVAR'){
            If($X -match '^{CLEARVARS}$'){
                $Script:VarsHash = @{}
            }Else{
                $Script:VarsHash.Remove(($X.Substring(0, $X.Length - 1) -replace '^{CLEARVAR '))
            }
        }ElseIf($X -match '^{QUIT}$'){
            $SyncHash.Stop = $True
        }ElseIf($X -match '^{EXIT}$'){
            $SyncHash.Stop = $True
        }ElseIf($X -match '^{CD '){
            CD ($X -replace '{CD ' -replace '}$')
            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'CHANGING DIRECTORY TO '+($X -replace '{CD ' -replace '}$'))}
        }ElseIf($X -match '^{REMOTE '){
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
                    $PHClient = ([Cons.Act]::CrI([System.Net.Sockets.TcpClient],@($PHIP,$PHPort)))
                    $PHStream = $PHClient.GetStream()
                    $PHStream.Write($Buffer, 0, $Buffer.Length)
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'SENT THE FOLLOWING TO '+$PHIP+':'+$PHPort)}
                    If($ShowCons.Checked){$PHSendString.Split($NL) | %{$FlipFlop = $True}{If($FlipFlop){[System.Console]::WriteLine(($Tab*2)+$_)};$FlipFlop=!$FlipFlop}}
                    $MaxTime = [Int]$CliTimeOut.Value
                    $PHResp = ''
                    $Timeout = 1
                    While(($PHResp -notmatch '{COMPLETE}') -AND !$SyncHash.Stop -AND ($Timeout -lt $MaxTime) -AND ($PHSendString -ne '{SERVERSTOP}')){
                        $PHMsg = ('WAITING FOR REMOTE END COMPLETION... '+$Timeout+'/'+$MaxTime)
                        If($ShowCons.Checked -AND !($Timeout % 3)){
                            If($Host.Name -match 'Console'){
                                [System.Console]::CursorLeft = 4
                                [System.Console]::Write($PHMsg)
                            }Else{
                                [System.Console]::WriteLine($Tab+$PHMsg)
                            }
                        }
                        $Buff = New-Object Byte[] 1024
                        While($PHStream.DataAvailable){
                            $Buff = New-Object Byte[] 1024
                            [Void]$PHStream.Read($Buff, 0, 1024)
                            $PHResp+=([System.Text.Encoding]::UTF8.GetString($Buff))
                        }
                        [System.Threading.Thread]::Sleep(1000)
                        $Timeout++
                        If($PHResp -eq '{KEEPALIVE}'){$Timeout = 0}
                    }
                    [System.Console]::WriteLine('')
                    If($PHResp -match '{COMPLETE}'){If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'COMPLETED!')}}
                    If($Timeout -ge $MaxTime){If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'TIMED OUT WAITING FOR REMOTE END!')}}
                    $PHStream.Close()
                    $PHStream.Dispose()
                    $PHClient.Close()
                    $PHClient.Dispose()
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: WOULD SEND THE FOLLOWING TO '+$PHIP+':'+$PHPort)}
                    If($ShowCons.Checked){$PHSendString.Split($NL) | %{$FlipFlop = $True}{If($FlipFlop){[System.Console]::WriteLine($Tab+$_)};$FlipFlop=!$FlipFlop}}
                }
            }Catch{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'ERROR! FAILED SEND TO '+$PHIP+':'+$PHPort)}
            }
        }ElseIf($X -match '^{SCRNSHT '){
            $PH = ($X -replace '{SCRNSHT ')
            $PH = $PH.Substring(0,($PH.Length - 1))
            $PH = $PH.Split(',')
            If(!$WhatIf){
                $Bounds = [GUI.Rect]::R($PH[0],$PH[1],$PH[2],$PH[3])
                $BMP = ([Cons.Act]::CrI([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
            
                $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
                $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.size)
            
                $BMP.Save($PH[4])
            
                $Graphics.Dispose()
                $BMP.Dispose()
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: TAKE SCREENSHOT AT TOP-LEFT ('+$PH[0]+','+$PH[1]+') TO BOTTOM-RIGHT ('+$PH[2]+','+$PH[3]+')')}
            }
        }ElseIf($Script:FuncHash.ContainsKey($X.Trim('{}').Split()[0]) -AND ($X -match '^{.*}')){
            $(If($X -match ' '){1..([Int]($X.Split()[-1] -replace '\D'))}Else{1}) | %{
                $Script:FuncHash.($X.Trim('{}').Split()[0]).Split($NL) | %{
                    ($_ -replace ('`'+$NL),'' -replace '^\s*' | ?{$_ -ne ''})
                } | %{$Commented = $False}{
                    If($_ -match '^<\\\\#'){$Commented = $True}
                    If($_ -match '^\\\\#>'){$Commented = $False}
                    If($_ -notmatch '^\\\\#' -AND !$Commented){$_}Else{If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$_)}}
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
        }ElseIf(($X -match '{FOCUS ') -OR ($X -match '{SETWIND ') -OR ($X -match '{MIN ') -OR ($X -match '{MAX ') -OR ($X -match '{HIDE ') -OR ($X -match '{SHOW ') -OR ($X -match '{SETWINDTEXT ')){
            $PHProc = $X
            If($PHProc -match ','){$PHProc = $PHProc.Split(',')[0]}
                
            $TrueHand = $False
            Try{
                If($X -match ' -ID '){
                    $PHProc = ($PHProc.Split(' ') | ?{$_ -ne ''})[2].Replace('{','').Replace('}','')
                    If(($Script:HiddenWindows.Keys -join '')){
                        $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProc+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                        $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProc+'_.*?_'+$LastHiddenTime+'$')})
                    }
                    $PHProc = (PS -Id $PHProc | ?{$_.MainWindowHandle -ne 0})
                    If($PHProc){$PHHidden = ''}
                }ElseIf($X -match ' -HAND '){
                    $PHProcHand = ($PHProc.Split(' ') | ?{$_ -ne ''})[2].Replace('{','').Replace('}','')
                    #If(($Script:HiddenWindows.Keys -join '')){
                    #    $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                    #    $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_'+$LastHiddenTime+'$')})
                    #}
                    $PHProc = (PS | ?{[String]$_.MainWindowHandle -match $PHProcHand})
                    If($PHProc){
                        $PHHidden = ''
                    }Else{
                        $TrueHand = $True
                        Try{
                            $PHProcHand = [IntPtr][Int]$PHProcHand
                            $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHProcHand)
                            $PHString = ([Cons.Act]::CrI([System.Text.StringBuilder],@(($PHTextLength + 1))))
                            [Void]([Cons.WindowDisp]::GetWindowText($PHProcHand, $PHString, $PHString.Capacity))
                            If(!$PHString){
                                $PHProc = ''
                                $PHHidden = ''
                            }Else{
                                $PHHidden = $PHProcHand
                            }
                        }Catch{$PHProc = ''; $PHHidden = ''}
                    }
                }Else{
                    $PHProcTMPName = $PHProc.Replace('{FOCUS ','').Replace('{SETWINDTEXT ','').Replace('{SETWIND ','').Replace('{MIN ','').Replace('{MAX ','').Replace('{HIDE ','').Replace('{SHOW ','').Replace('}','')
                    If(($Script:HiddenWindows.Keys -join '')){
                        $PHHidden = (($Script:HiddenWindows.Keys | ?{$_ -match ('^'+$PHProcTMPName+'_')}) | %{$Script:HiddenWindows.$_})
                    }
                    Try{$PHProc = @(PS $PHProcTMPName -ErrorAction Stop | ?{$_.MainWindowHandle -ne 0})}Catch{$PHProc = $False}
                    If(!$PHProc){$PHProc = @(PS | ?{$_.Id -notmatch $SyncHash.MouseIndPid} | ?{$_.MainWindowTitle -match $PHProcTMPName})}
                }
            }Catch{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'ERROR: FAILED DURING FIND PROC, KILLING MACRO TO AVOID CAUSING DAMAGE')}
                $SyncHash.Stop = $True
                Break
            }
            If($PHHidden){$PHProc+=$PHHidden}
            If(@($PHProc).Count){
                If(!$WhatIf){
                    $PHProc | %{
                        If($TrueHand){
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
                                    If(!$TrueHand){[Void][Cons.App]::Act($PHTMPProcTitle)}Else{[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,9)}
                                }Catch{
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'COULD NOT FIND TRUE HAND STATUS: '+([Boolean]$TrueHand).ToString().ToUpper()+', PROC TITLE: '+$PHTMPProcTitle+', HANDLE: '+$PHTMPProcHand)}
                                }
                            }
                            'MIN'         {[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,6)}
                            'MAX'         {[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,3)}
                            'SHOW'        {[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,9)}
                            'HIDE'        {
                                [Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,0)
                                If(!$TrueHand){
                                    $Script:HiddenWindows.Add(($PHTMPProc.Name+'_'+$PHTMPProc.Id+'_'+$PHTMPProcHand+'_'+[DateTime]::Now.ToFileTimeUtc()),$PHTMPProc)
                                }
                                #Else{
                                    #$Script:HiddenWindows.Add(('UNK_UNK_'+$PHTMPProcHand+'_'+[DateTime]::Now.ToFileTimeUtc()),$PHTMPProcHand)
                                #}
                            }
                            'SETWIND'     {
                                $PHCoords = (($X -replace '{SETWIND ' -replace '}$').Split(',') | Select -Skip 1)
                                [Void][Cons.WindowDisp]::MoveWindow($PHTMPProcHand,[Int]$PHCoords[0],[Int]$PHCoords[1],([Int]$PHCoords[2]-[Int]$PHCoords[0]),([Int]$PHCoords[3]-[Int]$PHCoords[1]),$True)
                            }
                            'SETWINDTEXT' {
                                $PHWindText = ($X -replace ('^\s*{.*?,') -replace '}$')
                                [Void][Cons.WindowDisp]::SetWindowText($PHTMPProcHand,$PHWindText)
                            }
                        }
                        If(($PHAction -match 'MIN') -OR ($PHAction -match 'MAX') -OR ($PHAction -match 'SHOW')){
                            $PHKey = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHTMPProcHand+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                            #If(!$PHKey){$PHKey = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHTMPProcHand+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)}
                            If($PHKey){
                                #$PHKey = ($_.Name+'_'+$_.Id+'_'+$PHTMPProcHand+'_'+$PHKey)
                                Try{
                                    $Script:HiddenWindows.Remove($PHKey)
                                }Catch{
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'COULD NOT DELETE PROC KEY ('+$PHKey+'), THIS MAY NOT BE AN ISSUE')}
                                }
                            }
                        }
                    }
                }Else{
                    $PHProc | %{
                        #$PHTMPProc = $_
                        Switch($X.Split(' ')[0].Replace('{','')){
                            'FOCUS'       {If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: FOCUS ON '+($X -replace '{FOCUS ' -replace '}'))}}
                            'MIN'         {If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: MIN WINDOW '+($X -replace '{MIN ' -replace '}' -replace '-ID'))}}
                            'MAX'         {If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: MAX WINDOW '+($X -replace '{MAX ' -replace '}' -replace '-ID'))}}
                            'SHOW'        {If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SHOW WINDOW '+($X -replace '{SHOW ' -replace '}' -replace '-ID'))}}
                            'HIDE'        {If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: HIDE WINDOW '+($X -replace '{HIDE ' -replace '}' -replace '-ID'))}}
                            'SETWIND'     {
                                $PHCoords = (($X -replace '{SETWIND ' -replace '}$').Split(',') | Select -Skip 1)
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: RESIZE WINDOW '+($X -replace '{SETWIND ' -replace '}' -replace '-ID ')+' TO TOP-LEFT ('+$PHCoords[0]+','+$PHCoords[1]+') AND BOTTOM-RIGHT ('+$PHCoords[2]+','+$PHCoords[3]+')')}
                            }
                            'SETWINDTEXT' {
                                $PHWindText = ($X -replace ('^\s*{.*?,') -replace '}$')
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SET WINDOW TEXT FOR '+($X -replace '{SETWINDTEXT ' -replace '}' -replace '-ID ').Split(',')[0]+' TO '+$PHWindText)}
                            }
                        }
                    }
                }
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'PROCESS NOT FOUND!')}
            }
        }ElseIf($X -match '{ECHO .*?}'){
            If($X -match '{ECHO -GUI \S+' -OR !$ShowCons.Checked){
                [Void][Microsoft.VisualBasic.Interaction]::MsgBox(($X -replace '^{ECHO ' -replace '^-GUI ' -replace '}$'), [Microsoft.VisualBasic.MsgBoxStyle]::OkOnly, 'ECHO GUI')
            }Else{
                [System.Console]::WriteLine($Tab+'ECHO: '+($X -replace '^{ECHO ' -replace '}$'))
            }
        }Else{
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
                        [Cons.Send]::Keys([String]$PHX)
                    }Else{
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SEND KEYS '+$PHX)}
                    }
                    
                    If($DelayCheck.Checked){
                        $PH = ((([Cons.Act]::CrI([Random],@()).Next((-1*$DelayRandTimer.Value),($DelayRandTimer.Value)))))
                    }Else{
                        $PH = 0
                    }
                        
                    [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($DelayTimer.Value + $PH))))
                }
            }Else{
                Try{
                    If(!$WhatIf){
                        [Cons.Send]::Keys([String]$X)
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
                            [Cons.Send]::Keys([String]$X)
                        }Else{
                            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: SEND KEYS '+$X)}
                        }
                    }Catch{
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'FAILED!')}
                    }
                }
            }
        }
        If($CommandDelayTimer.Value -ne 0 -OR ($CommDelayCheck.Checked -AND ($CommRandTimer.Value -gt 0))){
            If($CommDelayCheck.Checked){
                $PH = ((([Cons.Act]::CrI([Random],@()).Next((-1*$CommRandTimer.Value),($CommRandTimer.Value)))))
            }Else{
                $PH = 0
            }
            [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($CommandDelayTimer.Value + $PH))))
        }
    }
}
Function Interpret{
    Param([String]$X,[Switch]$SuppressConsole)
    #Do the really basic parsing
    #Write-Host 'NEW LINE IN INTERPRET FUNC'
    $X = [Parser]::Interpret($X)
    #Write-Host 'NEW LINE IN INTERPRET POST FUNC'
    #[System.Console]::WriteLine('INSIDE INTERPRET')
    #Reset the depth overflow (useful for finding bad logic with infinite loops)
    $DepthOverflow = 0
    #Don't exit until we see no more matches to any of the following substitution keywords or we hit the depth overflow
    While(
            $DepthOverflow -lt 500 -AND `
            !$SyncHash.Stop -AND `
            (($X -match '{VAR ') -OR `
            ($X -match '{LEN ') -OR `
            ($X -match '{ABS ') -OR `
            ($X -match '{POW ') -OR `
            ($X -match '{SIN ') -OR `
            ($X -match '{COS ') -OR `
            ($X -match '{TAN ') -OR `
            ($X -match '{RND ') -OR `
            ($X -match '{FLR ') -OR `
            ($X -match '{SQT ') -OR `
            ($X -match '{CEI ') -OR `
            ($X -match '{MOD ') -OR `
            ($X -match '{EVAL ') -OR `
            ($X -match '{VAR \S*\+\+}') -OR `
            ($X -match '{VAR \S*\+=') -OR `
            ($X -match '{VAR \S*--}') -OR `
            ($X -match '{VAR \S*-=') -OR `
            ($X -match '{PWD') -OR `
            ($X -match '{MANIP ') -OR `
            ($X -match '{GETCON ') -OR `
            ($X -match '{FINDVAR ') -OR `
            ($X -match '{GETPROC ') -OR `
            ($X -match '{GETPIX ') -OR `
            ($X -match '{FINDIMG ') -OR `
            ($X -match '{GETWIND ') -OR `
            ($X -match '{GETWINDTEXT ') -OR `
            ($X -match '{GETFOCUS') -OR `
            ($X -match '{GETSCREEN') -OR `
            ($X -match '{READIN '))
        ){
        
        $PHSplitX = $X.Split('{}')
        
        #Perform all the var substitutions now that are not for var setting, by replacing the string with the value stored in the VarHash
        While($X -match '{VAR [\w\d_:]*?}' -AND !$SyncHash.Stop){
            $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -notmatch '=' -AND $_ -notmatch '\+\+$' -AND $_ -notmatch '--$' -AND $_ -notmatch '\+=' -AND $_ -notmatch '-='} | %{
                $PH = $_.Split(' ')[1]
                $PHFound = $True
                If($Script:VarsHash.ContainsKey($PH)){
                    $X = $X.Replace(('{'+$_+'}'),($Script:VarsHash.$PH))
                }ElseIf($Script:VarsHash.ContainsKey(($PH+'_ESCAPED'))){
                    $X = $X.Replace(('{'+$_+'}'),($Script:VarsHash.($PH+'_ESCAPED')))
                    $Esc = $True
                }Else{
                    $X = ''
                    $PHFound = $False
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
                }
                If($PHFound){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab + 'INTERPRETED VALUE: ' + $X)}}
            }
            $PHSplitX = $X.Split('{}')
        }
        
        #Replace the keyword with the content from a file
        $PHSplitX | ?{$_ -match 'GETCON \S+'} | %{
            $X = ($X.Replace(('{'+$_+'}'),((GC $_.Substring(7)) | Out-String)))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the path with a result for Test-Path
        $PHSplitX | ?{$_ -match 'TESTPATH \S+'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(Test-Path ($_.Substring(9))).ToString().ToUpper()))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'TESTPATH RESULT: '+$X)}
        }
        #Replace the keyword with the dimension of all screens separated by semi-colons
        $PHSplitX | ?{$_ -match 'GETSCREEN'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(([GUI.ScreenInfo]::All | %{$PH = $_.Bounds; [String]$PH.X+','+$PH.Y+','+$PH.Width+','+$PH.Height}) -join ';').TrimEnd(';')))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the keyword with the present working directory
        $PHSplitX | ?{$_ -match '^PWD$'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(PWD).Path))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the keyword with the names of all variables matching the regex in the keyword (e.g. {FINDVAR Temp.*})
        $PHSplitX | ?{$_ -match 'FINDVAR \S+'} | %{
            $X = (($Script:VarsHash.Keys | ?{$_ -match ($X -replace '^{FINDVAR ' -replace '}$')} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort}) -join ',')
        }
    
        $PHSplitX | ?{
                ($_ -match 'GETPROC ((?!-(ID|HAND) )\S+|-ID \d+|-HAND \d+)') -OR `
                ($_ -match 'GETWIND ((?!-(ID|HAND) )\S+|-ID \d+|-HAND \d+)') -OR `
                ($_ -match 'GETWINDTEXT ((?!-(ID|HAND) )\S+|-ID \d+|-HAND \d+)') -OR `
                ($_ -match 'GETFOCUS( -ID| -HAND)?')
        } | %{
            $PHProc = $_
            $PHSel = $PHProc.Split(' ')[0]
            $TrueHand = $False
            If($_ -notmatch 'GETFOCUS'){
                $PHProc = $PHProc.Split(' ')[-1]
            }
            $PHID = $False
            If($_ -match ' -ID '){
                $PHID = $True
                If(($Script:HiddenWindows.Keys -join '')){
                    $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProc+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                    $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProc+'_'+$LastHiddenTime+'$')})
                }
                $PHProc = @(PS -Id $PHProc | ?{$_.MainWindowHandle -ne 0})
            }ElseIf($_ -match ' -HAND '){
                $PHProcHand = $PHProc
                #If(($Script:HiddenWindows.Keys -join '')){
                #    $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                #    $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_'+$LastHiddenTime+'$')})
                #}
                $PHProc = @(PS | ?{[String]($_.MainWindowHandle) -eq $PHProcHand})
                If($PHProc){
                    $PHHidden = ''
                }Else{
                    $TrueHand = $True
                    $PHProcHand = [IntPtr][Int]$PHProcHand
                    Try{
                        $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHProcHand)
                        $PHString = ([Cons.Act]::CrI([System.Text.StringBuilder],@(($PHTextLength + 1))))
                        [Void]([Cons.WindowDisp]::GetWindowText($PHProcHand, $PHString, $PHString.Capacity))
                        If(!$PHString){
                            $PHProc = ''
                            $PHHidden = ''
                        }Else{
                            $PHHidden = $PHProcHand
                        }
                    }Catch{$PHProc = ''; $PHHidden = ''}
                }
            }ElseIf($_ -notmatch 'GETFOCUS'){
                If(($Script:HiddenWindows.Keys -join '')){
                    $PHHidden = (($Script:HiddenWindows.Keys | ?{$_ -match ('^'+$PHProc+'_')}) | %{$Script:HiddenWindows.$_})
                }
                $PHProc = @(PS $PHProc | ?{$_.MainWindowHandle -ne 0})
            }
            If($PHHidden){$PHProc+=$PHHidden}
            $PHOut = ''
            If($PHProc.Count -OR $PHProc -match 'GETFOCUS'){
                $PHProc | %{
                    If($TrueHand){
                        $PHTMPProcHand = $_
                    }Else{
                        $PHTMPProc = $_
                        $PHTMPProcHand = $_.MainWindowHandle
                    }
                    $PHTMPProcHand = [IntPtr][Int]$PHTMPProcHand
                    Switch($PHSel){
                        'GETPROC'     {
                            If(!$TrueHand){
                                If($PHID){
                                    $PHOut = $PHTMPProc.Name
                                }Else{
                                    $PHOut+=([String]$PHTMPProc.Id+','+$PHTMPProcHand+';')
                                }
                            }Else{
                                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'COULD NOT PULL PROC, HANDLE IS VALID THOUGH')}
                            }
                        }
                        'GETWINDTEXT' {
                            $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHTMPProcHand)
                            $PHString = ([Cons.Act]::CrI([System.Text.StringBuilder],@(($PHTextLength + 1))))
                            [Void]([Cons.WindowDisp]::GetWindowText($PHTMPProcHand, $PHString, $PHString.Capacity))
                            $PHOut+=($PHString.ToString()+';')
                        }
                        'GETWIND'     {
                            $PHRect = [GUI.Rect]::E
                            [Void]([Cons.WindowDisp]::GetWindowRect($PHTMPProcHand,[Ref]$PHRect))
                            $PHOut+=(([String]$PHRect.X+','+[String]$PHRect.Y+','+[String]$PHRect.Width+','+[String]$PHRect.Height)+';')
                        }
                        default{
                            If($PHTMPProc -match 'GETFOCUS'){
                                $PHFocussedHandle = [Cons.WindowDisp]::GetForegroundWindow()
                                If($PHProc -match '-ID'){
                                    $PHOut = [String](PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle}).Id
                                }ElseIf($PHProc -match '-HAND'){
                                    $PHOut = [String]$PHFocussedHandle
                                }Else{
                                    $PHOut = [String](PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle}).Name
                                }
                            }
                        }
                    }
                }
            }
            
            $PHOut = $PHOut.ToString().Trim(';')
            If(!$PHProc -OR !$PHOut){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'PROCESS NOT FOUND!')}}
            $X = ($X.Replace(('{'+$_+'}'),$PHOut.Trim(';')))
        }
        #Replace the keyword with the input supplied to either the message box or the console prompt
        $PHSplitX | ?{$_ -match 'READIN \S+'} | %{
            If($CommandLine -OR ($X -match '{READIN -C')){
                $PH = $_.Substring(9)
            }Else{
                $PH = [Microsoft.VisualBasic.Interaction]::InputBox(($_.Substring(7)),'READIN')
            }
            $X = ($X.Replace(('{'+$_+'}'),($PH)))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replace the keyword with simple math function results (e.g. {SIN 0} returns 0)
        $PHSplitX | ?{
            ($_ -match '^LEN \S+') -OR `
            ($_ -match '^ABS \S+') -OR `
            ($_ -match '^SIN \S+') -OR `
            ($_ -match '^COS \S+') -OR `
            ($_ -match '^TAN \S+') -OR `
            ($_ -match '^RND \S+') -OR `
            ($_ -match '^FLR \S+') -OR `
            ($_ -match '^CEI \S+') -OR `
            ($_ -match '^SQT \S+') -OR `
            ($_ -match '^MOD \S+') -OR `
            ($_ -match '^POW \S+')
        } | %{
            $PH = $_.Substring(4)
            If(($_.Split(' ')[0] -notmatch 'LEN') -AND ($PH -match 'E-')){$PH = 0}
            
            Switch($_.Split(' ')[0]){
                'LEN'{$PH = $PH.Length}
                'ABS'{$PH = [Math]::Abs([Double]$PH)}
                'SIN'{$PH = [Math]::Sin([Double]$PH)}
                'COS'{$PH = [Math]::Cos([Double]$PH)}
                'TAN'{$PH = [Math]::Tan([Double]$PH)}
                'RND'{$PH = [Math]::Round([Double]$PH)}
                'FLR'{$PH = [Math]::Floor([Double]$PH)}
                'CEI'{$PH = [Math]::Ceiling([Double]$PH)}
                'SQT'{$PH = [Math]::Sqrt([Double]$PH)}
                'MOD'{$PH = $PH.Split(',');$PH = [Double]$PH[0] % [Double]$PH[1]}
                'POW'{$PH = $PH.Split(',');$PH = [Math]::Pow([Double]$PH[0],[Double]$PH[1])}
            }
    
            $X = ($X.Replace(('{'+$_+'}'),$PH))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        #Replaces the keyword with the evaluation of the arithmetic
        $PHSplitX | ?{$_ -match '^EVAL \S+.*\d$'} | %{
            ($_.SubString(5) -replace ' ') | %{
                #Preparse
                $PHOut = ($_ -replace '\+-','-')
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Pre:'+$PHOut)}
                $PHOut
            } | %{
                #Division
                $PHOut = $_
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Div:'+$PHOut)}
                While($PHOut -match '/'){
                    (($_ -replace '-','+-' -replace '\*','+*' -replace '/\+','/').Split('+*') | ?{$_ -match '/' -AND $_ -ne ''}) | Select -Unique | %{
                        $PHArr =  $_.Split('/')
                        $PHTotal = [Double]$PHArr[0]
                        $PHArr | Select -Skip 1 | %{$PHTotal = $PHTotal / [Double]$_}
                        If($PHTotal -ge 0){$PHTotal = '+' + $PHTotal}
                        $PHOut = $PHOut.Replace($_,$PHTotal)
                    }
                }
                $PHOut
            } | %{
                #Multiplication
                $PHOut = $_ -replace '\*\+','*'
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Mul:'+$PHOut)}
                While($PHOut -match '\*'){
                    (($_ -replace '-','+-' -replace '\*\+','*').Split('+') | ?{$_ -match '\*' -AND $_ -ne ''}) | Select -Unique | %{
                        $PHArr =  $_.Split('*')
                        $PHTotal = 1
                        $PHArr | %{$PHTotal = $PHTotal * [Double]$_}
                        If($PHTotal -ge 0){$PHTotal = '+' + $PHTotal}
                        $PHOut = $PHOut.Replace($_,$PHTotal)
                    }
                }
                $PHOut
            }  | %{
                #Subtraction
                $PHOut = $_
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Sub:'+$PHOut)}
                $PHOut = $PHOut -replace '-','+-'
                While($PHOut -match '\+\+'){$PHOut = $PHOut.Replace('++','+')}
                $PHOut
            }  | %{
                #Addition
                $PHOut = $_
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Add:'+$PHOut)}
                $PHTotal = 0
                While($PHOut -match '\+'){
                    ($_.Split('+') | ?{$_ -ne ''}) | %{
                        $PHTotal = $PHTotal + [Double]$_
                    }
                    $PHOut = $PHOut.Replace($_,$PHTotal)
                }
            }
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'Out:'+$PHOut)}
            $X = ($X.Replace(('{'+$_+'}'),($PHOut)))
            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}
        }
        $PHSplitX | ?{$_ -match 'GETPIX [0-9]*,[0-9]*'} | %{
            $PH = ($_ -replace 'GETPIX ')
            #$PH = $PH.Substring(0,($PH.Length - 1))
            $PH = $PH.Split(',')
            $Bounds = [System.Drawing.Rectangle]::FromLTRB($PH[0],$PH[1],($PH[0]+1),($PH[1]+1))
            $BMP = ([Cons.Act]::CrI([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
            
            $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
            $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
            $X = $X.Replace(('{'+$_+'}'),($BMP.GetPixel(0,0).Name.ToUpper()))
            
            $Graphics.Dispose()
            $BMP.Dispose()
        }
        $PHSplitX | ?{$_ -match 'FINDIMG \S+'} | %{
            $PHCoords = ($_ -replace '^FINDIMG ')
            $PHCoords = ($PHCoords.Split(',')[0,1,2,3] | %{[Int]$_})
            $PHIndex = 0
            $PHFile = ($_.Split(',') | ?{$_ -match '\.bmp'})
            If($_ -match '\.bmp,[0-9]+'){
                $PHIndex = ($_.Split(',')[-1] -replace '\D')
            }
            $Bounds = [GUI.Rect]::R($PHCoords[0],$PHCoords[1],$PHCoords[2],$PHCoords[3])
            $BMP1 = ([Cons.Act]::CrI([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
            
            $Graphics = [System.Drawing.Graphics]::FromImage($BMP1)
            $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.size)
            $BMP2 = [System.Drawing.Bitmap]::FromFile($PHFile)
            $PHOut = [Img.Find]::GetSubPositions($BMP1,$BMP2)[$PHIndex]
            If($PHOut -ne $Null){
                $PHOut = ([String]$PHOut.X + ',' + $PHOut.Y)
                If($ShowCons.Checked -AND !$SuppressConsole){
                    [System.Console]::WriteLine($Tab+'IMAGE FOUND WITH INDEX ' + $PHIndex + ' AT COORDINATES ' + $PHOut)
                }
            }ElseIf(!$SuppressConsole){
                [System.Console]::WriteLine($Tab+'IMAGE NOT FOUND!')
            }
            $X = ($X.Replace(('{'+$_+'}'),$PHOut))
        }
        $PHSplitX | ?{$_ -match '^MANIP \S+'} | %{
            $PH = ($_.Substring(6))
            $Operator = $PH.Split(' ')[0]
            $Operands = [String[]]($PH.Substring(4).Split(','))
            $Operands | %{$Index = 0}{If($_){$Operands[$Index] = ($_.Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',$NL).Replace('(NULL)','').Replace('(LBRACE)','{').Replace('(RBRACE)','}'))}; $Index++}
            
            $Output = ''
            Switch($Operator){
                'CNT'{
                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('^([0-9]*_)?'+$Operands[0]+'$')}).Count
                }
                'APP'{
                    If($Operands.Count -gt 2){
                        $Output = [String]($Operands[0..($Operands.Count - 2)] -join ',')+[String]$Operands[-1]
                    }Else{
                        $Output = $Operands -join ''
                    }
                }
                'RPL'{
                    If($Operands.Count -gt 3){
                        $Output = ($Operands[0..($Operands.Count - 3)] -join ',') -replace $Operands[-2],$Operands[-1]
                    }Else{
                        $Output = $Operands[0] -replace $Operands[1],$Operands[2]
                    }
                }
                'TRS'{
                    If($Operands.Count -gt 2){
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimStart($Operands[-1])
                    }Else{
                        $Output = $Operands[0].TrimStart($Operands[1])
                    }
                }
                'TRE'{
                    If($Operands.Count -gt 2){
                        $Output = ($Operands[0..($Operands.Count - 2)] -join ',').TrimEnd($Operands[-1])
                    }Else{
                        $Output = $Operands[0].TrimEnd($Operands[1])
                    }
                }
                'JOI'{
                    $Output = ($Script:VarsHash.Keys | ?{$_ -match ('^([0-9]*_)?'+$Operands[0]+'$')} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{$Script:VarsHash.$_}) -join $Operands[1]
                }
                'SPL'{
                    ($Script:VarsHash.($Operands[0])).ToString().Split($Operands[-1]) | %{$Count = 0}{
                        $Script:VarsHash.Remove(([String]$Count+'_'+$Operands[0]))
                        $Script:VarsHash.Add(([String]$Count+'_'+$Operands[0]),$(If($_ -eq $Null){''}Else{$_}))
                        $Count++
                    }
                }
                'TCA'{
                    ($Script:VarsHash.($Operands[0])).ToString().ToCharArray() | %{$Count = 0}{
                        $Script:VarsHash.Remove(([String]$Count+'_'+$Operands[1]))
                        $Script:VarsHash.Add(([String]$Count+'_'+$Operands[1]),$_)
                        $Count++
                    }
                }
                'REV'{
                    $CountF = 0
                    $CountR = (($Script:VarsHash.Keys | ?{$_ -match ('[0-9]*_'+$Operands[0]+'$')}).Count - 1)
                    0..[Math]::Ceiling($CountR / 2) | %{
                        If($CountR -ge $CountF){
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
            If($Output){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($X)}}
        }
        $PHSplitX = $X.Split('{}')
        $PHSplitX | ?{(($_ -match '^VAR \S*\+\+') -AND ($_ -notmatch '=')) -OR (($_ -match '^VAR \S*--') -AND ($_ -notmatch '=')) -OR ($_ -match '^VAR \S*?\+=\S+') -OR ($_ -match '^VAR \S+-=\d*')} | %{
            $PH = ((($_ -replace '\+=',' ' -replace '-=',' ' -replace '\+\+',' ' -replace '--',' ').Split(' ') | ?{$_ -ne ''})[1])
            If($Script:VarsHash.ContainsKey($PH)){
                Try{
                    If($_ -match '--'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - 1)
                        If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([Double]$Script:VarsHash.$PH)+'"')}
                        $X = ''
                    }ElseIf($_ -match '\+\+'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + 1)
                        If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([Double]$Script:VarsHash.$PH)+'"')}
                        $X = ''
                    }ElseIf($_ -match '-='){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - ($_.Split('=')[-1]))
                        If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([Double]$Script:VarsHash.$PH)+'"')}
                        $X = ''
                    }ElseIf($_ -match '\+='){
                        $PHInterpret = ($_.Split('=')[-1])
                        If(
                            [String]($Script:VarsHash.$PH -replace '\D') -AND `
                            $(Try{[Double]$Script:VarsHash.$PH;$True}Catch{$False}) -AND `
                            [String]($PHInterpret -replace '\D') -AND `
                            $(Try{[Double]$PHInterpret;$True}Catch{$False})
                        ){
                            $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + [Double]$PHInterpret)
                            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO '+([Double]$Script:VarsHash.$PH)+'"')}
                        }Else{
                            $Script:VarsHash.$PH = ([String]$Script:VarsHash.$PH + [String]$PHInterpret)
                            If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PH+' TO "'+([String]$Script:VarsHash.$PH)+'"')}
                        }
                        $X = ''
                    }
                }Catch{
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+$PH+' BAD DATA TYPE!')}
                }
            }Else{
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
            }
        }
        $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -match '=.+' -AND $_ -notmatch 'VAR \S*?\+='} | %{
            $PH = $_.Substring(4)
            $PHName = $PH.Split('=')[0]
            If($PHName -match '_ESCAPED$'){
               If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'THE NAME '+$PHName+' IS INVALID, _ESCAPED IS A RESERVED SUFFIX. THIS LINE WILL BE IGNORED...')}
                $X = ''
            }Else{
                $PHValue = $PH.Replace(($PHName+'='),'')
                If(!([String]$PHValue)){
                    $PHValue = ($X -replace '.*?{VAR .*?=')
                    $PHCount = ($X.Split('{') | %{$VarCheck = $False}{If($VarCheck){$_};If($_ -match 'VAR .*?='){$VarCheck = $True}}).Count
                    $PHValue = $PHValue.Split('}')[0..$PHCount] -join '}'
                    $X = $X.Replace(('{VAR '+$PHName+'='+$PHValue+'}'),'')
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'ABOVE VAR CONTAINS BRACES "{}" AND NO VALID VARS TO SUBSTITUTE.')}
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'PLEASE CONSIDER CHANGING LOGIC TO USE DIFFERENT DELIMITERS.')}
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'THIS WILL BE PARSED AS RAW TEXT AND NOT AS COMMANDS.')}
                    If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'IF YOU NEED TO ALIAS COMMANDS, USE A FUNCTION INSTEAD.')}
                    $PHName+='_ESCAPED'
                }Else{
                    $X = $X.Replace(('{'+$_+'}'),'').Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',$NL).Replace('(NULL)','').Replace('(LBRACE)','{').Replace('(RBRACE)','}')
                }
                $Script:VarsHash.Remove($PHName)
                $Script:VarsHash.Add($PHName,$PHValue)
                If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'SET VAR:'+$PHName+' TO "'+$PHValue+'"')}
            }
        }
        $X.Split('{') | ?{$_ -match 'VAR \S+=}' -AND $_ -notmatch 'VAR \S*?\+='} | %{
            $PHName = ($_.Split('=')[0] -replace '^VAR ')
            $Script:VarsHash.Remove($PHName)
            $Script:VarsHash.Add($PHName,'')
            $X = $X.Replace('{'+$_,'')
        }
        $DepthOverflow++
    }
    If($DepthOverflow -ge 500){If($ShowCons.Checked -AND !$SuppressConsole){[System.Console]::WriteLine($Tab+'OVERFLOW DEPTH REACHED! POSSIBLE INFINITE LOOP!')}}
    Return $X,$Esc
}
Function Parse-IfEl{
    Param([String]$X,[Switch]$WhatIf)
    #[System.Console]::WriteLine('INSIDE IFEL')
    If(!$SyncHash.Stop){
        If($X -match '{IF \(.*?\)}' -AND !$Script:Inside_If){
            If($ShowCons.Checked){[System.Console]::WriteLine($NL + 'BEGIN IF')}
            If($ShowCons.Checked){[System.Console]::WriteLine('--------')}
            
            $Script:Inside_If = $True
            $Script:IfElDepth = 0
            $Script:IfElEval = $False
            $X = $X.Replace('{IF (','')
            $X = $X.Substring(0,($X.Length - 2))
            $Comparator = ''
            $Script:BufferedCommandsIfEl = ''
            $PHEsc1 = $False
            $PHEsc2 = $False
            If($X -match '-'){
                $Comparator = $X.Split('-')[-1]
                $Comparator = $Comparator.Split(' ')[0]
                $Op1 = ($X -replace '-.*','').Trim(' ')
                $Op2 = ($X -replace ('.*-'+$Comparator),'').Trim(' ')
                
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND1: ' + $Op1)}
                $Op1,$PHEsc1 = (Interpret $Op1)
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND2: ' + $Op2)}
                $Op2,$PHEsc2 = (Interpret $Op2)
                If($ShowCons.Checked){[System.Console]::WriteLine('COMPARATOR: ' + $Comparator)}
            }Else{
                $Op1,$PHEsc1 = (Interpret $X)
                $Comparator = $Op1
                $Op2 = ''
            }
            $Caught = $False
            If(!$PHEsc1 -AND !$PHEsc2){
                Switch($Comparator){
                    'MATCH'    {If($Op1 -match $Op2)                       {$Script:IfElEval = $True}}
                    'EQ'       {If($Op1 -eq $Op2)                          {$Script:IfElEval = $True}}
                    'LIKE'     {If($Op1 -like $Op2)                        {$Script:IfElEval = $True}}
                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$Script:IfElEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$Script:IfElEval = $True}}
                    'NE'       {If($Op1 -ne $Op2)                          {$Script:IfElEval = $True}}
                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$Script:IfElEval = $True}}
                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$Script:IfElEval = $True}}
                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$Script:IfElEval = $True}}
                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$Script:IfElEval = $True}}
                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$Script:IfElEval = $True}}
                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$Script:IfElEval = $True}}
                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$Script:IfElEval = $True}}
                }
                If($ShowCons.Checked -AND $Caught){[System.Console]::WriteLine($Tab + 'ERROR! COULD NOT CONVERT TO NUMERIC!')}
                If($Comparator -eq 'TRUE' -OR $Comparator -eq 'FALSE'){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'IF STATEMENT: {IF (' + $Comparator + ')}')}
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'IF STATEMENT: {IF (' + $OP1 + ' -' + $Comparator + ' ' + $OP2 + ')}')}
                }
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'EVALUATION: ' + $Script:IfElEval.ToString().ToUpper() + $NL)}
            }
            Else{
                If($ShowCons.Checked){[System.Console]::WriteLine('IF STATEMENT FAILED! CHECK PARAMS! AN ARGUMENT WAS ESCAPED FOR SOME REASON!')}
            }
        }ElseIf($Script:Inside_If){
            If($X -match '{IF \(.*?\)}'){
                $Script:IfElDepth++
            }
            If($X -match '{FI}'){
                If($Script:IfElDepth -gt 0){
                    $Script:BufferedCommandsIfEl+=($NL+$X)
                    $Script:IfElDepth--
                }Else{
                    $Script:Inside_If = $False
                    $Script:IfElDepth = 0
                    $PH = ($Script:BufferedCommandsIfEl.Split($NL) | ?{$_ -ne ''})
                    $Script:BufferedCommandsIfEl = ''
                    $PH | %{$TF = $True; $PHDepth = 0; $PHT=''; $PHF=''}{
                        $Temp = $_
                        If($Temp -match '{IF \(.*?\)}'){
                            $PHDepth++
                        }
                        If($Temp -match '{ELSE}'){
                            If($PHDepth -eq 0){
                                $TF = $False
                                $Temp = ''
                            }Else{
                                $PHDepth++
                            }
                        }
                        If($Temp -match '{FI}' -AND $PHDepth){
                            If(!($PHDepth % 2)){
                                $PHDepth--
                            }
                            $PHDepth--
                            #If(!$PHDepth){$Temp = ''}
                        }ElseIf($Temp -match '{FI}'){
                            $Temp = ''
                        }
                        If($TF){
                            $PHT+=($NL+$Temp)
                        }Else{
                            $PHF+=($NL+$Temp)
                        }
                    }
                    $PHOut = ($(If($Script:IfElEval){$PHT}Else{$PHF}).Split($NL) | ?{$_ -ne ''})
                
                    $Script:IfElEval = $False
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'FOLLOWING COMMANDS WILL BE RUN:')}
                    If($ShowCons.Checked){$PHOut | %{[System.Console]::WriteLine($Tab*2+$_)}}
                    If($ShowCons.Checked){[System.Console]::WriteLine('------')}
                    If($ShowCons.Checked){[System.Console]::WriteLine('END IF'+$NL)}
                    $PHOut | %{
                        $_.Split($NL) | ?{$_ -ne ''} | %{$Break = $False}{
                            If(!$Break -AND !$SyncHash.Stop){
                                If($_ -notmatch '{BREAK}'){
                                    If(!$WhatIf){
                                       [Void](Parse-While $_)
                                    }Else{
                                       [Void](Parse-While $_ -WhatIf)
                                    }
                                }Else{$Break = $True}
                            }
                        }
                    }
                }
            }Else{
                $Script:BufferedCommandsIfEl+=($NL+$X)
            }
        }Else{
            If(!$WhatIf){
                #Write-Host 'NEW LINE IN ACTIONS'
                [Void](Actions $X)
            }Else{
                [Void](Actions $X -WhatIf)
            }
        }
    }
}
Function Parse-While{
    Param([String]$X,[Switch]$WhatIf)
    #[System.Console]::WriteLine('INSIDE WHILE')
    If(!$SyncHash.Stop){
        If($X -match '{WHILE \(.*?\)}' -AND !$Script:Inside_While -AND !$Script:Inside_If){
            If($ShowCons.Checked){[System.Console]::WriteLine($NL + 'BEGIN WHILE')}
            If($ShowCons.Checked){[System.Console]::WriteLine('--------')}
            
            $Script:Inside_While = $True
            $Script:WhileDepth = 1
            $Script:WhileEval = $False
            $Script:BufferedCommandsWhile = $X
            $X = $X.Replace('{WHILE (','')
            $X = $X.Substring(0,($X.Length - 2))
            $Comparator = ''
            $PHEsc1 = $False
            $PHEsc2 = $False
            If($X -match '-'){
                $Comparator = $X.Split('-')[-1]
                $Comparator = $Comparator.Split(' ')[0]
                $Op1 = ($X -replace '-.*','').Trim(' ')
                $Op2 = ($X -replace ('.*-'+$Comparator),'').Trim(' ')
                
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND1: ' + $Op1)}
                $Op1,$PHEsc1 = (Interpret $Op1)
                If($ShowCons.Checked){[System.Console]::WriteLine('OPERAND2: ' + $Op2)}
                $Op2,$PHEsc2 = (Interpret $Op2)
                If($ShowCons.Checked){[System.Console]::WriteLine('COMPARATOR: ' + $Comparator)}
            }Else{
                $Op1,$PHEsc1 = (Interpret $X)
                $Comparator = $Op1
                $Op2 = ''
            }
            $Caught = $False
            If(!$PHEsc1 -AND !$PHEsc2){
                Switch($Comparator){
                    'MATCH'    {If($Op1 -match $Op2)                       {$Script:WhileEval = $True}}
                    'EQ'       {If($Op1 -eq $Op2)                          {$Script:WhileEval = $True}}
                    'LIKE'     {If($Op1 -like $Op2)                        {$Script:WhileEval = $True}}
                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$Script:WhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$Script:WhileEval = $True}}
                    'NE'       {If($Op1 -ne $Op2)                          {$Script:WhileEval = $True}}
                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$Script:WhileEval = $True}}
                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$Script:WhileEval = $True}}
                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$Script:WhileEval = $True}}
                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$Script:WhileEval = $True}}
                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$Script:WhileEval = $True}}
                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$Script:WhileEval = $True}}
                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$Script:WhileEval = $True}}
                }
                If($ShowCons.Checked -AND $Caught){[System.Console]::WriteLine($Tab + 'ERROR! COULD NOT CONVERT TO NUMERIC!')}
                If($Comparator -eq 'TRUE' -OR $Comparator -eq 'FALSE'){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'WHILE STATEMENT: {WHILE (' + $Comparator + ')}')}
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'WHILE STATEMENT: {WHILE (' + $OP1 + ' -' + $Comparator + ' ' + $OP2 + ')}')}
                }
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'EVALUATION: ' + $Script:WhileEval.ToString().ToUpper() + $NL)}
            }
            Else{
                If($ShowCons.Checked){[System.Console]::WriteLine('WHILE STATEMENT FAILED! CHECK PARAMS! AN ARGUMENT WAS ESCAPED FOR SOME REASON!')}
            }
        }ElseIf($Script:Inside_While){
            If($X -match '{WHILE \(.*?\)}'){
                $Script:WhileDepth++
            }
            If($X -match '{END WHILE}'){
                If($Script:WhileDepth -gt 1){
                    $Script:BufferedCommandsWhile+=($NL+$X)
                    $Script:WhileDepth--
                }Else{
                    $Script:Inside_While = $False
                    $Script:WhileDepth = 1
                    #$Script:BufferedCommandsWhile+=($NL+$X)
                    $PH = ($Script:BufferedCommandsWhile.Split($NL) | ?{$_ -ne ''})
                    $Script:BufferedCommandsWhile = ''
                    $PH | %{$PHDepth = 1; $PHOut = ''}{
                        $Temp = $_
                        If($Temp -match '{WHILE \(.*?\)}'){
                            $PHDepth++
                        }
                        If($Temp -match '{END WHILE}' -AND ($PHDepth -gt 0)){
                            $PHDepth--
                        }ElseIf($Temp -match '{END WHILE}'){$Temp = ''}
                        $PHOut+=($NL+$Temp)
                    }
                    If($Script:WhileEval){
                        $PHOut = (($PHOut).Split($NL) | ?{$_ -ne ''})
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'FOLLOWING COMMANDS WILL BE RUN UNTIL '+$PHOut[0]+' IS FALSE:')}
                        If($ShowCons.Checked){$PHOut | Select -Skip 1 | %{[System.Console]::WriteLine($Tab*2+$_)}}
                        If($ShowCons.Checked){[System.Console]::WriteLine('------')}
                        If($ShowCons.Checked){[System.Console]::WriteLine('END WHILE'+$NL)}
                        $X = $PHOut[0]
                        $X = $X.Replace('{WHILE (','')
                        $X = $X.Substring(0,($X.Length - 2))
                    
                        Do{
                            $TempWhileEval = $False
                            $PHEsc1 = $False
                            $PHEsc2 = $False
                            If($X -match '-'){
                                $Comparator = $X.Split('-')[-1]
                                $Comparator = $Comparator.Split(' ')[0]
                                $Op1 = ($X -replace '-.*','').Trim(' ')
                                $Op2 = ($X -replace ('.*-'+$Comparator),'').Trim(' ')
                
                                $Op1,$PHEsc1 = (Interpret $Op1 -SuppressConsole)
                                $Op2,$PHEsc2 = (Interpret $Op2 -SuppressConsole)
                            }Else{
                                $Op1,$PHEsc1 = (Interpret $X -SuppressConsole)
                                $Comparator = $Op1
                                $Op2 = ''
                            }
                            $Caught = $False
                            If(!$PHEsc1 -AND !$PHEsc2){
                                Switch($Comparator){
                                    'MATCH'    {If($Op1 -match $Op2)                       {$TempWhileEval = $True}}
                                    'EQ'       {If($Op1 -eq $Op2)                          {$TempWhileEval = $True}}
                                    'LIKE'     {If($Op1 -like $Op2)                        {$TempWhileEval = $True}}
                                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$TempWhileEval = $True}}Catch [System.Management.Automation.RuntimeException]{$Caught = $True}}
                                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$TempWhileEval = $True}}
                                    'NE'       {If($Op1 -ne $Op2)                          {$TempWhileEval = $True}}
                                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$TempWhileEval = $True}}
                                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$TempWhileEval = $True}}
                                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$TempWhileEval = $True}}
                                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$TempWhileEval = $True}}
                                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$TempWhileEval = $True}}
                                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$TempWhileEval = $True}}
                                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$TempWhileEval = $True}}
                                }
                            }
                            If($TempWhileEval){
                                $PHOut | Select -Skip 1 | ?{$_ -ne ''} | %{$Break = $False}{
                                    If(!$Break -AND !$SyncHash.Stop){
                                        If($_ -notmatch '{BREAK}'){
                                            If(!$WhatIf){
                                                [Void](Parse-While $_)
                                            }Else{
                                                [Void](Parse-While $_ -WhatIf)
                                            }
                                        }Else{$Break = $True; $TempWhileEval = $False}
                                    }
                                }
                            }
                        }While($TempWhileEval -AND !$SyncHash.Stop)
                    }Else{
                        If($ShowCons.Checked){[System.Console]::WriteLine('------')}
                        If($ShowCons.Checked){[System.Console]::WriteLine('END WHILE'+$NL)}
                    }
                }
            }Else{
                $Script:BufferedCommandsWhile+=($NL+$X)
            }
        }Else{
            If(!$WhatIf){
                #Write-Host 'NEW LINE IN WHILE'
                [Void](Parse-IfEl $X)
            }Else{
                [Void](Parse-IfEl $X -WhatIf)
            }
        }
    }
}
Function GO{
    Param([Switch]$SelectionRun,[Switch]$Server,[Switch]$WhatIf,[String]$InlineCommand,$Stream=$Null)
    #[System.Console]::WriteLine('INSIDE GO')
    #Any lines with #Ignore are there for regex purposes when exporting scripts
    [System.Console]::WriteLine($NL+'Initializing:')                                             #Ignore
    [System.Console]::WriteLine('-------------------------')                                     #Ignore
    $Script:Refocus = $False
    $Script:Inside_If = $False
    $Script:IfElDepth = 0
    $Script:IfElEval = $False
    $Script:Inside_While = $False
    $Script:WhileDepth = 0
    $Script:WhileEval = $False
    $Script:BufferedCommandsIfEl = ''
    $Script:BufferedCommandsWhile = ''
    $Script:VarsHash = @{}
    $Script:FuncHash = @{}
    #$Script:HiddenWindows = @{}
    $UndoHash.KeyList | %{
        If($_ -notmatch 'MOUSE'){
            [Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)
        }Else{
            [Cons.MouseEvnt]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
        }
    }
    $UndoHash = @{KeyList=[String[]]@()}
    $Commands.ReadOnly      = $True
    $FunctionsBox.ReadOnly  = $True
    $Form.Refresh()
    #The below if statement is split for the regex as well
    If(
        $FunctionsBox.Text -replace '\s*' -AND `
        !$InlineCommand
    ){
        [System.Console]::WriteLine($Tab+'Parsing Functions:')                                   #Ignore
        [System.Console]::WriteLine($Tab+'-------------------------')                            #Ignore
        $FunctionsBox.Text.Split($NL) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart($Tab)} | %{ #Ignore
            $FunctionStart = $False                                                              #Ignore
            $FunctionText = @()                                                                  #Ignore
        }{                                                                                       #Ignore
            If(!$FunctionStart -AND $_ -match '^{FUNCTION NAME '){$FunctionStart = $True}        #Ignore
            If($FunctionStart){                                                                  #Ignore
                If($_ -match '^{FUNCTION NAME '){                                                #Ignore
                    $NameFunc = [String]($_ -replace '^.*{FUNCTION NAME ' -replace '}\s*$')      #Ignore
                }ElseIf($_ -match '{FUNCTION END}'){                                             #Ignore
                    $FunctionStart = $False                                                      #Ignore
                    $Script:FuncHash.Add($NameFunc,($FunctionText -join $NL))                    #Ignore
                    $FunctionText = @()                                                          #Ignore
                }Else{                                                                           #Ignore
                    $FunctionText+=$_                                                            #Ignore
                }                                                                                #Ignore
            }                                                                                    #Ignore
        }                                                                                        #Ignore
        $Script:FuncHash.Keys | Sort | %{                                                        #Ignore
            [System.Console]::WriteLine(($Tab*2) + $_ + $NL + ($Tab*2) + '-------------------------' + $NL + (($Script:FuncHash.$_.Split($NL) | ?{$_ -ne ''} | %{($Tab*2)+($_ -replace '^\s*')}) -join $NL) + $NL)#Ignore
        }                                                                                        #Ignore
    }
    [System.Console]::WriteLine($NL+'---------------'+$NL+'Starting Macro!'+$NL+'---------------'+$NL)
    
    $Results = (Measure-Command {
        [Cons.WindowDisp]::ShowWindow($Form.Handle,0)
            
        If($InlineCommand){
            $PHText = $InlineCommand
        }Else{
            If($SelectionRun){
                $(Switch($TabControllerComm.SelectedTab.Text)
                {
                    'Commands'{$Commands}
                    'Functions'{$FunctionsBox}
                    default{''}
                }) | %{$PHText = $_.SelectedText}
            }Else{
                $PHText = $Commands.Text
            }
        }
        $PHText = (($PHText -replace ('`'+$NL),'').Split($NL) | %{$_ -replace '^\s*'} | ?{$_ -ne ''} | %{$Commented = $False}{
            If($_ -match '^<\\\\#'){$Commented = $True}
            If($_ -match '^\\\\#>'){$Commented = $False}
            If($_ -notmatch '^\\\\#' -AND !$Commented){$_}
        })
        
           
        Do{
            $SyncHash.Stop = $False
            $SyncHash.Restart = $False
                
            $PHText | %{$InlineFunction = $False}{
                If(!$SyncHash.Stop){
                    Try{
                        $Line = $_
                        If($Line -match '{FUNCTION NAME '){
                            $InlineFunction = $True
                            $NewFuncName = ($Line -replace '^.*{FUNCTION NAME ' -replace '}\s*$').Trim(' ')
                            $NewFuncName,$FuncEsc = (Interpret $NewFuncName)
                            If(!$FuncEsc){
                                $Line = ''
                                $NewFuncBody = ''
                            }Else{
                                $InlineFunction = $False
                            }
                        }
                        If($InlineFunction){
                            If($Line -notmatch '{FUNCTION END}'){
                                $NewFuncBody+=($Line+$NL)
                            }Else{
                                $InlineFunction = $False
                                Try{
                                    $Script:FuncHash.Remove($NewFuncName)
                                }Catch{
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'NO FUNCTION WITH THE NAME '+$NewFuncName+' FOUND, THIS MAY BE INTENDED BEHAVIOR')}
                                }
                                Try{
                                    $Script:FuncHash.Add($NewFuncName,$NewFuncBody)
                                        
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Parsing New Function:')}
                                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'-------------------------')}
                                    If($ShowCons.Checked){[System.Console]::WriteLine(($Tab*2) + $NewFuncName + $NL + ($Tab*2) + '-------------------------' + $NL + (($Script:FuncHash.$NewFuncName.Split($NL) | ?{$_ -ne ''} | %{($Tab*2)+($_ -replace '^\s*')}) -join $NL) + $NL)}
                                }Catch{}
                            }
                        }Else{
                            If($Line -match '{SERVERSTOP}'){
                                [System.Console]::WriteLine('{SERVERSTOP}')
                                [System.Console]::WriteLine($Tab+'KILLING SERVER!')
                                $Server = $False
                                $SyncHash.Stop = $True
                                $SyncHash.Restart = $False
                            }Else{
                                If($Line -match '{KEEPALIVE}'){
                                    [Void]$Stream.Write([Text.Encoding]::UTF8.GetBytes('{KEEPALIVE}'),0,11)
                                }Else{
                                    If(!$WhatIf){
                                        #Write-Host 'NEW LINE IN GO'
                                        [Void](Parse-While $Line)
                                    }Else{
                                        [Void](Parse-While $Line -WhatIf)
                                    }
                                }
                            }
                        }
                    }Catch{
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'UNHANDLED ERROR: '+$_.ToString())}
                    }
                }
            }
        }While($SyncHash.Restart)
        $UndoHash.KeyList | %{
            If($_ -notmatch 'MOUSE'){
                [Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)
            }Else{
                [Cons.MouseEvnt]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
            }
        }
        If($Server){$SyncHash.Stop = $False}
        [System.Console]::WriteLine($NL+'---------'+$NL+'Complete!'+$NL+'---------'+$NL)
        If(!$CommandLine -AND !$Server){    
            $Commands.ReadOnly     = $False
            $FunctionsBox.ReadOnly = $False
            [Cons.WindowDisp]::ShowWindow($Form.Handle,4)
            $Form.Refresh()
            If($Script:Refocus){
                $Form.Activate()
                $Commands.Focus()
            }
        }
    })
    [System.Console]::WriteLine('Stats'+$NL+'-------------------------')
    [System.Console]::WriteLine((($Results | Select Hours,Minutes,Seconds,Milliseconds,Ticks | Out-String) -replace '^\s*'))
}
###############################################
              #####   #     #  ### 
             #     #  #     #   #  
             #        #     #   #  
             #  ####  #     #   #  
             #     #  #     #   #  
             #     #  #     #   #  
              #####    #####   ### 
###############################################
Function Handle-RMenuExit($MainObj){
    $PHObj = $MainObj
    
    If($MainObj.Parent.GetType().BaseType.ToString() -eq 'System.Windows.Forms.Panel'){
        $PHObj = $PHObj.Parent
    }
    $L = $PHObj.Location
    $S = $PHObj.Size
    $M = [Cons.Curs]::GPos()
    $M.X = ($M.X - $Form.Location.X)
    $M.Y = ($M.Y - $Form.Location.Y)
    If(($M.X -lt ($L.X + 10)) -OR ($M.Y -lt ($L.Y + 35)) -OR ($M.X -gt ($S.Width + $L.X + 4)) -OR ($M.Y -gt ($S.Height + $L.Y + 29))){
        $PHObj.Visible = $False
    }
}
Function Handle-RMenuClick($MainObj){
    $RightClickMenu.Visible = $False
    
    $(Switch($TabControllerComm.SelectedTab.Text)
    {
        'Commands'{$Commands}
        'Functions'{$FunctionsBox}
    }) | %{
        $PHObj = $_
        $PHObj.Focus()
        Switch($MainObj.Text)
        {
            'Cut'              {[Cons.Clip]::SetT($PHObj.SelectedText);$PHObj.SelectedText = ''}
            'Copy'             {[Cons.Clip]::SetT($PHObj.SelectedText)}
            'Paste'            {$PHObj.Paste()}
            'Select All'       {$PHObj.SelectAll()}
            'Select Line'      {
                $PHObj.SelectionStart = $PHObj.GetFirstCharIndexOfCurrentLine()
                $PHObj.SelectionLength = $PHObj.Lines[$PHObj.GetLineFromCharIndex($PHObj.SelectionStart)].Length
            }
            'Delete'           {$PHObj.SelectedText = ''}
            'Highlight Syntax' {Handle-TextBoxKey -KeyCode 'F10' -MainObj $PHObj -BoxType $TabController.SelectedTab.Text -Shift $_.Shift -Control $_.Control -Alt $_.Alt}
            'Undo'             {$PHObj.Undo()}
            'Redo'             {$PHObj.Redo()}
            'WhatIf Selection' {GO -SelectionRun -WhatIf}
            'WhatIf'           {GO -WhatIf}
            'Goto Top'         {$PHObj.SelectionStart = 0}
            'Goto Bottom'      {$PHObj.SelectionStart = $PHObj.Text.Length}
            'Find/Replace'     {
                $FindForm.Visible = $True
                $FindForm.BringToFront()
                $Form.Refresh()
            }
            'Run Selection'    {GO -SelectionRun}
            'Run'              {GO}
        }
    }
}
Function Handle-MousePosGet{
    $PH = [Cons.Curs]::GPos()
    
    $XCoord.Value = $PH.X
    $YCoord.Value = $PH.Y
    $MouseCoordsBox.Text = ('{MOUSE '+$PH.X+','+$PH.Y+'}')
            
    $Bounds = [GUI.Rect]::R($PH.X-8,$PH.Y-8,16,16)
    $BMP = ([Cons.Act]::CrI([System.Drawing.Bitmap],@($Bounds.Width, $Bounds.Height)))
    ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
    
    $PHPix = $BMP.GetPixel(8,8)
    $PixColorBox.Text = $PHPix.Name.ToUpper()
    $PixColorBox.BackColor = $PHPix
    $PHLum = [Math]::Sqrt(
        $PHPix.R * $PHPix.R * 0.299 +
        $PHPix.G * $PHPix.G * 0.587 +
        $PHPix.B * $PHPix.B * 0.114
    )
    If($PHLum -gt 130){
        $PixColorBox.ForeColor = [System.Drawing.Color]::Black
        $CenterDot.BackColor = [System.Drawing.Color]::Black
    }Else{
        $PixColorBox.ForeColor = [System.Drawing.Color]::White
        $CenterDot.BackColor = [System.Drawing.Color]::White
    }
    $BMPBig = ([Cons.Act]::CrI([System.Drawing.Bitmap],@(120, 106)))
    $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
    $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $GraphicsBig.DrawImage($BMP,0,0,120,106)
    $ZoomPanel.BackgroundImage = $BMPBig
}
Function Handle-TextBoxKey($KeyCode, $MainObj, $BoxType, $Shift, $Control, $Alt){
    If($KeyCode -eq 'F1'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '<\\# '
    }ElseIf($KeyCode -eq 'F2'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '\\#> '
    }ElseIf($KeyCode -eq 'F3'){
        $PrevStart = $MainObj.SelectionStart
        $PrevLength = $MainObj.SelectionLength
        
        $MainObj.SelectionStart = $MainObj.GetFirstCharIndexOfCurrentLine()
        $MainObj.SelectionLength = 4
        If($MainObj.SelectedText -eq '\\# '){
            $MainObj.SelectedText = ''
            $MainObj.SelectionStart = $PrevStart-4
        }Else{
            $MainObj.SelectionLength = 0
            $MainObj.SelectedText = '\\# '
            $MainObj.SelectionStart = $PrevStart+4
        }
        $MainObj.SelectionLength = $PrevLength
    }ElseIf($KeyCode -eq 'F4' -AND !$Alt){
        Switch($BoxType){
            'Commands'{
                $MainObj.SelectedText = ('{IF ()}'+$NL+'{ELSE}'+$NL+'{FI}')
            }
            'Functions'{
                $MainObj.Text+=($NL+'{FUNCTION NAME RENAMETHIS}'+$NL+$Tab+$NL+'{FUNCTION END}'+$NL)
                $MainObj.SelectionStart = ($MainObj.Text.Length - 1)
            }
        }
    }ElseIf($KeyCode -eq 'F5'){
        GO
    }ElseIf($KeyCode -eq 'F6'){
        $PH = [Cons.Curs]::GPos()
        $XCoord.Value = $PH.X
        $YCoord.Value = $PH.Y
        #$MainObj.SelectionLength = 0
        $MainObj.SelectedText = ('{MOUSE '+((($PH).ToString().Substring(3) -replace 'Y=').TrimEnd('}'))+'}'+$NL)
    }ElseIf($KeyCode -eq 'F7'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '{WAIT M 100}'
    }ElseIf($KeyCode -eq 'F8'){
        GO -SelectionRun
    }ElseIf($KeyCode -eq 'F10'){
        Try{$_.SuppressKeyPress = $True}Catch{}
        $Form.Enabled = $False
        #$PrevFormText = (($Form.Text -replace '\*$')+'*')
        $PrevFormText = $Form.Text
        #$PrevFormText = $Form.Text
        
        $PrevSaved = $Script:Saved
        #$Script:Saved = $False
        $Form.Text = 'PARSING'
        $Form.Refresh()
        #[Void][Cons.WindowDisp]::ShowWindow($Form.Handle, 0)
        #$Script:Saved = $False
        $TempSelectionIndex = $MainObj.SelectionStart
        $TempSelectionLength = $MainObj.SelectionLength
        $MainObj.SelectionStart = 0
        $MainObj.SelectionLength = $MainObj.Text.Length
        $MainObj.SelectionColor = [System.Drawing.Color]::Black
        
        $DetectedFunctions = @()
        #$Commands.Text.Split($NL).Where({$_ -match '{FUNCTION NAME '}) | %{$DetectedFunctions+=$_.Replace('FUNCTION NAME ','').Trim()}
        ForEach($Func in $Commands.Text.Split($NL).Where({$_ -match '{FUNCTION NAME '})){
            $DetectedFunctions+=$Func.Replace('FUNCTION NAME ','').Trim()
        }
        ForEach($Func in $FunctionsBox.Text.Split($NL).Where({$_ -match '{FUNCTION NAME '})){
            $DetectedFunctions+=$Func.Replace('FUNCTION NAME ','').Trim()
        }
        
        $LineCount = 0
        $Commented = $False
        ForEach($Line in $MainObj.Lines){
            If($Line -match '<\\\\#'){$Commented = $True}
            If($Line -match '\\\\#>'){$Commented = $False}
            $PreviousLineStart = $MainObj.GetFirstCharIndexFromLine($LineCount)
            $MainObj.SelectionStart = $PreviousLineStart
            
            $PreviousLength = $Line.Length
            $MainObj.SelectionLength = $PreviousLength
            $TrimmedLine = $Line.Trim()
            If($Commented -OR (($Line -replace '^\s*?') -match '\\\\#')){
                $MainObj.SelectionColor = [System.Drawing.Color]::DarkGray
            }ElseIf(!$Commented){
                If($TrimmedLine -match '{VAR \S*?='){
                    $MainObj.SelectionColor = [System.Drawing.Color]::FromArgb([Convert]::ToInt32("0xFFFF4500", 16))
                }ElseIf(($TrimmedLine -match '{IF \(') -OR ($TrimmedLine -match '{ELSE}') -OR ($TrimmedLine -match '{FI}') -OR ($TrimmedLine -match '{WHILE \(') -OR ($TrimmedLine -match '{END WHILE}')){
                    $MainObj.SelectionColor = [System.Drawing.Color]::DarkBlue
                }ElseIf($DetectedFunctions.Contains(($TrimmedLine -replace ' \d*')) -OR ($TrimmedLine -match 'FUNCTION NAME ') -OR ($TrimmedLine -match 'FUNCTION END')){
                    $MainObj.SelectionColor = [System.Drawing.Color]::Blue
                }ElseIf(
                    ($TrimmedLine -match '^{POWER ') -OR `
                    ($TrimmedLine -match '^{CMD ') -OR `
                    ($TrimmedLine -match '^{PAUSE') -OR `
                    ($TrimmedLine -match '^{FOREACH ') -OR `
                    ($TrimmedLine -match '^{SETCON') -OR `
                    ($TrimmedLine -match '^{SETCLIP ') -OR `
                    ($TrimmedLine -match '^{BEEP ') -OR `
                    ($TrimmedLine -match '^{FLASH') -OR `
                    ($TrimmedLine -match '^{WAIT ?(M )?\d*') -OR `
                    ($TrimmedLine -match '^{[/\\]?HOLD') -OR `
                    ($TrimmedLine -match '^{MOUSE ') -OR `
                    ($TrimmedLine -match '^{[LRM]?MOUSE') -OR `
                    ($TrimmedLine -match '^{RESTART') -OR `
                    ($TrimmedLine -match '^{REFOCUS') -OR `
                    ($TrimmedLine -match '^{REMOTE ') -OR `
                    ($TrimmedLine -match '^{CLEARVAR') -OR `
                    ($TrimmedLine -match '^{QUIT') -OR `
                    ($TrimmedLine -match '^{EXIT') -OR `
                    ($TrimmedLine -match '^{CD ') -OR `
                    ($TrimmedLine -match '^{SCRNSHT ') -OR `
                    ($TrimmedLine -match '^{FOCUS ') -OR `
                    ($TrimmedLine -match '^{SETWIND ') -OR `
                    ($TrimmedLine -match '^{MIN ') -OR `
                    ($TrimmedLine -match '^{MAX ') -OR `
                    ($TrimmedLine -match '^{HIDE ') -OR `
                    ($TrimmedLine -match '^{SHOW ') -OR `
                    ($TrimmedLine -match '^{SETWINDTEXT ') -OR `
                    ($TrimmedLine -match '^{ECHO .*?')
                ){
                    $MainObj.SelectionColor = [System.Drawing.Color]::DarkRed
                }
                $DepthCount = 0
                $StartedParse = $False

                $CurrentCount = 0
                $StrBldr = ''
                ForEach($Char in $Line.ToCharArray()){
                    $CurrentCount++
                    $StrBldr+=$Char
                    If($_ -match '{' -AND !$StartedParse){$StrBldr = '{'}
                    If($StartedParse){
                        $MainObj.SelectionLength++
                        If($Char -match '{'){
                            $DepthCount++
                        }ElseIf($_ -match '}'){
                            $DepthCount--
                        }
                    }
                    If(
                        !$StartedParse -AND `
                        (($StrBldr -match '^{LEN ') -OR `
                        ($StrBldr -match '^{ABS ') -OR `
                        ($StrBldr -match '^{POW ') -OR `
                        ($StrBldr -match '^{SIN ') -OR `
                        ($StrBldr -match '^{COS ') -OR `
                        ($StrBldr -match '^{TAN ') -OR `
                        ($StrBldr -match '^{RND ') -OR `
                        ($StrBldr -match '^{FLR ') -OR `
                        ($StrBldr -match '^{SQT ') -OR `
                        ($StrBldr -match '^{CEI ') -OR `
                        ($StrBldr -match '^{MOD ') -OR `
                        ($StrBldr -match '^{EVAL ') -OR `
                        ($StrBldr -match '^{PWD') -OR `
                        ($StrBldr -match '^{MANIP ') -OR `
                        ($StrBldr -match '^{GETCON ') -OR `
                        ($StrBldr -match '^{FINDVAR ') -OR `
                        ($StrBldr -match '^{GETPROC ') -OR `
                        ($StrBldr -match '^{FINDIMG ') -OR `
                        ($StrBldr -match '^{GETWIND ') -OR `
                        ($StrBldr -match '^{GETWINDTEXT ') -OR `
                        ($StrBldr -match '^{GETFOCUS') -OR `
                        ($StrBldr -match '^{GETSCREEN') -OR `
                        ($StrBldr -match '^{READIN ') -OR `
                        ($StrBldr -match '^{PID') -OR `
                        ($StrBldr -match '^{WHOAMI') -OR `
                        ($StrBldr -match '^{DATETIME') -OR `
                        ($StrBldr -match '^{RAND ') -OR `
                        ($StrBldr -match '^{GETCLIP') -OR `
                        ($StrBldr -match '^{GETMOUSE') -OR `
                        ($StrBldr -match '^{GETPIX '))
                    ){
                        $StartedParse = $True
                        $DepthCount = 1
                        $MainObj.SelectionStart=($PreviousLineStart+$CurrentCount-$StrBldr.Length)
                        $MainObj.SelectionLength = ($StrBldr.Length)
                        $StrBldr = ''
                    }
                    If($StartedParse -AND ($DepthCount -le 0)){
                        $DepthCount = 0
                        $StartedParse = $False
                        $MainObj.SelectionColor = [System.Drawing.Color]::FromArgb([Convert]::ToInt32("0xFF008080", 16))
                    }
                }
                $CharCount = $PreviousLineStart
                ForEach($SplitLine in $Line.Split('{}')){
                    $CharCount+=($SplitLine.Length+1)
                    $MainObj.SelectionStart = $PreviousLineStart
                    $MainObj.SelectionLength = $PreviousLength
                    If(
                        ($SplitLine -match 'VAR [\w\d_:]*?$') -OR `
                        ($SplitLine -match 'VAR [\w\d_:]*?\+\+$') -OR `
                        ($SplitLine -match 'VAR [\w\d_:]*?--$')
                    ){
                        $MainObj.SelectionStart=($CharCount-($SplitLine.Length+2))
                        $MainObj.SelectionLength=($SplitLine.Length+2)
                        $MainObj.SelectionColor = [System.Drawing.Color]::FromArgb([Convert]::ToInt32("0xFFFF4500", 16))
                    }
                }
            }
            $LineCount++
        }
                    
        $MainObj.SelectionStart = $TempSelectionIndex
        $MainObj.SelectionLength = $TempSelectionLength
        $Form.Enabled = $True
        #[Void][Cons.WindowDisp]::ShowWindow($Form.Handle, 1)
        
        $Form.Text = $PrevFormText
        $Script:Saved = $PrevSaved
        #$Form.Text+='*'
        $Form.Refresh()
    }ElseIf($KeyCode -eq 'F11'){
        Save-Profile
    }ElseIf($KeyCode -eq 'TAB'){
        If($MainObj.SelectionLength -gt 0){
            $Start = $MainObj.GetLineFromCharIndex($MainObj.SelectionStart)
            $End = $MainObj.GetLineFromCharIndex($MainObj.SelectionStart + $MainObj.SelectionLength)
            $TempSelectionIndex = $MainObj.GetFirstCharIndexFromLine($Start)
            $TempSelectionLength = $MainObj.SelectionLength
            If($_.Shift -AND ($MainObj.SelectedText -match ($Tab))){
                $TempLines = $MainObj.Lines
                $Start..$End | %{
                    If($TempLines[$_].Length -gt 1 -AND [Int][Char]$TempLines[$_].Substring(0,1) -eq 9){
                        $TempLines[$_] = $TempLines[$_].Substring(1, ($TempLines[$_].Length - 1))
                        $TempSelectionLength--
                    }ElseIf($TempLines[$_].Length -eq 1 -AND [Int][Char]$TempLines[$_].Substring(0,1) -eq 9){
                        $TempLines[$_] = ''
                        $TempSelectionLength--
                    }
                }
                $MainObj.Lines = $TempLines
            }ElseIf(!$_.Shift){
                $TempLines = $MainObj.Lines
                $Start..($End - 1) | %{$TempLines[$_] = ($Tab + $TempLines[$_]); $TempSelectionLength++}
                $MainObj.Lines = $TempLines
            }
            If($TempSelectionLength -lt 0){$TempSelectionLength = 0}
            $MainObj.SelectionStart = $TempSelectionIndex
            $MainObj.SelectionLength = $TempSelectionLength
            $_.SuppressKeyPress = $True
        }
    }ElseIf($KeyCode -eq 'S' -AND $Control){
        Save-Profile
    }
}
Function Check-Saved{
    $Response = 'No'
    If(!$Script:Saved -OR ($Script:LoadedProfile -eq $Null -AND ($Commands.Text -OR $FunctionsBox.Text))){
        If($Script:LoadedProfile){
            $Response = [System.Windows.Forms.MessageBox]::Show('You have not saved. Would you like to save now?','Save?','YesNoCancel')
            If($Response -eq 'Yes'){
                $Form.Text = ($Form.Text -replace '\*$')
                #$TempName = ($Profile.Text -replace '^Working Profile: ')
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
                #$SaveAsProfText.Text = ''
            }
        }Else{
            $Response = [System.Windows.Forms.MessageBox]::Show('You have not saved this profile yet. Would you like to create a new save?','Create New Save?','YesNoCancel')
            If($Response -eq 'Yes'){
                $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
                If($PH){
                    $Form.Text = ('Pikl - ' + $PH)
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
            }
        }
    }
    Return $Response
}
Function Save-Profile{
    If($Script:LoadedProfile){
        $Form.Text = ($Form.Text -replace '\*$')
        #$TempName = ($Profile.Text -replace '^Working Profile: ')
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
        #$SaveAsProfText.Text = ''
    }Else{
        If([System.Windows.Forms.MessageBox]::Show('You have not saved this profile yet. Would you like to create a new save?','Create New Save?','YesNoCancel') -eq 'Yes'){
            $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
            If($PH){
                $Form.Text = ('Pikl - ' + $PH)
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
        }
    }
}
If($Host.Name -match 'Console'){
    [Console]::Title = 'Pikl'
    #[Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
    [Void][Cons.WindowDisp]::Visual()
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
                $TmpCli = ([Cons.Act]::CrI([System.Net.Sockets.TCPClient],@($IP,$Port)))
                
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
    $MouseForm = New-Object System.Windows.Forms.Form
    $MouseForm.Size = (New-Object System.Drawing.Size -ArgumentList (50,50))
    $MouseForm.Text = 'Mouse Indicator'
    $Red = [System.Drawing.Color]::Red
    $DarkRed = [System.Drawing.Color]::DarkRed
    $Pointer = (New-Object System.Windows.Forms.Label)
    $Pointer.Size = (New-Object System.Drawing.Size -ArgumentList (50,50))
    $Pointer.Location = (New-Object System.Drawing.Size -ArgumentList (-10,0))
    $Pointer.BackColor = $DarkRed
    $Pointer.ForeColor = $Red
    $Pointer.Font = (New-Object System.Drawing.Font -ArgumentList ('Lucida Console',50,[System.Drawing.FontStyle]::Bold))
    $Pointer.Text = '←'
    $Pointer.Parent = $MouseForm
    $MouseForm.BackColor = $DarkRed
    $MouseForm.TransparencyKey = $DarkRed
    $MouseForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $MouseForm.TopMost = $True
    $MouseForm.Add_Closing({[system.Windows.Forms.Application]::Exit()})
    [System.Action[System.Windows.Forms.Form,HashTable]]$Act = {
        Param($F,$Sync)
	$Activated = $False
        $PrevMouseShow = $False
        While(!$Sync.Kill){
            Try{
	        If($Sync.ShowMouse){
                    If($Sync.ShowMouse -ne $PrevShowMouse){
                        $F.Show()
			If(!$Activated){$F.Activate();$Activated = $True}
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
                $F.Update()
	    }Catch{}
            [System.Threading.Thread]::Sleep(10)
        }
        $F.Close()
	$F.Dispose()
    }
    $MouseForm.Show()
    $MouseFormHandle = $MouseForm.BeginInvoke($Act,$MouseForm,$SyncHash)
    $MouseForm.Hide()
    $MouseAppContext = ([Cons.Act]::CrI([System.Windows.Forms.ApplicationContext],@()))
    [System.Windows.Forms.Application]::Run($MouseAppContext)
}) | Out-Null
$MouseIndPow.AddParameter('SyncHash', $SyncHash) | Out-Null
$MouseIndHandle = $MouseIndPow.BeginInvoke()
$Form = ([Cons.Act]::CrI([GUI.F],@(470, 500, 'Pikl')))
$Form.MinimumSize = [GUI.SP]::SI(470,500)
$TabController = ([Cons.Act]::CrI([GUI.TC],@(405, 400, 25, 7)))
    $TabPageComm = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0,'Main')))
        $TabControllerComm = ([Cons.Act]::CrI([GUI.TC],@(0, 0, 0, 0)))
        $TabControllerComm.Dock = 'Fill'
        $TabControllerComm.Add_SelectedIndexChanged({
            Switch($This.SelectedTab.Text){
                'Commands'  {$Commands.Focus()}
                'Functions' {$FunctionsBox.Focus()}
            }
        })
            $TabPageCommMain = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Commands')))
                $Commands = ([Cons.Act]::CrI([GUI.RTB],@(0, 0, 0, 0, '')))
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
                        $M = [Cons.Curs]::Gpos()
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
            $TabPageFunctMain = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Functions')))
                $FunctionsBox = ([Cons.Act]::CrI([GUI.RTB],@(0, 0, 0, 0, '')))
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
                        $M = [Cons.Curs]::Gpos()
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
            $TabPageHelper = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Helpers')))
                $TabHelperSub = ([Cons.Act]::CrI([GUI.TC],@(0, 0, 0, 0)))
                $TabHelperSub.Dock = 'Fill'
                $TabHelperSub.SizeMode = 'Fixed'
                $TabHelperSub.DrawMode = 'OwnerDrawFixed'
                $TabHelperSub.Add_DrawItem({
                    $PHText = $This.TabPages[$_.Index].Text
                    
                    $PHRect = $This.GetTabRect($_.Index)
                    $PHRect = ([Cons.Act]::CrI([System.Drawing.RectangleF],@($PHRect.X,$PHRect.Y,$PHRect.Width,$PHRect.Height)))
                    $PHBrush = ([Cons.Act]::CrI([System.Drawing.SolidBrush],@([System.Drawing.Color]::Black)))
                    $PHStrForm = ([Cons.Act]::CrI([System.Drawing.StringFormat],@()))
                    $PHStrForm.Alignment = [System.Drawing.StringAlignment]::Center
                    $PHStrForm.LineAlignment = [System.Drawing.StringAlignment]::Center
                    $_.Graphics.DrawString($PHText, $This.Font, $PHBrush, $PHRect, $PHStrForm)
                })
                $TabHelperSub.ItemSize = [GUI.SP]::SI(25,75)
                $TabHelperSub.Alignment = [System.Windows.Forms.TabAlignment]::Left
                    $TabHelperSubMouse = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Mouse/Pix')))
                        $GetMouseCoords = ([Cons.Act]::CrI([GUI.B],@(110, 25, 10, 25, 'Mouse Inf')))
                        $GetMouseCoords.Add_MouseDown({$This.Text = 'Drag Mouse'})
                        $GetMouseCoords.Add_MouseUp({$This.Text = 'Mouse Inf'})
                        $GetMouseCoords.Add_MouseMove({
                            If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){
                                Handle-MousePosGet; $Form.Refresh()
                            }
                        })
                        $GetMouseCoords.Parent = $TabHelperSubMouse
                        $MouseCoordLabel = ([Cons.Act]::CrI([GUI.L],@(110, 10, 130, 10, 'Mouse Coords:')))
                        $MouseCoordLabel.Parent = $TabHelperSubMouse
                        $MouseCoordsBox = ([Cons.Act]::CrI([GUI.TB],@(140, 25, 130, 25, '')))
                        $MouseCoordsBox.ReadOnly = $True
                        $MouseCoordsBox.Multiline = $True
                        $MouseCoordsBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                        $MouseCoordsBox.Parent = $TabHelperSubMouse
                        $MouseManualLabel = ([Cons.Act]::CrI([GUI.L],@(100, 10, 10, 60, 'Manual Move:')))
                        $MouseManualLabel.Parent = $TabHelperSubMouse
                        $XCoord = ([Cons.Act]::CrI([GUI.NUD],@(50, 25, 10, 75)))
                        $XCoord.Maximum = 99999
                        $XCoord.Minimum = -99999
                        $XCoord.Add_ValueChanged({[Cons.Curs]::SPos($This.Value,$YCoord.Value);Handle-MousePosGet})
                        $XCoord.Add_KeyUp({
                            If($_.KeyCode -eq 'Return'){
                                [Cons.Curs]::SPos($This.Value,$YCoord.Value)
                                Handle-MousePosGet
                            }
                        })
                        $XCoord.Parent = $TabHelperSubMouse
                
                        $YCoord = ([Cons.Act]::CrI([GUI.NUD],@(50, 25, 70, 75)))
                        $YCoord.Maximum = 99999
                        $YCoord.Minimum = -99999
                        $YCoord.Add_ValueChanged({[Cons.Curs]::SPos($XCoord.Value,$This.Value);Handle-MousePosGet})
                        $YCoord.Add_KeyUp({
                            If($_.KeyCode -eq 'Return'){
                                [Cons.Curs]::SPos($XCoord.Value,$This.Value)
                                Handle-MousePosGet
                            }
                        })
                        $YCoord.Parent = $TabHelperSubMouse
                        $PixColorLabel = ([Cons.Act]::CrI([GUI.L],@(110, 10, 130, 60, 'HexVal (ARGB):')))
                        $PixColorLabel.Parent = $TabHelperSubMouse
                        $PixColorBox = ([Cons.Act]::CrI([GUI.TB],@(140, 25, 130, 75, '')))
                        $PixColorBox.ReadOnly = $True
                        $PixColorBox.Multiline = $True
                        $PixColorBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                        $PixColorBox.Parent = $TabHelperSubMouse
                        $LeftMouseBox = ([Cons.Act]::CrI([GUI.B],@(135,25,10,110,'Left Click')))
                        $LeftMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [Cons.MouseEvnt]::mouse_event(2, 0, 0, 0, 0)
                                [Cons.MouseEvnt]::mouse_event(4, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $LeftMouseBox.Parent = $TabHelperSubMouse
                        $MiddleMouseBox = ([Cons.Act]::CrI([GUI.B],@(135,25,10,152,'Middle Click')))
                        $MiddleMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [Cons.MouseEvnt]::mouse_event(32, 0, 0, 0, 0)
                                [Cons.MouseEvnt]::mouse_event(64, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $MiddleMouseBox.Parent = $TabHelperSubMouse
                        $RightMouseBox = ([Cons.Act]::CrI([GUI.B],@(135,25,10,194,'Right Click')))
                        $RightMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [Cons.MouseEvnt]::mouse_event(8, 0, 0, 0, 0)
                                [Cons.MouseEvnt]::mouse_event(16, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $RightMouseBox.Parent = $TabHelperSubMouse
                        $ZoomPanel = ([Cons.Act]::CrI([GUI.GB],@(115,115,155,105,'')))
                        $ZoomPanel.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
                        $ZoomPanel.Parent = $TabHelperSubMouse
                        $GraphicFixPanel = ([Cons.Act]::CrI([GUI.P],@(115,5,155,105)))
                        $GraphicFixPanel.BackColor = $Form.BackColor
                        $GraphicFixPanel.Parent = $TabHelperSubMouse
                        $GraphicFixPanel.BringToFront()
                        
                        $CenterDot = ([Cons.Act]::CrI([GUI.P],@(8,8,209,159)))
                        $CenterDot.BackColor = [System.Drawing.Color]::Black
                        $CenterDot.Parent = $TabHelperSubMouse
                        $CenterDot.BringToFront()
                        $Tape = ([Cons.Act]::CrI([GUI.B],@(260, 25, 10, 240, 'Measuring Tape')))
                        $Tape.Add_Click({
                            $TapePow = [Powershell]::Create()
                            $TapeRun = [RunspaceFactory]::CreateRunspace()
                            $TapeRun.ApartmentState = [System.Threading.ApartmentState]::STA
                            $TapeRun.Open()
                            $TapePow.Runspace = $TapeRun
                            $TapePow.AddScript({
                                Add-Type -AssemblyName System.Windows.Forms
                                Add-Type -AssemblyName System.Drawing
                                $TapeForm = New-Object System.Windows.Forms.Form
                                $TapeForm.Size = New-Object System.Drawing.Size -ArgumentList (5000,5000)
                                $TapeForm.Text = 'Measuring Tape'
                                $Black = [System.Drawing.Color]::Black
                                $Red = [System.Drawing.Color]::Red
                                $Blue = [System.Drawing.Color]::Blue
                                $Green = [System.Drawing.Color]::LimeGreen
                                $DarkGray = [System.Drawing.Color]::DarkGray
                                $BlackPen = (New-Object System.Drawing.Pen -ArgumentList ($Black))
                                $RedPen = (New-Object System.Drawing.Pen -ArgumentList ($Red))
                                $BluePen = (New-Object System.Drawing.Pen -ArgumentList ($Blue))
                                $GreenBrush = (New-Object System.Drawing.SolidBrush -ArgumentList ($Green))
                                $Graphics = [System.Drawing.Graphics]::FromHwnd($TapeForm.Handle)
                                $TapeForm.Add_Paint({$Graphics.FillRectangle($GreenBrush, 70, 70, 5000, 5000)})
                                #$TapeForm.Add_Paint({$Graphics.DrawLine($BlackPen, 40, 40, 5000, 40)})
                                #$TapeForm.Add_Paint({$Graphics.DrawLine($BlackPen, 40, 40, 40, 5000)})
                                $OriginLabel = (New-Object System.Windows.Forms.Label)
                                $OriginLabel.Size = (New-Object System.Drawing.Size(70,25))
                                $OriginLabel.Location = (New-Object System.Drawing.Size(10,10))
                                $OriginLabel.BackColor = [System.Drawing.Color]::Transparent
                                $OriginLabel.Text = '0x0 Loc:'+[System.Environment]::NewLine+([String]($TapeForm.Location.X+83)+','+[String]($TapeForm.Location.Y+106))
                                $OriginLabel.Parent = $TapeForm
                                $OffSet = 50
                                0..5000 | ?{!($_ % ($OffSet)) -OR !($_ % (($OffSet)/2)) -OR !($_ % (($OffSet)/10))} | %{
                                    $PH = ($_+75)
                                    If(!($_ % ($OffSet))){
                                        $LocationLabel = (New-Object System.Windows.Forms.Label)
                                        $LocationLabel.Size = (New-Object System.Drawing.Size(30,15))
                                        $LocationLabel.Location = (New-Object System.Drawing.Size(($PH-5), 40))
                                        #$LocationLabel.BackColor = [System.Drawing.Color]::Transparent
                                        $LocationLabel.Text = $_
                                        $LocationLabel.Parent = $TapeForm
                                        $LocationLabel = (New-Object System.Windows.Forms.Label)
                                        $LocationLabel.Size = (New-Object System.Drawing.Size(30,15))
                                        $LocationLabel.Location = (New-Object System.Drawing.Size(22, ($PH-5)))
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
                                $TapeForm.Size = (New-Object System.Drawing.Size(500,500))
                                
                                $Box = (New-Object System.Windows.Forms.Panel)
                                $Box.Size = (New-Object System.Drawing.Size -ArgumentList (25,25))
                                $Box.Location = (New-Object System.Drawing.Size -ArgumentList (($TapeForm.Width-41),($TapeForm.Height-64)))
                                $Box.BackColor = $DarkGray
                                $Box.Parent = $TapeForm
                                $TapeForm.Add_SizeChanged({
                                    $Box.Location = (New-Object System.Drawing.Size -ArgumentList (($This.Width-41),($This.Height-64)))
                                })
                                $TapeForm.Add_LocationChanged({
                                    $OriginLabel.Text = '0x0 Loc:'+[System.Environment]::NewLine+([String]($This.Location.X+83)+','+[String]($This.Location.Y+106))
                                })
                                $TapeForm.TransparencyKey = $Green
                                $TapeForm.BackColor = $DarkGray
                                $TapeForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::SizableToolWindow
                                [System.Windows.Forms.Application]::Run($TapeForm)
                            })
                            $TapePow.BeginInvoke() | Out-Null
                        })
                        $Tape.Parent = $TabHelperSubMouse
                    $TabHelperSubMouse.Parent = $TabHelperSub
                    $TabHelperSubSystem = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Sys/Proc')))
                        $ScreenInfoLabel = ([Cons.Act]::CrI([GUI.L],@(110, 15, 10, 8, 'Display Info:')))
                        $ScreenInfoLabel.Parent = $TabHelperSubSystem
                        $ScreenInfoBox = ([Cons.Act]::CrI([GUI.RTB],@(285, 95, 10, 25, '')))
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
                        $ProcInfoLabel = ([Cons.Act]::CrI([GUI.L],@(110,15,10,136,'Process Info:')))
                        $ProcInfoLabel.Parent = $TabHelperSubSystem
                        $GetProcInfo = ([Cons.Act]::CrI([GUI.B],@(140, 23, 125, 129, 'Get Proc Inf')))
                        $GetProcInfo.Add_MouseDown({If($_.Button.ToString() -eq 'Left'){$This.Text = 'Click on Proc'}ElseIf($_.Button.ToString() -eq 'Right'){$ProcInfoBox.Text = ''}})
                        $GetProcInfo.Add_LostFocus({
                            If($This.Text -ne 'Get Proc Inf'){
                                $This.Text = 'Get Proc Inf'
                                $PHFocussedHandle = [Cons.WindowDisp]::GetForegroundWindow()
                                $PHProcInfo = (PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle})
                                $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHFocussedHandle)
                                $PHString = ([Cons.Act]::CrI([System.Text.StringBuilder],@(($PHTextLength + 1))))
                                [Void]([Cons.WindowDisp]::GetWindowText($PHFocussedHandle, $PHString, $PHString.Capacity))
                                $PHRect = [GUI.Rect]::E
                                [Void]([Cons.WindowDisp]::GetWindowRect($PHFocussedHandle,[Ref]$PHRect))
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
                        $ProcInfoBox = ([Cons.Act]::CrI([GUI.RTB],@(285, 160, 10, 155, '')))
                        $ProcInfoBox.Multiline = $True
                        $ProcInfoBox.ScrollBars = 'Both'
                        $ProcInfoBox.WordWrap = $False
                        $ProcInfoBox.ReadOnly = $True
                        $ProcInfoBox.Text = ''
                        $ProcInfoBox.Parent = $TabHelperSubSystem
                    $TabHelperSubSystem.Parent = $TabHelperSub
                    $TabPageDebug = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Debug')))
                        $GetFuncts = ([Cons.Act]::CrI([GUI.B],@(150, 25, 10, 10, 'Display Functions')))
                        $GetFuncts.Add_Click({
                            $Script:FuncHash.Keys | Sort | %{
                                [System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:FuncHash.$_ + $NL + $NL)
                                [System.Console]::WriteLine($NL * 3)
                            }
                        })
                        $GetFuncts.Parent = $TabPageDebug
                        $GetVars = ([Cons.Act]::CrI([GUI.B],@(150, 25, 10, 35, 'Display Variables')))
                        $GetVars.Add_Click({
                            $Script:VarsHash.Keys | Sort -Unique | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{
                                [System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:VarsHash.$_ + $NL + $NL)
                                [System.Console]::WriteLine($NL * 3)
                            }
                        })
                        $GetVars.Parent = $TabPageDebug
                        $ClearCons = ([Cons.Act]::CrI([GUI.B],@(150, 25, 10, 60, 'Clear Console')))
                        $ClearCons.Add_Click({Cls; $PseudoConsole.Text = ''})
                        $ClearCons.Parent = $TabPageDebug
                        $PseudoConsole = ([Cons.Act]::CrI([GUI.RTB],@(285, 165, 10, 110, '')))
                        $PseudoConsole.ReadOnly = $True
                        $PseudoConsole.ScrollBars = 'Both'
                        #$PseudoConsole.ForeColor = [System.Drawing.Color]::FromArgb(0xFFF5F5F5)
                        #$PseudoConsole.BackColor = [System.Drawing.Color]::FromArgb(0xFF012456)
                        $pseudoConsole.Parent = $TabPageDebug
                        $SingleCMD = ([Cons.Act]::CrI([GUI.RTB],@(185, 20, 10, 300, '')))
                        $SingleCMD.AcceptsTab = $True
                        $SingleCMD.Parent = $TabPageDebug
                        $SingleGO = ([Cons.Act]::CrI([GUI.B],@(90, 22, 205, 298, 'Run Line')))
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
    $TabPageAdvanced = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0,'File')))
        $TabControllerAdvanced = ([Cons.Act]::CrI([GUI.TC],@(0, 0, 10, 10)))
        $TabControllerAdvanced.Dock = 'Fill'
        $TabControllerAdvanced.SizeMode = 'Fixed'
        $TabControllerAdvanced.DrawMode = 'OwnerDrawFixed'
        $TabControllerAdvanced.Add_DrawItem({
            $PHText = $This.TabPages[$_.Index].Text
                    
            $PHRect = $This.GetTabRect($_.Index)
            $PHRect = ([Cons.Act]::CrI([System.Drawing.RectangleF],@($PHRect.X,$PHRect.Y,$PHRect.Width,$PHRect.Height)))
            $PHBrush = ([Cons.Act]::CrI([System.Drawing.SolidBrush],@([System.Drawing.Color]::Black)))
            $PHStrForm = ([Cons.Act]::CrI([System.Drawing.StringFormat],@()))
            $PHStrForm.Alignment = [System.Drawing.StringAlignment]::Center
            $PHStrForm.LineAlignment = [System.Drawing.StringAlignment]::Center
            $_.Graphics.DrawString($PHText, $This.Font, $PHBrush, $PHRect, $PHStrForm)
        })
        $TabControllerAdvanced.ItemSize = [GUI.SP]::SI(25,75)
        $TabControllerAdvanced.Alignment = [System.Windows.Forms.TabAlignment]::Left
            $TabPageProfiles = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0,'Save/Load')))
                $Profile = ([Cons.Act]::CrI([GUI.L],@(275, 15, 10, 10, 'Working Profile: None/Prev Text')))
                $Profile.Parent = $TabPageProfiles
                $SavedProfilesLabel = ([Cons.Act]::CrI([GUI.L],@(75, 15, 85, 36, 'Profiles:')))
                $SavedProfilesLabel.Parent = $TabPageProfiles
                $RefreshProfiles = ([Cons.Act]::CrI([GUI.B],@(75, 21, 186, 32, 'Refresh')))
                $RefreshProfiles.Add_Click({
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                    $SavedProfiles.SelectedItem = $Script:LoadedProfile})
                $RefreshProfiles.Parent = $TabPageProfiles
                $LoadProfile = ([Cons.Act]::CrI([GUI.B],@(75, 21, 10, 54, 'Load')))
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
                            $Form.Text = ('Pikl - ' + $SavedProfiles.SelectedItem)
                        }
                    }
                })
                $LoadProfile.Parent = $TabPageProfiles
                $SavedProfiles = ([Cons.Act]::CrI([GUI.CoB],@(175, 21, 85, 55)))
                $SavedProfiles.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                $SavedProfiles.Parent = $TabPageProfiles
                $QuickSave = ([Cons.Act]::CrI([GUI.B],@(75, 21, 10, 75, 'Save')))
                $QuickSave.Add_Click({[Void](Save-Profile)})
                $QuickSave.Parent = $TabPageProfiles
                $SaveProfile = ([Cons.Act]::CrI([GUI.B],@(75, 21, 10, 96, 'Save As')))
                $SaveProfile.Add_Click({
                    $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
                    If($PH){
                        $Form.Text = ('Pikl - ' + $PH)
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
                $BlankProfile = ([Cons.Act]::CrI([GUI.B],@(75, 21, 10, 132, 'New')))
                $BlankProfile.Add_Click({
                    If((Check-Saved) -ne 'Cancel'){
                        $Profile.Text = 'Working Profile: None/Prev Text'
                        $Script:LoadedProfile = $Null
                    
                        $SavedProfiles.SelectedIndex = -1
                        $Commands.Text = ''
                        $FunctionsBox.Text = ''
                        $Script:Saved = $True
                        $Form.Text = 'Pikl'
                    }
                })
                $BlankProfile.Parent = $TabPageProfiles
                $ImportProfile = ([Cons.Act]::CrI([GUI.B],@(75,21,186,85,'Import')))
                $ImportProfile.Add_Click({
                    If((Check-Saved) -ne 'Cancel'){
                        $DialogO = ([Cons.Act]::CrI([System.Windows.Forms.OpenFileDialog],@()))
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
                                $Form.Text = 'Pikl*'
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
                                $Form.Text = ('Pikl - ' + $ImportedName)
                            }
                        }
                    }
                })
                $ImportProfile.Parent = $TabPageProfiles
                $ExportProfile = ([Cons.Act]::CrI([GUI.B],@(75,21,186,115,'Export')))
                $ExportProfile.Add_Click({
                    $PIK_PS1 = ([System.Windows.Forms.MessageBox]::Show('Export as executable script? Select "No" or close to save as a PIK file instead.','Export Type','YesNo') -eq 'Yes')
                    
                    $DialogS = ([Cons.Act]::CrI([System.Windows.Forms.SaveFileDialog],@()))
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
                            $Temp = ('$MainBlock = {'+$NL)
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
                            $Temp+=('$Pow = [Powershell]::Create()'+$NL)
                            $Temp+=('$Run = [RunspaceFactory]::CreateRunspace()'+$NL)
                            $Temp+=('$Run.Open()'+$NL)
                            $Temp+=('$Pow.Runspace = $Run'+$NL)
                            $Temp+=('$Pow.AddScript({'+$NL)
                            $Temp+=('    Param($SyncHash)'+$NL)
                            $Temp+=('    Add-Type -Name Win32 -Namespace API -IgnoreWarnings -MemberDefinition '+"'"+$NL)
                            $Temp+=('    [DllImport("user32.dll")]'+$NL)
                            $Temp+=('    public static extern short GetAsyncKeyState(int virtualKeyCode);'+$NL)
                            $Temp+=('    '+"'"+' -ErrorAction SilentlyContinue'+$NL)
                            $Temp+=('    While(!$SyncHash.Kill){'+$NL)
                            $Temp+=('        [System.Threading.Thread]::Sleep(50)'+$NL)
                            $Temp+=('        If([API.Win32]::GetAsyncKeyState(145)){'+$NL)
                            $Temp+=('            $SyncHash.Stop = $True'+$NL)
                            $Temp+=('            $SyncHash.Restart = $False'+$NL)
                            $Temp+=('            Try{'+$NL)
                            $Temp+=('                $IP = [String]$SyncHash.SrvIP'+$NL)
                            $Temp+=('                If($IP -match "0\.0\.0\.0"){$IP = "127.0.0.1"}'+$NL)
                            $Temp+=('                $Port = [Int]$SyncHash.SrvPort'+$NL)
                            $Temp+=('                $TmpCli = [System.Net.Sockets.TCPClient]')#This is split here to avoid regex for the backwards compatibility
                            $Temp+=('::New($IP,$Port)'+$NL)
                            $Temp+=('                $TmpCli | %{'+$NL)
                            $Temp+=('                    $_.Close()'+$NL)
                            $Temp+=('                    $_.Dispose()'+$NL)
                            $Temp+=('                }'+$NL)
                            $Temp+=('            }Catch{}'+$NL)
                            $Temp+=('            [System.Threading.Thread]::Sleep(500)'+$NL)
                            $Temp+=('        }'+$NL)
                            $Temp+=('    }'+$NL)
                            $Temp+=('}) | Out-Null'+$NL)
                            $Temp+=('$Pow.AddParameter('+"'"+'SyncHash'+"'"+', $SyncHash) | Out-Null'+$NL)
                            $Temp+=('$Pow.BeginInvoke() | Out-Null'+$NL)
                            $Temp+=('$ShowCons = @{Checked=$True}'+$NL)
                            $Temp+=('$ScriptedCMDs = '+[Char]64+"'"+$NL)
                            $Temp+=($FunctionsBox.Text+$NL)
                            $Temp+=($Commands.Text+$NL)
                            $Temp+=("'"+[Char]64+$NL)
                            $Temp+=('GO -InlineCommand $ScriptedCMDs'+$NL)
                            $Temp+=('$UndoHash.KeyList | %{'+$NL)
                            $Temp+=('    If($_ -notmatch '+"'"+'MOUSE'+"'"+'){'+$NL)
                            $Temp+=('        [Cons.KeyEvnt]::keybd_event(([String]$_), 0, '+"'"+'&H2'+"'"+', 0)'+$NL)
                            $Temp+=('    }Else{'+$NL)
                            $Temp+=('        [Cons.MouseEvnt]::mouse_event(([Int]($_.Replace('+"'"+'MOUSE'+"'"+','+"'"+''+"'"+').Replace('+"'"+'L'+"'"+',4).Replace('+"'"+'R'+"'"+',16).Replace('+"'"+'M'+"'"+',64))), 0, 0, 0, 0)'+$NL)
                            $Temp+=('    }'+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('$SyncHash.Kill = $True'+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('If($(Try{[Void][PSObject]')#This is split here to avoid regex for the backwards compatibility
                            $Temp+=('::New()}Catch{$True})){'+$NL)
                            $Temp+=('    $MainBlock = ($MainBlock.toString().Split([System.Environment]::NewLine) | ?{$_ -ne '+"'"+''+"'"+'} | %{'+$NL)
                            $Temp+=('        If($_ -match '+"'"+']::New\('+"'"+'){'+$NL)
                            $Temp+=('            (($_.Split('+"'"+'['+"'"+')[0]+'+"'"+'(New-Object '+"'"+'+$_.Split('+"'"+'['+"'"+')[-1]+'+"'"+')'+"'"+') -replace '+"'"+']::New'+"'"+','+"'"+' -ArgumentList '+"'"+').Replace('+"'"+' -ArgumentList ()'+"'"+','+"'"+''+"'"+')'+$NL)
                            $Temp+=('        }Else{'+$NL)
                            $Temp+=('            $_'+$NL)
                            $Temp+=('        }'+$NL)
                            $Temp+=('    }) -join [System.Environment]::NewLine'+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('$MainBlock = [ScriptBlock]::Create($MainBlock)'+$NL)
                            $Temp+=('$MainBlock.Invoke($Macro)'+$NL)
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
                #$SaveNewProfLabel = ([Cons.Act]::CrI([GUI.L],@(170, 20, 10, 190, 'Save Current Profile As:')))
                #$SaveNewProfLabel.Parent = $TabPageProfiles
                #$SaveAsProfText = ([Cons.Act]::CrI([GUI.TB],@(165, 25, 10, 210, '')))
                #$SaveAsProfText.Parent = $TabPageProfiles
                <#$DelProfLabel = ([Cons.Act]::CrI([GUI.L],@(170, 20, 10, 260, 'Delete Profile:')))
                $DelProfLabel.Parent = $TabPageProfiles
                $DelProfile = ([Cons.Act]::CrI([GUI.B],@(75, 20, 186, 279, 'Delete')))
                $DelProfile.Add_Click({
                    If($Script:LoadedProfile -eq $DelProfText.Text){
                        $Profile.Text = ('Working Profile: None/Prev Text')
                        $SavedProfiles.SelectedItem = $Null
                        $Script:LoadedProfile = $Null
                        $Form.Text = ('Pikl')
                        $Script:Saved = $True
                    }
                    (Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | ?{$_.Name -eq $DelProfText.Text} | Remove-Item -Recurse -Force
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                    $DelProfText.Text = ''
                })
                $DelProfile.Parent = $TabPageProfiles
                $DelProfText = ([Cons.Act]::CrI([GUI.TB],@(165, 25, 10, 280, '')))
                $DelProfText.Parent = $TabPageProfiles#>
                $OpenFolder = ([Cons.Act]::CrI([GUI.B],@(250, 25, 10, 330, 'Open Profile Folder')))
                $OpenFolder.Add_Click({Explorer ($env:APPDATA+'\Macro\Profiles')})
                $OpenFolder.Parent = $TabPageProfiles
            $TabPageProfiles.Parent = $TabControllerAdvanced
            $TabPageServer = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Comms')))
                $ListenerLabel = ([Cons.Act]::CrI([GUI.L],@(300,15,22,10,'Listening IP/Port:')))
                $ListenerLabel.Parent = $TabPageServer
                $ServerIPOct1 = ([Cons.Act]::CrI([GUI.TB],@(30,25,25,25,'0')))
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
                $ServerIPOct2 = ([Cons.Act]::CrI([GUI.TB],@(30,25,65,25,'0')))
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
                $ServerIPOct3 = ([Cons.Act]::CrI([GUI.TB],@(30,25,105,25,'0')))
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
                $ServerIPOct4 = ([Cons.Act]::CrI([GUI.TB],@(30,25,145,25,'0')))
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
                $ServerPort = ([Cons.Act]::CrI([GUI.TB],@(75,25,190,25,'42069')))
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
                $ServerStart = ([Cons.Act]::CrI([GUI.B],@(150, 25, 25, 50, 'Start Listener')))
                $ServerStart.Add_Click({
                    $PHPort = [Int]$ServerPort.Text
                    $SyncHash.SrvPort = $PHPort
                    $SyncHash.SrvIP = ($ServerIPOct1.Text+'.'+$ServerIPOct2.Text+'.'+$ServerIPOct3.Text+'.'+$ServerIPOct4.Text)
                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Server started!'+$NL+'---------------'+$NL)
                    [Cons.WindowDisp]::ShowWindow($Form.Handle,0)
                    $MaxTime = [Int]$SrvTimeOut.Value
                    $Listener = ([Cons.Act]::CrI([System.Net.Sockets.TcpListener],@($SyncHash.SrvIP,$PHPort)))
                    $Listener.Start()
                    While(!$SyncHash.Stop){
                        $Client = $Listener.AcceptTCPClient()
                        $Listener.Stop()
                        $Stream = $Client.GetStream()
                        $Buff = New-Object Byte[] 1024
                        $CMDsIn = ''
                        $Timeout = 1
                        While(!(($CMDsIn -match '{CMDS_START}') -AND ($CMDsIn -match '{CMDS_END}')) -AND ($Timeout -lt $MaxTime)){
                            While($Stream.DataAvailable){
                                $Buff = New-Object Byte[] 1024
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
                                $Listener.Start()
                                
                                $Stream.Write([System.Text.Encoding]::UTF8.GetBytes('{COMPLETE}'),0,10)
                                $Stream.Close()
                                $Stream.Dispose()
                                $Client.Close()
                                $Client.Dispose()
                            }Catch{
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'ERROR! COULD NOT RETURN COMPLETE MESSAGE TO REMOTE END!')}
                            }
                        }
                    }
                    $Listener.Stop()
                    [Cons.WindowDisp]::ShowWindow($Form.Handle,4)
                    
                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Server stopped!'+$NL+'---------------'+$NL)
                    $Form.Refresh()
                    $SyncHash.Stop = $False
                    $SyncHash.Restart = $False
                })
                $ServerStart.Parent = $TabPageServer
                <#$RevServerStart = ([Cons.Act]::CrI([GUI.B],@(150, 25, 25, 50, 'Connect and Listen')))
                $RevServerStart.Add_Click({
                    $PHPort = [Int]$ServerPort.Text
                    $SyncHash.SrvPort = $PHPort
                    $SyncHash.SrvIP = ($ServerIPOct1.Text+'.'+$ServerIPOct2.Text+'.'+$ServerIPOct3.Text+'.'+$ServerIPOct4.Text)
                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Server started!'+$NL+'---------------'+$NL)
                    [Cons.WindowDisp]::ShowWindow($Form.Handle,0)
                    $MaxTime = [Int]$SrvTimeOut.Value
                    $Listener = ([Cons.Act]::CrI([System.Net.Sockets.TcpListener],@($SyncHash.SrvIP,$PHPort)))
                    $Listener.Start()
                    While(!$SyncHash.Stop){
                        $Client = $Listener.AcceptTCPClient()
                        $Listener.Stop()
                        $Stream = $Client.GetStream()
                        $Buff = New-Object Byte[] 1024
                        $CMDsIn = ''
                        $Timeout = 1
                        While(!(($CMDsIn -match '{CMDS_START}') -AND ($CMDsIn -match '{CMDS_END}')) -AND ($Timeout -lt $MaxTime)){
                            While($Stream.DataAvailable){
                                $Buff = New-Object Byte[] 1024
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
                                $Listener.Start()
                                
                                $Stream.Write([System.Text.Encoding]::UTF8.GetBytes('{COMPLETE}'),0,10)
                                $Stream.Close()
                                $Stream.Dispose()
                                $Client.Close()
                                $Client.Dispose()
                            }Catch{
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'ERROR! COULD NOT RETURN COMPLETE MESSAGE TO REMOTE END!')}
                            }
                        }
                    }
                    $Listener.Stop()
                    [Cons.WindowDisp]::ShowWindow($Form.Handle,4)
                    
                    [System.Console]::WriteLine($NL+'---------------'+$NL+'Server stopped!'+$NL+'---------------'+$NL)
                    $Form.Refresh()
                    $SyncHash.Stop = $False
                    $SyncHash.Restart = $False
                })
                $RevServerStart.Parent = $TabPageServer#>
                $CliTimeOutLabel = ([Cons.Act]::CrI([GUI.L],@(172, 15, 25, 200, 'Sender Timeout (s):')))
                $CliTimeOutLabel.Parent = $TabPageServer
                $CliTimeOut = ([Cons.Act]::CrI([GUI.NUD],@(150, 25, 25, 220)))
                $CliTimeOut.Maximum = 999999999
                $CliTimeOut.Minimum = 1
                $CliTimeOut.Value = 3600
                $CliTimeOut.Parent = $TabPageServer
                $SrvTimeOutLabel = ([Cons.Act]::CrI([GUI.L],@(172, 15, 25, 275, 'Listener Timeout (s):')))
                $SrvTimeOutLabel.Parent = $TabPageServer
                $SrvTimeOut = ([Cons.Act]::CrI([GUI.NUD],@(150, 25, 25, 295)))
                $SrvTimeOut.Maximum = 999999999
                $SrvTimeOut.Minimum = 1
                $SrvTimeOut.Value = 3600
                $SrvTimeOut.Parent = $TabPageServer
                $IPFormattingLabel1 = ([Cons.Act]::CrI([GUI.L],@(50,20,25,32,'    .')))
                $IPFormattingLabel1.Parent = $TabPageServer
                $IPFormattingLabel2 = ([Cons.Act]::CrI([GUI.L],@(50,20,65,32,'    .')))
                $IPFormattingLabel2.Parent = $TabPageServer
                $IPFormattingLabel3 = ([Cons.Act]::CrI([GUI.L],@(50,20,105,32,'    .')))
                $IPFormattingLabel3.Parent = $TabPageServer
                $IPFormattingLabel4 = ([Cons.Act]::CrI([GUI.L],@(50,20,147,28,'    :')))
                $IPFormattingLabel4.Parent = $TabPageServer
            $TabPageServer.Parent = $TabControllerAdvanced
            $TabPageConfig = ([Cons.Act]::CrI([GUI.TP],@(0, 0, 0, 0, 'Config')))
                $DelayLabel = ([Cons.Act]::CrI([GUI.L],@(175, 22, 10, 8, 'Keystroke Delay (ms):')))
                $DelayLabel.Parent = $TabPageConfig
                $DelayTimer = ([Cons.Act]::CrI([GUI.NUD],@(150, 25, 10, 30)))
                $DelayTimer.Maximum = 999999999
                $DelayTimer.Parent = $TabPageConfig
                $DelayTimer.BringToFront()
                $DelayCheck = ([Cons.Act]::CrI([GUI.ChB],@(150, 25, 170, 25, 'Randomize')))
                $DelayCheck.Parent = $TabPageConfig
                $DelayRandLabel = ([Cons.Act]::CrI([GUI.L],@(200, 25, 25, 60, 'Random Weight (ms):')))
                $DelayRandLabel.Parent = $TabPageConfig
                $DelayRandTimer = ([Cons.Act]::CrI([GUI.NUD],@(75, 25, 180, 55)))
                $DelayRandTimer.Maximum = 999999999
                $DelayRandTimer.Parent = $TabPageConfig
                $DelayRandTimer.BringToFront()
                $CommDelayLabel = ([Cons.Act]::CrI([GUI.L],@(175, 22, 10, 108, 'Command Delay (ms):')))
                $CommDelayLabel.Parent = $TabPageConfig
                $CommandDelayTimer = ([Cons.Act]::CrI([GUI.NUD],@(150, 25, 10, 130)))
                $CommandDelayTimer.Maximum = 999999999
                $CommandDelayTimer.Parent = $TabPageConfig
                $CommandDelayTimer.BringToFront()
                $CommDelayCheck = ([Cons.Act]::CrI([GUI.ChB],@(150, 25, 170, 125, 'Randomize')))
                $CommDelayCheck.Parent = $TabPageConfig
                $CommRandLabel = ([Cons.Act]::CrI([GUI.L],@(200, 25, 25, 160, 'Random Weight (ms):')))
                $CommRandLabel.Parent = $TabPageConfig
                $CommRandTimer = ([Cons.Act]::CrI([GUI.NUD],@(75, 25, 180, 155)))
                $CommRandTimer.Maximum = 999999999
                $CommRandTimer.Parent = $TabPageConfig
                $CommRandTimer.BringToFront()
                $ShowCons = ([Cons.Act]::CrI([GUI.ChB],@(150, 25, 10, 200, 'Show Console')))
                $ShowCons.Add_CheckedChanged({
                    If($Host.Name -match 'Console'){
                        If($This.Checked){
                            [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 1)
                        }Else{
                            [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
                        }
                    }
                })
                $ShowCons.Parent = $TabPageConfig
                $OnTop = ([Cons.Act]::CrI([GUI.ChB],@(150, 25, 10, 225, 'Always On Top')))
                $OnTop.Add_CheckedChanged({
                    $Form.TopMost = !$Form.TopMost
                })
		        $OnTop.Parent = $TabPageConfig
		
		        $Bold = ([Cons.Act]::CrI([GUI.ChB],@(150, 25, 10, 250, 'Bold Font')))
                $Bold.Add_CheckedChanged({
                    If($This.Checked){
		    	        $Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',9,[System.Drawing.FontStyle]::Bold)}
		            }Else{
		    	        $Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',9,[System.Drawing.FontStyle]::Regular)}
		            }
                })
                $Bold.Parent = $TabPageConfig
                $MousePosCheck = ([Cons.Act]::CrI([GUI.ChB],@(175, 25, 10, 275, 'Show Mouse Position')))
                $MousePosCheck.Add_CheckedChanged({
                    $SyncHash.ShowMouse = $This.Checked
                })
                $MousePosCheck.Parent = $TabPageConfig
            $TabPageConfig.Parent = $TabControllerAdvanced
        $TabControllerAdvanced.Parent = $TabPageAdvanced
    $TabPageAdvanced.Parent = $TabController
$TabController.Parent = $Form
$Help = ([Cons.Act]::CrI([GUI.B],@(25, 25, 430, -1, '?')))
$Help.Add_Click({Notepad ($env:APPDATA+'\Macro\Help.txt')})
$Help.Parent = $Form
$GO = ([Cons.Act]::CrI([GUI.B],@(200, 25, 25, 415, 'Run')))
$GO.Add_Click({If(!$WhatIfCheck.Checked){GO}Else{GO -WhatIf}})
$GO.Parent = $Form
$GOSel = ([Cons.Act]::CrI([GUI.B],@(125, 25, 230, 415, 'Run Selection')))
$GOSel.Add_Click({
    If(!$WhatIfCheck.Checked){
        GO -Selection
    }Else{
        GO -Selection -WhatIf
    }
})
$GOSel.Parent = $Form
$WhatIfCheck = ([Cons.Act]::CrI([GUI.ChB],@(80,27,365,415,'WhatIf?')))
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
$RightClickMenu = ([Cons.Act]::CrI([GUI.P],@(0,0,-1000,-1000)))
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
            $PH = ([Cons.Act]::CrI([GUI.B],@()))
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
$FindForm = ([Cons.Act]::CrI([GUI.P],@(250,110,(($Form.Width - 250) / 2),(($Form.Height - 90) / 2))))
$FindForm.BorderStyle = 'FixedSingle'
$FindForm.Visible = $False
    $FRTitle = ([Cons.Act]::CrI([GUI.L],@(300,18,25,7,'Find and Replace (RegEx):')))
    $FRTitle.Parent = $FindForm
    $FLabel = ([Cons.Act]::CrI([GUI.L],@(20,20,4,28,'F:')))
    $FLabel.Parent = $FindForm
    $Finder = ([Cons.Act]::CrI([GUI.RTB],@(200,20,25,25,'')))
    $Finder.AcceptsTab = $True
    $Finder.Parent = $FindForm
    $RLabel = ([Cons.Act]::CrI([GUI.L],@(20,20,4,53,'R:')))
    $RLabel.Parent = $FindForm
    $Replacer = ([Cons.Act]::CrI([GUI.RTB],@(200,20,25,50,'')))
    $Replacer.AcceptsTab = $True
    $Replacer.Parent = $FindForm
    $FRGO = ([Cons.Act]::CrI([GUI.B],@(95,25,25,75,'Replace All')))
        $FRGO.Add_Click({
            Switch($TabControllerComm.SelectedTab.Text){
                'Commands'  {$Commands.Text     = ($Commands.Text -replace $Finder.Text.Replace('(NEWLINE)',$NL),$Replacer.Text)}
                'Functions' {$FunctionsBox.Text = ($FunctionsBox.Text -replace $Finder.Text.Replace('(NEWLINE)',$NL),$Replacer.Text)}
            }
        })
    $FRGO.Parent = $FindForm
    $FRClose = ([Cons.Act]::CrI([GUI.B],@(95,25,130,75,'Close')))
        $FRClose.Add_Click({$This.Parent.Visible = $False})
    $FRClose.Parent = $FindForm
$FindForm.Parent = $Form
#If($Host.Name -match 'Console'){Cls}
If(Test-Path ($env:APPDATA+'\Macro\LegacySendKeys.txt')){[Cons.Send]::SetConfig()}
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
    $Bold.Checked            = $(If([String]$LoadedConfig.Bolded -eq 'False')    {$False}Else{[Boolean]$LoadedConfig.Bolded})
    $MousePosCheck.Checked   = $(If([String]$LoadedConfig.ShowMousePos -eq 'False')    {$False}Else{[Boolean]$LoadedConfig.ShowMousePos})
    $ShowCons.Checked = !$ShowCons.Checked
    Sleep -Milliseconds 40
    $ShowCons.Checked = !$ShowCons.Checked
    $OnTop.Checked = !$OnTop.Checked
    Sleep -Milliseconds 40
    $OnTop.Checked = !$OnTop.Checked
    If($Bold.Checked){
        $Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',9,[System.Drawing.FontStyle]::Bold)}
    }Else{
	    $Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',9,[System.Drawing.FontStyle]::Regular)}
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
                $Form.Text = ('Pikl - ' + $Macro)
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
                $Form.Text = ('Pikl - ' + $LoadedConfig.PrevProfile)
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
                $Form.Text = ('Pikl - ' + $SavedProfiles.SelectedItem)
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
                    [Void](MKDIR $TempDir)
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
    
    $AppContext = ([Cons.Act]::CrI([System.Windows.Forms.ApplicationContext],@()))
    [System.Windows.Forms.Application]::Run($AppContext)
}
$UndoHash.KeyList | %{
    If($_ -notmatch 'MOUSE'){
        [Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)
    }Else{
        [Cons.MouseEvnt]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
    }
}
$SyncHash.Kill = $True
$MutexPow.EndInvoke($MutexHandle)
$MutexRun.Close()
$MutexPow.Dispose()
$MouseIndPow.EndInvoke($MouseIndHandle)
$MouseIndRun.Close()
$MouseIndPow.Dispose()
#If($Host.Name -match 'Console'){Exit}
