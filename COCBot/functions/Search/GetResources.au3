;Uses the getGold,getElixir... functions and uses CompareResources until it meets conditions.
;Will wait ten seconds until getGold returns a value other than "", if longer than 10 seconds - calls checkNextButton
;-clicks next if checkNextButton returns true, otherwise will restart the bot.

Func GetResources($MidAttack = False) ;Reads resources
	Local $RetVal[6]
	Local $i = 0
	Local $x = 0
	Local $txtDead = "Live"
	If Not $MidAttack Then
		While getGold(51, 66) = "" ; Loops until gold is readable
			If _Sleep(500) Then Return False
			$i += 1
			If $i >= 20 Then ; If gold cannot be read by 10 seconds
				If checkNextButton() And $x <= 20 Then ;Checks for Out of Sync or Connection Error during search
					Click(750, 500) ;Click Next
					If _Sleep(1000) Then Return False
					$x += 1
				Else
					SetLog("Cannot locate Next button, Restarting Bot", $COLOR_RED)
					_CaptureRegion()
					Local $dummyX = 0
					Local $dummyY = 0
					If _ImageSearch(@ScriptDir & "\images\Client.bmp", 1, $dummyX, $dummyY, 50) = 1 Then
						If $dummyX > 290 And $dummyX < 310 And $dummyY > 325 And $dummyY < 340 Then
							$speedBump += 500
							If $speedBump > 5000 Then
								$speedBump = 5000
								SetLog("Out of sync! Already searching slowly, not changing anything.", $COLOR_RED)
							Else
								SetLog("Out of sync! Slowing search speed by 0.5 secs.", $COLOR_RED)
							EndIf
						EndIf
					EndIf
					If $DebugMode = 1 Then
						_GDIPlus_ImageSaveToFile($hBitmap, $dirDebug & "NoNextRes-" & @HOUR & @MIN & @SEC & ".png")
					EndIf
					If $PushBulletEnabled = 1 Then
						_Push("Disconnected", "Your bot got disconnected while searching for enemy..")
					EndIf
					Return False
				EndIf
				$i = 0
			EndIf
		WEnd
	EndIf

	If $MidAttack Then
		$RetVal[0] = ""
	Else
		$RetVal[0] = checkDeadBase()
	EndIf
	If $MidAttack Then
		$RetVal[1] = ""
	Else
		$RetVal[1] = checkTownhall()
	EndIf
	$RetVal[2] = getGold(51, 66)
	$RetVal[3] = getElixir(51, 66 + 29)
	$RetVal[5] = getTrophy(51, 66 + 90)

	If $RetVal[0] Then $txtDead = "Dead"

	If $RetVal[5] <> "" Then
		$RetVal[4] = getDarkElixir(51, 66 + 57)
	Else
		$RetVal[4] = 0
		$RetVal[5] = getTrophy(51, 66 + 60)
	EndIf

	If $RetVal[1] = "-" Then
		$THLoc = "-"
		$THquadrant = "-"
		$THx = 0
		$THy = 0
	Else
		$THquadrant = 0
		If $WideEdge = 1 Then
			If ((((85 - 389) / (528 - 131)) * ($THx - 131)) + 389 > $THy) Then
				$THquadrant = 1
			ElseIf ((((237 - 538) / (723 - 337)) * ($THx - 337)) + 538 > $THy) Then
				$THquadrant = 4
			Else
				$THquadrant = 7
			EndIf
			If ((((388 - 85) / (725 - 330)) * ($THx - 330)) + 85 > $THy) Then
				$THquadrant = $THquadrant + 2
			ElseIf ((((537 - 238) / (535 - 129)) * ($THx - 129)) + 238 > $THy) Then
				$THquadrant = $THquadrant + 1
			EndIf
		Else
			If ((((70 - 374) / (508 - 110)) * ($THx - 110)) + 374 > $THy) Then
				$THquadrant = 1
			ElseIf ((((252 - 552) / (742 - 358)) * ($THx - 358)) + 552 > $THy) Then
				$THquadrant = 4
			Else
				$THquadrant = 7
			EndIf
			If ((((373 - 70) / (744 - 350)) * ($THx - 350)) + 70 > $THy) Then
				$THquadrant = $THquadrant + 2
			ElseIf ((((552 - 253) / (516 - 108)) * ($THx - 108)) + 253 > $THy) Then
				$THquadrant = $THquadrant + 1
			EndIf
		EndIf
		If $THquadrant >= 1 And $THquadrant <= 4 Then $THLoc = "Out"
		If $THquadrant = 5 Then $THLoc = "In"
		If $THquadrant >= 6 And $THquadrant <= 9 Then $THLoc = "Out"
	EndIf

	$SearchCount += 1 ; Counter for number of searches
	SetLog("(" & $SearchCount & ") [G]: " & $RetVal[2] & Tab($RetVal[2], 7) & "[E]: " & $RetVal[3] & Tab($RetVal[3], 7) & "[D]: " & $RetVal[4] & Tab($RetVal[4], 4) & "[T]: " & $RetVal[5] & Tab($RetVal[5], 3) & "[TH]: " & $RetVal[1] & (($RetVal[1] <> "-") ? ("-Q" & $THquadrant) : ("")) & ", " & $THLoc & ", " & $txtDead, $COLOR_BLUE)
	Return $RetVal
EndFunc   ;==>GetResources
