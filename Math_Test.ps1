<#
.NAME
    Math_Test.ps1

.AUTHOR
    Ryan Parker

.SYNOPSIS
    Display 2 random numbers for a math equation

.DESCRIPTION
    Script will generate 2 random numbers and, based on size, mark them as an addition equation or subtraction equation

.NOTES

#>


function Question
{
    $AnswerTextBox.Text=$null
    $AnswerLabel.Text=$null
    $Global:a=Get-Random -Maximum 100
    if ($a -gt 50)
    {
        $Global:b=get-random -Maximum 50
    }
    else
    {
        $Global:b=Get-Random -Maximum 100
    }
    if ($a -gt $b)
    {
        $QuestionLabel.Text="$a - $b ="
        $Global:add=$false
    }
    else
    {
        $QuestionLabel.Text="$a + $b ="
        $Global:add=$true
    }
    $MainForm.Controls.Add($AnswerTextBox)
    $MainForm.Controls.Add($CheckAnswerButton)
    $NextQuestionButton.Text = "Next Question"
} # End Question funtion


Function CheckAnswer
{
    if ($Global:add -eq $true)
    {
        if (($Global:a + $Global:b) -eq $AnswerTextBox.Text)
        {
            $iscorrect=$true
        }
    }
    else
    {
        if (($Global:a - $Global:b) -eq $AnswerTextBox.Text)
        {
            $iscorrect=$true
        }
    }
    if ($iscorrect -eq $true)
    {
        $AnswerLabel.Text="Correct!"
        $AnswerLabel.ForeColor="Green"
        $AnswerLabel.Location = New-Object System.Drawing.Size(90,90)
        $MainForm.Controls.Add($AnswerLabel)
    }
    else
    {
        $AnswerLabel.Text="Incorrect :("
        $AnswerLabel.ForeColor="Red"
        $AnswerLabel.Location = New-Object System.Drawing.Size(60,90)
        $MainForm.Controls.Add($AnswerLabel)
    }
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



#**************************************************************************************************************************
# Create the GUI
#**************************************************************************************************************************

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


#Create form 
$MainForm = New-Object System.Windows.Forms.Form
$MainForm.Size = New-Object System.Drawing.Size(360,250)
$MainForm.KeyPreview = $True
$MainForm.FormBorderStyle = "1"
$MainForm.MaximizeBox = $false
$MainForm.StartPosition = "CenterScreen"
$MainForm.Text = "Exam Simulator"

#Question Label
$QuestionLabel = New-Object System.Windows.Forms.Label
$QuestionLabel.Size = New-Object System.Drawing.Size(150,150)
$QuestionLabel.Location = New-Object System.Drawing.Size(80,30)
$QuestionLabel.AutoSize=$True
$QuestionLabel.Text="Hi Greyson!"
$QuestionLabel.Font='Segoe UI, 15.75pt, style=Bold, Italic'
$MainForm.Controls.Add($QuestionLabel)

#Answer Label
$AnswerLabel = New-Object System.Windows.Forms.Label
$AnswerLabel.Size = New-Object System.Drawing.Size(150,140)
$AnswerLabel.AutoSize=$True
$AnswerLabel.Font='Segoe UI, 30pt, style=Bold, Italic'


#Answer TextBox
$AnswerTextBox = New-Object System.Windows.Forms.TextBox
$AnswerTextBox.Size = New-Object System.Drawing.Size(50,50)
$AnswerTextBox.Location = New-Object System.Drawing.Size(($QuestionLabel.right),($QuestionLabel.top))
$AnswerTextBox.Font='Segoe UI, 15.75pt, style=Bold, Italic'


#NextQuestion button
$NextQuestionButton = New-Object System.Windows.Forms.Button
$NextQuestionButton.Size = New-Object System.Drawing.Size(150,25)
$NextQuestionButton.Location = New-Object System.Drawing.Size(180,170)
$NextQuestionButton.Text = "Start Test"
$MainForm.Controls.Add($NextQuestionButton)
$NextQuestionButton.add_click({Question})

#CheckAnswer button
$CheckAnswerButton = New-Object System.Windows.Forms.Button
$CheckAnswerButton.Size = New-Object System.Drawing.Size(150,25)
$CheckAnswerButton.Location = New-Object System.Drawing.Size(15,170)
$CheckAnswerButton.Text = "Check Answer"
$CheckAnswerButton.add_click({CheckAnswer})



Display-Console 0
$MainForm.Add_Shown({$MainForm.Activate()})
[void] $MainForm.ShowDialog()

