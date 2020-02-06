<#
.NAME
    exam_simulator.ps1

.AUTHOR
    Ryan Parker

.SYNOPSIS
    Read a CSV file and create an exam

.DESCRIPTION
    Script will create a GUI based exam simulation to test subject knowledge. I built this because I didn't want to see the answer right below the question when viewing PDF based questions.

.NOTES

#>

# This function will display the Question number, Question, Options, and Checkboxes for the options
function Question
{
param ($array,
    $questionnumber)

    # Removing previous value for Questionlabel
    $QuestionLabel.Text=$null
    # Defining which question to display
    $question=$array[$questionnumber]
    # Starting a counter for the checkbox name
    $j=0
    # Creating the array to hold the checkboxes created in the foreach loop below
    $Global:checkboxes=@()
    # Displaying the question to the form
    $QuestionLabel.Text="Question $([int]$i + 1) of $($array.Question.count)`n`n"

    # Running foreach loop to create line breaks between the items in the Question column in the CSV. Using the semicolon as a separator
    foreach ($part in $question.question.split(";"))
    {
        $QuestionLabel.Text += "$part`n`n"
    }
    # Now we have to parse through the options for the question. I'm also creating one checkbox per option and adding it to an array
    foreach ($option in $($question.Options.split(";")))
    {
        #$OptionLabel.Text+=" $($option)`n`n"
        

        #$CheckBox=New-Variable -name "CheckBox_$($alpha[$j])"
        $CheckBox = New-Object System.Windows.Forms.CheckBox
        $CheckBox.Size = New-Object System.Drawing.Size(600,25)
        $CheckBox.Text=$null
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 25
        # Make sure to vertically space them dynamically, counter comes in handy
        $System_Drawing_Point.Y = ($QuestionLabel.bottom + 40) + (($checkboxcounter - 1) * 25)
        $CheckBox.Location = $System_Drawing_Point
        $CheckBox.Name="Checkbox_$($j)"
        $CheckBox.Text=$option
        $MainForm.Controls.Add($CheckBox)
        $Global:checkboxes+=$checkbox
        $checkboxcounter++
        $j++
    }  
    # Adding the Explanation fields
    ShowExplanation -array $Global:array -questionnumber $Global:i

    # Checking if we're on the last question. If so, we remove the Next Question button
    if ($Global:i -eq  $($Global:array.count -1))
    {
        $MainForm.Controls.Remove($NextQuestionButton)
    }
} # End Question funtion



Function ParseCSV
{
    # Setting global counter that we use to determine which question from the object we need
    $Global:i=0
    # Setting global array to collect the custom objects from the CSV
    $Global:array=@()
    # Setting global counters for answers
    $Global:correct=0
    $Global:incorrect=0
    #$Global:hash=@{}

    # Creating a results variable that we can store which questions were correct
    $Global:results=""
    # Parsing the CSV to create a custom object. I'm doing this so I can change the import type in the future without having to modify the functions
    Foreach ($question in (Import-Csv C:\temp\exam_simulator.csv))
    {
        $object=[pscustomobject] @{
            'Question'=$($question.Question)
            'Options'=$($question.Options)
            'Answer'=$($question.Answer)
            'Explanation'=$($question.Explanation)
            }
        $Global:array+=$object
    }
    $MainForm.Controls.Remove($StartTestButton)
    $MainForm.Controls.Add($EndTestButton)
    $MainForm.Controls.Add($NextQuestionButton)
    $MainForm.Controls.Remove($AnswerLabel)
    $MainForm.Controls.Add($ShowAnswerButton)
}

Function Answer
{
param ($array,
    $questionnumber)
    #resetting variable
    #$iscorrect=$null
    # Checking if the answer is more than one character (multiple parts for the answer)
    if ($array[$questionnumber].Answer.length -lt 2)
    {
        # Checking if the checkbox number that matches the answer is checked
        if ($checkboxes.checked[$array[$questionnumber].answer] -eq $true)
        { 
            $iscorrect=$True
        }
    }
    else # Need to revisit this if I add questions that have more than 2 right answers. Right now it only checks 2 values
    {
        if (($checkboxes.checked[[string]$array[$questionnumber].answer[0]]) -eq $true -and ($checkboxes.checked[[string]$array[$questionnumber].answer[1]]) -eq $true)
        {
            $iscorrect=$True
        }
    } 
    # Now we check if we returned true for the answer  
    if ($iscorrect -eq $true)
    {
        $Global:correct++
        $Global:results+="$($i + 1). Correct`n"
    }
    else
    {
        $Global:incorrect++
        $Global:results+="$($i + 1). Incorrect`n"
    }
    # Clear the checkboxes for the next question. This is required since the number of checkboxes changes
    foreach ($box in $checkboxes)
    {
        $MainForm.Controls.Remove($box)
    }
}

Function EndTest
{
    $MainForm.Controls.Add($StartTestButton)
    $MainForm.Controls.Remove($EndTestButton)
    $MainForm.Controls.Remove($NextQuestionButton)
    $QuestionLabel.Text=$null
    $QuestionLabel.Text += "Click on Start Exam to begin`n`n"
    $MainForm.Controls.Remove($ExplanationLabel)
    $MainForm.Controls.Remove($ExplanationTextBox)
    # Check the answer for the final question
    Answer -array $Global:array -questionnumber $Global:i
    write-host $Global:results
    # Display the results in the GUI. *** Needs to be broken up into columns ***
    $QuestionLabel.Text += $Global:results
}

Function NextQuestion
{
    if ($Global:i -eq  $($Global:array.count -1))
    {
        #write-host "no more questions"
        $MainForm.Controls.Remove($NextQuestionButton)
    }
    else
    {
        Answer -array $Global:array -questionnumber $Global:i
        $Global:i++
        Question -array $Global:array -questionnumber $Global:i
        
    }
}

Function ShowExplanation
{
param ($array,
    $questionnumber)

    $MainForm.Controls.Add($ExplanationLabel)
    $MainForm.Controls.Add($ExplanationTextBox)
    $ExplanationLabel.Location = New-Object System.Drawing.Size(($QuestionLabel.left),($Global:CheckBoxes[-1].Bottom + 40))
    $ExplanationTextBox.Location = New-Object System.Drawing.Size(($ExplanationLabel.left),($ExplanationLabel.Bottom + 10))
    $ExplanationTextBox.Text=$array[$questionnumber].Explanation

}


Function ShowAnswer ### IN PROGRESS ###
{
param ($array,
    $questionnumber)
      #get answer number

      #check the checkbox(s)
      $box=$checkboxes[$array[$questionnumber].answer]
      $box.forecolor="Red"
      $box.Font='10pt, style=Bold'
      $box.checked=$true
}


# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Display-Console ($option)
{
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, $option)
}

########################################################################
#                                                                      #
# FUTURE FEATURES:                                                     #
#                                                                      #
# Jump to Question                                                     #
# Hypertext to Question from Results                                   #
#                                                                      #
########################################################################


#**************************************************************************************************************************
# Create the GUI
#**************************************************************************************************************************

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


#Create form 
$MainForm = New-Object System.Windows.Forms.Form
$MainForm.Size = New-Object System.Drawing.Size(830,500)
$MainForm.KeyPreview = $True
$MainForm.FormBorderStyle = "1"
$MainForm.MaximizeBox = $false
$MainForm.StartPosition = "CenterScreen"
$MainForm.Text = "Exam Simulator"

#Question Label
$QuestionLabel = New-Object System.Windows.Forms.Label
$QuestionLabel.Size = New-Object System.Drawing.Size(750,150)
$QuestionLabel.Location = New-Object System.Drawing.Size(15,30)
$QuestionLabel.AutoSize=$True
$MainForm.Controls.Add($QuestionLabel)

<#
#Option Label
$OptionLabel = New-Object System.Windows.Forms.Label
$OptionLabel.Size = New-Object System.Drawing.Size(600,150)
$OptionLabel.Location = New-Object System.Drawing.Size(($QuestionLabel.left + 45),($QuestionLabel.Bottom + 20))
#$MainForm.Controls.Add($OptionLabel)
#>

#Explanation Label
$ExplanationLabel = New-Object System.Windows.Forms.Label
$ExplanationLabel.Size = New-Object System.Drawing.Size(100,15)
#$ExplanationLabel.Location = New-Object System.Drawing.Size(($QuestionLabel.left),($OptionLabel.Bottom + 20))
$ExplanationLabel.Text="Explanation:"
#$MainForm.Controls.Add($ExplanationLabel)


#Explanation TextBox
$ExplanationTextBox = New-Object System.Windows.Forms.TextBox
$ExplanationTextBox.Size = New-Object System.Drawing.Size(780,500)
#$ExplanationTextBox.Location = New-Object System.Drawing.Size(($ExplanationLabel.left),($ExplanationLabel.Bottom + 10))
#$ExplanationTextBox.Text="Explanation:"
#$ExplanationTextBox.Enabled=$false
#$MainForm.Controls.Add($ExplanationTextBox)



#StartTest button
$StartTestButton = New-Object System.Windows.Forms.Button
$StartTestButton.Size = New-Object System.Drawing.Size(150,25)
$StartTestButton.Location = New-Object System.Drawing.Size(620,420)
$StartTestButton.Text = "Start Exam"
$MainForm.Controls.Add($StartTestButton)
$StartTestButton.add_click({ParseCSV;Question -array $Global:array -questionnumber $Global:i})


#EndTest button
$EndTestButton = New-Object System.Windows.Forms.Button
$EndTestButton.Size = New-Object System.Drawing.Size(150,25)
$EndTestButton.Location = New-Object System.Drawing.Size(620,420)
$EndTestButton.Text = "End Exam"
#$MainForm.Controls.Add($EndTestButton)
$EndTestButton.add_click({EndTest})

#NextQuestion button
$NextQuestionButton = New-Object System.Windows.Forms.Button
$NextQuestionButton.Size = New-Object System.Drawing.Size(150,25)
$NextQuestionButton.Location = New-Object System.Drawing.Size(450,420)
$NextQuestionButton.Text = "Next Question"
#$MainForm.Controls.Add($NextQuestionButton)
$NextQuestionButton.add_click({NextQuestion})

#ShowAnswer button
$ShowAnswerButton = New-Object System.Windows.Forms.Button
$ShowAnswerButton.Size = New-Object System.Drawing.Size(150,25)
$ShowAnswerButton.Location = New-Object System.Drawing.Size(15,420)
$ShowAnswerButton.Text = "Show Answer"
#$MainForm.Controls.Add($ShowAnswerButton)
$ShowAnswerButton.add_click({ShowAnswer -array $Global:array -questionnumber $Global:i})


#Answer Label
$AnswerLabel = New-Object System.Windows.Forms.Label
$AnswerLabel.Size = New-Object System.Drawing.Size(200,150)
$AnswerLabel.Location = New-Object System.Drawing.Size(($QuestionLabel.left),($QuestionLabel.Bottom + 20))
#$AnswerLabel.Text="Explanation:"
#$MainForm.Controls.Add($AnswerLabel)

Display-Console 1
$MainForm.Add_Shown({$MainForm.Activate()})
[void] $MainForm.ShowDialog()


<#
foreach of questions
    create checkbox


    #$alpha=[char[]]([int][char]'A'..[int][char]'Z')
            #$alpha=$alpha[$i]
            #write-host $alpha'. '$($option)
            #$OptionLabel.Text+="$alpha. $($option)`n`n"


            $MainForm.Controls.Remove($StartTestButton)
    $MainForm.Controls.Add($EndTestButton)
    $csv=Import-Csv C:\temp\exam_simulator1.csv
    $correct=0
    $incorrect=0
    
    Foreach ($question in $csv)
    {
        $NextQuestion=$false
        $QuestionLabel.Text=$null
        $i=0
        $checkboxcounter=1
        #Write-Host $question.Question`n
        foreach ($part in $question.Question.split(";"))
        {
            $QuestionLabel.Text += "$part`n`n"
        } 
        $OptionLabel.Text=$null
        foreach ($option in $($question.Options.split(";")))
        {
            $OptionLabel.Text+=" $($option)`n`n"
            $CheckBox = New-Object System.Windows.Forms.CheckBox
            $CheckBox.Size = New-Object System.Drawing.Size(100,20)
            $System_Drawing_Point = New-Object System.Drawing.Point
            $System_Drawing_Point.X = 25
            # Make sure to vertically space them dynamically, counter comes in handy
            $System_Drawing_Point.Y = 95 + (($checkboxcounter - 1) * 25)
            $CheckBox.Location = $System_Drawing_Point
            #$CheckBox.Location = New-Object System.Drawing.Size(($OptionLabel.left -45),($OptionLabel.top -5))
            $CheckBox.Name="Checkbox$checkboxcounter"
            $MainForm.Controls.Add($CheckBox)
            $checkboxcounter++
            $i++
        }  
        while ($NextQuestion -eq $false)
        {
            start-sleep -Seconds 1
        }


    create option
    check answer (separate function)





     $correct=0
    foreach ($box in $checkboxes)
    {
        if ($box.name.split("_")[1] -eq $array[$questionnumber].Answer)
        {
            write-host "correct"
        }
        else
        {
            Write-Host "incorrect"
        }     
        
        <#
        if ($box.Checked)
        {
            write-host "$($box.name) is checked"
        }
        else
        {
            write-host "$($box.name) is not checked"
        }
        #>

#>