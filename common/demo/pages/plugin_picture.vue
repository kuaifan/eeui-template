<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">图片选择器</text>
            </navbar-item>
            <navbar-item type="right" @click="viewCode('markets/detail.html#picture')">
                <icon content="md-code-working" class="iconr"></icon>
            </navbar-item>
        </navbar>

        <div class="content">

            <scroll-view v-if="lists.length > 0"
                        :style="{width:'750px', height: (Math.ceil(lists.length / 5) * 150) + 'px'}"
                        :eeui="{pullTips:false}">
                <div v-for="list in sliceLists(lists, 5)" class="list">
                    <div v-for="item in list" class="imgbox" @click="pictureView(item.position)">
                        <image :src="'file://' + item.path" class="image" resize="cover"></image>
                    </div>
                </div>
            </scroll-view>

            <text class="button" @click="openPicture">选择照片</text>
            <text v-if="lists.length > 0" class="button2" @click="lists=[]">清空选择</text>

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

    .list {
        width: 750px;
        flex-direction: row;
        justify-content: center;
    }

    .imgbox {
        width: 150px;
        height: 150px;
    }

    .image {
        width: 130px;
        height: 130px;
        margin-top: 10px;
        margin-bottom: 10px;
        margin-right: 10px;
        margin-left: 10px;
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

    .button2 {
        margin-top: 24px;
        color: #00B4FF;
        font-size: 24px;
        border-bottom-width: 1px;
        border-bottom-style: solid;
        border-bottom-color: #00B4FF;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');
    const picture = app.requireModule('picture');

    export default {
        data() {
            return {
                lists: []
            }
        },
        methods: {
            viewCode(str) {
                this.openViewCode(str);
            },
            sliceLists(data, slice) {
                let lists = [];
                let j = 0;
                for (let i = 0, len = data.length; i < len; i += slice) {
                    let temp = [];
                    this.each(data.slice(i, i + slice), (index, item) => {
                        item.position = j;
                        temp.push(item);
                        j++;
                    });
                    lists.push(temp);
                }
                return lists;
            },
            openPicture() {
                if (typeof picture === 'undefined') {
                    eeui.alert({
                        title: '温馨提示',
                        message: "检测到未安装picture插件，安装详细请登录https://eeui.app/",
                    });
                    return;
                }
                picture.create({
                    gallery: 1,
                    selected: this.lists
                }, (result) => {
                    if (result.status === "success") {
                        this.lists = result.lists;
                    }
                });
            },
            pictureView(position) {
                if (typeof picture === 'undefined') {
                    eeui.alert({
                        title: '温馨提示',
                        message: "检测到未安装picture插件，安装详细请登录https://eeui.app/",
                    });
                    return;
                }
                picture.picturePreview(position, this.lists);
            }
        }
    };
</script>
