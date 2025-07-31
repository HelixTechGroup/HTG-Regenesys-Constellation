Scriptname HTG:Constellation:Quests:ActiveConstellationMembers extends HTG:RefCollectionAliasExt
import HTG:Constellation:Structs

Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)

    SQ_ConstellationController kController = GetOwningQuest() as SQ_ConstellationController
    Logger.Log("Current ActiveConstellationMembers: " + GetCount())
    If !abRemove        
        Logger.Log("Found Constellation MemberData: " + kController.MemberData.Count)
        int i
        ; If !kController.Membe rData \
        ;     || kController.MemberData.Count == 0
        ;     kController._InitializeMemberData()
        ; EndIf

        While i < kController.MemberData.Count
            ConstellationMember kMember = kController.MemberData.GetAt(i)
            Actor kActorToAdd = akObject as Actor
            Actor kActor = kMember.MemberRef as Actor
            If kActorToAdd == kMember.MemberRef
                Int kCount = kActor.GetItemCount(kMember.MemberWeapon)
                If kCount > 1
                    kActor.RemoveItem(kMember.MemberWeapon)
                    If !kActor.IsEquipped(kMember.MemberWeapon)
                        kActor.EquipItem(kMember.MemberWeapon)
                    EndIf
                EndIf
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
            i += 1
        EndWhile
        Logger.Log("Total found ActiveConstellationMembers: " + GetCount())

        If Utilities.IsDebugging
            Debug.Notification("Total active Constellation members found: " + GetCount())
        EndIf
    EndIf
EndEvent

; Event OnActivate(ObjectReference akSenderRef, ObjectReference akActionRef)
; EndEvent

; Event OnLoad(ObjectReference akSenderRef)
;     ;AddActiveConstellationMembers()
; EndEvent

; Event OnAliasInit()
;     ;AddActiveConstellationMembers()
; EndEvent

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