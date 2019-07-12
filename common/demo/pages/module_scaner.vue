<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">二维码扫描</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('module/scaner')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">
            <text class="button" @click="openScaner">打开二维码扫描</text>
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
        font-size: 24px;
        text-align: center;
        margin-top: 20px;
        margin-bottom: 20px;
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
            openScaner() {
                eeui.openScaner(null, (res) => {
                    switch (res.status) {
                        case "success":
                            eeui.toast("识别成功：" + res.text);
                            break;

                        case "failed":
                            eeui.toast("识别失败");
                            break;
                    }
                });
            },
        }
    };
</script>
