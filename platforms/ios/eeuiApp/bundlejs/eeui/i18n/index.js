const eeui = app.requireModule('eeui');
const locale = app.requireModule('locale') || app.requireModule('local');

Vue.mixin({
    data() {
        return {
            privateLanguageData: {
                en: require("./lang/en.js").default,
                zh: require("./lang/zh.js").default
            },
            privateLanguageType: 'system',
        }
    },

    created() {
        this.__loadLanguage();
        this.__setLanguageListener();
    },

    methods: {
        __loadLanguage() {
            let language = eeui.getCachesString("EEUI_I18N_LANGUAGE", "system");
            if (language === "system") {
                this.__getSystemLanguage((syslang) => {
                    if (syslang === null) syslang = 'zh';
                    this.privateLanguageType = syslang;
                });
            } else {
                this.privateLanguageType = language;
            }
        },

        __parseLanguage(language) {
            let supportedLanguageRE = /(en|zh)\_?\w*/i;
            let match = supportedLanguageRE.exec(language + "");
            if (match && match[1]) {
                return match[1];
            }
            return "";
        },

        __getSystemLanguage(callback) {
            try {
                let useSync = false;
                let resSync = locale.getLanguage((language) => {
                    let lang = this.__parseLanguage(language);
                    if (lang) {
                        useSync || callback(lang);
                    } else {
                        callback(null);
                    }
                });
                let langSync = this.__parseLanguage(resSync);
                if (langSync) {
                    useSync = true;
                    callback(langSync);
                } else {
                    callback(null);
                }
            } catch (e) {
                callback(null);
            }
        },

        __setLanguageListener() {
            let pageInfo = eeui.getPageInfo();
            if (pageInfo && pageInfo['pageName']) {
                let pageName = pageInfo['pageName'];
                let listenerName = pageName + "::i18n-change";
                let listenerLists = [];
                try {
                    listenerLists = JSON.parse(eeui.getVariate("__i18n::listener", "[]"));
                    if (!(listenerLists instanceof Array)) {
                        listenerLists = [];
                    }
                } catch (e) {
                    listenerLists = [];
                }
                if (listenerLists.indexOf(listenerName) === -1) {
                    listenerLists.push(listenerName);
                    eeui.setVariate("__i18n::listener", JSON.stringify(listenerLists));
                }
                eeui.setPageStatusListener({
                    pageName: pageName,
                    listenerName: listenerName,
                }, (res) => {
                    if (res.status === listenerName) {
                        eeui.setCachesString("EEUI_I18N_LANGUAGE", res.extra, 0);
                        this.__loadLanguage();
                    }
                });
            }
        },

        /**
         * 语言包数据
         * @param language
         * @param data
         */
        addLanguageData(language, data) {
            if (!language || typeof data !== "object") {
                return;
            }
            if (typeof this.privateLanguageData[language] === "undefined") {
                this.privateLanguageData[language] = {};
            }
            Object.assign(this.privateLanguageData[language], data);
        },

        /**
         * 变化语言
         * @param language
         */
        setLanguage(language) {
            let listenerLists = [];
            try {
                listenerLists = JSON.parse(eeui.getVariate("__i18n::listener", "[]"));
                if (!(listenerLists instanceof Array)) {
                    listenerLists = [];
                }
            } catch (e) {
                listenerLists = [];
            }
            //
            listenerLists.forEach((listenerName) => {
                if (listenerName && listenerName.indexOf("::i18n-change")) {
                    let pageName = listenerName.substring(0, listenerName.indexOf("::i18n-change"));
                    eeui.onPageStatusListener({
                        listenerName: listenerName,
                        pageName: pageName,
                        extra: language || "system"
                    }, listenerName);
                }
            });
        },

        /**
         * 获取语言
         * @returns {*}
         */
        getLanguage() {
            return eeui.getCachesString("EEUI_I18N_LANGUAGE", "system");
        },

        /**
         * 显示语言
         * @return {string}
         */
        lang(text) {
            if (typeof this.privateLanguageData[this.privateLanguageType] === "object") {
                return this.privateLanguageData[this.privateLanguageType][text] || text;
            }
            return text;
        }
    }
});