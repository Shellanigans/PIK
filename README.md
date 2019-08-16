# Macro

The purpose of this program is to simulate keystrokes and mouse input to the Windows operating system.

## Basic Functionality 

Each key is represented by one or more characters. To specify a single keyboard character, use the character itself. For example, to represent the letter A, pass in the string "A" to the commands textbox. To represent more than one character, append each additional character. To represent the letters A, B, and C, specify the parameter as "ABC". In the "commands", "functions", and the "statement" textboxes any spaces or tabs at the beginning of each line will be ignored. In order to actually specify a line that starts with either you must use {TAB} or {SPACE} 

The plus sign (+), caret (^), percent sign (%), tilde (~), and parentheses () have special meanings. To specify one of these characters, enclose it within braces ({}). For example, to specify the plus sign, use "{+}". To specify brace characters, use "{{}" and "{}}". Brackets ([]) have no special meaning, but they still require braces. 

The following are other special keys you can specify:

| Key             | Syntax                       |
|:--------------- | ----------------------------:|
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

**SCROLL LOCK is reserved for cancelling the macros. Simply press and hold until the macro stops on its own.**

To specify keys combined with any combination of the SHIFT, CTRL, and ALT keys, precede the key code with one or more of the following codes:

```
SHIFT (+)
CTRL  (^)
ALT   (%)
```

To specify that any combination of SHIFT, CTRL, and ALT should be held down while several other keys are pressed, enclose the code for those keys in parentheses. For example, to specify to hold down SHIFT while E and C are pressed, use "+(EC)". To specify to hold down SHIFT while E is pressed, followed by C without SHIFT, use "+EC".

To specify repeating keys, use the form {key number}. You must put a space between key and number. For example, {LEFT 42} means press the LEFT ARROW key 42 times; {h 10} means press H 10 times.

### Special Keywords and Mouse Info

You can comment out any line by starting it with "\\\\#" (no quotes). You can also create block comments that are basically just ignored by the program. To start a block comment use "<\\\\#" and to end a block comment use "\\\\#>" (no quotes). Both the block comment tags should be on their own line. You CAN use them on the same line but everything on the block close line will be ignored as though the whole line was commented out. See below:

```
{MOUSE 1,1}
{LMOUSE}
\\# This line does nothing. {WAIT 10}
{WAIT 5}
<\\#
    {SPACE}
    Everything
    between
    these
    lines
    is 
    ignored.
    {RMOUSE}
\\#> (Anything here is also ignored)
TEST
```

In this example the mouse will be moved to the point 1,1 (basically the top-right of the screen). It will then left click and wait five seconds. Finally, it will type out the word TEST. 

Do nothing {WAIT} (Nullifies entire line. I.e. putting {WAIT} anywhere on a line turns that line into a delay with a default value of one second. More time can be specified like the others. So {WAIT 5} is a 5 second delay and {WAIT M 300} is a 300 millisecond delay)

You can also specify that you want to focus on the specified window by using {FOCUS APPLICATION_TITLE} on its own line. (e.g. {FOCUS Untitled - Notepad})

You can specify mouse locations for the cursor by putting {MOUSE 10,10} (The numbers are in pixels with 0,0 being the top left) and clicking with {LMOUSE}, {RMOUSE}, or {MMOUSE}. This will do left, right, and middle click respectively. You must place all mouse functions on independent lines. All mouse clicks can also make use of the {key number} format. (e.g. {LMOUSE 1000} will click the left mouse button 1000 times)

If you need to figure out the X and Y coordinates of your cursor at a specific position, you can click "Get Mouse Inf" button on the "Helper" tab and you will be given 3 seconds to place your cursor where you would like it and when the timer runs out, the "Mouse Coords" box will populate. You may double click the textbox to have the command copied to your clipboard. The "HexVal (ARGB)" box tells you the specific hex color (Alpha Red Green Blue) of the pixel beneath the "action point" of the cursor.

The manual mouse coords allow you to fine tune mouse placement. Simply click in either box and use the up/down arrow keys to fine tune the cursor's position. Use Tab and Shift+Tab to switch between the boxes without using the mouse. Pressing enter in either box will perform the same action as the "Get Mouse Inf" button without the delay, but it will force the mouse to the coords specified if it is not there already.

You may also HOLD certain keys or mouse clicks down using {HOLD KEY} remember to replace "KEY" with the actual key or mouse button you want from the specified keys below. You must specify when to let go using {/HOLD KEY} or {\HOLD KEY}. This will ensure that the key is not continuously held down. As with LOOP, WAIT, FOCUS, and MOUSE functions, the HOLD function requires a dedicated line in the keystrokes. Your possible options for this function are as follows:

|                   |                    |                    |                    |
|:----------------- |:------------------ |:------------------ |:------------------ |
|LMOUSE             | RMOUSE             | MMOUSE             | CANCEL             |
|BACKSPACE          | TAB                | CLEAR              | ENTER              |
|SHIFT              | CTRL               | ALT                | PAUSE              |
|CAPSLOCK           | ESC                | SPACEBAR           | PAGEUP             |
|PAGEDOWN           | END                | HOME               | LEFTARROW          |
|UPARROW            | RIGHTARROW         | DOWNARROW          | SELECT             |
|EXECUTE            | PRINTSCREEN        | INS                | DEL                |
|HELP               | NUMLOCK            | NUM# (0-9)         | NUMMULT            |
|NUMPLUS            | NUMENTER           | NUMMINUS           | NUMPOINT           |
|NUMDIV             | All letters        | All numbers        | F(1-16)            |

### Functions

If you want to get really fancy then you can actually create shorthand for yourself to repeat specific parts multiple times. To do this, create a function by starting a line below that with {FUNCTION NAME THING} like so:

```
{FUNCTION NAME THING}
```

Then type out the keystrokes just like you would in the main window and end it with {FUNCTION END}. This allows you to specify the function in the main window as {THING}. Just make sure to call each function on their own line. You can specify multiple functions and you can even nest them together. A complete example would look like this:

```
{FUNCTION NAME THING1} 
Thing 1{ENTER} 
{FUNCTION END} 

{FUNCTION NAME THING2} 
Thing 2{ENTER} 
{FUNCTION END} 
 
{FUNCTION NAME THING3} 
Thing 3{ENTER} 
{FUNCTION END}
```

The above would allow you to type into the main window the following: 
```
{THING1} 
{THING2} 
{THING3} 
```

Which gets interpreted as: 
```
Thing 1{ENTER} 
Thing 2{ENTER} 
Thing 3{ENTER} 
```

Which would give the output:
```
Thing 1 
Thing 2 
Thing 3 
```

(Without the {ENTER}s they would all be on the same line) 

You can even specify number like with the other functions like so: 

```
{THING 5} 
```

This will call the {THING} function 5 times.

You should be aware that functions DO support recursion (i.e. A function can call upon itself). They can even create a loop or chain of functions (i.e. {FUNCTION1} calls {FUNCTION2} which calls {FUNCTION1}).

### Statements

Like functions, you can create statements which are, at their most basic form, an 'IF/ELSE' statement. They only accept two operands and one comparator. You also must always specify actions for both the true AND false cases; even if they are (NULL). You may begin and name each statement like so:

```
{STATEMENT NAME IF_ELSE_STATEMENT_NAME}
```

Unlike functions, the first 3-4 lines are reserved for the comparison. The first thing you need to specify is if the comparison you are going to check is numeric in nature. If so simply add the line {NUMERIC}.

```
{STATEMENT NAME IF_ELSE_STATEMENT_NAME}
{NUMERIC}
```

The next line should be the first operand you are going to check. Both operands can be a {MANIP} or {VAR VARIABLE_NAME} if you have one set. 

Then follow that with the operator of your choice. Then finish with the second operand. Valid values for the comparator are listed below. A complete top section of a statement would look like so:


```
{STATEMENT NAME IF_ELSE_STATEMENT_NAME}
{NUMERIC}
{OP1 3}
{CMP LT}
{OP2 5}
```

Anything below these lines will be interpreted as the actions to take when the condition above is true. These actions follow the exact same syntax as the main commands textbox. Thus, you should be able to utilize functions or even other statements within them since both statements and functions support recursion (i.e. a statement can call a function and vice versa). After you have your commands placed, on a new line add {ELSE}. This will tell the program that you are done with your true condition actions and have started your false condition actions. Just like before the false condition tells the program what to do when the above comparison is false. When you are done, finish the statement with {STATEMENT END}. Thus your finished statement should look like this:

```
{STATEMENT NAME IF_ELSE_STATEMENT_NAME}
    {NUMERIC}
    {OP1 3}
    {CMP LT}
    {OP2 5}
        This is what to type or the actions or functions or statements to call on true condition
    {ELSE}
        This is what to type or the actions or functions or statements to call on false condition
{STATEMENT END}
```

(Remember: You CAN use leading tabs and spaces in in all the main textboxes)

In this example you could call in the commands box:

```
{IF_ELSE_STATEMENT_NAME}
```

And in our case, the result would be for the program to type out "This is what to type or the actions or functions or statements to call on true condition" because our comparison of "3 LT 5" is true.

Below are the comparators you may use:

|Comparator               |   Syntax|
|:------------------------|--------:|
|MATCH                    |    MATCH|
|EQUALS                   |       EQ|
|LIKE                     |     LIKE|
|LESS THAN                |       LT|
|LESS THAN OR EQUAL TO    |       LE|
|GREATER THAN             |       GT|
|GREATER THAN OR EQUAL TO |       GE|
|NOT MATCH                | NOTMATCH|
|NOT EQUAL                |       NE|
|NOT LIKE                 |  NOTLIKE|

## GUI Explanations

There are four main tabs. The Commands, the Functions, the Statements, and the Advanced tabs. The first three are pretty self-explanatory. The fourth tab, Advanced, has some niceties.

### Commands, Functions, and Statements

These are pretty well covered elsewhere, but in a GUI sense, they all have some nifty shortcuts. Just click anywhere in any of the three main text boxes and press any of the following keys:

|Key |Action                                                                                       |
|:---|:--------------------------------------------------------------------------------------------|
|F1  |Insert <\\\\# block comment start                                                            |
|F2  |Insert \\\\#> block comment end                                                              |
|F3  |Insert \\\\# line comment                                                                    |
|F4  |Insert page-dependent code; Commands=:::Label, Functions=NewFunction, Statements=NewStatement|
|F5  |Insert {MOUSE X,Y} where the X and Y coords are of the mouse's current position              |
|F6  |Insert {WAIT M 100}                                                                          |
|F11 |Save; only works if a profile is currently loaded                                            |
|F12 |Run; same as clicking the "Start" button                                                     |

### Load/Save

The first sub-panel, Load/Save, allows you to save current whatever you have in the main three tabs as a profile. This way you can switch between several macros at ease. To create a new one. Simply type a name into the "Save Current Profile As" box and click "SAVE AS". You can see which profiles have been saved via the drop down menu underneath "Saved Profiles". You are also able to save over any profiles of the same name.

Whatever you save the profile as will become the currently loaded profile and will display in the title bar and just after "Working Profile". If you have a profile loaded and you make some changes, you will see an asterisk on the title bar after the loaded profile's name. This is to let you know you haven't saved. To save to an already loaded profile simply click "SAVE" or press F11 with the cursor in any of the main three textboxes.

You may delete a profile by typing out the name as it appears in the drop down menu and clicking "DELETE".

The "BLANK" button, unloads any profiles already loaded, WITHOUT SAVING, and blanks out the main text boxes.

### Settings

There are four major settings in the settings tab. The "Keystroke" and "Command" delays and the "Show Console" and "Always On Top" settings.

The delays are simple. The keystroke delay is the number of milliseconds you would like to get between the actual key presses. The command delay is the amount of time in milliseconds that you want the program to wait between each line. Remember that functions are more like aliases in this regard so a function will have delays between its own lines as well.

Please note that delays are less accurate the smaller they are.

The random checkboxes near the delays are if you would like to add some "noise" to the delays. This can help with bot detection, though detection is still very possible. The weight category beneath is how many milliseconds to use for the noise. (e.g. A delay of 40 milliseconds with the random box checked and a weight of 5 will have a delay ranging from 35 to 45 milliseconds per delay)

"Show Console" is for debugging pruposes. It makes the main console window visible. This will allow you to see what the program is interpretting each line as. This is very useful for debugging as well. (See Debug/Helper below)

The "Always On Top" checkbox is to allow the program to always sit on top of everything on screen regardless of what has focus.

Please note that any other programs that are also always on top need to be open first if you want this program on top. Windows gives the last window to open priority when determining the order of multiple windows with this flag set.

### Debug/Helper

The Debug tab is to help you troubleshoot and fine tune your macros.

The buttons from the top down to and including clear console require the console to be on. (See Settings above)

When a program is run the "memory" of the last run is cleared and all functions and statements are redefined and the variables are set as they are parsed in each run through. However, they still exist AFTER each run and you are able to view what the program has with some of the buttons on this tab.

"Get Functs" will display in the console what functions were defined and what their values are.
"Get States" will display in the console what statements were defined and what their values are.
"Get Vars" will display in the console what variables were defined and what their values are.

"Clear Vars" will erase all variables in the program memory. Though this shouldn't be needed before each run. You can achieve the same effect by putting {CLEARVARS} at the end of your macro.

"Clear Console" will clear the console host. This is essentially just "clear screen" or "cls" and is purely visual.

The last buttons are for the program itself.

"Open Data Folder" will open the folder where this program resides for your convenience.

"About/Help" will open Notepad with this help file.

## Advanced Functionality

There are some pretty cool things you can do in a programmatic sense. This program allows you to create and store variables as well as manipulate data.

When it comes to storing/getting variables, both are enclosed within braces. To GET, simply call the variable name with {VAR variable_name} and to SET variables, simply include an equals sign (=) without spaces to set a variable to the value after the space and not including the end brace. (i.e. {VAR variable_name=test} will create and store the variable 'variable_name' and set the value to the string 'test')

Every value will always be stored as a string, but numeric comparisons with strings are possible. (See below)

When you call a variable, remember that the {VAR var_name} will be interpreted as the value it represents in keystrokes (unless nested within something else, like another {VAR}). Thus, if you had focus of notepad and a variable named 'test' with the value 'abcd', then in the commands window you were to call {VAR test}, the command would be interpreted as the keystrokes 'abcd'.

You can clear any variables that have been set while running with the command {CLEARVARS}. This will clear the "memory" so to speak while the program is running. It doesn't matter between runs as the memory is reset on each run, but sometimes it may be useful to know that all previous values are cleared. It will only happen when that line is hit as this program runs top to bottom so if the line is never hit, then those values will remain. Think of this like a garbage cleanup, though the memory management is terrible.

You may also clear just a single variable with {CLEARVAR var_name}. This will completely remove the variable.

You can also FIND variables. The command is {FINDVAR some_regex}. This will return a comma separated string of all the variable names that match that regex.

There are too many commands to mention in paragraph form and some commands are simply for your convenience. Below is a table of the actions you may perform that may help you:

|Command                         |Action                                                                                      |
|:-------------------------------|:-------------------------------------------------------------------------------------------|
|{CLEARVARS}*                    |Deletes all variables in memory while running.                                              |
|{CLEARVAR var_name}*            |Delete the variable var_name from memory. Useful for verifying a var has been cleared.      |
|{FINDVAR regex}                 |Returns comma separated string of all vars matching the regex.                              |
|{SETCON(A) data,path}*          |Sets content of "path" to "data". The "A" is optional and specifies appending.              |
|{GETCON file_path}              |The line is converted to the contents of a file. Useful for long term variable storage.     |
|{GETPIX x,y}                    |Returns pixel color on screen in hex ARGB from the coords x,y.                              |
|{GETCLIP}                       |Returns the data on the clipboard.                                                          |
|{SETCLIP data}*                 |Sets the clipboard to the data specified.                                                   |
|{RAND x,y}                      |Returns a random number from x to (y - 1)                                                   |
|{DATETIME}*                     |Returns the time and date. Useful for logging or time stamping.                             |
|{COPY}                          |An alias for ^C (Ctrl+C).                                                                   |
|{PASTE}                         |An alias for ^V (Ctrl+V).                                                                   |
|{SELECTALL}                     |An alias for ^A (Ctrl+A).                                                                   |
|{SCRNSHT tlx,tly,brx,bry,path}* |Saves a screenshot from top-left pixel tlx,tly to bottom-right pixel brx,bry to path (.bmp) |
|{RESTART}*                      |Essentially a GOTO top. Useful for restarting automatically.                                |
|{KILL}*                         |Stop running. Essentially the same as pressing SCROLL LOCK.                                 |
|{REFOCUS}*                      |Tells the program to focus on itself after. This is a flag and can be set anywhere.         |
|{GOTO label_name}*              |Go to the first label defined in the commands tab by ":::label_name" and continue           |

\*This command needs to be on its own line.

### Variable Manipulation

When it comes to data manipulation, you can make use of the MANIP operator. Every MANIP must be formatted like so:

```
{MANIP OPT ARG1,ARG2}
```

Where OPT is one of the possible operations to perform (See below) and the ARG1 and ARG2 are the arguments. All MANIPS must have at least two ARGS even if one needs to be (NULL). Some operations can even take three arguments. See the chart below for example usage. Spacing and commas are reserved for MANIPS, so if you need to specify those, newline, or null values use (COMMA),  (SPACE), (NEWLINE), and (NULL).

|Operation |No. Args             |Syntax                      |Action                                                   |
|:---------|:--------------------|:---------------------------|:--------------------------------------------------------|
|ADD       |2                    |{MANIP ADD ARG1,ARG2}       | Adds ARG2 to ARG1                                       |
|SUB       |2                    |{MANIP SUB ARG1,ARG2}       | Subtracts ARG2 from ARG1                                |
|MUL       |2                    |{MANIP MUL ARG1,ARG2}       | Multiplies ARG1 and ARG2                                |
|DIV       |2                    |{MANIP DIV ARG1,ARG2}       | Divides ARG1 by ARG2                                    |
|POW       |2                    |{MANIP POW ARG1,ARG2}       | Takes ARG1 to the power of ARG2                         |
|MOD       |2                    |{MANIP MOD ARG1,ARG2}       | Modularly divides ARG1 by ARG2                          |
|APP       |2                    |{MANIP APP ARG1,ARG2}       | Appends the string value ARG2 to ARG1                   |
|TRS       |2                    |{MANIP TRS ARG1,ARG2}       | Trims the chars in ARG2 from the start of ARG1          |
|TRE       |2                    |{MANIP TRE ARG1,ARG2}       | Trims the chars in ARG2 from the end of ARG1            |
|SPL       |2                    |{MANIP SPL ARG1,ARG2}*      | Splits the **VARIABLE NAMED** ARG1 on the chars in ARG2 |
|JOI       |2                    |{MANIP JOI ARG1,ARG2}       | Joins the **ARRAY NAMED** ARG1 with the string ARG2     |
|TCA       |1                    |{MANIP TCA ARG1,(NULL)}*    | Converts the **VARIABLE NAMED** ARG1 to a char array    |
|REV       |1                    |{MANIP REV ARG1,(NULL)}*    | Reverses the order of the **ARRAY NAMED** ARG1          |
|ABS       |1                    |{MANIP ABS ARG1,(NULL)}     | Returns the absolute value of ARG1                      |
|SIN       |1                    |{MANIP SIN ARG1,(NULL)}     | Returns the SIN of ARG1                                 |
|COS       |1                    |{MANIP COS ARG1,(NULL)}     | Returns the COS of ARG1                                 |
|TAN       |1                    |{MANIP TAN ARG1,(NULL)}     | Returns the TAN of ARG1                                 |
|FLR       |1                    |{MANIP FLR ARG1,(NULL)}     | Returns the floor of ARG1                               |
|CEI       |1                    |{MANIP CEI ARG1,(NULL)}     | Returns the ceiling of ARG1                             |
|LEN       |1                    |{MANIP LEN ARG1,(NULL)}     | Returns the length of the **VARIABLE NAMED** ARG1       |
|CNT       |1                    |{MANIP CNT ARG1,(NULL)}     | Returns the count of the **ARRAY NAMED** ARG1           |
|RPL       |3                    |{MANIP RPL ARG1,ARG2,ARG3}  | Returns ARG1 after replacing the regex of ARG2 with ARG3|

\*This MANIP command doesn't actually return anything, it only performs the action described.

Note: When a variable has been split into an array of any kind, the index goes in the front of the variable name followed by an underscore. (i.e. The first variable in an array {VAR TEST} would be {VAR 0_TEST})

MANIPS that have an output can be set to a variable through nesting like so:

```
{VAR TEST={MANIP ADD 3,4}}
```

Which would set the value of 7 to the variable TEST. You may also call variables within the ARG portions, just be aware that some MANIPS require the actual variable NAME istelf and NOT the {VAR variable_name} syntax. This would look for a variable with the name of the VALUE contained WITHIN 'variable_name'. Below is an example:

In this example of MANIPS referencing variables, say we have a variable named 'TEST' that contains the string 'split me' In order to split this string on the space we would do the following:

```
{MANIP SPL TEST,(SPACE)}
```

This will create the variables '0_TEST' which contains the value 'split' and '1_TEST' which contains 'me'. Note how we referenced the variable by name but did NOT use the normal syntax of {VAR TEST}.

For other MANIPS like add, we would use the normal {VAR} syntax. In this way if 'TEST' had a value of 5 and we wanted to add one to it we could do the following:

```
{VAR TEST={MANIP ADD {VAR TEST},1}}
```

This will get interpreted as:

```
{VAR TEST={MANIP ADD 5,1}}
```

Then as:

```
{VAR TEST=6}
```

Which will set the value of 6 to TEST.
