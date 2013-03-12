//utf-8 width module ccchart.m.cssHybrid http://ccchart.com/

window.ccchart = 
(function(window) {
    return {
            aboutThis: {
                version: '1.00-b3',
                update: 20130209,
                updateMemo: 'http://ccchart.com/update.json',
                lisence: 'MIT (later v1.x MIT, before v0.9* Public Domain)',
                memo: 'This is a Simple JavaScript chart that does not depend on libraries such as jQuery.',
                demoCurrent: 'http://ccchart.com/',
                demo09xbefore: 'http://ccchart.com/c/',
                writer: 'Toshiro Takahashi @toshirot',
                see: 'http://www.facebook.com/javascripting',
                branched: ''
                       + 'This project has branched from the jQchart, that made by Toshiro Takahashi'
                       + 'jQchart is the jQuery plugin. since 2007.'
                       + 'http://archive.plugins.jquery.com/project/jQchart',
                module:[]
            },
            m: [],//for modules
            init: function (id, op, callback) {
                this.drawing = false;
                if((''+id.nodeName).toLowerCase() === 'canvas'){
                    this.canvas = id;
                    this.id= id.id;
                } else {
                    this.canvas = document.getElementById(id);
                    this.id= id;
                }
                if(typeof this.ids!=='object'){
                    this.ids=[]; //canvas elements
                    this.cxs=[]; //ctx collection
                    this.ops=[]; //settings and datas
                    this.wses=[]; 
                    //websocket lists e.g. ccchart.wses[id+'-ccchart-'+url]

                    this.idsLen = 0;
                    this.maxZindex = 0;//canvasのzIndex最大値
                    
                    this.moveDly = 0;//move2 delay 初期値
                    this.moveStack = [];
                    this.moveStackDly =[];
                    
                    this.cssgs=[];//CSS group
                    this.cssTooltips=[];//CSS cssTooltips

                    for(var i in window.ccchart.m){var isModule = !!i;break;};
                    if(isModule)
                      for(var i in window.ccchart.m){
                          this.extend(window.ccchart.m[i]);
                      }
                    
                }

                this.idsLen++;
                this.canvas.setAttribute('class',"-ccchart");
                this.ids[this.id] = this.canvas;
                this.ctx =
                   this.cxs[this.id] =
                        this.canvas.getContext('2d');
                this.ops[this.id]=[];
                //unload reset. doesn't work on chrome
                if(window.ccchart['_added_unloadEvent']!=='on'){
                  window.addEventListener('unload', function(){ window.ccchart=null; });
                  window.ccchart['_added_unloadEvent'] = 'on';
                }


                //css-hybridリセット
                if(this.adds){
                  var hybrid = document.getElementById('-ccchart-css-hybrid');
                  if(hybrid){
                    if(this._ws){
                      if(this._ws[this.id]){
                        if(this._ws[this.id].readyState=== this._ws[this.id].OPEN){
                          //don't remove
                        }
                      } else document.body.removeChild(hybrid);
                    } else document.body.removeChild(hybrid);
                  }
                }

                if(!this.adds){
                    this.adds=[];//added charts configs
                    this.adds.push([id, op, callback]);
                }
                
                this.loadBranch (op, callback);
                
                return this;
            },
            loadBranch: function (op, callback) {
                //initの第1引数opと以下のプロパティがURL文字列の時に Ajax load する。
                var isStrOp = (typeof op === 'string');
                var isStrOpCnf = (typeof op.config === 'string');
                var isStrOpData = (typeof op.data === 'string');
                if(isStrOp){
                    this.getOption(op, callback, true);
                } else if(isStrOpData || isStrOpCnf){
                    if(isStrOpData && isStrOpCnf){
                          this.getOptionCnfData(op, callback, true);
                    } else if(isStrOpCnf){
                          this.getOptionCnf(op, callback, true);
                    } else if(isStrOpData){
                          this.getOptionData(op, callback, true);
                    }
                } else if(this.util.isArray(op.data)){
                    this.preProcessing(op, callback);
                }
            },
            extend: function (oj, prop) {
                if (!prop) {
                    prop = oj;
                    oj = this;
                }
                if(!prop['aboutThis_module'])
                  prop['aboutThis_module']={name:'module_'+(new Date()).getTime()};
                for (var i in prop){
                    if(i==='aboutThis_module'){
                        var name = prop[i]['name']||'module_'+(new Date()).getTime();
                        oj['aboutThis']['module'][prop[i].name]=prop[i];
                    } else oj[i] = prop[i];
                    
                }
                return oj;
            },
            preProcessing: function (op, callback) {
              //  this.drawing = true;
                if(!op)op={}
                if(!op.config)op.config={};
                this.op = op;
                this.width = op.config.width || 600;
                this.height = op.config.height || 400;
                this.bg = op.config.bg || '';
                this.bgGradient = op.config.bgGradient || '';
                if(this.bgGradient || this.bg===''){
                   this.bgGradient = op.config.bgGradient || {
                            direction :"vertical", //vertical|horizontal
                            from      :"#687478",
                            to        :"#222"
                        };
                }
                
                //グラフの種類 折れ線(line) または 棒(bar)など swtGraph参照
                this.type = op.config.type || "line";

                //CSSを使うかどうか
                this.useCss = op.config.useCss || 'no';
                //データマーカー描画 //none|arc|ring|maru|css-ring|css-maru
                this.useMarker = op.config.useMarker || 'none'; 
                if(this.useMarker === 'css-ring' || this.useMarker === 'css-maru'){
                    if(this.type !== 'pie')this.useCss = 'yes';
                }
                if(this.type === 'pie')this.useMarker = 'none'; 
                
                //マーカーの幅または直径
                this.markerWidth = op.config.markerWidth || this.lineWidth * 2 ;
                
                //CSSツールチップ
                this.useCssToolTip = op.config.useCssToolTip || 'yes';

                //マーカーの幅または直径
                this.markerWidth = op.config.markerWidth || this.lineWidth * 2 ;

                if(this.useCss === 'yes'){
                    this.bind('scroll', '_adjustcsspos');
                    this.bind('load', '_adjustcsspos');
                    this.bind('resize', '_adjustcsspos');
                }
                this.wkdata = op.data || [];
                /*[
                        ["Year", 2007, 2008, 2009, 2010, 2011, 2012, 2013],
                        ["Tea", 435, 332, 524, 688, 774, 825, 999],
                        ["Coffee", 600, 335, 584, 333, 457, 788, 900],
                        ["Juice", 60, 435, 456, 352, 567, 678, 1260],
                        ["Oolong", 200, 123, 312, 200, 402, 300, 512]
                    ];*/
                    
                //データ配列の1行目を項目名とする(デフォルトはtrue)
                // scatter では項目名ではないが、判例type識別用に使う
                this.useFirstToColName = 
                    (op.config.useFirstToColName === false)?
                        ((this.type === 'scatter')?true:false):true;
                        
                if(this.wkdata.length ===1)this.useFirstToColName = false;
                //データ配列の1列目を項目名とする(デフォルトはtrue)
                this.useFirstToRowName = 
                    (op.config.useFirstToRowName === false)?
                        false:true;
                
                //useFirstToColNameがtrueなら
                //最初の行をカラム項目名として抜き出す
                this.colNames = 
                    (this.useFirstToColName)?
                        this.wkdata.slice(0,1)[0]:'';
                this.data = 
                    (this.useFirstToColName)?
                        this.wkdata.slice(1):this.wkdata;

                //useFirstToRowNameがtrueなら
                //各行の最初の列を行タイトルとして抜き出す
                this.rowNames = [];
                if(this.useFirstToRowName){
                    this.data = [];
                    this.colNamesTitle = this.colNames.slice(0,1)[0]||"";
                    this.colNames =  this.colNames.slice(1);
                    for(var i = 1; i < this.wkdata.length; i++){
                        this.rowNames.push(this.wkdata[i][0]);
                        this.data.push(this.wkdata[i].slice(1));
                    }
                }
                /* 上記 「データ配列の1行目」と「1列目」を項目名として取り出した結果、
                   先頭行と列を除いたdataおよび、次のプロパティと配列が作成されます。
                    X軸ラベルのタイトル  ccchart.colNamesTitle //"年度"
                    X軸ラベルの配列      ccchart.colNames
                                            //[2007, 2008, 2009, 2010, 2011, 2012, 2013]
                    Y軸ラベルの配列      ccchart.rowNames
                                            //["紅茶", "コーヒー", "ジュース", "ウーロン"]
                */
                
                this.hanreiNames = this.rowNames;
                this.useRow0thToHanrei = op.config.useRow0thToHanrei||'none';
                if(this.type === 'scatter'){
                  this.colNamesTitle = this.rowNames[0]||'';//X軸タイトル
                  this.rowNamesTitle = this.rowNames[1]||'';//Y軸タイトル
                  if(this.useRow0thToHanrei==='yes')
                    this.hanreiNames = '';
                  else
                    this.hanreiNames = this.util.uniq(this.colNames.slice(1));//hanrei判例リスト
                  
                }
                //データ行数
                this.dataRowLen = this.data.length;
                //データ列数
                this.dataColLen = this.data[0].length;
                
                //WebSocket受信時の最大データ列数
                this.maxWsColLen = this.op.config.maxWsColLen || 10;
                
                //this.wsKeepAlive = this.op.config.wsKeepAlive || true;

                //データのnumber化
                var _data =[];
                for(var i = 0;i< this.data.length; i++){ 
                    _data[i]=[];
                    for(var j = 0; j<this.data[i].length; j++){
                        _data[i][j] = parseFloat(ccchart.data[i][j])
                    }
                }
                this.data = _data;
                  
                
                //Y軸目盛のパーセント表示を行うかどうか
                this.yScalePercent = this.op.config.yScalePercent || 'no';

                //for drawStacked%
                if(this.type === 'stacked%')this.percentVal = this.op.config.percentVal || 'yes';
                

                
                //for drawTitle, drawSubTitle
                //タイトル文字列
                this.title = op.config.title || "";
                this.subtitle = op.config.subtitle || op.config.subTitle || "";
                //タイトルをcanvasにセットする
                this.canvas.setAttribute('title',this.title);

                //チャートのみを表示(タイトル,サブタイトル,水平垂直目盛無し) no|yes
                this.onlyChart = op.config.onlyChart || "no";
                this.onlyChartWidthTitle = op.config.onlyChartWidthTitle || "no";
                this.paddingDefault = op.config.paddingDefault || 10;
                if(this.onlyChartWidthTitle === 'yes'){
                    this.paddingBottomDefault = 
                    this.paddingLeftDefault = 
                    this.paddingRightDefault = this.paddingDefault;
                    this.paddingTopDefault = 90;
                    this.onlyChart = 'yes';
                } else
                if(this.onlyChart === 'yes'){
                    this.paddingTopDefault = 
                    this.paddingBottomDefault = 
                    this.paddingLeftDefault = 
                    this.paddingRightDefault = this.paddingDefault;
                } else {
                    this.paddingTopDefault = 90;
                      if(this.title === '' && this.adds.length === 1)
                            this.paddingTopDefault = this.paddingTopDefault - 30;
                      if(this.subtitle === '' && this.adds.length === 1)
                            this.paddingTopDefault = this.paddingTopDefault - 15;
                    this.paddingBottomDefault = 40;
                    this.paddingLeftDefault = 100;
                    if(this.yScalePercent==='no')
                        this.paddingLeftDefault = 70;
                    this.paddingRightDefault = 80;
                }
                
                if(this.adds.length >= 2){
                    this.paddingRightDefault = 160;
                } 
                
                //データ値を表示
                this.useVal = op.config.useVal || 'no'; //yes|no
                
                if(op.config.type === 'stacked%' &&
                   op.config.useVal==='yes'){
                    this.paddingTopDefault = 90;
                }
 
                //for drawAxisX, drawAxisY, etc...
                //グラフ領域のパディング
                this.paddingTop = op.config.paddingTop || this.paddingTopDefault;
                this.paddingBottom = op.config.paddingBottom || this.paddingBottomDefault;
                this.paddingLeft = op.config.paddingLeft || this.paddingLeftDefault;
                this.paddingRight = op.config.paddingRight || this.paddingRightDefault;
                
                //グラフ領域の幅
                this.chartWidth = 
                    this.width - this.paddingLeft - this.paddingRight;
                //グラフ領域の高さ
                this.chartHeight = 
                    this.height - this.paddingTop - this.paddingBottom;
                
                //グラフ領域の上端
                this.chartTop = this.paddingTop;
                //グラフ領域の下端
                this.chartBottom = this.height - this.paddingBottom;
                //グラフ領域の左端
                this.chartLeft = this.paddingLeft;
                //グラフ領域の右端
                this.chartRight = this.width - this.paddingRight;

                //水平目盛り線AxisXの本数
                this.axisXLen = this.op.config.axisXLen || 10;
                
                //for drawAxisX
                //水平目盛線用
                this.yGap = this.chartHeight/this.axisXLen;
                
                //X軸の色 Y軸の色
                this.xColor = op.config.xColor || 'rgba(180,180,180,0.3)'; 
                this.yColor = op.config.yColor || 'rgba(180,180,180,0.3)'; 
                
                //for drawAxisY
                //垂直目盛線用
                this.axisYLen = this.dataColLen//本数
                this.xGap = (this.chartWidth)/this.axisYLen  ;//目盛線の間隔

                //X目盛を小数点有りにするか？
                this.xScaleDecimal = this.op.config.xScaleDecimal || false;
                //Y目盛を小数点有りにするか？
                this.yScaleDecimal = this.op.config.yScaleDecimal || false;
                //Yデータの最大値maxYを求めるfor drawYscale
                this.maxY = _getMax(this, 'maxY')||0;
                //データ最大値this.maxYの切り上げ処理 デフォルトmaxYの1/10桁
                if(!this.yScaleDecimal)
                  _setRoundedUpMax(this, 'maxY', 'roundedUpMaxY');

                //データの最小値を求める
                this.minY = _getMin(this, 'minY')||0;
                //水平目盛線1本当たりのラベル値
                this.yGapValue = parseFloat((this.maxY-this.minY)/this.axisXLen, 10);
                //値1当たりの高さ
                this.unitH = this.chartHeight/(this.maxY - this.minY);
                if(this.type === 'stacked%')this.unitH = this.chartHeight/100;
                //ラベルの値初期値
                this.wkYScale = this.minY;
                
                //scatter時、Xデータ
                if(this.type==='scatter'){
                  if(this.op.config.maxX){
                    this.maxX=this.op.config.maxX;
                  } else {
                    var wk = this.util.hCopy(this.data[0]);//ハードコピー
                    this.maxX =  wk.sort(function(a,b){return b-a})[0];
                  }
                  _setRoundedUpMax(this, 'maxX', 'roundedUpMaxX');
                  if(typeof this.op.config.minX==='number'){
                    this.minX=this.op.config.minX||0;
                  } else {
                    var wk = this.util.hCopy(this.data[0]);//ハードコピー
                    this.minX = wk.sort(function(b,a){return b-a})[0];
                  }
                  //for drawAxisY for scatter
                  //scatter時の垂直目盛線用
                  this.axisYLen = this.op.config.axisYLen || 10;//本数
                  this.xGap = (this.chartWidth)/this.axisYLen  ;//目盛線の間隔
                  
                  //垂直目盛線1本当たりのラベル値
                  this.xGapValue = parseFloat((this.maxX-this.minX)/this.axisYLen, 10);
                  //値1当たりの幅
                  this.unitW = this.chartWidth/(this.maxX - this.minX);
                  //ラベルの値初期値
                  this.wkXScale = this.minX;
                }

                //for drawLine, drowHanrei
                //カラーセット
                this.colorSet = op.config.colorSet ||  
                  ["red","#FF9114","#3CB000","#00A8A2","#0036C0","#C328FF","#FF34C0"];
                //文字列カラー
                this.textColor = op.config.textColor || false;
                this.textColors = op.config.textColors ||{
                    "title" : "#ccc",
                    "subTitle": "#ddd",
                    "x": "#aaa",
                    "y": "#aaa",
                    "hanrei": "#ccc",
                    "unit": "#aaa",
                    "memo": "#ccc"
                }
                if(op.config.textColors)
                   this.textColors.all = op.config.textColors.all || undefined;
                   
                //for drowHanrei
                //凡例マーカーの形 arc|rect
                this.hanreiMarkerStyle =  op.config.hanreiMarkerStyle || 'arc';
                
                //for drawLine, drawAmplitude
                //折れ線グラフ用パラメータ
                this.lineWidth = op.config.lineWidth?op.config.lineWidth:3;
                //円グラフのドーナツ穴の半径
                this.pieHoleRadius = op.config.pieHoleRadius?op.config.pieHoleRadius:40;
                //円グラフのドーナツ幅
                this.pieRingWidth = this.op.config.pieRingWidth?this.op.config.pieRingWidth:40; 

                //棒グラフ用パラメータ
                this.barPadding = op.config.barPadding || 10; 
                this.barWidth = op.config.barWidth || 10;
                this.barGap = op.config.barGap || 1;
                
                //単位を表示
                this.unit = op.config.unit || ''; 

                //キャンバス回転エフェクトの方向 x|y
                this.flipDirection = op.config.flipDirection || 'x';
                
                //X軸にカスタムXラインを引き、そのY値を表示する
                this.xLines = op.config.xLines || 'none' ||[{
                        "color":"rgba(204,153,0,0.7)",  //ライン色
                        "width":"1",     //ライン幅
                        "val":0,         //Y値
                        "vColor":"rgba(204,153,0,0.7)",//値色
                        "xOffset": 2,    //X方向オフセット
                        "yOffset": 4     //Y方向オフセット
                }];
                //memo
                this._memo = 
                       (typeof op.config.memo === 'undefined')?null:op.config.memo;
                //image
                this._img = 
                       (typeof op.config.img === 'undefined')?null:op.config.img;
                //影を付けるかどうか
                this.useShadow =  op.config.useShadow || 'yes';
                if(this.useShadow === 'yes'){
                  this.shadows = op.config.shadows ||{
                      "hanrei" : ['#222', 5, 5, 5],
                      "xline": ['#444', 7, 7, 5],
                      "line": ['#222', 5, 5, 5],
                      "bar": ['#222', 5, 5, 5],
                      "stacked": ['#222', 5, -5, 5],
                      "stackedarea": ['#222', 5, 5, 5],
                      "bezi": ['#222', 5, 5, 5],
                      "bezi2": ['#222', 5, 5, 5],
                      "scatter": ['#222', 5, 5, 5],
                      "pie": ['#444', 3, 3, 3]
                  }
                  if(op.config.shadows)
                     this.shadows.all = op.config.shadows.all || undefined;
                }
                
                 //forCSS prifix
                 this.ua = navigator.userAgent.toLowerCase();
                 this.prefix = this.ua.match(/webkit/)?'-webkit':
                              this.ua.match(/firefox/)?'-moz':
                              this.ua.match(/opera/)?'-o':'-ms';
                 this.pfx =[];
                 this.setPfx('transform'); //this.pfx['transform']
                 this.setPfx('transform-origin'); //this.pfx['transform-origin']
                 this.setPfx('transition'); //this.pfx['transition']
                 this.setPfx('box-sizing'); //this.pfx['box-sizing']
                
                 this.borderWidth = op.config.borderWidth || 3;
                 
                 this.useCssToolTip = op.config.useCssToolTip || 'yes';
                 
                 //copy the preProcessing data to ids.
                 this.opsLen = 0;
                 for(var i in this){
                     this.ops[this.id][i] = this[i];
                     this.opsLen++;
                 }
                
                 if(this.useCss==='yes')
                   if(this.useCssSetting)this.useCssSetting(op);

                 this.ondrew = callback || function(){};
                 this._ondrew =  function(){
                   this.drawing = false; 
                   if(this.ondrew)this.ondrew(this);
                 };
                 this.draw(op);
                 
                //データの最大値を求める
                function _getMax(that, prop){
                  
                  if(
                    typeof op.config[prop] === 'undefined'||
                    typeof op.config[prop]===null||
                    typeof op.config[prop]==='none'){
                      if(
                        that.type === 'stacked' ||
                        that.type === 'stackedarea' || 
                        that.type === 'stacked%'){
                          //積み重ねた時の最大値
                          return that.util.getMaxSum(that);
                      } else {
                          return that.util.getMax(that);
                      }
                  } else  {
                      return parseFloat(op.config[prop]);
                  }
                }
                
                //データ最大値this[maxY|maxX]の切り上げ処理 デフォルトmaxYまたはmaxXの1/10桁
                function _setRoundedUpMax(that, max, roundedUp){
                  if(that.yScalePercent==='no'){
                      var _rumy = Math.pow(10,(""+that[max]).split('.')[0].length-2);
                        //デフォルトmaxY|maxXの1/10桁
                      that[roundedUp] = 
                          (op.config[roundedUp] !== undefined )?
                              op.config[roundedUp]:_rumy ;
                      if(that[roundedUp] !== 0){
                          that[max] = Math.ceil(
                              that[max]/that[roundedUp]
                          ) * that[roundedUp];
                      } else {
                          that[max] = that[max];
                      }
                  }
                }

                //データの最小値を求める
                function _getMin(that, prop){
                  
                  if( that.type==='line' ||
                      that.type==='bezi2' ||
                      that.type==='bezi' ||
                      that.type==='area' ||
                      that.type==='scatter' ||
                      that.type==='ampli')
                        if(typeof op.config[prop] === 'undefined'){
                            return that.util.getMin(that);
                        } else  {
                            return parseFloat(op.config[prop])||0;
                        }
                }
            },
            setPfx: function(prop){
                return this.pfx[prop] = this.prefix + '-' + prop;
            },
            get: function (url, fnc, async) {
                var that = this;
                var async = (async === false)?false:true;
                var req = new XMLHttpRequest();
                req.open('GET', url, async);
                req.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                req.onreadystatechange = function (evt) {
                    if(req.readyState == 4 && req.status == 200) {
                        if(req.responseText === '')return req
                        var res = decodeURIComponent(req.responseText);
                        if(fnc)fnc(res);
                    }
                };
                req.send();
                return req;
            },
            getOption: function(op, callback, async){
                var that = this;
                this.get(op, function(res){//op is url
                   try{
                      //op must be JSON
                      op = JSON.parse(res);
                      that.loadBranch (op, callback);
                   } catch(e){ }
                }, async);
            },
            getOptionCnfData: function(op, callback, async){
                var that = this;
                this.get(op.config, function(res){//op.config is url
                   try{
                      //op.config must be JSON
                      op.config = JSON.parse(res);
                      that.getOptionData(op, callback, true);
                   } catch(e){ }
                }, async);
            },
            getOptionCnf: function(op, callback, async){
                var that = this;
                this.get(op.config, function(res){//op.config is url
                   try{
                      //op.config must be JSON
                      op.config = JSON.parse(res);
                      that.preProcessing(op, callback);
                   } catch(e){ }
                }, async);
            },
            getOptionData: function(op, callback, async){
                var that = this;
                this.get(op.data, function(res){//op.data is url
                   try{
                      //op.data must be JSON
                      op.data = JSON.parse(res);
                      that.preProcessing(op, callback);
                   } catch(e){ }
                }, async);
            },
            bind: function(type,fnc){
                var it = this;
                var target = this.canvas;
                //for iphone android
                if(type==='click'||type==='touchstart'){
                    var mbl = this.util.isMobile();
                    type = (mbl)?'touchstart':'click';
                }
                // this is for ccchart.$(function(){});
                //   and ccchart.bind('load', function () {});
                if(typeof this.ids!=='object'){
                    target = window;
                }
                if(fnc!=='_adjustcsspos'){
                    if(typeof fnc==='function'){
                        target.removeEventListener(type, function (e) {
                            fnc.apply(it,[e, it.canvas]);
                        });
                        if(type==='load'){//console.log('load----')
                          fnc.apply(it,[window.event, it.canvas]);
                        } else {
                          target.addEventListener(type, function (e) {
                              fnc.apply(it,[e, it.canvas]);
                          });
                        }
                        if(this.useCss==='yes' && this.hybridBox){
                            this.hybridBox.addEventListener(type, function (e) {
                                fnc.apply(it,[e, it.canvas]);
                            });
                        }
                    }
                }
                
                //for CSS Hybrid
                if(this.useCss!=='yes'){
                  return this;
                } else {
                  if(type==='load'){
                      setAdjustCssEvent(this, window, 'load');
                  }
                  if(type==='resize'){
                      setAdjustCssEvent(this, window, 'resize');
                  }
                  if(type==='scroll'){
                      setAdjustCssEvent(this, document, 'scroll');
                  }
                  function _a(){it.adjustCss(type)}
                  function setAdjustCssEvent(that, target, type){//重複登録を防ぐ
                      if(that['_added_css_' + type + 'Event']!=='on'){
                          target.addEventListener(type, _a);
                          that['_added_css_' + type + 'Event'] = 'on';
                      }
                  }
                }
                return this;
            },
            $: function(func){
                if(typeof func === 'function')this.bind('load', func);
            },
            draw: function (op) {
                this.drawing = true;
                if(this.adds.length <= 2){
                    this.canvas.width = this.width;
                    this.canvas.height = this.height;
                    
                    this.ctx.scale(1, 1);
                    this.ctx.translate(0, 0);
                    
                    if(this.bgGradient)this.drawGradient();
                    else if(this.bg) this.drawBG();
                    
                    if(this.type !== 'pie'){
                      this.drawAxisX();
                      this.drawAxisY();
                    }
                    
                    if(this.onlyChart==='no' || this.onlyChartWidthTitle ==='yes')
                        this.drawTitle();
                    if(this.onlyChart==='no')this.drawSubTitle();
                } else this.drawAxisX(this.adds.length);

                if(this.onlyChart==='no')this.drowHanrei();
                if(typeof this._img === 'object'){
                  this.drawImg(this._img);
                }
                if(typeof this._memo === 'object'){
                  this.drawMemo();
                  //this.drawImgが同じ座標にあるとそちらが
                  //コールバック遅延するのでメモが見えなくなる
                }
                if(op)this.swtGraph();
                if(
                  this.useMarker!=='none' &&
                  this.type !== 'scatter'
                )this.drawMarkers();
                if(this.xLines!=='none')this.drawXLine();
                if(this.type==='line' && this.useVal !== 'no')this.drawVals();
                if(this.type==='area' && this.useVal !== 'no')this.drawVals();
                if(this.unit!=='')this.drawUnit(this.unit);
            },
            swtGraph: function () {
                //チャートタイプ分岐
                switch(this.type){
                    case('line')    : this.drawLine ();break;
                    case('bar')     : this.drawBar ();break;
                    case('pie')     : this.drawPie();break;
                    case('bezi')    : this.drawbeziLine();break;
                    case('bezi2')    : this.drawbeziLine2();break;
                    case('stacked') : this.drawStackedBar();break;
                    case('area')   : this.drawArea();break;
                    case('stackedarea')   : this.drawStackedArea();break;
                    case('stacked%')   : this.drawStackedPercent();break;
                    case('ampli')   : this.drawAmplitude();break;
                    case('scatter')   : this.drawScatter();break;
                    default         : this.drawBar ();break;
                }
            },
            drawBG: function(bg){
              if(this.bg==='' && !bg)return;
              if(this.canvas.style && this.bg !==''){
                this.canvas.style.setProperty ("background", (bg||this.bg), '');
              }
              //fillRecだとboder-radiusが壊れるがあとで再検討
              //  this.ctx.fillRect(0, 0, this.width, this.height);
                return this;
            },
            drawGradient: function () {
            
                var bg = this.bgGradient;
                var y = (bg.direction==='vertical')?this.height:0;
                var x = (bg.direction==='horizontal')?this.width:0;
                var lingrad = this.ctx.createLinearGradient(
                  0, 0, x, y
                );
                lingrad.addColorStop(0, bg.from);
                lingrad.addColorStop(1, bg.to);
                this.ctx.fillStyle = lingrad;
                this.ctx.fillRect(0, 0, this.width, this.height);
                return this;
            },
            drawAxisX: function () {
                this.axisXWidth = this.op.config.axisXWidth || 1;
                //水平目盛線を下辺から描いていく
                for (
                        var top = this.chartBottom, count = 0; 
                        top >= this.chartTop; 
                        top -= this.yGap, count++
                    ) {
                    
                    if(this.adds.length <=2){
                        this.ctx.beginPath();
                        this.ctx.lineWidth = this.axisXWidth;
                        this.ctx.strokeStyle = this.xColor;
                        this.ctx.moveTo(this.chartLeft, top);//ライン描画開始
                        this.ctx.lineTo(this.chartRight, top);//ライン描画終了
                        this.ctx.stroke();
                    }
                    //Y方向の垂直軸ラベル描画へ
                    if(this.onlyChart==='no')this.drawYscale(top, count);
                }
                return this;
            },
            drawAxisY: function () {
                this.axisYWidth = this.op.config.axisYWidth || 1;
                //垂直目盛線を左から描いていく
                this.xScaleSkip = this.op.config.xScaleSkip || 0;
                var lineWidth = this.axisYWidth
                for (
                        var left = this.chartLeft, count = 0;
                        left <= this.chartRight;
                        left += this.xGap, count++
                    ) {
                    
                    if(this.xScaleSkip!==0)
                      if(count % this.xScaleSkip === 0){lineWidth=3}else{ lineWidth=1}
                    this.ctx.beginPath();
                    this.ctx.lineWidth  = lineWidth;
                    this.ctx.strokeStyle = this.yColor;
                    this.ctx.moveTo(left, this.chartTop);//ライン描画開始
                    this.ctx.lineTo(left, this.chartBottom);//ライン描画終了
                    this.ctx.stroke();

                    //X方向の水平軸ラベル描画へ
                    if(this.useFirstToColName && this.onlyChart==='no'){
                        if(this.xScaleSkip!==0){
                             if(count % this.xScaleSkip === 0)
                                  this.drawXscale(left, count);
                        } else {
                            this.drawXscale(left, count);
                        }
                    }
                }
                return this;
            },
            drawXscale: function (left, count){
                if(this.type!=='scatter')if(!this.colNames[count])return this;
                this.ctx.save();
                var xScaleDecimal = this.xScaleDecimal;
                var xScaleColor = this.op.config.xScaleColor || this.textColor ||this.textColors.all|| this.textColors.x ||"#aaa";
                var xScaleFont = this.op.config.xScaleFont || "100 12px 'Arial'";
                var xScaleAlign = this.op.config.xScaleAlign || "center";
                var xOffset = this.op.config.xScaleXOffset || 0;
                var yOffset = this.op.config.xScaleYOffset || 18;
                var tOffset = this.op.config.colNamesTitleOffset || 22;
                if(this.type === 'scatter')tOffset += this.xGap/2;

                if(this.type==='scatter'){
                  var val = '', percent = '';
                  if(left >= this.chartRight){this.wkXScale = this.maxX}//小手先修正あとで再考
                  val = this.util.addComma(this.wkXScale, xScaleDecimal);
                  percent = (this.xScalePercent==='yes')?( ' ('+ count * 10 +'%)' ):'';
                  this.wkXScaleStr = val + percent;//change type to string
                }

                var xWkOffset = 
                  (this.type==='scatter')?0:this.xGap/2 - xOffset;
                this.ctx.font = xScaleFont;
                this.ctx.textAlign = xScaleAlign;
                this.ctx.fillStyle = xScaleColor;
                this.ctx.fillText(
                    (this.type==='scatter')?this.wkXScaleStr:this.colNames[count], 
                    left + xWkOffset , 
                    this.chartBottom + yOffset
               );
               if(count===0){
                 var text = (this.colNamesTitle==='')?'':'(' + this.colNamesTitle + ')';
                 var x = this.chartRight + tOffset;
                 var y = this.chartBottom + yOffset;
                 if(this.type !== 'scatter')
                   this.ctx.fillText(
                        text, 
                        x, 
                        y
                   );
                 else
                   this.drawMemo({
                          "val": text, 
                          "left": this.chartLeft + (this.chartRight - this.chartLeft)/2, 
                          "top":  y + 15,
                          "align": 'center',
                          "color": xScaleColor,
                          "font": xScaleFont
                      })
               }
               if(this.type==='scatter'){
                 this.wkXScale = parseFloat(this.wkXScale);//change type to number
                 this.wkXScale += this.xGapValue;
               }
               this.ctx.restore();
               return this;
            },
            drawYscale: function(top, count){
                this.ctx.save();
                var yScaleDecimal = this.yScaleDecimal;
                var yScaleColor = this.op.config.yScaleColor || this.textColor ||this.textColors.all|| this.textColors.y ||"#aaa";
                var yScaleFont = this.op.config.yScaleFont || "100 12px 'Arial'";
                var yScaleAlign = this.op.config.yScaleAlign || "right";
                var xOffset = this.op.config.yScaleXOffset || this.paddingLeft - 10 ;
                var yOffset = this.op.config.yScaleYOffset || 6;
                
                xOffset = (this.adds.length > 2)?(this.chartRight+10):xOffset;
                yScaleAlign = (this.adds.length > 2)?'left':yScaleAlign;
                
                var val = '', percent = '';
                if(this.type === 'stacked%'){
                    val = count * 10 +'%';
                } else {
                    //console.log((top+' '+ this.chartTop))
                    if(top <= this.chartTop){this.wkYScale = this.maxY}//小手先修正あとで再考
                    val = this.util.addComma(this.wkYScale, yScaleDecimal);
                    percent = (this.yScalePercent==='yes')?( ' ('+ count * 10 +'%)' ):'';
                }
                
                this.wkYScaleStr = val + percent;//change type to string
                
                this.ctx.font = yScaleFont;
                this.ctx.fillStyle = yScaleColor;
                this.ctx.textAlign = yScaleAlign;
                this.ctx.fillText(
                    this.wkYScaleStr, xOffset , 
                    top + yOffset
                );
                this.wkYScale = parseFloat(this.wkYScale);//change type to number
                this.wkYScale += this.yGapValue;

                if(count===0){
                  if(this.type === 'scatter'){
                    var text = (this.rowNamesTitle==='')?'':'(' + this.rowNamesTitle + ')';
                    var x = this.chartLeft + -10;
                    var y = this.chartTop + (this.chartHeight/2);
                    this.ctx.font = yScaleFont;
                    this.ctx.fillStyle = yScaleColor;
                    this.ctx.textAlign = yScaleAlign;
                    this.ctx.textAlign = 'center';
                    this.ctx.translate( 24,this.chartTop+(this.chartHeight/2) )
                    this.ctx.rotate( 45 * 2 * Math.PI / 12 )
                     this.ctx.fillText(
                          text, 
                          0, 
                          0
                     );
                     
                  }
                }
                this.ctx.restore();
               return this;
            },
            drawTitle: function(){
                if(this.title === '')return this;
                this.ctx.save();
                var title = this.title || "";
                var titleFont = this.op.config.titleFont || "100 28px 'Arial'";
                var titleTextAlign = this.op.config.titleTextAlign || "center";
                var titleColor = 
                  this.op.config.titleColor || this.textColor ||this.textColors.all|| this.textColors.title || "#ccc";
                var titleY = this.op.config.titleY || 38;
                
                this.ctx.font = titleFont;
                this.ctx.textAlign = titleTextAlign;
                this.ctx.fillStyle = titleColor;
                this.ctx.fillText(title, this.width/2, titleY);
                this.ctx.restore();
                return this;
            },
            drawSubTitle: function(){
                if(this.subtitle === '')return this;
                this.ctx.save();
                var subTitle =  this.subtitle || "";
                var subTitleFont = this.op.config.subTitleFont || "100 12px 'Arial'";
                var subTitleTextAlign = this.op.config.subTitleTextAlign || "center";
                var subTitleColor = 
                  this.op.config.subTitleColor || this.textColor ||this.textColors.all|| this.textColors.subTitle ||"#ddd";
                var subTitleY = this.op.config.subTitleY || 55;
                if(this.title === '')subTitleY = 25;
                
                this.ctx.font = subTitleFont;
                this.ctx.textAlign = subTitleTextAlign;
                this.ctx.fillStyle = subTitleColor;
                this.ctx.fillText(subTitle, this.width/2, subTitleY);
                this.ctx.restore();
                return this;
            },
            drowHanrei: function () {
                //凡例出力
                this.ctx.save();
                var len = this.hanreiNames.length;
                var xOffset = this.op.config.hanreiXOffset || 14;
                var yOffset = this.op.config.hanreiYOffset || 40;
                var radius = this.op.config.hanreiRadius  || (len < 10)?8:(len < 20)?5:3;
                var offradius = 0;
                if(this.type==='line' ||this.type==='bezi' ||this.type==='bezi2'){
                  offradius = radius/5;
                  radius = radius - offradius;
                }
                var lineHeight = this.op.config.hanreiLineHeight || (len < 10)?20:(len < 20)?14:8;
                var fontsize = (len < 10)?12:(len < 20)?9:6;
                var font = this.op.config.hanreiFont || "100 "+fontsize+"px 'Arial'";
                var color = 
                  this.op.config.hanreiColor || this.textColor ||this.textColors.all|| this.textColors.hanrei ||"#ccc";
                var align = this.op.config.hanreiAlign || "left";
                var shdw = (this.shadows)?this.shadows.hanrei||this.shadows.all||['#222', 5, 5, 5]:'';
                
                if(this.adds.length >= 2){
                    xOffset = xOffset + 48;
                } 
                if(this.adds.length == 2){//2つめのY位置
                    yOffset = yOffset + (lineHeight*len ) + 10;
                }
                
                for(var i = 0; i < this.hanreiNames.length; i++){
                    this.ctx.beginPath();
                    if(this.useShadow === 'yes')this.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                    this.ctx.fillStyle = this.colorSet[i];
                    this.ctx.strokeStyle = this.colorSet[i];
                    if(this.hanreiMarkerStyle === 'arc')markerArc(this);
                    else markerRect(this);
                    
                    this.ctx.font = font;
                    this.ctx.textAlign = "left";
                    this.ctx.fillStyle = color;
                    this.ctx.fillText(
                        this.hanreiNames[i], 
                        this.chartRight + xOffset + radius * 2 , 
                        this.chartBottom - (lineHeight * i) - yOffset
                    );
                    this.ctx.closePath();
                }
                this.ctx.restore();
                
                function markerArc(that){
                    var x = that.chartRight + xOffset;
                    var y = that.chartBottom -(lineHeight * i)- yOffset- 4;
                    that.ctx.arc(
                        x, 
                        y,
                        radius, 
                        0, 
                        Math.PI*2
                    );
                    that.ctx.fill();
                    if(that.type==='line' ||that.type==='bezi'||that.type==='bezi2'){
                      that.ctx.beginPath();
                      that.ctx.lineWidth=3;
                      that.ctx.moveTo(x-offradius*2-6 , y  );
                      that.ctx.lineTo(x+radius*2-offradius*2, y  );
                      that.ctx.stroke();
                    }
                }
                function markerRect(that){
                    var x = that.chartRight + xOffset -radius;
                    var y = that.chartBottom -(lineHeight * i)- yOffset- 3 -radius;
                    that.ctx.fillRect(
                        x, 
                        y,
                        radius*2,  
                        radius*2
                    );
                    that.ctx.fill();
                    if(that.type==='line' ||that.type==='bezi'||that.type==='bezi2'){
                      that.ctx.lineWidth=3;
                      that.ctx.moveTo(x-offradius*2, y+radius);
                      that.ctx.lineTo(x+radius*2+offradius*2, y+radius);
                      that.ctx.stroke();
                    }
                }
                return this;
            },
            drawUnit: function(unit){
                if(this.type==='scatter')return;
                var unitTitle = navigator.language==='ja'?'単位:':'';
                var left = this.chartLeft - (this.op.config.unitXOffset || 10);
                var top = this.chartTop - (this.op.config.unitYOffset || 12);
                var color = this.op.config.unitColor || this.textColor ||this.textColors.all|| this.textColors.unit || "#aaa";
                var font = this.op.config.unitFont || "100 12px 'Arial'";
                var align = this.op.config.unitAlign || "right";
                
                left = (this.adds.length > 2)?(this.chartRight+10):left;
                align = (this.adds.length > 2)?'left':align;
                
                if(typeof unit==='string'){
                    this.unit = this.unit;
                    this.drawMemo({
                        "val": '('+unitTitle + this.unit + ')', 
                        "left": left, 
                        "top":  top,
                        "align": align,
                        "color": color,
                        "font": font
                    })
                } else if(typeof unit==='object'){
                    this.unit = unit.unit;
                    this.drawMemo({
                        "val": '('+unitTitle + unit.unit + ')', 
                        "left": unit.left || left, 
                        "top":  unit.top || top,
                        "align": unit.align || 'left',
                        "color": unit.color || color,
                        "font": unit.font || font
                    })
                }
                return this;
            },
            drawVals: function () {
               //データ値を出力する
               if(this.useVal==='no')return this; //no|yes
                this.ctx.save();
                var xOffset = this.valXOffset = this.op.config.valXOffset || 0;
                var yOffset = this.valYOffset = this.op.config.valYOffset || 0;
                var font = this.valFont = this.op.config.valFont || "100 12px 'Arial'";
                //各オプションは配列でデータ行単位でも指定できます
                for (var k = 0; k < this.dataRowLen; k++) {
                    if( typeof this.useVal==='object'){
                        if(this.useVal[k]==='no')continue;
                    }
                    if( typeof this.valXOffset==='object'){
                        xOffset = this.valXOffset[k]|| 0;
                    }
                    if( typeof this.valYOffset==='object'){
                        yOffset = this.valYOffset[k]|| 0;
                    }
                    if( typeof this.valFont==='object'){
                        font = this.valFont[k]||"100 12px 'Arial'";
                    }
                    //データの文字色 this.valColorの指定がなければcolorSet
                    var color = 
                        (typeof this.valColor==='string')?
                          this.valColor: 
                          ( typeof this.valColor==='object' &&
                            this.valColor.length > 0)?
                                  this.valColor[k]:this.colorSet[k];
                    var x = this.chartLeft;
                    x += this.xGap / 2; 
                    for (var l = 0; l < this.data[k].length; l++) {
                        var y = this.chartBottom - (this.data[k][l] - this.minY) * this.unitH;
                        this.ctx.beginPath();
                        this.ctx.font = font;
                        this.ctx.fillStyle = color;
                        this.ctx.textAlign = "right";
                        this.ctx.fillText(
                            this.data[k][l], 
                            x+xOffset , y-yOffset
                        );
                        
                        x += this.xGap;
                    }
                }
                this.ctx.restore();
                return this;
            },
            _drawVals: function (op) {
               //データ値を出力する
               var it = op.that;
               var k = op.row;
               var l = op.col;
               if(it.useVal==='no')return this; //no|yes
                it.ctx.save();
                it.valColor = it.op.config.valColor ;
                var xOffset = it.valXOffset = it.op.config.valXOffset || op.xoff || 10;
                var yOffset = it.valYOffset = it.op.config.valYOffset || op.yoff || -20;
                var font = it.valFont = it.op.config.valFont ||op.font|| "100 12px 'Arial'";
                //各オプションは配列でデータ行単位でも指定できます
                
                if( typeof it.useVal==='object'){
                    if(it.useVal[k]==='no')return this;
                }
                if( typeof it.valXOffset==='object'){
                    xOffset = it.valXOffset[k]|| 0;
                }
                if( typeof it.valYOffset==='object'){
                    yOffset = it.valYOffset[k]|| 0;
                }
                if( typeof it.valFont==='object'){
                    font = it.valFont[k]||op.font||"100 12px 'Arial'";
                }
                //データの文字色 it.valColorの指定がなければop.color
                var color = 
                    (typeof it.valColor==='string')?
                      it.valColor: 
                      ( typeof it.valColor==='object' &&
                        it.valColor.length > 0)?
                              it.valColor[k]:op.color;
                var val = op.val;
                if(this.type === 'stacked%')
                    val = (this.percentVal==='yes')?op.percent+'%':op.val;

                it.ctx.font = font;
                it.ctx.fillStyle = color;
                it.ctx.textAlign = op.align||"right";
                
                val = val || 0;
                op.x = op.x || 0;
                op.y = op.y || 0;
                
                it.ctx.fillText(
                    val,
                    op.x+xOffset , 
                    op.y+yOffset
                );
                
                it.ctx.restore();
                return this;
            },
            drawMarkers: function (op) {
                //データマーカーを描く
                var that = this;
                this.ctx.save();
                if(!op)var op = this.op||{};
                var markerWidth = op.markerWidth || this.markerWidth;
                var colorSet = op.colorSet || this.colorSet;
                var wkOffset = (this.type==='scatter')?0:this.xGap/2;
                var colorIndex = 0;

                if(this.type === 'stackedarea'){
                  var data = this.stacedData;
                } else if(this.type === 'stacked%'){
                  var data = this.stacedPData;
                } else {
                  var data = this.data;
                }
                if(this.useCss==='yes' && this.hybridBox){
                   var cssGroup = 
                      document.querySelector('#-ccchart-css-group-' + this.id);
                   cssGroup.innerHTML='';
                }
                if(this.type==='scatter'){
                  for (var l = 0; l < this.dataColLen; l++) {
                   
                    colorIndex =  this.hanreiNames.indexOf(this.colNames[l]) ;
                    if(colorIndex < 0)colorIndex=0;
                        
                    var posx = 
                          (data[0][l]||0)*this.unitW;
                    var x= posx+this.chartLeft - this.minX * this.unitW;
                    var posy = 
                          (data[1][l]||0)*this.unitH;
                    var y = (this.chartBottom - (posy - this.minY * this.unitH));
                      //draw
                    _drawmarkers(x||0, y||0, 0, l, data, colorSet, colorIndex);
                  }
                } else {
                  for (var k = 0; k < this.dataRowLen; k++) {
                    var x = this.chartLeft;
                    x += wkOffset; 
                    for (var l = 0; l < data[k].length; l++) {
                      colorIndex = k;
                      var posy = 
                        data[k][l]*this.unitH;
                      var y = this.chartBottom - (posy - this.minY * this.unitH);
                      //draw
                      _drawmarkers(x, y, k, l, data, colorSet, colorIndex);
                      x += this.xGap;
                    }
                      
                  }
                }
                this.ctx.restore();
                
                function _drawmarkers(x, y, row, col, data, colorSet, colorIndex){
                  that.ctx.beginPath();
                  that.ctx.fillStyle = colorSet[colorIndex];
                  var scatterX = (that.type==='scatter')?data[0][col]:'';
                  var scatterY = (that.type==='scatter')?data[1][col]:'';
                  if(that.useCss === 'yes' &&
                      ( that.useMarker === 'css-ring'|| 
                        that.useMarker === 'css-maru')
                  ){
                    var op = {
                        x: x, y: y, 
                        radius: markerWidth / 2 ,
                        row:row,col:col,//scatterではrowは常に0
                        data: data[row][col],
                        scatterX: scatterX, scatterY: scatterY,
                        colorIndex:colorIndex
                    }
                     
                    if(that.useMarker === 'css-ring'){
                        that.css_ring(op);
                    } else if(that.useMarker === 'css-maru'){
                        that.css_maru(op);
                    }
                  } else {
                      that.ctx.arc( //丸を打つ
                            x, y, markerWidth / 2, 0, Math.PI * 2
                      );
                  }
                  that.ctx.closePath();
                  that.ctx.fill();
                }
                return this;
            },
            drawXLine: function () {
                //水平カスタム目盛線を描く
                var op = this.xLines;
                this.ctx.save();
                for (var i = 0; i < op.length; i++) {
                    var font = op[i].font || "100 18px 'Arial'";
                    var value = op[i].val || 0;
                    // useRow > value || 0
                    if(this.type==='line'){
                      if(op[i].useRow !== undefined){
                        var useRow = op[i].useRow || ((op[i].useRow===0)?0:this.dataRowLen-1);
                        if(useRow > this.dataRowLen-1 || useRow <= 0)useRow=0;
                        value = (this.data[useRow][this.data[0].length-1]);
                      }
                    }
                    value = value || 0;
                    
                    var lineColor = op[i].color || 'rgba(204,153,0,0.7)';
                    var valueColor = op[i].vColor || lineColor;
                    var lineWidth = op[i].width || 1;
                    var xOffset = this.chartRight - (op[i].xOffset || 2);
                    var yOffset = - (op[i].yOffset || 4);
                    var val = this.unitH * value //this.chartHeight * value / this.maxY; //parseInt(this.maxY/10, 10);
                    
                    var top = (this.chartBottom-(val - this.minY * this.unitH))||0;
                    var shdw = (this.shadows)?this.shadows.xline||this.shadows.all||['#444', 7, 7, 5]:'';
                    //line
                    this.ctx.beginPath();
                    this.ctx.lineWidth = lineWidth;
                    this.ctx.strokeStyle = lineColor;
                    if(this.useShadow === 'yes')this.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                    this.ctx.moveTo(this.chartLeft, top);//ライン描画開始
                    this.ctx.lineTo(this.chartRight, top);//ライン描画終了
                    this.ctx.stroke();
                    //value
                    this.wkYScaleStr = value ;
                    this.ctx.textAlign = "right";
                    this.ctx.font = font;
                    this.ctx.fillStyle = valueColor;
                    this.ctx.fillText(
                        this.wkYScaleStr, xOffset , 
                        top + yOffset
                    );
                }
                this.ctx.restore();
                return this;
             
            },
            _drawLine: function (op, func) {
                //折れ線系グラフ(line,ampli,area)を描く
                this.ctx.save();
                if(!op)var op = this.op||{};
                var lineWidth = op.lineWidth || this.lineWidth;
                var colorSet = op.colorSet || this.colorSet;
                var shdw = (this.shadows)?this.shadows.line||this.shadows.all||['#222', 5, 5, 5]:'';
                for(var k = 0; k < this.dataRowLen; k++ ){
                    var x = this.chartLeft;
                    x += this.xGap/2; //オフセット
                    this.ctx.beginPath();
                    this.ctx.lineWidth  = lineWidth;
                    this.ctx.strokeStyle = colorSet[k];
                    this.ctx.fillStyle = this.colorSet[k];
                    if(this.useShadow === 'yes')if(lineWidth>1)this.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                        //lineWith=1の時影がおかしくなるのでlineWidth>1
                    if(this.type === 'area'){
                        this.ctx.moveTo(x,this.chartBottom);
                    }
                    for(var l = 0; l < this.data[k].length; l++ ){
                        var y = this.chartBottom - (this.data[k][l] - this.minY) * this.unitH;
                        if(this.type === 'area')this.ctx.lineTo(x,y);
                        else {
                            if(l===0) this.ctx.moveTo(x,y);
                            else     this.ctx.lineTo(x,y);
                        }
                        x += this.xGap;
                    }
                    if(this.type === 'area'){
                        this.ctx.lineTo(x-this.xGap,this.chartBottom);
                    }
                    if(func)func(this);
                    else this.ctx.stroke();
                }
                this.ctx.restore();
                this._ondrew(this);

                //Option 内のイベントは、セキュリティのリスクがありうるので一旦停止
                //替りにchart.bind('load',function(e,it){})を使ってください
                /* eval しない場合 */
                //if(this.op.config.onend)this.op.config.onend(this, this.op);
                
                /* eval する場合
                if(this.op.config.onend){
                    var _;
                    eval('_='+this.op.config.onend)
                    _(this, this.op);
                }*/
                
                return this;
            },
            drawLine: function (op) {
                //折れ線グラフを描く
                this._drawLine (op, function(it){it.ctx.stroke()});
                return this;
            },
            drawAmplitude: function (op) {
                //振幅グラフを描く
                this._drawLine (op, function(it){it.ctx.fill()});
                return this;
            },
            drawArea: function (op) {
                //面グラフを描く
                this._drawLine (op, function(it){it.ctx.fill()});
                return this;
            },
            _drawStackedArea: function (op, func) {
                //積み上げ面グラフを描く
                //if(!(this.type === 'stackedarea'||this.type === 'stacked%'))return this;
                this.ctx.save();
                if(!op)var op = this.op||{};
                var lineWidth = op.lineWidth || this.lineWidth;
                var colorSet = op.colorSet || this.colorSet;
                var shdw = (this.shadows)?this.shadows.stackedarea||this.shadows.all||['#222', 5, 5, 5]:'';
                var wkData = [];
                var wkMaxYs = [];
                for(var k = 0; k < this.dataRowLen; k++ ){
                    wkData[k] = [];
                    for(var l = 0; l < this.data[k].length; l++ ){
                        wkData[k][l] = ((this.data[k][l]||0)+(wkData[k-1]?wkData[k-1][l]:0));
                        wkMaxYs[l] = wkData[k][l];
                    }
                }
                this.stacedData = wkData;
                this.stacedPData = [];
                for(var k = wkData.length-1; k >= 0; k-- ){
                    var x = this.chartLeft;
                    x += this.xGap/2; //オフセット
                    this.ctx.beginPath();
                    this.ctx.lineWidth  = lineWidth;
                    this.ctx.strokeStyle = colorSet[k];
                    this.ctx.fillStyle =  colorSet[k];
                    if(this.useShadow === 'yes')if(this.lineWidth>1)this.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                        //lineWith=1の時影がおかしくなるのでthis.lineWidth>1
                    this.ctx.moveTo(x,this.chartBottom);
                    
                    this.stacedPData[k]=[];
                    for(var l = 0; l < wkData[k].length; l++ ){
                        var posy = wkData[k][l] * this.unitH;
                        if(this.type === 'stacked%'){
                            this.stacedPData[k][l] = wkData[k][l]*100/wkMaxYs[l];
                            posy = this.stacedPData[k][l] * this.unitH;
                        }
                        var y = this.chartBottom - (posy /*- this.minY * this.unitH*/);
                        this.ctx.lineTo(x, y);
                        
                        this._drawVals({
                            that: this,
                            //color: '#eee',
                            val: (this.data[k][l]||0),
                            percent: Math.round((this.data[k][l]||0)*100/wkMaxYs[l],10),
                            row:k,
                            col:l,
                            align: 'left',
                            xoff: -10,
                            yoff:-10,
                            x: x  ,
                            y: y
                        });
                        x += this.xGap;
                    }
                    this.ctx.lineTo(x-this.xGap,this.chartBottom);
                    this.ctx.fill();
                   // this.ctx.stroke();
                }
                this.ctx.restore();
                this._ondrew(this);
                return this;
            },
            drawStackedArea: function (op) {
                //積み上げパーセント(構成比推移)グラフを描く
                this._drawStackedArea (op, function(it){});
                return this;
            },
            drawStackedPercent: function (op) {
                //積み上げパーセント(構成比推移)グラフを描く
                //this.yScalePercent は 'yes'です
                this._drawStackedArea (op, function(it){});
                return this;
            },
            drawBar: function () {
                var that = this;
                var shdw = (this.shadows)?this.shadows.bar||this.shadows.all||['#222', 5, 5, 5]:'';

                //全幅サイズを取得
                that.widthOfAllBar = getWidthOfAllBar();

                //widthOfAllBarが垂直目盛線1本の間隔xGapより
                //大きければ調整
                if(this.widthOfAllBar > this.xGap){
                
                     this.barPadding =0;
                     this.barGap =1;
                     this.barWidth = this.xGap/that.dataRowLen-1
                     okDrowBar();
                 
                } else {
                    //棒グラフ描画へ
                    okDrowBar();
                }
                
                this._ondrew(this);

                //全barとかの幅
                function getWidthOfAllBar (){
                    //垂直目盛線1本の間にあるすべてのバーの
                    //幅barWithと隙間barGapとパディングbarPadding
                    //を足した幅をwidthOfAllBarとする
                    return  that.barPadding 
                            + that.barWidth * that.dataRowLen 
                            + that.barGap * (that.dataRowLen-1);
                }

                //棒グラフ描画
                function okDrowBar(){
                    //棒描画
                    _drowBar(function(that,k,l,x,y){
                        that.ctx.fillRect(
                          x, y,
                          that.barWidth,  
                          that.data[k][l] * that.unitH
                        );
                    });
                    //値描画
                    _drowBar(function(that,k,l,x,y){
                        that._drawVals({
                            that: that,
                           // color: '#eee',
                            val:that.data[k][l] ,
                            row:k,
                            col:l,
                            align: 'left',
                            xoff: 2,
                            yoff:-15,
                            x: x  ,
                            y: y
                        });
                    });
                    
                    function _drowBar(func){
                      that.ctx.save();
                      for (var k = 0; k < that.dataRowLen; k++) {
                          var x = that.barPadding + that.chartLeft;
                          that.ctx.beginPath();
                          that.ctx.fillStyle = that.colorSet[k];
                          if(that.useShadow === 'yes')that.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                          for (var l = 0; l < that.data[k].length; l++) {
                              var y = (
                                  that.chartBottom 
                                  - that.data[k][l] * that.unitH
                              );
                              
                              func(that,k,l,x,y)
                              
                              x += that.xGap;
                          }
                          that.ctx.translate(that.barWidth + that.barGap, 0);
                      }
                      that.ctx.restore();
                      return this;
                    }
                }
            },
            drawStackedBar: function () {
                //積重ねグラフを描く 
                this.ctx.save();
                var that = this;
                var x = that.barPadding + that.chartLeft;
                var shdw = (this.shadows)?this.shadows.stacked||this.shadows.all||['#222', 5, -5, 5]:'';
                
               // if(this.type==='stacked')--that.dataColLen;//暫定：あとでチェック
                for (var k = 0; k < that.dataColLen; k++) {
                    var sumHeight = 0; //積重ねた高さ
                    for (var l = 0; l < that.dataRowLen; l++) {
                        var y = (
                            that.chartBottom 
                               - (that.data[l][k]||0)
                               * that.unitH
                        );
                        that.ctx.beginPath();
                        that.ctx.fillStyle = that.colorSet[l];
                        if(that.useShadow === 'yes')that.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                        that.ctx.fillRect(
                            x, y, 
                            that.barWidth,
                            that.chartBottom - y
                        );
                        //値
                        that._drawVals({
                            that: that,
                            color: '#eee',
                            val:(that.data[l][k]||0) ,
                            row:k,
                            col:l,
                            align: 'left',
                            xoff:2,
                            yoff:-20,
                            x: x  ,
                            y: that.chartBottom + 15
                        });
                        that.ctx.translate(0, -(that.chartBottom - y));
                        sumHeight += that.chartBottom - y;
                    }
                    that.ctx.translate(0, sumHeight);
                    x += that.xGap;
                }
                that.ctx.restore();
                this._ondrew(this);
                return this;
            },
            drawbeziLine: function () {
                this.ctx.save();
                var recx=0,recy=0;
                var shdw = (this.shadows)?this.shadows.bezi||this.shadows.all||['#222', 5, 5, 5]:'';
                for(var k = 0; k < this.dataRowLen; k++ ){
                    var x = this.chartLeft;
                    x += this.xGap/2; //オフセット
                    this.ctx.beginPath();
                    this.ctx.lineWidth  = this.lineWidth;
                    this.ctx.strokeStyle = this.colorSet[k];
                    if(this.useShadow === 'yes')this.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                    for(var l = 0; l < this.data[k].length; l++ ){
                        var y = this.chartBottom - (this.data[k][l] - this.minY) * this.unitH;
                        if(l==0) this.ctx.moveTo(x,y);
                        else   this.ctx.quadraticCurveTo(recx,recy,x,y);
                         x += this.xGap;
                         recx =x, recy =y;
                    }
                    this.ctx.stroke();
                }
                this.ctx.restore();
                this._ondrew(this);
                return this;
            },
            drawbeziLine2: function () {
                var shdw = (this.shadows)?this.shadows.bezi2||this.shadows.all||['#222', 5, 5, 5]:'';
                //ベジェグラフを描く
                this.ctx.save();
                for(var k = 0; k < this.dataRowLen; k++ ){
                    var x = this.chartLeft;
                    x += this.xGap/2; //オフセット
                    this.ctx.beginPath();
                    this.ctx.lineWidth  = this.lineWidth;
                    this.ctx.strokeStyle = this.colorSet[k];
                    if(this.useShadow === 'yes')this.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);
                    for(var l = 0; l < this.data[k].length; l++ ){
                        var y = this.chartBottom - (this.data[k][l] - this.minY) * this.unitH;
                        var cpx = x+(this.xGap)/2
                        var cpy = this.chartBottom
                             -  (((this.data[k][l+1] + this.data[k][l])/2) * this.unitH  - this.minY * this.unitH);
                        if(l==0) this.ctx.moveTo(x,y);
                        else if(l==this.data[k].length-1)this.ctx.quadraticCurveTo(x,y,x,y);
                        else     this.ctx.quadraticCurveTo(x,y,cpx,cpy);
                        
                        x += this.xGap;
                    }
                    this.ctx.stroke();
                }
                this.ctx.restore();
                this._ondrew(this);
                return this;
            },
            drawScatter: function () {
                //var shdw = (this.shadows)?this.shadows.scatter||this.shadows.all||['#222', 5, 5, 5]:'';
                
                //Todo 判例列が増えた時の自動Limitter
                
                //散布図を描く
                this.ctx.save();
                this.drawMarkers();
                this.ctx.restore();
                this._ondrew(this);
                return this;
            },
            drawPie: function(){
                this.ctx.save();
                var that = this;
                var shdw = (this.shadows)?this.shadows.pie||this.shadows.all||['#444', 3, 3, 3]:'';
                //var pieMaxCol = this.op.config.pieMaxCol || 0;
                var pieDataIndex = 
                  (this.op.config.pieDataIndex != undefined)?
                    this.op.config.pieDataIndex:(this.dataColLen-1);
                if(pieDataIndex < 0 || pieDataIndex > (this.dataColLen-1))pieDataIndex = (this.dataColLen-1);
                var colNameFont = 
                  this.op.config.colNameFont ||this.op.font|| "100 18px 'Arial'";
                var cnfs = this.util.getFontSizeFromStyle(colNameFont);
                var valFont = this.valFont = 
                  this.op.config.valFont ||this.op.font|| "100 12px 'Arial'";
                var stfs = this.util.getFontSizeFromStyle(
                  (this.op.config.subTitleFont || "100 12px 'Arial'")
                );
                var xOffset = this.op.config.pieXOffset || 0;
                var yOffset = this.op.config.pieYOffset || 0;
                
                //pieHoleRadiusやpieRingWidthを指定しても自動調整されるので
                //信用できないところが使いにくい
                
                var hfW = this.chartWidth/2; //チャートエリア幅 1/2
                var hfH = (this.chartHeight - stfs)/2; //チャートエリア高さ 1/2
                var ringWmin = 20;//リング幅の最小サイズ
                var holeRmin = 50;//ドーナツ穴の半径最小サイズ
                
                var holeR = this.pieHoleRadius; //ドーナツ穴の半径
                if((holeR >= hfW) || (holeR >= hfH))ringW=ringWmin;
                //ドーナツ穴がチャートエリア幅を超えたら
                holeR = Math.min(
                  ((holeR >= hfW)?(hfW - ringWmin):holeR),
                  ((holeR >= hfH)?(hfH - ringWmin):holeR)
                );
                //ドーナツ穴+リング幅/2が　hfWまたはhfHを超えたら
                var ringW = this.pieRingWidth; //リング幅
                var radius = getRadius(holeR, ringW);
                ringW = Math.min(
                  ((radius >= hfW)?(hfW - holeR):ringW),
                  ((radius >= hfH)?(hfH - holeR):ringW)
                );
                radius = getRadius(holeR, ringW);
                var center = Math.min(this.chartHeight ,this.chartWidth )
                var y = this.chartTop+this.chartHeight/2 + yOffset;
                var x = this.width/2 + xOffset;
                var colAry = [];
                var degAry = [];
                var perAry = [];
                var newDeg = 0, oldDeg = 0;
                var TORAD = 2*Math.PI/360;//deg to radian
                var pieDataLastIndex = pieDataIndex;//this.dataColLen

                for(var k = pieDataIndex; k <= pieDataLastIndex; k++){
                 
                  //if(this.id==='hoge0')   console.log(this.id, k,this.dataColLen)
                  
                  colAry[k]=degAry[k]=[];deg = 0;
                  for(var preCol = 0; preCol < this.dataRowLen; preCol++ ){
                    colAry[k].push(this.data[preCol][k]||0);//列配列作成
                  }
                  degAry[k] = this.util.aryToDeg(colAry[k]);//角度配列作成
                  perAry[k] = this.util.aryToPercent(colAry[k]);//角度配列作成
                  for(var l = 0; l < degAry[k].length; l++ ){
                    newDeg += degAry[k][l];
                    var val = colAry[k][l];
                    _drawArc(
                      x, y, radius, 
                      oldDeg*TORAD, newDeg*TORAD, 
                      this.colorSet[l], k, l, 
                      val
                    );
                    oldDeg = newDeg;
                  }
                }
                
                this.ctx.restore();
                this._ondrew(this);

                //半径取得
                function getRadius(holeRadius, ringW){
                  return holeRadius + ringW/2;
                }
                //ドーナツ穴の直径
                function getHoleW(radius, ringW){
                  return radius*2 - ringW;
                }
                
                function _drawArc(x, y, r, rStartAng, rEndAng, color,k,l,val){
                  that.ctx.save();
                  that.ctx.beginPath();
                  that.ctx.strokeStyle =  that.colorSet[l];
                  that.ctx.lineWidth =  ringW;
                 // that.drawShadow(shdw[0],shdw[1],shdw[2],shdw[3]);

                  //値のXY
                  var rad = rStartAng + (rEndAng - rStartAng)/2;
                  var valX = x+(radius+ringW/2+8) * Math.cos( rad )
                  var valY = y+(radius+ringW/2+8) * Math.sin( rad )
                  
                  //値描画
                  that._drawVals({
                    that: that,
                    color: that.ctx.strokeStyle ,
                    val: parseInt(val) +' ('+parseInt(perAry[k][l])+'%)' ,
                    row:k,
                    col:l,
                    align: (valX < x)? 'right':'left',
                        //値の位置によってalineを変える
                    font: valFont,
                    xoff:1,
                    yoff:5,
                    x: valX,
                    y: valY
                  });
                  try{
                    //ドーナッツ描画
                    that.ctx.arc(
                      x, 
                      y,
                      radius, 
                      rStartAng, 
                      rEndAng
                    );
                  }catch(e){
                  }
                  //項目タイトル文字描画
                  var txt = that.colNames[k]||'';
                  that.ctx.textAlign = 'center';
                  that.ctx.fillStyle =   that.textColor ||that.textColors.all|| '#333';
                  that.ctx.font =colNameFont;
                  //文字の合計幅がドーナツ穴直径より大きいなら下に移動
                  if(getHoleW(radius, ringW)*2 < (txt.length * cnfs)){
                    y = y + radius + ringW/2 ;
                  }
                  that.ctx.fillText( txt , x, y + cnfs/2-2);
                  that.ctx.fillStyle =  '#888';
                  that.ctx.stroke();
                  that.ctx.restore();
                }
            },
            drawShadow: function (color, x, y, blur) {
                if(this.useShadow !== 'yes')return this;
               // var ua = this.util.isMobile();
               // if(ua === 'android')
               //     y = -y;
               // 影が反対につくバグはAndroid4.0で直っているらしい
                var ua = navigator.userAgent.toLowerCase();
                var isAndroid = 
                    /(android) ([0-9])/.exec(ua);
                if(isAndroid)y = (isAndroid[2] < 4)? -y : y;

                this.ctx.shadowColor = color||'#222';
                this.ctx.shadowOffsetX = x||5;
                this.ctx.shadowOffsetY = y||5;
                this.ctx.shadowBlur = blur||5;
                return this;
            },
            flip: function(cvs, lists, flipDirection){
                var xbcss = this.util.xbcss;
                var direction = flipDirection?flipDirection:this.flipDirection;
                var scaleProp = (direction === 'x')? 'scaleX' : 'scaleY';
                var index = parseInt(this.canvas.getAttribute('data-flipIndex'), 10);
                //set a current chart to the cvs.flipListTop, and add to top of the lists
                if(isNaN(index)){
                    this.flipLists = lists;
                    this.flipLists.unshift(this.op);//console.log(index, next,this.flipLists)
                    index = 1;
                }
                var next = this.flipLists[ index ];
                var stepMax = 5;
                var interval = 8;
                
                chg(cvs, next, stepMax);

                if(index >= this.flipLists.length-1){
                    index = 0;
                } else index++;
                cvs.setAttribute('data-flipIndex', index);
                
                function chg(cvs, next, stepMax){
                    var i=stepMax;
                    clearInterval(this.flipID);
                    this.flipID = setInterval(function(){
                      try{
                        var s=i/stepMax;
                        if(i <= -stepMax)clearInterval(this.flipID);
                        
                        if(i >= 0){
                            cvs.setAttribute('style', xbcss.enjoy(
                                xbcss[scaleProp](s)
                            ));
                        }else if(i < 0){
                            cvs.setAttribute('style', xbcss.enjoy(
                                xbcss[scaleProp]( Math.abs(s) )
                            ));
                        }
                        if(i===0)ccchart.init(cvs, next);

                        i--;
                      } catch(e){clearInterval(this.flipID);console.log('err')}
                    },interval);
                }
                return this;
            },
            flipX: function(cvs, lists){this.flip(cvs, lists, 'x');return this;},
            flipY: function(cvs, lists){this.flip(cvs, lists, 'y');return this;},
            move: function(a0,a1,a2,a3){
                if((''+a0.nodeName).toLowerCase() === 'canvas'){
                    this.move1(a0,a1,a2,a3);//(cvs, config, dataAry, delay);
                } else if(this.util.isArray(a0)){
                    this.move2(a0,a1);//(colData, delay)
                }
                return this;
            },
            ws: function(url, cb){
              var that = this;
              var uid = (new Date).getTime() + '' +(Math.random()*100);
              var protocol = 'ws.ccchart.com';
              var id = this.id;
              var w = this.wses[id+'-ccchart-'+url];
              if(w){
                if( w.readyState === w.OPEN && w.on ){
                  // do nothing
                } else {
                  w = _w(url, id); // if !OPEN
                }
              } else {
                w = _w(url, id); // if !w
              }
              w.id = id;
              if(cb)cb(w, url);
              function _w(url, id){
                  var w = 
                    new (window.WebSocket || window.MozWebSocket)
                      ( url, protocol);
                  w.on = w.addEventListener;
                  w.uid = uid;
                  w.on('open', function () { console.log('ws opened: ' + url + ' for canvas id:' + id); });
                  w.on('close' , function () { 
                    // console.log('ws closed: ' + url + ' at ' + id); 
                  });
                  return w;
              }
              this.wses[id+'-ccchart-'+url] = w;
              
              return w;
            },
            wsCloseAll: function(){
              for(var i in ccchart.wses){
                ccchart.wses[i].on('close', 
                  function(){console.log('ws closed: '+ccchart.wses[i].url)}
                );
                ccchart.wses[i].close();
              }
            },
            wscase: {
              // WebSocketの受信パターン
                /* e.g. 
                [
                  ["2013", "2014", "2015", "2016", "2017"],
                  [   435,    332,    524,    688,    774],
                  [   600,    335,    584,    333,    457]
                ];*/

              oneColAtATime: function(msg){
                // 一度に1列ずつ [["2013"],[435],[600]] といった配列で届く場合
                // e.g. ws.on('message', ccchart.wscase.oneColAtAtime)
                var msgs = JSON.parse(msg.data);
                var that = ccchart.ops[this.id];
                if(that.drawing){
                  console.log('I threw away the data: ', JSON.stringify(msgs));
                  return;           // グラフ描画中なら着信データを捨てる
                }
                for(var i =0; i < msgs.length; i++){
                  var rowTitle = that.op.data[i].shift();// 先頭を行タイトルとして削除
                  that.op.data[i].push(msgs[i]);// WSで受け取ったデータを追記
                  if(that.op.data[i].length > that.maxWsColLen ){
                    that.op.data[i].shift();// maxWsColLen列以上は削除
                  }
                  that.op.data[i].unshift(rowTitle);// 先頭へ行タイトルを戻す
                }
                if(that.type==='pie'){ that.op.config.maxWsColLen = 1}
                ccchart.init(that.id, that.op);//再起へ
              },
              someColsAtATime: function(msg){
                // 一度に複数列ずつ [[["製品A"],[435],[600]],[["製品B"],[332],[335]],[["製品C"],[524],[584]]] 
                // といった配列で届く場合  複数列の列数 === maxWsColLen
                // e.g. ws.on('message', ccchart.wscase.someColsAtATime)
                var msgs = JSON.parse(msg.data);
                var that = ccchart.ops[this.id];
                if(that.drawing){
                  console.log('I threw away the data: ', JSON.stringify(msgs));
                  return;           // グラフ描画中なら着信データを捨てる
                }
                for(var j =0; j < msgs.length; j++){
                  for(var i =0; i < msgs[j].length; i++){
                    var rowTitle = that.op.data[i].shift();// 先頭を行タイトルとして削除
                    that.op.data[i].push(msgs[j][i]);// WSで受け取ったデータを追記
                    if(that.op.data[i].length > that.maxWsColLen ){
                      that.op.data[i].shift();// maxWsColLen列以上は削除
                    }
                    that.op.data[i].unshift(rowTitle);// 先頭へ行タイトルを戻す
                  }
                }
                ccchart.init(that.id, that.op);//再起へ
                
              }
            },
            //調整中：
            move1: function(cvs, config, dataAry, delay){
                console.log('調整中');return;
                
                var that = this;
                var dly = (delay!==undefined)?delay:100;
                var cnfIsAry = this.util.isArray(config);
                var i = 0;
                clearInterval(this.moveTid);
                this.moveTid = setInterval(function () {
                    try{
                        if(i < dataAry.length - 1) {
                            i++;
                            var chartdata = { 
                              "config": (cnfIsAry)?config[i]:config,
                              "data": dataAry[i]
                            }
                            that.init(cvs, chartdata);
                        } else {
                            clearInterval(this.moveTid);
                        }
                    } catch(e) {
                        clearInterval(this.moveTid);
                    }
                }, dly);
                return this;
            },
            //調整中：
            move2: function(colDataAry, delay){
                console.log('調整中');return;
                
                var that = this;
                if(!colDataAry)return this;
                if(this.moveStack.length===0){
                    if(!this.moveIntOpData){
                        this.moveIntOpData = JSON.stringify(this.op.data);
                        if(this.useFirstToRowName){
                            this.moveIntRowNames = this.rowNames;
                        }
                    } else if(this.moveIntOpData!==this.op.data){
                        this.moveDly = 0;//move2 delay 初期値
                        this.moveStack = [];
                        this.moveStackDly =[];
                        this.op.data = JSON.parse(this.moveIntOpData);
                    }
                }
                var dly = delay || 200;
                this.moveDly += dly;
                var cnf = this.op.config;
                var d = this.op.data;
                for(var i=0; i<d.length;i++){
                    d[i].shift();
                    d[i].shift();
                    d[i].push(colDataAry[i]);
                    d[i].unshift(this.moveIntRowNames[i-1]);
                    if(i===d.length-1){
                        this.moveStack.push(JSON.stringify(d));
                    }
                }
                this.moveStackDly.push(this.moveDly);
                if(this.moveStack.length===0){
                    draw(that);
                } else {
                    var tid = setTimeout(function(){
                        clearTimeout(tid);
                        draw(that);
                    },  this.moveStackDly.shift());
                }
                function draw(that){
                    var data =JSON.parse(that.moveStack.shift());
                    that.init({
                        "config": cnf,
                        "data": data
                    });
                }
                return this;
            },
            drawImg: function(arg){
                this.ctx.save();
                if(!arg)var arg = this._img||{};
                var url =  arg[0] || "";
                if(url === "")return this;
                var len = arg.length;
                var that = this;
                this.currImgTargetCtx = this.cxs[this.id];
                var sx,sy,sw,sh,dx,dy,dw,dh;
                var img = new Image();
                img.src = url;
                img.onload = function(){
                    if(len <=3){
                            dx = arg[1] || 0;
                            dy = arg[2] || 0;
                            that.currImgTargetCtx
                                .drawImage(img, dx, dy);
                    } else if(len <=5){
                            dx = arg[1] || 0;
                            dy = arg[2] || 0;
                            dw = arg[3] || 0;
                            dh = arg[4] || 0;
                            that.currImgTargetCtx
                                .drawImage(img, dx, dy, dw, dh);
                    } else if(len <=9 ){
                            sx = arg[1] || 0;
                            sy = arg[2] || 0;
                            sw = arg[3] || 0;
                            sh = arg[4] || 0;
                            dx = arg[5] || 0;
                            dy = arg[6] || 0;
                            dw = arg[7] || 0;
                            dh = arg[8] || 0;
                            that.currImgTargetCtx
                                .drawImage(img, sx, sy, sw, sh, dx, dy, dw, dh);
                    }
                }
                this.ctx.restore();
            },
            drawMemo: function(op){
                this.ctx.save();
                if(!op)var op = this._memo||{};
                var val =  op.val || "";
                var left = op.left || 0;
                var top = op.top || 0;
                var lineTo = op.lineTo || false;
                var lineTo2 = op.lineTo2 || false;
                if(!(val && ((left && top) || lineTo || lineTo2)))return this;
                var font = op.font || "100 14px 'Arial'";
                var textAlign = op.align || "left";
                var fillStyle = op.color || this.textColor ||this.textColors.all|| this.textColors.memo || "#ccc";
                if(this.util.isArray(lineTo)){
                    if(lineTo.length===2){
                        var lineToXOffset  = (typeof op.lineToXOffset ==='number')?op.lineToXOffset:50;
                        var lineToYOffset  = (typeof op.lineToYOffset ==='number')?op.lineToYOffset:3;
                        var lineToWidth  = (typeof op.lineToWidth ==='number')?op.lineToWidth:1;
                        var lineToColor  = op.lineToColor || fillStyle;
                        
                    } else {
                        lineTo = false;
                    }
                } else lineTo = false;

                this.ctx.font = font;
                this.ctx.textAlign = textAlign;
                this.ctx.fillStyle = fillStyle;
                this.ctx.fillText(val, left, top);
                
                if(lineTo){
                    var that = this;
                    _lineTo(
                      decodeURIComponent(_getNum(this.id, 'rowNames', lineTo[0])), 
                      decodeURIComponent(_getNum(this.id, 'colNames', lineTo[1]))
                    )
                }
                this.ctx.restore();
                return this;
                
                function _lineTo(row, col){
                    //line
                    var x = that.chartLeft + that.xGap / 2 + that.xGap * col; 
                    var y = that.chartBottom - ( that.data[row][col] - that.minY ) * that.unitH;
                    that.ctx.save();
                    that.ctx.beginPath();
                    that.ctx.lineWidth = lineToWidth;
                    that.ctx.strokeStyle = lineToColor;
                    that.ctx.moveTo(left + lineToXOffset, top + lineToYOffset);
                    that.ctx.lineTo(x, y);
                    that.ctx.stroke();
                    that.ctx.restore();
                }
                function _getNum(id, prop, val){
                    for(var i=0;i<that.ops[id][prop].length;i++){
                          if(''+that.ops[id][prop][i]===''+val)return i;
                    }
                    //console.log('This '+prop+' does not exist.')
                }
            },
            toData: function(arg){
                var type, canvas;
                if(typeof arg !== 'object'){
                    type = 'image/png';
                    canvas = this.canvas;
                } else {
                    type = (arg.type)?arg.type:'image/png';
                    if((''+arg.canvas.nodeName).toLowerCase() === 'canvas'){
                        canvas = arg.canvas;
                    } else {
                        canvas = document.getElementById(arg.canvas);
                    }
                }
                
                return canvas.toDataURL(type);
            },
            add: function(op, callback){
                var that = this;
                this.adds.push([this.id, op, callback]);
                this.init(this.adds[0][0], this.adds[0][1], this.adds[0][2]);
                this.adds.push([this.id, op, callback]);
                this.preProcessing (op, callback);
                that.adds=undefined;
                return this; 
            },
            line: function(op){ this.drawLine(op);return this; },
            markers: function(op){ this.drawMarkers(op);return this; },
            memo: function(op){ this.drawMemo(op);return this; },
            setOp: function(prop, ops){//test for ops
                //this.setOp('width', op.config.width || 600);
                return this.ops[this.id][prop] = this[prop] = ops;
            },
            util:{
                cnfExtend: function(baseCnf, newCnf){
                  // baseCnfオブジェクトをディープコピーしてnewCnfを追加
                  var base = deepJSONCopy(baseCnf);
                  return appendCnfCopy(base, newCnf);

                  // ひな形oldObjectをディープコピー 
                  //  (元ojへの参照なしコピー。ついでに不正なJSONも排除)
                  function deepJSONCopy(oldObject){
                    return JSON.parse(JSON.stringify(oldObject));
                  }

                  // baseCnfオブジェクトへnewCnfを追加コピー
                  function appendCnfCopy(baseCnf, newCnf){
                    for(var i in newCnf){
                      var prop = newCnf[i];
                      if(i === 'config' || i === 'data'){
                        if(typeof prop==='object' && !ccchart.util.isArray(prop)){
                          appendCnfCopy(baseCnf[i], prop);
                        } else { baseCnf[i] = prop;}
                      } else { baseCnf[i] = prop;}
                    }
                    return baseCnf;
                  }
                },
                uniq: function(ary){ //[1,1,2,3,3,2] => [1,2,3]
                  //配列内項目の重複を無くす
                  var old=null
                  var _ary=[];
                  ary.sort().forEach(function(x,i,a){
                    if(x===null)return;
                    if(old!==x)_ary.push(x);
                    old=x;
                  })
                  return _ary;
                },
                addComma: function (num, deci) {
                  //3桁カンマ
                  //forked from http://fukuno.jig.jp/2012/util.js#addComma
                  if (isNaN(parseFloat(num)))
                      return num;
                      
                  var s = '';
                  var decimal = '';
                  var comma = '.';
                  if(deci){
                    
                    s = parseFloat(num);
                    s = '' + Math.round(s * 1000)/1000;//三桁
                    decimal = s.split(comma)[1];
                    s = s.split(comma)[0];
                  } else {
                    s += parseInt(num);
                    comma = '';
                  }

                  var singn = s.charAt(0);
                      singn = (singn==='-'||singn==='+')?singn:'';
                  s = (singn==='')?s:s.substr(1);
                  for (var i = 3; i < s.length; i += 4) {
                      s = s.substring(0, s.length - i) + "," + s.substring(s.length - i);
                  }
                  decimal = isNaN(decimal)?'':comma + decimal;
                   return singn + s + decimal;
                },
                getMax: function (that){
                    //最大値を求める
                    return this
                      ._preGetMinMax(that)
                      .sort(function(a,b){return b-a})[0];
                },
                getMin: function (that){
                    //最小値を求める
                    return this
                      ._preGetMinMax(that)
                      .sort(function(a,b){return a-b})[0];
                },
                _preGetMinMax: function (that){
                    var _ary = [];
                    for(var i = 0; i < that.dataRowLen; i++){
                      var _aryR=[];
                      for(var j = 0; j < that.data[i].length; j++){
                        if(
                          !(that.data[i][j]===null ||
                            that.data[i][j]===undefined)
                        ) _aryR=_aryR.concat(that.data[i][j]);
                      }
                      _ary=_ary.concat(_aryR);
                    }
                    return _ary;
                },
                getMaxSum: function(that){
                    //積み重ねた時に最大になる列の合計値を求める
                    var _ary = [];
                    var _sum = 0;
                    for(var i = 0; i < that.dataColLen; i++){
                        for(var j = 0; j < that.dataRowLen; j++){
                            if(that.data[j][i])_sum += parseFloat(that.data[j][i]);
                        }
                        _ary.push(_sum);
                        _sum =0;
                    }
                    return _ary.sort(function(a,b){return b-a})[0];
                },
                aryToPercent: function(ary){
                  // 配列内の各要素をその合計に対するパーセントに置き換えた配列を返す
                  //null等は0
                  // [1,2,3] => [16.666666666666664, 33.33333333333333, 50]
                  var a=0,b=[];
                  ary.forEach(function(x, i){ a+=(x||0) });
                  ary.forEach(function(x, i){ b.push(((x||0)/a)*100) });
                  return b;
                },
                aryToDeg: function(ary){
                  // 配列内の各要素をその合計に対する角度degに置き換えた配列を返す
                  // [1,2,3] => [59.999999999999986, 119.99999999999997, 180]
                  var b=[];
                  var a = this.aryToPercent(ary);
                  a.forEach(function(x, i){ b.push(( x/100 ) * 360) });
                  return b;
                },
                isMobile: function () {
                  //スマートフォン識別文字列 android|iphone|ipad|iemobile を返す
                    var ua = navigator.userAgent.toLowerCase();
                    var match = /(android|iphone|ipad|iemobile)/.exec(ua);
                    return match ? match[0] : null;
                },
                isArray: function(arg){
                    if(typeof arg === 'object' && arg.length >= 0) return true;
                    return Object.prototype.toString.call(arg).toLowerCase() === '[object array]';
                },

                bGgradient: function (from,to,start){
                    var start = start || 'left'
                    return ';'
                    +';background-image:'
                        +'-webkit-gradient(linear, '+start+' top, '+start+' bottom, color-stop(0, '+from+'), color-stop(.5, '+to+'))'
                    +';background-image:-webkit-linear-gradient('+start+', '+from+' 0%, '+to+' 50%)'
                    +';background-image:-moz-linear-gradient('+start+', '+from+' 0%, '+to+' 50%)'
                    +';background-image:-ms-linear-gradient('+start+', '+from+' 0%, '+to+' 50%)'
                    +';background-image:-o-linear-gradient('+start+', '+from+' 0%, '+to+' 50%)'
                    +';'
                },
                setBG: function (doms, from, to, start){
                    if(doms.nodeType===1){
                        doms.style.cssText = ccchart.util.bGgradient(from, to, start);
                    } else if(doms.length > 0) {
                        for(var i=0;i<doms.length;i++){
                            doms[i].style.cssText = ccchart.util.bGgradient(from, to, start);
                        }
                    }
                },
                getFontSizeFromStyle: function(fontStyle){
                  var fontSize = (fontStyle).split(' ')[1]||0;
                  return parseFloat(fontSize);
                },
                hCopy: function (oj){ //JSON objectのハードコピー(ついでに不正なJSONも排除)
                  return JSON.parse(JSON.stringify(oj));
                },
                /* xbcss.js for CrossBrowser CSS3
                 * http://socketapi.com/jsbu/20120206/croscss.htm
                 * Update: 2012/11/10
                 * Create: 2012/02/06
                 * version: 0.34
                 * Public domain
                 * Toshiro Takahashi @toshirot
                 * http://www.facebook.com/javascripting
                 */
                xbcss : {
                    enjoy: function(){
                        var arg = this.enjoy.arguments;
                        if(!this[arg[0].split('(')[0]])return;
                        var names = {
                          '-webkit-transform': document.body.style.webkitTransform,
                          'transform': document.body.style.transform,
                          '-moz-transform': document.body.style.MozTransform,
                          '-ms-transform': document.body.style.msTransform,
                          '-o-transform': document.body.style.OTransform
                        };
                        var csstext = '';
                        for(var i in names){
                          if(names[i]!==undefined){
                            csstext = i; break;
                          }
                        }
                        return csstext;
                    },
                    translate: function(tx, ty){
                        var arg = (ty)? (tx+','+ty) : (tx+', 0px');
                        return 'translate('+arg+') ';
                    },
                    translateX: function(tx){
                        return 'translateX('+tx+')'
                    },
                    translateY: function(tx){
                        return 'translateY('+tx+')'
                    },
                    scale: function(sx, sy){
                        var sy = (sy)? sy : sx;
                        return 'scale('+sx+','+sy+')'
                    },
                    scaleX: function(sx){
                        return 'scaleX('+sx+')'
                    },
                    scaleY: function(sy){
                        return 'scaleY('+sy+')'
                    },
                    skew: function(ax, ay){
                        var arg = (ay)? (ax+','+ay) : ax;
                        return 'skew('+arg+')'
                    },
                    skewX: function(ax){
                        return 'skewX('+ax+')'
                    },
                    skewY: function(ay){
                        return 'skewY('+ay+')'
                    },
                    matrix: function(a, b, c, d, tx, ty){
                        return 'matrix('+a+','+b+','+c+','+d+','+tx+','+ty+')'
                    },
                    matrix3d: function(
                            m00, m01, m02, m03,
                            m10, m11, m12, m13,
                            m20, m21, m22, m23,
                            m30, m31, m32, m33){
                            
                        return 'matrix3d('
                            +m00+','+m01+','+m02+','+m03+','
                            +m10+','+m11+','+m12+','+m13+','
                            +m20+','+m21+','+m22+','+m23+','
                            +m30+','+m31+','+m32+','+m33+')'
                    },
                    rotate: function(angle){
                        return 'rotate(' + angle + 'deg)'
                    }
                }
            }
    }
})(window);


window.ccchart.m.cssHybrid = 
(function(window) {
    return {
        aboutThis_module: {
            name: 'cssHybrid',
            varsion: '0.04',
                update: 20120610,
                lisence: 'Public Domain',
                demo: 'http://ccchart.com/',
                writer: 'Toshiro Takahashi @toshirot',
                see: 'http://www.facebook.com/javascripting',
                branched: ''
                       + 'This is module for ccchart(canvasChart) v0.919+'
                       + 'http://ccchart.com/'
        },
        useCssSetting: function(){
            if (this.useCss !== 'yes') return this;
            if (this.type === 'pie') return this;
            var id = this.id;
            var that = this;

            var style = getComputedStyle(this.canvas);
            var top = getNum('top');
            var left = getNum('left');
            var marginTop = getNum('margin-top');
            var marginLeft = getNum('margin-left');
            var paddingTop = getNum('padding-top');
            var paddingLeft = getNum('padding-left');
            var borderTopWidth = getNum('border-top-width');
            var borderLeftWidth = getNum('border-left-width');
            var currZindex = getNum('z-index');
            var position = style.position;
                
            var position = 
                    (position==='relative'||position==='static')?
                        'absolute':position;
                        
             this.maxZindex = 
                (this.maxZindex < currZindex)?
                     currZindex: this.maxZindex;
                     
            var operaTop = 
                (this.ua.match(/opera/) && position==='fixed')?(
                    getNum('top')
                    + Math.max(
                        getNum('margin'),
                        getNum('margin-top')
                    )
            ):0;//operafix
            
            var operaLeft = 
                (this.ua.match(/opera/) && position==='fixed')?(
                    getNum('left')
                    + Math.max(
                        getNum('margin'),
                        getNum('margin-left')
                    )
            ):0;//operafix
            
            this.ops[this.id]['adjustTop'] = 
                paddingTop + borderTopWidth + operaTop;
            this.ops[this.id]['adjustLeft'] = 
                paddingLeft + borderLeftWidth + operaLeft;
            
            //CSS要素用デフォルトスタイル用style要素生成
            var TMP_tooltip = ''
                + '{'
                + ';width:120px'
                + ';height:40px'
                + ';box-shadow: 6px 6px 6px rgba(000,000,000,0.6), inset 2px 2px 3px 3px rgba(180,180,180,0.2);'
                + ';border: 1px solid rgba(180,180,180,0.7)'
                + ';border-radius: 12px'
                + ';position: absolute'
                + ';top: -100px'
                + ';left: -1000px'
                + ';font-size: 10px'
                + ';line-height: 11px'
                + ';padding-top: 5px'
                + ';text-align: center'
                + ';text-shadow: 0px;'
                + '}';
            var TMP_tooltip_fukidashi = ''
                + '{'
                + ';content: " "'
                + ';position: absolute'
                + ';z-index: 2'
                + ';left: 20px'
                + ';top: 45px'
                + ';background: transparent'
                + ';border : 12px solid'
                + ';border-color: rgba(200,200,200,0.9) transparent transparent;'
                + '}';
            this.cssTooltip = this.op.cssTooltip || TMP_tooltip;
            this.cssTooltipFukidashi = this.op.cssTooltipFukidashi || TMP_tooltip_fukidashi;
            
            this.hybridCssEl = 
                document.querySelector('#-ccchart-css-styles');
            this.hybridCss = getHybridCss();//document.styleSheets['-ccchart-css-styles'];
            if(this.hybridCssEl=== null){
                this.hybridCssEl= document.createElement('style');
                this.hybridCssEl.setAttribute('id', '-ccchart-css-styles');
                this.hybridCssEl.setAttribute('title', '-ccchart-css-styles');

                var cssText = ''
                cssText+='.-ccchart-css-arc{background-color: rgba(0,0,0,0.5);}';
                cssText+='div.-ccchart-css-arc:hover{';
                cssText+='  box-shadow: 0px 0px 30px rgba(255,255,255,1);';
                cssText+='  background-color: rgba(255,255,255,0.5);';
                cssText+='}';
                cssText+='.line{border-top: 1px solid #000;}';
                cssText+='div.line:hover{';
                cssText+='  box-shadow: 0px 0px 30px rgba(255,255,255,1);';
                cssText+='  background-color: rgba(255,255,255,0.5);';
                cssText+='}';
                
                //tooltip
                cssText+='.-ccchart-css-tooltip ' + this.cssTooltip;
                cssText+='.-ccchart-css-tooltip:before ' + this.cssTooltipFukidashi;

                this.hybridCssEl.innerHTML=cssText;
                document.head.appendChild(this.hybridCssEl);

            } 
                
            //you will be set ccchart.hybridCss.insertRule( ".hoo { color: #888; }")
            // this.hybridCss = document.styleSheets['-ccchart-css-styles'];
            this.hybridCss = document.styleSheets[0];
                

            //ハイブリッドCSS要素のコンテナ生成
            this.hybridBox = 
                document.querySelector('#-ccchart-css-hybrid')
            if (this.hybridBox === null) {
                var hybridBox = document.createElement('div');
                hybridBox.setAttribute('id', '-ccchart-css-hybrid');
                this.hybridBox = document.body.appendChild(hybridBox);
            }
            //if(this.hybridBox.innerHTML!=='')this.hybridBox.innerHTML= '';//リセットこれはバグ?
            
            //css group用要素
            this.cssgs[id] = 
                document.querySelector('#-ccchart-css-group-' + id);
            if(!this.cssgs[id]){
                var cssGrp = document.createElement('div');
                cssGrp.setAttribute('class', '-ccchart-css-group');
                 //CSSコンテナへ追加
                this.cssgs[id] = this.hybridBox.appendChild(cssGrp);
                this.cssgs[id].setAttribute('id', '-ccchart-css-group-' + id);
            }
            var cssText = ''
            cssText += ';width:' + getCvsVal('width', this.width) + 'px';
            cssText += ';height:' + getCvsVal('height', this.height) + 'px';
            cssText += ';position:' + position;
            if (position === 'fixed') {
                var fixedZ = this.maxZindex + 2;
                cssText += ';z-index:' + ('' + fixedZ);
                this.canvas.style.zIndex = ('' + fixedZ);
            } else cssText += ';z-index:' + (this.maxZindex + 1);
                    
            //CSS適用
            this.cssgs[id].setAttribute('style',
                cssText+';background:transparent;border-color:transparent;'
            );
            //this.hybridBox.addEventListener('DOMNodeInserted',function(e,f){addToolTip(that);})
            if(this.useCssToolTip==='yes'){
                addToolTip(this);
            }

            return this;

            function addToolTip(that){
                var id = that.id
                //css tooltip用要素
                
                that.cssTooltips[id] = document.querySelector('#-ccchart-css-tooltip-' + id);
                if(!that.cssTooltips[id]){
                    var csstooltip = document.createElement('div');
                    csstooltip.setAttribute('class', '-ccchart-css-tooltip');
                    csstooltip.setAttribute('id', '-ccchart-css-tooltip-' + id);
                    var cssText = ''
                    cssText += ';z-index:' + (that.maxZindex + 1);
                    
                    //CSSコンテナへ追加
                    //setTimeoutかませないと出力されない
                    setTimeout(function(){
                        that.cssTooltips[id] =
                            that.cssgs[id].appendChild(csstooltip);
                            
                        that.util.setBG(
                            document.querySelectorAll('#-ccchart-css-tooltip-' + id)
                            ,'rgba(200,200,200,0.6)'
                            ,'rgba(255,255,255,0.6)'
                            , 'top'
                        );
                    },0)
                }
            }
            
            function getHybridCss(){
                var sheet = null;
                for(var i=0;i<document.styleSheets.length;i++){
                    if(document.styleSheets[i].title==='-ccchart-css-styles')
                        sheet = document.styleSheets[i]; break;
                }
                return sheet
            }

            function getCvsVal(prop,defaultVal){
                return  that.canvas.style[prop]||
                        that.canvas.getAttribute(prop)||defaultVal;
            }
            function getComputedStyle(elm){
                return elm.currentStyle || 
                    document.defaultView.getComputedStyle(elm, '');
            }
            function getNum(prop){
                return parseFloat(
                  document
                    .defaultView
                    .getComputedStyle(that.canvas, '')
                    .getPropertyValue(prop), 10
               )||0;
            }
            
        },
        adjustCss: function (type){
            var that = this;
            for(var i in this.ops){
                if(this.ops[i].useCss !== 'yes')continue;
                var el =document.getElementById(i);
                var level = 0;
                getPos(el, level, 5, 0, 0,
                   function(numAry){
                     var topOff =  that.ops[i]['adjustTop'] 
                     var leftOff = that.ops[i]['adjustLeft']
                     var top = topOff + numAry[0]||0;
                     var left = leftOff + numAry[1]||0;
                     document.getElementById("-ccchart-css-group-"+i).style.top = top+'px';
                     document.getElementById("-ccchart-css-group-"+i).style.left = left + 'px';
                   });
            }
            //Dom Treeを遡上してposを調整する
            function getPos(el, level, deep, numT, numL, fn){
              if(el.nodeName.toUpperCase === 'BODY')return;
              if(!deep)var deep = 5;
              var css = getComputedStyle(el);
              if(css){
                  if(( (level===0 && css['position']==='fixed') ||
                       (level===0 && css['position']==='static') ||
                        css['position']==='relative' ||
                        css['position']==='absolute' )
                    ){
                    numT += el['offsetTop'];
                    numL += el['offsetLeft'];
                  } else {
                  }
                  
                  if(el.parentNode.nodeName.toUpperCase() === 'BODY'){ 
                    if(fn)fn([numT,numL]);
                  } else {
                    getPos(el.parentNode, ++level, deep, numT, numL, fn);
                  }
                  delete css;
              }
              
            }
        },
        _css_arc: function(op){
            var that = this;
            var id = this.id;
            if(!op)var op = this.op||{};
            var x = op.x || 0;
            var y = op.y || 0;
            var radius = op.radius || 5;
            var borderWidth = this.borderWidth || 3;
            var borderColor = op.borderColor || op.colorSet || this.colorSet;
            var colorIndex = ((this.type==='scatter')?op.colorIndex:op.row)||0;
            var bgcolor = op.bgColor || this.colorSet[colorIndex] || this.colorSet[colorIndex];
            var etc = (op.etcStyle?op.etcStyle:'');
            var el = document.createElement('div');
            if(borderWidth > radius)radius = borderWidth;//ringのborder幅が半径を超えたら半径を拡大
            
            var dataX = (this.type==='scatter')?(this.rowNames[0]):this.colNames[op.col];
            var dataY = (this.type==='scatter')?(this.rowNames[1]):this.rowNames[op.row];

            
            //マーカーの属性をセット
            el.setAttribute('class','-ccchart-css-arc ' + op.classStr);
            el.setAttribute('data-row',op.row);//scatterでは常に0
            el.setAttribute('data-col',op.col);
            el.setAttribute('data-colnametitle',this.colNames[op.col]);
            el.setAttribute('data-y', dataY);
            el.setAttribute('data-x',dataX);
            el.setAttribute('data-scatter-y', op.scatterY);
            el.setAttribute('data-scatter-x',op.scatterX);
            el.setAttribute('data-data',op.data);
            el.setAttribute('data-bg',bgcolor);
            var xyr = ''
                    + 'position: absolute;'
                    + 'left:'+( x - radius )+'px;'
                    + 'top:'+( y - radius )+'px;'
                    + 'width:'+radius*2+'px;'
                    + 'height:'+radius*2+'px;'
                    + 'border-radius:'+radius*2+'px;'
                    + ((op.classStr==='css-maru')?('background: ' + bgcolor + ';'):'')
                    + ((op.classStr==='css-ring')?('border:'+borderWidth+'px solid ' + borderColor + ';'):'')
                    + 'box-sizing: border-box;'
                    +  this.pfx['transform-origin'] +': 0px 0px;'
                    +  this.pfx['box-sizing'] +': border-box;'
                    +  this.pfx['transition'] +': background-color 200ms linear';
            el.setAttribute('style', xyr+etc);
            
            //マーカーをグループへ登録
            var arc = this.cssgs[id].appendChild(el);

            function showTooltip(id,e){
                that.csstoolRock = true;
                var rowNum = e.target.getAttribute('data-row');
                var rowName = e.target.getAttribute('data-y');
                var colName = e.target.getAttribute('data-x');
                var scatterXData = e.target.getAttribute('data-scatter-x');
                var scatterYData = e.target.getAttribute('data-scatter-y');
                var colnametitle = e.target.getAttribute('data-colnametitle');
                var data = e.target.getAttribute('data-data');
                var bgcolor = e.target.getAttribute('data-bg');
                var colNameTitle = (that.type==='scatter')?
                           colnametitle:((that.colNamesTitle)?that.colNamesTitle:'');
                //if(!that.cssTooltips[id])return;
                that.cssTooltips[id].style.left = ( x - radius -20)+'px';
                that.cssTooltips[id].style.top = ( y - radius - 70 )+'px';
                //.-ccchart-ttip-dataでCSSから指定可能です
                if(that.type==='scatter'){
                  var htm = ''
                    + '<span class="-ccchart-ttip-sct-colnametitle">'+colNameTitle + '</span>'+ '<br>' 
                    + '<span class="-ccchart-ttip-sct-colname">'+colName + '</span>' + ' '
                    + '<span class="-ccchart-ttip-sct-data-x">'+scatterXData + '</span>'+'<br>' 
                    + '<span class="-ccchart-ttip-sct-rowname">'+rowName + '</span>' + ' '
                    + '<span class="-ccchart-ttip-sct-data-y">'+scatterYData + '</span>'+ '<br>' 
                } else {
                  var htm = ''
                    + '<span class="-ccchart-ttip-colnametitle">'+colNameTitle + '</span>' + ' '
                    + '<span class="-ccchart-ttip-colname">'+colName  + '</span>'+'<br>' 
                    + '<span class="-ccchart-ttip-rowname">'+rowName + '</span>'+ '<br>' 
                    + '<span class="-ccchart-ttip-data">' + data + '</span>'+ (that.unit||'')
                }
                that.cssTooltips[id].innerHTML = htm;

                //同じセレクタのルールがあったら一旦除去して::before部分の吹き出しの色を設定
                that.deleteCssRule('#-ccchart-css-tooltip-'+id+'::before');
                that.hybridCss.insertRule(
                    '#-ccchart-css-tooltip-'+id+':before{'
                    +' border-color:'
                    + bgcolor
                    +' transparent transparent;'
                    +'}',
                    that.hybridCss.cssRules.length
                );

                clearTimeout(this._ttId);
                this._ttId = setTimeout(function(){
                    that.csstoolRock = false;//ロック解除1秒延命で2)では消えなくなる
                },1500);
            }
            function hideTooltip(id){
                if(!that.csstoolRock && that.cssTooltips[id]){
                    that.cssTooltips[id].style.left = -1000 +'px';
                    that.cssTooltips[id].style.top = -1000 +'px';
                    that.cssTooltips[id].innerHTML = '';
                }
            }

            //ツールチップ
            if(this.useCssToolTip==='yes'){
              
                //Cross Event type
                var mbl = this.util.isMobile();
                var over = (mbl)?'touchstart':'mouseover';
                var out = (mbl)?'touchend':'mouseout';

                //触った時のイベント登録 1)触ったら現れ、離れるまで消えない
                arc.addEventListener(over, function(e){ showTooltip(id,e) } );
                
                //離れた時のイベント登録 2)1秒後に消える
                arc.addEventListener(out,  function(){
                    setTimeout(function(){
                        if(!that.csstoolRock)hideTooltip(id);
                    },1000);
                });
                
                //トグルなロック登録 ダブルクリックで消えなくなる 再ダブルクリックで解除
                arc.addEventListener('dblclick',  function(){
                    if(that.csstoolRock)that.csstoolRock = false;
                    else that.csstoolRock = true
                });
                

            }

            //CSS位置調整
            if(
                (this.dataRowLen-1)===op.row &&
                (this.dataColLen-1)===op.col
            )this.adjustCss();

            return el;
        },
        css_ring: function(op){
            op.classStr = 'css-ring';
          //  op.bgColor = op.bgColor || 'rgba(0,0,0,0.5)';
            if(this.type!=='scatter')op.borderColor = op.borderColor || this.colorSet[op.row];
            this._css_arc(op);
        },
        css_maru: function(op){
            op.classStr = 'css-maru';
            if(this.type!=='scatter')op.bgColor = op.bgColor || this.colorSet[op.row];
            this._css_arc(op);
        },
        css_lineTo:  function(op){
            op.classStr = 'css_lineTo';
            op.bgColor = op.bgColor || this.colorSet[op.row];
          //  this._css_arc(op);
        },
        deleteCssRule: function(selectorText){
            for(var i=0; i<this.hybridCss.cssRules.length;i++){
                if(this.hybridCss.cssRules[i].selectorText===selectorText){
                    this.hybridCss.deleteRule(i)
                }
            }
        } 
    }

})(window);
