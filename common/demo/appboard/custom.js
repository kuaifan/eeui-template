const eeui = app.requireModule('eeui');

Vue.mixin({
    data() {
        return {
            resourceUrl: '',
        }
    },

    methods: {

        openViewCode(str) {
            this.openViewUrl("https://eeui.app/" + str + ".html");
        },

        openViewUrl(url) {
            eeui.openPage({
                url: this.resourceUrl + 'index_browser.js',
                pageType: 'app',
                statusBarColor: "#3EB4FF",
                params: {
                    title: "EEUI",
                    url: url,
                }
            });
        }
    }
});
