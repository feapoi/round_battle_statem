@start werl -setcookie round_battle_statem -name round_battle_statem@127.0.0.1 +K true +A 30  +B i +c true +C multi_time_warp +P 1048576 +Q 1048576 +spp true -stdlib shell_catch_exception true -config ../config/sys.config -eval "code:add_pathsa(filelib:wildcard(\"../_build/default/lib/*/ebin\")),application:ensure_all_started(round_battle_statem)." -s observer