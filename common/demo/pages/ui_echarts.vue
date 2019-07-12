<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">Echarts 图表</text>
            </navbar-item>
        </navbar>

        <scroll-view class="list">
            <div v-for="(item, index) in lists" :key="index" class="item" @click="openDemo(item.title, item.option)">
                <image class="item-img" :src="item.src" resize="cover"></image>
                <text class="item-title">{{item.title}}</text>
                <icon class="item-icon"></icon>
            </div>
            <div class="item" @click="openMore">
                <image class="item-img" src="https://www.echartsjs.com/examples/data/thumb/bar-histogram.png" resize="cover"></image>
                <text class="item-title">更多图表效果.....</text>
                <icon class="item-icon"></icon>
            </div>
        </scroll-view>

    </div>
</template>

<style scoped>
    .app {
        width: 750px;
        flex: 1;
        background-color: #ffffff;
    }

    .navbar {
        width: 750px;
        height: 100px;
    }

    .title {
        font-size: 28px;
        color: #ffffff
    }

    .list {
        width: 750px;
        flex: 1;
    }

    .item {
        flex-direction: row;
        align-items: center;
        padding: 24px;
        border-bottom-width: 1px;
        border-bottom-style: solid;
        border-bottom-color: #d4d4d4;
    }

    .item-img {
        width: 120px;
        height: 120px;
        background-color: #f4f4f4;
    }

    .item-title {
        flex: 1;
        padding-left: 22px;
        padding-right: 22px;
        font-size: 26px;
    }

    .item-icon {
        font-size: 24px;
        width: 40px;
        height: 40px;
        color: #C9C9CE;
        content: 'tb-right';
    }
</style>

<script>
    const eeui = app.requireModule('eeui');

    export default {
        data() {
            return {
                lists: [{
                    title: '折线图 Basic Line Chart',
                    src: 'https://echarts.baidu.com/examples/data/thumb/line-simple.png',
                    option: {
                        xAxis: {
                            type: 'category',
                            data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        },
                        yAxis: {
                            type: 'value'
                        },
                        series: [{
                            data: [820, 932, 901, 934, 1290, 1330, 1320],
                            type: 'line'
                        }]
                    }
                }, {
                    title: '柱状图 Bar Simple',
                    src: 'https://echarts.baidu.com/examples/data/thumb/bar-simple.png',
                    option: {
                        xAxis: {
                            type: 'category',
                            data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        },
                        yAxis: {
                            type: 'value'
                        },
                        series: [{
                            data: [120, 200, 150, 80, 70, 110, 130],
                            type: 'bar'
                        }]
                    }
                }, {
                    title: '饼图 Customized Pie',
                    src: 'https://echarts.baidu.com/examples/data/thumb/pie-custom.png',
                    option: {
                        backgroundColor: '#2c343c',

                        title: {
                            text: 'Customized Pie',
                            left: 'center',
                            top: 20,
                            textStyle: {
                                color: '#ccc'
                            }
                        },

                        tooltip : {
                            trigger: 'item',
                            formatter: "{a} <br/>{b} : {c} ({d}%)"
                        },

                        visualMap: {
                            show: false,
                            min: 80,
                            max: 600,
                            inRange: {
                                colorLightness: [0, 1]
                            }
                        },
                        series : [
                            {
                                name:'访问来源',
                                type:'pie',
                                radius : '55%',
                                center: ['50%', '50%'],
                                data:[
                                    {value:335, name:'直接访问'},
                                    {value:310, name:'邮件营销'},
                                    {value:274, name:'联盟广告'},
                                    {value:235, name:'视频广告'},
                                    {value:400, name:'搜索引擎'}
                                ].sort(function (a, b) { return a.value - b.value; }),
                                roseType: 'radius',
                                label: {
                                    normal: {
                                        textStyle: {
                                            color: 'rgba(255, 255, 255, 0.3)'
                                        }
                                    }
                                },
                                labelLine: {
                                    normal: {
                                        lineStyle: {
                                            color: 'rgba(255, 255, 255, 0.3)'
                                        },
                                        smooth: 0.2,
                                        length: 10,
                                        length2: 20
                                    }
                                },
                                itemStyle: {
                                    normal: {
                                        color: '#c23531',
                                        shadowBlur: 200,
                                        shadowColor: 'rgba(0, 0, 0, 0.5)'
                                    }
                                },

                                animationType: 'scale',
                                animationEasing: 'elasticOut',
                                animationDelay: function (idx) {
                                    return Math.random() * 200;
                                }
                            }
                        ]
                    }
                }, {
                    title: '散点图 Basic Scatter Chart',
                    src: 'https://echarts.baidu.com/examples/data/thumb/scatter-simple.png',
                    option: {
                        xAxis: {},
                        yAxis: {},
                        series: [{
                            symbolSize: 20,
                            data: [
                                [10.0, 8.04],
                                [8.0, 6.95],
                                [13.0, 7.58],
                                [9.0, 8.81],
                                [11.0, 8.33],
                                [14.0, 9.96],
                                [6.0, 7.24],
                                [4.0, 4.26],
                                [12.0, 10.84],
                                [7.0, 4.82],
                                [5.0, 5.68]
                            ],
                            type: 'scatter'
                        }]
                    }
                }, {
                    title: 'K 线图 Basic Candlestick',
                    src: 'https://echarts.baidu.com/examples/data/thumb/candlestick-simple.png',
                    option: {
                        xAxis: {
                            data: ['2017-10-24', '2017-10-25', '2017-10-26', '2017-10-27']
                        },
                        yAxis: {},
                        series: [{
                            type: 'k',
                            data: [
                                [20, 30, 10, 35],
                                [40, 35, 30, 55],
                                [33, 38, 33, 40],
                                [40, 40, 32, 42]
                            ]
                        }]
                    }
                }]
            }
        },

        methods: {
            openDemo(title, option) {
                eeui.openPage({
                    url: 'ui_echarts_demo',
                    pageType: 'app',
                    params: {
                        title: title,
                        options: JSON.stringify(option),
                    }
                });
            },

            openMore() {
                this.openViewUrl("https://www.echartsjs.com/examples/");
            },
        }
    };
</script>
