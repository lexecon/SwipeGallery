window.SwipeGallery = function(options){
    this.options = $.extend({
        selector:$(''),
        onChange: function(){},
        getHTMLitem: function(num){
            return '<div class="control"></div>'
        },
        noDrag: false
    }, options);
    var self = this;
    var element = $(this.options.selector);

    var container = $(">ul", element);
    var panes = $(">ul>li", element);
    element.append('<div class="controls_overflow">\
       <div class="controls">\
        </div>\
        </div>');
    this.controls = $('.controls', element);
    for (var i = 0; i<panes.size(); i++){
        this.controls.append(this.options.getHTMLitem(i))
    }
    var currentLeft = 0;
    $('.control', this.controls).first().addClass('active');
    var pane_width = 0;
    var pane_count = panes.length;

    var current_pane = 0;
    this.update = function(){
        $('.controls_overflow .controls', element).html('');
        panes = $(">ul>li", element);
        for (var i = 0; i<panes.size(); i++){
            this.controls.append('<div class="control"></div>')
        }
         currentLeft = 0;
         $('.control', this.controls).first().addClass('active');
         pane_width = 0;
         pane_count = panes.length;
         current_pane = 0;
    };
    this.setPaneDimensions = function(){
        pane_width = element.width();
        panes.each(function() {
            $(this).width(pane_width);
        });
        container.width(pane_width*pane_count);
        this.showPane(0);
    };

    this.showPane = function(index, animate) {
        // between the bounds
        this.options.onChange(index, pane_count-1);
        index = Math.max(0, Math.min(index, pane_count-1));
        current_pane = index;
        $('.control.active', this.controls).removeClass('active');
        $('.control', this.controls).eq(current_pane).addClass('active');
        currentLeft = 0 - pane_width*current_pane;
        setContainerOffset(currentLeft, animate);
    };
    this.setPaneDimensions();

    function setContainerOffset(px, animate) {
        container.removeClass("animate");
        if(animate) {
            container.addClass("animate");
        }
        if(Modernizr.csstransforms3d) {
            container.css("transform", "translate3d("+ px +"px,0,0) scale3d(1,1,1)");
        }
        else if(Modernizr.csstransforms) {
            container.css("transform", "translate("+ px +"px,0)");
        }
        else {
            container.css("left", px+"px");
        }
    }

    this.next = function() { return this.showPane(current_pane+1, true); };
    this.prev = function() { return this.showPane(current_pane-1, true); };
    this.goTo = function(num) { return this.showPane(num, true); };


    function handleHammer(ev) {
        // disable browser scrolling
        ev.gesture.preventDefault();

        switch(ev.type) {
            case 'dragright':
            case 'dragleft':
                setContainerOffset(currentLeft + ev.gesture.deltaX);
                break;

            case 'swipeleft':
                self.next();
                ev.gesture.stopDetect();
                break;

            case 'swiperight':
                self.prev();
                ev.gesture.stopDetect();
                break;

            case 'release':
                // more then 25% moved, navigate
                if(Math.abs(ev.gesture.deltaX) > pane_width/4) {
                    if(ev.gesture.direction == 'right') {
                        self.prev();
                    } else {
                        self.next();
                    }
                }
                else {
                    self.showPane(current_pane, true);
                }
                break;
        }
    }
    if(!this.options.noDrag)
        new Hammer(element[0], { drag_lock_to_axis: true }).on("release dragleft dragright swipeleft swiperight", handleHammer);
};