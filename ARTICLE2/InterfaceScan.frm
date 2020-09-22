VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "Comdlg32.ocx"
Begin VB.Form InterfaceScan 
   Caption         =   "Interface Scan"
   ClientHeight    =   3585
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   10230
   LinkTopic       =   "Form1"
   ScaleHeight     =   3585
   ScaleWidth      =   10230
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdBrowse2 
      Caption         =   "Browse"
      Height          =   375
      Left            =   8040
      TabIndex        =   9
      Top             =   2040
      Width           =   2055
   End
   Begin VB.TextBox txtWriteTo 
      Height          =   285
      Left            =   2280
      TabIndex        =   8
      Top             =   2040
      Width           =   5655
   End
   Begin MSComDlg.CommonDialog cdgSave 
      Left            =   8040
      Top             =   1200
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton cmdBrowse 
      Caption         =   "Browse"
      Height          =   375
      Left            =   8040
      TabIndex        =   6
      Top             =   720
      Width           =   2055
   End
   Begin VB.TextBox txtName 
      Height          =   285
      Left            =   2280
      TabIndex        =   3
      Top             =   1320
      Width           =   5655
   End
   Begin VB.CommandButton cmdScan 
      Caption         =   "Generate HTML Help Outline"
      Height          =   495
      Left            =   2280
      TabIndex        =   2
      Top             =   3000
      Width           =   5655
   End
   Begin VB.TextBox txtProject 
      Height          =   495
      Left            =   2280
      MultiLine       =   -1  'True
      TabIndex        =   1
      Top             =   720
      Width           =   5655
   End
   Begin VB.Label lblWriteTo 
      Caption         =   "Location where you wish the generate the HTML help outline and its HTML help files."
      Height          =   855
      Left            =   120
      TabIndex        =   7
      Top             =   2040
      Width           =   1935
   End
   Begin VB.Label lblTitle 
      Alignment       =   2  'Center
      Caption         =   "HTML Help File Outline Generator"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   8055
   End
   Begin VB.Label Label1 
      Caption         =   "Name of HTML help file in the Active X .dll"
      Height          =   495
      Left            =   120
      TabIndex        =   4
      Top             =   1440
      Width           =   1935
   End
   Begin VB.Label lblProject 
      Caption         =   "Path to ActiveX dll you wish to generate HTML help outline for:"
      Height          =   615
      Left            =   120
      TabIndex        =   0
      Top             =   720
      Width           =   1935
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileOpen 
         Caption         =   "&Open"
      End
      Begin VB.Menu mnuFileExit 
         Caption         =   "&Exit"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "InterfaceScan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Sub cmdBrowse_Click()

Dim sName As String
Dim rtn As String
 
 
' very standard common dialog opening mechanism.
cdgSave.CancelError = True
On Error GoTo cmdSaveAs_Click_Error:
    cdgSave.Filter = ".dll file (*.dll*)|*.dll|.tlb file (*.tlb*)|*.tlb"
    cdgSave.Flags = &H2 Or &H400
    cdgSave.ShowOpen

' set the local name of the file from the browsed entry
    sName = cdgSave.FileName
' set the txtproject text value based on the name of the file
    txtProject.Text = sName
    txtName.Text = Left(cdgSave.FileTitle, Len(cdgSave.FileTitle) - (Len(cdgSave.FileTitle) - InStr(1, cdgSave.FileTitle, ".")) - 1)
     
' standard error handling shell, unused.
cmdSaveAs_Click_Exit:
    Exit Sub
cmdSaveAs_Click_Error:
    Resume cmdSaveAs_Click_Exit

End Sub

Private Sub cmdBrowse2_Click()
Dim sName As String
Dim rtn As String
 
 
' very standard common dialog opening mechanism.
cdgSave.CancelError = True
On Error GoTo cmdSaveAs_Click_Error:
    cdgSave.Filter = ""
    cdgSave.Flags = &H2 Or &H400
    cdgSave.ShowOpen

' set the local name of the file from the browsed entry
    sName = Left(cdgSave.FileName, InStrRev(cdgSave.FileName, "\") - 1)
' set the txtproject text value based on the name of the file
    txtWriteTo.Text = sName
     
' standard error handling shell, unused.
cmdSaveAs_Click_Exit:
    Exit Sub
cmdSaveAs_Click_Error:
    Resume cmdSaveAs_Click_Exit
End Sub

Private Sub cmdScan_Click()
    
' start scanning an interface
' begin by disabling the button to give a visual sign that the scan is working
' also, turn on the hourglass so that the hint is very strong :)
    cmdScan.Enabled = False
    Screen.MousePointer = vbHourglass
' define an object for scanning the interface
    Dim oInterfaceScan As clsInterfaceScan
    Set oInterfaceScan = New prjInterfaceScan.clsInterfaceScan
' run the scan
    oInterfaceScan.InterfaceScan txtProject.Text, txtName.Text, txtWriteTo.Text
' indicate the scan is complete
    Screen.MousePointer = vbNormal
    cmdScan.Enabled = True

End Sub

Private Sub Form_Load()

InterfaceScan.Width = Screen.Width
InterfaceScan.Height = Screen.Height
txtWriteTo.Text = App.Path

End Sub

Private Sub Form_Unload(Cancel As Integer)

End

End Sub

Private Sub Label1_Click()

End Sub

Private Sub lblProject_Click()

End Sub

Private Sub mnuFileExit_Click()
    Unload InterfaceScan
End Sub

Private Sub mnuFileOpen_Click()
cmdBrowse_Click
End Sub

Private Sub mnuHelpAbout_Click()
    Load frmAbout
    frmAbout.Visible = True
End Sub
