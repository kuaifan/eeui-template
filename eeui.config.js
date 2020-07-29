/**
 * 配置文件
 * 参数详细说明：https://eeui.app/guide/config.html
 */
module.exports = {
    serviceUrl: "",

    homePage: "",
    homePageParams: { },

    appKey: "3TRWyttKzxRBtmHc004sJMjjyAxOf08l",

    android: {
        imageEngine: "picasso",
    },

    wxpay: {
        appid: 'wx76cd9902f7e09bf3',
        universalLink: 'https://eeui.app/open/wxapp/',
    },

    getui: {
        GETUI_APP_ID    : "",
        GETUI_APP_KEY   : "",
        GETUI_APP_SECRET: "",
        XIAOMI_APP_ID   : "",
        XIAOMI_APP_KEY  : "",

        MEIZU_APP_ID    : "",
        MEIZU_APP_KEY   : "",

        HUAWEI_APP_ID   : "",

        OPPO_APP_KEY    : "",
        OPPO_APP_SECRET : "",

        VIVO_APP_ID     : "",
        VIVO_APP_KEY    : ""
    },

    rongim: {
        ios: {
            enabled: true,
            appKey: "vnroth0kv8o7o",
            appSecret: "5mILjdXtXid7iM",
        },
        android: {
            enabled: true,
            appKey: "vnroth0kv8o7o",
            appSecret: "5mILjdXtXid7iM",
        },
    },

    umeng: {
        ios: {
            enabled: true,
            appKey: "5cfa398c3fc1959f7b000e9b",
            channel: "eeuidemo",
        },
        android: {
            enabled: true,
            appKey: "5cfa3958570df3a0e8001015",
            messageSecret: "49d0bac141dc8dc6df35d210a9c79289",
            channel: "eeuidemo",

            xiaomiAppId: "",
            xiaomiAppKey: "",
            huaweiAppId: "",
            meizuAppId: "",
            meizuAppKey: "",
            oppoAppKey: "",
            oppoAppSecret: "",
            vivoAppId: "",
            vivoAppKey: "",
        }
    },

    tencent: {
        ios: {
            appid: "1110227774",
        },
        android: {
            appid: "1110117645",
        }
    }
};
