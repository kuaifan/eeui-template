<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">城市选择器</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('markets/detail.html#citypicker')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">

            <text class="address">省份：{{province}}</text>
            <text class="address">城市：{{city}}</text>
            <text class="address">区域：{{area}}</text>

            <text class="button" @click="citypicker">选择地址</text>

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

    .address {
        height: 56px;
        line-height: 56px;
        text-align: center;
        font-size: 26px;
    }

    .button {
        font-size: 24px;
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        padding-bottom: 20px;
        width: 220px;
        color: #ffffff;
        background-color: #00B4FF;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');
    const citypicker = app.requireModule('citypicker');

    export default {
        data() {
            return {
                province: '浙江省',
                city: '杭州',
                area: '市辖区'
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            citypicker() {
                if (typeof citypicker === 'undefined') {
                    eeui.alert({
                        title: '温馨提示',
                        message: "检测到未安装citypicker插件，安装详细请登录https://eeui.app/",
                    });
                    return;
                }
                citypicker.select({
                    province: this.province,
                    city: this.city,
                    area: this.area
                }, (result) => {
                    this.province = result.province;
                    this.city = result.city;
                    this.area = result.area;
                });
            }
        }
    };
</script>
