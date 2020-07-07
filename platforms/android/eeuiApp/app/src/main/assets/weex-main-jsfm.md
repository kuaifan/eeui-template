# 修改内容

## 一

```js
//顶部添加
var eeuiNativeLog={app:null,create:function(e,type){if(e instanceof Array){var f=e[0]+"";if(f.indexOf("[JS Framework]")!==-1){return e.concat(["__"+type])}}try{if(this.app!=null){this.app.addLog(type.toLowerCase(),e)}}catch(e){}return e.concat(["__"+type])}};
```

## 二 

```
var a,s,c,l,u=(a=e,s={weex:r,
```

替换成

```
eeuiNativeLog.app=r.requireModule("debug");var a,s,c,l,u=(a=e,s={weex:r,app:r,
```

## 三

```
cn\(e\).concat\(\["__(.*?)"\]\)
```

正则替换成

```
eeuiNativeLog.create(cn(e), "$1")
```

## 四


在`E=[......,"errorCaptured"]`数组添加

```
"appActive","appDeactive","pageReady","pageResume","pagePause","pageDestroy","pageMessage"
```

## 五


在第一个`mixin.beforeCreate`里面最后加入

```
;(function(t){var g=t.$requireWeexModule("globalEvent");var u=function(s){return s.charAt(0).toUpperCase()+s.slice(1)};g.addEventListener("__appLifecycleStatus",function(data){if(typeof data=="object"&&data!=null&&data.status){var n=data.type+u(data.status);var e=t.$options[n];if(e){for(var r=0,o=e.length;r<o;r++){try{e[r].call(t,data)}catch(e){Ne(e,t,n+" hook")}}}}})})(this)
```