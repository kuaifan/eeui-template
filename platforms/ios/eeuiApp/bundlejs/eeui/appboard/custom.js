var eeui = app.requireModule('eeui');

Vue.mixin({
    data() {
        return {
            resourceUrl: 'https://editor.eeui.app/compile/editor/releases/1/official/a1133cf10fe4e8490845c465b1e08d39/src/pages/',
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
