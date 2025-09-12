Scriptname HTG:Constellation:Quests:SQ_ConstellationController extends HTG:QuestExt
{Regenesys:Constellation - System Controller}
import HTG
import HTG:Structs
import HTG:UtilityExt
import HTG:Collections
import HTG:Constellation:Structs
import HTG:Constellation:Collections
import Utility

Group Autofill
    ObjectReference Property PlayerRef Mandatory Const Auto
    Keyword Property ShowWornItemsKeyword Mandatory Const Auto
    RefCollectionAlias Property ActiveConstellationMembers Mandatory Const Auto
    RefCollectionAlias Property AvailableConstellationMembers Mandatory Const Auto
    RefCollectionAlias Property KnownConstellationMembers Mandatory Const Auto
    ObjectReference Property Loot_Mannequin_Spacesuit_Female_Mark1_Lodge Mandatory Const Auto
    ActorValue Property PlayerUnityTimesEntered Mandatory Const Auto
    GlobalVariable Property FirstActivation Mandatory Auto
EndGroup

Group SystemDefaults
    Bool Property MidgameInstall Auto Hidden
    ConstellationMember[] Property DefaultMemberData Mandatory Const Auto
    QuestCheckInfo[] Property RewardQuests Mandatory Const Auto
    ArmorSet Property NonPlayableConstellationArmorSet Mandatory Const Auto
    ArmorSet Property PlayableConstellationArmorSet Mandatory Const Auto
    ; LeveledArmorSet Property ConstellationLeveldArmorSet Mandatory Const Auto
    ArmorSet Property Mark1ArmorSet Mandatory Const Auto
    ; LeveledArmorSet Property Mark1LeveledArmorSet Mandatory Const Auto
EndGroup

Group LegendaryLeveledItems
    LeveledItem Property LL_Weapon_Constellation_Legendary Mandatory Const Auto
    LeveledItem Property LL_Armor_Constellation_Legendary Mandatory Const Auto
    LeveledItem Property LL_Clothes_Constellation_Legendary Mandatory Const Auto
    LeveledItem Property LL_Spacesuit_Mark1_FullSet_Legendary Mandatory Const Auto
EndGroup

Message Property ServiceEnabled Mandatory Const Auto

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
        Logger.Log("First Activation Started.")
        SetStage(_initId)
        ; RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
    EndIf

    Int i = RewardQuests.FindStruct("QuestName", "MQ101")
    If i > -1
        QuestCheckInfo kQuestInfo = RewardQuests[i]
        If !kQuestInfo.QuestObject.IsStageDone(kQuestInfo.Stage)
            RegisterForRemoteEvent(kQuestInfo.QuestObject, "OnStageSet")
        EndIf
    EndIf

    ServiceEnabled.Show()
    ; Debug.Notification("Legendary Constellation Equipment has been Enabled")
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    Parent.OnStageSet(auiStageID, auiItemID)

    If auiStageID == _giveAllEquipmentId && auiItemID == 0
        Debug.Notification("Updating available Constellation member's equipment.")
        AddConstellationEquipmentToAvailableMembers()
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
        If FirstActivation.GetValue() == 1.0
            Actor kActor = PlayerRef as Actor
            If (ActiveConstellationMembers.GetCount() > 0 \
                || AvailableConstellationMembers.GetCount() > 0) \
                || !Utilities.IsNewGame
                SetStage(_giveAllEquipmentId)
                ; && kActor.GetLevel() > 1 || 
            EndIf

            SetStage(_checkRewardsId)
            SetStage(_checkMark1Id)
            Logger.Log("Regenesys:Constellation First Activation Completed.")
        EndIF
    EndIf
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
	If FirstActivation.GetValueInt() == 1
        If ActiveConstellationMembers.GetCount() > 0 || Game.GetPlayer().GetLevel() > 1
            Logger.Log("First Activation Started.")
            SetStage(_initId)
            ; RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
        Else
            Logger.Log("First Activation Skipped.")
            FirstActivation.SetValueInt(0)
        EndIf
    EndIF

    UnregisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
EndEvent

Event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)
    WaitForInitialized()

    ; MQ101 has no leveled list for its reward so we have to add it here as it does not like when i add it into the quest directly 
    ; (assuming this is due to a diffefence in master types?)
    ; I did remove the vanilla backpack reward from the quest reward as to now worry about that functionality here.
    Int i = RewardQuests.FindStruct("QuestName", "MQ101")
    If i > -1
        QuestCheckInfo kQuestInfo = RewardQuests[i]
        If (akSender == kQuestInfo.QuestObject) && auiStageID == kQuestInfo.Stage
            If kQuestInfo.UnityCheck \
                && !(PlayerRef.GetValue(PlayerUnityTimesEntered) >= kQuestInfo.UnityCheckTimes)
                return
            EndIf

            PlayerRef.AddItem(kQuestInfo.RewardItem)

            UnregisterForRemoteEvent(kQuestInfo.QuestObject, "OnStageSet")
        EndIf
    EndIf
EndEvent

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
    WaitForInitialized()

    If _recievedWeapons
        return
    EndIf

    AddConstellationEquipmentToAvailableMembers(False, True, False)
EndFunction

Function AddConstellationArmorToActiveMembers()
    WaitForInitialized()

    If _recievedArmor
        return
    EndIf

    AddConstellationEquipmentToAvailableMembers(True, False, False)
EndFunction

Function AddConstellationClothesToActiveMembers()
    WaitForInitialized()

    If _recievedClothes
        return
    EndIf

    AddConstellationEquipmentToAvailableMembers(False, False, True)
EndFunction

Function AddClothesToMember(ConstellationMember akMember,  LeveledItem clothesList, Bool autoEquip = False)
    WaitForInitialized()

    Actor kActor = akMember.MemberRef as Actor
    If !AddLeveledItemToActor(kActor, clothesList, akMember.MemberClothesPlayable, 1, True, autoEquip)
        Logger.Log("Failed to add Clothes: " + clothesList + " to Actor: " + kActor)
    EndIf

    If !IsNone(akMember.MemberHatPlayable) && kActor.GetItemCount(akMember.MemberHatPlayable) > 0
        kActor.EquipItem(akMember.MemberHatPlayable)
    EndIf
EndFunction

Function AddWeaponToMember(ConstellationMember akMember,  LeveledItem aWeaponList, bool autoEquip = False)
    WaitForInitialized()

    Actor kActor = akMember.MemberRef as Actor
    If !AddLeveledItemToActor(kActor, aWeaponList, akMember.MemberWeapon, 1, True, autoEquip)
        Logger.Log("Failed to add Weapon: " + aWeaponList + " to Actor: " + kActor)
    EndIf
EndFunction

Function AddArmorSetToMember(ConstellationMember akMember, ArmorSet armorSet, LeveledItem aArmorList, bool autoEquip = False)
    WaitForInitialized()

    Actor kActor = akMember.MemberRef as Actor
    If !AddLeveledItemToActor(kActor, aArmorList)
        Logger.Log("Failed to add ArmorSet: " + armorSet + " to Actor: " + kActor)
    Else
        WaitExt(0.666)
        If autoEquip
            If !EquipItemToActor(kActor, akMember.MemberSpacesuit)
                Logger.Log("Failed to equip Spacesuit: " + armorSet.Spacesuit + " to Actor: " + kActor)
            EndIf
            WaitExt(0.25)
            If !EquipItemToActor(kActor, armorSet.Helmet)
                Logger.Log("Failed to equip Helmet: " + armorSet.Helmet + " to Actor: " + kActor)
            EndIf
            WaitExt(0.25)
            If !EquipItemToActor(kActor, armorSet.Backpack)
                Logger.Log("Failed to equip Backpack: " + armorSet.Backpack + " to Actor: " + kActor)
            EndIf
        EndIf
    EndIf
EndFunction

Function AddConstellationEquipmentToAvailableMembers(bool addArmor = true, bool addWeapon = true, bool addClothes = true)
    WaitForInitialized()

    If _recievedEquipment
        return
    EndIf

    If !IsNone(MemberData)
        ; WaitExt(0.25)
        Logger.Log("Found ActiveConstellationMembers: " + ActiveConstellationMembers.GetCount())
        Logger.Log("Found AvailableConstellationMembers: " + AvailableConstellationMembers.GetCount())
        Logger.Log("Found Constellation MemberData: " + MemberData.Count)
        int i
        While i < MemberData.Count
            ConstellationMember kMember = MemberData.GetAt(i)
            If (InitializedMembers.Find(kMember.MemberRef) < 0 \
                && AvailableConstellationMembers.Find(kMember.MemberRef) >= 0)
                ; Actor memberActor = member.MemberRef as Actor
                _ClearExistingEquipment(kMember, NonPlayableConstellationArmorSet)
                Wait(0.25)
                AddEquipmentToMember(kMember)

                ; WaitExt(0.25)
                ; If !AddItemToActor(memberActor, member.Spacesuit, LL_Armor_Constellation_Legendary, 1, True, True)
                ;     Logger.Log("Failed to add Legendary Constellation Spacesuit to member: " + member.MemberName)
                ; Else
                ;     WaitExt(0.666)
                ;     If !EquipItemToActor(memberActor, NonPlayableConstellationArmorSet.Helmet)
                ;         Logger.Log("Failed to add Legendary Constellation Helmet to member: " + member.MemberName)
                ;     EndIf
                ;     WaitExt(0.25)
                ;     If !EquipItemToActor(memberActor, NonPlayableConstellationArmorSet.Backpack)
                ;         Logger.Log("Failed to add Legendary Constellation Backpack to member: " + member.MemberName)
                ;     EndIf
                ; EndIf

                ; WaitExt(0.25)
                ; If !AddItemToActor(memberActor, NonPlayableConstellationArmorSet.Helmet, ConstellationArmorSetLeveled.Helmet, 1, True, True)
                ;     Logger.Log("Failed to add Legendary Constellation Helmet to member: " + member.MemberName)
                ; EndIf
                ; WaitExt(0.25)
                ; If !AddItemToActor(memberActor, NonPlayableConstellationArmorSet.Backpack, ConstellationArmorSetLeveled.Backpack, 1, True, True)
                ;     Logger.Log("Failed to add Legendary Constellation Backpack to member: " + member.MemberName)
                ; EndIf
                Debug.Notification(kMember.MemberName + " recieved Legendary Constellation equipment.")
                InitializedMembers.Add(kMember.MemberRef)
            Else
                Logger.Log("Member is not currently active: " + kMember.MemberName)
            EndIf

            i += 1
        EndWhile
    Else
        Logger.Log("No Constellation MemberData Found.")
    EndIf
EndFunction

Function CheckMark1Armor()
    WaitForInitialized()

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
    WaitForInitialized()

    If RewardQuests
        bool passed = true
        int i
        While i < RewardQuests.Length
            QuestCheckInfo kQuestInfo = RewardQuests[i]
            If (kQuestInfo.QuestObject.IsStageDone(kQuestInfo.Stage))
                If kQuestInfo.CompletionCheck && !kQuestInfo.QuestObject.IsCompleted()
                    passed = False
                EndIf
                If kQuestInfo.UnityCheck && !(PlayerRef.GetValue(PlayerUnityTimesEntered) >= kQuestInfo.UnityCheckTimes)
                    passed = False
                EndIf
            Else
                passed = False
            EndIf

            If passed
                PlayerRef.AddItem(kQuestInfo.RewardItem)
            EndIf
            i += 1
        EndWhile
    EndIf
EndFunction

Function AddEquipmentToMember(ConstellationMember akMember, bool abAddArmor = true, bool abAddWeapon = true, bool abAddClothes = true)
    Actor kMemberActor = akMember.MemberRef as Actor
    If !kMemberActor.HasKeyword(ShowWornItemsKeyword)
        kMemberActor.AddKeyword(ShowWornItemsKeyword)
    EndIf
    ; WaitExt(0.25)
    ; memberActor.SetOutfit(member.MemberOutfit)
    ; WaitExt(0.666)
    ; memberActor.SetOutfit(member.MemberSpacesuitOutfit, True)
    ; WaitExt(0.5)

    If abAddWeapon
        AddWeaponToMember(akMember, LL_Weapon_Constellation_Legendary, True)
    EndIf
    WaitExt(0.333)
    If abAddArmor
        ; AddLeveledItemToActor(kMemberActor, LL_Armor_Constellation_Legendary, 1, True, False)
        AddArmorSetToMember(akMember, PlayableConstellationArmorSet, LL_Armor_Constellation_Legendary, True)
    EndIf
    WaitExt(0.333)
    If abAddClothes
        AddClothesToMember(akMember, LL_Clothes_Constellation_Legendary, True)
    EndIf
EndFunction

Bool Function _CreateCollections()
    If InitializedMembers == None
        InitializedMembers = HTG:Collections:ObjectReferenceList.ObjectReferenceList(Utilities.ModInfo)
    EndIf

    If MemberData == None
        MemberData = HTG:Constellation:Collections:ConstellationMemberList.ConstellationMemberList(Utilities.ModInfo)
    EndIf

    return (!IsNone(InitializedMembers) && InitializedMembers.IsInitialized) \
            && (!IsNone(MemberData) && MemberData.IsInitialized && _UpdateMemberData())
EndFunction

Bool Function _UpdateMemberData()
    Int i = 0
    Int count = DefaultMemberData.Length
    While i < count
        ConstellationMember kDefaultMember = DefaultMemberData[i]
        If !MemberData.Contains(kDefaultMember)          
            MemberData.Add(kDefaultMember)
        EndIf
        i += 1
    EndWhile

    return MemberData.Count > 0
EndFunction

Bool Function _ClearExistingEquipment(ConstellationMember akMember, ArmorSet akArmorSet)
    ObjectReference kMember = akMember.MemberRef
    If kMember.GetItemCount(akMember.MemberSpacesuit) > 0
        kMember.RemoveItem(akMember.MemberSpacesuit)
    EndIf

    If kMember.GetItemCount(akArmorSet.Helmet) > 0
        kMember.RemoveItem(akArmorSet.Helmet)
    EndIf

    If kMember.GetItemCount(akArmorSet.Backpack) > 0
        kMember.RemoveItem(akArmorSet.Backpack)
    EndIf

    If kMember.GetItemCount(akMember.MemberWeapon) > 0
        kMember.RemoveItem(akMember.MemberWeapon)
    EndIf

    If kMember.GetItemCount(akMember.MemberClothes) > 0
        kMember.RemoveItem(akMember.MemberClothes)
    EndIf

    If !IsNone(akMember.MemberHat) && kMember.GetItemCount(akMember.MemberHat) > 0
        kMember.RemoveItem(akMember.MemberHat)
    EndIf

    return kMember.GetItemCount(akMember.MemberSpacesuit) > 0 \
            && kMember.GetItemCount(akArmorSet.Helmet) > 0 \
            && kMember.GetItemCount(akArmorSet.Backpack) > 0 \
            && kMember.GetItemCount(akMember.MemberWeapon) > 0 \
            && kMember.GetItemCount(akMember.MemberClothes) > 0 \
            && (!IsNone(akMember.MemberHat) && kMember.GetItemCount(akMember.MemberClothes) > 0)
EndFunction