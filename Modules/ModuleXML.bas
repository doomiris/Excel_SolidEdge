Attribute VB_Name = "ModuleXML"
Dim ColDef As ColDefType
Private Function getSubLevel(currentLevel As String) As String
'Debug.Print currentLevel
        getSubLevel = Left(currentLevel, 1) & Left(currentLevel, Len(currentLevel) - 1) & CStr(CInt(Right(currentLevel, 1)) + 1)
End Function
Private Function getUpLevel(currentLevel As String) As String
        getUpLevel = Left(currentLevel, Len(currentLevel) - 2) & CStr(CInt(Right(currentLevel, 1)) - 1)
End Function
Private Function getUpLevelRow(ByVal currentRow As Integer) As Integer

If currentRow = ColDef.DefRow + 1 Then
    getUpLevelRow = 1
    Exit Function
End If

        Dim cLvl As Integer
        cLvl = getLvlNum(Cells(currentRow, ColDef.LvlCol).Text)
        
        Dim tLvl As Integer
        tLvl = cLvl
        
        Dim n As Integer
        n = currentRow
        
        Do Until cLvl - tLvl = 1
            n = n - 1
            tLvl = getLvlNum(Cells(n, ColDef.LvlCol).Text)
        Loop
        
        getUpLevelRow = n
        
End Function
Private Function getLvlNum(lvlStr As String) As Integer
        Dim s As Variant
        s = Split(lvlStr, ".")
        getLvlNum = CInt(s(UBound(s)))
End Function
Private Sub GetBomColumn()
Dim asht As Excel.Worksheet
If Excel.ActiveSheet Is Nothing Then Exit Sub
Set asht = Excel.ActiveSheet

Dim i&
For i = 1 To asht.UsedRange.Rows.Count
    If asht.Cells(i, 1).Text = "�㼶" Or asht.Cells(i, 1).Text = "���" Then
        ColDef.DefRow = i
        Exit For
    End If
Next

ColDef.LvlCol = 1
        
If ColDef.DefRow = 0 Then Exit Sub
For i = 1 To asht.UsedRange.Columns.Count
Select Case asht.Cells(ColDef.DefRow, i).Text
    Case "�������ϴ���", "ר�ú�", "���ϴ���"
        ColDef.CodeCol = i
    Case "��������", "��������"
        ColDef.DespCol = i
    Case "��������", "����"
        ColDef.TypeCol = i
    Case "��λ"
        ColDef.UnitCol = i
    Case "����", "��λ����", "����"
        ColDef.QtyCol = i
    Case "��λ"
        ColDef.LocCol = i
End Select

If i > 100 Then Exit For

Next

If ColDef.CodeCol = 0 Then Debug.Print "û�ҵ�ר�ú�������"
If ColDef.DespCol = 0 Then Debug.Print "û�ҵ���������������"
If ColDef.TypeCol = 0 Then Debug.Print "û�ҵ���������������"
If ColDef.UnitCol = 0 Then Debug.Print "û�ҵ���λ������"
If ColDef.QtyCol = 0 Then Debug.Print "û�ҵ���λ���������� "
If ColDef.LocCol = 0 Then Debug.Print "û�ҵ���λ������"

End Sub
Sub bom2db()
Dim oSht As Excel.Worksheet
Set oSht = Excel.ActiveSheet

Call GetBomColumn

Dim dbConn As ADODB.Connection
Dim dbRs As ADODB.Recordset

Const dbPath = "D:\Users\Personal LGP\personal Documents\code_space\qhc_k3_data.mdb"

Set dbConn = New ADODB.Connection
Set dbRs = New ADODB.Recordset

dbConn.Provider = "Microsoft.Jet.oledb.4.0"
dbConn.Open dbPath

Dim sql$

For i = ColDef.DefRow + 1 To oSht.UsedRange.Rows.Count

'���������������ĺ��ؼ���, ����[ ] �ᱨ��.
    sql = "INSERT INTO BOM ([Parent],[Item],[Description],[Type],[Unit],[Qty],[Position]) select top 1 '" & _
                oSht.Cells(getUpLevelRow(i), ColDef.CodeCol) & "','" & _
                oSht.Cells(i, ColDef.CodeCol) & "','" & _
                oSht.Cells(i, ColDef.DespCol) & "','" & _
                oSht.Cells(i, ColDef.TypeCol) & "','" & _
                oSht.Cells(i, ColDef.UnitCol) & "','" & _
                oSht.Cells(i, ColDef.QtyCol) & "','" & _
                oSht.Cells(i, ColDef.LocCol) & _
            "' FROM BOM WHERE not exists (select 1 FROM BOM WHERE [Parent]='" & oSht.Cells(getUpLevelRow(i), ColDef.CodeCol) & "' AND [Item]='" & oSht.Cells(i, ColDef.CodeCol) & "');"
   dbConn.Execute sql
   'Debug.Print sql
Next
'

'
'dbRs.Open sql, dbConn, adOpenForwardOnly, adLockOptimistic
'
'dbRs.Close
dbConn.Close



End Sub
Sub WMIReg()

Dim xValue
Dim xName
Dim xType
Dim i As Integer
Dim xStrTemp As String
Dim xWMIObj As Object

'On Error Resume Next

Const HKEY_CLASSES_ROOT = &H80000000
Const HKEY_CURRENT_USER = &H80000001
Const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_USERS = &H80000003
Const HKEY_CURRENT_CONFIG = &H80000005

Const REG_SZ = 1 '�ַ�����
Const REG_EXPAND = 2 '�������ַ�����
Const REG_BINARY = 3 '��������
Const REG_DWORD = 4 '˫�ֽ���
Const REG_MULTI_SZ = 7 '���ַ�����



Set xWMIObj = GetObject("winmgmts:\\.\root\default:StdRegProv")

'xWMIObj.CreateKey HKEY_CURRENT_USER, "MyTest\test"  '����ע����ֵ

'д��ע���
'xWMIObj.SetBinaryValue HKEY_CURRENT_USER, "MyTest\test", "test1", Array(&H0, &H0, &H1)
'xWMIObj.SetStringValue HKEY_CURRENT_USER, "MyTest\test", "test2", "2"
xWMIObj.SetDWORDValue HKEY_CLASSES_ROOT, "CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder", "FolderValueFlags", &H28
xWMIObj.SetDWORDValue HKEY_CLASSES_ROOT, "CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder", "Attributes", &HF090004D
'��ȡע���
'xWMIObj.getbinaryvalue HKEY_CURRENT_USER, "MyTest\test", "test1", xValue
'
'For i = 0 To UBound(xValue)
'  MsgBox xValue(i)
'Next

'xWMIObj.deletevalue HKEY_CURRENT_USER,"MyTest\test", "test1"

'xWMIObj.EnumValues HKEY_CURRENT_USER, "MyTest\test", xName, xType
'
'For i = 0 To UBound(xName)
'    If xType(i) = 1 Then
'            xWMIObj.Getstringvalue HKEY_CURRENT_USER, "MyTest\test", xName(i), xValue
'            MsgBox xValue
'    ElseIf xType(i) = 4 Then
'            xWMIObj.GetDWORDValue HKEY_CURRENT_USER, "MyTest\test", xName(i), xValue
'            MsgBox xValue
'    End If
'Next

'ɾ��ע���
'xWMIObj.Getstringvalue HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "DisableRegistryTools", xValue
xWMIObj.GetDWORDValue HKEY_CLASSES_ROOT, "CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder", "Attributes", xValue
Debug.Print xValue
'xWMIObj.DeleteValue HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "DisableRegistryTools"
'xWMIObj.DeleteKey HKEY_CURRENT_USER, "MyTest"

End Sub

