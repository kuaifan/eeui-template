<template>
    <div class="app" @click="">

        <div class="tabs">
            <text @click="active='all'" :class="[active==='all'?'tab-item-active':'tab-item']">All</text>
            <text @click="active='log'" :class="[active==='log'?'tab-item-active':'tab-item']">Log</text>
            <text @click="active='info'" :class="[active==='info'?'tab-item-active':'tab-item']">Info</text>
            <text @click="active='warn'" :class="[active==='warn'?'tab-item-active':'tab-item']">Warn</text>
            <text @click="active='error'" :class="[active==='error'?'tab-item-active':'tab-item']">Error</text>
        </div>

        <div class="tline"></div>

        <div v-if="noConsole === true" class="tismain">
            <div class="tisbody">
                <text class="tisitem">当前环境不支持，可能不是开发环境。</text>
            </div>
        </div>
        <div v-else-if="lists.length === 0" class="tismain">
            <div class="tisbody">
                <text class="tisitem">可使用以下方法调试日志：</text>
                <text class="tisitem" @click="addLog('log', '普通日志')">console.log("普通日志")</text>
                <text class="tisitem" @click="addLog('info', '蓝色日志')">console.info("蓝色日志")</text>
                <text class="tisitem" @click="addLog('warn', '黄色日志')">console.warn("黄色日志")</text>
                <text class="tisitem" @click="addLog('error', '红色日志')">console.error("红色日志")</text>
            </div>
        </div>
        <scroller v-else ref="myList" class="lists" @scroll="scroll" @scrollend="scrollend">
            <div v-for="(item, index) in lists" class="item" :key="index" @click="info(item)">
                <text class="text" :class="['text-' + item.type]">{{formatLog(item.text)}}</text>
                <div :ref="'item' + index"></div>
            </div>
        </scroller>

        <div class="fline"></div>

        <div class="foot">
            <text class="foot-item" @click="clear">清除</text>
            <div class="foot-line"></div>
            <text class="foot-item" @click="close">隐藏</text>
        </div>

    </div>
</template>

<style>
    .app {
        width: 750px;
        flex: 1;
    }

    .tabs {
        flex-direction: row;
        align-items: center;
        background-color: #DDE1E7;
    }

    .tline {
        width: 750px;
        height: 1px;
        background-color: #cccccc;
    }

    .tab-item,.tab-item-active {
        flex: 1;
        height: 68px;
        line-height: 68px;
        font-size: 26px;
        color: #333333;
        text-align: center;
    }

    .tab-item-active {
        color: #333333;
        background-color: #ffffff;
    }

    .tismain {
        width: 750px;
        flex: 1;
        justify-content: center;
        align-items: center;
    }

    .tisbody {
        padding: 24px;
    }

    .tisitem {
        color: #bbbbbb;
        font-size: 26px;
        padding-top: 10px;
        padding-bottom: 10px;
    }

    .lists {
        width: 750px;
        flex: 1;
    }

    .item {
        width: 750px;
        padding: 14px 12px;
        border-bottom-width: 1px;
        border-bottom-style: solid;
        border-bottom-color: #eeeeee;
    }

    .text {
        font-size: 24px;
    }

    .text-log {
        color: #333;
    }

    .text-info {
        color: #428bca;
    }

    .text-warn {
        color: #ca8d1c;
    }

    .text-error {
        color: #ca3420;
    }

    .text-debug {
        color: #994dca;
    }

    .fline {
        width: 750px;
        height: 1px;
        background-color: #dddddd;
    }

    .foot {
        width: 750px;
        height: 86px;
        flex-direction: row;
        justify-content: center;
        background-color: #ffffff;
    }
    .foot-item {
        flex: 1;
        text-align: center;
        font-size: 24px;
        line-height: 86px;
    }
    .foot-line {
        width: 1px;
        margin-top: 20px;
        height: 46px;
        background-color: #dddddd;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');
    const debug = app.requireModule('debug');
    const dom = app.requireModule('dom');

    export default {
        data() {
            return {
                active: '',
                lists: [],

                noConsole: false,

                scrollHeight: 0,
                scrollBottom: true,
                scrollDiffer: 0,
                scrollInterval: null,
            }
        },

        mounted() {
            if (console.open !== true) {
                this.noConsole = true;
                return;
            }
            //
            this.active = "all";
            debug.setLogListener((item) => {
                if (this.active === 'all' || item.type === this.active) {
                    let length = this.lists.push(item);
                    if (length > 550) this.lists.splice(0, length - 50);
                    this.toBottom(length);
                }
            });
            //
            setInterval(() => {
                this.scrollBottom = this.scrollDiffer - this.scrollHeight < 10;
            }, 300);
        },

        watch: {
            active(val) {
                switch (val) {
                    case "all": {
                        debug.getLogAll((res) => {
                            if (res.length > 550) res.splice(0, res.length - 500);
                            this.lists = res;
                            this.toBottom(this.lists.length);
                        });
                        break;
                    }
                    default: {
                        debug.getLog(val, (res) => {
                            if (res.length > 550) res.splice(0, res.length - 500);
                            this.lists = res;
                            this.toBottom(this.lists.length);
                        });
                    }
                }
            }
        },

        methods: {
            formatLog(text) {
                let string = "";
                if (text != null && typeof text == "object") {
                    this.each(text, (index, item) => {
                        string += (item != null && typeof item == "object") ? this.jsonStringify(item) : item;
                        string += " ";
                    });
                }else{
                    string = text;
                }
                return string;
            },

            addLog(type, text) {
                switch (type) {
                    case 'log':
                        console.log(text, '随机字符：' + this.randomString(16));
                        break;
                    case 'info':
                        console.info(text, '随机字符：' + this.randomString(16));
                        break;
                    case 'warn':
                        console.warn(text, '随机字符：' + this.randomString(16));
                        break;
                    case 'error':
                        console.error(text, '随机字符：' + this.randomString(16));
                        break;
                }
                if (this.active !== 'all') {
                    this.active = type;
                }
            },

            info(item) {
                eeui.confirm({
                    title: "日志详情",
                    message: "类型：" + item.type + "\n时间：" + this.formatDate("Y-m-d H:i:s", item.time) + "\n内容：" + this.formatLog(item.text),
                    buttons: ["复制", "关闭"]
                }, (result) => {
                    if (result.status === "click" && result.title === "复制") {
                        eeui.copyText(this.jsonStringify(item));
                        eeui.toast("复制成功");
                    }
                });
            },

            scroll(e) {
                this.scrollDiffer = e.contentSize.height + e.contentOffset.y;
            },

            scrollend() {
                dom.getComponentRect(this.$refs.myList, (res) => {
                    this.scrollHeight = res.size.height;
                });
            },

            toBottom(length) {
                if (!this.scrollBottom) {
                    return;
                }
                let i = 0;
                clearInterval(this.scrollInterval);
                this.scrollInterval = setInterval(() => {
                    i++;
                    let indicator = this.$refs['item' + (length - 1)];
                    if (indicator|| i > 5) {
                        clearInterval(this.scrollInterval);
                        if (this.scrollBottom && indicator) {
                            dom.scrollToElement(indicator[0], {});
                        }
                    }
                }, 300);
            },

            clear() {
                if (this.active === "all") {
                    debug.clearLogAll();
                    this.lists = [];
                }else{
                    debug.clearLog(this.active);
                    this.lists = [];
                }
            },

            close() {
                debug.removeLogListener();
                debug.closeConsole();
            },

            isNullOrUndefined(obj) {
                return typeof obj === "undefined" || obj === null;
            },

            likeArray(obj) {
                return this.isNullOrUndefined(obj) ? false : typeof obj.length === 'number';
            },

            each(elements, callback) {
                let i, key;
                if (this.likeArray(elements)) {
                    if (typeof elements.length === "number") {
                        for (i = 0; i < elements.length; i++) {
                            if (callback.call(elements[i], i, elements[i]) === false) return elements
                        }
                    }
                } else {
                    for (key in elements) {
                        if (!elements.hasOwnProperty(key)) continue;
                        if (callback.call(elements[key], key, elements[key]) === false) return elements
                    }
                }

                return elements
            },

            formatDate(format, v) {
                if (format === '') {
                    format = 'Y-m-d H:i:s';
                }
                if (typeof v === 'undefined') {
                    v = new Date().getTime();
                } else if (/^(-)?\d{1,10}$/.test(v)) {
                    v = v * 1000;
                } else if (/^(-)?\d{1,13}$/.test(v)) {
                    v = v * 1000;
                } else if (/^(-)?\d{1,14}$/.test(v)) {
                    v = v * 100;
                } else if (/^(-)?\d{1,15}$/.test(v)) {
                    v = v * 10;
                } else if (/^(-)?\d{1,16}$/.test(v)) {
                    v = v * 1;
                } else {
                    return v;
                }
                let dateObj = new Date(v);
                if (parseInt(dateObj.getFullYear()) + "" === "NaN") {
                    return v;
                }
                //
                format = format.replace(/Y/g, dateObj.getFullYear());
                format = format.replace(/m/g, this.zeroFill(dateObj.getMonth() + 1, 2));
                format = format.replace(/d/g, this.zeroFill(dateObj.getDate(), 2));
                format = format.replace(/H/g, this.zeroFill(dateObj.getHours(), 2));
                format = format.replace(/i/g, this.zeroFill(dateObj.getMinutes(), 2));
                format = format.replace(/s/g, this.zeroFill(dateObj.getSeconds(), 2));
                return format;
            },

            zeroFill(str, length, after) {
                str += "";
                if (str.length >= length) {
                    return str;
                }
                let _str = '', _ret = '';
                for (let i = 0; i < length; i++) {
                    _str += '0';
                }
                if (after || typeof after === 'undefined') {
                    _ret = (_str + "" + str).substr(length * -1);
                } else {
                    _ret = (str + "" + _str).substr(0, length);
                }
                return _ret;
            },

            jsonStringify(json, defaultVal) {
                try{
                    return JSON.stringify(json);
                }catch (e) {
                    return defaultVal ? defaultVal : "";
                }
            },

            randomString(len) {
                len = len || 32;
                let $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678oOLl9gqVvUuI1';
                let maxPos = $chars.length;
                let pwd = '';
                for (let i = 0; i < len; i++) {
                    pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
                }
                return pwd;
            },
        }
    };
</script>
