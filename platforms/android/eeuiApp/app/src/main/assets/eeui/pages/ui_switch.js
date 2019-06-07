// { "framework": "Vue"} 
if(typeof app=="undefined"){app=weex}
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 149);
/******/ })
/************************************************************************/
/******/ ({

/***/ 110:
/***/ (function(module, exports, __webpack_require__) {

var __vue_exports__, __vue_options__
var __vue_styles__ = []

/* script */
__vue_exports__ = __webpack_require__(150)

/* template */
var __vue_template__ = __webpack_require__(157)
__vue_options__ = __vue_exports__ = __vue_exports__ || {}
if (
  typeof __vue_exports__.default === "object" ||
  typeof __vue_exports__.default === "function"
) {
if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
__vue_options__ = __vue_exports__ = __vue_exports__.default
}
if (typeof __vue_options__ === "function") {
  __vue_options__ = __vue_options__.options
}
__vue_options__.__file = "/Users/GAOYI/wwwroot/eeui/eeui-template/common/demo/components/WSwitch.vue"
__vue_options__.render = __vue_template__.render
__vue_options__.staticRenderFns = __vue_template__.staticRenderFns
__vue_options__.style = __vue_options__.style || {}
__vue_styles__.forEach(function (module) {
  for (var name in module) {
    __vue_options__.style[name] = module[name]
  }
})
if (typeof __register_static_styles__ === "function") {
  __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
}

module.exports = __vue_exports__


/***/ }),

/***/ 149:
/***/ (function(module, exports, __webpack_require__) {

var __vue_exports__, __vue_options__
var __vue_styles__ = []

/* styles */
__vue_styles__.push(__webpack_require__(51)
)

/* script */
__vue_exports__ = __webpack_require__(37)

/* template */
var __vue_template__ = __webpack_require__(87)
__vue_options__ = __vue_exports__ = __vue_exports__ || {}
if (
  typeof __vue_exports__.default === "object" ||
  typeof __vue_exports__.default === "function"
) {
if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
__vue_options__ = __vue_exports__ = __vue_exports__.default
}
if (typeof __vue_options__ === "function") {
  __vue_options__ = __vue_options__.options
}
__vue_options__.__file = "/Users/GAOYI/wwwroot/eeui/eeui-template/src/pages/ui_switch.vue"
__vue_options__.render = __vue_template__.render
__vue_options__.staticRenderFns = __vue_template__.staticRenderFns
__vue_options__._scopeId = "data-v-41367deb"
__vue_options__.style = __vue_options__.style || {}
__vue_styles__.forEach(function (module) {
  for (var name in module) {
    __vue_options__.style[name] = module[name]
  }
})
if (typeof __register_static_styles__ === "function") {
  __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
}

module.exports = __vue_exports__
module.exports.el = 'true'
new Vue(module.exports)


/***/ }),

/***/ 150:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
//
//
//
//
//
//

var animation = app.requireModule('animation');

exports.default = {
    name: 'WSwitch',
    props: {
        value: {
            type: Boolean,
            default: false
        },
        solid: Boolean,
        disabled: {
            type: Boolean,
            default: false
        },
        blurColor: String,
        focusColor: String,
        borderColor: {
            type: String,
            default: '#D9D9D9'
        },
        backgroundColor: {
            type: String,
            default: '#E31D1A'
        }
    },

    data: function data() {
        return {
            wRatio: 1,
            hRatio: 1,
            loadIng: false,
            isAnimate: false,
            _checked: false,
            _ballStyle: {}
        };
    },
    created: function created() {
        this.inited();
    },
    mounted: function mounted() {
        var _this = this;

        this.wRatio = this.$refs.wSwitch.style.width / 144;
        this.hRatio = this.$refs.wSwitch.style.height / 72;
        this.$nextTick(function () {
            _this.inited();
        });
    },


    computed: {
        getBgStyle: function getBgStyle() {
            var solid = this.solid,
                borderColor = this.borderColor,
                backgroundColor = this.backgroundColor,
                disabled = this.disabled,
                wRatio = this.wRatio,
                hRatio = this.hRatio;

            var style = !solid ? {
                borderColor: borderColor,
                backgroundColor: 'transparent'
            } : {
                borderColor: backgroundColor,
                backgroundColor: backgroundColor
            };
            if (disabled) {
                style.opacity = 0.3;
            } else {
                style.opacity = 1;
            }
            style.flexDirection = 'row';
            style.alignItems = 'center';
            style.width = 144 * wRatio;
            style.height = 72 * hRatio;
            style.borderRadius = 72 * hRatio;
            style.borderWidth = 5 * hRatio;
            return style;
        },
        ballStyle: function ballStyle() {
            var _ballStyle = this._ballStyle,
                _checked = this._checked,
                hRatio = this.hRatio,
                focusColor = this.focusColor,
                solid = this.solid,
                backgroundColor = this.backgroundColor,
                blurColor = this.blurColor,
                borderColor = this.borderColor;

            var style = _ballStyle;
            style.width = 72 * hRatio - 5 * hRatio * 2;
            style.height = 72 * hRatio - 5 * hRatio * 2;
            style.borderRadius = style.width / 2;
            style.backgroundColor = _checked ? focusColor || (solid ? '#FFFFFF' : backgroundColor) : blurColor || (solid ? '#FFFFFF' : borderColor);
            return style;
        }
    },

    watch: {
        value: function value(bool) {
            this._checked = bool;
            this.toggleState(bool);
        }
    },

    methods: {
        changeState: function changeState() {
            var _this2 = this;

            if (this.loadIng) return;
            if (this.disabled) return;
            this._checked = !this._checked;
            this.toggleState(this._checked);
            this.loadIng = true;
            setTimeout(function () {
                _this2.$emit('input', _this2._checked);
                _this2.loadIng = false;
            }, 260);
        },
        toggleState: function toggleState(bool) {
            var animated = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : true;

            var style = bool ? {
                backgroundColor: this.focusColor || (this.solid ? '#FFFFFF' : this.backgroundColor),
                transform: 'scale(0.8) translate(' + (144 * this.wRatio - (72 * this.hRatio - 5 * this.hRatio * 2) - 5 * this.hRatio * 2) + 'px, 0)',
                transformOrigin: 'center center'
            } : {
                backgroundColor: this.blurColor || (this.solid ? '#FFFFFF' : this.borderColor),
                transform: 'scale(0.6)',
                transformOrigin: 'center center'
            };
            var wBall = this.$refs.wBall;
            if (!wBall) {
                return;
            }
            animation.transition(wBall, {
                styles: style,
                timingFunction: 'ease',
                duration: animated ? 260 : 0.00001
            });
        },
        inited: function inited() {
            this.value ? this._ballStyle = {
                backgroundColor: this.focusColor || (this.solid ? '#FFFFFF' : this.backgroundColor),
                transform: 'scale(0.8) translate(' + (144 * this.wRatio - (72 * this.hRatio - 5 * this.hRatio * 2) - 5 * this.hRatio * 2) + 'px, 0)'
            } : this._ballStyle = {
                backgroundColor: this.blurColor || (this.solid ? '#FFFFFF' : this.borderColor),
                transform: 'scale(0.6)'
            };
            this._checked = this.value;
            this.toggleState(this._checked, false);
        }
    }
};

/***/ }),

/***/ 157:
/***/ (function(module, exports) {

module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    ref: "wSwitch",
    style: _vm.getBgStyle,
    on: {
      "click": _vm.changeState
    }
  }, [_c('div', {
    ref: "wBall",
    style: _vm.ballStyle
  })])
},staticRenderFns: []}
module.exports.render._withStripped = true

/***/ }),

/***/ 37:
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _WSwitch = __webpack_require__(110);

var _WSwitch2 = _interopRequireDefault(_WSwitch);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var eeui = app.requireModule('eeui'); //
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//


exports.default = {
    components: { WSwitch: _WSwitch2.default },
    data: function data() {
        return {
            status: true
        };
    },


    methods: {}
};

/***/ }),

/***/ 51:
/***/ (function(module, exports) {

module.exports = {
  "app": {
    "width": "750",
    "flex": 1,
    "backgroundColor": "#ffffff"
  },
  "navbar": {
    "width": "750",
    "height": "100"
  },
  "title": {
    "fontSize": "28",
    "color": "#ffffff"
  },
  "main": {
    "flex": 1,
    "alignItems": "center",
    "justifyContent": "center"
  },
  "status": {
    "fontSize": "26",
    "marginBottom": "24"
  },
  "switch": {
    "width": "120",
    "height": "60"
  }
}

/***/ }),

/***/ 87:
/***/ (function(module, exports) {

module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: ["app"]
  }, [_c('navbar', {
    staticClass: ["navbar"]
  }, [_c('navbar-item', {
    attrs: {
      "type": "back"
    }
  }), _c('navbar-item', {
    attrs: {
      "type": "title"
    }
  }, [_c('text', {
    staticClass: ["title"]
  }, [_vm._v("Switch 开关")])])], 1), _c('div', {
    staticClass: ["main"]
  }, [_c('text', {
    staticClass: ["status"]
  }, [_vm._v("当前状态：" + _vm._s(_vm.status))]), _c('WSwitch', {
    staticClass: ["switch"],
    model: {
      value: (_vm.status),
      callback: function($$v) {
        _vm.status = $$v
      },
      expression: "status"
    }
  })], 1)], 1)
},staticRenderFns: []}
module.exports.render._withStripped = true

/***/ })

/******/ });