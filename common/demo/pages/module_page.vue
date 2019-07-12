<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">页面功能</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('module/newPage')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">
            <text class="button" @click="openPage">打开一个普通的页面</text>
            <text class="button" @click="openPage2">打开一个沉浸式页面</text>
            <text class="button" @click="openPage3">打开一个全屏的页面</text>
            <text class="button" @click="openPage4">打开一个WEB页面</text>

            <div class="item" @click="isLight = !isLight">
                <text class="item-title">状态栏字体颜色</text>
                <div class="item-input"></div>
                <w-switch class="switch" v-model="isLight"></w-switch>
            </div>

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
        margin-top: 20px;
        margin-bottom: 20px;
        padding-top: 26px;
        padding-bottom: 26px;
        padding-left: 30px;
        padding-right: 30px;
        color: #ffffff;
        background-color: #00B4FF;
    }

    .item {
        width: 380px;
        height: 100px;
        flex-direction: row;
        align-items: center;
        background-color: #ffffff;
        margin-top: 20px;
        margin-bottom: 20px;
    }
    .item-title {
        font-size: 28px;
        margin-left: 24px;
        margin-right: 34px;
        color: #242424;
    }
    .item-input {
        flex: 1;
        font-size: 28px;
        height: 80px;
        padding-right: 24px;
        text-align: right;
    }
    .switch {
        width: 86px;
        height: 50px;
        margin-right: 24px;
    }
</style>

<script>
    import WSwitch from "../components/WSwitch.vue";

    const eeui = app.requireModule('eeui');

    export default {
        components: {WSwitch},
        data() {
            return {
                isLight: false,
            }
        },
        mounted() {
            eeui.statusBarStyle(this.isLight);
        },
        watch: {
            isLight(val) {
                eeui.statusBarStyle(val);
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            openPage() {
                eeui.openPage({
                    url: 'http://dotwe.org/raw/dist/25f26c060a9358ebfce419f1a0dc7f9b.bundle.wx',
                });
            },
            openPage2() {
                eeui.openPage({
                    url: 'http://dotwe.org/raw/dist/a3ccb0407c780c120c65ade15c6c7110.bundle.wx',
                    statusBarType: 'immersion',
                });
            },
            openPage3() {
                eeui.openPage({
                    url: 'http://dotwe.org/raw/dist/c7f96bf3571cc23a94127a6835d1c7a4.bundle.wx',
                    statusBarType: 'fullscreen',
                });
            },
            openPage4() {
                eeui.openPage({
                    url: 'https://eeui.app',
                    pageType: 'web',
                });
            },
        }
    };
</script>
