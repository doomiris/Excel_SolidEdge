VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmBatchOpen 
   Caption         =   "��ָ��DFT"
   ClientHeight    =   1380
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   4215
   OleObjectBlob   =   "frmBatchOpen.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmBatchOpen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CommandButton1_Click()
Me.Hide
End Sub

Private Sub CommandButton2_Click()
Me.Hide
AppActivate seApp.Name
End Sub

Private Sub UserForm_Activate()
ListBox1.Clear
'TextBox1.Value = "Loading...please wait..."
frmBatchOpen.Height = 97
Call batchOpen

End Sub

Sub batchOpen()
If seApp Is Nothing Then Call Conn2se

Dim Docs As SolidEdgeFramework.Documents
Set Docs = seApp.Documents

Dim myWorkspace As String
myWorkspace = GetSetting("Domisoft", "Config", "SE_Working", "")

Dim uRg As Excel.Range
Set uRg = Excel.Selection

Dim filename As String
Dim msG As String
msG = ""

Dim allowDeepSearch As Boolean
allowDeepSearch = True

Dim fl As New Scripting.Dictionary
If allowDeepSearch Then
    Set fl = ListAllFsoDic(myWorkspace)
Else
    Dim fso As New Scripting.FileSystemObject
    Dim fs As Scripting.Files
    Set fs = fso.GetFolder(myWorkspace).Files
    If fs.Count > 1 Then
        For Each f In fs
            fl(f.Name) = f.path
        Next
    Else
       '
    End If
End If

seApp.Application.DisplayAlerts = False

'If uRg.Find("*") Is Nothing Then
'    filename = InputBox("������Ҫ�򿪵��ļ���\n ����0080191234:", "�ļ���")
'    If Len(filename) > 0 Then
'        Call Docs.Open(fl(filename))
'    End If
'End If

For j = 1 To uRg.Columns.Count
    For i = 1 To uRg.Rows.Count
        If uRg.Cells(i, j).Value = "" Then GoTo nSkip
        filename = Split(uRg.Cells(i, j).Value, ".")(0)
        If InStr(1, filename, Chr(10), vbTextCompare) > 0 Then
            filename = Split(filename, Chr(10))(0)           ' TODO һ���ﺬ�ж���ļ���
        End If
        filename = Trim(filename)
        
        If Len(filename) = 8 And Left(filename, 1) = 8 Then filename = "00" & filename    '���00����
        
        'filename = Replace(filename, cha(16), "")
        'filename = Left(filename, 10)
        
        If filename = "" Then GoTo nSkip
        filename = filename & ".dft"
        'filename = myWorkspace & "\" & filename
        
        If fl.Exists(filename) Then
            Call Docs.Open(fl(filename))
        Else
            msG = msG & "," & filename
        End If
nSkip:
    Next i
Next j

seApp.Application.DisplayAlerts = True

Set Docs = Nothing

If msG = "" Then
'    TextBox1.ForeColor = vbBlack
'    TextBox1.Value = "All done"
'CommandButton2.Enabled = True
    Me.Hide
    AppActivate seApp.Name
Else
    ListBox1.Visible = True
    frmBatchOpen.Height = 184
    
    Dim lit As Variant
    lit = Split(Trim(Join(Split(msG, ","), " ")), " ")

    For k = LBound(lit) To UBound(lit)
            ListBox1.AddItem lit(k), k
            ListBox1.list(k, 1) = "�Ҳ�����ͼֽ!"
    Next k
    CommandButton2.Caption = "  Click to return to Solid Edge >>"
End If
End Sub

Private Function ListAllFsoDic(myPath$) As Scripting.Dictionary '
    Dim i&, j&
    Dim d1 As New Scripting.Dictionary '�ֵ�d1��¼���ļ��еľ���·����
    Dim d2 As New Scripting.Dictionary '�ֵ�d2��¼�ļ���(key)��·��(items)
     
     d1(myPath) = ""           '�Ե�ǰ·��myPath��Ϊ��ʼ��¼���Ա㿪ʼѭ�����
     
    Dim fso As New Scripting.FileSystemObject
    Dim f As Scripting.File
    Do While i < d1.Count
    '���ֵ�1�ļ�������δ���������key����ʱ����Doѭ�� ֱ�� i=d1.Count���������ļ��ж��Ѵ���ʱֹͣ
 
        kr = d1.Keys 'ȡ���ļ��������е�key���������ļ���·�� ��ע��ÿ�ζ�Ҫ���£�
        For Each f In fso.GetFolder(kr(i)).Files '���������ļ����������ļ� ��ע������µ�kr(i) ��ʼ��
            j = j + 1
            Select Case f.Type
                Case "Solid Edge Draft Document"
                    d2(f.Name) = f.path
            End Select
           '�Ѹ����ļ����ڵ������ļ�����Ϊ�ֵ�key������ֵ�d2 ,����������д*******************************
        Next
 
        i = i + 1 '�Ѿ�����������ļ�����Ŀ i +1 �������´β����ظ�����
        For Each fd In fso.GetFolder(kr(i - 1)).SubFolders '�������ļ����������µ����ļ���
            d1(fd.path) = " " & fd.Name & ""
            '���µ����ļ���·�������ֵ�d1�Ա�����һ��ѭ���д���
        Next
    Loop
    
    Set ListAllFsoDic = d2

End Function
