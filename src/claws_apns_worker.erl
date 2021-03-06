-module(claws_apns_worker).
-author("benhur.langoni").

-behaviour(gen_server).

%% gen_server callbacks
-export([ init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

init(ApnsConfig) ->
    {ok, ConnectionPid} = apns:connect(ApnsConfig),
    {ok, #{connection_pid => ConnectionPid}}.

handle_call({push, DeviceId, ApnsTopic, Notification}, _From, State) ->
    #{connection_pid := ConnectionPid} = State,
    Headers = #{apns_topic => ApnsTopic},
    Response = apns:push_notification(ConnectionPid, DeviceId, Notification, Headers),
    {reply, Response, State};

handle_call({push_token, Token, DeviceId, ApnsTopic, Notification}, _From, State) ->
    #{connection_pid := ConnectionPid} = State,
    Headers = #{apns_topic => ApnsTopic},
    Response = apns:push_notification_token(ConnectionPid, Token, DeviceId, Notification, Headers),
    {reply, Response, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
