local bShareFoodBox = false
local OnlyMergeCertainChest=0

local OnlyMergeCertainChestFood=0
local mySpecialContainer=nil
local mySpecialNumber=239

local mySpecialContainerFood=nil
local mySpecialNumberFood=97

local ModelName="PalMapObjectItemChestModel"
local ModelNameFood="PalMapObjectPalFoodBoxModel"

--PlayerController:ClientRestart��������ʱҲ�ᴥ��
--Pre/PostBeginPlay��ΪBPModLoader��bug���ظ������������bpmod����ԭ����BeginPlay�¼�����hook��ReceiveBeginPlay����
--ReceiveBeginPlay����������Ϸ�������˳�һ����Ϸʱ��������ȡGameMode���ǻ�ȡ��1��˲��������жϣ�
--������Ϸʱ���������û��Ӱ�죬����������container��ÿգ�Ȼ����ΪcontainerModule��validʲô������
--��һ��ClientRestart�϶��ǽ���Ϸ(���߸�������Ϸ)����ʱhook ReceiveBeginPlay, ֮����ReceiveBeginPlay������ʼ������һ�ν���Ϸʱ��hookҲ�ܴ���
--Hook����Bp-only����(��ʹ����/Script��ͷ�ĺ���)��posthook����bp-only����(/Script��ͷ��)��prehook,���ReceiveBeginPlay��hook���ڸ��ִ������ʱִ��
--BP-only���������hook��Σ�ֻ������ִ�еĻ���Ч,��bp���������Ч(Ҳ��bug?)
local hooked=false
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
    if not hooked then
        RegisterHook("/Game/Mods/ShareChest/ModActor.ModActor_C:ReceiveBeginPlay",function()
            ExecuteWithDelay(5000,function()
                ExecuteInGameThread(function()
                    Init()
                end)
            end)
        end)
        --��ĳЩ�û��Ļ����ϣ�ClientRestart����������Ϸʱ�ʹ���һ�Σ�����ʱReceiveBeginPlay��hook��ʧ�ܣ�ԭ����
        --�����Ҫ��hooked=true���ں��棬�������RegisterHookeʧ����hooked�Ͳ��ᱻ��ֵ
        hooked=true
    end
end)

--���⽨�����ʱ���Ժϲ�������(ֱ���������ľ�ذ岻�ᴥ��)
--����ڲ��ģʽ�ڴ����ú������������µ�Container��Ϊ�յ����ӣ��ٽ��������ᵼ��SpecialContainer���٣������������
RegisterHook("/Script/Pal.PalBuildProcess:OnFinishWorkInServer",function(self,Work)
    --����������ʱCheckInit=false,˵����ǰ����û���κα�ѡ��SpecialContainer
    --��ʱ���Բ������Ӳ���������ΪSpecialContainer1
    --�������������֮ǰ���ӱ������ƻ���ɵģ���ʱ���ܻ���ContainerΪ�յ����ӣ������޸�
    if (not CheckInit()) or (bShareFoodBox and not CheckInitFood())then
         InitSpecialContainer(false)
         RecoverSpecialContainerToAllChests()
    end
    MergeEmptyChestToSpecial()   
end)

--���ģʽʱ��������Container��Ϊ���Ա�����������
RegisterHook("/Script/Pal.PalUIDismantlingModel:Setup",function()
    RemoveSpecialContainerFromAllChests()
end)
RegisterHook("/Script/Pal.PalUIDismantlingModel:FinishDismantling",function()
    RecoverSpecialContainerToAllChests()
end)

    --��ʼ��
function Init()
    mySpecialContainer=nil
    mySpecialContainerFood=nil
    print("[ShareChest]Start Init")
    MyMod=StaticFindObject("/Game/Mods/ShareChest/ModActor.Default__ModActor_C")
    InitSpecialContainer(true)
    if CheckInit() then
        --����ԭ��(�����ӱ������ƻ�����Container����)ʹ��һЩ���ӵ�ContainerΪ�գ�������ʱ�Զ��޸�
        RecoverSpecialContainerToAllChests()
        --�Զ��ϲ�����
        MergeEmptyChestToSpecial()
    end
end
function MergeEmptyChestToSpecial()
    --use bp mod,faster 
    if CheckInit() then 
        local manager=FindFirstOf("PalMapObjectManager")
        if manager~=nil and manager:IsValid() then
            MyMod:MergeEmptyChestToSpecial(manager,mySpecialNumber,mySpecialContainer,ModelName,OnlyMergeCertainChest)
        end
    end
    if CheckInitFood() then
        local manager=FindFirstOf("PalMapObjectManager")
        if manager~=nil and manager:IsValid() then
            MyMod:MergeEmptyChestToSpecial(manager,mySpecialNumberFood,mySpecialContainerFood,ModelNameFood,OnlyMergeCertainChestFood)
        end
    end
    --[[
    if false then
        chestmodel=FindAllOf(ModelName)
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
    ]]---
end

function CheckInit()
    if mySpecialContainer == nil or not mySpecialContainer:IsValid() or not mySpecialContainer:IsA("/Script/Pal.PalItemContainer") then
        return false
    end
    return true
end

function CheckInitFood()
    if not bShareFoodBox then 
        return false
    end
    if mySpecialContainerFood == nil or not mySpecialContainerFood:IsValid() or not mySpecialContainerFood:IsA("/Script/Pal.PalItemContainer") then
        return false
    end
    return true
end

function RemoveSpecialContainerFromAllChests()
    if CheckInit() then
        local manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:RemoveSpecialContainerFromAllChests(manager,mySpecialContainer,ModelName)
        end
    end
    if CheckInitFood() then
        local manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:RemoveSpecialContainerFromAllChests(manager,mySpecialContainerFood,ModelNameFood)
        end
    end
        --[[
        chestmodel=FindAllOf(ModelName)
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
        ]]--
end
function RecoverSpecialContainerToAllChests()
    --use bp mod,faster 
    if CheckInit() then
        local manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:RecoverSpecialContainerToAllChests(manager,mySpecialContainer,ModelName)
        end
    end
    if CheckInitFood() then
        local manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:RecoverSpecialContainerToAllChests(manager,mySpecialContainerFood,ModelNameFood)
        end
    end
        --[[
        chestmodel=FindAllOf(ModelName)
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
        end]]--
end

function InitSpecialContainer(searchContainers)
    --���Գ��Դ��������ң�����û��Ҫ����Ϊblueprint�б���Container�ܿ�
    --�������������ض���������Container
    local manager=FindFirstOf("PalItemContainerManager")
    if searchContainers and manager~=nil and manager:IsValid() then
        --����BPmod���ң��ǳ���
        MyMod:FindContainerBySlotNum(manager,mySpecialNumber,mySpecialNumberFood)
        local x={}
        local y={}
        MyMod:GetResultContainer(x,{})--����ֵ
        MyMod:GetResultBool(y,{})--�Ƿ�ɹ�
        if y.Result and x.Result~=nil and x.Result:IsValid() then
            print("[ShareChest]Find Special Container:")
            print(tostring(x.Result:GetFullName()))
            print(tostring(x.Result:Num()))
            mySpecialContainer=x.Result
        end
        if y.Result2 and x.Result2~=nil and x.Result2:IsValid() then
            print("[ShareChest]Find Special Container Food:")
            print(tostring(x.Result2:GetFullName()))
            print(tostring(x.Result2:Num()))
            mySpecialContainerFood=x.Result2
        end
    end
    
    --�Ҳ���˵����δ��ʼ����/֮ǰ��SpecialContainer��Ϊ���ӱ�����������
    --ѡ���µ�SpecialContainer
    if mySpecialContainer == nil then
        mySpecialContainer=StaticElectSpecialContainer(ModelName,mySpecialNumber,OnlyMergeCertainChest)
    end
    if bShareFoodBox and mySpecialContainerFood == nil then
        --�Ҳ���˵����δ��ʼ����/֮ǰ��SpecialContainer��Ϊ���ӱ�����������
        mySpecialContainerFood=StaticElectSpecialContainer(ModelNameFood,mySpecialNumberFood,OnlyMergeCertainChestFood)
    end
    -- �ӳ�����ʱ�䣬��Ϊÿ�����ӵ����������Ӷ���ʹ��ʳ��ӿ츯���ٶ�
    if not CheckInit() then
        print("[ShareChest][Info]Can't get Special Container")
    else
        mySpecialContainer["CorruptionMultiplier"]=0.001
    end
    if not CheckInitFood() then
        print("[ShareChest][Info]Can't get Special Container Food")
    else
        mySpecialContainerFood["CorruptionMultiplier"]=0.001
    end
end

function StaticElectSpecialContainer(ModelName,SpecialNumber,MergeNumber)
    local chestmodel=FindAllOf(ModelName)
    --����������ѡһ������ΪSpecialContainer�������ҿյ�
    if chestmodel~=nil then
        --�ҿյ�
        print(tostring(#chestmodel))
        for i=1,#chestmodel do
            print(tostring(chestmodel[i]))
            print(tostring(chestmodel[i]:GetFullName()))
            if chestmodel[i]:GetItemContainerModule():IsValid() then
                local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                if container ~=nil and container:IsValid() and container:IsEmpty() and container:Num()<SpecialNumber then
                    if MergeNumber ==0 or container:Num()==MergeNumber then
                        print(string.format("[ShareChest]No Special Container,Elect from a Chest"))
                        --����
                        MyMod:AddSlotToContainer(container,SpecialNumber)
                        return container
                    end
                end
            end
        end
        --�ǿ�
        for i=1,#chestmodel do
            if chestmodel[i]:GetItemContainerModule():IsValid() then
                local container=chestmodel[i]:GetItemContainerModule():GetContainer()
                if container ~=nil and container:IsValid() and not container:IsEmpty() and container:Num()<SpecialNumber then
                    if MergeNumber ==0 or container:Num()==MergeNumber then
                        print(string.format("[ShareChest]No Special Container,Elect from a Chest"))
                        --����
                        MyMod:AddSlotToContainer(container,SpecialNumber)
                        return container
                    end
                end
            end
        end
    end
    return nil
end