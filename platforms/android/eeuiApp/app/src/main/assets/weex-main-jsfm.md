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
