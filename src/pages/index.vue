<template>

    <div class="app">

        <navbar class="navbar">
            <navbar-item type="left" @click="scaner">
                <icon class="navbar-icon" :eeui="{content: 'tb-scan'}"></icon>
            </navbar-item>

            <navbar-item type="title">
                <div class="navbar-main">
                    <image class="navbar-logo" src="logo-white.png"></image>
                    <text class="navbar-title">EEUI</text>
                </div>
            </navbar-item>

            <navbar-item type="right" @click="refresh">
                <icon class="navbar-icon" :eeui="{content: 'md-refresh'}"></icon>
            </navbar-item>
        </navbar>

        <scroll-view class="list">

            <text class="list-title">组件 Components</text>

            <div class="list-item" v-for="(item, index) in components" :key="index" @click="openUrl(item.url)">
                <div class="list-item-left">
                    <icon class="list-left-icon" :eeui="{content: item.icon}"></icon>
                    <text class="list-left-title">{{item.title}}</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title"><{{item.title_en}}></text>
                    <icon class="list-right-icon"></icon>
                </div>
            </div>

            <text class="list-title">自定义组件 UI</text>

            <div class="list-item" v-for="(item, index) in uis" :key="index" @click="openUrl(item.url)">
                <div class="list-item-left">
                    <icon class="list-left-icon" :eeui="{content: item.icon}"></icon>
                    <text class="list-left-title">{{item.title}}</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title"><{{item.title_en}}></text>
                    <icon class="list-right-icon"></icon>
                </div>
            </div>

            <text class="list-title">模块 Module</text>

            <div class="list-item" v-for="(item, index) in module" :key="index" @click="openUrl(item.url)">
                <div class="list-item-left">
                    <icon class="list-left-icon" :eeui="{content: item.icon}"></icon>
                    <text class="list-left-title">{{item.title}}</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title">{{item.title_en}}</text>
                    <icon class="list-right-icon"></icon>
                </div>
            </div>

            <text class="list-title">插件化 Plugins</text>

            <div class="list-item" v-for="(item, index) in plugin" :key="index" @click="openUrl(item.url)">
                <div class="list-item-left">
                    <icon class="list-left-icon" :eeui="{content: item.icon}"></icon>
                    <text class="list-left-title">{{item.title}}</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title">{{item.title_en}}</text>
                    <icon class="list-right-icon"></icon>
                </div>
            </div>
            <div class="list-item" @click="openWeb('https://eeui.app/markets/')">
                <div class="list-item-left">
                    <icon class="list-left-icon" content="tb-more"></icon>
                    <text class="list-left-title">更多插件</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title"></text>
                    <icon class="list-right-icon"></icon>
                </div>
            </div>

            <text class="list-title">关于 About EEUI</text>

            <div class="list-item" v-for="(item, index) in abouts" :key="index" @click="openWeb(item.url)">
                <div class="list-item-left">
                    <icon class="list-left-icon" :eeui="{content: item.icon}"></icon>
                    <text class="list-left-title">{{item.title}}</text>
                </div>
                <div class="list-item-right">
                    <text class="list-right-title">{{item.title_en}}</text>
                    <icon class="list-right-icon"></icon>
                </div>
            </div>

            <div class="list-title-box" v-if="history.length > 0">
                <text class="list-title">扫码历史</text>
                <text class="list-subtitle" @click="clearHistory()">清空历史</text>
            </div>

            <div v-if="history.length > 0">
                <div class="list-item" v-for="(text, index) in history" :key="index" @click="openAuto(text)">
                    <div class="list-item-left">
                        <text class="list-left-title-history">{{text}}</text>
                    </div>
                    <div class="list-item-right">
                        <icon class="list-right-icon"></icon>
                    </div>
                </div>
            </div>

        </scroll-view>

    </div>

</template>

<style scoped>
    .app {
        flex: 1;
    }

    .navbar {
        width: 750px;
        height: 100px;
    }

    .navbar-main {
        flex-direction: row;
        align-items: center;
    }

    .navbar-logo {
        width: 36px;
        height: 36px;
        margin-right: 18px;
    }

    .navbar-title {
        font-size: 32px;
        color: #ffffff;
    }

    .navbar-icon {
        width: 100px;
        height: 100px;
        color: #ffffff;
    }

    .list {
        width: 750px;
        flex: 1;
    }

    .list-title-box {
        flex-direction: row;
        align-items: center;
    }

    .list-title {
        padding-top: 36px;
        padding-right: 24px;
        padding-bottom: 24px;
        padding-left: 24px;
        font-size: 28px;
        color: #757575;
    }

    .list-subtitle {
        position: absolute;
        right: 24px;
        bottom: 24px;
        font-size: 24px;
    }

    .list-item {
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        height: 100px;
        width: 750px;
        padding-left: 20px;
        padding-right: 20px;
        border-top-width: 1px;
        border-top-color: #e8e8e8;
        border-top-style: solid;
    }

    .list-item-left {
        flex-direction: row;
        align-items: center;
        justify-content: flex-start;
        height: 100px;
        flex: 1;
    }

    .list-left-icon {
        width: 60px;
        height: 60px;
        color: #3EB4FF;
    }

    .list-left-title {
        color: #242424;
        padding-left: 12px;
        width: 380px;
        font-size: 26px;
        text-overflow: ellipsis;
        lines: 1;
    }

    .list-left-title-history {
        color: #242424;
        padding-left: 12px;
        width: 660px;
        font-size: 26px;
        text-overflow: ellipsis;
        lines: 1;
    }

    .list-right-title {
        color: #a2a2a2;
        padding-right: 3px;
        font-size: 22px;
        text-overflow: ellipsis;
        lines: 1;
    }

    .list-right-icon {
        font-size: 24px;
        width: 40px;
        height: 40px;
        color: #C9C9CE;
        content: 'tb-right'
    }

    .list-item-right {
        flex-direction: row;
        align-items: center;
        justify-content: flex-end;
        height: 100px;
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                components: [],
                uis: [],
                module: [],
                plugin: [],
                abouts: [],
                history: [],
            }
        },

        mounted() {
            this.components = [
                {
                    title: '轮播控件',
                    title_en: 'banner',
                    icon: 'md-easel',
                    url: this.resourceUrl + 'component_banner.js',
                }, {
                    title: '常用按钮',
                    title_en: 'button',
                    icon: 'logo-youtube',
                    url: this.resourceUrl + 'component_button.js',
                }, {
                    title: '网格容器',
                    title_en: 'grid',
                    icon: 'md-grid',
                    url: this.resourceUrl + 'component_grid.js',
                }, {
                    title: '字体图标',
                    title_en: 'icon',
                    icon: 'logo-ionic',
                    url: this.resourceUrl + 'component_icon.js',
                }, {
                    title: '跑马文字',
                    title_en: 'marquee',
                    icon: 'md-code-working',
                    url: this.resourceUrl + 'component_marquee.js',
                }, {
                    title: '导航栏',
                    title_en: 'navbar',
                    icon: 'md-menu',
                    url: this.resourceUrl + 'component_navbar.js',
                }, {
                    title: '列表容器',
                    title_en: 'scroll-view',
                    icon: 'md-list',
                    url: this.resourceUrl + 'component_list.js',
                }, {
                    title: '滚动文字',
                    title_en: 'scroll-text',
                    icon: 'ios-more',
                    url: this.resourceUrl + 'component_scroll_text.js',
                }, {
                    title: '侧边栏',
                    title_en: 'side-panel',
                    icon: 'md-albums',
                    url: this.resourceUrl + 'component_side_panel.js',
                }, {
                    title: '标签页面',
                    title_en: 'tabbar',
                    icon: 'md-filing',
                    url: this.resourceUrl + 'component_tabbar.js',
                }
            ];
            this.uis = [
                {
                    title: 'Echarts图表',
                    title_en: 'w-echarts',
                    icon: 'md-trending-up',
                    url: this.resourceUrl + 'ui_echarts.js',
                },{
                    title: 'Switch开关',
                    title_en: 'w-switch',
                    icon: 'md-switch',
                    url: this.resourceUrl + 'ui_switch.js',
                }
            ];
            this.module = [
                {
                    title: '页面功能',
                    title_en: 'newPage',
                    icon: 'md-book',
                    url: this.resourceUrl + 'module_page.js',
                }, {
                    title: '系统信息',
                    title_en: 'system',
                    icon: 'ios-cog',
                    url: this.resourceUrl + 'module_system.js',
                }, {
                    title: '数据缓存',
                    title_en: 'caches',
                    icon: 'md-beaker',
                    url: this.resourceUrl + 'module_caches.js',
                }, {
                    title: '确认对话框',
                    title_en: 'alert',
                    icon: 'md-alert',
                    url: this.resourceUrl + 'module_alert.js',
                }, {
                    title: '等待弹窗',
                    title_en: 'loading',
                    icon: 'tb-loading',
                    url: this.resourceUrl + 'module_loading.js',
                }, {
                    title: '验证弹窗',
                    title_en: 'captcha',
                    icon: 'md-checkmark-circle',
                    url: this.resourceUrl + 'module_captcha.js',
                }, {
                    title: '二维码扫描',
                    title_en: 'scaner',
                    icon: 'tb-scan',
                    url: this.resourceUrl + 'module_scaner.js',
                }, {
                    title: '跨域异步请求',
                    title_en: 'ajax',
                    icon: 'md-git-pull-request',
                    url: this.resourceUrl + 'module_ajax.js',
                }, {
                    title: '剪切板',
                    title_en: 'clipboard',
                    icon: 'md-copy',
                    url: this.resourceUrl + 'module_plate.js',
                }, {
                    title: '提示消息',
                    title_en: 'toast',
                    icon: 'md-notifications',
                    url: this.resourceUrl + 'module_toast.js',
                }, {
                    title: '广告弹窗',
                    title_en: 'adDialog',
                    icon: 'logo-buffer',
                    url: this.resourceUrl + 'module_ad_dialog.js',
                }
            ];
            this.plugin = [
                {
                    title: '城市选择器',
                    title_en: 'citypicker',
                    icon: 'md-pin',
                    url: this.resourceUrl + 'plugin_citypicker.js',
                }, {
                    title: '图片选择器',
                    title_en: 'picture',
                    icon: 'md-camera',
                    url: this.resourceUrl + 'plugin_picture.js',
                }, {
                    title: '组件截图',
                    title_en: 'screenshots',
                    icon: 'md-crop',
                    url: this.resourceUrl + 'plugin_screenshots.js',
                }, {
                    title: '融云通信模块',
                    title_en: 'rongim',
                    icon: 'tb-community',
                    url: this.resourceUrl + 'plugin_rongim.js',
                }, {
                    title: '友盟推送模块',
                    title_en: 'umeng',
                    icon: 'md-send',
                    url: this.resourceUrl + 'plugin_umeng.js',
                }, {
                    title: '第三方支付(微信/支付宝)',
                    title_en: 'pay',
                    icon: 'tb-sponsor',
                    url: this.resourceUrl + 'plugin_pay.js',
                }, {
                    title: '即时通讯',
                    title_en: 'websocket',
                    icon: 'md-repeat',
                    url: this.resourceUrl + 'plugin_websocket.js',
                }
            ];
            this.abouts = [
                {
                    title: '开发文档',
                    title_en: 'document',
                    icon: 'md-code-working',
                    url: 'https://eeui.app',
                }, {
                    title: '托管平台',
                    title_en: 'github',
                    icon: 'logo-github',
                    url: 'https://github.com/kuaifan/eeui',
                }, {
                    title: '个人博客',
                    title_en: 'http://kuaifan.vip',
                    icon: 'logo-rss',
                    url: 'http://kuaifan.vip',
                }, {
                    title: 'EEUI版本',
                    title_en: eeui.getVersionName(),
                    icon: 'md-information-circle',
                    url: 'https://eeui.app',
                }
            ];
            this.history = this.jsonParse(eeui.getCachesString("scaner", []), []);
            //
            eeui.setPageBackPressed(null, function(){
                eeui.confirm({
                    title: "温馨提示",
                    message: "你确定要退出eeui.app吗？",
                    buttons: ["取消", "确定"]
                }, (result)=>{
                    if (result.status === "click" && result.title === "确定") {
                        eeui.closePage(null);
                    }
                });
            });
        },

        methods: {
            scaner() {
                eeui.openScaner(null, (res) => {
                    if (res.status === "success") {
                        this.history.unshift(res.text);
                        eeui.setCachesString("scaner", this.jsonStringify(this.history), 0);
                        this.openAuto(res.text);
                    }
                });
            },

            refresh() {
                eeui.reloadPage();
            },

            clearHistory() {
                eeui.confirm({
                    title: "删除提示",
                    message: "你确定要删除扫码记录吗？",
                    buttons: ["取消", "确定"]
                }, (result)=>{
                    if (result.status === "click" && result.title === "确定") {
                        this.history = [];
                        eeui.setCachesString("scaner", this.jsonStringify(this.history), 0);
                    }
                });
            },

            openUrl(url) {
                eeui.openPage({
                    url: url,
                    pageType: 'app'
                });
            },

            openWeb(url) {
                this.openViewUrl(url);
            },

            openAuto(url) {
                eeui.openPage({
                    url: url,
                    pageType: 'auto'
                });
            },
        }
    };
</script>
