<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">确认对话框</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('module/alert')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">
            <text class="button" @click="toAlert">alert</text>
            <text class="button" @click="toAlert2">alert 带标题</text>
            <text class="button" @click="toConfirm">confirm</text>
            <text class="button" @click="toConfirm2">confirm 3个按钮</text>
            <text class="button" @click="toInput">input</text>
            <text class="button" @click="toInput2">input 2个输入框</text>
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

    .content {
        flex: 1;
        justify-content: center;
        align-items: center;
    }

    .button {
        width: 380px;
        font-size: 24px;
        text-align: center;
        margin-top: 16px;
        margin-bottom: 16px;
        padding-top: 26px;
        padding-bottom: 26px;
        padding-left: 30px;
        padding-right: 30px;
        color: #ffffff;
        background-color: #00B4FF;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            toAlert() {
                eeui.alert('感谢你使用EEUI！', function() {
                    eeui.toast("点击了确定！")
                });

            },
            toAlert2() {
                eeui.alert({
                    title: '温馨提示',
                    message: '感谢你使用EEUI！',
                }, function() {
                    eeui.toast("点击了确定！")
                });
            },
            toConfirm() {
                eeui.confirm("确定感谢你使用EEUI！", function(result) {
                    if (result.status == "click") {
                        eeui.toast("点击了：" + result.title)
                    }
                });
            },
            toConfirm2() {
                eeui.confirm({
                    title: "温馨提示",
                    message: "确定感谢你使用EEUI！",
                    buttons: ["取消", "确定", "第三个按钮"],
                }, function(result) {
                    if (result.status == "click") {
                        eeui.toast("点击了：" + result.title)
                    }
                });
            },
            toInput() {
                eeui.input({
                    title: "输入昵称",
                    buttons: ["取消", "确定"],
                    inputs:[{
                        type: 'text',
                    }]
                }, function(result) {
                    if (result.status == "click" && result.title == "确定") {
                        eeui.toast("昵称：" + result.data[0])
                    }
                });
            },
            toInput2() {
                eeui.input({
                    title: "输入昵称和真实姓名",
                    buttons: ["取消", "确定"],
                    inputs:[{
                        type: 'text',
                        placeholder: '请输入昵称',
                    },{
                        type: 'text',
                        placeholder: '请输入真实姓名',
                    }]
                }, function(result) {
                    if (result.status == "click" && result.title == "确定") {
                        eeui.toast("昵称：" + result.data[0] + "，真实姓名：" + result.data[1])
                    }
                });
            }
        }
    };
</script>
