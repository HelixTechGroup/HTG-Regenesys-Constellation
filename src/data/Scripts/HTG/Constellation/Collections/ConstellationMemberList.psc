Scriptname HTG:Constellation:Collections:ConstellationMemberList extends HTG:Collections:List
import HTG
import HTG:SystemLogger
import HTG:SystemFormUtility
import HTG:SystemIntUtility
import HTG:Collections
import HTG:Constellation:Structs

Event OnInit()
    Parent.OnInit()
    ArrayType = "ConstellationMember"
EndEvent

ConstellationMemberList Function ConstellationMemberList(SystemModuleInformation akMod, Int aiSize = 0) Global
    Int iFormId = 0x0000076
    String sModName = "HTG-Regenesys-Constellation-LE"
    ConstellationMemberList res =  HTG:Collections:List._CreateList(akMod, iFormId, sModName, aiSize) as ConstellationMemberList
    ; If HTG:UtilityExt.IsNone(res)
    ;     res =  HTG:Collections:List._CreateList(iFormId, aModName + "-Integrated", aiSize) as ConstellationMemberList
    ; EndIf
    LogObjectGlobal(res, "HTG:Constellation:Collections:ConstellationMemberList.ConstellationMemberList(" + aiSize  + "): " + res)
    return res
EndFunction

ConstellationMember Function GetAt(Int index)
    return GetVarAt(index) as ConstellationMember
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

Int Function _FindStruct(String asVarName, Var akElement)
    ConstellationMember[] kArray = new ConstellationMember[0]
    Int i
    Int res = -1
    While i < Count
        ConstellationMember kMember = GetAt(i)
        kArray.Add(kMember)
        i += 1
    EndWhile

    If asVarName == "MemberName"
        res = kArray.FindStruct("MemberName", akElement as String)
    ElseIf asVarName == "MemberRef"
        res = kArray.FindStruct("MemberRef", akElement as ObjectReference)
    ElseIf asVarName == "MemberWeapon"
        res = kArray.FindStruct("MemberWeapon", akElement as Weapon)
    EndIf

    kArray = None
    return res
EndFunction