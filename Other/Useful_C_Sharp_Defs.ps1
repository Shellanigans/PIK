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
        [return: MarshalAs(UnmanagedType.Bool)]
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
        public F (){}
        public F (int sx, int sy, string tx){this.Size = new DR.Size(sx,sy);this.Text = tx;}
    }
    public class TC : SWF.TabControl{
        public TC (){}
        public TC (int sx, int sy, int lx, int ly){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class TP : SWF.TabPage{
        public TP (){}
        public TP (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class L : SWF.Label{
        public L (){}
        public L (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class TB : SWF.TextBox{
        public TB (){}
        public TB (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class RTB : SWF.RichTextBox{
        public RTB (){}
        public RTB (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class MTB : SWF.MaskedTextBox{
        public MTB (){}
        public MTB (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class B : SWF.Button{
        public B (){}
        public B (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class RB : SWF.RadioButton{
        public RB (){}
        public RB (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class ChB : SWF.CheckBox{
        public ChB (){}
        public ChB (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    
    public class CB : SWF.ComboBox{
        public CB (){}
        public CB (int sx, int sy, int lx, int ly){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class P : SWF.Panel{
        public P (){}
        public P (int sx, int sy, int lx, int ly){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class LB : SWF.ListBox{
        public LB (){}
        public LB (int sx, int sy, int lx, int ly){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class CoB : SWF.ComboBox{
        public CoB (){}
        public CoB (int sx, int sy, int lx, int ly){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class NUD : SWF.NumericUpDown{
        public NUD (){}
        public NUD (int sx, int sy, int lx, int ly){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);}
    }
    public class GB : SWF.GroupBox{
        public GB (){}
        public GB (int sx, int sy, int lx, int ly, string tx){this.Size = new DR.Size(sx,sy);this.Location = new DR.Point(lx,ly);this.Text = tx;}
    }
    public class Rect{
        public static DR.Rectangle E = DR.Rectangle.Empty;
        public static DR.Rectangle R (int lx, int ly, int sx, int sy){
            return (new DR.Rectangle(lx, ly, sx, sy));
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
