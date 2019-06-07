<template>
    <div class="app">

        <tabbar
                ref="reflectName"
                class="tabbar"
                :eeui="{ tabType: 'bottom' }"
                @pageSelected="pageSelected"
                @tabReselect="tabReselect"
                @refreshListener="refreshListener">

            <!--页签①-->
            <tabbar-page :eeui="{ tabName: 'name_1', title:'首页', selectedIcon:'md-home' }">
                <navbar class="page-navbar">
                    <navbar-item type="back"></navbar-item>
                    <navbar-item type="title">
                        <text class="page-navbar-title">首页</text>
                    </navbar-item>
                    <navbar-item type="right" @click="viewCode('component/tabbar')">
                        <icon content="md-code-working" class="iconr"></icon>
                    </navbar-item>
                </navbar>
                <div class="page-content">
                    <text style="font-size:24px">页签里面可以放任何子组件，感谢你对eeui的支持</text>
                    <image src="https://eeui.app/assets/images/cartoon/m2.png"
                           class="page-content-image"></image>
                </div>
            </tabbar-page>

            <!--页签②-->
            <tabbar-page
                    :eeui="{ tabName: 'name_2', title:'好友', message:3, selectedIcon:'https://eeui.app/assets/images/cartoon/m8.png' , unSelectedIcon:'https://eeui.app/assets/images/cartoon/m7.png' }">
                <navbar class="page-navbar">
                    <navbar-item type="title">
                        <text class="page-navbar-title">好友</text>
                    </navbar-item>
                </navbar>
                <div class="page-content">
                    <text style="font-size:24px">page 2，图标支持网络图片</text>
                </div>
            </tabbar-page>

            <!--页签③-->
            <tabbar-page :eeui="{ tabName: 'name_3', title:'圈子', message:99, selectedIcon:'md-aperture' }">
                <navbar class="page-navbar">
                    <navbar-item type="title">
                        <text class="page-navbar-title">圈子</text>
                    </navbar-item>
                </navbar>
                <div class="page-content">
                    <text style="font-size:24px">page 3</text>
                </div>
            </tabbar-page>

            <!--页签④-->
            <tabbar-page :eeui="{ tabName: 'name_4', title:'设置', dot:true, selectedIcon:'md-cog' }">
                <navbar class="page-navbar">
                    <navbar-item type="title">
                        <text class="page-navbar-title">设置</text>
                    </navbar-item>
                </navbar>
                <div class="page-content">
                    <text style="font-size:24px">page 4</text>
                </div>
            </tabbar-page>

        </tabbar>

    </div>
</template>

<style>
    .app {
        flex: 1
    }

    .iconr {
        width: 100px;
        height: 100px;
        color: #ffffff;
    }

    .tabbar {
        width: 750px;
        flex: 1;
    }

    .page-content {
        width: 750px;
        padding-top: 200px;
        justify-content: center;
        align-items: center;
    }

    .page-navbar {
        width: 750px;
        height: 90px;
    }

    .page-navbar-title {
        color: #ffffff;
        font-size: 28px;
    }

    .page-content-image {
        width: 480px;
        height: 480px;
        margin-top: 30px;
        margin-bottom: 30px;
    }
</style>

<script>
    import {openViewCode} from "../../common/js/common";

    const eeui = app.requireModule('eeui');

    export default {
        methods: {
            viewCode(str) {
                openViewCode(str);
            },
            pageSelected(params) {
                eeui.toast({
                    message: "切换到第" + (params.position + 1) + "个标签页",
                    gravity: "middle"
                });
            },
            tabReselect(params) {
                eeui.toast({
                    message: "第" + (params.position + 1) + "个标签页被再次点击",
                    gravity: "middle"
                });
                eeui.toast();
            },
            refreshListener(params) {
                setTimeout(() => {
                    eeui.toast({
                        message: "刷新成功：第" + (params.position + 1) + "个标签页",
                        gravity: "middle"
                    });
                    this.$refs.reflectName.setRefreshing(params['tabName'], false);
                }, 1000);
            }
        }
    };
</script>
