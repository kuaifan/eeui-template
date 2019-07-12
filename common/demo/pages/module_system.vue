<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">系统信息</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('module/system')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">
            <text class="item" v-for="(item, index) in lists" :key="index">{{item}}</text>
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
    }

    .item {
        padding-top: 26px;
        padding-bottom: 26px;
        padding-left: 30px;
        padding-right: 30px;
        font-size: 24px;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                lists: [],
            }
        },

        mounted() {
            this.lists.push("获取状态栏高度（屏幕像素）：" + eeui.getStatusBarHeight());
            this.lists.push("获取状态栏高度（px单位）：" + eeui.getStatusBarHeightPx());
            this.lists.push("获取虚拟键盘高度（屏幕像素）：" + eeui.getNavigationBarHeight());
            this.lists.push("获取虚拟键盘高度（px单位）：" + eeui.getNavigationBarHeightPx());
            this.lists.push("获取本地软件版本号：" + eeui.getLocalVersion());
            this.lists.push("获取本地软件版本号名称：" + eeui.getLocalVersionName());
            this.lists.push("获取手机的IMEI：" + eeui.getImei());
            this.lists.push("获取设备系统版本号：" + eeui.getSDKVersionCode());
            this.lists.push("获取设备系统版本名称：" + eeui.getSDKVersionName());
        },

        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
        }
    };
</script>
