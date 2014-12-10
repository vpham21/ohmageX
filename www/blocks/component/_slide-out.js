var SlideOutComponent = function(ele, context){

    var $ele = $(context ? context : 'body').find(ele),
        $overlay = $ele.children('.overlay'),
        id = $ele.attr('id'),
        triggerEvent = 'click',
        __self__ = this;

    $ele.addClass('slide-out');

    if($overlay.length < 1){
        $overlay = $('<div class="overlay"></div>').appendTo($ele);
    }

    $overlay.on(triggerEvent,function(){ __self__.toggle(); });

    __self__.toggle = function(){
        $ele.attr('data-state', $ele.attr('data-state') == 'active' ? false : 'active');
    };

    __self__.open = function(){
        $ele.attr('data-state', 'active');
    };

    __self__.close = function(){
        $ele.attr('data-state', false);
    };

    __self__.toggleOn = function(event, ele, context){
        triggerEvent = event;
        $(context ? context : 'body').find(ele).on(event, function(){
            __self__.toggle();
        });
    };
};