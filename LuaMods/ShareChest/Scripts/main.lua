local mySpecialContainer=nil
local mySpecialNumber=237

local ModelName="PalMapObjectItemChestModel"
local ResultIndex=1
local hooked=false
local inited=false
local manager=nil
if true then
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
                    mySpecialContainer["CorruptionMultiplier"]=0.01
                    --����ԭ��(�����ӱ������ƻ�����Container����)ʹ��һЩ���ӵ�ContainerΪ�գ�������ʱ�Զ��޸�
                    RecoverSpecialContainerToAllChests()
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
         if CheckInit() then
             mySpecialContainer["CorruptionMultiplier"]=0.01
             RecoverSpecialContainerToAllChests()
         end
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

function MergeEmptyChestToSpecial()
    if CheckInit() then 
        --use bp mod,faster 
        manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:MergeEmptyChestToSpecial(manager,mySpecialNumber,mySpecialContainer,ModelName)
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
end

function CheckInit()
    if mySpecialContainer == nil or not mySpecialContainer:IsValid() or not mySpecialContainer:IsA("/Script/Pal.PalItemContainer") then
        return false
    end
    return true
end

function RemoveSpecialContainerFromAllChests()
    if CheckInit() then   
        --use bp mod,faster 
        manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:RemoveSpecialContainerFromAllChests(manager,mySpecialContainer,ModelName)
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
end
function RecoverSpecialContainerToAllChests()
    if CheckInit() then
        --use bp mod,faster 
        manager=FindFirstOf("PalMapObjectManager")
        --print(tostring(manager:GetFullName()))
        if manager~=nil and manager:IsValid() then
            MyMod:RecoverSpecialContainerToAllChests(manager,mySpecialContainer,ModelName)
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
end

function InitSpecialContainer(ct,searchContainers)
    local chestmodel=FindAllOf(ModelName)
    --���Գ��Դ��������ң�����û��Ҫ����Ϊblueprint�б���Container�ܿ�
    --�������������ض���������Container
    local manager=FindFirstOf("PalItemContainerManager")
    if searchContainers and manager~=nil and manager:IsValid() then
        --����BPmod���ң��ǳ���
        MyMod:FindContainerBySlotNum(manager,mySpecialNumber,ModelName)
        local x={}
        local y={}
        MyMod:GetResultContainer(ResultIndex,x)--����ֵ
        MyMod:GetResultBool(ResultIndex,y)--�Ƿ�ɹ�
        if y.Result and x.Result~=nil and x.Result:IsValid() then
            print("[One Chest]Find Special Container:")
            print(tostring(x.Result:GetFullName()))
            print(tostring(x.Result:Num()))
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
end