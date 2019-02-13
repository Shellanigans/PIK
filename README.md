# Macro

The purpose of this program is to simulate keystrokes and mouse input to the windows operating system.

Each key is represented by one or more characters. To specify a single keyboard character, use the character itself. For example, to represent the letter A, pass in the string "A" to the method. To represent more than one character, append each additional character to the one preceding it. To represent the letters A, B, and C, specify the parameter as "ABC".

The plus sign (+), caret (^), percent sign (%), tilde (~), and parentheses () have special meanings. To specify one of these characters, enclose it within braces ({}). For example, to specify the plus sign, use "{+}". To specify brace characters, use "{{}" and "{}}". Brackets ([ ]) have no special meaning to SendKeys, but you must enclose them in braces. 

The following are other special keys you can specify:

| Key             | Syntax                       |
| --------------- | ----------------------------:|
| BACKSPACE       | {BACKSPACE}, {BS}, or {BKSP} |
| BREAK           | {BREAK}                      |
| CAPS LOCK       | {CAPSLOCK}                   |
| DEL or DELETE   | {DELETE} or {DEL}            |
| END             | {END}                        |
| ENTER           | {ENTER} or ~                 |
| ESC             | {ESC}                        |
| HELP            | {HELP}                       |
| HOME            | {HOME}                       |
| INS or INSERT   | {INSERT} or {INS}            |
| PAGE DOWN       | {PGDN}                       |
| PAGE UP         | {PGUP}                       |
| NUM LOCK        | {NUMLOCK}                    |
| TAB             | {TAB}                        |
| UP ARROW        | {UP}                         |
| DOWN ARROW      | {DOWN}                       |
| RIGHT ARROW     | {RIGHT}                      |
| LEFT ARROW      | {LEFT}                       |
| F#              | {F#} (Can be from 1 - 16)    |
| Keypad add      | {ADD}                        |
| Keypad subtract | {SUBTRACT}                   |
| Keypad multiply | {MULTIPLY}                   |
| Keypad divide   | {DIVIDE}                     |

SCROLL LOCK is reserved for cancelling the macros. Simply press and hold until the macro stops on its own.

To specify keys combined with any combination of the SHIFT, CTRL, and ALT keys, precede the key code with one or more of the following codes.

SHIFT (+)
CTRL  (^)
ALT   (%)

To specify that any combination of SHIFT, CTRL, and ALT should be held down while several other keys are pressed, enclose the code for those keys in parentheses. For example, to specify to hold down SHIFT while E and C are pressed, use "+(EC)". To specify to hold down SHIFT while E is pressed, followed by C without SHIFT, use "+EC".

To specify repeating keys, use the form {key number}. You must put a space between key and number. For example, {LEFT 42} means press the LEFT ARROW key 42 times; {h 10} means press H 10 times.

Do nothing {WAIT} (Nullifies entire line. I.e. putting {WAIT} anywhere on a line turns that line into a delay with a default value of one second. More time can be specified like the others. So {WAIT 5} is a 5 second delay and {WAIT M 300} is a 300 millisecond delay)

You can also specify that you want to focus on the specified window by using {FOCUS APPLICATION TITLE} on its own line. (e.g. {FOCUS Untitled - Notepad})

You can specify mouse locations for the cursor by putting {MOUSE 10,10} (The numbers are in pixels with 0,0 being the top left) and clicking with {LMOUSE}, {RMOUSE}, or {MMOUSE}. This will do left, right, and middle click respectively. You must place all mouse functions on independent lines.

If you need to figure out the X and Y coordinates of your cursor at a specific position, you can click "Get Mouse X,Y" and you will be given 3 seconds to place your cursor where you would like it and you will get a notification of the coordinates of your cursor at that position. The command to place the mouse at the specified coords will be copied to your clipboard for you to simply paste into the main window.

You may also specify to HOLD certain keys or mouse clicks down using {HOLD KEY} remember to replace "KEY" with the actual key or mouse button you want from the specified keys below. You must specify when to let go using {/HOLD KEY} or {\HOLD KEY}. This will ensure that the key is not continuously held down. As with LOOP, WAIT, FOCUS, and MOUSE functions, the HOLD function requires a dedicated line in the keystrokes. Your possible options for this function are as follows:

LMOUSE             RMOUSE             MMOUSE             CANCEL
BACKSPACE          TAB                CLEAR              ENTER
SHIFT              CTRL               ALT                PAUSE
CAPSLOCK           ESC                SPACEBAR           PAGEUP
PAGEDOWN           END                HOME               LEFTARROW
UPARROW            RIGHTARROW         DOWNARROW          SELECT
EXECUTE            PRINTSCREEN        INS                DEL
HELP               NUMLOCK            NUM# (0-9)         NUMMULT
NUMPLUS            NUMENTER           NUMMINUS           NUMPOINT
NUMDIV             All letters        All numbers        F(1-16)

You can loop the entire thing by checking the "Loop" checkbox. Then specifying the number of time you want the program to run through completely. (The default is 10)

If you want to get really fancy then you can actually create shorthand for yourself to repeate specific parts multiple times. In the "Notes" window add a line {FUNCTIONS} below all of your notes. Then create a functions by starting a line below that with {FUNCTION NAME THING} like so:

{FUNCTIONS}
{FUNCTION NAME THING}

Then type out the keystrokes just like you would in the main window and end it with {FUNCTION END}. This allows you to specify the function in the main window as {THING}. Just make sure to call each function on their own line. You can specify multiple functions and you can even nest them together. A complete example would look like this:

{FUNCTIONS}
{FUNCTION NAME THING1}
Thing 1{ENTER}
{FUNCTION END}

{FUNCTION NAME THING2}
Thing 2{ENTER}
{FUNCTION END}

{FUNCTION NAME THING3}
Thing 3{ENTER}
{FUNCTION END}

The above would allow you to type into the main window the following:

{THING1}
{THING2}
{THING3}

Which gets interpreted as:

Thing 1{ENTER}
Thing 2{ENTER}
Thing 3{ENTER}

Which would give the output:

Thing 1
Thing 2
Thing 3

(Without the {ENTER}s they would all be on the same line)

You can even specify number like with the other functions like so:

{THING 5}

FINAL NOTE: It is probably NOT a good idea to use the macro to enter data into the notes. This causes some stability issues.
