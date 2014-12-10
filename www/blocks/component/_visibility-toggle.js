var VisibilityToggleComponent = function(ele, context){

    var $ele = $(context ? context : 'body').find(ele),
        __self__ = this;

    __self__.toggle = function(){
        __self__[$ele.attr('data-visible') == 'false' ? 'show' : 'hide']();
    };

    __self__.hide = function(){
        $ele.attr('data-visible', 'false');
    };

    __self__.show = function(){
        $ele.attr('data-visible', 'true');
        $ele.focus();
    };

    __self__.toggleOn = function(event, ele, context){
        $(context ? context : 'body').find(ele).on(event, function(){
            __self__.toggle();
        });
    };

};