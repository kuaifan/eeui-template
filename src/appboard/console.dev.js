var debug = app.requireModule('debug');

console = {
    open: true,

    _: function(e) {
        return e.map(function(e) {
            return e = "[object object]" === Object.prototype.toString.call(e).toLowerCase() ? JSON.stringify(e) : e
        })
    },

    debug: function() {
        for (var e = [], t = arguments.length; t--;) e[t] = arguments[t];
        debug.addLog("debug", this._(e))
    },

    log: function() {
        for (var e = [], t = arguments.length; t--;) e[t] = arguments[t];
        debug.addLog("log", this._(e))
    },

    info: function() {
        for (var e = [], t = arguments.length; t--;) e[t] = arguments[t];
        debug.addLog("info", this._(e))
    },

    warn: function() {
        for (var e = [], t = arguments.length; t--;) e[t] = arguments[t];
        debug.addLog("warn", this._(e))
    },

    error: function() {
        for (var e = [], t = arguments.length; t--;) e[t] = arguments[t];
        debug.addLog("error", this._(e))
    }
};
