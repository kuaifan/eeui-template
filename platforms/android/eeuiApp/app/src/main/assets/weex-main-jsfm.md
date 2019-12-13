## 一

```js
//顶部添加
var eeuiNativeLog={app:null,debug:null,create:function(e,type){if(this.app!=null){if(this.debug==null){this.debug=this.app.requireModule("debug")}this.debug.addLog(type.toLowerCase(),e)}return e.concat(["__"+type])}};
```

## 二 

```
var a,s,c,l,u=(a=e,s={weex:r,
```

替换成

```
eeuiNativeLog.app=r;var a,s,c,l,u=(a=e,s={weex:r,app:r,
```

## 三

```
cn\(e\).concat\(\["__(.*?)"\]\)
```

正则替换成

```
eeuiNativeLog.create(cn(e), "$1")
```