/**
 * 
 * jQuery Blender slider
 *
 * Copyright (c) 2010 Alexander Smirnov (aka Exvion) e-mail: exvion@gmail.com  http://exvion.ru
 * Licensed under GPL license.
*/


(function($){
  $.extend({
    colorpicker: {
		imageBasePath: 'img/colorpicker2/',
		colorPickerLeftImage: 'colorpicker_left.png',
		colorPickerRightImage: 'colorpicker_right.png',
		//sliderLeftClickImage: 'slider_left_click.png',
		//sliderRightClickImage: 'slider_right_click.png',
		//inputRightImage: 'right.png',
		//spinLeftImage: 'left_minus.png',
		//inputLeftImage: 'left.png',
		//spinUpImage: 'spin-up.png',
		//spinDownImage: 'spin-down.png',
		//btnCss: {cursor: 'pointer', padding: 0, margin: 0, verticalAlign: 'middle', float:'left'},
		//colorPickerLeftCss: {cursor: 'pointer', padding: '0px', margin: '0pt 0pt 0pt -100%', width: '5px', vertical-align: 'middle', float: 'left'},
		colorPickerLeftCss: {cursor: 'pointer', padding: '0px', margin: '0pt 0pt 0pt -100%', width: '5px', float: 'left'},
		colorPickerRightCss: {cursor: 'pointer', padding: '0px', margin: '0pt 0pt 0pt -4px', width: '4px', float: 'left'},
		txtCss: {marginRight: 0, padding: '1px 0px 1px 0px',float:'left', display:'block', border:'none', width:'100%',background: 'url("img/slider/slider_fill.png") 0 0 repeat-x' },
		//ppCss: {marginRight: 0, padding: '6px 0px 3px 0px', border:'none',float:'left',display:'block', textAlign: 'center', width:'100%',background: 'url("img/spin/fill_input.png") 0 0 repeat-x'},
		decimal: null,
		interval: 1,
		max: null,
		min: null
    }
  });
  $.fn.extend({
    colorpicker: function(o){
      return this.each(function(){
				o = o || {};
				var opt = {};
				$.each($.colorpicker, function(k,v){
					opt[k] = (typeof o[k]!='undefined' ? o[k] : v);
				});
        
			var txt = $(this);
			var lbl=txt.prev('label');
			var div_colorpicker_label=$(document.createElement('div'));
			div_colorpicker_label.addClass('colorpicker-label');
			div_colorpicker_label.text(lbl.text());
			
			var div_colorpicker=$(document.createElement('div'));
			div_colorpicker.addClass('colorpicker');
			
			var div_colorpicker_fill=$(document.createElement('div'));
			div_colorpicker_fill.addClass('colorpicker-fill');
			
			
		
		
			var colorPickerLeftImagePath=opt.imageBasePath+opt.colorPickerLeftImage;
			var colorPickerLeftClickImagePath=opt.imageBasePath+opt.colorPickerLeftClickImage;
			var colorPickerLeft = $(document.createElement('img'));
			colorPickerLeft.attr('src', colorPickerLeftImagePath);
			if (opt.colorPickerLeftCss) colorPickerLeft.css(opt.colorPickerLeftCss);
		
		
			var colorPickerRightImagePath=opt.imageBasePath+opt.colorPickerRightImage;
			var colorPickerRightClickImagePath=opt.imageBasePath+opt.colorPickerRightClickImage;
			var colorPickerRight = $(document.createElement('img'));
			colorPickerRight.attr('src', colorPickerRightImagePath);
			if (opt.colorPickerRightCss) colorPickerRight.css(opt.colorPickerRightCss);
			
			var div_clear=$(document.createElement('div'));
			div_clear.addClass('clear');
			txt.after(div_colorpicker_label);
			div_colorpicker_label.after(div_colorpicker);
			div_colorpicker.append(div_colorpicker_fill);
			div_colorpicker.append(colorPickerRight);
			div_colorpicker.append(colorPickerLeft);
			div_colorpicker.after(div_clear);
		// div_slider.append(sliderLeft);
		// var div_indicator=$(document.createElement('div'));
		// div_indicator.addClass('indicator');
		// var div_counter=$(document.createElement('div'));
		// div_counter.attr('title',lbl.attr('title'));
		// div_counter.attr('unselectable','on');
		// div_counter.text(lbl.text()+txt.val());
		// div_counter.addClass('counter');
		
		// var div_slider=$(document.createElement('div'));
		// div_slider.addClass('slider');
		// //div_slider.attr('id',txt.attr('id'));
		// var div_contentwrapper=$(document.createElement('div'));
		// div_contentwrapper.addClass('contentwrapper');
		
		// var div_contentcolumn=$(document.createElement('div'));
		// div_contentcolumn.addClass('contentcolumn');
		
		// if(opt.txtCss) txt.css(opt.txtCss);
		
		// txt.after(div_slider);
		// //txt.remove();
		// div_slider.append(div_contentwrapper);
		// div_contentwrapper.append(div_contentcolumn);
		// div_contentcolumn.append(txt);
		// div_contentcolumn.append(div_indicator);
		// div_contentcolumn.append(div_counter);
		// div_slider.append(sliderRight);
		// div_slider.append(sliderLeft);

		// div_counter.attr('title',lbl.attr('title'));

		lbl.hide();
		txt.hide();
		
		 // txt.change(function(){
			// var widthIndicator=((txt.val()-opt.min)*100)/(opt.max-opt.min);
			// div_counter.text(lbl.text()+txt.val());
			// div_indicator.width(widthIndicator+'%');
			// //changeTxt();	
			// // var txt_val=parseFloat(txt.val());
			// // if(opt.min!==null && txt_val<opt.min) txt_val=opt.min;
			// // if(opt.max!==null && txt_val>opt.max) txt_val=opt.max;
			// // var widthIndicator=((txt_val-opt.min)*100)/(opt.max-opt.min);
			// // //alert(widthIndicator);
			// // div_counter.show();
			// // div_indicator.show();
			
			// // div_indicator.width(widthIndicator+'%');
			// // div_counter.text(lbl.text()+txt_val);
		  // });
		
		
		// function round(n,s)
		// { s=1/s;
			// //return (n*s).toFixed(0)/s
			// return Math.floor(n*s).toFixed(0)/s;
		// }

		
		// function slide(pos) {
		  // //var val;
          
		  // var vector=round((pos*(opt.max-opt.min))/(div_contentcolumn.width()),opt.interval);
		  // //if(opt.decimal) current_val=current_val.replace(opt.decimal, '.');
          // if (!isNaN(current_val)){
             // val = calcFloat.sum(current_val, vector);
            // // val = calcFloat.sum(val, new_value);
            // if(opt.min!==null && val<opt.min) val=opt.min;
            // if(opt.max!==null && val>opt.max) val=opt.max;
            // if(val != txt.val()){
               // //alert(val);
			   // if(opt.decimal) val=val.toString().replace('.', opt.decimal);
               // //var ret = ($.isFunction(opt.beforeChange) ? opt.beforeChange.apply(txt, [val, org_val]) : true);
               // //if(ret!==false){
                 // //txt.val(val);
                 // //if($.isFunction(opt.changed)) opt.changed.apply(txt, [val]);
                 // //changeTxt();
				// if(opt.min!==null && val<opt.min) val=opt.min;
				// if(opt.max!==null && val>opt.max) val=opt.max;
				// //div_counter.show();
				// //div_indicator.show();
				// //alert(val);
				// var widthIndicator=((val-opt.min)*100)/(opt.max-opt.min);
				// div_indicator.width(widthIndicator+'%');
				// div_counter.text(lbl.text()+val); 
				 
                
               // //}
             // }
           // } else {
			// div_counter.text(lbl.text()+current_val);
		   // }
		  // //div_counter.text(lbl.text()+txt.val());
		// }
		
		// var clicking = false;
		// var startX;
		// var current_val;
		// var val;
		// //var diapozon=opt.max-opt.min;
		// div_slider.mousemove(function(e){
			// if(clicking == false) return;
			// pos=e.pageX-startX;
			// slide(pos);

		// });
		// var pos;
		
		// div_slider.mouseup(function(){
			// div_contentwrapper.removeClass('contentwrapper_click');
			// div_contentwrapper.addClass('contentwrapper');
			// div_indicator.removeClass('indicator_click');
			// div_indicator.addClass('indicator');
			// sliderLeft.attr('src', sliderLeftImagePath);
			// sliderRight.attr('src', sliderRightImagePath);
			// clicking = false;
			// txt.val(val);
			// txt.change();
			// // if (pos==0) {
				// // div_counter.hide();
				// // div_indicator.hide();
				// // txt.show();
				// // txt.select();
			// // }
		// }).mousedown(function(e) {
			// div_contentwrapper.removeClass('contentwrapper');
			// div_contentwrapper.addClass('contentwrapper_click');
			// div_indicator.removeClass('indicator');
			// div_indicator.addClass('indicator_click');
			// sliderLeft.attr('src', sliderLeftClickImagePath);
			// sliderRight.attr('src', sliderRightClickImagePath);
			// clicking = true;
			// current_val= txt.val();
			// pos=0;
			// startX=e.pageX;
			// //var txtValue=txt.val();
			// //handleMouseDown(event, this);

				
			// //var startX=e.pageX;
			// //alert(div_indicator.width());
			// //alert(startX);
			// // var startX=e.pageX;
			// // var vector=-1;
			// // $(document).one('mousemove', function(e) {
				// // var tk = setTimeout(arguments.callee, 1000);
				// // var pos=e.pageX-startX;
				// // startX=e.pageX;
				// // //alert(pos);
				// // slide(pos);		
			// // });
			
		// });
		
		// if ($.browser.mozilla) {
			// txt.keypress (checkKey);
		// } else {
			// txt.keydown (checkKey);
		// }

		// function checkKey(e){
		// if (event.keyCode == 13) {
			// txt.blur();
		// } 
		// }

		// function changeTxt() {
			// var txt_val=parseFloat(txt.val());
			// if(opt.min!==null && txt_val<opt.min) txt_val=opt.min;
			// if(opt.max!==null && txt_val>opt.max) txt_val=opt.max;
			// div_counter.show();
			// div_indicator.show();
			// var widthIndicator=((txt_val-opt.min)*100)/(opt.max-opt.min);
			// div_indicator.width(widthIndicator+'%');
			// div_counter.text(lbl.text()+txt_val);
			// //txt.change();
			
		// }
		
		// txt.blur(function(){
			// txt.hide();
			// //alert('txt.blur');
			// //pp.show();
			// changeTxt();
			// //txt.change();
		// });
		
      });
    }
  });
})(jQuery);
