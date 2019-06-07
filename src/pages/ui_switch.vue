<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">Switch 开关</text>
            </navbar-item>
        </navbar>

        <div class="main">
            <text class="status">当前状态：{{status}}</text>
            <WSwitch class="switch" v-model="status"></WSwitch>
        </div>

    </div>
</template>

<style scoped>
    .app {
        width: 750px;
        flex: 1;
        background-color: #ffffff;
    }

    .navbar {
        width: 750px;
        height: 100px;
    }

    .title {
        font-size: 28px;
        color: #ffffff
    }

    .main {
        flex: 1;
        align-items: center;
        justify-content: center;
    }

    .status {
        font-size: 26px;
        margin-bottom: 24px;
    }

    .switch {
        width: 120px;
        height: 60px;
    }
</style>

<script>

    import WSwitch from "../../common/demo/components/WSwitch";
    const eeui = app.requireModule('eeui');

    export default {
        components: {WSwitch},
        data() {
            return {
                status: true,
            }
        },

        methods: {

        }
    };
</script>
