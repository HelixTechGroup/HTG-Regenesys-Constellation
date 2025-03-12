Scriptname HTG:Constellation:Quests:ActiveConstellationMembers extends HTG:RefCollectionAliasExt
import HTG:Constellation:Structs

SQ_ConstellationController _controller = None


Event OnAliasChanged(ObjectReference akObject, bool abRemove)
    Parent.OnAliasChanged(akObject, abRemove)

    If !_controller
        _controller = GetOwningQuest() as SQ_ConstellationController
    EndIf

    ;SQ_ConstellationController kParentQuest = GetOwningQuest() as SQ_ConstellationController
    Logger.Log("Current ActiveConstellationMembers: " + GetCount())
    If abRemove        
        Logger.Log("Found Constellation MemberData: " + _controller.MemberData.Count)
        int i = _controller.MemberData.Count - 1
        While i >= 0
            ConstellationMember member = _controller.MemberData.GetAt(i)
            Actor memberActor = member.MemberRef as Actor
            If _controller.InitializedMembers.Find(memberActor) < 0
                ;&& member.CompanionQuest.IsRunning(); member.CompanionQuest.GetStageDone(0) ;member.CompanionQuest.IsRunning || member.CompanionQuest.IsCompleted())
                    Logger.Log("member.MemberName: " + member.MemberName)
                    ;Logger.Log("member.CompanionQuest.IsRunning(): " + member.CompanionQuest.IsRunning())
                    ;Logger.Log("member.CompanionQuest.IsCompleted(): " + member.CompanionQuest.IsCompleted())
                    ;Logger.Log("member.CompanionQuest.GetStageDone(0): " + member.CompanionQuest.GetStageDone(0))

                    If memberActor.IsPlayerTeammate()
                        Debug.Notification("Found Active Constellation Member: " + member.MemberName)
                        _controller.AddEquipmentToMemberActor(memberActor)
                        ;member.MemberActor = member.MemberRef as Actor                        
                        ;member.HasBeenFound = True
                    EndIf
                ; Else
                ;     If !member.MemberActor
                ;         member.MemberActor = member.MemberRef as Actor                        
                ;     EndIf
                ;     member.HasBeenFound = True
                ; EndIf
            Else
                ; RemoveRef(member.MemberRef)
                Logger.Log("Removed MemberRef to ActiveConstellationMembers: " + member.MemberName)
                ;member.HasBeenFound = False
            EndIf
            i -= 1
        EndWhile
        Logger.Log("Total found ActiveConstellationMembers: " + GetCount())
        Debug.Notification("Total active Constellation members found: " + GetCount())
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

Function _InitialRun()
    _controller = GetOwningQuest() as SQ_ConstellationController
EndFunction