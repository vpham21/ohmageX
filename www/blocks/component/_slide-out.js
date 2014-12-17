var SlideOutComponent = function(ele, context, activationEvent){

    var $ele = $(context ? context : 'body').find(ele),
        $overlay = $ele.children('.overlay'),
        id = $ele.attr('id'),
        triggerEvent = activationEvent,
        __self__ = this;

    $ele.addClass('slide-out');

    if($overlay.length < 1){
        $overlay = $('<div class="overlay"></div>').appendTo($ele);
    }

    $overlay.on(triggerEvent,function(e){ __self__.toggle(); e.stopPropagation; return false; });

    __self__.toggle = function(){
        $ele.attr('data-state', $ele.attr('data-state') == 'active' ? false : 'active');
    };

    __self__.open = function(){
        $ele.attr('data-state', 'active');
    };

    __self__.close = function(){
        $ele.attr('data-state', false);
    };

    __self__.toggleOn = function(ele, context){
        $(context ? context : 'body').find(ele).on(triggerEvent, function(e){
            __self__.toggle();
            e.stopPropagation;
            return false;
        });
    };
};
