(function(k){var a=new Hashtable();var f=["ae","au","ca","cn","eg","gb","hk","il","in","jp","sk","th","tw","us"];var b=["at","br","de","dk","es","gr","it","nl","pt","tr","vn"];var i=["cz","fi","fr","ru","se","pl"];var d=["ch"];var g=[[".",","],[",","."],[","," "],[".","'"]];var c=[f,b,i,d];function j(n,l,m){this.dec=n;this.group=l;this.neg=m}function h(){for(var l=0;l<c.length;l++){localeGroup=c[l];for(var m=0;m<localeGroup.length;m++){a.put(localeGroup[m],l)}}}function e(l,r){if(a.size()==0){h()}var q=".";var o=",";var p="-";if(r==false){if(l.indexOf("_")!=-1){l=l.split("_")[1].toLowerCase()}else{if(l.indexOf("-")!=-1){l=l.split("-")[1].toLowerCase()}}}var n=a.get(l);if(n){var m=g[n];if(m){q=m[0];o=m[1]}}return new j(q,o,p)}k.fn.formatNumber=function(l,m,n){return this.each(function(){if(m==null){m=true}if(n==null){n=true}var p;if(k(this).is(":input")){p=new String(k(this).val())}else{p=new String(k(this).text())}var o=k.formatNumber(p,l);if(m){if(k(this).is(":input")){k(this).val(o)}else{k(this).text(o)}}if(n){return o}})};k.formatNumber=function(q,w){var w=k.extend({},k.fn.formatNumber.defaults,w);var l=e(w.locale.toLowerCase(),w.isFullLocale);var n=l.dec;var u=l.group;var o=l.neg;var m="0#-,.";var t="";var s=false;for(var r=0;r<w.format.length;r++){if(m.indexOf(w.format.charAt(r))==-1){t=t+w.format.charAt(r)}else{if(r==0&&w.format.charAt(r)=="-"){s=true;continue}else{break}}}var v="";for(var r=w.format.length-1;r>=0;r--){if(m.indexOf(w.format.charAt(r))==-1){v=w.format.charAt(r)+v}else{break}}w.format=w.format.substring(t.length);w.format=w.format.substring(0,w.format.length-v.length);var p=new Number(q);return k._formatNumber(p,w,v,t,s)};k._formatNumber=function(m,q,n,I,t){var q=k.extend({},k.fn.formatNumber.defaults,q);var G=e(q.locale.toLowerCase(),q.isFullLocale);var F=G.dec;var w=G.group;var l=G.neg;var z=false;if(isNaN(m)){if(q.nanForceZero==true){m=0;z=true}else{return null}}if(n=="%"){m=m*100}var B="";if(q.format.indexOf(".")>-1){var H=F;var u=q.format.substring(q.format.lastIndexOf(".")+1);if(q.round==true){m=new Number(m.toFixed(u.length))}else{var M=m.toString();M=M.substring(0,M.lastIndexOf(".")+u.length+1);m=new Number(M)}var A=m%1;var C=new String(A.toFixed(u.length));C=C.substring(C.lastIndexOf(".")+1);for(var J=0;J<u.length;J++){if(u.charAt(J)=="#"&&C.charAt(J)!="0"){H+=C.charAt(J);continue}else{if(u.charAt(J)=="#"&&C.charAt(J)=="0"){var r=C.substring(J);if(r.match("[1-9]")){H+=C.charAt(J);continue}else{break}}else{if(u.charAt(J)=="0"){H+=C.charAt(J)}}}}B+=H}else{m=Math.round(m)}var v=Math.floor(m);if(m<0){v=Math.ceil(m)}var E="";if(q.format.indexOf(".")==-1){E=q.format}else{E=q.format.substring(0,q.format.indexOf("."))}var L="";if(!(v==0&&E.substr(E.length-1)=="#")||z){var x=new String(Math.abs(v));var p=9999;if(E.lastIndexOf(",")!=-1){p=E.length-E.lastIndexOf(",")-1}var o=0;for(var J=x.length-1;J>-1;J--){L=x.charAt(J)+L;o++;if(o==p&&J!=0){L=w+L;o=0}}if(E.length>L.length){var K=E.indexOf("0");if(K!=-1){var D=E.length-K;var s=E.length-L.length-1;while(L.length<D){var y=E.charAt(s);if(y==","){y=w}L=y+L;s--}}}}if(!L&&E.indexOf("0",E.length-1)!==-1){L="0"}B=L+B;if(m<0&&t&&I.length>0){I=l+I}else{if(m<0){B=l+B}}if(!q.decimalSeparatorAlwaysShown){if(B.lastIndexOf(F)==B.length-1){B=B.substring(0,B.length-1)}}B=I+B+n;return B};k.fn.parseNumber=function(l,m,o){if(m==null){m=true}if(o==null){o=true}var p;if(k(this).is(":input")){p=new String(k(this).val())}else{p=new String(k(this).text())}var n=k.parseNumber(p,l);if(n){if(m){if(k(this).is(":input")){k(this).val(n.toString())}else{k(this).text(n.toString())}}if(o){return n}}};k.parseNumber=function(s,x){var x=k.extend({},k.fn.parseNumber.defaults,x);var m=e(x.locale.toLowerCase(),x.isFullLocale);var p=m.dec;var v=m.group;var q=m.neg;var l="1234567890.-";while(s.indexOf(v)>-1){s=s.replace(v,"")}s=s.replace(p,".").replace(q,"-");var w="";var o=false;if(s.charAt(s.length-1)=="%"||x.isPercentage==true){o=true}for(var t=0;t<s.length;t++){if(l.indexOf(s.charAt(t))>-1){w=w+s.charAt(t)}}var r=new Number(w);if(o){r=r/100;var u=w.indexOf(".");if(u!=-1){var n=w.length-u-1;r=r.toFixed(n+2)}else{r=r.toFixed(w.length-1)}}return r};k.fn.parseNumber.defaults={locale:"us",decimalSeparatorAlwaysShown:false,isPercentage:false,isFullLocale:false};k.fn.formatNumber.defaults={format:"#,###.00",locale:"us",decimalSeparatorAlwaysShown:false,nanForceZero:true,round:true,isFullLocale:false};Number.prototype.toFixed=function(l){return k._roundNumber(this,l)};k._roundNumber=function(n,m){var l=Math.pow(10,m||0);var o=String(Math.round(n*l)/l);if(m>0){var p=o.indexOf(".");if(p==-1){o+=".";p=0}else{p=o.length-(p+1)}while(p<m){o+="0";p++}}return o}})(jQuery);