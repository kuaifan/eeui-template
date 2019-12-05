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
        imageEngine: "",
    },

    wxpay: {
        appid: 'wx76cd9902f7e09bf3',
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
        }
    },

};
