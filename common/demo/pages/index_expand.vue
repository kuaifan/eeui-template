<template>

    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">拓展模块</text>
            </navbar-item>
        </navbar>


        <scroller class="list">

            <div class="list-title-box">
                <text class="list-title">Expand Module</text>
                <text class="list-subtitle">（暂不支持ios）</text>
            </div>

            <div class="list-item" v-for="(item, key) in expand_module" :key="key" @click="expandModuleClick(item.url)">
                <div class="list-item-left">
                    <icon class="list-left-icon" :eeui="{content: item.icon}"></icon>
                    <text class="list-left-title">{{item.title}}</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title">{{item.title_en}}</text>
                    <icon class="list-right-icon" :eeui="{content: 'tb-right'}"></icon>
                </div>
            </div>

        </scroller>

    </div>

</template>

<style>
    .app {
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

    .list {
        width: 750px;
        flex: 1;
    }

    .list-title-box {
        flex-direction: row;
        align-items: center;
    }

    .list-title {
        padding-top: 36px;
        padding-right: 8px;
        padding-bottom: 24px;
        padding-left: 24px;
        font-size: 28px;
        color: #757575;
    }

    .list-subtitle {
        padding-top: 12px;
        font-size: 22px;
        color: #bbbbbb;
    }

    .list-item {
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        height: 100px;
        flex: 1;
        padding-left: 20px;
        padding-right: 20px;
        border-top-width: 1px;
        border-top-color: #e8e8e8;
        border-top-style: solid;
    }

    .list-item-left {
        flex-direction: row;
        align-items: center;
        justify-content: flex-start;
        height: 100px;
        flex: 1;
    }

    .list-left-icon {
        width: 60px;
        height: 60px;
        color: #3EB4FF;
    }

    .list-left-title {
        color: #242424;
        padding-left: 12px;
        width: 380px;
        font-size: 26px;
        text-overflow: ellipsis;
        lines: 1;
    }

    .list-right-title {
        color: #a2a2a2;
        padding-right: 3px;
        font-size: 22px;
        text-overflow: ellipsis;
        lines: 1;
    }

    .list-right-icon {
        width: 40px;
        height: 40px;
        font-size: 22px;
        color: #C9C9CE;
    }

    .list-item-right {
        flex-direction: row;
        align-items: center;
        justify-content: flex-end;
        height: 100px;
    }
</style>

<script>
    import {openViewCode} from "../../common/js/common";

    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                expand_module: [{
                    title: 'APP相关',
                    title_en: 'appUtils',
                    icon: 'logo-ionic',
                    url: 'appUtils',
                }, {
                    title: '设备相关',
                    title_en: 'deviceUtils',
                    icon: 'logo-ionic',
                    url: 'deviceUtils',
                }, {
                    title: '网络相关',
                    title_en: 'networkUtils',
                    icon: 'logo-ionic',
                    url: 'networkUtils',
                }, {
                    title: '权限相关',
                    title_en: 'permissionUtils',
                    icon: 'logo-ionic',
                    url: 'permissionUtils',
                }, {
                    title: '手机相关',
                    title_en: 'phoneUtils',
                    icon: 'logo-ionic',
                    url: 'phoneUtils',
                }, {
                    title: '进程相关',
                    title_en: 'processUtils',
                    icon: 'logo-ionic',
                    url: 'processUtils',
                }, {
                    title: '屏幕相关',
                    title_en: 'screenUtils',
                    icon: 'logo-ionic',
                    url: 'screenUtils',
                }, {
                    title: '时间相关',
                    title_en: 'timeUtils',
                    icon: 'logo-ionic',
                    url: 'timeUtils',
                }, {
                    title: '摄像相关',
                    title_en: 'cameraTool',
                    icon: 'logo-ionic',
                    url: 'cameraTool',
                }, {
                    title: '定位相关',
                    title_en: 'locationTool',
                    icon: 'logo-ionic',
                    url: 'locationTool',
                }, {
                    title: '震动相关',
                    title_en: 'vibrateTool',
                    icon: 'logo-ionic',
                    url: 'vibrateTool',
                }],
            }
        },

        methods: {

            expandModuleClick(url) {
                openViewCode("module/expand/" + url);
            },

        }
    };
</script>
