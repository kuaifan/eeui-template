<template>
    <div class="app">

        <navbar class="navbar">
            <navbar-item type="back"></navbar-item>
            <navbar-item type="title">
                <text class="title">{{title}}</text>
            </navbar-item>
        </navbar>

        <div class="main">
            <WEcharts class="echarts" :options="options"></WEcharts>
        </div>
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

    .main {
        flex: 1;
        justify-content: center;
    }

    .echarts {
        width: 750px;
        height: 750px;
    }
</style>

<script>
    import WEcharts from "../components/WEcharts/index";
    const eeui = app.requireModule('eeui');

    export default {
        components: {WEcharts},
        data() {
            return {
                title: '折线图 Basic Line Chart',
                options: {
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
            }
        },

        mounted() {
            this.title = app.config.params.title ? app.config.params.title : this.title;
            this.options = app.config.params.options ? JSON.parse(app.config.params.options) : this.options;
        },

        methods: {

        }
    };
</script>
