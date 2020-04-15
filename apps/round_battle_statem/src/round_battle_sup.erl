%%%-------------------------------------------------------------------
%%% @author 10621
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2020 10:56
%%%-------------------------------------------------------------------
-module(round_battle_sup).
-author("10621").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-include("round_battle_statem.hrl").

-define(SERVER, ?MODULE).

-record(state, {}).

-export([start_battle/0]).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    process_flag(trap_exit, true),
    {ok, #state{}}.

handle_call(Request, From, State) ->
    try
        do_handle_call(Request, From, State)
    catch
        _:_Reason:_StackInfo ->
            {reply, error, State}
    end.

handle_cast(Request, State) ->
    try
        do_handle_info(Request, State)
    catch
        _:_Reason:_StackInfo ->
            {noreply, State}
    end.

handle_info(Info, State) ->
    try
        do_handle_info(Info, State)
    catch
        _:_Reason:_StackInfo ->
            {noreply, State}
    end.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


do_handle_info(start_battle, State) ->
    battle:start_link({10001, [1,2,3]}, {10002, [4,5,6]}),
    {noreply, State};
do_handle_info(Request, State) ->
    ?INFO("sup info ~p~n", [Request]),
    {noreply, State}.

do_handle_call(Request, _From, State) ->
    ?INFO("sup call ~p~n", [Request]),
    {reply, error, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
start_battle() ->
    gen_server:cast(?MODULE, start_battle).