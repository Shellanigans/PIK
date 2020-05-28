############################################################################################################################################################################################################################################################################################################
             ###                                                                    #       #####     # #   
              #   #    #  #  #####  #    ##    #       #  ######  ######           #       #     #    # #   
              #   ##   #  #    #    #   #  #   #       #      #   #               #        #        ####### 
              #   # #  #  #    #    #  #    #  #       #     #    #####          #         #          # #   
              #   #  # #  #    #    #  ######  #       #    #     #             #          #        ####### 
              #   #   ##  #    #    #  #    #  #       #   #      #            #           #     #    # #   
             ###  #    #  #    #    #  #    #  ######  #  ######  ######      #             #####     # #   
############################################################################################################################################################################################################################################################################################################                                                                                                

#Read in either a specific profile to run or a single line command
Param([String]$Macro = $Null,[String]$CLICMD = '')

#Clean up the env
Remove-Variable * -Exclude Macro,CLICMD -EA SilentlyContinue

#Using a giant script block allows for regexing the new types of constructors to the old kind (i.e. the New() vs. the New-Object)
#The New() constructors are much faster but for backwards compatibility a way to swap everything to the New-object was needed
#At the end there is some regex parsing going on that converts the whole program if the environment doesn't support New()
$MainBlock = {
#Some C# code that I use as wrapper class for System.Windows.Forms (for easy instantiation) as well as a collection of imported functions from other dlls
#Eventually should move to entirely C# invoked by Powershell and some of the migration is done below (the interpret method in the parser class)
$CSharpDef = @'
using System;
using System.IO;
using System.Text;
using System.Diagnostics;
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
        public static void Keys (string Keys)  {SWF.SendKeys.SendWait(Keys);}
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

                    foreach (var item in possiblepos.ToArray()) {
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
            if(Regex.IsMatch(X, "{[CPS][OAE]")){
                X = (X.Replace("{COPY}","(^c)"));
                X = (X.Replace("{PASTE}","(^v)"));
                X = (X.Replace("{SELECTALL}","(^a)"));
            }
            if(Regex.IsMatch(X, "{PID}")){
                X = (X.Replace("{MYPID}",(Process.GetCurrentProcess().Id.ToString())));
            }
            if(Regex.IsMatch(X, "{WHOAMI}")){
                X = (X.Replace("{WHOAMI}",(Environment.UserDomainName.ToString()+"\\"+Environment.UserName.ToString())));
            }
            if(Regex.IsMatch(X, "{[DSR][PA][TAN]")){
                X = (X.Replace("{DATETIME}",DateTime.Now.ToString()));
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
            if(Regex.IsMatch(X, "{GET[CMP]")){
                DR.Point Coords = Cons.Curs.GPos();
                X = X.Replace("{GETCLIP}",(Cons.Clip.GetT()));
                X = X.Replace("{GETMOUSE}",(Coords.X.ToString()+","+Coords.Y.ToString()));
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

Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic -IgnoreWarnings -TypeDefinition $CSharpDef

############################################################################################################################################################################################################################################################################################################
             #######                                                           
             #        #    #  #    #   ####   #####  #   ####   #    #   ####  
             #        #    #  ##   #  #    #    #    #  #    #  ##   #  #      
             #####    #    #  # #  #  #         #    #  #    #  # #  #   ####  
             #        #    #  #  # #  #         #    #  #    #  #  # #       # 
             #        #    #  #   ##  #    #    #    #  #    #  #   ##  #    # 
             #         ####   #    #   ####     #    #   ####   #    #   ####  
############################################################################################################################################################################################################################################################################################################
#Major functions are located here the all call each other and are organized like so:
<#
    "GO" is the main function called to action on button click or F-Key press, contains a lot of instancing and cleanup prior to each run as well as macro function parsing
     |
     ---> "Actions" is called to check each line as it comes in and is the collection of keywords for performing actual actions on the machine (i.e. not just simple substitution or "Get" style keywords)
           |
           ---> "Interpret" Gets called before any actions (though if statetments true/flase conditions take precedence). The purpose is to make substitutions such as var substitutions or getting content (i.e. values are known)
                 |
                 ---> "[Parser]::Interpret" Ultimately where interpret/actions/GO will reside, but for now a place where extremely simple find/replace keywords can get parsed and is completed first.
      
#>
Function Interpret{
    Param([String]$X)

    #Do the really basic parsing
    $X = [Parser]::Interpret($X)

    #Reset the depth overflow (useful for finding bad logic with infinite loops)
    $DepthOverflow = 0

    #Don't exit until we see no more matches to any of the following substitution keywords or we hit the depth overflow
    While(
            $DepthOverflow -lt 500 -AND `
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
            ($X -match '{FINDIMG ') -OR `
            ($X -match '{GETWIND ') -OR `
            ($X -match '{GETWINDTEXT ') -OR `
            ($X -match '{GETFOCUS') -OR `
            ($X -match '{GETSCREEN') -OR `
            ($X -match '{READIN '))){
        
        $PHSplitX = $X.Split('{}')
        
        #Perform all the var substitutions now that are not for var setting, by replacing the string with the value stored in the VarHash
        $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -notmatch '=' -AND $_ -notmatch '\+\+$' -AND $_ -notmatch '--$'} | %{
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
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
            }

            If($PHFound){If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'INTERPRETED VALUE: ' + $X)}}
        }
        
        #Replace the keyword with the content from a file
        $PHSplitX | ?{$_ -match 'GETCON \S+'} | %{
            $X = ($X.Replace(('{'+$_+'}'),((GC $_.Substring(7)) | Out-String)))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

        #Replace the keyword with the dimension of all screens separated by semi-colons
        $PHSplitX | ?{$_ -match 'GETSCREEN'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(([System.Windows.Forms.Screen]::AllScreens | %{$PH = $_.Bounds; [String]$PH.X+','+$PH.Y+','+$PH.Width+','+$PH.Height}) -join ';').TrimEnd(';')))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

        #Replace the keyword with the present working directory
        $PHSplitX | ?{$_ -match '^PWD$'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(PWD).Path))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
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
                $PHProc = (PS -Id $PHProc | ?{$_.MainWindowHandle -ne 0})
            }ElseIf($_ -match ' -HAND '){
                $PHProcHand = $PHProc
                #If(($Script:HiddenWindows.Keys -join '')){
                #    $LastHiddenTime = (($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_')} | %{[String]($_.Split('_')[-1])} | Sort) | Select -Last 1)
                #    $PHHidden = $Script:HiddenWindows.($Script:HiddenWindows.Keys | ?{$_ -match ('_'+$PHProcHand+'_'+$LastHiddenTime+'$')})
                #}
                $PHProc = (PS | ?{[String]($_.MainWindowHandle) -eq $PHProcHand})

                If($PHProc){
                    $PHHidden = ''
                }Else{
                    $TrueHand = $True
                    $PHProcHand = [IntPtr][Int]$PHProcHand
                    Try{
                        $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHProcHand)
                        $PHString = [System.Text.StringBuilder]::New(($PHTextLength + 1))
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
                $PHProc = (PS $PHProc | ?{$_.MainWindowHandle -ne 0})
            }
            If($PHHidden){$PHProc+=$PHHidden}

            $PHOut = ''
            If($PHProc.Count -ge 1){
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
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'COULD NOT PULL PROC, HANDLE IS VALID THOUGH')}
                            }
                        }
                        'GETWINDTEXT' {
                            $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHTMPProcHand)
                            $PHString = [System.Text.StringBuilder]::New(($PHTextLength + 1))
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
            If(!$PHProc -OR !$PHOut){If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'PROCESS NOT FOUND!')}}
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
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
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
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

        #Replaces the keyword with the evaluation of the arithmetic
        $PHSplitX | ?{$_ -match '^EVAL \S+.*\d$'} | %{
            ($_.SubString(5) -replace ' ') | %{
                #Preparse
                $PHOut = ($_ -replace '\+-','-')
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Pre:'+$PHOut)}
                $PHOut
            } | %{
                #Division
                $PHOut = $_
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Div:'+$PHOut)}
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
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Mul:'+$PHOut)}
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
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Sub:'+$PHOut)}
                $PHOut = $PHOut -replace '-','+-'
                While($PHOut -match '\+\+'){$PHOut = $PHOut.Replace('++','+')}
                $PHOut
            }  | %{
                #Addition
                $PHOut = $_
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Add:'+$PHOut)}
                $PHTotal = 0
                While($PHOut -match '\+'){
                    ($_.Split('+') | ?{$_ -ne ''}) | %{
                        $PHTotal = $PHTotal + [Double]$_
                    }
                    $PHOut = $PHOut.Replace($_,$PHTotal)
                }
            }

            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'Out:'+$PHOut)}

            $X = ($X.Replace(('{'+$_+'}'),($PHOut)))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

        $PHSplitX | ?{(($_ -match '^VAR \S*\+\+') -AND ($_ -notmatch '=')) -OR (($_ -match '^VAR \S*--') -AND ($_ -notmatch '=')) -OR ($_ -match '^VAR \S+\+=\d*') -OR ($_ -match '^VAR \S+-=\d*')} | %{
            $PH = ((($_ -replace '\+=',' ' -replace '-=',' ' -replace '\+\+',' ' -replace '--',' ').Split(' ') | ?{$_ -ne ''})[1])
            If($Script:VarsHash.ContainsKey($PH)){
                Try{
                    If($_ -match '\+\+'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + 1)
                    }ElseIf($_ -match '\+='){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + ($_.Split('=')[-1]))
                    }ElseIf($_ -match '--'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - 1)
                    }ElseIf($_ -match '-='){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - ($_.Split('=')[-1]))
                    }
                }Catch{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$PH+' BAD DATA TYPE!')}
                }
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
            }
            $X = ''
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

            $BMP1 = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
            $Graphics = [System.Drawing.Graphics]::FromImage($BMP1)
            $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.size)

            $BMP2 = [System.Drawing.Bitmap]::FromFile($PHFile)

            $PHOut = [Img.Find]::GetSubPositions($BMP1,$BMP2)[$PHIndex]
            If($PHOut -ne $Null){
                $PHOut = ([String]$PHOut.X + ',' + $PHOut.Y)

                If($ShowCons.Checked){
                    [System.Console]::WriteLine($Tab+'IMAGE FOUND WITH INDEX ' + $PHIndex + ' AT COORDINATES ' + $PHOut)
                }
            }Else{
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
            If($Output){If($ShowCons.Checked){[System.Console]::WriteLine($X)}}
        }

        $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -match '=.+'} | %{
            $PH = $_.Substring(4)
            $PHName = $PH.Split('=')[0]
            If($PHName -match '_ESCAPED$'){
               If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'THE NAME '+$PHName+' IS INVALID, _ESCAPED IS A RESERVED SUFFIX. THIS LINE WILL BE IGNORED...')}
                $X = ''
            }Else{
                $PHValue = $PH.Replace(($PHName+'='),'')
                If(!([String]$PHValue)){
                    $PHValue = ($X -replace '.*?{VAR .*?=')
                    $PHCount = ($X.Split('{') | %{$VarCheck = $False}{If($VarCheck){$_};If($_ -match 'VAR .*?='){$VarCheck = $True}}).Count
                    $PHValue = $PHValue.Split('}')[0..$PHCount] -join '}'
                    $X = $X.Replace(('{VAR '+$PHName+'='+$PHValue+'}'),'')

                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'ABOVE VAR CONTAINS BRACES "{}" AND NO VALID VARS TO SUBSTITUTE.')}
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'PLEASE CONSIDER CHANGING LOGIC TO USE DIFFERENT DELIMITERS.')}
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'THIS WILL BE PARSED AS RAW TEXT AND NOT AS COMMANDS.')}
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'IF YOU NEED TO ALIAS COMMANDS, USE A FUNCTION INSTEAD.')}

                    $PHName+='_ESCAPED'
                }Else{
                    $X = $X.Replace(('{'+$_+'}'),'').Replace('(COMMA)',',').Replace('(SPACE)',' ').Replace('(NEWLINE)',$NL).Replace('(NULL)','').Replace('(LBRACE)','{').Replace('(RBRACE)','}')
                }


                $Script:VarsHash.Remove($PHName)
                $Script:VarsHash.Add($PHName,$PHValue)
            }
        }

        $X.Split('{') | ?{$_ -match 'VAR \S+=}'} | %{
            $PHName = ($_.Split('=')[0] -replace '^VAR ')

            $Script:VarsHash.Remove($PHName)
            $Script:VarsHash.Add($PHName,'')

            $X = $X.Replace('{'+$_,'')
        }

        $DepthOverflow++
    }

    If($DepthOverflow -ge 500){If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'OVERFLOW DEPTH REACHED! POSSIBLE INFINITE LOOP!')}}

    Return $X,$Esc
}

Function Actions{
    Param([String]$X,[Switch]$WhatIf)

    If(!$SyncHash.Stop -AND ($X -notmatch '^:::')){
        If($Script:IfEl){
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }Else{
            If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$X)}
        }

        $GOTOLabel = ''

        If($X -match '{IF \(.*?\)}' -AND $Script:IfEl){
            If($ShowCons.Checked){[System.Console]::WriteLine($NL + 'BEGIN IF')}
            If($ShowCons.Checked){[System.Console]::WriteLine('--------')}
            
            $Script:IfEl = $False
            
            $x = $X.Replace('{IF (','')
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

            If(!$PHEsc1 -AND !$PHEsc2){
                Switch($Comparator){
                    'MATCH'    {If($Op1 -match $Op2)                       {$Script:IfEl = $True}}
                    'EQ'       {If($Op1 -eq $Op2)                          {$Script:IfEl = $True}}
                    'LIKE'     {If($Op1 -like $Op2)                        {$Script:IfEl = $True}}
                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT TO NUMERIC!')}}}
                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT TO NUMERIC!')}}}
                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT TO NUMERIC!')}}}
                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT TO NUMERIC!')}}}
                    'NOTMATCH' {If($Op1 -notmatch $Op2)                    {$Script:IfEl = $True}}
                    'NE'       {If($Op1 -ne $Op2)                          {$Script:IfEl = $True}}
                    'NOTLIKE'  {If($Op1 -notlike $Op2)                     {$Script:IfEl = $True}}
                    'AND'      {If($Op1 -eq 'TRUE' -AND $Op2 -eq 'TRUE')   {$Script:IfEl = $True}}
                    'OR'       {If($Op1 -eq 'TRUE' -OR $Op2 -eq 'TRUE')    {$Script:IfEl = $True}}
                    'NAND'     {If($Op1 -eq 'FALSE' -OR $Op2 -eq 'FALSE')  {$Script:IfEl = $True}}
                    'NOR'      {If($Op1 -eq 'FALSE' -AND $Op2 -eq 'FALSE') {$Script:IfEl = $True}}
                    'NOT'      {If(!$Op2 -OR $Op2 -eq 'FALSE')             {$Script:IfEl = $True}}
                    'TRUE'     {If($Op1 -eq 'TRUE')                        {$Script:IfEl = $True}}
                }

                If($Comparator -eq 'TRUE' -OR $Comparator -eq 'FALSE'){
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'IF STATEMENT: {IF (' + $Comparator + ')}')}
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'IF STATEMENT: {IF (' + $OP1 + ' -' + $Comparator + ' ' + $OP2 + ')}')}
                }
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'EVALUATION: ' + $Script:IfEl.ToString().ToUpper() + $NL)}
            }
            Else{
                If($ShowCons.Checked){[System.Console]::WriteLine('IF STATEMENT FAILED! CHECK PARAMS! AN ARGUMENT WAS ESCAPED FOR SOME REASON!')}
            }

            $X = ''
        }
        
        If(($X -match '{ELSE}') -OR ($X -match '{FI}')){
            If($X -match '{ELSE}' -AND $Script:ElFi){$Script:IfEl = !$Script:IfEl}

            If($X -match '{FI}'){$Script:IfEl = $True}
        }ElseIf($Script:IfEl){
            $Escaped = $False
            $X,$Escaped = (Interpret $X)

            $TempX = $Null
            If($Escaped){
                $TempX = $X
                $X = ''
            }
        
            If($X -match '^{GOTO '){
                $GOTOLabel = ($X.Substring(0,$X.Length - 1) -replace '^{GOTO ')
                $SyncHash.Restart = $True
                $SyncHash.Stop = $True
                
                $X = ''
            }ElseIf($X -match '^{POWER .*}$'){
                If(!$WhatIf){$X = ([ScriptBlock]::Create(($X -replace '^{POWER ' -replace '}$'))).Invoke()}Else{If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: CREATE A SCRIPTBLOCK OF '+($X -replace '^{POWER ' -replace '}$'))}}
            }ElseIf($X -match '{PAUSE'){
                If($CommandLine -OR ($X -match '{PAUSE -C}')){
                    If($ShowCons.Checked){[System.Console]::WriteLine('PRESS ANY KEY TO CONTINUE...')}
                    [Void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                }Else{
                    [Void][System.Windows.Forms.MessageBox]::Show('PAUSED - Close this box to continue...','PAUSED',0,64)
                }
            
                $X = $X.Replace('{PAUSE}','').Replace('{PAUSE -C}','')
            }ElseIf($X -match '^{FOREACH '){
                $PH = ($X.Substring(0, $X.Length - 1) -replace '^{FOREACH ').Split(',')
                $Script:VarsHash.Keys.Clone() | ?{$_ -match ('^[0-9]*_' + $PH[1])} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{
                    $Script:VarsHash.Remove($PH[0])
                    $Script:VarsHash.Add($PH[0],$Script:VarsHash.$_)
                    
                    If(!$WhatIf){
                        Actions $PH[2]
                    }Else{
                        Actions $PH[2] -WhatIf
                    }
                }
                $Script:VarsHash.Remove($PH[0])
            }ElseIf($X -match '^{SETCON'){
                $PHFileName = ($X.Substring(8)).Split(',')[0].TrimStart(' ')
                $PHFileContent = (($X -replace '^{SETCONA? ').Replace(($PHFileName+','),'') -replace '}$')

                If(!$WhatIf){
                    If($X -notmatch '^{SETCONA '){
                        $PHFileContent | Out-File $PHFileName -Force
                    }Else{
                        $PHFileContent | Out-File $PHFileName -Append -Force
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
                        1..$Flashes | %{
                            $Coords = $Host.UI.RawUI.WindowSize
                            $Origin = $Host.UI.RawUI.CursorPosition
    
                            [System.Console]::WriteLine($Blank)

                            $Blank = (' '*($Coords.Width*$Coords.Height))
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
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WHATIF: BEEP FOR '+$Time+' AT '+$Tone)}
                    }
                    $X = ($X -replace ('{'+$_+'}'))
                }
            }ElseIf($X -match '{WAIT ?(M )?\d*}'){
                $X -replace '{WAIT' -replace '}' | %{
                    If($_ -match 'M'){
                        $PH = [Int]($_ -replace ' M ')
                    }ElseIf($_ -match ' '){
                        $PH = [Int]($_ -replace ' ')*1000
                    }Else{
                        $PH = 1000
                    }

                    If(!$SyncHash.Stop -AND ($PH % 3000)){
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WAITING: '+[Double]($PH / 1000)+' SECONDS REMAIN...')}
                        [System.Threading.Thread]::Sleep($PH % 3000)
                    }
                
                    $MaxWait = [Int]([Math]::Floor($PH / 3000))
                    $PH = ($PH - ($PH % 3000))
                    For($i = 0; $i -lt $MaxWait -AND !$SyncHash.Stop; $i++){
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'WAITING: '+[Double](($PH - (3000 * $i)) / 1000)+' SECONDS REMAIN...')}
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

                        $Coords = [Cons.Curs]::GPos()
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
                            $Random = [System.Random]::New()
                            
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
                                If($Right) {$PHTMPCoords.X = ($PHTMPCoords.X+$OffsetX)}Else{$PHTMPCoords.X = ($PHTMPCoords.X-$OffsetX)}
                                If($Down)  {$PHTMPCoords.Y = ($PHTMPCoords.Y+$OffsetY)}Else{$PHTMPCoords.Y = ($PHTMPCoords.Y-$OffsetY)}
                                
                                $j = $Coords.X
                                $k = $Coords.Y
                                While($j -ne $PHTMPCoords.X){
                                    [Cons.Curs]::SPos($j,$k)
                                    If($j -lt $PHTMPCoords.X){$j++}Else{$j--}
                                }
                                While($k -ne $PHTMPCoords.Y){
                                    [Cons.Curs]::SPos($j,$k)
                                    If($k -lt $PHTMPCoords.Y){$k++}Else{$k--}
                                }

                                $RemainderX = $OffsetX - [Math]::Round($OffsetX)
                                $RemainderY = $OffsetY - [Math]::Round($OffsetY)
                                If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                            }

                            If(!$SyncHash.Stop){
                                While($j -ne [Math]::Round($MoveCoords[0]) -AND !$SyncHash.Stop){
                                    [Cons.Curs]::SPos($j,$k)
                                    If($j -lt [Math]::Round($MoveCoords[0])){$j++}Else{$j--}
                                }
                                While($k -ne [Math]::Round($MoveCoords[1])){
                                    [Cons.Curs]::SPos($j,$k)
                                    If($k -lt [Math]::Round($MoveCoords[1]) -AND !$SyncHash.Stop){$k++}Else{$k--}
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
            }ElseIf($X -match '^{CD '){
                CD ($X -replace '{CD ' -replace '}$')
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'CHANGING DIRECTORY TO '+($X -replace '{CD ' -replace '}$'))}
            }ElseIf($X -match '^{REMOTE '){
                Try{
                    If(!$WhatIf){
                        $PH = ($X -replace '{REMOTE ' -replace '}$')
                        $PHIP = [String]($PH.Split(',')[0].Split(':')[0])
                        $PHPort = [Int]($PH.Split(',')[0].Split(':')[-1])
                        $PHSendString = ($PH.Split(',')[-1])

                        If($Script:FuncHash.($PHSendString -replace '^{' -replace '}$')){
                            $PHSendString = $Script:FuncHash.($PHSendString -replace '^{' -replace '}$')
                        }

                        $PHCMDS = '{CMDS_START}'+($NL*2)+$PHSendString+($NL*2)+'{CMDS_END}'
                        $Buffer = [Text.Encoding]::UTF8.GetBytes($PHCMDS)

                        $PHClient = [System.Net.Sockets.TcpClient]::New($PHIP,$PHPort)
                        $PHStream = $PHClient.GetStream()
                        $PHStream.Write($Buffer, 0, $Buffer.Length)

                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'SENT THE FOLLOWING TO '+$PHIP+':'+$PHPort)}
                        If($ShowCons.Checked){$PHSendString.Split($NL) | %{$FlipFlop = $True}{If($FlipFlop){[System.Console]::WriteLine($Tab+$_)};$FlipFlop=!$FlipFlop}}

                        $PHResp = ''
                        $Timeout = 1
                        While(($PHResp -notmatch '{COMPLETE}') -AND !$SyncHash.Stop -AND ($Timeout -lt 1000) -AND ($PHSendString -ne '{SERVERSTOP}')){
                            If($ShowCons.Checked -AND !($Timeout % 6)){[System.Console]::WriteLine($Tab+'WAITING FOR REMOTE END COMPLETION... '+($Timeout/2))}

                            $Buff = New-Object Byte[] 1024
                            While($PHStream.DataAvailable){
                                [Void]$PHStream.Read($Buff, 0, 1024)
                                $PHResp+=([System.Text.Encoding]::UTF8.GetString($Buff))
                            }
                            [System.Threading.Thread]::Sleep(500)
                            $Timeout++
                        }

                        If($PHResp -match '{COMPLETE}'){If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'COMPLETED!')}}
                        If($Timeout -ge 1000){If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'TIMED OUT WAITING FOR REMOTE END!')}}

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

                    $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
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
                        If($_ -match '^\s*?<\\\\#'){$Commented = $True}
                        If($_ -match '^\s*?\\\\#>'){$Commented = $False}
                
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$_)}

                        If($_ -notmatch '^\s*?\\\\#' -AND !$Commented -AND $_ -notmatch '^:::'){$_}
                    } | %{
                        If(!$SyncHash.Stop){
                            If(!$WhatIf){
                                [Void](Actions $_)
                            }Else{
                                [Void](Actions $_ -WhatIf)
                            }
                        }
                    }
                }
            }ElseIf(($X -match '{FOCUS ') -OR ($X -match '{SETWIND ') -OR ($X -match '{MIN ') -OR ($X -match '{MAX ') -OR ($X -match '{HIDE ') -OR ($X -match '{SHOW ') -OR ($X -match '{SETWINDTEXT ')){
                $PHProc = $X
                If($PHProc -match ','){$PHProc = $PHProc.Split(',')[0]}
                
                $TrueHand = $False

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
                            $PHString = [System.Text.StringBuilder]::New(($PHTextLength + 1))
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
                    $PHProcTMPName = ($PHProc.Split(' ') | ?{$_ -ne ''})[1].Replace('{','').Replace('}','')
                    If(($Script:HiddenWindows.Keys -join '')){
                        $PHHidden = (($Script:HiddenWindows.Keys | ?{$_ -match ('^'+$PHProcTMPName+'_')}) | %{$Script:HiddenWindows.$_})
                    }
                    $PHProc = (PS $PHProcTMPName | ?{$_.MainWindowHandle -ne 0})
                    If(!$PHProc){$PHProc = (PS | ?{$_.MainWindowTitle -match $PHProcTMPName})}
                }

                If($PHHidden){$PHProc+=$PHHidden}

                If($PHProc){
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
                                'FOCUS'       {If(!$TrueHand){[Void][Cons.App]::Act($PHTMPProcTitle)}Else{[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,9)}}
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
                If($X -match '{ECHO -GUI \S+'){
                    [Void][Microsoft.VisualBasic.Interaction]::MsgBox(($X -replace '^{ECHO -GUI ' -replace '}$'), [Microsoft.VisualBasic.MsgBoxStyle]::OkOnly, 'ECHO GUI')
                }Else{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+($X -replace '^{ECHO ' -replace '}$'))}
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
                            $PH = (([Random]::New()).Next((-1*$DelayRandTimer.Value),($DelayRandTimer.Value)))
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
                    $PH = (([Random]::New()).Next((-1*$CommRandTimer.Value),($CommRandTimer.Value)))
                }Else{
                    $PH = 0
                }

                [System.Threading.Thread]::Sleep([Math]::Round([Math]::Abs(($CommandDelayTimer.Value + $PH))))
            }
        }
    }

    Return $GOTOLabel
}

Function GO{
    Param([Switch]$SelectionRun,[Switch]$Server,[Switch]$WhatIf,[String]$InlineCommand)
    
    #Any lines with #Ignore are there for regex purposes when exporting scripts
    [System.Console]::WriteLine($NL+'Initializing:')                                             #Ignore
    [System.Console]::WriteLine('-------------------------')                                     #Ignore

    $Script:Refocus = $False
    $Script:IfEl = $True
    $Script:ElFi = $True

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
                    $NameFunc = [String]($_ -replace '{FUNCTION NAME ' -replace '}')             #Ignore
                }ElseIf($_ -match '^{FUNCTION END}'){                                            #Ignore
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

    [System.Console]::WriteLine('Starting Macro!'+$NL+'-------------------------')
    
    $Results = (Measure-Command {
        $PHGOTO = ''
        Do{
            [Cons.WindowDisp]::ShowWindow($Form.Handle,0)

            $SyncHash.Stop = $False
            $SyncHash.Restart = $False
            
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

            ($PHText -replace ('`'+$NL),'').Split($NL) | %{$_ -replace '^\s*'} | ?{$_ -ne ''} | %{$Commented = $False}{
                If($_ -match '^\s*?<\\\\#'){$Commented = $True}
                If($_ -match '^\s*?\\\\#>'){$Commented = $False}
                
                #If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$_)}

                If($_ -notmatch '^\s*?\\\\#' -AND !$Commented){
                    $_
                }
            } | %{$InlineFunction = $False}{
                If(!$SyncHash.Stop){
                    Try{
                        $Line = $_

                        If(!$PHGOTO){
                            If($Line -match '{FUNCTION NAME '){
                                $InlineFunction = $True
                                $NewFuncName = ($Line.Replace('{FUNCTION NAME ','') -replace '}$').Trim(' ')
                                $NewFuncName,$FuncEsc = (Interpret $NewFuncName)
                                If(!$FuncEsc){
                                    $Line = ''
                                    $NewFuncBody = ''
                                }Else{
                                    $InlineFunction = $False
                                }
                            }
                            If($InlineFunction){
                                If($Line -notmatch '^{FUNCTION END}'){
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
                                If($Line.Trim() -match '^{SERVERSTOP}$'){
                                    $Server = $False
                                    $SyncHash.Stop = $True
                                    $SyncHash.Restart = $False
                                }Else{
                                    If(!$WhatIf){
                                        $PHGOTO = (Actions $Line)
                                    }Else{
                                        $PHGOTO = (Actions $Line -WhatIf)
                                    }
                                    
                                    If($Line -match '{ELSE}'){$Script:ElFi = $False}ElseIf($Line -match '{FI}'){$Script:ElFi = $True}
                                }
                            }
                        }ElseIf(($_ -match '^:::'+$PHGOTO)){
                            $PHGOTO = ''
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

        If(!$CommandLine -AND !$Server){    
            $Commands.ReadOnly     = $False
            $FunctionsBox.ReadOnly = $False

            [Cons.WindowDisp]::ShowWindow($Form.Handle,4)

            [System.Console]::WriteLine('Complete!'+$NL)

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

############################################################################################################################################################################################################################################################################################################
              #####   #     #  ### 
             #     #  #     #   #  
             #        #     #   #  
             #  ####  #     #   #  
             #     #  #     #   #  
             #     #  #     #   #  
              #####    #####   ### 
############################################################################################################################################################################################################################################################################################################
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

    $Position = ('{MOUSE '+((($PH).ToString().Substring(3) -replace 'Y=').TrimEnd('}'))+'}')
    
    $XCoord.Value = $PH.X
    $YCoord.Value = $PH.Y

    $MouseCoordsBox.Text = $Position

    $Bounds = [GUI.Rect]::R($PH.X,$PH.Y,1,1)

    $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
            
    $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
    $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
    
    $PHPix = $BMP.GetPixel(0,0)
    $PixColorBox.Text = $PHPix.Name.ToUpper()
    $PixColorBox.BackColor = [System.Drawing.Color]::FromArgb('0x'+$PixColorBox.Text)

    $PHLum = [Math]::Sqrt(
        [Math]::Pow($PHPix.R,2) * 0.299 +
        [Math]::Pow($PHPix.G,2) * 0.587 +
        [Math]::Pow($PHPix.B,2) * 0.114
    )

    If($PHLum -gt 130){
        $PixColorBox.ForeColor = [System.Drawing.Color]::Black
        $CenterDot.BackColor = [System.Drawing.Color]::Black
    }Else{
        $PixColorBox.ForeColor = [System.Drawing.Color]::White
        $CenterDot.BackColor = [System.Drawing.Color]::White
    }

    $Bounds = [GUI.Rect]::R($PH.X-8,$PH.Y-8,16,16)

    $BMP = [System.Drawing.Bitmap]::New($Bounds.Width, $Bounds.Height)
    $Graphics = [System.Drawing.Graphics]::FromImage($BMP)
    $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

    $BMPBig = [System.Drawing.Bitmap]::New(120, 106)    
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
        }Else{
            $MainObj.SelectionLength = 0
            $MainObj.SelectedText = '\\# '
        }
        
        $MainObj.SelectionStart = $PrevStart
        $MainObj.SelectionLength = $PrevLength
    }ElseIf($KeyCode -eq 'F4'){
        Switch($BoxType){
            'Commands'{
                $MainObj.SelectionLength = 0
                $MainObj.SelectedText = (':::label_me'+$NL)
            }
            'Functions'{
                $MainObj.Text+=($NL+'{FUNCTION NAME RENAMETHIS}'+$NL+$Tab+$NL+'{FUNCTION END}'+$NL)
                $MainObj.SelectionStart = ($MainObj.Text.Length - 1)
            }
        }
    }ElseIf($KeyCode -eq 'F5'){
        $PH = [Cons.Curs]::GPos()

        $XCoord.Value = $PH.X
        $YCoord.Value = $PH.Y

        #$MainObj.SelectionLength = 0
        $MainObj.SelectedText = ('{MOUSE '+((($PH).ToString().Substring(3) -replace 'Y=').TrimEnd('}'))+'}'+$NL)
    }ElseIf($KeyCode -eq 'F6'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '{WAIT M 100}'
    }ElseIf($KeyCode -eq 'F9'){
        GO -SelectionRun
    }ElseIf($KeyCode -eq 'F10'){
        $TempSelectionIndex = $MainObj.SelectionStart
        $TempSelectionLength = $MainObj.SelectionLength

        $MainObj.SelectionStart = 0
        $MainObj.SelectionLength = $MainObj.Text.Length
        $MainObj.SelectionColor = [System.Drawing.Color]::Black
        
        $DetectedFunctions = @()

        $Commands.Text.Split($NL) | ?{($_ -ne '') -AND $_ -match '{FUNCTION NAME '} | %{$DetectedFunctions+=$_.Replace('FUNCTION NAME ','').Trim()}
        $FunctionsBox.Text.Split($NL) | ?{($_ -ne '') -AND ($_ -match '{FUNCTION NAME ')} | %{$DetectedFunctions+=$_.Replace('FUNCTION NAME ','').Trim()}

        ($MainObj.Lines | %{$Count = 0; $Commented = $False}{
            $PH = $_.TrimStart(' ').TrimStart($Tab)

            If($PH -match '^<\\\\#'){$Commented = $True}
            If($PH -match '^\\\\#>'){$Commented = $False}

            If($PH -match '^\\\\#' -OR $Commented){
                'G,'+$Count
            }
            ElseIf(!$Commented){
                If($PH -match '^:::'){
                    'B,'+$Count
                }ElseIf(
                    ($PH -match '{VAR ') -OR `
                    ($PH -match '{LEN ') -OR `
                    ($PH -match '{ABS ') -OR `
                    ($PH -match '{POW ') -OR `
                    ($PH -match '{SIN ') -OR `
                    ($PH -match '{COS ') -OR `
                    ($PH -match '{TAN ') -OR `
                    ($PH -match '{RND ') -OR `
                    ($PH -match '{FLR ') -OR `
                    ($PH -match '{SQT ') -OR `
                    ($PH -match '{CEI ') -OR `
                    ($PH -match '{MOD ') -OR `
                    ($PH -match '{EVAL ') -OR `
                    ($PH -match '{VAR \S*\+\+}') -OR `
                    ($PH -match '{VAR \S*\+=') -OR `
                    ($PH -match '{VAR \S*--}') -OR `
                    ($PH -match '{VAR \S*-=') -OR `
                    ($PH -match '{PWD') -OR `
                    ($PH -match '{MANIP ') -OR `
                    ($PH -match '{GETCON ') -OR `
                    ($PH -match '{FINDVAR ') -OR `
                    ($PH -match '{GETPROC ') -OR `
                    ($PH -match '{FINDIMG ') -OR `
                    ($PH -match '{GETWIND ') -OR `
                    ($PH -match '{GETWINDTEXT ') -OR `
                    ($PH -match '{GETFOCUS') -OR `
                    ($PH -match '{GETSCREEN') -OR `
                    ($PH -match '{READIN ')
                ){
                    'T,'+$Count
                }ElseIf(
                    @($PH.Split('{}') | %{$DetectedFunctions.Contains('{'+($_ -replace ' \d*')+'}')}).Contains($True)
                ){
                    'V,'+$Count
                }ElseIf($PH -match '^.*{.*}.*$'){
                    'R,'+$Count
                }
            }
                        
            $Count++
        }) | %{
            $PHLine = $MainObj.Lines[$_.Split(',')[-1]]
            $MainObj.SelectionStart = $MainObj.GetFirstCharIndexFromLine($_.Split(',')[-1])
            $MainObj.SelectionLength = $PHLine.Length
            
            Switch($_.Split(',')[0]){
                'G' {$MainObj.SelectionColor = [System.Drawing.Color]::DarkGreen}
                'B' {$MainObj.SelectionColor = [System.Drawing.Color]::DarkBlue}
                'T' {
                    $MainObj.SelectionStart+=($PHLine.Split('{')[0].Length)
                    $MainObj.SelectionLength=($PHLine.Length-($PHLine.Split('{')[0].Length+$(If($PHLine -notmatch '}\s*$'){$PHLine.Split('}')[-1].Length}Else{0})))
                    $MainObj.SelectionColor = [System.Drawing.Color]::Teal
                }
                'V' {
                    $MainObj.SelectionStart+=($PHLine.Split('{')[0].Length)
                    $MainObj.SelectionLength=($PHLine.Length-($PHLine.Split('{')[0].Length+$(If($PHLine -notmatch '}\s*$'){$PHLine.Split('}')[-1].Length}Else{0})))
                    $MainObj.SelectionColor = [System.Drawing.Color]::BlueViolet
                }
                'R' {
                    $MainObj.SelectionStart+=($PHLine.Split('{')[0].Length)
                    $MainObj.SelectionLength=($PHLine.Length-($PHLine.Split('{')[0].Length+$(If($PHLine -notmatch '}\s*$'){$PHLine.Split('}')[-1].Length}Else{0})))
                    $MainObj.SelectionColor = [System.Drawing.Color]::DarkRed
                }
            }
        }
                    
        $MainObj.SelectionStart = $TempSelectionIndex
        $MainObj.SelectionLength = $TempSelectionLength
        
        Try{$_.SuppressKeyPress = $True}Catch{}
    }ElseIf($KeyCode -eq 'F11'){
        Save-Profile
    }ElseIf($KeyCode -eq 'F12'){
        GO
    }ElseIf($KeyCode -eq 'TAB'){
        If($MainObj.SelectionLength -gt 0){
            $Start = $MainObj.GetLineFromCharIndex($MainObj.SelectionStart)
            $End = $MainObj.GetLineFromCharIndex($MainObj.SelectionStart + $MainObj.SelectionLength)

            $TempSelectionIndex = $MainObj.GetFirstCharIndexFromLine($Start)
            $TempSelectionLength = $MainObj.SelectionLength

            If($_.Shift -AND ($MainObj.SelectedText -match ($Tab))){
                $TempLines = $MainObj.Lines
                $Start..($End - 1) | %{
                    If([Int][Char]$TempLines[$_].Substring(0,1) -eq 9 -AND $TempLines[$_].Length -gt 1){
                        $TempLines[$_] = $TempLines[$_].Substring(1, ($TempLines[$_].Length - 1))
                        $TempSelectionLength--
                    }ElseIf([Int][Char]$TempLines[$_].Substring(0,1) -eq 9 -AND $TempLines[$_].Length -eq 1){
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
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                }Catch{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                }

                #$SaveAsProfText.Text = ''
            }
        }Else{
            $Response = [System.Windows.Forms.MessageBox]::Show('You have not saved this profile yet. Would you like to create a new save?','Create New Save?','YesNoCancel')
            If($Response -eq 'Yes'){
                $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
                If($PH){
                    $Form.Text = ('Pickle - ' + $PH)
                    $Profile.Text = ('Working Profile: ' + $PH)
                    $Script:LoadedProfile = $PH
                    #$TempName = $SaveAsProfText.Text
                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')

                    [Void](MKDIR $TempDir)

                    $Script:Saved = $True

                    #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                    #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                    Try{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
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
            '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
        }Catch{
            '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
        }

        #$SaveAsProfText.Text = ''
    }Else{
        If([System.Windows.Forms.MessageBox]::Show('You have not saved this profile yet. Would you like to create a new save?','Create New Save?','YesNoCancel') -eq 'Yes'){
            $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
            If($PH){
                $Form.Text = ('Pickle - ' + $PH)
                $Profile.Text = ('Working Profile: ' + $PH)
                $Script:LoadedProfile = $PH
                #$TempName = $SaveAsProfText.Text
                $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')

                [Void](MKDIR $TempDir)

                $Script:Saved = $True

                #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                Try{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                }Catch{
                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
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
    [Console]::Title = 'Pickle'

    [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 0)
    [Void][Cons.WindowDisp]::Visual()
}

If(!(Test-Path ($env:APPDATA+'\Macro'))){[Void](MKDIR ($env:APPDATA+'\Macro') -Force)}
If(!(Test-Path ($env:APPDATA+'\Macro\Profiles'))){[Void](MKDIR ($env:APPDATA+'\Macro\Profiles') -Force)}

$CommandLine = $False

$Tab = ([String][Char][Int]9)
$NL = [System.Environment]::NewLine

$Script:Refocus = $False
$Script:IfEl = $True
$Script:ElFi = $True

$Script:LoadedProfile = $Null
$Script:Saved = $True

#$Script:Cons = $True

$UndoHash = @{KeyList=[String[]]@()}
$Script:VarsHash = @{}
$Script:FuncHash = @{}
$Script:HiddenWindows = @{}
$SyncHash = [HashTable]::Synchronized(@{Stop=$False;Kill=$False;Restart=$False})

$ClickHelperParent = [HashTable]::Synchronized(@{})

$AutoChange = $False

$Pow = [Powershell]::Create()
$Run = [RunspaceFactory]::CreateRunspace()
$Run.Open()
$Pow.Runspace = $Run
$Pow.AddScript({
    Param($SyncHash)

    Add-Type -Name Win32 -Namespace API -IgnoreWarnings -MemberDefinition '
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int virtualKeyCode);
    ' -ErrorAction SilentlyContinue

    While(!$SyncHash.Kill){
        [System.Threading.Thread]::Sleep(50)
        If([API.Win32]::GetAsyncKeyState(145)){
            $SyncHash.Stop = $True
            $SyncHash.Restart = $False
        }
    }
}) | Out-Null
$Pow.AddParameter('SyncHash', $SyncHash) | Out-Null
$Pow.BeginInvoke() | Out-Null

$Form = [GUI.F]::New(470, 500, 'Pickle')
$Form.MinimumSize = [GUI.SP]::SI(470,500)

$TabController = [GUI.TC]::New(405, 400, 25, 7)
    $TabPageComm = [GUI.TP]::New(0, 0, 0, 0,'Main')
        $TabControllerComm = [GUI.TC]::New(0, 0, 0, 0)
        $TabControllerComm.Dock = 'Fill'
        $TabControllerComm.Add_SelectedIndexChanged({
            Switch($This.SelectedTab.Text){
                'Commands'  {$Commands.Focus()}
                'Functions' {$FunctionsBox.Focus()}
            }
        })
            $TabPageCommMain = [GUI.TP]::New(0, 0, 0, 0, 'Commands')
                $Commands = [GUI.RTB]::New(0, 0, 0, 0, '')
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
                    
                    #$This.Text | Out-File ($env:APPDATA+'\Macro\Commands.txt') -Width 1000 -Force
                    Try{
                        '' | Select @{Name='Commands';Expression={$This.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 1000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$This.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 1000 -Force
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

            $TabPageFunctMain = [GUI.TP]::New(0, 0, 0, 0, 'Functions')
                $FunctionsBox = [GUI.RTB]::New(0, 0, 0, 0, '')
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
                    
                    #$This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 1000 -Force
                    Try{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$This.Text}} | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 1000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$This.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\AutoSave.pik') -Width 1000 -Force
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

            $TabPageHelper = [GUI.TP]::new(0, 0, 0, 0, 'Info')
                $TabHelperSub = [GUI.TC]::New(0, 0, 0, 0)
                $TabHelperSub.Dock = 'Fill'
                $TabHelperSub.SizeMode = 'Fixed'
                $TabHelperSub.DrawMode = 'OwnerDrawFixed'
                $TabHelperSub.Add_DrawItem({
                    $PHText = $This.TabPages[$_.Index].Text
                    
                    $PHRect = $This.GetTabRect($_.Index)
                    $PHRect = [System.Drawing.RectangleF]::New($PHRect.X,$PHRect.Y,$PHRect.Width,$PHRect.Height)

                    $PHBrush = [System.Drawing.SolidBrush]::New('Black')

                    $PHStrForm = [System.Drawing.StringFormat]::New()
                    $PHStrForm.Alignment = [System.Drawing.StringAlignment]::Center
                    $PHStrForm.LineAlignment = [System.Drawing.StringAlignment]::Center

                    $_.Graphics.DrawString($PHText, $This.Font, $PHBrush, $PHRect, $PHStrForm)
                })
                $TabHelperSub.ItemSize = [GUI.SP]::SI(25,75)
                $TabHelperSub.Alignment = [System.Windows.Forms.TabAlignment]::Left
                    $TabHelperSubMouse = [GUI.TP]::new(0, 0, 0, 0, 'Mouse/Pix')
                        $GetMouseCoords = [GUI.B]::New(110, 25, 10, 25, 'Get Mouse Inf')
                        $GetMouseCoords.Add_MouseDown({$This.Text = 'Drag Mouse'})
                        $GetMouseCoords.Add_MouseUp({$This.Text = 'Get Mouse Inf'})
                        $GetMouseCoords.Add_MouseMove({If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){Handle-MousePosGet; $Form.Refresh()}})
                        $GetMouseCoords.Parent = $TabHelperSubMouse

                        $MouseCoordLabel = [GUI.L]::New(110, 10, 130, 10, 'Mouse Coords:')
                        $MouseCoordLabel.Parent = $TabHelperSubMouse

                        $MouseCoordsBox = [GUI.TB]::New(140, 25, 130, 25, '')
                        $MouseCoordsBox.ReadOnly = $True
                        $MouseCoordsBox.Multiline = $True
                        $MouseCoordsBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                        $MouseCoordsBox.Parent = $TabHelperSubMouse

                        $MouseManualLabel = [GUI.L]::New(100, 10, 10, 60, 'Manual Move:')
                        $MouseManualLabel.Parent = $TabHelperSubMouse

                        $XCoord = [GUI.NUD]::New(50, 25, 10, 75)
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
                
                        $YCoord = [GUI.NUD]::New(50, 25, 70, 75)
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

                        $PixColorLabel = [GUI.L]::New(110, 10, 130, 60, 'HexVal (ARGB):')
                        $PixColorLabel.Parent = $TabHelperSubMouse

                        $PixColorBox = [GUI.TB]::New(140, 25, 130, 75, '')
                        $PixColorBox.ReadOnly = $True
                        $PixColorBox.Multiline = $True
                        $PixColorBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                        $PixColorBox.Parent = $TabHelperSubMouse

                        $LeftMouseBox = [GUI.B]::New(135,25,10,110,'Left Click')
                        $LeftMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [Cons.MouseEvnt]::mouse_event(2, 0, 0, 0, 0)
                                [Cons.MouseEvnt]::mouse_event(4, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $LeftMouseBox.Parent = $TabHelperSubMouse

                        $MiddleMouseBox = [GUI.B]::New(135,25,10,152,'Middle Click')
                        $MiddleMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [Cons.MouseEvnt]::mouse_event(32, 0, 0, 0, 0)
                                [Cons.MouseEvnt]::mouse_event(64, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $MiddleMouseBox.Parent = $TabHelperSubMouse

                        $RightMouseBox = [GUI.B]::New(135,25,10,194,'Right Click')
                        $RightMouseBox.Add_KeyUp({
                            If($_.KeyCode -eq 'Space'){
                                [Cons.MouseEvnt]::mouse_event(8, 0, 0, 0, 0)
                                [Cons.MouseEvnt]::mouse_event(16, 0, 0, 0, 0)
                            }
                            $_.SuppressKeyPress = $True
                        })
                        $RightMouseBox.Parent = $TabHelperSubMouse

                        $ZoomPanel = [GUI.GB]::New(115,115,155,105,'')
                        $ZoomPanel.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
                        $ZoomPanel.Parent = $TabHelperSubMouse

                        $GraphicFixPanel = [GUI.P]::New(115,5,155,105)
                        $GraphicFixPanel.BackColor = $Form.BackColor
                        $GraphicFixPanel.Parent = $TabHelperSubMouse
                        $GraphicFixPanel.BringToFront()
                        
                        $CenterDot = [GUI.P]::New(8,8,209,159)
                        $CenterDot.BackColor = [System.Drawing.Color]::Black
                        $CenterDot.Parent = $TabHelperSubMouse
                        $CenterDot.BringToFront()
                    $TabHelperSubMouse.Parent = $TabHelperSub

                    $TabHelperSubSystem = [GUI.TP]::new(0, 0, 0, 0, 'Sys/Proc')
                        $ScreenInfoLabel = [GUI.L]::New(110, 15, 10, 8, 'Display Info:')
                        $ScreenInfoLabel.Parent = $TabHelperSubSystem

                        $ScreenInfoBox = [GUI.RTB]::New(285, 95, 10, 25, '')
                        $ScreenInfoBox.Multiline = $True
                        $ScreenInfoBox.ScrollBars = 'Both'
                        $ScreenInfoBox.WordWrap = $False
                        $ScreenInfoBox.ReadOnly = $True
                        $ScreenInfoBox.Text = (([System.Windows.Forms.Screen]::AllScreens | %{$DispCount = 1}{
                            $PH = $_.Bounds
                            'DISPLAY '+$DispCount+':'+$NL+'----------------'+$NL+'TOP LEFT     (x,y) : '+$PH.X+','+$PH.Y+$NL+'WIDTH/HEIGHT (w,h) : '+$PH.Width+','+$PH.Height+$NL+$NL
                            $DispCount++
                        }) -join $NL).TrimEnd($NL)
                        $ScreenInfoBox.Parent = $TabHelperSubSystem

                        $ProcInfoLabel = [GUI.L]::New(110,15,10,136,'Process Info:')
                        $ProcInfoLabel.Parent = $TabHelperSubSystem

                        $GetProcInfo = [GUI.B]::New(140, 23, 125, 129, 'Get Proc Inf')
                        $GetProcInfo.Add_MouseDown({If($_.Button.ToString() -eq 'Left'){$This.Text = 'Click on Proc'}ElseIf($_.Button.ToString() -eq 'Right'){$ProcInfoBox.Text = ''}})
                        $GetProcInfo.Add_LostFocus({
                            If($This.Text -ne 'Get Proc Inf'){
                                $This.Text = 'Get Proc Inf'
                                $PHFocussedHandle = [Cons.WindowDisp]::GetForegroundWindow()
                                $PHProcInfo = (PS | ?{$_.MainWindowHandle -eq $PHFocussedHandle})

                                $PHTextLength = [Cons.WindowDisp]::GetWindowTextLength($PHFocussedHandle)
                                $PHString = [System.Text.StringBuilder]::New(($PHTextLength + 1))
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

                        $ProcInfoBox = [GUI.RTB]::New(285, 160, 10, 155, '')
                        $ProcInfoBox.Multiline = $True
                        $ProcInfoBox.ScrollBars = 'Both'
                        $ProcInfoBox.WordWrap = $False
                        $ProcInfoBox.ReadOnly = $True
                        $ProcInfoBox.Text = ''
                        $ProcInfoBox.Parent = $TabHelperSubSystem
                    $TabHelperSubSystem.Parent = $TabHelperSub

                    $TabPageDebug = [GUI.TP]::New(0, 0, 0, 0, 'Debug')
                        $GetFuncts = [GUI.B]::New(150, 25, 10, 10, 'Display Functions')
                        $GetFuncts.Add_Click({
                            $Script:FuncHash.Keys | Sort | %{
                                [System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:FuncHash.$_ + $NL + $NL)

                                [System.Console]::WriteLine($NL * 3)
                            }
                        })
                        $GetFuncts.Parent = $TabPageDebug

                        $GetVars = [GUI.B]::New(150, 25, 10, 35, 'Display Variables')
                        $GetVars.Add_Click({
                            $Script:VarsHash.Keys | Sort -Unique | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{
                                [System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:VarsHash.$_ + $NL + $NL)

                                [System.Console]::WriteLine($NL * 3)
                            }
                        })
                        $GetVars.Parent = $TabPageDebug

                        $ClearCons = [GUI.B]::New(150, 25, 10, 60, 'Clear Console')
                        $ClearCons.Add_Click({Cls; $PseudoConsole.Text = ''})
                        $ClearCons.Parent = $TabPageDebug

                        $PseudoConsole = [GUI.RTB]::New(285, 165, 10, 110, '')
                        $PseudoConsole.ReadOnly = $True
                        $PseudoConsole.ScrollBars = 'Both'
                        #$PseudoConsole.ForeColor = [System.Drawing.Color]::FromArgb(0xFFF5F5F5)
                        #$PseudoConsole.BackColor = [System.Drawing.Color]::FromArgb(0xFF012456)
                        $pseudoConsole.Parent = $TabPageDebug

                        $SingleCMD = [GUI.RTB]::New(185, 20, 10, 300, '')
                        $SingleCMD.AcceptsTab = $True
                        $SingleCMD.Parent = $TabPageDebug

                        $SingleGO = [GUI.B]::New(90, 22, 205, 298, 'Run Line')
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

    $TabPageAdvanced = [GUI.TP]::New(0, 0, 0, 0,'File')
        $TabControllerAdvanced = [GUI.TC]::New(0, 0, 10, 10)
        $TabControllerAdvanced.Dock = 'Fill'
        $TabControllerAdvanced.SizeMode = 'Fixed'
        $TabControllerAdvanced.DrawMode = 'OwnerDrawFixed'
        $TabControllerAdvanced.Add_DrawItem({
            $PHText = $This.TabPages[$_.Index].Text
                    
            $PHRect = $This.GetTabRect($_.Index)
            $PHRect = [System.Drawing.RectangleF]::New($PHRect.X,$PHRect.Y,$PHRect.Width,$PHRect.Height)

            $PHBrush = [System.Drawing.SolidBrush]::New('Black')

            $PHStrForm = [System.Drawing.StringFormat]::New()
            $PHStrForm.Alignment = [System.Drawing.StringAlignment]::Center
            $PHStrForm.LineAlignment = [System.Drawing.StringAlignment]::Center

            $_.Graphics.DrawString($PHText, $This.Font, $PHBrush, $PHRect, $PHStrForm)
        })
        $TabControllerAdvanced.ItemSize = [GUI.SP]::SI(25,75)
        $TabControllerAdvanced.Alignment = [System.Windows.Forms.TabAlignment]::Left
            $TabPageProfiles = [GUI.TP]::New(0, 0, 0, 0,'Save/Load')
                $Profile = [GUI.L]::New(275, 15, 10, 10, 'Working Profile: None/Prev Text Vals')
                $Profile.Parent = $TabPageProfiles

                $SavedProfilesLabel = [GUI.L]::New(75, 15, 85, 36, 'Profiles:')
                $SavedProfilesLabel.Parent = $TabPageProfiles

                $RefreshProfiles = [GUI.B]::New(75, 21, 186, 32, 'Refresh')
                $RefreshProfiles.Add_Click({
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                    $SavedProfiles.SelectedItem = $Script:LoadedProfile})
                $RefreshProfiles.Parent = $TabPageProfiles

                $LoadProfile = [GUI.B]::New(75, 21, 10, 54, 'Load')
                $LoadProfile.Add_Click({
                    If((Get-ChildItem ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem)).Count -gt 0 -AND $SavedProfiles.SelectedIndex -ne -1){
                        If((Check-Saved) -ne 'Cancel'){
                            $Profile.Text = ('Working Profile: ' + $(If($SavedProfiles.SelectedItem -ne $Null){$SavedProfiles.SelectedItem}Else{'None/Prev Text Vals'}))
                            $Script:LoadedProfile = $SavedProfiles.SelectedItem

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

                            $Form.Text = ('Pickle - ' + $SavedProfiles.SelectedItem)
                        }
                    }
                })
                $LoadProfile.Parent = $TabPageProfiles

                $SavedProfiles = [GUI.CoB]::New(175, 21, 85, 55)
                $SavedProfiles.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                $SavedProfiles.Parent = $TabPageProfiles

                $QuickSave = [GUI.B]::New(75, 21, 10, 75, 'Save')
                $QuickSave.Add_Click({[Void](Save-Profile)})
                $QuickSave.Parent = $TabPageProfiles

                $SaveProfile = [GUI.B]::New(75, 21, 10, 96, 'Save As')
                $SaveProfile.Add_Click({
                    $PH = [Microsoft.VisualBasic.Interaction]::InputBox('Choose a name for this profile.'+($NL*2)+'It will be saved in:'+$NL+'%APPDATA%\Roaming\Macro\Profiles','Save As')
                    If($PH){
                        $Form.Text = ('Pickle - ' + $PH)
                        $Profile.Text = ('Working Profile: ' + $PH)
                        $Script:LoadedProfile = $PH
                        #$TempName = $SaveAsProfText.Text
                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')

                        [Void](MKDIR $TempDir)

                        $Script:Saved = $True

                        #$Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                        #$FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force
                        Try{
                            '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                        }Catch{
                            '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                        }

                        $SavedProfiles.Items.Clear()
                        [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                        $SavedProfiles.SelectedItem = $Script:LoadedProfile

                        #$SaveAsProfText.Text = ''
                    }
                })
                $SaveProfile.Parent = $TabPageProfiles

                $BlankProfile = [GUI.B]::New(75, 21, 10, 132, 'New')
                $BlankProfile.Add_Click({
                    If((Check-Saved) -ne 'Cancel'){
                        $Profile.Text = 'Working Profile: None/Prev Text Vals'
                        $Script:LoadedProfile = $Null
                    
                        $SavedProfiles.SelectedIndex = -1

                        $Commands.Text = ''
                        $FunctionsBox.Text = ''

                        $Script:Saved = $True

                        $Form.Text = 'Pickle'
                    }
                })
                $BlankProfile.Parent = $TabPageProfiles

                $ImportProfile = [GUI.B]::New(75,21,186,85,'Import')
                $ImportProfile.Add_Click({
                    If((Check-Saved) -ne 'Cancel'){
                        $DialogO = [System.Windows.Forms.OpenFileDialog]::New()
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

                                $Profile.Text = 'Working Profile: None/Prev Text Vals'
                                $Script:LoadedProfile = $Null
                    
                                $SavedProfiles.SelectedIndex = -1

                                $Commands.Text = ($PH -join $NL)
                                $FunctionsBox.Text = ''

                                $Script:Saved = $True

                                $Form.Text = 'Pickle'
                            }Else{
                                $ImportedName = ($DialogO.FileName.Split('\')[-1] -replace '\.pik$')
                                $Profile.Text = ('Working Profile: ' + $ImportedName)
                                $Script:LoadedProfile = $ImportedName

                                $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$ImportedName+'\')

                                [Void](MKDIR $TempDir)

                                #$Commands.Text = ((Get-Content ($TempDir+'\Commands.txt')).Split($NL) -join $NL).TrimEnd($NL)
                                #$FunctionsBox.Text = ((Get-Content ($TempDir+'\Functions.txt')).Split($NL) -join $NL).TrimEnd($NL)
                                $Commands.Text = Try{
                                    ((Get-Content $DialogO.FileName -ErrorAction SilentlyContinue | Out-String | ConvertFrom-JSON).Commands | Out-String).TrimEnd($NL)# -join $NL
                                }Catch{
                                    Try{
                                        ((Get-Content $DialogO.FileName -ErrorAction SilentlyContinue | Out-String | ConvertFrom-CSV).Commands | Out-String).TrimEnd($NL)# -join $NL
                                    }Catch{
                                        ''
                                    }
                                }
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
                                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$ImportedName+'.pik') -Width 1000 -Force
                                }Catch{
                                    '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$ImportedName+'.pik') -Width 1000 -Force
                                }

                                $SavedProfiles.Items.Clear()
                                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                                $SavedProfiles.SelectedItem = $Script:LoadedProfile

                                #$SaveAsProfText.Text = ''

                                $Script:Saved = $True

                                $Form.Text = ('Pickle - ' + $ImportedName)
                            }
                        }
                    }
                })
                $ImportProfile.Parent = $TabPageProfiles

                $ExportProfile = [GUI.B]::New(75,21,186,115,'Export')
                $ExportProfile.Add_Click({
                    $PIK_PS1 = ([System.Windows.Forms.MessageBox]::Show('Export as executable script? Select "No" or close to save as a PIK file instead.','Export Type','YesNo') -eq 'Yes')
                    
                    $DialogS = [System.Windows.Forms.SaveFileDialog]::New()
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
                            $Temp+=('Function GO{'+$NL)
                            $Temp+=((((GCI Function:GO).Definition.Split($NL) | ?{($_ -ne '') -AND ($_ -notmatch '\$Commands') -AND ($_ -notmatch '\$Form') -AND ($_ -notmatch '\$FunctionsBox') -AND ($_ -notmatch '#Ignore')}) -join $NL)+$NL)
                            $Temp+=('}'+$NL)
                            $Temp+=('$Tab = ([String][Char][Int]9)'+$NL)
                            $Temp+=('$NL = [System.Environment]::NewLine'+$NL)
                            $Temp+=('$Script:Refocus = $False'+$NL)
                            $Temp+=('$Script:IfEl = $True'+$NL)
                            $Temp+=('$UndoHash = @{KeyList=[String[]]@()}'+$NL)
                            $Temp+=('$Script:VarsHash = @{}'+$NL)
                            $Temp+=('$Script:FuncHash = @{}'+$NL)
                            $Temp+=('$Script:HiddenWindows = @{}'+$NL)
                            $Temp+=('$SyncHash = [HashTable]::Synchronized(@{Stop=$False;Kill=$False;Restart=$False})'+$NL)
                            $Temp+=('$ClickHelperParent = [HashTable]::Synchronized(@{})'+$NL)
                            $Temp+=('$AutoChange = $False'+$NL)
                            $Temp+=('$Pow = [Powershell]::Create()'+$NL)
                            $Temp+=('$Run = [RunspaceFactory]::CreateRunspace()'+$NL)
                            $Temp+=('$Run.Open()'+$NL)
                            $Temp+=('$Pow.Runspace = $Run'+$NL)
                            $Temp+=('$Pow.AddScript({'+$NL)
                            $Temp+=('    Param($SyncHash)'+$NL)
                            $Temp+=('    Add-Type -Name Win32 -Namespace API -MemberDefinition '+"'"+$NL)
                            $Temp+=('    [DllImport("user32.dll")]'+$NL)
                            $Temp+=('    public static extern short GetAsyncKeyState(int virtualKeyCode);'+$NL)
                            $Temp+=('    '+"'"+' -ErrorAction SilentlyContinue'+$NL)
                            $Temp+=('    While(!$SyncHash.Kill){'+$NL)
                            $Temp+=('        [System.Threading.Thread]::Sleep(50)'+$NL)
                            $Temp+=('        If([API.Win32]::GetAsyncKeyState(145)){'+$NL)
                            $Temp+=('            $SyncHash.Stop = $True'+$NL)
                            $Temp+=('            $SyncHash.Restart = $False'+$NL)
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
                                '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File $DialogS.FileName -Width 1000 -Force
                            }Catch{
                                '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File $DialogS.FileName -Width 1000 -Force
                            }
                        }
                    }
                })
                $ExportProfile.Parent = $TabPageProfiles

                #$SaveNewProfLabel = [GUI.L]::New(170, 20, 10, 190, 'Save Current Profile As:')
                #$SaveNewProfLabel.Parent = $TabPageProfiles

                #$SaveAsProfText = [GUI.TB]::New(165, 25, 10, 210, '')
                #$SaveAsProfText.Parent = $TabPageProfiles

                <#$DelProfLabel = [GUI.L]::New(170, 20, 10, 260, 'Delete Profile:')
                $DelProfLabel.Parent = $TabPageProfiles

                $DelProfile = [GUI.B]::New(75, 20, 186, 279, 'Delete')
                $DelProfile.Add_Click({
                    If($Script:LoadedProfile -eq $DelProfText.Text){
                        $Profile.Text = ('Working Profile: None/Prev Text Vals')
                        $SavedProfiles.SelectedItem = $Null
                        $Script:LoadedProfile = $Null

                        $Form.Text = ('Pickle')

                        $Script:Saved = $True
                    }

                    (Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | ?{$_.Name -eq $DelProfText.Text} | Remove-Item -Recurse -Force
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})

                    $DelProfText.Text = ''
                })
                $DelProfile.Parent = $TabPageProfiles

                $DelProfText = [GUI.TB]::New(165, 25, 10, 280, '')
                $DelProfText.Parent = $TabPageProfiles#>

                $OpenFolder = [GUI.B]::New(250, 25, 10, 330, 'Open Profile Folder')
                $OpenFolder.Add_Click({Explorer ($env:APPDATA+'\Macro\Profiles')})
                $OpenFolder.Parent = $TabPageProfiles
            $TabPageProfiles.Parent = $TabControllerAdvanced

            $TabPageServer = [GUI.TP]::New(0, 0, 0, 0, 'Server')
                $ServerStart = [GUI.B]::New(100, 20, 25, 25, 'Start')
                $ServerStart.Add_Click({
                    $PHPort = [Int]$ServerPort.Text
                    $Listener = [System.Net.Sockets.TcpListener]::New('0.0.0.0',$PHPort)
                    $Listener.Start()
                    While(!$SyncHash.Stop){
                        $Client = $Listener.AcceptTCPClient()
                        $Listener.Stop()

                        $Stream = $Client.GetStream()

                        $Buff = New-Object Byte[] 1024
                        $CMDsIn = ''
                        $Timeout = 1
                        While(!$SyncHash.Stop -AND !(($CMDsIn -match '{CMDS_START}') -AND ($CMDsIn -match '{CMDS_END}')) -AND ($Timeout -lt 1000)){
                            While($Stream.DataAvailable){
                                [Void]$Stream.Read($Buff, 0, 1024)
                                $CMDsIn+=([System.Text.Encoding]::UTF8.GetString($Buff))
                            }
                            [System.Threading.Thread]::Sleep(500)
                            $Timeout++
                        }

                        If(!$SyncHash.Stop -AND ($Timeout -lt 1000)){GO -InlineCommand ($CMDsIn -replace '{CMDS_START}' -replace '{CMDS_END}') -Server}
                        
                        If(!$SyncHash.Stop -AND ($Timeout -lt 1000)){
                            Try{
                                $Stream.Write([System.Text.Encoding]::UTF8.GetBytes('{COMPLETE}'),0,10)
                                $Listener.Start()
                            }Catch{
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'ERROR! COULD NOT RETURN COMPLETE MESSAGE TO REMOTE END!')}
                            }
                        }
                    }

                    $Listener.Stop()

                    $SyncHash.Stop = $False
                    $SyncHash.Restart = $False
                })
                $ServerStart.Parent = $TabPageServer

                $ServerPort = [GUI.TB]::New(75,25,135,26,'42069')
                $ServerPort.Add_TextChanged({$This.Text = ($This.Text -replace '\D')})
                $ServerPort.Parent = $TabPageServer
            $TabPageServer.Parent = $TabControllerAdvanced

            $TabPageConfig = [GUI.TP]::New(0, 0, 0, 0, 'Config')
                $DelayLabel = [GUI.L]::New(175, 22, 10, 8, 'Keystroke Delay (ms):')
                $DelayLabel.Parent = $TabPageConfig

                $DelayTimer = [GUI.NUD]::New(150, 25, 10, 30)
                $DelayTimer.Maximum = 999999999
                $DelayTimer.Parent = $TabPageConfig
                $DelayTimer.BringToFront()

                $DelayCheck = [GUI.ChB]::New(150, 25, 170, 25, 'Randomize')
                $DelayCheck.Parent = $TabPageConfig

                $DelayRandLabel = [GUI.L]::New(200, 25, 25, 60, 'Random Weight (ms):')
                $DelayRandLabel.Parent = $TabPageConfig

                $DelayRandTimer = [GUI.NUD]::New(75, 25, 180, 55)
                $DelayRandTimer.Maximum = 999999999
                $DelayRandTimer.Parent = $TabPageConfig
                $DelayRandTimer.BringToFront()

                $CommDelayLabel = [GUI.L]::New(175, 22, 10, 108, 'Command Delay (ms):')
                $CommDelayLabel.Parent = $TabPageConfig

                $CommandDelayTimer = [GUI.NUD]::New(150, 25, 10, 130)
                $CommandDelayTimer.Maximum = 999999999
                $CommandDelayTimer.Parent = $TabPageConfig
                $CommandDelayTimer.BringToFront()

                $CommDelayCheck = [GUI.ChB]::New(150, 25, 170, 125, 'Randomize')
                $CommDelayCheck.Parent = $TabPageConfig

                $CommRandLabel = [GUI.L]::New(200, 25, 25, 160, 'Random Weight (ms):')
                $CommRandLabel.Parent = $TabPageConfig

                $CommRandTimer = [GUI.NUD]::New(75, 25, 180, 155)
                $CommRandTimer.Maximum = 999999999
                $CommRandTimer.Parent = $TabPageConfig
                $CommRandTimer.BringToFront()

                $ShowCons = [GUI.ChB]::New(150, 25, 10, 200, 'Show Console')
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

                $OnTop = [GUI.ChB]::New(150, 25, 10, 225, 'Always On Top')
                $OnTop.Add_CheckedChanged({
                    $Form.TopMost = !$Form.TopMost
                })
                $OnTop.Parent = $TabPageConfig
            $TabPageConfig.Parent = $TabControllerAdvanced
        $TabControllerAdvanced.Parent = $TabPageAdvanced
    $TabPageAdvanced.Parent = $TabController
$TabController.Parent = $Form

$Help = [GUI.B]::New(25, 25, 430, -1, '?')
$Help.Add_Click({Notepad ($env:APPDATA+'\Macro\Help.txt')})
$Help.Parent = $Form

$GO = [GUI.B]::New(200, 25, 25, 415, 'Run')
$GO.Add_Click({If(!$WhatIfCheck.Checked){GO}Else{GO -WhatIf}})
$GO.Parent = $Form

$GOSel = [GUI.B]::New(125, 25, 230, 415, 'Run Selection')
$GOSel.Add_Click({
    If(!$WhatIfCheck.Checked){
        GO -Selection
    }Else{
        GO -Selection -WhatIf
    }
})
$GOSel.Parent = $Form

$WhatIfCheck = [GUI.ChB]::New(80,27,365,415,'WhatIf?')
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

$RightClickMenu = [GUI.P]::New(0,0,-1000,-1000)
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
            $PH = [GUI.B]::New(135,22,0,(22*$Index),$_)
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
$RightClickMenu.Size = [GUI.SP]::SI(137,(2+($Index*22)))

$RightClickMenu.Visible = $False
$RightClickMenu.BorderStyle = 'FixedSingle'
$RightClickMenu.Add_MouseLeave({Handle-RMenuExit $This})
$RightClickMenu.Parent = $Form

$FindForm = [GUI.P]::New(250,110,(($Form.Width - 250) / 2),(($Form.Height - 90) / 2))
$FindForm.BorderStyle = 'FixedSingle'
$FindForm.Visible = $False
    $FRTitle = [GUI.L]::New(300,18,25,7,'Find and Replace (RegEx):')
    $FRTitle.Parent = $FindForm
    $FLabel = [GUI.L]::New(20,20,4,28,'F:')
    $FLabel.Parent = $FindForm
    $Finder = [GUI.RTB]::New(200,20,25,25,'')
    $Finder.AcceptsTab = $True
    $Finder.Parent = $FindForm
    $RLabel = [GUI.L]::New(20,20,4,53,'R:')
    $RLabel.Parent = $FindForm
    $Replacer = [GUI.RTB]::New(200,20,25,50,'')
    $Replacer.AcceptsTab = $True
    $Replacer.Parent = $FindForm
    $FRGO = [GUI.B]::New(95,25,25,75,'Replace All')
        $FRGO.Add_Click({
            $Commands.Text = ((($Commands.Text.Split($NL) | ?{$_ -ne ''}) | %{
                $_ -replace ($This.Parent.GetChildAtPoint([GUI.SP]::PO(30,30)).Text),($This.Parent.GetChildAtPoint([GUI.SP]::PO(30,55)).Text.Replace('(NEWLINE)',$NL))
            }) -join $NL)
        })
    $FRGO.Parent = $FindForm
    $FRClose = [GUI.B]::New(95,25,130,75,'Close')
        $FRClose.Add_Click({$This.Parent.Visible = $False})
    $FRClose.Parent = $FindForm
$FindForm.Parent = $Form

$Form.Controls | %{$_.Font = New-Object System.Drawing.Font('Lucida Console',9,[System.Drawing.FontStyle]::Regular)}

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
    @{NAME='PrevProfile';EXPRESSION={$Null}},`
    @{NAME='LastLoc';EXPRESSION={$Null}},`
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

    $ShowCons.Checked = !$ShowCons.Checked
    Sleep -Milliseconds 40
    $ShowCons.Checked = !$ShowCons.Checked

    $OnTop.Checked = !$OnTop.Checked
    Sleep -Milliseconds 40
    $OnTop.Checked = !$OnTop.Checked

    If($LoadedConfig.PrevProfile -OR $Macro -OR $CLICMD){
        If($Macro){
            If(Test-Path ($env:APPDATA+'\Macro\Profiles\'+$Macro)){
                $Profile.Text = ('Working Profile: ' + $Macro)
                $Form.Text = ('Pickle - ' + $Macro)
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
                $Form.Text = ('Pickle - ' + $LoadedConfig.PrevProfile)
                $Script:LoadedProfile = $LoadedConfig.PrevProfile
                $SavedProfiles.SelectedIndex = $SavedProfiles.Items.IndexOf($LoadedConfig.PrevProfile)
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

    $Form.Visible = $False

    $Form.Add_Closing({
        $Config.ShowConsCheck = $ShowCons.Checked
        $Config.OnTopCheck    = $OnTop.Checked

        If($Script:LoadedProfile -ne $Null){
            $Config.PrevProfile = $Script:LoadedProfile
            
            If(!$Script:Saved){
                $result = [System.Windows.Forms.MessageBox]::Show('Save before exiting?' , "Info" , 4)
                If($result -eq 'Yes'){
                    $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$Script:LoadedProfile+'\')

                    [Void](MKDIR $TempDir)

                    $Script:Saved = $True

                    Try{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-JSON | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                    }Catch{
                        '' | Select @{Name='Commands';Expression={$Commands.Text}},@{Name='Functions';Expression={$FunctionsBox.Text}} | ConvertTo-CSV -NoTypeInformation | Out-File ($TempDir+$Script:LoadedProfile+'.pik') -Width 1000 -Force
                    }
                }
            }
        }Else{
            $Config.PrevProfile = $Null
        }

        $Config.LastLoc = ([String]$Form.Location.X + ',' + [String]$Form.Location.Y)
        $Config.SavedSize = ([String]$Form.Size.Width + ',' + [String]$Form.Size.Height)

        Try{
            $Config | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\_Config_.json') -Width 1000 -Force
        }Catch{
            Try{
                $Config | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\_Config_.csv') -Width 1000 -Force
            }Catch{
                [System.Console]::WriteLine('COULD NOT SAVE CONFIG FILE!')
                [System.Threading.Thread]::Sleep(3000)
            }
        }
    })

    [System.Windows.Forms.Application]::Run($Form)
}

$UndoHash.KeyList | %{
    If($_ -notmatch 'MOUSE'){
        [Cons.KeyEvnt]::keybd_event(([String]$_), 0, '&H2', 0)
    }Else{
        [Cons.MouseEvnt]::mouse_event(([Int]($_.Replace('MOUSE','').Replace('L',4).Replace('R',16).Replace('M',64))), 0, 0, 0, 0)
    }
}

$SyncHash.Kill = $True

$Config.DelayTimeVal  = $DelayTimer.Value
$Config.DelayChecked  = $DelayCheck.Checked
$Config.DelayRandVal  = $DelayRandTimer.Value

$Config.CommTimeVal   = $CommandDelayTimer.Value
$Config.CommChecked   = $CommDelayCheck.Checked
$Config.CommRandVal   = $CommRandTimer.Value

If($Host.Name -match 'Console'){Exit}
}

If($(Try{[Void][PSObject]::New()}Catch{$True})){
    $MainBlock = ($MainBlock.toString().Split([System.Environment]::NewLine) | ?{$_ -ne ''} | %{
        If($_ -match ']::New\('){
            (($_.Split('[')[0]+'(New-Object '+$_.Split('[')[-1]+')') -replace ']::New',' -ArgumentList ').Replace(' -ArgumentList ()','')
        }Else{
            $_
        }
    }) -join [System.Environment]::NewLine
}
$MainBlock = [ScriptBlock]::Create($MainBlock)

$MainBlock.Invoke($Macro)
