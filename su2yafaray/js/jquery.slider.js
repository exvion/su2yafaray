/**
 * 
 * jQuery Blender slider
 *
 * Copyright (c) 2010 Alexander Smirnov (aka Exvion) e-mail: exvion@gmail.com  http://exvion.ru
 * Licensed under GPL license.
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
    slider: {
		imageBasePath: 'img/slider/',
		sliderLeftImage: 'slider_left.png',
		sliderRightImage: 'slider_right.png',
		sliderLeftClickImage: 'slider_left_click.png',
		sliderRightClickImage: 'slider_right_click.png',
		//inputRightImage: 'right.png',
		//spinLeftImage: 'left_minus.png',
		//inputLeftImage: 'left.png',
		//spinUpImage: 'spin-up.png',
		//spinDownImage: 'spin-down.png',
		//btnCss: {cursor: 'pointer', padding: 0, margin: 0, verticalAlign: 'middle', float:'left'},
		sliderLeftCss: {cursor: 'pointer', padding: 0, margin: '0 0 0 -100%',width:'10px', verticalAlign: 'middle', float:'left'},
		sliderRightCss: {cursor: 'pointer', padding: 0, margin: '0 0 0 -8px',width:'8px', verticalAlign: 'middle', float:'left'},
		txtCss: {marginRight: 0, padding: '1px 0px 1px 0px',float:'left', display:'block', border:'none', width:'100%',background: 'url("img/slider/slider_fill.png") 0 0 repeat-x' },
		//ppCss: {marginRight: 0, padding: '6px 0px 3px 0px', border:'none',float:'left',display:'block', textAlign: 'center', width:'100%',background: 'url("img/spin/fill_input.png") 0 0 repeat-x'},
		decimal: null,
		interval: 1,
		max: null,
		min: null
    }
  });
  $.fn.extend({
    slider: function(o){
      return this.each(function(){
				o = o || {};
				var opt = {};
				$.each($.slider, function(k,v){
					opt[k] = (typeof o[k]!='undefined' ? o[k] : v);
				});
        
        var txt = $(this);
		var lbl=txt.prev('label');
		var txt_label=lbl.text();

		
		
		var sliderLeftImagePath=opt.imageBasePath+opt.sliderLeftImage;
		var sliderLeftClickImagePath=opt.imageBasePath+opt.sliderLeftClickImage;
		var sliderLeft = $(document.createElement('img'));
        sliderLeft.attr('src', sliderLeftImagePath);
		if (opt.sliderLeftCss) sliderLeft.css(opt.sliderLeftCss);
		
		
		var sliderRightImagePath=opt.imageBasePath+opt.sliderRightImage;
		var sliderRightClickImagePath=opt.imageBasePath+opt.sliderRightClickImage;

		var sliderRight = $(document.createElement('img'));
        sliderRight.attr('src', sliderRightImagePath);
		if (opt.sliderRightCss) sliderRight.css(opt.sliderRightCss);

		
		var div_indicator=$(document.createElement('div'));
		div_indicator.addClass('indicator');
		var div_counter=$(document.createElement('div'));
		div_counter.attr('title',lbl.attr('title'));
		div_counter.attr('unselectable','on');
		div_counter.text(lbl.text()+txt.val());
		div_counter.addClass('counter');
		
		var div_slider=$(document.createElement('div'));
		div_slider.addClass('slider');
		//div_slider.attr('id',txt.attr('id'));
		var div_contentwrapper=$(document.createElement('div'));
		div_contentwrapper.addClass('contentwrapper');
		
		var div_contentcolumn=$(document.createElement('div'));
		div_contentcolumn.addClass('contentcolumn');
		
		if(opt.txtCss) txt.css(opt.txtCss);
		
		txt.after(div_slider);
		//txt.remove();
		div_slider.append(div_contentwrapper);
		div_contentwrapper.append(div_contentcolumn);
		div_contentcolumn.append(txt);
		div_contentcolumn.append(div_indicator);
		div_contentcolumn.append(div_counter);
		div_slider.append(sliderRight);
		div_slider.append(sliderLeft);

		div_counter.attr('title',lbl.attr('title'));

		 lbl.hide();
		 txt.hide();
		
		 txt.change(function(){
			var widthIndicator=((txt.val()-opt.min)*100)/(opt.max-opt.min);
			div_counter.text(lbl.text()+txt.val());
			div_indicator.width(widthIndicator+'%');
			//changeTxt();	
			// var txt_val=parseFloat(txt.val());
			// if(opt.min!==null && txt_val<opt.min) txt_val=opt.min;
			// if(opt.max!==null && txt_val>opt.max) txt_val=opt.max;
			// var widthIndicator=((txt_val-opt.min)*100)/(opt.max-opt.min);
			// //alert(widthIndicator);
			// div_counter.show();
			// div_indicator.show();
			
			// div_indicator.width(widthIndicator+'%');
			// div_counter.text(lbl.text()+txt_val);
		  });
		
		
		function round(n,s)
		{ s=1/s;
			//return (n*s).toFixed(0)/s
			return Math.floor(n*s).toFixed(0)/s;
		}

		
		function slide(pos) {
		  //var val;
          
		  var vector=round((pos*(opt.max-opt.min))/(div_contentcolumn.width()),opt.interval);
		  //if(opt.decimal) current_val=current_val.replace(opt.decimal, '.');
          if (!isNaN(current_val)){
             val = calcFloat.sum(current_val, vector);
            // val = calcFloat.sum(val, new_value);
            if(opt.min!==null && val<opt.min) val=opt.min;
            if(opt.max!==null && val>opt.max) val=opt.max;
            if(val != txt.val()){
               //alert(val);
			   if(opt.decimal) val=val.toString().replace('.', opt.decimal);
               //var ret = ($.isFunction(opt.beforeChange) ? opt.beforeChange.apply(txt, [val, org_val]) : true);
               //if(ret!==false){
                 //txt.val(val);
                 //if($.isFunction(opt.changed)) opt.changed.apply(txt, [val]);
                 //changeTxt();
				if(opt.min!==null && val<opt.min) val=opt.min;
				if(opt.max!==null && val>opt.max) val=opt.max;
				//div_counter.show();
				//div_indicator.show();
				//alert(val);
				var widthIndicator=((val-opt.min)*100)/(opt.max-opt.min);
				div_indicator.width(widthIndicator+'%');
				div_counter.text(lbl.text()+val); 
				 
                
               //}
             }
           } else {
			div_counter.text(lbl.text()+current_val);
		   }
		  //div_counter.text(lbl.text()+txt.val());
		}
		
		var clicking = false;
		var startX;
		var current_val;
		var val;
		//var diapozon=opt.max-opt.min;
		div_slider.mousemove(function(e){
			if(clicking == false) return;
			pos=e.pageX-startX;
			slide(pos);

		});
		var pos;
		
		div_slider.mouseup(function(){
			div_contentwrapper.removeClass('contentwrapper_click');
			div_contentwrapper.addClass('contentwrapper');
			div_indicator.removeClass('indicator_click');
			div_indicator.addClass('indicator');
			sliderLeft.attr('src', sliderLeftImagePath);
			sliderRight.attr('src', sliderRightImagePath);
			clicking = false;
			txt.val(val);
			txt.change();
			// if (pos==0) {
				// div_counter.hide();
				// div_indicator.hide();
				// txt.show();
				// txt.select();
			// }
		}).mousedown(function(e) {
			div_contentwrapper.removeClass('contentwrapper');
			div_contentwrapper.addClass('contentwrapper_click');
			div_indicator.removeClass('indicator');
			div_indicator.addClass('indicator_click');
			sliderLeft.attr('src', sliderLeftClickImagePath);
			sliderRight.attr('src', sliderRightClickImagePath);
			clicking = true;
			current_val= txt.val();
			pos=0;
			startX=e.pageX;
			//var txtValue=txt.val();
			//handleMouseDown(event, this);

				
			//var startX=e.pageX;
			//alert(div_indicator.width());
			//alert(startX);
			// var startX=e.pageX;
			// var vector=-1;
			// $(document).one('mousemove', function(e) {
				// var tk = setTimeout(arguments.callee, 1000);
				// var pos=e.pageX-startX;
				// startX=e.pageX;
				// //alert(pos);
				// slide(pos);		
			// });
			
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

		function changeTxt() {
			var txt_val=parseFloat(txt.val());
			if(opt.min!==null && txt_val<opt.min) txt_val=opt.min;
			if(opt.max!==null && txt_val>opt.max) txt_val=opt.max;
			div_counter.show();
			div_indicator.show();
			var widthIndicator=((txt_val-opt.min)*100)/(opt.max-opt.min);
			div_indicator.width(widthIndicator+'%');
			div_counter.text(lbl.text()+txt_val);
			//txt.change();
			
		}
		
		txt.blur(function(){
			txt.hide();
			//alert('txt.blur');
			//pp.show();
			changeTxt();
			//txt.change();
		});
		
      });
    }
  });
})(jQuery);
