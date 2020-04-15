%%%-------------------------------------------------------------------
%%% @author 10621
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2020 10:36
%%%-------------------------------------------------------------------
-module(battle).
-author("10621").

-behaviour(gen_statem).

%% API
-export([start_link/2]).

%% gen_statem callbacks
-export([
    init/1,
    handle_event/4,
    terminate/3,
    code_change/4,
    callback_mode/0
]).

-include("round_battle_statem.hrl").

-define(SERVER, ?MODULE).

-record(state, {
    mon_list = [],
    player1 = 0,
    player2 = 0
}).

%%%===================================================================
%%% API
%%%===================================================================
start_link({PlayerId1, MonList1}, {PlayerId2, MonList2}) ->
    gen_statem:start_link({local, ?SERVER}, ?MODULE, [{PlayerId1, MonList1}, {PlayerId2, MonList2}], []).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================
init([{PlayerId1, MonList1}, {PlayerId2, MonList2}]) ->
    Fun1 = fun(MonId) ->
        #mon{speed = Speed, max_hp = MaxHp} = Mon = conf:get_data(MonId),
        Mon#mon{
        hp = MaxHp
        ,location = Speed
        ,own = PlayerId1
        }
        end,
    Fun2 = fun(MonId) ->
        #mon{speed = Speed, max_hp = MaxHp} = Mon = conf:get_data(MonId),
        Mon#mon{
            hp = MaxHp
            ,location = Speed
            ,own = PlayerId2
        }
           end,
    NewMonList1 = lists:map(Fun1, MonList1),
    NewMonList2 = lists:map(Fun2, MonList2),
    {ok, in_battle, #state{mon_list = NewMonList1 ++ NewMonList2, player1 = PlayerId1, player2 = PlayerId2}, {next_event, info, next_mon}}.

callback_mode() ->
    handle_event_function.

handle_event(EventType, EventContent, StateName, State) ->
    try
        do_handle_event(EventType, EventContent, StateName, State)
    catch
        _:Error:StackInfo  ->
            ?ERROR("battle error ~p~n~p", [Error, StackInfo]),
            {next_state, error, State}
    end.

do_handle_event(info, next_mon, in_battle, #state{mon_list = MonList, player1 = Player1, player2 = Player2} = State) ->
    Fun = fun(#mon{own = Own, location = Location} = ThisMon, {#mon{location = MaxLocation} = OldMon, OldP1, OldP2}) ->
        {NewP1, NewP2} =
            if
                Own =:= Player1 -> {OldP1 + 1, OldP2};
                true -> {OldP1, OldP2 + 1}
            end,
        NewMon =
            case Location > MaxLocation of
                true ->
                    ThisMon;
                _ ->
                    OldMon
            end,
        {NewMon, NewP1, NewP2}
          end,
    {NowMon, P1, P2} = lists:foldl(Fun, {#mon{}, 0, 0}, MonList),
    Fun1 = fun(#mon{id = ThisId} = ThisMon, OldList) ->
        case ThisId =:= NowMon#mon.id of
            true ->
                [ThisMon#mon{location = 0} | OldList];
            _ ->
                ThisLocation = ThisMon#mon.location,
                [ThisMon#mon{location = ThisLocation + ThisMon#mon.speed}  | OldList]
        end
        end,
    NewMonList = lists:reverse(lists:foldl(Fun1, [], MonList)),
    ?INFO("%%-----------------------------------------------~n", []),
    [?INFO("Id:~p Hp:~p Own:~p~n", [Lid, LHp, LOwn]) ||#mon{id = Lid, hp = LHp, own = LOwn} <- NewMonList],
    ?INFO("%%-----------------------------------------------~n~n", []),
    if
        P1 =:= 0 ->
            ?INFO("~p win", [Player2]),
            {stop, normal, State};
        P2 =:= 0 ->
            ?INFO("~p win", [Player1]),
            {stop, normal, State};
        true ->
            ?INFO("~p mon:~p select target.~n", [NowMon#mon.own, NowMon#mon.id]),
            {next_state, {wait_operation, NowMon#mon.own, NowMon#mon.id}, State#state{mon_list = NewMonList}, 15000}
    end;

do_handle_event(cast, {operation, Own, Id, Target}, {wait_operation, Own, Id},
    #state{mon_list = MonList} = State) ->
    EnemyList = get_enemy(Own, MonList),
    ?INFO("11111:~p~n", [EnemyList]),
    case lists:keymember(Target, #mon.id, EnemyList) of
        true ->
            AckMon = lists:keyfind(Id, #mon.id, MonList),
            [#mon{hp = DefHp} = DefMon | _] = EnemyList,
            NewMonList = lists:keyreplace(Target, #mon.id, MonList, DefMon#mon{hp = max(0, DefHp - AckMon#mon.ack)}),
            {next_state, in_battle, State#state{mon_list = NewMonList}, {next_event, info, next_mon}};
        _ ->
            {keep_state, State}
    end;

do_handle_event(timeout, _Timeout, {wait_operation, Own, Id},
    #state{mon_list = MonList} = State) ->
    EnemyList = get_enemy(Own, MonList),
    [#mon{id = Target,hp = DefHp} = DefMon | _] = EnemyList,
    case lists:keymember(Target, #mon.id, EnemyList) of
        true ->
            AckMon = lists:keyfind(Id, #mon.id, MonList),
            NewMonList =
                case DefHp - AckMon#mon.ack > 0  of
                    true ->
                        lists:keyreplace(Target, #mon.id, MonList, DefMon#mon{hp = max(0, DefHp - AckMon#mon.ack)});
                    _ ->
                        lists:keydelete(Target, #mon.id, MonList)
                end,
            {next_state, in_battle, State#state{mon_list = NewMonList}, {next_event, info, next_mon}};
        _ ->
            {keep_state, State}
    end;

do_handle_event(EventType, EventContent, StateName, State) ->
    ?INFO("Other Info EventType:~p EventContent:~p StateName:~p State:~p~n", [EventType, EventContent, StateName, State]),
    {keep_state, State}.

terminate(_Reason, _StateName, _State) ->
    ok.

code_change(_OldVsn, StateName, State, _Extra) ->
    {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_enemy(Own, MonList) ->
    Fun = fun(#mon{own = ThisOwn}) ->
        ThisOwn =/= Own
        end,
    lists:filter(Fun, MonList).
