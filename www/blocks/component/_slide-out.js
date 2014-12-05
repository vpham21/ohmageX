var SlideOutComponent = function(ele, context){

    var $ele = $(context ? context : 'body').find(ele),
        $overlay = $ele.children('.overlay'),
        id = $ele.attr('id'),
        __self__ = this;

    $ele.addClass('slide-out');

    if($overlay.length < 1){
        $overlay = $('<div class="overlay"></div>').appendTo($ele);
    }

    $overlay.click(function(){ __self__.toggle(); });

    __self__.toggle = function(){
        $ele.attr('data-state', $ele.attr('data-state') == 'active' ? false : 'active');
    };

    __self__.addToggle = function(event, ele, context){
        $(context ? context : 'body').find(ele).on(event, function(){
            __self__.toggle();
        });
    };
};