<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">等待弹窗</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('module/loading')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <scroll-view class="content" :eeui="{ pullTips:false }">
            <div v-for="list in sliceLists(lists, 2)" class="list">
                <div class="item" v-for="(item, index) in list" :key="index">
                    <text class="button" @click="loading(item)">样式:{{item}}</text>
                </div>
            </div>
        </scroll-view>

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
        width: 750px;
        flex: 1;
        padding-top: 20px;
    }

    .list {
        width: 750px;
        flex-direction: row;
    }

    .item {
        width: 375px;
        align-items: center;
    }

    .button {
        width: 320px;
        font-size: 24px;
        text-align: center;
        margin-top: 30px;
        padding-top: 26px;
        padding-bottom: 26px;
        padding-left: 30px;
        padding-right: 30px;
        color: #ffffff;
        background-color: #00B4FF;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                lists: [
                    'default',
                    'RotatingPlane',
                    'DoubleBounce',
                    'Wave',
                    'WanderingCubes',
                    'Pulse',
                    'ChasingDots',
                    'ThreeBounce',
                    'Circle',
                    'CubeGrid',
                    'FadingCircle',
                    'FoldingCube',
                    'RotatingCircle'
                ],
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            sliceLists(data, slice) {
                let lists = [];
                for (let i = 0, len = data.length; i < len; i += slice) {
                    lists.push(data.slice(i, i + slice));
                }
                return lists;
            },
            loading(style) {
                eeui.loading({
                    style: style,
                });
            },
        }
    };
</script>
