Scriptname HTG:Constellation:Quests:ActiveConstellationMembers extends HTG:RefCollectionAliasExt
import HTG:Constellation:Structs
import HTG:Collections
import HTG:UtilityExt

ObjectReferenceList Property FixedMembers Auto Hidden

Guard _fixMemberWeaponGuard ProtectsFunctionLogic
Int _fixMemberWeaponTimerId = 5
Bool _fixMemberWeaponTimerStarted
ObjectReference[] _toBeFixedMembers

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)

    SQ_ConstellationController kController = GetOwningQuest() as SQ_ConstellationController
    Logger.Log("Current ActiveConstellationMembers: " + GetCount())
    If !abRemove        
        If _toBeFixedMembers.Find(akObject) < 0
            _toBeFixedMembers.Add(akObject)
            Logger.Log("Starting timer to fix member weapon: " + kController.MemberData.Count)
            StartTimer(0.1, _fixMemberWeaponTimerId)
        EndIf

        ; int i
        ; If !kController.Membe rData \
        ;     || kController.MemberData.Count == 0
        ;     kController._InitializeMemberData()
        ; EndIf

        ; While i < kController.MemberData.Count
            
        ;     i += 1
        ; EndWhile
        ; Logger.Log("Total found ActiveConstellationMembers: " + GetCount())

        If Utilities.IsDebugging
            Debug.Notification("Total active Constellation members found: " + GetCount())
        EndIf
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    Parent.OnTimer(aiTimerID)

    If aiTimerID == _fixMemberWeaponTimerId
        If _fixMemberWeaponTimerStarted || !IsInitialized
            StartTimer(0.1, _fixMemberWeaponTimerId)
        EndIf
        
        TryLockGuard _fixMemberWeaponGuard
            _fixMemberWeaponTimerStarted = True
            Int i
            While i < _toBeFixedMembers.Length
                ObjectReference kMember = _toBeFixedMembers[i]
                If !FixedMembers.Contains(kMember)
                    _FixMemberWeapon(kMember)
                    FixedMembers.Add(kMember)
                EndIf

                _toBeFixedMembers.Remove(i)
                i += 1
            EndWhile
            _fixMemberWeaponTimerStarted = True
        EndTryLockGuard
    EndIf
EndEvent

; Function AddActiveConstellationMembers(CMGU_SystemQuestScript systemQuest)
;     ;CMGU_SystemQuestScript systemQuest = GetOwningQuest() as CMGU_SystemQuestScript
;     If systemQuest.MemberData
;         int i = 0
;         While i < systemQuest.MemberData.Length
;             HTG:CMGU:Quests:CMGU_SystemQuestScript:ConstellationMemberData member = systemQuest.MemberData[i]
;             Actor memberActor = member.MemberRef as Actor
;             If !memberActor.IsDead() && (member.CompanionQuest.GetStage() > 2 || member.CompanionQuest.IsCompleted())
;                     ;AddRef(member.MemberRef)
;                     member.HasBeenFound = True
;                     Debug.Notification("Found Active Constellation Member: " + member.MemberName)
;             EndIf
            
;             i += 1
;         EndWhile
;     EndIf
; EndFunction

Bool Function _CreateCollections()
    If FixedMembers == None
        FixedMembers = HTG:Collections:ObjectReferenceList.ObjectReferenceList(Utilities.ModInfo)
    EndIf

    If _toBeFixedMembers == None
        _toBeFixedMembers = new ObjectReference[0]
    EndIf

    return (!IsNone(FixedMembers) && FixedMembers.IsInitialized)
EndFunction

Function _FixMemberWeapon(ObjectReference akMember)
    SQ_ConstellationController kController = GetOwningQuest() as SQ_ConstellationController
    Int iIndex = kController.MemberData.FindStruct("MemberRef", akMember)
    If iIndex > -1
        ConstellationMember kMember = kController.MemberData.GetAt(iIndex)
        Actor kActor = kMember.MemberRef as Actor
        Int kCount = kActor.GetItemCount(kMember.MemberWeapon)
        If kCount > 1
            Bool equipped = kActor.IsEquipped(kMember.MemberWeapon)
            kActor.RemoveItem(kMember.MemberWeapon)
            If equipped
                kActor.EquipItem(kMember.MemberWeapon)
            EndIf

            If Utilities.IsDebugging
                Debug.Notification("Fixed " + kMember.MemberName + "'s duplicate legendary weapon.")
            EndIf
            Logger.Log("Fixed " + kMember.MemberName + "'s duplicate legendary weapon.")
        Else
            If Utilities.IsDebugging
                Debug.Notification("No need to fix " + kMember.MemberName + "'s duplicate legendary weapon.")
            EndIf
        EndIf
    Else
        Logger.Log("Could not find MemberData with Reference: " + akMember)
    EndIf

;     If kController.InitializedMembers.Find(memberActor) < 0
;         ;&& member.CompanionQuest.IsRunning(); member.CompanionQuest.GetStageDone(0) ;member.CompanionQuest.IsRunning || member.CompanionQuest.IsCompleted())
;             Logger.Log("member.MemberName: " + member.MemberName)
;             ;Logger.Log("member.CompanionQuest.IsRunning(): " + member.CompanionQuest.IsRunning())
;             ;Logger.Log("member.CompanionQuest.IsCompleted(): " + member.CompanionQuest.IsCompleted())
;             ;Logger.Log("member.CompanionQuest.GetStageDone(0): " + member.CompanionQuest.GetStageDone(0))

;             If memberActor.IsPlayerTeammate()
;                 Debug.Notification("Found Active Constellation Member: " + member.MemberName)
;                 kController.AddEquipmentToMemberActor(memberActor)
;                 ;member.MemberActor = member.MemberRef as Actor                        
;                 ;member.HasBeenFound = True
;             EndIf
;         ; Else
;         ;     If !member.MemberActor
;         ;         member.MemberActor = member.MemberRef as Actor                        
;         ;     EndIf
;         ;     member.HasBeenFound = True
;         ; EndIf
;     Else
;         ; RemoveRef(member.MemberRef)
;         Logger.Log("Removed MemberRef to ActiveConstellationMembers: " + member.MemberName)
;         ;member.HasBeenFound = False
;     EndIf
EndFunction