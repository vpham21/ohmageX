var LoadingSpinnerComponent = function(ele){

    // options for later:
    // hide_background - hides the content behind it while loading.

    var $ele = $('body').find(ele),
        __self__ = this;

    __self__.toggle = function(){

        var active = $ele.attr('data-state') == 'active' ? false : 'active';
        $ele.attr('data-state', active);

        // add body 'loading-spinner-state' so body can be modified when loading is active.
        $('body').attr('loading-spinner-state', active);

        if (active === false) {
            // remove any sibling element attributes like aria-hidden.
        } else {
            // add sibling element attributes like aria-hidden.
        }
    };

    __self__.hide = function(){
        $ele.attr('data-state', 'false');
        $('body').attr('loading-spinner-state', 'false');
    };

    __self__.show = function(){
        $ele.attr('data-state', 'active');
        $('body').attr('loading-spinner-state', 'active');
    };

};