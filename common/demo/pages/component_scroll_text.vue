<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">滚动文字</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('component/scroll-text')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <scroll-text
                ref="reflectName"
                class="scroll_text"
                :eeui="{
                        text: scrollText,
                        speed: 2,
                        fontSize: 32,
                    }"
                @itemClick="itemClick"
        ></scroll-text>

        <scroll-text
                ref="reflectName2"
                class="scroll_text"
                :eeui="{
                        text: scrollText,
                        speed: 10,
                        fontSize: 32,
                        color: '#ff0000',
                        backgroundColor: '#00ffff'
                    }"
                @itemClick="itemClick"
        ></scroll-text>

        <scroll-text
                ref="reflectName3"
                class="scroll_text"
                :eeui="{
                        text: scrollText,
                        speed: 5,
                        fontSize: 24,
                        color: '#6e0a92',
                        backgroundColor: '#c8e7ff'
                    }"
                @itemClick="itemClick"
        ></scroll-text>

    </div>
</template>

<style scoped>
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

    .scroll_text {
        width: 750px;
        margin-top: 50px;
        height: 60px;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                scrollText: "这是一段滚动的文字，可以自定义调整速度的滚动文字~~~~~感谢你对eeui的支持！",
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            itemClick(params) {
                let starting = params.isStarting ? "运行中" : "停止了";
                eeui.toast("我被点击了，当前状态：" + starting);
            },
        }
    };
</script>
