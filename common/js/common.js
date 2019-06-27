import {runNum} from "./global";

let eeui = app.requireModule('eeui');

let common = {

    jshome: '',

    openViewCode(str) {
        common.openViewUrl("https://eeui.app/" + str + ".html");
    },

    openViewUrl(url) {
        eeui.openPage({
            url: common.jshome + 'index_browser.js',
            pageType: 'app',
            statusBarColor: "#3EB4FF",
            params: {
                title: "EEUI",
                url: url,
            }
        });
    },

    checkVersion(compareVersion) {
        if (typeof eeui.getVersion !== "function") {
            return false;
        }
        return runNum(eeui.getVersion()) >= runNum(compareVersion);
    },

};

module.exports = common;
