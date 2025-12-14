--!strict

export type CallbackFn<T...> = (T...) -> ()
export type Connection<T...> = {
    Connected: boolean,
    Disconnect: (self: Connection<T...>) -> (),
    _Signal: Signal<T...>,
    _Callback: CallbackFn<T...>
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, fn: CallbackFn<T...>) -> Connection<T...>,
    Once: (self: Signal<T...>, fn: CallbackFn<T...>) -> Connection<T...>,
    Fire: (self: Signal<T...>, T...) -> (),
    FireAsync: (self: Signal<T...>, T...) -> (),
    Wait: (self: Signal<T...>) -> T...,
    Destroy: (self: Signal<T...>) -> (),
    
    _Alive: boolean,
    _Connections: {[Connection<T...>]: boolean}
}

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection.Disconnect<T...>(self: Connection<T...>)
    if not self.Connected then return end
    self.Connected = false
    self._Signal._Connections[self] = nil
end

function Signal.New<T...>(): Signal<T...>
    local self = setmetatable({
        _Connections = {} :: {[Connection<T...>]: boolean},
        _Alive = true
    }, Signal)

    return self :: Signal<T...>
end

function Signal.Connect<T...>(self: Signal<T...>, fn: CallbackFn<T...>): Connection<T...>
    local conn: Connection<T...> = setmetatable({
        Connected = true,
        Disconnect = Connection.Disconnect,
        _Signal = self,
        _Callback = fn,
    }, Connection)

    self._Connections[conn] = true
    return conn
end

function Signal.Once<T...>(self: Signal<T...>, fn: CallbackFn<T...>): Connection<T...>
    local conn: Connection<T...>
    conn = self:Connect(function(...: T...)
        conn:Disconnect()
        fn(...)
    end)
    return conn
end

function Signal.Fire<T...>(self: Signal<T...>, ...: T...)
    if not self._Alive then return end
    for conn: Connection<T...> in pairs(self._Connections) do
        if conn.Connected then
            task.spawn(conn._Callback, ...)
        end
    end
end

function Signal.FireAsync<T...>(self: Signal<T...>, ...: T...)
    if not self._Alive then return end

    local active = 0
    local finished = 0
    local thread = coroutine.running()

    for conn: Connection<T...> in pairs(self._Connections) do
        if conn.Connected then
            active += 1
            task.spawn(function()
                conn._Callback(...)
                finished += 1
                if finished == active then
                    task.spawn(thread)
                end
            end)
        end
    end

    if active > 0 then
        coroutine.yield()
    end
end

function Signal.Wait<T...>(self: Signal<T...>): T...
    local thread = coroutine.running()
    local conn: Connection<T...>

    conn = self:Connect(function(...: T...)
        conn:Disconnect()
        task.spawn(thread, ...)
    end)

    return coroutine.yield()
end

function Signal.Destroy<T...>(self: Signal<T...>)
    self._Alive = false
    for conn: Connection<T...> in pairs(self._Connections) do
        conn:Disconnect()
    end
    table.clear(self._Connections)
end

return Signal
