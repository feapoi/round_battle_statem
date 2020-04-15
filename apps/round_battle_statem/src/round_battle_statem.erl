%%%-------------------------------------------------------------------
%%% @author 10621
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2020 10:33
%%%-------------------------------------------------------------------
-module(round_battle_statem).
-author("10621").

-behaviour(application).

%% Application callbacks
-export([start/2,
    stop/1]).

-export([process_name/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================
start(_StartType, _StartArgs) ->
    reloader:start_link(),
    round_battle_sup:start_link().

stop(_State) ->
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
process_name(Pid)->
    case process_info(Pid,registered_name) of
        {registered_name,Name}->
            Name;
        _->
            Pid
    end.