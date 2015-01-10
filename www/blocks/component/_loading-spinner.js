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
            // disable hiding sibling elements from screen readers.
        } else {
            // hide sibling elements from screen readers.
        }
    };

    __self__.hide = function(){
        $ele.attr('data-state', 'false');
        $('body').attr('loading-spinner-state', 'false');
        // hide sibling elements from screen readers.
        $ele.siblings().attr('aria-hidden', 'true')
    };

    __self__.show = function(){
        $ele.attr('data-state', 'active');
        $('body').attr('loading-spinner-state', 'active');
        // disable hiding sibling elements from screen readers.
        $ele.siblings().attr('aria-hidden', 'false')
    };

};
