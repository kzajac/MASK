-module(proba2).

-export([loopmodule/1, fullmodule/0]).
 
loopmodule(0) ->
       io:format("~w ending ~n",[self()]);

loopmodule(Number) ->
 
       io:format("~w spawning ~n",[self()]),
        Pid2 = spawn(proba2, fullmodule, []),
 
        io:format("~w sending data to ~w ~n",[self(), Pid2]),
        Pid2 ! {self(), value},

        io:format("~w waiting from answer from ~w ~n",[self(), Pid2]),
        receive 
                {Pid2, Msg} ->
                        io:format("~w received ~w~n",[self(),Msg])
        end,

        io:format("~w calculating~n",[self()]),
        timer:sleep(1000),

        loopmodule(Number-1).
 

fullmodule() ->

        io:format("~w ready ~n",[self()]),
        receive
                {From, Msg} ->
                        io:format("data received ~w calculating~n",[self()]),
                        timer:sleep(1000), 
                       
                        io:format("~w sending back calculations ~n",[self()]),
                        From ! {self(), Msg}
        end.

