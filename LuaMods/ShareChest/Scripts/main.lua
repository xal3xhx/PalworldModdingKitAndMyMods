--local UEHelpers = require("UEHelpers")
--PlayerController=UEHelpers.GetPlayerController()
--PalPlayerState=PlayerController:GetPalPlayerState()
--Player = PlayerController.Pawn
--PalNetworkPlayerComponent=FindFirstOf("PalNetworkPlayerComponent")
--PalUtility = FindFirstOf("PalNetworkTransmitter"):GetPlayer()
mySpecialContainer=nil
mySpecialNumber=237

--RegisterKeyBind(Key.F2,function()
    --MergeEmptyChestToSpecial()
    --MapObjectConcreteModelMapForServer
    --manager=FindFirstOf("PalMapObjectManager")
    --map=manager["MapObjectConcreteModelMapForServer"]
    --print(tostring(map:Keys()))
--end)
local hooked=false
local inited=false
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
    if not hooked then
        hooked=true
        ExecuteWithDelay(5000,function()
            ExecuteInGameThread(function()
                RegisterHook("/Game/Pal/Blueprint/UI/UserInterface/ESCMenu/WBP_MenuESC.WBP_MenuESC_C:OnReturn2Title",function()
                    inited=false
                end)
            end)
        end)
    end

    if not inited then
        inited=true
        mySpecialContainer=nil
        --��Ҫ�ȴ�����object����
        ExecuteWithDelay(6000,function()
            ExecuteInGameThread(function ()
                print("[ShareChest]Start Init")
                MyMod=StaticFindObject("/Game/Mods/ShareChest/ModActor.Default__ModActor_C")
                --mySpecialContainer=nil
                --��ʼ��
                mySpecialContainer=InitSpecialContainer(mySpecialNumber,true)
                if CheckInit() then
                    --����ԭ��(�����ӱ������ƻ�����Container����)ʹ��һЩ���ӵ�ContainerΪ�գ�������ʱ�Զ��޸�
                    RecoverSpecialContainerToAllChest()
                    --�Զ��ϲ�����
                    MergeEmptyChestToSpecial()
                end
            end)
        end)
    end
end)
--���⽨�����ʱ���Ժϲ�������(ֱ���������ľ�ذ岻�ᴥ��)
--����ڲ��ģʽ�ڴ����ú������������µ�Container��Ϊ�յ����ӣ��ٽ��������ᵼ��SpecialContainer���٣������������
RegisterHook("/Script/Pal.PalBuildProcess:OnFinishWorkInServer",function(self,Work)
    --����������ʱCheckInit=false,˵����ǰ����û���κα�ѡ��SpecialContainer
    --��ʱ���Բ������Ӳ���������ΪSpecialContainer1
    --�������������֮ǰ���ӱ������ƻ���ɵģ���ʱ���ܻ���ContainerΪ�յ����ӣ������޸�
    if not CheckInit() then
         mySpecialContainer=InitSpecialContainer(mySpecialNumber,false)
         RecoverSpecialContainerToAllChest()
    end
    MergeEmptyChestToSpecial()   
end)

--���ģʽʱ��������Container��Ϊ���Ա�����������
RegisterHook("/Script/Pal.PalUIDismantlingModel:Setup",function()
    RemoveSpecialContainerFromAllChest()
end)
RegisterHook("/Script/Pal.PalUIDismantlingModel:FinishDismantling",function()
    RecoverSpecialContainerToAllChest()
end)

function MergeEmptyChestToSpecial()
    if CheckInit() then 
        --use bp mod,faster 
        manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:MergeEmptyChestToSpecial(manager,mySpecialNumber,mySpecialContainer)
        end
        if false then
            chestmodel=FindAllOf("PalMapObjectItemChestModel")
            print(string.format("[ShareChest]Searching Chest %d",#chestmodel))
            for i=1,#chestmodel do
                if chestmodel[i]:GetItemContainerModule():IsValid() then
                    local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                    if container ~=nil and container:IsValid() and container:IsEmpty() and container:Num() ~= mySpecialNumber then
                        chestmodel[i]:GetItemContainerModule()["TargetContainer"]=mySpecialContainer
                        print(string.format("[ShareChest]Merge Empty Chest"))
                    end
                end
            end
        end
    end
end

function CheckInit()
    if mySpecialContainer == nil or not mySpecialContainer:IsValid() or not mySpecialContainer:IsA("/Script/Pal.PalItemContainer") then
        return false
    end
    return true
end

function RemoveSpecialContainerFromAllChest()
    if CheckInit() then   
        chestmodel=FindAllOf("PalMapObjectItemChestModel")
        if chestmodel~=nil then
            print(string.format("[ShareChest]Searching Chest %d",#chestmodel))
            for i=1,#chestmodel do
                if chestmodel[i]:GetItemContainerModule():IsValid() then
                    local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                    if container ~=nil and container:IsValid() and container:GetFullName()==mySpecialContainer:GetFullName() then
                        print(string.format("[ShareChest]Temp Remove Container From Chest"))            
                        chestmodel[i]:GetItemContainerModule()["TargetContainer"]=nil
                    end
                end
            end
        end
    end
end
function RecoverSpecialContainerToAllChest()
    if CheckInit() then   
        chestmodel=FindAllOf("PalMapObjectItemChestModel")
        if chestmodel~=nil then
            print(string.format("[ShareChest]Searching Chest %d",#chestmodel))
            for i=1,#chestmodel do
                if chestmodel[i]:GetItemContainerModule():IsValid() then
                    local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                    if not container:IsValid() then
                        print(string.format("[ShareChest]Recover Container To Chest"))            
                        chestmodel[i]:GetItemContainerModule()["TargetContainer"]=mySpecialContainer
                    end
                end
            end
        end
    end
end

function InitSpecialContainer(ct,searchContainers)
    local chestmodel=FindAllOf("PalMapObjectItemChestModel")
    --���Գ��Դ��������ң�����û��Ҫ����Ϊblueprint�б���Container�ܿ�
    if false then
        if chestmodel~=nil then
            print(string.format("[ShareChest]Searching Chest %d",#chestmodel))
            for i=1,#chestmodel do
                if chestmodel[i]:GetItemContainerModule():IsValid() then
                    local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                    if container ~=nil and container:IsValid() and container:Num()==mySpecialNumber then
                        return container
                    end
                end
            end
        end
    end
    --�������������ض���������Container
    local manager=FindFirstOf("PalItemContainerManager")
    if searchContainers and manager~=nil and manager:IsValid() then
        --����BPmod���ң��ǳ���
        MyMod:FindContainerBySlotNum(manager,mySpecialNumber)
        local x={}
        local y={}
        MyMod:GetResultContainer(x)--����ֵ
        MyMod:GetResultBool(y)--�Ƿ�ɹ�
        if y.Result and x.Result~=nil and x.Result:IsValid() then
            print("[One Chest]Find Special Container:")
            print(tostring(x.Result:GetFullName()))
            return x.Result
        end
    end
    --�Ҳ���˵����δ��ʼ����/֮ǰ��SpecialContainer��Ϊ���ӱ�����������
    --����������ѡһ������ΪSpecialContainer�������ҿյ�
    if chestmodel~=nil then
        --�ҿյ�
        for i=1,#chestmodel do
            if chestmodel[i]:GetItemContainerModule():IsValid() then
                local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                if container ~=nil and container:IsValid() and container:IsEmpty() and container:Num()>0 then
                    print(string.format("[ShareChest]No Special Container,Elect from a Chest"))
                    --����
                    MyMod:AddSlotToContainer(container,mySpecialNumber - container:Num())
                    return container
                end
            end
        end
        --�ǿ�
        for i=1,#chestmodel do
            if chestmodel[i]:GetItemContainerModule():IsValid() then
                local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                if container ~=nil and container:IsValid() and not container:IsEmpty() and container:Num()>0 then
                    print(string.format("[ShareChest]No Special Container,Elect from a Chest"))
                    --����
                    MyMod:AddSlotToContainer(container,mySpecialNumber - container:Num())
                    return container
                end
            end
        end
    end
    print("[ShareChest]Can't get Special Container")
end