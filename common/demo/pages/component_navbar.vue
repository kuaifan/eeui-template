<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">导航栏</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('component/navbar')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <!--样式①-->
        <navbar class="navbarb">

            <navbar-item type="back"></navbar-item>

            <navbar-item type="title">
                <text class="nav-title">标题</text>
            </navbar-item>

        </navbar>

        <!--样式②-->
        <navbar class="navbarb" :eeui="{titleType:'left'}">

            <navbar-item type="back"></navbar-item>

            <navbar-item type="title">
                <text class="nav-title">标题</text>
            </navbar-item>

        </navbar>

        <!--样式③-->
        <navbar class="navbarb">

            <navbar-item type="back"></navbar-item>

            <navbar-item type="title">
                <text class="nav-title">标题</text>
            </navbar-item>

            <navbar-item type="right">
                <icon content="md-refresh" class="icon"></icon>
            </navbar-item>

        </navbar>

        <!--样式④-->
        <navbar class="navbarc">

            <navbar-item type="left">
                <icon content="md-menu" class="icon"></icon>
            </navbar-item>

            <navbar-item type="title">
                <text class="nav-title">标题</text>
            </navbar-item>

            <navbar-item type="right">
                <icon content="md-refresh" class="icon"></icon>
            </navbar-item>

        </navbar>

        <!--样式⑤-->
        <navbar class="navbarb">

            <!--返回按钮-->
            <navbar-item type="back"></navbar-item>

            <!--左边内容-->
            <navbar-item type="left">
                <text class="nav-title">左边内容</text>
            </navbar-item>

            <!--中间内容(标题内容)-->
            <navbar-item type="title">
                <text class="nav-title">中间(标题)内容</text>
            </navbar-item>

            <!--右边内容-->
            <navbar-item type="right">
                <text class="nav-title">右边内容</text>
            </navbar-item>

        </navbar>

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

    .navbarb {
        width: 750px;
        height: 100px;
        margin-top: 50px;
    }

    .navbarc {
        width: 750px;
        height: 100px;
        margin-top: 50px;
        background-color: #FF5001;
    }

    .nav-title {
        font-size: 24px;
        color: #ffffff
    }

    .icon {
        width: 100px;
        height: 100px;
    }
</style>
<script>
    const eeui = app.requireModule('eeui');

    export default {
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
        }
    };
</script>
