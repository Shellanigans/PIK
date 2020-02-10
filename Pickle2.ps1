############################################################################################################################################################################################################################################################################################################
             ###                                                                    #       #####     # #   
              #   #    #  #  #####  #    ##    #       #  ######  ######           #       #     #    # #   
              #   ##   #  #    #    #   #  #   #       #      #   #               #        #        ####### 
              #   # #  #  #    #    #  #    #  #       #     #    #####          #         #          # #   
              #   #  # #  #    #    #  ######  #       #    #     #             #          #        ####### 
              #   #   ##  #    #    #  #    #  #       #   #      #            #           #     #    # #   
             ###  #    #  #    #    #  #    #  ######  #  ######  ######      #             #####     # #   
############################################################################################################################################################################################################################################################################################################                                                                                                

Param([String]$Macro = $Null,[String]$CLICMD = '')

Remove-Variable * -Exclude Macro,CLICMD -EA SilentlyContinue

$MainBlock = {
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing,Microsoft.VisualBasic -IgnoreWarnings -TypeDefinition @'
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

############################################################################################################################################################################################################################################################################################################
             #######                                                           
             #        #    #  #    #   ####   #####  #   ####   #    #   ####  
             #        #    #  ##   #  #    #    #    #  #    #  ##   #  #      
             #####    #    #  # #  #  #         #    #  #    #  # #  #   ####  
             #        #    #  #  # #  #         #    #  #    #  #  # #       # 
             #        #    #  #   ##  #    #    #    #  #    #  #   ##  #    # 
             #         ####   #    #   ####     #    #   ####   #    #   ####  
############################################################################################################################################################################################################################################################################################################
Function Interpret{
    Param([String]$X)

    $X = [Parser]::Interpret($X)
    $DepthOverflow = 0

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
            ($X -match '{VAR\+\+ ') -OR `
            ($X -match '{VAR-- ') -OR `
            ($X -match '{MANIP ') -OR `
            ($X -match '{GETCON ') -OR `
            ($X -match '{FINDVAR ') -OR `
            ($X -match '{GETPROC ') -OR `
            ($X -match '{GETWIND ') -OR `
            ($X -match '{GETWINDTEXT ') -OR `
            ($X -match '{GETFOCUS') -OR `
            ($X -match '{GETSCREEN') -OR `
            ($X -match '{READIN '))
        ){
        $PHSplitX = $X.Split('{}')
        
        $PHSplitX | ?{$_ -match 'VAR \S+' -AND $_ -notmatch '='} | %{
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
        
        $PHSplitX | ?{$_ -match 'GETCON \S+'} | %{
            $X = ($X.Replace(('{'+$_+'}'),((GC $_.Substring(7)) | Out-String)))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

        $PHSplitX | ?{$_ -match 'GETSCREEN'} | %{
            $X = ($X.Replace(('{'+$_+'}'),(([System.Windows.Forms.Screen]::AllScreens | %{$PH = $_.Bounds; [String]$PH.X+','+$PH.Y+','+$PH.Width+','+$PH.Height}) -join ';').TrimEnd(';')))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

        $PHSplitX | ?{$_ -match 'FINDVAR \S+'} | %{
            $X = (($Script:VarsHash.Keys | ?{$_ -match ($X -replace '^{FINDVAR ' -replace '}$')} | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort}) -join ',')
        }
    
        $PHSplitX | ?{
                ($_ -match 'GETPROC ((?!-(ID|HAND) )\d+|-ID \S+|-HAND \d+)') -OR `
                ($_ -match 'GETWIND ((?!-(ID|HAND) )\d+|-ID \S+|-HAND \d+)') -OR `
                ($_ -match 'GETWINDTEXT ((?!-(ID|HAND) )\d+|-ID \S+|-HAND \d+)') -OR `
                ($_ -match 'GETFOCUS( -ID| -HAND)?')} | %{
            $PHProc = $_
            $PHSel = $PHProc.Split(' ')[0].Replace('{','')

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
                                    $PHOut+=([String]$PHTMPProc.Id+';')
                                }
                            }Else{
                                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+'COULD NOT PULL PROC, HANDLE IS VALID')}
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

        $PHSplitX | ?{$_ -match 'READIN \S+'} | %{
            If($CommandLine -OR ($X -match '{READIN -C')){
                $PH = $_.Substring(9)
            }Else{
                $PH = [Microsoft.VisualBasic.Interaction]::InputBox(($_.Substring(7)),'READIN')
            }

            $X = ($X.Replace(('{'+$_+'}'),($PH)))
            If($ShowCons.Checked){[System.Console]::WriteLine($X)}
        }

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

        $PHSplitX | ?{($_ -match '^VAR\+\+ \S+') -OR ($_ -match '^VAR-- \S+')} | %{
            $PH = $_.Split(' ')[1]
            If($Script:VarsHash.ContainsKey($PH)){
                Try{
                    If($_ -match '\+\+'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH + 1)
                    }ElseIf($_ -match '--'){
                        $Script:VarsHash.$PH = ([Double]$Script:VarsHash.$PH - 1)
                    }
                }Catch{
                    If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$PH+' BAD DATA TYPE!')}
                }
            }Else{
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$PH+' WAS NOT FOUND!')}
            }
            $X = ''
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
        
        If($X -match '^{GOTO '){
            $GOTOLabel = ($X.Substring(0,$X.Length - 1) -replace '^{GOTO ')
            $SyncHash.Restart = $True
            $SyncHash.Stop = $True
                
            $X = ''
        }

        If($X -match '{IF \(.*?\)}'){
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
                    'LT'       {Try{If([Double]$Op1 -lt [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT STR TO NUMERIC!')}}}
                    'LE'       {Try{If([Double]$Op1 -le [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT STR TO NUMERIC!')}}}
                    'GT'       {Try{If([Double]$Op1 -gt [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT STR TO NUMERIC!')}}}
                    'GE'       {Try{If([Double]$Op1 -ge [Double]$Op2)      {$Script:IfEl = $True}}Catch [System.Management.Automation.RuntimeException]{If($ShowCons.Checked){[System.Console]::WriteLine($Tab + 'COULD NOT CONVERT STR TO NUMERIC!')}}}
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
            If($X -match '{ELSE}'){$Script:IfEl = !$Script:IfEl}

            If($X -match '{FI}'){$Script:IfEl = $True}
        }
        ElseIf($Script:IfEl){
            $Escaped = $False
            $X,$Escaped = (Interpret $X)

            $TempX = $Null
            If($Escaped){
                $TempX = $X
                $X = ''
            }

            If($X -match '^{POWER .*}$'){
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
                        
                        If(($PHX -match '\+') -OR ($PHX -match '-\d+') -OR ($PHMoveType -notmatch 'NONE')){
                            $Coords = [Cons.Curs]::GPos()
                            $PHTMPCoords = $Coords
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
                            $DistX = ($MoveCoords[0]-$Coords.X)
                            If($DistX -lt 0){$DistX = ($Coords.X-$MoveCoords[0]);$Right = $False}
                            $DistX = [Math]::Pow($DistX,2)

                            $Down = $True
                            $DistY = ($MoveCoords[1]-$Coords.Y)
                            If($DistY -lt 0){$DistY = ($Coords.Y-$MoveCoords[1]);$Down = $False}
                            $DistY = [Math]::Pow($DistY,2)
                            
                            $Dist = [math]::Sqrt(($DistX+$DistY))
                            $Dist = [Math]::Round($Dist)

                            Switch($PHMoveType){
                                'LINEAR' {
                                    0..$Dist | %{
                                        If($Right) {$PHTMPCoords.X = ($PHTMPCoords.X+1)}Else{$PHTMPCoords.X = ($PHTMPCoords.X-1)}
                                        If($Down)  {$PHTMPCoords.Y = ($PHTMPCoords.Y+1)}Else{$PHTMPCoords.Y = ($PHTMPCoords.Y-1)}
                                        [Cons.Curs]::SPos($PHTMPCoords.X,$PHTMPCoords.Y)
                                        If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                                    }
                                    [Cons.Curs]::SPos($MoveCoords[0],$MoveCoords[1])
                                }
                                'SINE'   {
                                    $Offset = 0
                                    For($i = 0; $i -lt $Dist; $i+=[Math]::Sqrt(2)*$Offset){
                                        $Offset = ($Weight*[Math]::Sin(([Math]::PI*$i)/$Dist) + 1)
                                        
                                        If($Right) {$PHTMPCoords.X = ($PHTMPCoords.X+$Offset)}Else{$PHTMPCoords.X = ($PHTMPCoords.X-$Offset)}
                                        If($Down)  {$PHTMPCoords.Y = ($PHTMPCoords.Y+$Offset)}Else{$PHTMPCoords.Y = ($PHTMPCoords.Y-$Offset)}
                                        [Cons.Curs]::SPos($PHTMPCoords.X,$PHTMPCoords.Y)
                                        If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                                    }
                                    [Cons.Curs]::SPos($MoveCoords[0],$MoveCoords[1])
                                }
                                'RANDOM' {
                                    $Random = [System.Random]::New()
                                    
                                    $Offset = 0
                                    For($i = 0; $i -lt $Dist; $i+=[Math]::Sqrt(2)*$Offset){
                                        $Offset = $Random.Next(1,($Weight+1))
                                        
                                        If($Right) {$PHTMPCoords.X = ($PHTMPCoords.X+$Offset)}Else{$PHTMPCoords.X = ($PHTMPCoords.X-$Offset)}
                                        If($Down)  {$PHTMPCoords.Y = ($PHTMPCoords.Y+$Offset)}Else{$PHTMPCoords.Y = ($PHTMPCoords.Y-$Offset)}
                                        [Cons.Curs]::SPos($PHTMPCoords.X,$PHTMPCoords.Y)
                                        If($PHDelay -gt 0){[System.Threading.Thread]::Sleep($PHDelay)}
                                    }
                                    [Cons.Curs]::SPos($MoveCoords[0],$MoveCoords[1])
                                }
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
            }ElseIf($X -match '^{KILL}$'){
                $SyncHash.Stop = $True
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
                
                        If($_ -notmatch '^\s*?\\\\#' -AND !$Commented -AND $_ -notmatch '^:::'){$_}Else{If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$_)}}
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
                    $PHProc = ($PHProc.Split(' ') | ?{$_ -ne ''})[1].Replace('{','').Replace('}','')
                    If(($Script:HiddenWindows.Keys -join '')){
                        $PHHidden = (($Script:HiddenWindows.Keys | ?{$_ -match ('^'+$PHProc+'_')}) | %{$Script:HiddenWindows.$_})
                    }
                    $PHProc = (PS $PHProc | ?{$_.MainWindowHandle -ne 0})
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
                                'FOCUS'       {If($TrueHand){[Void][Cons.App]::Act($PHTMPProcTitle)}Else{[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,9)}}
                                'MIN'         {[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,6)}
                                'MAX'         {[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,3)}
                                'SHOW'        {[Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,9)}
                                'HIDE'        {
                                    [Void][Cons.WindowDisp]::ShowWindow($PHTMPProcHand,0)
                                    If($TrueHand){
                                        #$Script:HiddenWindows.Add(('UNK_UNK_'+$PHTMPProcHand+'_'+[DateTime]::Now.ToFileTimeUtc()),$PHTMPProcHand)
                                    }Else{
                                        $Script:HiddenWindows.Add(($PHTMPProc.Name+'_'+$PHTMPProc.Id+'_'+$PHTMPProcHand+'_'+[DateTime]::Now.ToFileTimeUtc()),$PHTMPProc)
                                    }
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
            }ElseIf($X -match '{CONSOLE .*?}'){
                If($ShowCons.Checked){[System.Console]::WriteLine($Tab+($X -replace '^{CONSOLE ' -replace '}$'))}
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

Function GO ([Switch]$SelectionRun,[Switch]$WhatIf,[String]$InlineCommand){
    [System.Console]::WriteLine($NL+'Initializing:')
    [System.Console]::WriteLine('-------------------------')

    $Script:Refocus = $False
    $Script:IfEl = $True

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

    If($FunctionsBox.Text -replace '\s*' -AND !$InlineCommand){
        [System.Console]::WriteLine($Tab+'Parsing Functions:')
        [System.Console]::WriteLine($Tab+'-------------------------')

        $FunctionsBox.Text.Split($NL) | ?{$_ -ne ''} | %{$_.TrimStart(' ').TrimStart($Tab)} | %{
            $FunctionStart = $False

            $FunctionText = @()
        }{
            If(!$FunctionStart -AND $_ -match '^{FUNCTION NAME '){$FunctionStart = $True}
            If($FunctionStart){
                If($_ -match '^{FUNCTION NAME '){
                    $NameFunc = [String]($_ -replace '{FUNCTION NAME ' -replace '}')
                }ElseIf($_ -match '^{FUNCTION END}'){
                    $FunctionStart = $False
                    $Script:FuncHash.Add($NameFunc,($FunctionText -join $NL))
                    $FunctionText = @()
                }Else{
                    $FunctionText+=$_
                }
            }
        }

        $Script:FuncHash.Keys | Sort | %{
            [System.Console]::WriteLine(($Tab*2) + $_ + $NL + ($Tab*2) + '-------------------------' + $NL + (($Script:FuncHash.$_.Split($NL) | ?{$_ -ne ''} | %{($Tab*2)+($_ -replace '^\s*')}) -join $NL) + $NL)
        }
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
                    }) | %{$PHText = $_.SelectedText}
                }Else{
                    $PHText = $Commands.Text
                }
            }

            ($PHText -replace ('`'+$NL),'').Split($NL) | %{$_ -replace '^\s*'} | ?{$_ -ne ''} | %{$Commented = $False}{
                    If($_ -match '^\s*?<\\\\#'){$Commented = $True}
                    If($_ -match '^\s*?\\\\#>'){$Commented = $False}
                
                    If($_ -notmatch '^\s*?\\\\#' -AND !$Commented){
                        $_
                    }Else{
                        If($ShowCons.Checked){[System.Console]::WriteLine($Tab+$_)}
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
                                If(!$WhatIf){
                                    $PHGOTO = (Actions $Line)
                                }Else{
                                    $PHGOTO = (Actions $Line -WhatIf)
                                }
                            }
                        }ElseIf(($_ -match '^:::'+$PHGOTO)){
                            $PHGOTO = ''
                        }
                    }Catch{
                        [System.Console]::WriteLine($Tab+'UNHANDLED ERROR: '+$_.ToString())
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
        $SyncHash.Stop = $False

        If(!$CommandLine){    
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
            'Goto Bottom'         {$PHObj.SelectionStart = $PHObj.Text.Length}
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

    $Position = ('{MOUSE '+((($PH).ToString().Substring(3) -replace 'Y=').TrimEnd('}'))+'}')
    
    $MouseCoordsBox.Text = $Position

    $Bounds = [GUI.Rect]::R($PH.X,$PH.Y,($PH.X+1),($PH.Y+1))

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
    }Else{
        $PixColorBox.ForeColor = [System.Drawing.Color]::White
    }

    $Graphics.Dispose()
    $BMP.Dispose()
}

Function Handle-TextBoxKey($KeyCode, $MainObj, $BoxType, $Shift, $Control, $Alt){
    If($KeyCode -eq 'F1'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '<\\# '
    }ElseIf($KeyCode -eq 'F2'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '\\#> '
    }ElseIf($KeyCode -eq 'F3'){
        $MainObj.SelectionLength = 0
        $MainObj.SelectedText = '\\# '
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
    }ElseIf($KeyCode -eq 'F10'){
        $TempSelectionIndex = $MainObj.SelectionStart
        $TempSelectionLength = $MainObj.SelectionLength

        $MainObj.SelectionStart = 0
        $MainObj.SelectionLength = $MainObj.Text.Length
        $MainObj.SelectionColor = [System.Drawing.Color]::Black
                    
        ($MainObj.Lines | %{$Count = 0; $Commented = $False}{
            $PH = $_.TrimStart(' ').TrimStart($Tab)

            If($PH -match '^<\\\\#'){$Commented = $True}
            If($PH -match '^\\\\#>'){$Commented = $False}

            If($PH -match '^\\\\#' -OR $Commented){
                'G,'+$Count
            }
            ElseIf(!$Commented){
                If(($PH -match '^:::') -AND ($BoxType -eq 'Commands')){
                    'B,'+$Count
                }

                If($PH -match '^.*{.*}.*$'){
                    'R,'+$Count
                }
            }
                        
            $Count++
        }) | %{
            $PHLine = $MainObj.Lines[$_.Split(',')[-1]]
            $MainObj.SelectionStart = $MainObj.GetFirstCharIndexFromLine($_.Split(',')[-1])
            $MainObj.SelectionLength = $PHLine.Length
            
            Switch($_.Split(',')[0]){
                'G' {$MainObj.SelectionColor = [System.Drawing.Color]::Gray}
                'B' {$MainObj.SelectionColor = [System.Drawing.Color]::DarkBlue}
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
        If($Profile.Text -ne 'Working Profile: None/Prev Text Vals'){
            $Form.Text = ($Form.Text -replace '\*$')

            $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

            [Void](MKDIR $TempDir)

            $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
            $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force

            $SaveAsProfText.Text = ''
        }
    }ElseIf($KeyCode -eq 'F12'){
        $GO.PerformClick()
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
        If($Profile.Text -ne 'Working Profile: None/Prev Text Vals'){
            $Form.Text = ($Form.Text -replace '\*$')

            $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

            [Void](MKDIR $TempDir)

            $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
            $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force

            $SaveAsProfText.Text = ''
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

    Add-Type -Name Win32 -Namespace API -MemberDefinition '
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
                    If($Form.Text -notmatch '\*$'){
                        $Form.Text+='*'
                    }
                    $This.Text | Out-File ($env:APPDATA+'\Macro\Commands.txt') -Width 1000 -Force
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
                $Commands.Text = Try{(Get-Content ($env:APPDATA+'\Macro\Commands.txt') -ErrorAction SilentlyContinue | Out-String).TrimEnd($NL) -join $NL}Catch{''}
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
                    If($Form.Text -notmatch '\*$'){
                        $Form.Text+='*'
                    }
                    $This.Text | Out-File ($env:APPDATA+'\Macro\Functions.txt') -Width 1000 -Force
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
                $FunctionsBox.Text = Try{(Get-Content ($env:APPDATA+'\Macro\Functions.txt') -ErrorAction SilentlyContinue | Out-String).TrimEnd($NL) -join $NL}Catch{''}
                $FunctionsBox.Dock = 'Fill'
                $FunctionsBox.Parent = $TabPageFunctMain
                $FunctionsBox.Add_KeyDown({Handle-TextBoxKey -KeyCode ($_.KeyCode.ToString()) -MainObj $This -BoxType 'Functions' -Shift $_.Shift -Control $_.Control -Alt $_.Alt})
            $TabPageFunctMain.Parent = $TabControllerComm

            $TabPageHelper = [GUI.TP]::new(0, 0, 0, 0, 'Info')
                $TabHelperSub = [GUI.TC]::New(0, 0, 0, 0)
                $TabHelperSub.Dock = 'Fill'
                    $TabHelperSubMouse = [GUI.TP]::new(0, 0, 0, 0, 'Mouse/Pixel')
                        $GetMouseCoords = [GUI.B]::New(110, 25, 10, 25, 'Get Mouse Inf')
                        $GetMouseCoords.Add_MouseMove({If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){Handle-MousePosGet; $Form.Refresh()}})
                        $GetMouseCoords.Parent = $TabHelperSubMouse

                        $MouseCoordLabel = [GUI.L]::New(100, 10, 130, 10, 'Mouse Coords:')
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
                        $XCoord.Add_ValueChanged({[Cons.Curs]::SPos($This.Value,$YCoord.Value)})
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
                        $YCoord.Add_ValueChanged({[Cons.Curs]::SPos($XCoord.Value,$This.Value)})
                        $YCoord.Add_KeyUp({
                            If($_.KeyCode -eq 'Return'){
                                [Cons.Curs]::SPos($XCoord.Value,$This.Value)

                                Handle-MousePosGet
                            }
                        })
                        $YCoord.Parent = $TabHelperSubMouse

                        $PixColorLabel = [GUI.L]::New(100, 10, 130, 60, 'HexVal (ARGB):')
                        $PixColorLabel.Parent = $TabHelperSubMouse

                        $PixColorBox = [GUI.TB]::New(140, 25, 130, 75, '')
                        $PixColorBox.ReadOnly = $True
                        $PixColorBox.Multiline = $True
                        $PixColorBox.Add_DoubleClick({If($This.Text){[Cons.Clip]::SetT($This.Text); $This.SelectAll()}})
                        $PixColorBox.Parent = $TabHelperSubMouse
                    $TabHelperSubMouse.Parent = $TabHelperSub

                    $TabHelperSubSystem = [GUI.TP]::new(0, 0, 0, 0, 'Sys/Proc')
                        $ScreenInfoLabel = [GUI.L]::New(100, 10, 10, 10, 'Display Info:')
                        $ScreenInfoLabel.Parent = $TabHelperSubSystem

                        $ScreenInfoBox = [GUI.RTB]::New(250, 95, 10, 25, '')
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

                        $ProcInfoLabel = [GUI.L]::New(100,15,10,136,'Process Info:')
                        $ProcInfoLabel.Parent = $TabHelperSubSystem

                        $GetProcInfo = [GUI.B]::New(135, 20, 125, 132, 'Get Proc Inf')
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

                        $ProcInfoBox = [GUI.RTB]::New(360, 160, 10, 155, '')
                        $ProcInfoBox.Multiline = $True
                        $ProcInfoBox.ScrollBars = 'Both'
                        $ProcInfoBox.WordWrap = $False
                        $ProcInfoBox.ReadOnly = $True
                        $ProcInfoBox.Text = ''
                        $ProcInfoBox.Parent = $TabHelperSubSystem
                    $TabHelperSubSystem.Parent = $TabHelperSub

                    $TabPageDebug = [GUI.TP]::New(0, 0, 0, 0, 'Debugging')
                        $GetFuncts = [GUI.B]::New(135, 25, 10, 10, 'Display Functions')
                        $GetFuncts.Add_Click({
                            $Script:FuncHash.Keys | Sort | %{
                                If($ShowCons.Checked){[System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:FuncHash.$_ + $NL + $NL)}

                                If($ShowCons.Checked){[System.Console]::WriteLine($NL * 3)}
                            }
                        })
                        $GetFuncts.Parent = $TabPageDebug

                        $GetVars = [GUI.B]::New(135, 25, 10, 35, 'Display Variables')
                        $GetVars.Add_Click({
                            $Script:VarsHash.Keys | Sort -Unique | Group Length | Select *,@{NAME='IntName';EXPRESSION={[Int]$_.Name}} | Sort IntName | %{$_.Group | Sort} | %{
                                If($ShowCons.Checked){[System.Console]::WriteLine($NL + $_ + $NL + '-------------------------' + $NL + $Script:VarsHash.$_ + $NL + $NL)}

                                If($ShowCons.Checked){[System.Console]::WriteLine($NL * 3)}
                            }
                        })
                        $GetVars.Parent = $TabPageDebug

                        $ClearCons = [GUI.B]::New(135, 25, 10, 60, 'Clear Console')
                        $ClearCons.Add_Click({Cls; $PseudoConsole.Text = ''})
                        $ClearCons.Parent = $TabPageDebug

                        $PseudoConsole = [GUI.RTB]::New(360, 165, 10, 110, '')
                        $PseudoConsole.ReadOnly = $True
                        $PseudoConsole.ScrollBars = 'Both'
                        #$PseudoConsole.ForeColor = [System.Drawing.Color]::FromArgb(0xFFF5F5F5)
                        #$PseudoConsole.BackColor = [System.Drawing.Color]::FromArgb(0xFF012456)
                        $pseudoConsole.Parent = $TabPageDebug

                        $SingleCMD = [GUI.RTB]::New(260, 20, 10, 300, '')
                        $SingleCMD.AcceptsTab = $True
                        $SingleCMD.Parent = $TabPageDebug

                        $SingleGO = [GUI.B]::New(90, 20, 280, 300, 'Run Line')
                        $SingleGO.Add_Click({
                            If(!$WhatIfCheck.Checked -AND $SingleCMD.Text){GO -InlineCommand $SingleCMD.Text}Else{GO -InlineCommand $SingleCMD.Text -WhatIf}
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
            $TabPageProfiles = [GUI.TP]::New(0, 0, 0, 0,'Save/Load')
                $Profile = [GUI.L]::New(250, 20, 10, 10, 'Working Profile: None/Prev Text Vals')
                $Profile.Parent = $TabPageProfiles

                $SavedProfilesLabel = [GUI.L]::New(120, 20, 10, 36, 'Saved Profiles:')
                $SavedProfilesLabel.Parent = $TabPageProfiles

                $SavedProfiles = [GUI.CoB]::New(250, 25, 10, 60)
                $SavedProfiles.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})
                $SavedProfiles.Parent = $TabPageProfiles

                $QuickSave = [GUI.B]::New(75, 25, 10, 85, 'SAVE')
                $QuickSave.Add_Click({
                    If($Profile.Text -ne 'Working Profile: None/Prev Text Vals'){
                        $Form.Text = ($Form.Text -replace '\*$')

                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

                        [Void](MKDIR $TempDir)

                        $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                        $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force

                        $SaveAsProfText.Text = ''
                    }
                })
                $QuickSave.Parent = $TabPageProfiles

                $LoadProfile = [GUI.B]::New(75, 25, 99, 85, 'LOAD')
                $LoadProfile.Add_Click({
                    If((Get-ChildItem ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem)).Count -gt 1){
                        $Profile.Text = ('Working Profile: ' + $(If($SavedProfiles.SelectedItem -ne $Null){$SavedProfiles.SelectedItem}Else{'None/Prev Text Vals'}))

                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$SavedProfiles.SelectedItem)

                        $Commands.Text = ((Get-Content ($TempDir+'\Commands.txt')).Split($NL) -join $NL).TrimEnd($NL)
                        $FunctionsBox.Text = ((Get-Content ($TempDir+'\Functions.txt')).Split($NL) -join $NL).TrimEnd($NL)

                        $Form.Text = ('Pickle - ' + $SavedProfiles.SelectedItem)
                    }
                })
                $LoadProfile.Parent = $TabPageProfiles

                $BlankProfile = [GUI.B]::New(75, 25, 186, 85, 'NEW')
                $BlankProfile.Add_Click({
                    $Profile.Text = 'Working Profile: None/Prev Text Vals'
                    
                    $SavedProfiles.SelectedIndex = -1

                    $Commands.Text = ''
                    $FunctionsBox.Text = ''

                    $Form.Text = 'Pickle'
                })
                $BlankProfile.Parent = $TabPageProfiles

                $SaveNewProfLabel = [GUI.L]::New(170, 20, 10, 170, 'Save Current Profile As:')
                $SaveNewProfLabel.Parent = $TabPageProfiles

                $SaveProfile = [GUI.B]::New(75, 20, 186, 189, 'SAVE AS')
                $SaveProfile.Add_Click({
                    If($SaveAsProfText.Text){
                        $Form.Text = ('Pickle - ' + $SaveAsProfText.Text)
                        $Profile.Text = ('Working Profile: ' + $SaveAsProfText.Text)

                        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+$SaveAsProfText.Text)

                        [Void](MKDIR $TempDir)

                        $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
                        $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force

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
                    If($Profile.Text -eq ('Working Profile: ' + $DelProfText.Text)){
                        $Profile.Text = ('Working Profile: None/Prev Text Vals')
                        $SavedProfiles.SelectedItem = $Null

                        $Form.Text = ('Pickle')
                    }

                    (Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | ?{$_.Name -eq $DelProfText.Text} | Remove-Item -Recurse -Force
                    $SavedProfiles.Items.Clear()
                    [Void]((Get-ChildItem ($env:APPDATA+'\Macro\Profiles')) | %{$SavedProfiles.Items.Add($_.Name)})

                    $DelProfText.Text = ''
                })
                $DelProfile.Parent = $TabPageProfiles

                $DelProfText = [GUI.TB]::New(165, 25, 10, 260, '')
                $DelProfText.Parent = $TabPageProfiles

                $OpenFolder = [GUI.B]::New(250, 25, 10, 310, 'Open Working Folder')
                $OpenFolder.Add_Click({Explorer ($env:APPDATA+'\Macro')})
                $OpenFolder.Parent = $TabPageProfiles
            $TabPageProfiles.Parent = $TabControllerAdvanced

            $TabPageConfig = [GUI.TP]::New(0, 0, 0, 0, 'Config')
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
                        If($This.Checked){
                            [Void][Cons.WindowDisp]::ShowWindow([Cons.WindowDisp]::GetConsoleWindow(), 1)
                        }Else{
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
        $TabControllerAdvanced.Parent = $TabPageAdvanced
    $TabPageAdvanced.Parent = $TabController
$TabController.Parent = $Form

$Help = [GUI.B]::New(25, 25, 430, 0, '?')
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

$WhatIfCheck = [GUI.ChB]::New(75,27,365,415,'WhatIf?')
$WhatIfCheck.Parent = $Form

$Form.Add_SizeChanged({
    $TabController.Size         = [GUI.SP]::SI((([Int]$This.Width)-65),(([Int]$This.Height)-100))
    $TabControllerAdvanced.Size = [GUI.SP]::SI((([Int]$TabController.Width)-30),(([Int]$TabController.Height)-50))
    
    $PseudoConsole.Size         = [GUI.SP]::SI(($TabController.Width-45),($TabController.Height-235))

    $SingleCMD.Location         = [GUI.SP]::PO(10,($TabController.Height-100))
    $SingleCMD.Size             = [GUI.SP]::SI(($TabController.Width-145),20)
    
    $SingleGO.Location          = [GUI.SP]::PO(($TabController.Width-125),($TabController.Height-100))

    $Help.Location              = [GUI.SP]::PO(($This.Width-40),0)
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
    $RClickMenuArr = (('Cut','Copy','Paste','Select All','Select Line','Delete','Highlight Syntax','Undo','Redo','WhatIf Selection','WhatIf','Goto Top','Goto Bottom','Find/Replace','Run Selection','Run') | %{$Index = 0}{
        $PH = [GUI.B]::New(125,20,0,(20*$Index),$_)
        $PH.Add_Click({Handle-RMenuClick $This})
        $PH.Add_MouseLeave({Handle-RMenuExit $This})
        $PH.FlatStyle = 'Flat'
        $PH.FlatAppearance.BorderSize = 0
        $PH.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $PH.Parent = $RightClickMenu
        $PH
        $Index++
    })
$RightClickMenu.Size = [GUI.SP]::SI(127,(2+($Index*20)))

$RightClickMenu.Visible = $False
$RightClickMenu.BorderStyle = 'FixedSingle'
$RightClickMenu.Add_MouseLeave({Handle-RMenuExit $This})
$RightClickMenu.Parent = $Form

$FindForm = [GUI.P]::New(250,110,(($Form.Width - 250) / 2),(($Form.Height - 90) / 2))
$FindForm.BorderStyle = 'FixedSingle'
$FindForm.Visible = $False
    $FRTitle = [GUI.L]::New(300,18,25,7,'Find and Replace (RegEx):')
    $FRTitle.Parent = $FindForm
    $FLabel = [GUI.L]::New(18,20,6,28,'F:')
    $FLabel.Parent = $FindForm
    $Finder = [GUI.RTB]::New(200,20,25,25,'')
    $Finder.AcceptsTab = $True
    $Finder.Parent = $FindForm
    $RLabel = [GUI.L]::New(18,20,6,53,'R:')
    $RLabel.Parent = $FindForm
    $Replacer = [GUI.RTB]::New(200,20,25,50,'')
    $Replacer.AcceptsTab = $True
    $Replacer.Parent = $FindForm
    $FRGO = [GUI.B]::New(90,25,25,75,'Replace All')
        $FRGO.Add_Click({
            $Commands.Text = ((($Commands.Text.Split($NL) | ?{$_ -ne ''}) | %{
                $_ -replace ($This.Parent.GetChildAtPoint([GUI.SP]::PO(30,30)).Text),($This.Parent.GetChildAtPoint([GUI.SP]::PO(30,55)).Text.Replace('(NEWLINE)',$NL))
            }) -join $NL)
        })
    $FRGO.Parent = $FindForm
    $FRClose = [GUI.B]::New(90,25,135,75,'Close')
        $FRClose.Add_Click({$This.Parent.Visible = $False})
    $FRClose.Parent = $FindForm
$FindForm.Parent = $Form

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
            $Profile.Text = ('Working Profile: ' + $LoadedConfig.PrevProfile)
            $Form.Text = ('Pickle - ' + $LoadedConfig.PrevProfile)
            $SavedProfiles.SelectedIndex = $SavedProfiles.Items.IndexOf($LoadedConfig.PrevProfile)
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

If(!$CommandLine){
    $Config.ShowConsCheck = $ShowCons.Checked
    $Config.OnTopCheck    = $OnTop.Checked

    If($Profile.Text -ne 'Working Profile: None/Prev Text Vals' -AND $Profile.Text){
        $Config.PrevProfile = ($Profile.Text -replace '^Working Profile: ')
    
        $Form.Text = ($Form.Text -replace '\*$')

        $TempDir = ($env:APPDATA+'\Macro\Profiles\'+($Profile.Text -replace '^Working Profile: '))

        [Void](MKDIR $TempDir)

        $Commands.Text | Out-File ($TempDir+'\Commands.txt') -Width 10000 -Force
        $FunctionsBox.Text | Out-File ($TempDir+'\Functions.txt') -Width 10000 -Force

        $SaveAsProfText.Text = ''
    }Else{
        $Config.PrevProfile = $Null
    }

    $Config.LastLoc = ([String]$Form.Location.X + ',' + [String]$Form.Location.Y)
    $Config.SavedSize = ([String]$Form.Size.Width + ',' + [String]$Form.Size.Height)

    Try{
        $Config | ConvertTo-JSON | Out-File ($env:APPDATA+'\Macro\_Config_.json') -Width 1000 -Force
    }Catch{
        $Config | ConvertTo-CSV -NoTypeInformation | Out-File ($env:APPDATA+'\Macro\_Config_.csv') -Width 1000 -Force
    }
}

If($Host.Name -match 'Console'){Exit}
}

If($(Try{[Void][PSObject]::New()}Catch{$True})){
    $MainBlock = ($MainBlock.toString().Split([System.Environment]::NewLine) | %{
        $FlipFlop = $True
    }{
        If($FlipFLop){$_}
        $FlipFlop = !$FlipFlop
    } | %{
        If($_ -match '::New\('){
            (($_.Split('[')[0]+'(New-Object '+$_.Split('[')[-1]+')') -replace ']::New',' -ArgumentList ').Replace(' -ArgumentList ()','')
        }Else{
            $_
        }
    }) -join [System.Environment]::NewLine
}
$MainBlock = [ScriptBlock]::Create($MainBlock)

$MainBlock.Invoke($Macro)
