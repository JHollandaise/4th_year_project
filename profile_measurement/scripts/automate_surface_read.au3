#include <FileConstants.au3>

;; Initialisation ========================================================================

; folder of the ID of the given scan set
Local $topLevelPath = FileSelectFolder("Scan save folder", "C:\Users\mrt10\Desktop")

; scan region variables
Local $xSpace = Number(InputBox("X scan spacing", "Input the desired x spacing [mm]", 1))
Local $xSamples = Number(InputBox("X samples", "Input the desired number of samples along x-axis", 1))
Local $xInitial = Number(InputBox("X initial", "Input the desired initial location on the x-axis [mm]", 1))

Local $ySpace = Number(InputBox("Y scan spacing", "Input the desired y spacing [mm]", 1))
Local $ySamples = Number(InputBox("Y samples", "Input the desired number of samples along y-axis", 1))
Local $yInitial = Number(InputBox("Y initial", "Input the desired initial location on the y-axis [mm]", 1))

; write a log file
$openLogFile = FileOpen($topLevelPath & "\scan_log.txt", $FO_OVERWRITE)
FileWrite($openLogFile, "x_space = " & String($xSpace))
FileWrite($openLogFile, @CRLF & "y_space = " & String($ySpace))
FileWrite($openLogFile, @CRLF & "x_samples = " & String($xSamples))
FileWrite($openLogFile, @CRLF & "y_samples = " & String($ySamples))
FileWrite($openLogFile, @CRLF & "x_initial = " & String($xInitial))
FileWrite($openLogFile, @CRLF & "Y_initial = " & String($YInitial))


Local $scanSpeed = 40;

; x-axis scan counter
Local $xCurrentScan;
; y-axis scan counter
Local $yCurrentScan;

; vary these mouse coords if the monitor used for this system is changed, as they are dependent on this!!!!
Local $scanCTRLTopBarXCoord = 850;
Local $scanCTRLTopBarYCoord = 20;


; initialise first motor driver instance
Local $xMotorTitle = "x_motor_control"
Run("C:\Program Files (x86)\Haydon Kerk Motion Solutions\IDEA Software\IDEA GUI.exe")
; wait for window to open
WinWaitActive("Select Drive Parameters")
; select default options
Send("{ENTER}")
WinWaitActive("Haydon Kerk IDEA Drive Interface Program (Realtime Mode)")
; rename the window to allow control
WinSetTitle("Haydon Kerk IDEA Drive Interface Program (Realtime Mode)", "", $xMotorTitle)
; initialise x extend parameters
; move to side of screen to make way for the jank scanCONTROL
Send("#{LEFT}")

; reset position
ControlClick($xMotorTitle,"","[CLASS:WindowsForms10.BUTTON.app.0.378734a; INSTANCE:24]")
WinWaitActive("Create Set Position Command")
Send("0")
Send("{ENTER}")
WinWaitActive($xMotorTitle)

; open move to menu
ControlClick($xMotorTitle,"","[CLASS:WindowsForms10.BUTTON.app.0.378734a; INSTANCE:16]")
WinWaitActive("Create Move To Command")
; enter distance (y scan spacing)
Send(String($xInitial))
; enter speed (WE DEFAULT THIS AT 5 mm/sec!!!)
Send("{TAB}")
Send(String($scanSpeed))
; select 1/64 step mode
Send("{TAB 4}")
Send("{DOWN 6}")
; execute in order to save these params into the box
Send("{ENTER}")
; wait for movement to finish
Sleep(Ceiling(1000 * $xInitial / $scanSpeed))



; initialise second motor driver instance
Local $yMotorTitle = "y_motor_control"
Run("C:\Program Files (x86)\Haydon Kerk Motion Solutions\IDEA Software\IDEA GUI.exe")
; wait for window to open
WinWaitActive("Select Drive Parameters")
; select default options
Send("{ENTER}")
WinWaitActive("Haydon Kerk IDEA Drive Interface Program (Realtime Mode)")
; rename the window to allow control
WinSetTitle("Haydon Kerk IDEA Drive Interface Program (Realtime Mode)", "", $yMotorTitle)
; initialise y extend parameters

; reset position
ControlClick($yMotorTitle,"","[CLASS:WindowsForms10.BUTTON.app.0.378734a; INSTANCE:24]")
WinWaitActive("Create Set Position Command")
Send(String(0))
Send("{ENTER}")
WinWaitActive($yMotorTitle)

; open move to menu
ControlClick($yMotorTitle,"","[CLASS:WindowsForms10.BUTTON.app.0.378734a; INSTANCE:16]")
WinWaitActive("Create Move To Command")
; enter distance (y scan spacing)
Send($yInitial)
; enter speed (WE DEFAULT THIS AT 5 mm/sec!!!)
Send("{TAB}")
Send(String($scanSpeed))
; select 1/64 step mode
Send("{TAB 4}")
Send("{DOWN 6}")
; execute in order to save these params into the box
Send("{ENTER}")
; wait for movement to finish
Sleep(Ceiling(1000 * $yInitial / $scanSpeed))

; intialise scanControl configurator (laser scanner control app) ------------------------------
Local $lasTitle = "scanCONTROL Configuration Tools"

; IMPORTANT!!!!!!!!! CHECK THESE THINGS BEFORE RUNNING THE SCRIPT!!!
; ensure scanCONTROL is running and has been stacked to the screen rhs
; also ensure "Trigger mode" is ticked
; and that the cursor to enter text into the name box is flashing
; see instructions for images and more detail for this stage, as careful setup is critical for proper functionality

; main loop
Local $x;
Local $y
Local $xScanSliceFolder;

; move from name entry to directory selector
Sleep(100)
MouseClick("left", $scanCTRLTopBarXCoord, $scanCTRLTopBarYCoord)
Send("+{TAB}")
For $x = 0 To $xSamples-1
   If Not ($x == 0) Then
	  ; move to appropriate x location
	  WinActivate($xMotorTitle)
	  WinWaitActive($xMotorTitle)
	  Send("{ENTER}")
	  WinWaitActive("Create Move To Command")
	  Send(String($xInitial + $xSpace * $x))
	  Send("{ENTER}")
	  WinActivate($xMotorTitle)
	  Sleep(Ceiling(1000 * $xSpace / $scanSpeed))
	  MouseClick("left", $scanCTRLTopBarXCoord, $scanCTRLTopBarYCoord)
	  Sleep(100)
   EndIf

   $xScanSliceFolder = $topLevelPath & "\" & String($x)
   ; add the x slice scan folder
   DirCreate($xScanSliceFolder)
   ; change the working directory
   Send("{SPACE}")
   WinWaitActive("Save profiles")
   Send("{TAB 3}")
   Send("{ENTER}")
   Send($xScanSliceFolder)
   Send("{ENTER}")
   Sleep(100)
   ControlClick("Save profiles","","[CLASS:Button; INSTANCE:1]")
   Sleep(500)
   ; go to record button and start recording and go to trigger button
   Send("{TAB 2}")
   Send("{SPACE}")
   Send("+{TAB}")

   ; scan loop
   For $y = 0 To $ySamples-1
	  If Not ($x == 0) Or Not ($y == 0) Then
		 ; move to appropriate location
		 WinActivate($yMotorTitle)
		 WinWaitActive($yMotorTitle)
		 Send("{ENTER}")
		 WinWaitActive("Create Move To Command")
		 Send(String($yInitial + $ySpace * $y))
		 Send("{ENTER}")
		 WinActivate($yMotorTitle)

		 ; wait for movement
		 Sleep(Ceiling(1000 * $ySpace / $scanSpeed))
		 ; additional wait for the return to start
		 If ($y == 0) Then
			Sleep(Ceiling(1000 * $ySpace * ($ySamples-1) / $scanSpeed))
		 EndIf
	  EndIf

	  MouseClick("left", $scanCTRLTopBarXCoord, $scanCTRLTopBarYCoord)
	  Sleep(20)
	  ; record sample
	  Send("{SPACE}")

   Next
   ; return to directory selector
   Send("+{TAB}")
   Send("{SPACE}")
   Send("+{TAB 4}")
Next

; move back to (0,0)
; in y
WinActivate($yMotorTitle)
WinWaitActive($yMotorTitle)
Send("{ENTER}")
WinWaitActive("Create Move To Command")
Send("0")
Send("{ENTER}")
WinActivate($yMotorTitle)
; in x
WinActivate($xMotorTitle)
WinWaitActive($xMotorTitle)
Send("{ENTER}")
WinWaitActive("Create Move To Command")
Send("0")
Send("{ENTER}")
WinActivate($xMotorTitle)
