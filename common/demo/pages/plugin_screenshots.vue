<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">组件截图</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('markets/detail.html#screenshots')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div ref="content" class="content">
            <image class="img" :src="img"></image>
            <text class="txt">{{src}}</text>
            <text class="button" @click="shots">截屏</text>
        </div>
    </div>
</template>
<style>
    .app {
        align-items: center;
        justify-content: center
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

    .txt {
        font-size: 22px;
        margin-bottom: 20px
    }

    .button {
        font-size: 24px;
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        padding-bottom: 20px;
        margin-left: 225px;
        margin-right: 225px;
        width: 300px;
        color: #ffffff;
        background-color: #00B4FF;
    }

    .img {
        width: 300px;
        height: 400px;
        margin-bottom: 20px;
        background-color: red
    }
</style>
<script>
    const eeui = app.requireModule('eeui');
    const screenshots = app.requireModule('screenshots');

    export default {
        data() {
            return {
                src: '',
                img: ''
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },

            shots() {
                if (typeof screenshots === 'undefined') {
                    eeui.alert({
                        title: '温馨提示',
                        message: "检测到未安装screenshots插件，安装详细请登录https://eeui.app/",
                    });
                    return;
                }
                screenshots.shots(this.$refs.content, (p) => {
                    if (p.status === 'success') {
                        this.src = p.path;
                        this.img = "file://" + p.path + "?r=" + Math.random();
                    }
                });
            }
        }
    }
</script>
