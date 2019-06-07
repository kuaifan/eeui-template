<template>
    <div ref="wSwitch" @click="changeState" :style="getBgStyle">
        <div ref="wBall" :style="ballStyle"></div>
    </div>
</template>

<script>
    const animation = app.requireModule('animation');

    export default {
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

        data() {
            return {
                wRatio: 1,
                hRatio: 1,
                loadIng: false,
                isAnimate: false,
                _checked: false,
                _ballStyle: {}
            };
        },

        created() {
            this.inited();
        },

        mounted() {
            this.wRatio = this.$refs.wSwitch.style.width / 144;
            this.hRatio = this.$refs.wSwitch.style.height / 72;
            this.$nextTick(() => { this.inited(); });
        },

        computed: {
            getBgStyle() {
                const {solid, borderColor, backgroundColor, disabled, wRatio, hRatio} = this;
                const style = !solid ? {
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

            ballStyle() {
                const {_ballStyle, _checked, hRatio, focusColor, solid, backgroundColor, blurColor, borderColor} = this;
                const style = _ballStyle;
                style.width = 72 * hRatio - 5 * hRatio * 2;
                style.height = 72 * hRatio - 5 * hRatio * 2;
                style.borderRadius = style.width / 2;
                style.backgroundColor = _checked ? (focusColor || (solid ? '#FFFFFF' : backgroundColor)) : (blurColor || (solid ? '#FFFFFF' : borderColor));
                return style;
            }
        },

        watch: {
            value(bool) {
                this._checked = bool;
                this.toggleState(bool);
            },
        },

        methods: {
            changeState() {
                if (this.loadIng) return;
                if (this.disabled) return;
                this._checked = !this._checked;
                this.toggleState(this._checked);
                this.loadIng = true;
                setTimeout(() => {
                    this.$emit('input', this._checked);
                    this.loadIng = false;
                }, 260);
            },

            toggleState(bool, animated = true) {
                const style = bool
                    ? {
                        backgroundColor: this.focusColor || (this.solid ? '#FFFFFF' : this.backgroundColor),
                        transform: 'scale(0.8) translate(' + (144 * this.wRatio - (72 * this.hRatio - 5 * this.hRatio * 2) - 5 * this.hRatio * 2) + 'px, 0)',
                        transformOrigin: 'center center'
                    }
                    : {
                        backgroundColor: this.blurColor || (this.solid ? '#FFFFFF' : this.borderColor),
                        transform: 'scale(0.6)',
                        transformOrigin: 'center center'
                    };
                const wBall = this.$refs.wBall;
                if (!wBall) {
                    return;
                }
                animation.transition(wBall, {
                    styles: style,
                    timingFunction: 'ease',
                    duration: animated ? 260 : 0.00001
                });
            },

            inited() {
                this.value ? (this._ballStyle = {
                    backgroundColor: this.focusColor || (this.solid ? '#FFFFFF' : this.backgroundColor),
                    transform: 'scale(0.8) translate(' + (144 * this.wRatio - (72 * this.hRatio - 5 * this.hRatio * 2) - 5 * this.hRatio * 2) + 'px, 0)'
                }) : (this._ballStyle = {
                    backgroundColor: this.blurColor || (this.solid ? '#FFFFFF' : this.borderColor),
                    transform: 'scale(0.6)'
                });
                this._checked = this.value;
                this.toggleState(this._checked, false);
            }
        }
    };
</script>
