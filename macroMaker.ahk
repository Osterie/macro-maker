; [^ = Ctrl] [+ = Shift] [! = Alt] [# = Win] is this correct?

; --------General whatever---------
; #Persistent
; #InstallKeybdHook ; only responds to keyboard inputs


; --------Global variables---------

GUIshowKeysPressedAndDuration := "KeysGUI" ;. IH_Count (? what does this do blah.... https://jacks-autohotkey-blog.com/2017/10/13/create-multiple-gui-pop-ups-in-a-single-script-autohotkey-scripting/#:~:text=The%20secret%20to%20building%20multiple,not%20modifying%20an%20existing%20one.%E2%80%9D)
GUIKeysTextEditor := "EditorGUI" ;. IH_Count (...)

KeysPressed := "hei"
KeysPressedDurations := "hei"

Gui, %GUIshowKeysPressedAndDuration%: new ; Create a new GUI
Gui, %GUIshowKeysPressedAndDuration%: -Caption +AlwaysOnTop +Owner +LastFound 
WinSet, TransColor, EEAA99
Gui, %GUIshowKeysPressedAndDuration%: Color, EEAA99
Gui, %GUIshowKeysPressedAndDuration%: Font, s20 w70 q4, Times New Roman
Gui, %GUIshowKeysPressedAndDuration%: add, Text, w890 vKeysPressedText, %KeysPressed%
Gui, %GUIshowKeysPressedAndDuration%: add, Text, w890 vKeysPressedDurationsText, %KeysPressedDurations%
Gui, %GUIshowKeysPressedAndDuration%: Show

; Create the sub-menus for the menu bar:
Menu, FileMenu, Add, &New, FileNew
Menu, FileMenu, Add, &Open, FileOpen
Menu, FileMenu, Add, &Save, FileSave
Menu, FileMenu, Add, Save &As, FileSaveAs
Menu, FileMenu, Add  ; Separator line.
Menu, FileMenu, Add, E&xit, FileExit
Menu, HelpMenu, Add, &About, HelpAbout

; Create the menu bar by attaching the sub-menus to it:
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu

; Attach the menu bar to the window:
Gui, %GUIKeysTextEditor%: new ; Create a new GUI
Gui, %GUIKeysTextEditor%: Menu, MyMenuBar


Gui, %GUIKeysTextEditor%: +Resize  ; Make the window resizable.
Gui, %GUIKeysTextEditor%: Add, Edit, vMainEdit WantTab W600 R20
Gui, %GUIKeysTextEditor%: Add, Button,, &Done


CurrentFileName := ""  ; Indicate that there is no current file.
return

FileNew:
GuiControl,%GUIKeysTextEditor%: ,  MainEdit  ; Clear the Edit control.
return

FileOpen:
Gui %GUIKeysTextEditor%: +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, 3,, Open File, Text Documents (*.txt)
if not SelectedFileName  ; No file selected.
    return
Gosub FileRead
return

FileRead:  ; Caller has set the variable SelectedFileName for us.
FileRead, MainEdit, %SelectedFileName%  ; Read the file's contents into the variable.
if ErrorLevel
{
    MsgBox Could not open "%SelectedFileName%".
    return
}
GuiControl, %GUIKeysTextEditor%:,  MainEdit, %MainEdit%  ; Put the text into the control.
CurrentFileName := SelectedFileName
Gui, %GUIKeysTextEditor%: Show,, %CurrentFileName%   ; Show file name in title bar.
return

FileSave:
if not CurrentFileName   ; No filename selected yet, so do Save-As instead.
    Goto FileSaveAs
Gosub SaveCurrentFile
return

FileSaveAs:
Gui, %GUIKeysTextEditor%: +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, S16,, Save File, Text Documents (*.txt)
if not SelectedFileName  ; No file selected.
    return
CurrentFileName := SelectedFileName
Gosub SaveCurrentFile
return

SaveCurrentFile:  ; Caller has ensured that CurrentFileName is not blank.
if FileExist(CurrentFileName)
{
    FileDelete %CurrentFileName%
    if ErrorLevel
    {
        MsgBox The attempt to overwrite "%CurrentFileName%" failed.
        return
    }
}
GuiControlGet, %GUIKeysTextEditor%: MainEdit  ; Retrieve the contents of the Edit control.
FileAppend, %MainEdit%, %CurrentFileName%  ; Save the contents to the file.
; Upon success, Show file name in title bar (in case we were called by FileSaveAs):
Gui, %GUIKeysTextEditor%: Show,, %CurrentFileName%
return

HelpAbout:
Gui,%GUIKeysTextEditor%: About:+owner1  ; Make the main window (Gui #1) the owner of the "about box".
Gui %GUIKeysTextEditor%: +Disabled  ; Disable main window.
Gui, %GUIKeysTextEditor%: About:Add, Text,, Text for about box.
Gui, %GUIKeysTextEditor%: About:Add, Button, Default, OK
Gui, %GUIKeysTextEditor%: About:Show
return

AboutButtonOK:  ; This section is used by the "about box" above.
AboutGuiClose:
AboutGuiEscape:
Gui,%GUIKeysTextEditor%: 1:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui %GUIKeysTextEditor%: Destroy  ; Destroy the about box.
return

GuiDropFiles:  ; Support drag & drop.
Loop, Parse, A_GuiEvent, `n
{
    SelectedFileName := A_LoopField  ; Get the first file only (in case there's more than one).
    break
}
Gosub FileRead
return

GuiSize:
if (ErrorLevel = 1)  ; The window has been minimized. No action needed.
    return
; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
NewWidth := A_GuiWidth - 20
NewHeight := A_GuiHeight - 20
GuiControl, %GUIKeysTextEditor%: Move, MainEdit, W%NewWidth% H%NewHeight%
return

FileExit:     ; User chose "Exit" from the File menu.
GuiClose:  ; User closed the window.
ButtonOK:
GuiEscape:
ExitApp


; Gui, Add, Text,, Activation Variable:
; Gui, Add, Text,, Key Sequence:
; Gui, Add, Edit, vActivationVariable ym  ; The ym option starts a new column of controls.
; Gui, Add, Edit, vKeySequence
; Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
; Gui, Show,, Simple Input Example
; return  ; End of auto-execute section. The script is idle until the user does something.

; GuiClose:
; ButtonOK:
; Gui, Submit  ; Save the input from the user to each control's associated variable.
; MsgBox Activation variable is: "%ActivationVariable%".
; MsgBox Sequence is: "%KeySequence%".






UserInput:

    Input, KeyPressed, L1 V, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
    
    if (KeyPressed = "i" Or KeyPressed = "p"){
        SetTimer, UserInput, Off
        Return
    }

    time := A_TickCount
    KeyWait, %KeyPressed%
    timePressedDown := A_TickCount - time
    ToolTip User interaction at %A_Hour%:%A_Min%:%A_Sec%
    ; MsgBox, The %KeyPressed% key has been held down for %timePressedDown%ms

    KeysPressed = %KeysPressed%|%KeyPressed%
    KeysPressedDurations = %KeysPressedDurations%|%timePressedDown%


    GuiControl, %GUIshowKeysPressedAndDuration%:,  KeysPressedText, % KeysPressed
    GuiControl, %GUIshowKeysPressedAndDuration%:,  KeysPressedDurationsText, % KeysPressedDurations
Return

O::
    KeysPressed = 
    KeysPressedDurations = 
    SetTimer,UserInput,10
Return

I::
    SetTimer, UserInput, Off
    test :=  DecodeKeyStrokes(KeysPressed, KeysPressedDurations)
    MsgBox,, Title, %test%
    GuiControl, %GUIKeysTextEditor%:,  MainEdit, %test%
    ; Put the text into the control.
    Gui, %GUIKeysTextEditor%: Show,, Untitled
Return

K::
    ExcecuteKeyStrokes(KeysPressed, KeysPressedDurations)   
Return

P::
    ExitApp, [ ExitCode]
Return



;*************FUNCTIONS***********
List(listName,integer)
{
    Loop, parse, listName, |
    {
        If (integer = A_Index) {
            returnValue := A_LoopField
        }
    }
    return returnValue
}

ExcecuteKeyStrokes(KeysPressed, KeysPressedDuration)
{
    Loop, parse, KeysPressed, |
    {
        KeyDownDuration := List(KeysPressedDuration, A_index)
        Send {%A_LoopField% down}
        Sleep KeyDownDuration
        Send {%A_LoopField% up}
    }
    return 
}

DecodeKeyStrokes(KeysPressed, KeysPressedDuration)
{
    OutputVariable := "Key(s) Pressed | Time Held"

    Loop, parse, KeysPressed, |
        {
            KeyDownDuration := List(KeysPressedDuration, A_index)
            OutputVariable =%OutputVariable% %A_LoopField%
            OutputVariable =%OutputVariable% %KeyDownDuration%
            OutputVariable =%OutputVariable% `n
        }
    return OutputVariable
}

; ? should i use this --> SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

; ;TODO can press a button, for then it to take inputs, maybe get a menu? ;
; ; Also, can read the mouse movement and then copy it, this could be very useful for very easily automating f.eks leaf blower revolution;
; ; In that game i could buy upgrades, change location, wait, and then reset and do it over, f.eks. can be applied for a lot of repetitive tasks i'm sure.;
; ; do it like macros do, and add an option to save. have "repeat x times", "run forever(until a button press or something)" "run for this long time", and so on... ; 
; !this code snippet is an example of how to make a loop that can repeat the given key strokes
; !figure out what is and is not needed.
; #maxThreadsPerHotkey, 2
; setKeyDelay, 0, 0
; setMouseDelay, 0
; banana:=0
; $f2::
; 	banana:=!banana
	
; 	while (banana=1)
; 	{
; 		send, {left}
; 		sleep, 100
; 		send, {right}
; 		sleep, 100
; 		send, {enter}
; 	}