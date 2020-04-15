%%%-------------------------------------------------------------------
%%% @author 10621
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2020 10:38
%%%-------------------------------------------------------------------
-author("10621").
-record(mon, {
    id = 0
    ,speed = 100
    ,max_hp = 0
    ,ack = 0
    %%tem
    ,hp = 0
    ,location = 0
    ,own = 0
}).


-define(SKILL_NORMAL_ACK, 1).           %% 单体攻击
-define(SKILL_AOE, 2).                  %% 群体攻击
-define(SKILL_NORMAL_RECOVER, 3).       %% 单体回复
-define(SKILL_AOE_RECOVER, 4).          %% 群体回复
-define(SKILL_AOE_ADD_SPEED, 5).        %% 群体加速

-define(WAIT_TIME, 10000).


-define(LAGER_LOG(__Level,__Msg),LAGER_LOG(__Level,__Msg,[])).

-define(LAGER_LOG(__Level,__Msg,__Args),lager:__Level("~w "++__Msg,[round_battle_statem:process_name(self())|__Args])).

-define(DEBUG(__Msg),?DEBUG(__Msg,[])).
-define(DEBUG(__Msg,__Args),?LAGER_LOG(debug,__Msg,__Args)).
%% 同DEBUG普通信息输出
-define(INFO(__Msg),?INFO(__Msg,[])).
-define(INFO(__Msg,__Args),?LAGER_LOG(info,__Msg,__Args)).
%% 非法操作
-define(WARNING(__Msg),?WARNING(__Msg,[])).
-define(WARNING(__Msg,__Args),?LAGER_LOG(warning,__Msg,__Args)).
%% 报错 未处理消息
-define(ERROR(__Msg),?ERROR(__Msg,[])).
-define(ERROR(__Msg,__Args),?LAGER_LOG(error,__Msg,__Args)).
%% 核心进程不响应 数据库延迟
-define(CRITICAL(__Msg),?CRITICAL(__Msg,[])).
-define(CRITICAL(__Msg,__Args),?LAGER_LOG(critical,__Msg,__Args)).
