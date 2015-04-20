Holder = (hammer)->
  class SwipeGallery
    constructor: (options) ->
      @options = $.extend(
        selector: null #Селектор на блок, в котором находится список
        activeSlide: 0 # Активный слайд
        countSwitchingSlides: 1 # сколько слайдов прокручивает за одно нажатие мтрелки
        loop: false # включает зацикливание галлереи
        elementsOnSide: 1 # сколько элементов должно быть по краям от активного (нужно для зацикленной галереи)
        positionActive: "auto" #[left, center, right, auto] какую позицию будет занимать активный элемент
        percentageSwipeElement: 0.3 # Сколько процентов элемента надо проскролить для переключения на него
        getHtmlItem: (num) -> #Метод возвращает html код для содержимого контрола, под номером num
          ""

        onChange: (index, max, itemMas, direction) ->

        onRender: (index, max, itemMas) ->

        onUpdate: (index, max, itemMas) ->
        events: true #Навешивать ли события на свайп
        mouseEvents: false #Навешивать ли события мыши (свайп)

        fastSwipe: true #При быстром свайпе увеличивать количество прокручиваемого контента
      , options)
      if @options.selector and $(@options.selector).size() isnt 0
        @options.positionActive = "left"  if @options.positionActive is "auto" and @options.loop
        @container = $(@options.selector)
        @containerContent = $(">.ul_overflow", @container)
        @gallery = $(">ul", @containerContent)

        #this.galleryWidth = this.gallery.width();
        @galleryItems = $(">*", @gallery)
        @appendControls()
        @arrowLeft = $(">.arrow_left", @container)
        @arrowRight = $(">.arrow_right", @container)
        @controlsContainer = $(">.controls_overflow .controls", @container)
        @currentActive = @options.activeSlide
        @currentLeft = 0
        @controlItems = null
        @galerySize = 0
        @galleryWidth = 0
        @transform3d = @has3d()
        @showLoop = @options.loop
        @update()
        if @options.events
          hammerManager = new hammer.Manager(@containerContent[0])
          hammerManager.add( new hammer.Pan({ direction: hammer.DIRECTION_HORIZONTAL, threshold: 0 }) )
          hammerManager.on("panleft panright panend", $.proxy(@handleHammer, this))
        @itemsMas[@currentActive].selector.addClass "active"  if @itemsMas.length > 0
        @options.onRender @currentActive, @galerySize - 1, @itemsMas
      else
        console.log "SwipeGallery: Селектор не может быть пустым"

    createItemsMas: ->
      obj = this
      obj.currentActive = obj.itemsMas[obj.currentActive].index  if obj.itemsMas and obj.itemsMas.length > 0
      obj.itemsMas = []
      left = 0
      obj.galleryItems.each (num) ->
        obj.itemsMas.push
          index: num
          selector: $(this)
          width: $(this).width()
          left: left

        left += $(this).width()


    updateWidthGallery: ->
      commonWidth = 0
      $.each @itemsMas, (num) ->
        @selector.css left: @left
        commonWidth += @width

      @galleryWidth = @containerContent.width()
      if @options.positionActive is "auto"
        if @galleryWidth >= commonWidth
          @centerLeft = @galleryWidth / 2 - commonWidth / 2
        else
          @centerLeft = 0
        @maxLeft = 0 - (@itemsMas[@itemsMas.length - 1].left - @galleryWidth + @itemsMas[@itemsMas.length - 1].width)

    updateControllState: ->
      @controlItems.removeClass "active"
      @controlItems.eq(@itemsMas[@currentActive].index).addClass "active"

    appendControls: ->
      @container.append "<div class=\"controls_overflow\">                              <div class=\"controls\"></div>                           </div>                           <div class=\"arrow_left\"></div>                           <div class=\"arrow_right\"></div>"

    destroy: ->
      $(">.controls_overflow, >.arrow_left, >.arrow_right", @container).remove()

    update: (silent) ->
      @containerContent = $(">.ul_overflow", @container)
      @gallery = $(">ul", @containerContent)
      @galleryItems = $(">*", @gallery)
      @createItemsMas()
      @controlsContainer.html ""
      @galerySize = @galleryItems.size()
      htmlControls = ""
      i = 0

      while i < @galerySize
        htmlControls += "<div class=\"control\">" + @options.getHtmlItem(i) + "</div>"
        i++
      @controlsContainer.append htmlControls
      @controlItems = $(">.control", @controlsContainer)
      if @options.loop and @galerySize >= (@options.elementsOnSide * 2 + 1)
        @showLoop = true
      else
        @showLoop = false
      if @itemsMas.length > 0
        @updateControllState()
        @updateWidthGallery()
        unless silent
          @showPane @currentActive, false
        else
          @updateArrow()
      @options.onUpdate @currentActive, @galerySize - 1, @itemsMas

    updateArrow: ->
      if @currentActive is 0
        @arrowLeft.addClass "disable"
      else
        @arrowLeft.removeClass "disable"
      if @currentActive >= @galerySize - @options.countSwitchingSlides
        @arrowRight.addClass "disable"
      else
        @arrowRight.removeClass "disable"
      if @galerySize <= @options.countSwitchingSlides
        @arrowLeft.addClass "hide"
        @arrowRight.addClass "hide"
      else
        @arrowLeft.removeClass "hide"
        @arrowRight.removeClass "hide"

    handleHammer: (ev) ->
      if !@options.mouseEvents && ev.pointerType == "mouse"
        return false
      switch ev.type
        when "panleft", "panright"
          @slidersMove @currentLeft + ev.deltaX
        when "panend"
          @showPane @detectActiveSlideWithPosition(ev.deltaX, ev.deltaTime), true

    detectActiveSlideWithPosition: (deltaX, deltaTime) ->
#      return @currentActive  if deltaX is 0
#      mn = 1
#      mn = -1  if deltaX > 0
#      if @options.positionActive is "center" and Math.abs(deltaX) > @itemsMas[@currentActive].width * @options.percentageSwipeElement
#        @detectActiveSlide deltaX + mn * @itemsMas[@currentActive].width / 2
#      else if @options.positionActive is "right"
#        @detectActiveSlide deltaX
#      else
      @detectActiveSlide deltaX

    detectActiveSlide: (deltaX) ->
      index = @currentActive
      widthElements = 0
      if deltaX > 0
        index--
        while @itemsMas[index] and (deltaX - @itemsMas[index].width * @options.percentageSwipeElement - widthElements) >= 0
          widthElements += @itemsMas[index].width
          index--
        index + 1
      else
        while @itemsMas[index] and (deltaX + @itemsMas[index].width * @options.percentageSwipeElement + widthElements) <= 0
          widthElements += @itemsMas[index].width
          index++
        index

    elementMoveLeft: ->
      lastElement = @itemsMas.pop()
      lastElement.left = @itemsMas[0].left - lastElement.width
      @itemsMas.unshift lastElement
      @currentActive++
      @setLeft 0

    elementMoveRight: ->
      firstElement = @itemsMas.shift()
      firstElement.left = @itemsMas[@galerySize - 2].left + @itemsMas[@galerySize - 2].width
      @itemsMas.push firstElement
      @currentActive--
      @setLeft @galerySize - 1

    setLeft: (num) ->
      element = @itemsMas[num]
      element.selector.css left: element.left + "px"  if element

    next: ->
      @showPane @currentActive + @options.countSwitchingSlides, true

    prev: ->
      @showPane @currentActive - @options.countSwitchingSlides, true

    goTo: (num) ->
      index = 0
      $.each @itemsMas, (numItem) ->
        if @index is num
          index = numItem

      @showPane index, true

    showPane: (index, animate) ->
      index = Math.max(0, Math.min(index, @galerySize - 1))
      direction = "left"
      changeallery = false
      unless @currentActive is index
        changeallery = true
        direction = "right"  if index > @currentActive
        $(">li.active", @gallery).removeClass "active"
        @itemsMas[index].selector.addClass "active"
      @currentActive = index
      @updateControllState()
      if @options.positionActive is "auto"
        @currentLeft = 0 - @itemsMas[index].left
        unless @centerLeft is 0
          @currentLeft = @centerLeft
        else
          @setPositionElement()
        @updateArrow()
        @currentLeft = @maxLeft  if not @showLoop and Math.abs(@currentLeft) > Math.abs(@maxLeft)
      else
        if @options.positionActive is "left"
          @currentLeft = 0 - @itemsMas[index].left
        else if @options.positionActive is "center"
          @currentLeft = @galleryWidth / 2 - @itemsMas[index].left - @itemsMas[index].width / 2
        else @currentLeft = @galleryWidth - @itemsMas[index].width - @itemsMas[index].left  if @options.positionActive is "right"
        @setPositionElement()
        @updateArrow()
      @options.onChange @currentActive, @galerySize - 1, @itemsMas, direction  if changeallery

      #

      #this.maxLeft = 0-(this.itemsMas[this.itemsMas.length-1].left - this.containerContent.width() + this.itemsMas[this.itemsMas.length-1].width);
      @slidersMove @currentLeft, animate

    setPositionElement: ->
      if @showLoop
        i = @currentActive

        while i < @options.elementsOnSide
          @elementMoveLeft()
          i++
        i = @currentActive

        while i > @galerySize - 1 - @options.elementsOnSide
          @elementMoveRight()
          i--

    slidersMove: (px, animate) -> #Перемещает портянку со слайдами влево на указанное количество пикселей
      if animate
        @gallery.addClass "animate"
      else
        @gallery.removeClass "animate"
      @gallery.width() # Для принудительной перерисовки
      if @transform3d
        @gallery.css "transform", "translate3d(" + px + "px,0,0)"
      else
        @gallery.css "left", px + "px"

    has3d: ->
      el = document.createElement("p")
      has3d = undefined
      transforms =
        webkitTransform: "-webkit-transform"
        OTransform: "-o-transform"
        msTransform: "-ms-transform"
        MozTransform: "-moz-transform"
        transform: "transform"


      # Add it to the body to get the computed style.
      document.body.insertBefore el, null
      for t of transforms
        if el.style[t] isnt `undefined`
          el.style[t] = "translate3d(1px,1px,1px)"
          has3d = window.getComputedStyle(el).getPropertyValue(transforms[t])
      document.body.removeChild el
      has3d isnt `undefined` and has3d.length > 0 and has3d isnt "none"


if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
  define (require, exports, module)->
    Hammer = require 'Hammer'
    Holder(Hammer)
else
  window.SwipeGallery = Holder(Hammer)