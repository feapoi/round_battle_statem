%%%-------------------------------------------------------------------
%%% @author 10621
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2020 10:38
%%%-------------------------------------------------------------------
-module(conf).
-author("10621").

-include("round_battle_statem.hrl").

%% API
-export([get_data/1]).
get_data(1) ->
    #mon{
        id = 1
        ,speed = 100
        ,max_hp = 300
        ,ack = 100
    };
get_data(2) ->
    #mon{
        id = 2
        ,speed = 110
        ,max_hp = 250
        ,ack = 90
    };
get_data(3) ->
    #mon{
        id = 3
        ,speed = 120
        ,max_hp = 200
        ,ack = 80
    };
get_data(4) ->
    #mon{
        id = 4
        ,speed = 130
        ,max_hp = 150
        ,ack = 70
    };
get_data(5) ->
    #mon{
        id = 5
        ,speed = 140
        ,max_hp = 150
        ,ack = 60
    };
get_data(6) ->
    #mon{
        id = 6
        ,speed = 150
        ,max_hp = 100
        ,ack = 50
    }.