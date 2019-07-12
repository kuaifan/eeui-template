<template>

    <div class="app" @lifecycle="lifecycle">

        <head-nav :title="title" :loading="loadIng > 0" back-icon="tb-close"></head-nav>

        <web-view ref="myWebview" class="app" @ready="apiReady" @stateChanged="stateChanged"></web-view>

        <div v-if="!hideBottomNav && (canGoBack || canGoForward)" class="bottom">
            <icon @click="webLeft" :class="[canGoBack?'bottom-icon':'bottom-icon-gray']" content="tb-back"></icon>
            <icon @click="webRight" :class="[canGoForward?'bottom-icon':'bottom-icon-gray']" content="tb-right"></icon>
        </div>

    </div>

</template>

<style scoped>
    .app {
        flex: 1;
    }

    .bottom {
        flex-direction: row;
        justify-content: center;
        align-items: center;
        width: 750px;
        height: 98px;
        background-color: #ffffff;
        border-top-width: 1px;
        border-top-style: solid;
        border-top-color: #EAEAEA;
    }

    .bottom-icon,
    .bottom-icon-gray {
        width: 180px;
        height: 98px;
        font-size: 50px;
        margin-left: 20px;
        margin-right: 20px;
        color: #242424;
    }

    .bottom-icon-gray {
        color: #e4e4e4;
    }
</style>
<script>
    import HeadNav from "../components/headNav.vue";

    const eeui = app.requireModule('eeui');

    export default {
        components: {HeadNav},
        data() {
            return {
                loadIng: 1,

                title: '',
                url: '',
                fixedTitle: false,
                hideBottomNav: false,

                canGoBack: false,
                canGoForward: false,
            }
        },

        mounted() {

        },

        methods: {
            lifecycle(res) {

            },

            apiReady() {
                this.title = this.getObject(app.config.params, 'title');
                this.url = this.getObject(app.config.params, 'url');
                this.fixedTitle = this.getObject(app.config.params, 'fixedTitle') === true;
                this.hideBottomNav = this.getObject(app.config.params, 'hideBottomNav') === true;
                this.$refs.myWebview.setProgressbarVisibility(this.getObject(app.config.params, 'progressbarVisibility') !== false);
                this.$refs.myWebview.setUrl(this.url);
                setTimeout(() => { this.loadIng--; }, 100);
            },

            stateChanged(res) {
                switch (res.status) {
                    case 'start':
                        this.loadIng++;
                        break;

                    case 'success':
                    case 'error':
                        this.loadIng--;
                        this.canGo();
                        break;

                    case 'title':
                        if (this.fixedTitle === false) {
                            this.title = res.title;
                        }
                        break;
                }
            },

            goBack() {
                eeui.closePage();
            },

            webLeft() {
                this.$refs.myWebview.goBack((res) => {
                    this.canGo();
                });
            },

            webRight() {
                this.$refs.myWebview.goForward((res) => {
                    this.canGo();
                });
            },

            canGo() {
                this.$refs.myWebview.canGoBack((result) => {
                    this.canGoBack = result;
                });
                this.$refs.myWebview.canGoForward((result) => {
                    this.canGoForward = result;
                });
            }
        }
    }
</script>
