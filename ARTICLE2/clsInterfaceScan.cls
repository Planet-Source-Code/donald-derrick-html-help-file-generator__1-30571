VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsInterfaceScan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' define counter variables
Private i As Long
Private K As Long
Private M As Long
Private W As Long
Private lngBracketCount As Long

' define file name and help context variables
Private strMemberText As String
Private varFileName As Variant
Private varFileNames As Variant
Private m_helpContextIDS() As Long
Private m_strSave As String

' define XML DOM variables
Private objDocument As MSXML2.DOMDocument30
Private objElement As MSXML2.IXMLDOMElement
Private objServer As MSXML2.IXMLDOMElement
Private objEnums As MSXML2.IXMLDOMElement
Private objEnum As MSXML2.IXMLDOMElement
Private objConstants As MSXML2.IXMLDOMElement
Private objConstant As MSXML2.IXMLDOMElement
Private objClasses As MSXML2.IXMLDOMElement
Private objclass As MSXML2.IXMLDOMElement
Private objMembers As MSXML2.IXMLDOMElement
Private objmember As MSXML2.IXMLDOMElement
Private objParameters As MSXML2.IXMLDOMElement
Private objParameter As MSXML2.IXMLDOMElement
Private objAttribute As MSXML2.IXMLDOMAttribute
Private objInterfaces As MSXML2.IXMLDOMElement
Private objInterface As MSXML2.IXMLDOMElement
Private objCollections As MSXML2.IXMLDOMElement
' define type library variables
Private objTypeLibInfo As tli.TypeLibInfo
' variants are used for for-each loops
Private objCoClassInfo As Variant
Private objInterfaceInfo As Variant
Private objSearchItem As Variant
Private objParameterInfo As Variant
Private varInterface As Variant
Private varEnum As Variant
Private varConstant As Variant
' the only public function, it requires a file name, a chosen name for the project, and an optional starting helpcontextID
Public Function InterfaceScan(ByVal strFileNames As String, ByVal strProject As String, strSave As String, Optional ByVal HelpContextID As Long = 10) As String

m_strSave = strSave
' begin by adding the information on the passed project
    Call ProjectAdd(strProject, strFileNames)
' check each file name (this function was disabled, now you can only pass one file name at a time)
    For Each varFileName In varFileNames
    ' check the servers in a file [that's the same as classes in the project]
        Call ServerAdd
        ' for each server, check each interface
        For Each varInterface In objTypeLibInfo.Interfaces
            Call InterfaceAdd
            ' for each interface, add each member
            For Each objSearchItem In varInterface.Members
                Call MembersAdd
            Next objSearchItem
            ' when done, add the interface to the connection list
            Call AddToCollections(objDocument, objCollections, objInterface)
        Next varInterface
        
        ' do the same for CoClasses [the place that events are hidden!]
        For Each varInterface In objTypeLibInfo.CoClasses
            Call InterfaceAdd
            For Each objInterfaceInfo In varInterface.Interfaces
                For Each objSearchItem In objInterfaceInfo.Members
                    Call MembersAdd
                Next objSearchItem
            Next objInterfaceInfo
            Call AddToCollections(objDocument, objCollections, objInterface)
        Next varInterface
        
        'Iterate through each enum and it's members
        Set objEnums = objDocument.createElement("ENUMS")
        objElement.selectNodes("SERVER").Item(i - 1).appendChild objEnums
        For Each varEnum In objTypeLibInfo.Constants
        Call EnumAdd
            For Each varConstant In varEnum.Members
                Call ConstantAdd
            Next varConstant
        Next varEnum
    Next varFileName
    ' when everything is scanned, save the header file
    Call SaveHeader
    Call SaveHelpFile(m_strSave & "\")
    ' save the index file
    Call SaveIndex
    ' save the table of contents
    Call SaveTableOfContents
    ' save the main file
    Call SaveMain
    ' save all the project files
    Call SaveProject(m_strSave & "\")
    Call CopyMainObjects
    
End Function
Private Function CheckIDS(ByRef HelpContextIDS() As Long, ByRef HelpContextID As Long) As Boolean
    
    ' a routine for adding new help context ids to the list of those already created.
    Dim i As Long
    
    For i = 0 To UBound(HelpContextIDS())
        If HelpContextIDS(i) = HelpContextID Then CheckIDS = True
    Next i
    
End Function
Private Function MaxIDS(ByRef HelpContextIDS() As Long) As Long

    ' a routine for adding a new id, which is 10 higher than the maximum id, for
    ' allowing access to ENUMS [which do not have help context id's for some
    ' foolish reason!]
    Dim i As Long
    Dim J As Long
    For i = 0 To UBound(HelpContextIDS())
        If HelpContextIDS(i) > J Then
        J = HelpContextIDS(i)
        End If
    Next i
    MaxIDS = J

End Function
Private Function VariableTypeName(ByRef lngVariable As Long) As String

    ' identify a variable used in a member sub, function, event or property.
    
    Select Case (lngVariable And 1) + (lngVariable And 2) + (lngVariable And 4) + (lngVariable And 8) + (lngVariable And 16) + (lngVariable And 32) + (lngVariable And 64) + (lngVariable And 128)
    Case tli.TliVarType.VT_EMPTY
            VariableTypeName = "Empty"
    Case tli.TliVarType.VT_NULL
            VariableTypeName = "Null"
    Case tli.TliVarType.VT_I2
            VariableTypeName = "Integer"
    Case tli.TliVarType.VT_I4
            VariableTypeName = "Long"
    Case tli.TliVarType.VT_R4
            VariableTypeName = "Single"
    Case tli.TliVarType.VT_R8
            VariableTypeName = "Double"
    Case tli.TliVarType.VT_CY
            VariableTypeName = "Currency"
    Case tli.TliVarType.VT_DATE
            VariableTypeName = "Date"
    Case tli.TliVarType.VT_BSTR
            VariableTypeName = "String"
    Case tli.TliVarType.VT_DISPATCH
            VariableTypeName = "Object"
    Case tli.TliVarType.VT_ERROR
            VariableTypeName = "Error"
    Case tli.TliVarType.VT_BOOL
            VariableTypeName = "Boolean"
    Case tli.TliVarType.VT_VARIANT
            VariableTypeName = "Variant"
    Case tli.TliVarType.VT_UNKNOWN
            VariableTypeName = "DataObject"
    Case tli.TliVarType.VT_DECIMAL
            VariableTypeName = "Decimal"
    Case tli.TliVarType.VT_I1
            VariableTypeName = "Byte"
    Case tli.TliVarType.VT_UI1
            VariableTypeName = "Unsigned Byte"
    Case tli.TliVarType.VT_UI2
            VariableTypeName = "Unsigned Integer"
    Case tli.TliVarType.VT_UI4
            VariableTypeName = "Unsigned Long"
    Case tli.TliVarType.VT_I8
            VariableTypeName = "GUID"
    Case tli.TliVarType.VT_UI8
            VariableTypeName = "Unsigned GUID"
    Case tli.TliVarType.VT_INT
            VariableTypeName = "Integer"
    Case tli.TliVarType.VT_UINT
            VariableTypeName = "Unsigned Integer"
    Case tli.TliVarType.VT_UI8
            VariableTypeName = "Unsigned GUID"
    Case tli.TliVarType.VT_VOID
            VariableTypeName = "No Return"
    Case tli.TliVarType.VT_HRESULT
            VariableTypeName = "HRESULT"
    Case tli.TliVarType.VT_PTR
            VariableTypeName = "PTR"
    Case tli.TliVarType.VT_SAFEARRAY
            VariableTypeName = "SAFEARRAY"
    Case tli.TliVarType.VT_CARRAY
            VariableTypeName = "CARRAY"
    Case tli.TliVarType.VT_USERDEFINED
            VariableTypeName = "User Defined Data Type"
    Case tli.TliVarType.VT_LPSTR
            VariableTypeName = "LP String"
    Case tli.TliVarType.VT_LPWSTR
            VariableTypeName = "LPW String"
    Case tli.TliVarType.VT_RECORD
            VariableTypeName = "Unsigned GUID"
    Case tli.TliVarType.VT_FILETIME
            VariableTypeName = "Time Stamp"
    Case tli.TliVarType.VT_BLOB
            VariableTypeName = "Binary Large Object Block"
    Case tli.TliVarType.VT_STREAM
            VariableTypeName = "Stream"
    Case tli.TliVarType.VT_STORAGE
            VariableTypeName = "Storage Device"
    Case tli.TliVarType.VT_STREAMED_OBJECT
            VariableTypeName = "Unsigned GUID"
    Case tli.TliVarType.VT_STORED_OBJECT
            VariableTypeName = "Unsigned GUID"
    Case tli.TliVarType.VT_BLOB_OBJECT
            VariableTypeName = "Unsigned GUID"
    Case tli.TliVarType.VT_CF
            VariableTypeName = "CF"
    Case tli.TliVarType.VT_CLSID
            VariableTypeName = "GUID"
    End Select

End Function
Private Function Reference(ByRef intReference As Long) As String

' identify a reference type, either by pointer or by value.
' for those w/o C++ backgrounds, I'll explain.
' In all member functions, [private or public] in a class
' which have parameters will receive those parameters in one of two ways
' By Value:  pass a copy of the whole parameter
' By Reference:  pass the memory location of the parameter
' By Reference parameters, when changed in the called function, stay changed
' in the calling function, By Value parameters are not changed in the calling
' function no matter what happens in the called function

    If (intReference And tli.ParamFlags.PARAMFLAG_NONE) Or intReference = 0 Then
        Reference = Reference & "Void, "
    End If
    If (intReference And tli.ParamFlags.PARAMFLAG_FIN) Then
        Reference = Reference & "input, "
    End If
    If (intReference And tli.ParamFlags.PARAMFLAG_FOUT) Then
        Reference = Reference & "output, "
    End If
    If (intReference And tli.ParamFlags.PARAMFLAG_FRETVAL) Then
        Reference = Reference & "Function, "
    End If
    
    If Reference = "input, " Then
    Reference = "ByVal"
    End If
    
    If Reference = "input, output, " Then
    Reference = "ByRef"
    End If
    
End Function
Private Function ReturnType(ByRef intReturnType As Long) As String
 
' not used
 
End Function
Private Function InvokeKind(ByRef intInvokeKind As Long, ByRef intMemberID As String, ByRef strInterfaceName As String, ByRef strReturnType As String, ByRef strMemberName As String) As String
    
    ' * confirmed

    Dim strInvokeRecommend As String
    
' first, we identify the type of call - roughly
    
    If (intInvokeKind And tli.InvokeKinds.INVOKE_UNKNOWN) Or intInvokeKind = 0 Then
        InvokeKind = InvokeKind & "Unknown, "
    End If
    If (intInvokeKind And tli.InvokeKinds.INVOKE_FUNC) Then
        InvokeKind = InvokeKind & "Sub, Function, or Event, "
    End If
    If (intInvokeKind And tli.InvokeKinds.INVOKE_PROPERTYGET) Then
        InvokeKind = InvokeKind & "Property Get, "
    End If
    If (intInvokeKind And tli.InvokeKinds.INVOKE_PROPERTYPUT) Then
        InvokeKind = InvokeKind & "Property Let, "
    End If
    If (intInvokeKind And tli.InvokeKinds.INVOKE_PROPERTYPUTREF) Then
        InvokeKind = InvokeKind & "Property Set, "
    End If
    If (intInvokeKind And tli.InvokeKinds.INVOKE_EVENTFUNC) Then
        InvokeKind = InvokeKind & "Event Function, "
    End If
    If (intInvokeKind And tli.InvokeKinds.INVOKE_CONST) Then
        InvokeKind = InvokeKind & "Constant, "
    End If
    
    InvokeKind = Left(InvokeKind, Len(InvokeKind) - 2)
    
    ' perform standard VB compilation tests for Events
    ' if the function shows up in this subset, it is an event and not a subroutine

    Dim test As Variant
    Dim test2 As Variant
    Dim bEvent As Boolean
    bEvent = False
    For Each test In objTypeLibInfo.GetTypes(, tliStEvents)
        For Each test2 In objTypeLibInfo.GetMembers(test.SearchData)
            If intMemberID = test2.MemberId And strMemberName = test2.Name Then
                InvokeKind = "Event"
            End If
        Next
    Next
        
    ' if there is a return type, the function is a function, otherwise it is a
    ' subroutine

    If InvokeKind = "Sub, Function, or Event" Then
        If strReturnType = "No Return" Then
            InvokeKind = "Sub"
        Else
            InvokeKind = "Function"
        End If
    End If
    
    ' now we know whether the function was a sub, function, event, or property.
    
End Function
Private Function OptionalValue(intReference As Long) As String

    ' is the parameter optional?
    
    If (intReference And tli.ParamFlags.PARAMFLAG_FOPT) Then
        OptionalValue = "Optional"
    Else
        OptionalValue = ""
    End If

End Function
Private Function MemberTextStart(objmember As MSXML2.IXMLDOMElement) As String

' how to display the whole sub, function, event or property.

    Select Case CStr(objmember.Attributes.getNamedItem("INVOKEKIND").nodeValue)
        
        Case "Sub"
            MemberTextStart = "Call <I>{Object_Name}." & objmember.Attributes.getNamedItem("NAME").nodeValue & "</I>("
        Case "Function"
            If (objmember.Attributes.getNamedItem("RETURNTYPE") Is Nothing) Then
                MemberTextStart = "<I>" & objmember.Attributes.getNamedItem("RETURNVARIABLETYPE").nodeValue & "_Name</I> = <I>{Object_Name}</I>." & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
            Else
               MemberTextStart = "<I>" & objmember.Attributes.getNamedItem("RETURNTYPE").nodeValue & "_Name</I> = <I>{Object_Name}</I>." & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
            End If
        Case "Property Get"
            If (objmember.Attributes.getNamedItem("RETURNTYPE") Is Nothing) Then
                MemberTextStart = "<I>" & objmember.Attributes.getNamedItem("RETURNVARIABLETYPE").nodeValue & "_Name</I> = <I>{Object_Name}.</I>" & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
            Else
                MemberTextStart = "<I>" & objmember.Attributes.getNamedItem("RETURNTYPE").nodeValue & "_Name</I> = <I>{Object_Name}.</I>" & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
            End If
        Case "Property Let"
            MemberTextStart = "<I>{Object_Name}.</I>" & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
        Case "Property Set"
            MemberTextStart = "<I>{Object_Name}.</I>" & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
        Case "Event"
            MemberTextStart = "Private Sub <I>{Object_Name}</I>_" & objmember.Attributes.getNamedItem("NAME").nodeValue & "("
    End Select

End Function
Private Function MemberTextParameter(objParameter As MSXML2.IXMLDOMElement) As String

    ' how to display the member, including parameter arrays and optional values with defaults.
    
    On Error Resume Next
    
    If CStr(objParameter.Attributes.getNamedItem("OPTIONAL").nodeValue) <> "" Then
        MemberTextParameter = CStr(objParameter.Attributes.getNamedItem("OPTIONAL").nodeValue) & " "
    End If
    'MsgBox CStr(objParameter.Attributes.getNamedItem("PARAMARRAY").nodeValue)
    If CStr(objParameter.Attributes.getNamedItem("PARAMARRAY").nodeValue) = "-1" Then
        MemberTextParameter = MemberTextParameter & "ParamArray "
    End If
    
    MemberTextParameter = MemberTextParameter & CStr(objParameter.Attributes.getNamedItem("NAME").nodeValue) & " As "
    MemberTextParameter = MemberTextParameter & CStr(objParameter.Attributes.getNamedItem("VARTYPEINFO").nodeValue)
    
    If Not (objParameter.Attributes.getNamedItem("DEFAULT").nodeValue Is Nothing) Then
        If Err.Number = 0 Then
            MemberTextParameter = " = " & CStr(objParameter.Attributes.getNamedItem("DEFAULT").nodeValue)
        Else
            Err.Clear
        End If
    End If
    
    MemberTextParameter = MemberTextParameter & ", "

End Function
Private Function MemberTextEnd(objmember As MSXML2.IXMLDOMElement) As String

' the last parts of the member function display.

Select Case CStr(objmember.Attributes.getNamedItem("INVOKEKIND").nodeValue)
    
    Case "Sub"
        MemberTextEnd = ")"
    Case "Function"
        MemberTextEnd = ")"
    Case "Property Get"
        MemberTextEnd = ")"
    Case "Property Let"
        If (objmember.Attributes.getNamedItem("RETURNTYPE") Is Nothing) Then
        MemberTextEnd = ") = <I>" & objmember.Attributes.getNamedItem("RETURNVARIABLETYPE").nodeValue & "_Name</I>"
        Else
        MemberTextEnd = ") = <I>" & objmember.Attributes.getNamedItem("RETURNTYPE").nodeValue & "_Name</I>"
        
        End If
    Case "Property Set"
        If (objmember.Attributes.getNamedItem("RETURNTYPE") Is Nothing) Then
        MemberTextEnd = ") = <I>" & objmember.Attributes.getNamedItem("RETURNVARIABLETYPE").nodeValue & "_Name</I>"
        Else
        MemberTextEnd = ") = <I>" & objmember.Attributes.getNamedItem("RETURNTYPE").nodeValue & "_Name</I>"
        
        End If
    Case "Event"
        MemberTextEnd = ")"
End Select

End Function
Private Function VariableGroupName(ByRef lngVariable As Long, ByVal Variable As String) As String

    ' * confirmed
    ' this works, but I'm not entirely sure what it is really good for!
    
    VariableGroupName = Variable
    
    If (lngVariable And tli.TliVarType.VT_VECTOR) Then
        VariableGroupName = "Vector(" & VariableGroupName & ")"
    End If
    
    If (lngVariable And tli.TliVarType.VT_ARRAY) Then
        VariableGroupName = VariableGroupName & "()"
    End If
    
    If (lngVariable And tli.TliVarType.VT_BYREF) Then
        VariableGroupName = "ByRef(" & VariableGroupName & ")"
    End If
    
    If (lngVariable And tli.TliVarType.VT_RESERVED) Then
        VariableGroupName = "Reserved(" & VariableGroupName & ")"
    End If

End Function
Private Sub AddToCollections(ByRef objDocument As MSXML2.DOMDocument30, ByRef objCollections As MSXML2.IXMLDOMElement, objInterface As MSXML2.IXMLDOMElement)

' add interfaces and coclasses to the collections list in the TOC

    Dim objFilter As MSXML2.IXMLDOMNodeList
    Dim objCollection As MSXML2.IXMLDOMElement
    Dim objAttribute As MSXML2.IXMLDOMAttribute
    Dim bTest As Boolean
    
' run a series of tests to make sure that this entry is not already on the list of
' connections
    
    If objCollections.childNodes.length > 0 Then
        Set objFilter = objCollections.selectNodes("COLLECTION[@NAME='" & Replace(objInterface.Attributes.getNamedItem("NAME").nodeValue, "_", "") & "']")
    End If
    
    If (objFilter Is Nothing) Then
        bTest = True
    End If
    If bTest = False Then
        If objFilter.length = 0 Then
            bTest = True
        End If
    End If
    
' if it is not in the list, add it
    
    If bTest = True Then
    ' create a collection element
        Set objCollection = objDocument.createElement("COLLECTION")
        ' add the name w/o underscores [which show up automatically in CoClass names!]
        Set objAttribute = objDocument.createAttribute("NAME")
        objAttribute.nodeValue = Replace(objInterface.Attributes.getNamedItem("NAME").nodeValue, "_", "")
        objCollection.Attributes.setNamedItem objAttribute
        ' add the help context id
        Set objAttribute = objDocument.createAttribute("HELPCONTEXTID")
        objAttribute.nodeValue = objInterface.Attributes.getNamedItem("HELPCONTEXTID").nodeValue
        ' add the help context ID to the collection needed to make enums useful
        If Not CheckIDS(m_helpContextIDS(), objAttribute.Value) Then
            ReDim Preserve m_helpContextIDS(UBound(m_helpContextIDS) + 1)
            m_helpContextIDS(UBound(m_helpContextIDS)) = objAttribute.nodeValue
        End If
        ' add the help string
        objCollection.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("HELPSTRING")
        objAttribute.nodeValue = objInterface.Attributes.getNamedItem("HELPSTRING").nodeValue
        objCollection.Attributes.setNamedItem objAttribute
        ' add an empty description and level for use in a program designed to edit
        ' the html help outlines.
        Set objAttribute = objDocument.createAttribute("DESCRIPTION")
        objAttribute.nodeValue = ""
        objCollection.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("LEVEL")
        objAttribute.nodeValue = "0"
        objCollection.Attributes.setNamedItem objAttribute
        objCollections.appendChild objCollection
    End If

End Sub
Private Sub AlterCollections(objDocument As DOMDocument30, objCollections As IXMLDOMElement)


' not used
Dim objFilter As MSXML2.IXMLDOMNodeList
'Set objFilter = objDocument.selectNodes("//MEMBER[@RETURNTYPE]")

End Sub
Private Sub InterfaceAdd()
        ' add the class title if there is no title of same name in the list.
    If (objDocument.selectNodes("PROJECT/SERVER/INTERFACES/INTERFACE[@NAME='" & Replace(varInterface.Name, "_", "") & "']").length = 0) Then
        ' name the interface, and remove underscores.
        Set objInterface = objDocument.createElement("INTERFACE")
        Set objAttribute = objDocument.createAttribute("NAME")
        objAttribute.nodeValue = Replace(varInterface.Name, "_", "")
        objInterface.Attributes.setNamedItem objAttribute
        ' set an empty space for a description
        Set objAttribute = objDocument.createAttribute("DESCRIPTION")
        objAttribute.nodeValue = ""
        objInterface.Attributes.setNamedItem objAttribute
        ' set classID, type kind, help strings and help context ID's
        Set objAttribute = objDocument.createAttribute("CLASSID")
        objAttribute.nodeValue = varInterface.Guid
        objInterface.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("TYPEKIND")
        objAttribute.nodeValue = varInterface.TypeKindString
        objInterface.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("HELPSTRING")
        objAttribute.nodeValue = varInterface.HelpString
        objInterface.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("HELPCONTEXTID")
        objAttribute.nodeValue = varInterface.HelpContext
        
        If Not CheckIDS(m_helpContextIDS(), objAttribute.Value) Then
            ReDim Preserve m_helpContextIDS(UBound(m_helpContextIDS) + 1)
            m_helpContextIDS(UBound(m_helpContextIDS)) = objAttribute.nodeValue
        End If
        ' append in the right location
        objInterface.Attributes.setNamedItem objAttribute
        objElement.selectNodes("SERVER/INTERFACES").Item(i - 1).appendChild objInterface
        Set objMembers = objDocument.createElement("MEMBERS")
        objElement.selectNodes("SERVER/INTERFACES/INTERFACE").Item(K).appendChild objMembers
        K = K + 1
    End If
End Sub
Private Sub MembersAdd()

' add the members, but do NOT add COM standard interfaces or previously added interfaces
    If objSearchItem.Name <> "QueryInterface" And _
    objSearchItem.Name <> "AddRef" And _
    objSearchItem.Name <> "Release" And _
    objSearchItem.Name <> "GetTypeInfoCount" And _
    objSearchItem.Name <> "GetTypeInfo" And _
    objSearchItem.Name <> "GetIDsOfNames" And _
    objSearchItem.Name <> "Invoke" And _
    objDocument.selectNodes("PROJECT/SERVER/INTERFACES/INTERFACE[@NAME='" _
    & Replace(varInterface.Name, "_", "") & "']/MEMBERS/MEMBER[@NAME='" & _
    objSearchItem.Name & "' and @INVOKEKIND='" & _
    InvokeKind(objSearchItem.InvokeKind, Hex$(objSearchItem.MemberId), _
    varInterface.Name, VariableGroupName(objSearchItem.ReturnType, _
    VariableTypeName(objSearchItem.ReturnType)), objSearchItem.Name) & "']").length = 0 _
    Then
        ' add the member title
        Set objmember = objDocument.createElement("MEMBER")
        Set objAttribute = objDocument.createAttribute("NAME")
        objAttribute.nodeValue = objSearchItem.Name
        objmember.Attributes.setNamedItem objAttribute
        ' add blank space for a description header and footer
        Set objAttribute = objDocument.createAttribute("DESCRIPTIONHEADER")
        objAttribute.nodeValue = ""
        objmember.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("DESCRIPTIONFOOTER")
        objAttribute.nodeValue = ""
        objmember.Attributes.setNamedItem objAttribute
        ' add the member id
        Set objAttribute = objDocument.createAttribute("MEMBERID")
        objAttribute.nodeValue = Hex$(objSearchItem.MemberId)
        objmember.Attributes.setNamedItem objAttribute
        ' add the help string
        Set objAttribute = objDocument.createAttribute("HELPSTRING")
        objAttribute.nodeValue = objSearchItem.HelpString
        objmember.Attributes.setNamedItem objAttribute
        ' id the variable type of the return variable, including VOID for subroutines.
        Set objAttribute = objDocument.createAttribute("VARTYPEINFO")
        objAttribute.nodeValue = VariableGroupName(objSearchItem.ReturnType, VariableTypeName(objSearchItem.ReturnType))
        objmember.Attributes.setNamedItem objAttribute
        If Not (objSearchItem.ReturnType.TypeInfo Is Nothing) Then
            Set objAttribute = objDocument.createAttribute("RETURNTYPE")
            objAttribute.nodeValue = objSearchItem.ReturnType.TypeInfo
            objmember.Attributes.setNamedItem objAttribute
        End If
        Set objAttribute = objDocument.createAttribute("RETURNVARIABLETYPE")
        objAttribute.nodeValue = VariableGroupName(objSearchItem.ReturnType.VarType, VariableTypeName(objSearchItem.ReturnType.VarType))
        objmember.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("INVOKEKIND")
        objAttribute.nodeValue = InvokeKind(objSearchItem.InvokeKind, Hex$(objSearchItem.MemberId), varInterface.Name, VariableGroupName(objSearchItem.ReturnType, VariableTypeName(objSearchItem.ReturnType)), objSearchItem.Name)
        objmember.Attributes.setNamedItem objAttribute
        
        Set objAttribute = objDocument.createAttribute("HELPCONTEXTID")
        objAttribute.nodeValue = objSearchItem.HelpContext
  
        If Not CheckIDS(m_helpContextIDS(), objAttribute.Value) Then
            ReDim Preserve m_helpContextIDS(UBound(m_helpContextIDS) + 1)
            m_helpContextIDS(UBound(m_helpContextIDS)) = objAttribute.nodeValue
        End If
  
        objmember.Attributes.setNamedItem objAttribute
        ' place in the DOM object properly
        objElement.selectSingleNode("SERVER/INTERFACES/INTERFACE[@NAME='" _
        & Replace(varInterface.Name, "_", "") & "']/MEMBERS").appendChild objmember
        Set objParameters = objDocument.createElement("PARAMETERS")
        objElement.selectSingleNode("SERVER/INTERFACES/INTERFACE[@NAME='" _
        & Replace(varInterface.Name, "_", "") & "']/MEMBERS/MEMBER[@NAME='" & _
    objSearchItem.Name & "' and @INVOKEKIND='" & _
    InvokeKind(objSearchItem.InvokeKind, Hex$(objSearchItem.MemberId), _
    varInterface.Name, VariableGroupName(objSearchItem.ReturnType, _
    VariableTypeName(objSearchItem.ReturnType)), objSearchItem.Name) & "']").appendChild objParameters
        M = M + 1
        ' Use objMember to begin the member string
        strMemberText = MemberTextStart(objmember)
        ' add parameters
        For Each objParameterInfo In objSearchItem.Parameters
            Call ParameterAdd
        Next
        If Right(strMemberText, 2) = ", " Then
            strMemberText = Left(strMemberText, Len(strMemberText) - 2)
        End If
        strMemberText = strMemberText & MemberTextEnd(objmember)
        Set objAttribute = objDocument.createAttribute("STRING")
        objAttribute.nodeValue = strMemberText
        objmember.Attributes.setNamedItem objAttribute
    End If
End Sub
Private Sub ServerAdd()

    Set objTypeLibInfo = tli.TypeLibInfoFromFile(CStr(varFileName))
    objTypeLibInfo.SearchDefault = tliStConstants
    Set objServer = objDocument.createElement("SERVER")
    ' add the name of the server
    
    Set objAttribute = objDocument.createAttribute("NAME")
    objAttribute.nodeValue = objTypeLibInfo.Name
    objServer.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTION")
    objAttribute.nodeValue = ""
    objServer.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("UUID")
    objAttribute.nodeValue = objTypeLibInfo.Guid
    objServer.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("MAJORVERSION")
    objAttribute.nodeValue = objTypeLibInfo.MajorVersion
    objServer.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("MINORVERSION")
    objAttribute.nodeValue = objTypeLibInfo.MinorVersion
    objServer.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("HELPSTRING")
    objAttribute.nodeValue = objTypeLibInfo.HelpString
    objServer.Attributes.setNamedItem objAttribute
    
    ' add the help context id
    
    Set objAttribute = objDocument.createAttribute("HELPCONTEXTID")
    objAttribute.nodeValue = objTypeLibInfo.HelpContext
    
    If Not CheckIDS(m_helpContextIDS(), objAttribute.Value) Then
        ReDim Preserve m_helpContextIDS(UBound(m_helpContextIDS))
        m_helpContextIDS(UBound(m_helpContextIDS)) = objAttribute.nodeValue
    End If
    
    objServer.Attributes.setNamedItem objAttribute
    objElement.appendChild objServer
    
    ' Create the initial collection object to be populated as the server is
    ' worked on
    
    Set objCollections = objDocument.createElement("COLLECTIONS")
    objServer.appendChild objCollections
    
    ' set the classes title
    Set objInterfaces = objDocument.createElement("INTERFACES")
    objElement.selectNodes("SERVER").Item(i).appendChild objInterfaces
    i = i + 1

End Sub
Private Sub ProjectAdd(strProject As String, strFileNames As String)
    ' set the opening values of the DOM object
    Set objDocument = CreateObject("MSXML2.DOMDocument.3.0")
    Set objElement = objDocument.createElement("PROJECT")
    Set objDocument.documentElement = objElement
    Set objAttribute = objDocument.createAttribute("NAME")
    objAttribute.nodeValue = strProject
    objElement.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTIONHEADER")
    objAttribute.nodeValue = "Main Project"
    objElement.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTIONFOOTER")
    objAttribute.nodeValue = "Main Project"
    objElement.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("HELPCONTEXTID")
    objAttribute.nodeValue = "0"
    objElement.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("FILTERHELPCONTEXTID")
    objAttribute.nodeValue = "0"
    objElement.Attributes.setNamedItem objAttribute
    ' take a joined string of file names and split it into an array
    varFileNames = Split(strFileNames, ", ")
    ' take each file name in the array and scan each typelib
End Sub
Private Sub EnumAdd()

    Set objEnum = objDocument.createElement("ENUM")
    Set objAttribute = objDocument.createAttribute("NAME")
    objAttribute.nodeValue = varEnum.Name
    objEnum.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("HELPCONTEXTID")
    objAttribute.nodeValue = MaxIDS(m_helpContextIDS()) + 10
    ReDim Preserve m_helpContextIDS(UBound(m_helpContextIDS) + 1)
    m_helpContextIDS(UBound(m_helpContextIDS)) = objAttribute.nodeValue
    objEnum.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTIONHEADER")
    objAttribute.nodeValue = ""
    objEnum.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTIONFOOTER")
    objAttribute.nodeValue = ""
    objEnum.Attributes.setNamedItem objAttribute
    objElement.selectNodes("SERVER/ENUMS").Item(i - 1).appendChild objEnum
    Set objConstants = objDocument.createElement("CONSTANTS")
    objElement.selectNodes("SERVER/ENUMS/ENUM").Item(W).appendChild objConstants
    W = W + 1

End Sub
Private Sub ConstantAdd()

    Set objConstant = objDocument.createElement("CONSTANT")
    Set objAttribute = objDocument.createAttribute("NAME")
    objAttribute.nodeValue = varConstant.Name
    objConstant.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTION")
    objAttribute.nodeValue = ""
    objConstant.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("VALUE")
    objAttribute.nodeValue = varConstant.Value
    objConstant.Attributes.setNamedItem objAttribute
    objElement.selectNodes("SERVER/ENUMS/ENUM/CONSTANTS").Item(W - 1).appendChild objConstant

End Sub
Private Sub ParameterAdd()

    Set objParameter = objDocument.createElement("PARAMETER")
    Set objAttribute = objDocument.createAttribute("NAME")
    objAttribute.nodeValue = objParameterInfo.Name
    objParameter.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("DESCRIPTION")
    objAttribute.nodeValue = ""
    objParameter.Attributes.setNamedItem objAttribute
    If Not (objParameterInfo.VarTypeInfo.TypeInfo Is Nothing) Then
        Set objAttribute = objDocument.createAttribute("VARTYPEINFO")
        objAttribute.nodeValue = VariableGroupName(objParameterInfo.VarTypeInfo, Replace(objParameterInfo.VarTypeInfo.TypeInfo.Name, "_", ""))
        objParameter.Attributes.setNamedItem objAttribute
        Set objAttribute = objDocument.createAttribute("INTERFACE")
        objAttribute.nodeValue = objParameterInfo.VarTypeInfo.TypeInfo.TypeKindString
        objParameter.Attributes.setNamedItem objAttribute
    Else
        Set objAttribute = objDocument.createAttribute("VARTYPEINFO")
        objAttribute.nodeValue = VariableGroupName(objParameterInfo.VarTypeInfo, VariableTypeName(objParameterInfo.VarTypeInfo))
        objParameter.Attributes.setNamedItem objAttribute
    End If
    
    Set objAttribute = objDocument.createAttribute("REFERENCE")
    objAttribute.nodeValue = Reference(objParameterInfo.Flags)
    objParameter.Attributes.setNamedItem objAttribute
    If objParameterInfo.Default = True Then
        Set objAttribute = objDocument.createAttribute("DEFAULT")
        objAttribute.nodeValue = objParameterInfo.DefaultValue
        objParameter.Attributes.setNamedItem objAttribute
    End If
    Set objAttribute = objDocument.createAttribute("OPTIONAL")
    objAttribute.nodeValue = OptionalValue(objParameterInfo.Flags)
    objParameter.Attributes.setNamedItem objAttribute
    Set objAttribute = objDocument.createAttribute("PARAMARRAY")
    objAttribute.nodeValue = objParameterInfo.Optional
    objParameter.Attributes.setNamedItem objAttribute
    objElement.selectSingleNode("SERVER/INTERFACES/INTERFACE[@NAME='" _
    & Replace(varInterface.Name, "_", "") & "']/MEMBERS/MEMBER[@NAME='" & _
    objSearchItem.Name & "' and @INVOKEKIND='" & _
    InvokeKind(objSearchItem.InvokeKind, Hex$(objSearchItem.MemberId), _
    varInterface.Name, VariableGroupName(objSearchItem.ReturnType, _
    VariableTypeName(objSearchItem.ReturnType)), objSearchItem.Name) & "']/PARAMETERS").appendChild objParameter
    objElement.selectNodes("SERVER/INTERFACES/INTERFACE/MEMBERS/MEMBER/PARAMETERS").Item(M - 1).appendChild objParameter
    strMemberText = strMemberText & MemberTextParameter(objParameter)

End Sub

Private Sub SaveProject(strFile As String)

'    Call AlterCollections(objDocument, objCollections)
    objDocument.save (strFile & "\html\typelib.xml")
    'MsgBox objDocument.xml

End Sub
Private Sub SaveHeader()

Call SaveFiles(m_strSave & "\header.h", App.Path & "\header.xsl")

End Sub
Private Sub SaveIndex()

    Call SaveFiles(m_strSave & "\Index.hhk", App.Path & "\index.xsl")

End Sub
Private Sub SaveTableOfContents()

    Call SaveFiles(m_strSave & "\TableOfContents.hhc", App.Path & "\tableOfContents.xsl")

End Sub
Private Sub SaveMain()

    Call SaveFiles(m_strSave & "\" & objDocument.selectSingleNode("PROJECT").Attributes.getNamedItem("NAME").nodeValue & ".hhp", App.Path & "\main.xsl")

End Sub
Private Sub SaveHelpFile(strFile As String)

    Dim objFileSystem As Scripting.FileSystemObject
    Dim objHTMLTemplate As MSXML2.DOMDocument30
    Dim strhold As String
    Dim strFileLocation As String
    Set objHTMLTemplate = CreateObject("MSXML2.DOMDocument.3.0")
    Set objFileSystem = CreateObject("Scripting.FileSystemObject")
    objHTMLTemplate.Load (App.Path & "\htmltemplate.xsl")
    Dim varAttribute As Variant
    If Not (objFileSystem.FolderExists(strFile & "\html")) Then
        objFileSystem.CreateFolder (strFile & "\html")
    End If
    For Each varAttribute In objDocument.selectNodes("//")
        If Not (varAttribute.Attributes.getNamedItem("HELPCONTEXTID") Is Nothing) Then
            'MsgBox varAttribute.Attributes.getNamedItem("HELPCONTEXTID").nodeValue
            objDocument.selectSingleNode("PROJECT").Attributes.getNamedItem("FILTERHELPCONTEXTID").nodeValue = varAttribute.Attributes.getNamedItem("HELPCONTEXTID").nodeValue
            strhold = objDocument.transformNode(objHTMLTemplate)
            strFileLocation = strFile & "\html\IDH_" & varAttribute.Attributes.getNamedItem("HELPCONTEXTID").nodeValue & ".htm"
            objFileSystem.CreateTextFile strFileLocation, True, False
            objFileSystem.OpenTextFile(strFileLocation, ForWriting, True).Write (strhold)
        End If
    Next

End Sub
Private Sub SaveFiles(fileLocation As String, fileXSL As String)

    Dim objTableOfContents As MSXML2.DOMDocument30
    Dim strhold As String
    Dim objFileSystem As Scripting.FileSystemObject
    Set objTableOfContents = CreateObject("MSXML2.DOMDocument.3.0")
    objTableOfContents.Load (fileXSL)
    strhold = objDocument.transformNode(objTableOfContents)
    Set objFileSystem = CreateObject("Scripting.FileSystemObject")
    objFileSystem.CreateTextFile fileLocation, True, False
    objFileSystem.OpenTextFile(fileLocation, ForWriting, True).Write (strhold)

End Sub

Private Sub Class_Initialize()

    ReDim m_helpContextIDS(0)

End Sub
Private Sub CopyMainObjects()

Dim objFileSystem As Scripting.FileSystemObject
Set objFileSystem = CreateObject("Scripting.FileSystemObject")
objFileSystem.CopyFile App.Path & "\typelib.xsl", m_strSave & "\html\typelib.xsl", True
objFileSystem.CopyFile App.Path & "\typelibfunctions.js", m_strSave & "\html\typelibfunctions.js", True
objFileSystem.CopyFile App.Path & "\typelib.css", m_strSave & "\html\typelib.css", True
objFileSystem.CopyFile App.Path & "\downarrow.gif", m_strSave & "\html\downarrow.gif", True
objFileSystem.CopyFile App.Path & "\rightarrow.gif", m_strSave & "\html\rightarrow.gif", True

End Sub
