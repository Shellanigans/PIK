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

//::new() doesn't exist in POSH versions below 3, but we want to cover as many versions of powershell as possible.
//This makes it so we can use [N.e]::w([Type],@(args)) instead of New-Object (POSH v2) which is very slow.
//We COULD just use [System.Activator]::CreatInstance([Type],@(args)), but this gets long and wordy quickly.
namespace N{
    public class e{
        public static Object w (Type type, params Object[] args){
            return System.Activator.CreateInstance(type, args);
        }
    }
}

//This is just a bunch of wrapper classes that allow for shorter, easier instantiation of GUI objects.
//This also adds a bunch of constructor types that allow you to specify location, size, and text in one go.
namespace GUI{
    public class Style{
        public static void Enable (){
            SWF.Application.EnableVisualStyles();
        }
    }

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

    public class Window{
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

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
        public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
        public static extern IntPtr PostMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

        public static void Act (string AppTitle){
            Microsoft.VisualBasic.Interaction.AppActivate(AppTitle);
        }
    }

    public class Clip{
        public static string GetTxt ()           {return SWF.Clipboard.GetText();}
        public static void SetTxt (string Text)  {SWF.Clipboard.SetText(Text);}
    }

    public class Cursor{
        public static DR.Point GetPos ()         {return SWF.Cursor.Position;}
        public static void SetPos (int x, int y) {SWF.Cursor.Position = new DR.Point(x, y);}
    }

    public class Events{
        [DllImport("user32.dll")]
        public static extern void mouse_event(Int64 dwFlags, Int64 dx, Int64 dy, Int64 cButtons, Int64 dwExtraInfo);

        [DllImport("user32.dll")]
        public static extern void keybd_event(Byte bVk, Byte bScan, Int64 dwFlags, Int64 dwExtraInfo);
    }

    public class Send{
    	public static void SetConfig ()        {
            System.Configuration.ConfigurationManager.AppSettings.Set("SendKeys","SendInput");
        }

	    public static string Check ()          {
            return System.Configuration.ConfigurationManager.AppSettings["SendKeys"].ToString();
        }
        
        public static void Keys (string Keys)  {
            if(Regex.IsMatch(Keys, "WINDOWS ")){
                string WinKeys = Keys.Replace("{","").Replace("WINDOWS","").Replace("}","").Replace(" ","");
                
                int WinKeyCount = 1;
                if(Regex.IsMatch(WinKeys, "\\d")){
                    WinKeyCount = Convert.ToInt32(Regex.Replace(WinKeys, "\\D", ""));
                }
                
                if(Regex.IsMatch(WinKeys, "R")){
                    GUI.Events.keybd_event(0x5C, 0, 0x02, 0);
                    System.Threading.Thread.Sleep(40);
                    GUI.Events.keybd_event(0x5C, 0, 0, 0);
                }else{
                    GUI.Events.keybd_event(0x5B, 0, 0x02, 0);
                    System.Threading.Thread.Sleep(40);
                    GUI.Events.keybd_event(0x5B, 0, 0, 0);
                }
            }else{
                SWF.SendKeys.SendWait(Keys);
            }
        }
    }

    public class FindImg{
        public static System.Collections.Generic.List<DR.Point> GetSubPositions(DR.Bitmap main, DR.Bitmap sub) {
            System.Collections.Generic.List<DR.Point> possiblepos = new System.Collections.Generic.List<DR.Point>();
            
            int mainwidth = main.Width;
            int mainheight = main.Height;
            int subwidth = sub.Width;
            int subheight = sub.Height;
            int movewidth = mainwidth - subwidth;
            int moveheight = mainheight - subheight;
            
            DR.Imaging.BitmapData bmMainData = main.LockBits(
                new DR.Rectangle(0, 0, mainwidth, mainheight),
                DR.Imaging.ImageLockMode.ReadWrite,
                DR.Imaging.PixelFormat.Format32bppArgb
            );

            DR.Imaging.BitmapData bmSubData = sub.LockBits(
                new DR.Rectangle(0, 0, subwidth, subheight),
                DR.Imaging.ImageLockMode.ReadWrite,
                DR.Imaging.PixelFormat.Format32bppArgb
            );
            
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

namespace Cons{
    public class Wind{
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
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

        public static void Write (string Line){
            System.Console.Write(Line);
        }
    }
}

public class Parse{
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

    public static string KeyWord(string X){
        if(Regex.IsMatch(X.ToUpper(), "{[CPSDGRMW]")){
            if(Regex.IsMatch(X, "{COPY}|{PASTE}|{SELECTALL}")){
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
            if(Regex.IsMatch(X, "{DATETIME|{RAND |{SPACE ?")){
                X = (X.Replace("{DATETIME}",DateTime.Now.ToString()));
		        X = (X.Replace("{DATETIMEUTC}",DateTime.Now.ToFileTimeUtc().ToString()));

                while(Regex.IsMatch(X, "{SPACE ?")){
                    foreach(string SubString in X.Split("{}".ToCharArray())){
                        if(Regex.IsMatch(SubString, "SPACE")){
                            X = X.Replace(
                                ("{"+SubString+"}"),
                                (new string (' ', Convert.ToInt32(Regex.Replace(SubString, "^SPACE$", "SPACE 1").Split(' ')[1])))
                            );
                            System.Console.WriteLine(X);
                        }
                    }
                }

                while(Regex.IsMatch(X, "{RAND ")){
                    foreach(string SubString in X.Split("{}".ToCharArray())){
                        if(Regex.IsMatch(SubString, "RAND ") && Regex.IsMatch(SubString, ",")){
                            X = X.Replace(
                                ("{"+SubString+"}"),
                                (Convert.ToString((new Random()).Next(Convert.ToInt32(SubString.Split(' ')[1].Split(',')[0]),
                                Convert.ToInt32(SubString.Split(' ')[1].Split(',')[1]))))
                            );
                            System.Console.WriteLine(X);
                        }
                    }
                }
            }

            if(Regex.IsMatch(X, "{GETCLIP}|{GETMOUSE}")){
                if(Regex.IsMatch(X, "{GETCLIP}")){X = X.Replace("{GETCLIP}",(GUI.Clip.GetTxt()));}
                if(Regex.IsMatch(X, "{GETMOUSE}")){
                    DR.Point Coords = GUI.Cursor.GetPos();
                    X = X.Replace("{GETMOUSE}",(Coords.X.ToString()+","+Coords.Y.ToString()));
                }
            }
        }
        return X;
    }
}
