local bShareFoodBox = false
local OnlyMergeCertainChest=0


--DO NOT MODIFY Following variables unless you know enought about them
--�޸�1.6��1.7�汾����mySpecialNumber�ĳ�239��ɵ�����
local mySpecialNumber=237
local mySpecialNumberForFix=239
local mySpecialNumberFood=97

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
            ExecuteWithDelay(6000,function()
                ExecuteInGameThread(function()
                    FindMyMod()
                    MyMod:DebugEvent()
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
    MyMod:OnFinishWork(Work:get())
end)

--���ģʽʱ��������Container��Ϊ���Ա�����������
RegisterHook("/Script/Pal.PalUIDismantlingModel:Setup",function()
    MyMod:RemoveSpecialContainerFromAllChests()
end)
RegisterHook("/Script/Pal.PalUIDismantlingModel:FinishDismantling",function()
    MyMod:RecoverSpecialContainerToAllChests()
end)

    --��ʼ��
function Init()
    mySpecialContainer=nil
    mySpecialContainerFood=nil
    print("[ShareChest]Start Init")
    MyMod:InitPara(mySpecialNumber,mySpecialNumberFood,mySpecialNumberFix,bShareFoodBox,OnlyMergeCertainChest)
    MyMod:InitSpecialContainer(true)
    --����ԭ��(�����ӱ������ƻ�����Container����)ʹ��һЩ���ӵ�ContainerΪ�գ�������ʱ�Զ��޸�
    MyMod:RecoverSpecialContainerToAllChests()
    --�Զ��ϲ�����
    MyMod:MergeEmptyChestToSpecial()
end

function FindMyMod()    
    local modActors = FindAllOf("ModActor_C");
    for idx, modActor in ipairs(modActors) do
        if modActor:IsA("/Game/Mods/ShareChest/ModActor.ModActor_C") then
            MyMod=modActor
            print("[ShareChest] Find BP Mod")
        end
    end
end