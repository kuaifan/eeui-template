<template>
    <div class="app">

        <side-panel
                ref="reflectName"
                class="side_panel"
                :eeui="{
                        width: '420px',
                        scrollbar: false,
                        backgroundColor: '#26c9ff'
                    }"
                @itemClick="itemClick"
                @switchListener="switchListener">

            <!--侧滑菜单部分-->
            <side-panel-menu class="panel_menu" name="菜单1">
                <text class="menu-text">菜单①</text>
            </side-panel-menu>

            <side-panel-menu class="panel_menu" name="菜单2">
                <text class="menu-text">菜单②</text>
            </side-panel-menu>

            <!--正文内容部分-->
            <div class="content">
                <!--正文标题栏-->
                <navbar class="content-navbar">
                    <navbar-item type="back"></navbar-item>
                    <navbar-item type="title">
                        <text class="title">侧边栏</text>
                    </navbar-item>
                    <navbar-item type="right" @click="viewCode('component/side-panel')">
                        <icon content="md-code-working" class="iconr"></icon>
                    </navbar-item>
                </navbar>
                <!--正文内容-->
                <div class="content-body">
                    <text style="font-size:24px">正文内容，屏幕右划试试看。</text>
                    <text class="content-body-toggle" @click="menuToggle">切换显示状态</text>
                </div>
            </div>

        </side-panel>

    </div>
</template>

<style scoped>
    .app {
        width: 750px;
        flex: 1;
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

    .side_panel {
        width: 750px;
        flex: 1;
    }

    .panel_menu {
        width: 420px;
        padding-top: 26px;
        padding-bottom: 26px;
        padding-right: 20px;
        padding-left: 20px;
        border-bottom-width: 1px;
        border-bottom-style: solid;
        border-bottom-color: #ffffff;
    }

    .menu-text {
        color: #ffffff;
        font-size: 26px;
    }

    .content {
        width: 750px;
    }

    .content-navbar {
        width: 750px;
        height: 100px;
    }

    .content-body {
        width: 750px;
        margin-top: 200px;
        justify-content: center;
        align-items: center;
    }

    .content-body-toggle {
        width: 300px;
        font-size: 24px;
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        padding-bottom: 20px;
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
            itemClick(params) {
                eeui.toast("点击了" + (params.position + 1) + "项，name：" + params.name);
            },
            switchListener(params) {
                eeui.toast("侧边栏：" + (params.show ? "显示了" : "隐藏了"));
            },
            menuToggle() {
                this.$refs.reflectName.menuToggle();
            },
        }
    };
</script>
