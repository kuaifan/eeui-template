<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">跑马文字</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('component/marquee')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <marquee
                ref="reflectName"
                class="marquee"
                style="width:750px"
                :eeui="{
                        text: scrollText,
                        fontSize: 24,
                    }"
        ></marquee>

        <marquee
                ref="reflectName2"
                class="marquee"
                style="width:375px"
                :eeui="{
                        text: scrollText,
                        fontSize: 24,
                        color: '#ff0000',
                        backgroundColor: '#00ffff'
                    }"
        ></marquee>

        <marquee
                ref="reflectName3"
                class="marquee"
                style="width:200px"
                :eeui="{
                        text: scrollText,
                        fontSize: 24,
                        color: '#6e0a92',
                        backgroundColor: '#c8e7ff'
                    }"
        ></marquee>

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

    .marquee {
        margin-top: 50px;
        height: 60px;
        background-color: #00B4FF;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                scrollText: "地方不够放时才滚动！",
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
        }
    };
</script>
