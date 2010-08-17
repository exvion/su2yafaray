// select box
// 1. change moreButton
// 2. сгладить уголки

// jQuery Selectbox 



(function($){
  $.extend({
    selectbox: {
      imageBasePath: '/img/selectbox/',
      selectBtnImage: 'selectBtnImage.png',
    }
  });
  
  $.fn.extend({
    
	selectbox: function(o){
      return this.each(function(){
				o = o || {};
				var opt = {};
				$.each($.selectbox, function(k,v){
					opt[k] = (typeof o[k]!='undefined' ? o[k] : v);
				});
        
		// делаем что-то с  элементами
		var slctbox = $(this);
		//$("<div class= \"left-input\"><div class= \"right-input\"><div class= \"fill-input\"><span class=\"jquery-selectbox-currentItem\">Item one</span></div></div></div>").insertAfter(slctbox); 
		//slctbox.remove();
      });
    }
  });
})(jQuery);
