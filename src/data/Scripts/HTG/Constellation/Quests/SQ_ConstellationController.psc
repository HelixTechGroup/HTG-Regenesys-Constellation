Scriptname HTG:Constellation:Quests:SQ_ConstellationController extends HTG:QuestExt
{Regenesys:Constellation - System Controller}
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:Collections
import HTG:Constellation:Structs
import HTG:Constellation:Collections

Group Autofill
    ObjectReference Property PlayerRef Auto Const Mandatory
    Keyword Property ShowWornItemsKeyword Auto Const Mandatory
    RefCollectionAlias Property ActiveConstellationMembers Mandatory Auto
    RefCollectionAlias Property KnownConstellationMembers Mandatory Auto
    ObjectReference Property Loot_Mannequin_Spacesuit_Female_Mark1_Lodge Const Auto Mandatory
    ActorValue Property PlayerUnityTimesEntered Const Auto Mandatory
    GlobalVariable Property FirstActivation Mandatory Auto
EndGroup

Group SystemDefaults
    ConstellationMember[] Property DefaultMemberData Const Auto Mandatory
    QuestCheckInfo[] Property RewardQuests Const Auto Mandatory
    ; ArmorSet Property ConstellationArmorSet Const Auto Mandatory
    ; LeveledArmorSet Property ConstellationLeveldArmorSet Const Auto Mandatory
    ArmorSet Property Mark1ArmorSet Const Auto Mandatory
    ; LeveledArmorSet Property Mark1LeveledArmorSet Const Auto Mandatory
EndGroup

Group LegendaryLeveledItems
    LeveledItem Property LL_Weapon_Constellation_Legendary Const Auto Mandatory
    LeveledItem Property LL_Spacesuit_Constellation_Legendary Const Auto Mandatory
    LeveledItem Property LL_Clothes_Constellation_Legendary Const Auto Mandatory
    LeveledItem Property LL_Spacesuit_Mark1_FullSet_Legendary Mandatory Const Auto
EndGroup

; Group NewMemberListInjectors
;     LeveledItemInjectionSet Property ArmorInjectorSet Mandatory Const Auto
;     LeveledItemInjectionSet Property WeaponInjectorSet Mandatory Const Auto
; EndGroup

Group Properties
    ObjectReferenceList Property InitializedMembers Auto Hidden
    ConstellationMemberList Property MemberData Auto Hidden
EndGroup

Bool _recievedArmor
Bool _recievedWeapons
Bool _recievedClothes
Bool _recievedEquipment
Bool _checkedRewards
Bool _checkedMark1

Int _initId = 1
Int _giveAllEquipmentId = 10
Int _giveWeaponsId = 11
Int _giveArmorId = 12
Int _giveClothesId = 13
Int _checkRewardsId = 14
Int _checkMark1Id = 15

Event OnQuestStarted()
    Parent.OnQuestStarted()

    If FirstActivation.GetValueInt() == 1
        If Game.GetPlayer().GetLevel() > 1
            Logger.Log("First Activation Started.")
            SetStage(_initId)
            ; RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
        Else
            Logger.Log("First Activation Skipped.")
            FirstActivation.SetValueInt(0)
        EndIf
    EndIF
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    Parent.OnStageSet(auiStageID, auiItemID)

    If auiStageID == _giveAllEquipmentId && auiItemID == 0
        Debug.Notification("Updating available Constellation member's equipment.")
        AddConstellationEquipmentToActiveMembers()
        _recievedEquipment = True
    ElseIf auiStageID == _giveWeaponsId && auiItemID == 0
        AddConstellationWeaponsToActiveMembers()
    ElseIf auiStageID == _giveArmorId && auiItemID == 0
        AddConstellationArmorToActiveMembers()
    ElseIf auiStageID == _giveClothesId && auiItemID == 0
        AddConstellationClothesToActiveMembers()
    ElseIf auiStageID == _checkedRewards && auiItemID == 0
        Debug.Notification("Updating Constellation equipment quest rewards.")
        CheckConstellationRewardQuests()
        _checkedRewards = True
    ElseIf auiStageID == _checkedMark1 && auiItemID == 0
        Debug.Notification("Updating Mark1 armor.")
        CheckMark1Armor()
        _checkedMark1 = True
    ElseIf auiStageID == _initId && auiItemID == 0
        If FirstActivation.GetValue() == 1.0 && Game.GetPlayer().GetLevel() > 1
            SetStage(_giveAllEquipmentId)
            SetStage(_checkRewardsId)
            SetStage(_checkMark1Id)
            Logger.Log("Regenesys:Constellation First Activation Completed.")
        EndIF
    EndIf
EndEvent

; Event Actor.OnPlayerLoadGame(Actor akSender)
; 	SetStage(_giveAllEquipmentId)
;     UnregisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
; EndEvent

; Function CheckActiveConstellationMembers()
;     WaitExt(0.25)
;     If MemberData && ActiveConstellationMembers

;         Logger.Log("Found ActiveConstellationMembers: " + ActiveConstellationMembers.GetCount())
;         Logger.Log("Found Constellation MemberData: " + MemberData.Length)
;         int i = MemberData.Length - 1
;         While i >= 0
;             ConstellationMemberData member = MemberData[i]
;             Actor memberActor = member.MemberRef as Actor
;             ; ActiveConstellationMembers.Find(member.MemberRef) >= 0 ||
;             If memberActor && !memberActor.IsDead()
;                 If ActiveConstellationMembers.Find(member.MemberRef) < 0 ;&& member.CompanionQuest.IsRunning(); member.CompanionQuest.GetStageDone(0) ;member.CompanionQuest.IsRunning || member.CompanionQuest.IsCompleted())
;                     Logger.Log("member.MemberName: " + member.MemberName)
;                     Logger.Log("member.CompanionQuest.IsRunning(): " + member.CompanionQuest.IsRunning())
;                     Logger.Log("member.CompanionQuest.IsCompleted(): " + member.CompanionQuest.IsCompleted())
;                     Logger.Log("member.CompanionQuest.GetStageDone(0): " + member.CompanionQuest.GetStageDone(0))

;                     If memberActor.IsPlayerTeammate()
;                         Debug.Notification("Found Active Constellation Member: " + member.MemberName)
;                         ActiveConstellationMembers.AddRef(member.MemberRef)
;                         Logger.Log("Added MemberRef to ActiveConstellationMembers: " + member.MemberName)
;                         member.MemberActor = member.MemberRef as Actor                        
;                         member.HasBeenFound = True
;                     EndIf
;                 Else
;                     If !member.MemberActor
;                         member.MemberActor = member.MemberRef as Actor                        
;                     EndIf
;                     member.HasBeenFound = True
;                 EndIf
;             Else
;                 ActiveConstellationMembers.RemoveRef(member.MemberRef)
;                 Logger.Log("Removed MemberRef to ActiveConstellationMembers: " + member.MemberName)
;                 member.HasBeenFound = False
;             EndIf
;             i -= 1
;         EndWhile
;         Logger.Log("Total found ActiveConstellationMembers: " + ActiveConstellationMembers.GetCount())
;         Debug.Notification("Total active Constellation members found: " + ActiveConstellationMembers.GetCount())
;     Else
;         Logger.Log("No Constellation MemberData Found.")
;     EndIf
; EndFunction

Function AddConstellationWeaponsToActiveMembers()
    If _recievedWeapons
        return
    EndIf

    AddConstellationEquipmentToActiveMembers(False, True, False)
EndFunction

Function AddConstellationArmorToActiveMembers()
    If _recievedArmor
        return
    EndIf

    AddConstellationEquipmentToActiveMembers(True, False, False)
EndFunction

Function AddConstellationClothesToActiveMembers()
    If _recievedClothes
        return
    EndIf

    AddConstellationEquipmentToActiveMembers(False, False, True)
EndFunction

Function AddClothesToMember(Actor actr, LeveledItem clothesList, Bool autoEquip = False)
    If !AddLeveledItemToActor(actr, clothesList, 1, True, autoEquip)
        Logger.Log("Failed to add Clothes: " + clothesList + " to Actor: " + actr)
    EndIf
EndFunction

Function AddWeaponToMember(Actor actr, LeveledItem aWeaponList, bool autoEquip = False)
    If !AddLeveledItemToActor(actr, aWeaponList, 1, True, autoEquip)
        Logger.Log("Failed to add Weapon: " + aWeaponList + " to Actor: " + actr)
    EndIf
EndFunction

Function AddArmorSetToMember(Actor actr, ArmorSet armorSet, LeveledItem aArmorList, bool autoEquip = False)
    If !AddLeveledItemToActor(actr, aArmorList, 1, True, False)
        Logger.Log("Failed to add ArmorSet: " + armorSet + " to Actor: " + actr)
    Else
        WaitExt(0.666)
        If autoEquip
            If !EquipItemToActor(actr, armorSet.Spacesuit)
                Logger.Log("Failed to equip Spacesuit: " + armorSet.Spacesuit + " to Actor: " + actr)
            EndIf
            WaitExt(0.25)
            If !EquipItemToActor(actr, armorSet.Helmet)
                Logger.Log("Failed to equip Helmet: " + armorSet.Helmet + " to Actor: " + actr)
            EndIf
            WaitExt(0.25)
            If !EquipItemToActor(actr, armorSet.Backpack)
                Logger.Log("Failed to equip Backpack: " + armorSet.Backpack + " to Actor: " + actr)
            EndIf
        EndIf
    EndIf
EndFunction

Function AddConstellationEquipmentToActiveMembers(bool addArmor = true, bool addWeapon = true, bool addClothes = true)
    If _recievedEquipment
        return
    EndIf

    If IsNone(MemberData)
        _SyncMemberData()
    EndIf

    If MemberData && ActiveConstellationMembers
        WaitExt(0.25)
        Logger.Log("Found ActiveConstellationMembers: " + ActiveConstellationMembers.GetCount())
        Logger.Log("Found Constellation MemberData: " + MemberData.Count)
        int i = MemberData.Count
        While i >= 0
            ConstellationMember member = MemberData.GetAt(i)
            If (InitializedMembers.Find(member.MemberRef) < 0 \
                && ActiveConstellationMembers.Find(member.MemberRef) >= 0)
                Actor memberActor = member.MemberRef as Actor
                AddEquipmentToMemberActor(memberActor)

                ; WaitExt(0.25)
                ; If !AddItemToActor(memberActor, member.Spacesuit, LL_Spacesuit_Constellation_Legendary, 1, True, True)
                ;     Logger.Log("Failed to add Legendary Constellation Spacesuit to member: " + member.MemberName)
                ; Else
                ;     WaitExt(0.666)
                ;     If !EquipItemToActor(memberActor, ConstellationArmorSet.Helmet)
                ;         Logger.Log("Failed to add Legendary Constellation Helmet to member: " + member.MemberName)
                ;     EndIf
                ;     WaitExt(0.25)
                ;     If !EquipItemToActor(memberActor, ConstellationArmorSet.Backpack)
                ;         Logger.Log("Failed to add Legendary Constellation Backpack to member: " + member.MemberName)
                ;     EndIf
                ; EndIf

                ; WaitExt(0.25)
                ; If !AddItemToActor(memberActor, ConstellationArmorSet.Helmet, ConstellationArmorSetLeveled.Helmet, 1, True, True)
                ;     Logger.Log("Failed to add Legendary Constellation Helmet to member: " + member.MemberName)
                ; EndIf
                ; WaitExt(0.25)
                ; If !AddItemToActor(memberActor, ConstellationArmorSet.Backpack, ConstellationArmorSetLeveled.Backpack, 1, True, True)
                ;     Logger.Log("Failed to add Legendary Constellation Backpack to member: " + member.MemberName)
                ; EndIf
                Debug.Notification(member.MemberName + " recieved Legendary Constellation equipment.")
                InitializedMembers.Add(memberActor)
            Else
                Logger.Log("Member is not currently active: " + member.MemberName)
            EndIf
            i -= 1
        EndWhile
    Else
        Logger.Log("No Constellation MemberData Found.")
    EndIf
EndFunction

Function CheckMark1Armor()
    bool equip = true
    Actor addTo = Loot_Mannequin_Spacesuit_Female_Mark1_Lodge as Actor
    If addTo.GetItemCount(Mark1ArmorSet.Spacesuit) == 0
        addTo = PlayerRef as Actor
        equip = false
    EndIf

    WaitExt(0.25)
    AddLeveledItemToActor(addto, LL_Spacesuit_Mark1_FullSet_Legendary)
    ; If !AddItemToActor(addTo, Mark1ArmorSet.Spacesuit, Mark1LeveledArmorSet.Spacesuit, 1, True, equip)
    ;     Logger.Log("Failed to add Legendary Mark 1 Spacesuit to player")
    ; EndIf
    ; WaitExt(0.25)
    ; If !AddItemToActor(addTo, Mark1ArmorSet.Helmet, Mark1LeveledArmorSet.Helmet, 1, True, equip)
    ;     Logger.Log("Failed to add Legendary Mark 1 Helmet to player")
    ; EndIf
    ; WaitExt(0.25)
    ; If !AddItemToActor(addTo, Mark1ArmorSet.Backpack, Mark1LeveledArmorSet.Backpack, 1, True, equip)
    ;     Logger.Log("Failed to add Legendary Mark 1 Backpack to player")
    ; EndIf
    If addTo == PlayerRef
        Debug.Notification("You recieved Legendary Mark 1 equipment.")
    EndIf
EndFunction

Function CheckConstellationRewardQuests()
    If RewardQuests
        bool passed = true
        int i = RewardQuests.Length - 1
        While i >= 0
            QuestCheckInfo q = RewardQuests[i]
            If (q.QuestObject.IsStageDone(q.Stage))
                If q.CompletionCheck && !q.QuestObject.IsCompleted()
                    passed = False
                EndIf
                If q.UnityCheck && !(PlayerRef.GetValue(PlayerUnityTimesEntered) >= q.UnityCheckTimes)
                    passed = False
                EndIf
            Else
                passed = False
            EndIf

            If passed
                PlayerRef.AddItem(q.RewardItem)
            EndIf
            i -= 1
        EndWhile
    EndIf
EndFunction

Function AddEquipmentToMemberActor(Actor akMemberActor, bool abAddArmor = true, bool abAddWeapon = true, bool abAddClothes = true)
    If !akMemberActor.HasKeyword(ShowWornItemsKeyword)
        akMemberActor.AddKeyword(ShowWornItemsKeyword)
    EndIf
    ; WaitExt(0.25)
    ; memberActor.SetOutfit(member.MemberOutfit)
    ; WaitExt(0.666)
    ; memberActor.SetOutfit(member.MemberSpacesuitOutfit, True)
    ; WaitExt(0.5)

    If abAddWeapon
        AddWeaponToMember(akMemberActor, LL_Weapon_Constellation_Legendary)
    EndIf
    WaitExt(0.333)
    If abAddArmor
        AddLeveledItemToActor(akMemberActor, LL_Spacesuit_Constellation_Legendary, 1, True, False)
        ; AddArmorSetToMember(memberActor, ConstellationArmorSet, LL_Spacesuit_Constellation_Legendary)
    EndIf
    WaitExt(0.333)
    If abAddClothes
        AddClothesToMember(akMemberActor, LL_Clothes_Constellation_Legendary)
    EndIf
EndFunction

Bool Function _Init()
    return Parent._Init() \
            && _InitializeMemberData()
EndFunction

Bool Function _InitializeMemberData()
    If InitializedMembers == None
        InitializedMembers = HTG:Collections:ObjectReferenceList.ObjectReferenceListIntegrated(SystemUtilities.ModInfo)
    EndIf

    If MemberData == None
        MemberData = HTG:Constellation:Collections:ConstellationMemberList.ConstellationMemberList()
        _SyncMemberData()
    EndIf

    return InitializedMembers.IsInitialized \
            && MemberData.IsInitialized
EndFunction

Function _SyncMemberData()
    Int i = 0
    Int count = DefaultMemberData.Length
    While i < count
        ConstellationMember kDefaultMember = DefaultMemberData[i]
        If MemberData.Find(kDefaultMember) < 0          
            MemberData.Add(kDefaultMember)
        EndIf
        i += 1
    EndWhile
EndFunction