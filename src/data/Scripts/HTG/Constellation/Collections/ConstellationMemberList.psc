Scriptname HTG:Constellation:Collections:ConstellationMemberList extends HTG:Collections:List
import HTG:SystemLogger
import HTG:FormUtility
import HTG:IntUtility
import HTG:Collections
import HTG:Constellation:Structs

Event OnInit()
    Parent.OnInit()
    ArrayType = "ConstellationMember"
EndEvent

ConstellationMemberList Function ConstellationMemberList(Int aiSize = 4) Global
    Int aFormId = 0x00001540
    String aModName = "HTG-Regenesys-Constellation"
    Form aForm = HTG:Collections:List._CreateForm(aFormId, aModName)
    ConstellationMemberList res = HTG:Collections:List._CreateReference(aForm, aiSize) as ConstellationMemberList
    LogObjectGlobal(res, "HTG:Constellation:Collections:ConstellationMemberList.ConstellationMemberList(" + aiSize  + "): " + res)
    res.Enable(False)
    res.Initialize(aiSize)
    return res
EndFunction

ConstellationMember Function GetAt(Int index)
    return _Array[index] as ConstellationMember
EndFunction

Bool Function IsNone(Var akItem)
    If akItem is ConstellationMember
        ConstellationMember kMember = akItem as ConstellationMember
        return kMember == none || kMember.MemberRef == None
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If akItem as ConstellationMember
        return True
    EndIf
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If akArrayItem is ConstellationMember && akItem is ConstellationMember
        return akArrayItem as ConstellationMember == akItem as ConstellationMember
    EndIf
EndFunction

; Form[] Function FindActorEquipment(Actor akActor)
;     Int i = 0
;     Form[] resArray = new Form[0]

;     While i < Count
;         If !IsNone(_Array[i])
;             ConstellationMember kMember = _Array[i] as ConstellationMember
;             If kMember.MemberRef == akActor as ObjectReference
;                 resArray.Add(kMember.Clothes, 1)
;                 resArray.Add(kMember.Spacesuit, 1)
;                 resArray.Add(kMember.MemberWeapon, 1)
;             EndIf
;         EndIf
;         i += 1
;     EndWhile

;     FormArrayClean(resArray)
;     return resArray
; EndFunction

Int Function FindActor(Actor akActor)
    Int i = 0

    While i < Count
        If !IsNone(_Array[i])
            ConstellationMember kMember = _Array[i] as ConstellationMember
            If kMember.MemberRef == akActor as ObjectReference
                return i
            EndIf
        EndIf

        i += 1
    EndWhile

    return -1
EndFunction