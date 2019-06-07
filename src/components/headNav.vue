<template>

    <div class="nav" :style="{backgroundColor:backgroundColor}">
        <div class="title">
            <text class="title-text" :style="{color:color}">{{title}}</text>
            <icon v-if="loading" class="title-load" :style="{color:color}"></icon>
        </div>
        <text v-if="rightTitle !== ''" class="title-right" @click="rightClick">{{rightTitle}}</text>
        <icon v-if="back" class="back" @click="goBack" :content="backIcon"></icon>
    </div>

</template>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        name: 'head-nav',

        props: {
            title: {
                type: String,
                default: '',
            },

            loading: {
                type: Boolean,
                default: false
            },

            back: {
                type: Boolean,
                default: true
            },

            backIcon: {
                type: String,
                default: 'tb-back'
            },

            rightTitle: {
                type: String,
                default: ''
            },

            color: {
                type: String,
                default: '#FFFFFF'
            },

            backgroundColor: {
                type: String,
                default: '#3EB4FF'
            }
        },

        methods: {
            goBack() {
                eeui.closePage();
            },

            rightClick() {
                this.$emit('rightClick');
            }
        }
    }
</script>

<style scoped>
    .nav {
        flex-direction: row;
        align-items: center;
        width: 750px;
        height: 96px;
    }

    .back {
        position: absolute;
        left: 0;
        top: 0;
        width: 96px;
        height: 96px;
        line-height: 96px;
        text-align: center;
        font-size: 38px;
        color: #ffffff;
    }

    .title {
        flex: 1;
        flex-direction: row;
        justify-content: center;
        align-items: center;
    }

    .title-text {
        font-size: 32px;
        font-weight: 300;
        max-width: 520px;
        text-overflow: ellipsis;
        lines: 1;
    }

    .title-load {
        width: 42px;
        height: 42px;
        font-size: 32px;
        margin-left: 6px;
        content: 'tb-loading-d spin';
    }

    .title-right {
        position: absolute;
        right: 0;
        top: 0;
        height: 96px;
        line-height: 96px;
        text-align: center;
        font-size: 26px;
        color: #ffffff;
        padding: 0 26px;
    }
</style>

