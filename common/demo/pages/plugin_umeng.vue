<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">友盟推送模块</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('markets/detail.html#umeng')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">

            <text class="info">{{info}}</text>
            <text class="button" @click="getToken">获取token</text>

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

    .info {
        font-size: 22px;
        margin-bottom: 20px
    }

    .button {
        font-size: 24px;
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        padding-bottom: 20px;
        width: 220px;
        color: #ffffff;
        background-color: #00B4FF;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');
    const umeng = app.requireModule('umeng');

    export default {
        data() {
            return {
                info: '',
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },

            getToken() {
                if (typeof umeng === 'undefined') {
                    eeui.alert({
                        title: '温馨提示',
                        message: "检测到未安装umeng插件，安装详细请登录https://eeui.app/",
                    });
                    return;
                }
                this.info = umeng.getToken();
            }
        }
    };
</script>
