var eeui = app.requireModule('eeui');

Vue.mixin({
    data() {
        return {
            resourceUrl: 'https://editor.eeui.app/compile/editor/releases/1/official/8a4d237d53a906ce69d517e63435d2b3/src/pages/',
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
