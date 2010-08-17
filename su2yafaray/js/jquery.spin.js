/**
 * 
 jQuery Spin for UI su2slg (Sketchup Exporter for SmallLuxGPU)
 
 * Initialy based on jQuery Spin 1.1.1 by Naohiko MORI
 * Copyright (c) 2010 Alexander Smirnov (aka Exvion) e-mail: exvion@gmail.com  http://exvion.ru
 * Dual licensed under the MIT and GPL licenses.
*/


(function($){
  var calcFloat = {
    get: function(num){
      var num = num.toString();
      if(num.indexOf('.')==-1) return[0, eval(num)];
      var nn = num.split('.');
      var po = nn[1].length;
      var st = nn.join('');
      var sign = '';
      if(st.charAt(0)=='-'){
        st = st.substr(1);
        sign = '-';
      }
      for(var i=0; i<st.length; ++i) if(st.charAt(0)=='0') st=st.substr(1, st.length);
      st = sign + st;
      return [po, eval(st)];
    },
    getInt: function(num, figure){
      var d = Math.pow(10, figure);
      var n = this.get(num);
      var v1 = eval('num * d');
      var v2 = eval('n[1] * d');
      if(this.get(v1)[1]==v2) return v1;
      return(n[0]==0 ? v1 : eval(v2 + '/Math.pow(10, n[0])'));
    },
    sum: function(v1, v2){
      var n1 = this.get(v1);
      var n2 = this.get(v2);
      var figure = (n1[0] > n2[0] ? n1[0] : n2[0]);
      v1 = this.getInt(v1, figure);
      v2 = this.getInt(v2, figure);
      return eval('v1 + v2')/Math.pow(10, figure);
    }
  };
  $.extend({
    spin: {
      imageBasePath: 'img/spin/',
      spinBtnImage: 'right_plus.png',
	  spinRightImage: 'right_plus.png',
	  inputRightImage: 'right.png',
	  spinLeftImage: 'left_minus.png',
	  inputLeftImage: 'left.png',
      spinUpImage: 'spin-up.png',
      spinDownImage: 'spin-down.png',
      interval: 1,
      max: null,
      min: null,
      timeInterval: 300,
      timeBlink: 300,
      btnClass: null,
      btnCss: {cursor: 'pointer', padding: 0, margin: 0, verticalAlign: 'middle', float:'left'},
      btnLeftCss: {cursor: 'pointer', padding: 0, margin: '0 0 0 -100%',width:'14px', verticalAlign: 'middle', float:'left'},
      btnRightCss: {cursor: 'pointer', padding: 0, margin: '0 0 0 -13px',width:'13px', verticalAlign: 'middle', float:'left'},
      txtCss: {marginRight: 0, padding: '3px 0px 1px 0px',float:'left', display:'block', border:'none', width:'100%', background: 'url("img/spin/fill_input.png") 0 0 repeat-x' },
	  ppCss: {marginRight: 0, padding: '6px 0px 3px 0px', border:'none',float:'left',display:'block', textAlign: 'center', width:'100%',background: 'url("img/spin/fill_input.png") 0 0 repeat-x'},
      lock: false,
      decimal: null,
      beforeChange: null,
      changed: null,
      buttonUp: null,
      buttonDown: null
    }
  });
  $.fn.extend({
    spin: function(o){
      return this.each(function(){
				o = o || {};
				var opt = {};
				$.each($.spin, function(k,v){
					opt[k] = (typeof o[k]!='undefined' ? o[k] : v);
				});
        
        var txt = $(this);
        
		var lbl=txt.prev('label');
		//lbl.hide();
		//var txt_label=lbl.text();
		//var txt_val=txt.val();
		
		
		
		//txt_val=txt_label+txt_val;
		//alert(txt_val);
		//txt_val.replace(txt_label,'');
		
		//txt.val(txt_val);
		//alert(txt.prev('label').text());
		
        var spinBtnImage = opt.imageBasePath+opt.spinBtnImage;
        var btnSpin = new Image();
        btnSpin.src = spinBtnImage;
        
		var spinUpImage = opt.imageBasePath+opt.spinUpImage;
        var btnSpinUp = new Image();
        btnSpinUp.src = spinUpImage;
        
		var spinLeftImage = opt.imageBasePath+opt.spinLeftImage;
        var btnSpinLeft = new Image();
        btnSpinLeft.src = spinLeftImage;
        
		var spinRightImage = opt.imageBasePath+opt.spinRightImage;
        var btnSpinRight = new Image();
        btnSpinRight.src = spinRightImage;
        
		
		var spinDownImage = opt.imageBasePath+opt.spinDownImage;
        var btnSpinDown = new Image();
        btnSpinDown.src = spinDownImage;
        
		var div_spinner=$(document.createElement('div'));
		div_spinner.addClass('spinner');
		//div_spinner.attr('id',txt.attr('id'));
		
		var pp=$(document.createElement('div'));
		pp.attr('title',lbl.attr('title'));
		pp.addClass('spin');
		pp.css(opt.ppCss);
		//alert(lbl.text()+txt.val());
		pp.text(lbl.text()+txt.val());
		
		
		var btnRight = $(document.createElement('img'));
        btnRight.attr('src', spinBtnImage);
        if(opt.btnClass) btnRight.addClass(opt.btnClass);
        if(opt.btnRightCss) btnRight.css(opt.btnRightCss);
        if(opt.txtCss) txt.css(opt.txtCss);
       
		if(opt.lock){
					txt.focus(function(){txt.blur();});
        }
        var btnLeft = $(document.createElement('img'));
        btnLeft.attr('src', spinLeftImage);
        if(opt.btnClass) btnLeft.addClass(opt.btnClass);
        if(opt.btnLeftCss) btnLeft.css(opt.btnLeftCss);
        if(opt.txtCss) txt.css(opt.txtCss);
        
		if(opt.lock){
					txt.focus(function(){txt.blur();});
        }
		
		
		
		
		txt.after(div_spinner);
		div_spinner.append(txt);
		div_spinner.append(pp);
		div_spinner.append(btnRight);
		div_spinner.append(btnLeft);
        
		

		//lbl.replaceWith("<div>"+lbl.text()+txt.val()+"</div>");
		//lbl.css(opt.txtCss);
		lbl.hide();
		txt.hide();
		
		
        function spin(vector){
          var val = txt.val();
          var org_val = val;
          if(opt.decimal) val=val.replace(opt.decimal, '.');
          if(!isNaN(val)){
            val = calcFloat.sum(val, vector * opt.interval);
            if(opt.min!==null && val<opt.min) val=opt.min;
            if(opt.max!==null && val>opt.max) val=opt.max;
            if(val != txt.val()){
              if(opt.decimal) val=val.toString().replace('.', opt.decimal);
              var ret = ($.isFunction(opt.beforeChange) ? opt.beforeChange.apply(txt, [val, org_val]) : true);
              if(ret!==false){
                txt.val(val);
                if($.isFunction(opt.changed)) opt.changed.apply(txt, [val]);
                txt.change();
                src = (vector > 0 ? spinUpImage : spinDownImage);
               // btn.attr('src', src);
               // if(opt.timeBlink<opt.timeInterval)
                //  setTimeout(function(){btn.attr('src', spinBtnImage);}, opt.timeBlink);
              }
            }
          }
          if(vector > 0){
            if($.isFunction(opt.buttonUp)) opt.buttonUp.apply(txt, [val]);
          }else{
            if($.isFunction(opt.buttonDown)) opt.buttonDown.apply(txt, [val]);
          }
		  pp.text(lbl.text()+txt.val());
        }
        
		pp.click(function(){
			pp.hide();
			btnRight.attr('src','img/spin/right.png');
			btnLeft.attr('src','img/spin/left.png');
			txt.show();
			txt.select();
		//alert("double click");
		//hide label; change background color, change color cursor, change left and right image; after потеря фокуса, 
		});
		
		if ($.browser.mozilla) {
			txt.keypress (checkKey);
		} else {
			txt.keydown (checkKey);
		}

		function checkKey(e){
		if (event.keyCode == 13) {
			txt.blur();
		} 
		}
		
		txt.change(function(){
			pp.text(lbl.text()+txt.val());
		});
		
		txt.blur(function(){
		txt.hide();
		btnLeft.attr('src','img/spin/left_minus.png');
		btnRight.attr('src','img/spin/right_plus.png');
		pp.show();
		pp.text(lbl.text()+txt.val());
		});
		
		btnRight.mousedown(function(e){
          var pos = e.pageY - btnRight.offset().top;
		  //alert(pos);
          //var vector = (btn.height()/2 > pos ? 1 : -1);
		  var vector= 1;
          (function(){
            spin(vector);
            var tk = setTimeout(arguments.callee, opt.timeInterval);
            $(document).one('mouseup', function(){
              clearTimeout(tk); btnRight.attr('src', spinBtnImage);
            });
          })();
          return false;
        });
		
		
        btnLeft.mousedown(function(e){
          var pos = e.pageY - btnLeft.offset().top;
		  //alert(pos);
          //var vector = (btnLeft.height()/2 > pos ? 1 : -1);
		  var vector= -1;
          (function(){
            spin(vector);
            var tk = setTimeout(arguments.callee, opt.timeInterval);
            $(document).one('mouseup', function(){
              clearTimeout(tk); btnLeft.attr('src', spinLeftImage);
            });
          })();
          return false;
        });
      });
    }
  });
})(jQuery);
