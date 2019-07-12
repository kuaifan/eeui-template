<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">列表容器</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('component/scroll-view')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <scroll-view
                ref="reflectName"
                class="list"
                :eeui="{
                        pullTips: true,
                    }"
                @itemClick="itemClick"
                @pullLoadListener="pullLoadListener"
                @refreshListener="refreshListener">
            <div class="panel" v-for="num in lists">
                <div class="panel-item">
                    <text class="panel-text">{{num}}</text>
                </div>
            </div>
        </scroll-view>

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

    .list {
        width: 750px;
        flex: 1
    }

    .panel {
        width: 750px;
        border-bottom-color: #e4e4e4;
        border-bottom-style: solid;
        border-bottom-width: 1px;
    }

    .panel-item {
        width: 750px;
        padding-top: 22px;
        padding-bottom: 22px;
        flex-direction: column;
        justify-content: center;
    }

    .panel-text {
        font-size: 50px;
        text-align: center;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                lists: [],
            }
        },
        mounted() {
            for (let i = 1; i <= 20; i++) {
                this.lists.push(i);
            }
            this.$refs.reflectName.setHasMore(true);
            //
            setTimeout(() => {
                this.lists.splice(2, 1, "改变第三项文字")
                // splice 详细用法http://www.w3school.com.cn/jsref/jsref_splice.asp
            }, 1000);
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            itemClick(params) {
                eeui.toast("点击了" + (params.position + 1) + "项");
            },
            pullLoadListener() {
                let count = this.lists.length;
                if (count >= 100) {
                    this.$refs.reflectName.setHasMore(false);
                    return;
                }
                setTimeout(() => {
                    for (let i = 1; i <= 20; i++) {
                        this.lists.push(count + i);
                    }
                    this.$refs.reflectName.pullloaded();
                    eeui.toast("加载" + (count + 1) + "~" + this.lists.length + "数据成功");
                }, 1000);

            },
            refreshListener() {
                let newList = [];
                for (let i = 1; i <= 20; i++) {
                    newList.push(i);
                }
                setTimeout(() => {
                    this.lists = newList;
                    this.$refs.reflectName.setHasMore(true);
                    this.$refs.reflectName.refreshed();
                    eeui.toast("刷新数据成功");
                }, 1000);

            },
        }
    };
</script>
