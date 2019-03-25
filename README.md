# Macro

The purpose of this program is to simulate keystrokes and mouse input to the windows operating system.

## Basic Functionality 

Each key is represented by one or more characters. To specify a single keyboard character, use the character itself. For example, to represent the letter A, pass in the string "A" to the method. To represent more than one character, append each additional character to the one preceding it. To represent the letters A, B, and C, specify the parameter as "ABC". In both the "commands" and the "functions" textboxes any spaces or tabs at the beginning of each line will be ignored. In order to actually specify a line that starts with either you must use {TAB} or {SPACE} 

The plus sign (+), caret (^), percent sign (%), tilde (~), and parentheses () have special meanings. To specify one of these characters, enclose it within braces ({}). For example, to specify the plus sign, use "{+}". To specify brace characters, use "{{}" and "{}}". Brackets ([ ]) have no special meaning to SendKeys, but you must enclose them in braces. 

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

## Special Keywords

Do nothing {WAIT} (Nullifies entire line. I.e. putting {WAIT} anywhere on a line turns that line into a delay with a default value of one second. More time can be specified like the others. So {WAIT 5} is a 5 second delay and {WAIT M 300} is a 300 millisecond delay)

You can also specify that you want to focus on the specified window by using {FOCUS APPLICATION TITLE} on its own line. (e.g. {FOCUS Untitled - Notepad})

You can specify mouse locations for the cursor by putting {MOUSE 10,10} (The numbers are in pixels with 0,0 being the top left) and clicking with {LMOUSE}, {RMOUSE}, or {MMOUSE}. This will do left, right, and middle click respectively. You must place all mouse functions on independent lines.

If you need to figure out the X and Y coordinates of your cursor at a specific position, you can click "Mouse X,Y" and you will be given 3 seconds to place your cursor where you would like it and the command to place the mouse at the specified coords will be copied to your clipboard for you to simply paste into the main window. It will also be appended to the end of the commands textbox.

You may also specify to HOLD certain keys or mouse clicks down using {HOLD KEY} remember to replace "KEY" with the actual key or mouse button you want from the specified keys below. You must specify when to let go using {/HOLD KEY} or {\HOLD KEY}. This will ensure that the key is not continuously held down. As with LOOP, WAIT, FOCUS, and MOUSE functions, the HOLD function requires a dedicated line in the keystrokes. Your possible options for this function are as follows:

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

## Advanced Functionality

There are some pretty cool things you can do in a programmatic sense. This program allows you to create and store variables, as well as, manipulate data.

When it comes to storing/getting variables, both are enclosed within braces. To GET, simply call the variable name with {VAR variable_name} and to SET variables, simply include an equals sign (=) without spaces to set a variable to the value after the space and not including the end brace. (i.e. {VAR variable_name=test} will create and store the variable 'variable_name' and set the value to the string 'test')

Every value will always be stored as a string, but comparisons with strings interpreted as numbers is possible. (See below)

When you call a variable, remember that the {VAR var_name} will be interpreted as the value it represents in keystrokes (unless nested within something else, like another {VAR}). Thus, if you had focus of notepad and a variable named 'test' with the value 'abcd', then in the commands window you were to call {VAR test}, the command would be interpreted as the keystrokes 'abcd'.

When it comes to data manipulation, you can make use of the MANIP operator. Every MANIP must be formmatted like so:

```
{MANIP OPT ARG1,ARG2}
```

Where OPT is one of the possible operations to perform (See below) and the ARG1 and ARG2 are the arguments. All MANIPS must have at least two ARGS even if one needs to be (NULL). Some operations can even take three arguments. See the chart below for example usage.

|Operation |Num of Args         |                    Syntax| Action|
|:---------|:-------------------|--------------------------|:------|
|ADD       |2                   |     {MANIP ADD ARG1,ARG2}| Adds ARG2 to ARG1|
|SUB       |2                   |     {MANIP SUB ARG1,ARG2}| Subtracts ARG2 from ARG1|
|MUL       |2                   |     {MANIP MUL ARG1,ARG2}| Multiplies ARG1 and ARG2|
|DIV       |2                   |     {MANIP DIV ARG1,ARG2}| Divides ARG1 by ARG2|
|POW       |2                   |     {MANIP POW ARG1,ARG2}| Takes ARG1 to the power of ARG2|
|MOD       |2                   |     {MANIP MOD ARG1,ARG2}| Modularly divides ARG1 by ARG2|
|APP       |2                   |     {MANIP APP ARG1,ARG2}| Appends the string value of ARG2 to ARG1|
|TRS       |2                   |     {MANIP TRS ARG1,ARG2}| Trims the chars in ARG2 from the start of ARG1|
|TRE       |2                   |     {MANIP TRE ARG1,ARG2}| Trims the chars in ARG2 from the end of ARG1|
|SPL       |2                   |     {MANIP SPL ARG1,ARG2}| Splits the **VARIABLE NAMED** ARG1 on the chars in ARG2|
|JOI       |2                   |     {MANIP JOI ARG1,ARG2}| Joins the **ARRAY NAMED** ARG1 with the string ARG2|
|TCA       |1                   |   {MANIP TCA ARG1,(NULL)}| Converts the **VARIABLE NAMED** ARG1 to a char array|
|REV       |1                   |   {MANIP REV ARG1,(NULL)}| Reverses the order of the **ARRAY NAMED** ARG1|
|SIN       |1                   |   {MANIP SIN ARG1,(NULL)}| Returns the SIN of ARG1|
|COS       |1                   |   {MANIP COS ARG1,(NULL)}| Returns the COS of ARG1|
|TAN       |1                   |   {MANIP TAN ARG1,(NULL)}| Returns the TAN of ARG1|
|FLR       |1                   |   {MANIP FLR ARG1,(NULL)}| Returns the floor of ARG1|
|CEI       |1                   |   {MANIP CEI ARG1,(NULL)}| Returns the ceiling of ARG1|
|LEN       |1                   |   {MANIP LEN ARG1,(NULL)}| Returns the length of the **VARIABLE NAMED** ARG1|
|CNT       |1                   |   {MANIP CNT ARG1,(NULL)}| Returns the count of the **ARRAY NAMED** ARG1|
|RPL       |3                   |{MANIP RPL ARG1,ARG2,ARG3}| Returns ARG1 after replacing the regex of ARG2 with ARG3|

## Functions

If you want to get really fancy then you can actually create shorthand for yourself to repeate specific parts multiple times. In the "Functions" textbox add a line {FUNCTIONS}. Then create a functions by starting a line below that with {FUNCTION NAME THING} like so:

```
{FUNCTIONS}
{FUNCTION NAME THING}
```

Then type out the keystrokes just like you would in the main window and end it with {FUNCTION END}. This allows you to specify the function in the main window as {THING}. Just make sure to call each function on their own line. You can specify multiple functions and you can even nest them together. To stop declaring funtions (this is required) add the line {FUNCTIONS END}. A complete example would look like this:

```
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
{FUNCTIONS END} 
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

## Statements

Like functions, you can create statements which are, at their most basic form, an 'IF/ELSE' statement. They only accept two operands and one comparator. You also must always specify actions for both the true AND false cases; even if they are (NULL).

Just like functions, you must begin all the statements with the line {STATEMENTS}. After this you may begin and name each statement like so:

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

And when enclosed by the {STATEMENTS} blocks, a complete statements section would look like:

```
{STATEMENTS}
    {STATEMENT NAME IF_ELSE_STATEMENT_NAME}
        {NUMERIC}
        {OP1 3}
        {CMP LT}
        {OP2 5}
            This is what to type or the actions or functions or statements to call on true condition
        {ELSE}
            This is what to type or the actions or functions or statements to call on false condition
        {STATEMENT END}
{STATEMENTS END}
```

(Remember: You CAN use leading tabs and spaces in both the commands textbox and the functions textbox)

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

**DO NOT NEST THE STATEMENTS BLOCK WITHIN THE FUNCTIONS BLOCK OR VICE VERSA!!! IN THE FUNCTIONS TEXTBOX BOTH THE STATEMENTS AND FUNCTIONS BLOCKS SHOULD BE SEPARATE AND THERE SHOULD ONLY BE ONE OF EACH IN SAID BOX**

**YES**
```
{STATEMENTS}
    ...
{STATEMENTS END}

{FUNCTIONS}
    ...
{FUNCTIONS END}
```

**NO**
```
{STATEMENTS}
    ...

{FUNCTIONS}
    ...
{FUNCTIONS END}

    ...
{STATEMENTS END}
```
