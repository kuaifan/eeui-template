<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">即时通讯</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('markets/detail.html#websocket')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <scroll-view ref="myLists" class="lists">
            <div v-for="(detail, index) in msgLists" :key="index">
                <div v-if="detail.type==='left'" class="left">
                    <image class="photo" resize="cover" src="https://eeui.app/assets/grid/grid_7.jpg"></image>
                    <div class="detail">
                        <text class="text">{{detail.msg}}</text>
                    </div>
                </div>
                <div v-else class="right">
                    <div class="detail detail-right">
                        <text class="text">{{detail.msg}}</text>
                    </div>
                    <image class="photo" resize="cover" src="https://eeui.app/assets/grid/grid_10.jpg"></image>
                </div>
            </div>
        </scroll-view>

        <div class="bottom">
            <input v-model="sendText" class="bottom-input" :hideDoneButton="true" :upriseOffset="9" placeholder="输入要发送的内容" return-key-type="send" @return="returnSend">
            <text :class="[sendText.trim() === '' ? 'bottom-button-null' : 'bottom-button']" @click="send">发送</text>
            <div class="bottom-line"></div>
        </div>

    </div>
</template>

<style>
    .app {
        width: 750px;
        flex: 1;
    }

    .navbar {
        width: 750px;
        height: 100px;
    }

    .title {
        font-size: 28px;
        color: #ffffff
    }

    .iconr {
        width: 100px;
        height: 100px;
        color: #ffffff;
    }

    .lists {
        flex: 1;
        padding-bottom: 25px;
        background-color: #e8e8e8;
    }

    .left {
        width: 700px;
        flex-direction: row;
        margin-top: 25px;
        margin-left: 25px;
        margin-right: 25px;
    }
    .right {
        width: 700px;
        flex-direction: row;
        justify-content: flex-end;
        margin-top: 25px;
        margin-left: 25px;
        margin-right: 25px;
    }
    .photo {
        width: 90px;
        height: 90px;
        background-color: #ffffff;
        border-radius: 45px;
    }
    .detail {
        margin-left: 24px;
        margin-right: 24px;
        justify-content: center;
        padding: 24px;
        border-radius: 4px;
        background-color: #ffffff;
    }
    .detail-right {
        background-color: #7CBF57;
    }
    .text {
        max-width: 520px;
        font-size: 28px;
    }

    .bottom {
        width: 750px;
        height: 98px;
        flex-direction: row;
        align-items: center;
    }

    .bottom-input {
        width: 570px;
        height: 80px;
        line-height: 80px;
        margin-left: 20px;
        font-size: 28px;
        padding-left: 6px;
        padding-right: 6px;
    }

    .bottom-line {
        position: absolute;
        top: 89px;
        left: 20px;
        width: 570px;
        height: 1px;
        background-color: #dddddd;
    }

    .bottom-button,
    .bottom-button-null {
        width: 130px;
        height: 70px;
        margin-left: 10px;
        margin-right: 20px;
        line-height: 70px;
        font-size: 24px;
        text-align: center;
        color: #ffffff;
        background-color: #00B4FF;
        border-radius: 6px;
    }
    .bottom-button-null {
        background-color: #e4e4e4;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');
    const websocket = app.requireModule('websocket');

    export default {
        data() {
            return {
                url: 'ws://echo.websocket.org',

                onLine: false,
                msgLists: [],
                sendText: '',
            }
        },

        mounted() {
            if (typeof websocket === 'undefined') {
                eeui.alert({
                    title: '温馨提示',
                    message: "检测到未安装websocket插件，安装详细请登录https://eeui.app/",
                });
                return;
            }
            this.connect();
        },

        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },

            connect() {
                let loaddingName = eeui.loading({
                    title: '正在连接，请稍后...',
                });
                websocket.connect(this.url, (result) => {
                    switch (result.status) {
                        case 'open': //连接已经准备好接受和发送数据
                            eeui.loadingClose(loaddingName);
                            this.onLine = true;
                            this.addMsg({
                                type: 'left',
                                msg: '请问您有什么问题？'
                            });
                            break;

                        case 'message': //接收到新消息：result.msg
                            this.addMsg({
                                type: 'left',
                                msg: result.msg
                            });
                            break;

                        case 'closed':
                        case 'failure':
                        case 'error': //连接关闭
                            eeui.loadingClose(loaddingName);
                            eeui.confirm({
                                title: "温馨提示",
                                message: "连接关闭，点击确定重新连接？",
                                buttons: ["取消", "确定"]
                            }, (result) => {
                                if (result.status === "click") {
                                    if (result.title === "确定") {
                                        this.connect();
                                    }else{
                                        eeui.closePage();
                                    }
                                }
                            });
                            break;
                    }
                });
            },

            addMsg(data) {
                this.msgLists.push(data);
                setTimeout(() => {
                    this.$refs.myLists.smoothScrollToPosition(-1);
                }, 300);
            },

            send() {
                let msg = this.sendText.trim();
                if (msg === "") {
                    eeui.toast("请输入要发送的内容！");
                    return;
                }
                this.sendText = "";
                eeui.keyboardHide();
                if (!this.onLine) {
                    eeui.alert({
                        title: '温馨提示',
                        message: "检测到未安装websocket插件，安装详细请登录https://eeui.app/",
                    });
                    return;
                }
                this.addMsg({
                    type: 'right',
                    msg: msg
                });
                websocket.send(msg);
            },

            returnSend(data) {
                if (data.returnKeyType === 'send') {
                    this.send(data.value);
                }
            },

            startAjax() {
                this.status = "";
                this.content = "";
                eeui.ajax({
                    url: this.url,
                    dataType: 'text',
                }, (res) => {
                    if (this.status === "") {
                        this.status+= res.status;
                    }else{
                        this.status+= " > " + res.status;
                    }
                    if (res.status === "success") {
                        this.content = res.result;
                    }
                });
            },
        }
    };
</script>
