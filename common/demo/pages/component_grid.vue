<template>

    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">分页网格容器</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('component/grid')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <grid class="grid" @itemClick="itemClick">

            <div class="grid-item" v-for="item in gridLists">
                <image class="item-image" resize="cover"
                       :src="'https://eeui.app/assets/grid/' + item + '.jpg'"></image>
                <text class="item-title">{{item}}</text>
            </div>

        </grid>

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

    .grid {
        width: 750px;
        margin-top: 10px;
        height: 570px;
    }

    .grid-item {
        width: 250px;
        height: 180px;
        align-items: center;
    }

    .item-image {
        margin-top: 10px;
        width: 120px;
        height: 120px;
        border-radius: 90px;
    }

    .item-title {
        width: 250px;
        height: 50px;
        font-size: 24px;
        line-height: 50px;
        text-align: center;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                gridLists: ["grid_1", "grid_2", "grid_3", "grid_4", "grid_5", "grid_6", "grid_7", "grid_8", "grid_9", "grid_10", "grid_11", "grid_12", "grid_13", "grid_14", "grid_15", "grid_16", "grid_17", "grid_18", "grid_19", "grid_20", "grid_21", "grid_22", "grid_23", "grid_24", "grid_25", "grid_26", "grid_27", "grid_28", "grid_29", "grid_30", "grid_31", "grid_32"],
            }
        },

        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            itemClick(data) {
                eeui.toast("点击第" + (data.page + 1) + "页第" + (data.position + 1) + "个，总序号第" + (data.index + 1) + "个");
            },
        }
    };
</script>
