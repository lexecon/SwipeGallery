Holder = (hammer)->
  class SwipeGallery
    constructor: (options) ->
      @options = $.extend(
        selector: null #Селектор на блок, в котором находится список
        activeSlide: 0 # Активный слайд
        countSwitchingSlides: 1 # сколько слайдов прокручивает за одно нажатие стрелки
        loop: false # включает зацикливание галлереи
        elementsOnSide: 1 # сколько элементов должно быть по краям от активного (нужно для зацикленной галереи)
        positionActive: "auto" #[left, center, right, auto] какую позицию будет занимать активный элемент
        percentageSwipeElement: 0.3 # Сколько процентов элемента надо проскролить для переключения на него
        lock: false # блокирует пользовательские действие для галереи
        getHtmlItem: (num) -> #Метод возвращает html код для содержимого контрола, под номером num
          ""

        onChange: (index, max, itemMas, direction) ->

        onRender: (index, max, itemMas) ->

        onUpdate: (index, max, itemMas) ->
        events: true #Навешивать ли события на свайп
        mouseEvents: false #Навешивать ли события мыши (свайп)

        fastSwipe: true #При быстром свайпе увеличивать количество прокручиваемого контента
      , options)

      vendors = [
        'ms'
        'moz'
        'webkit'
        'o'
      ]
      x = 0
      while x < vendors.length and !window.requestAnimationFrame
        window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
        window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
        ++x
      if !window.requestAnimationFrame
        @requestAnimationFrame = (func)->
          func()
      else
        @requestAnimationFrame = $.proxy(window.requestAnimationFrame, window)

      if !window.cancelAnimationFrame
        @cancelAnimationFrame = ->
      else
        @cancelAnimationFrame = $.proxy(window.cancelAnimationFrame, window)

      if @options.selector and $(@options.selector).size() isnt 0
        @lockGallery = false
#        @options.positionActive = "left"  if @options.positionActive is "auto" and @options.loop
        @container = $(@options.selector)
        @containerContent = $(">.ul_overflow", @container)
        @gallery = $(">ul", @containerContent)

        #this.galleryWidth = this.gallery.width();
        @galleryItems = $(">*", @gallery)
        @appendControls()
        @arrowLeft = $(">.arrow_left", @container)
        @arrowRight = $(">.arrow_right", @container)
        @controlsContainer = $(">.controls_overflow .controls", @container)
        @requestAnimationId = 1
        @startPx = 0
        @endPx = 0
        @currentActive = @options.activeSlide
        @currentLeft = 0
        @controlItems = null
        @galerySize = 0
        @galleryWidth = 0
        @showLoop = @options.loop
        if @has3d()
          @styleLeft = (px)=>
            @gallery.css "transform", "translate3d(#{px}px,0,0)"
        else
          @styleLeft = (px)=>
            @gallery.css {left: "#{px}px"}
        @update()
        if @options.events
          @hammerManager = new hammer.Manager(@containerContent[0])
          @hammerManager.add( new hammer.Pan({ direction: hammer.DIRECTION_HORIZONTAL, threshold: 0 }) )
          @hammerManager.on("panstart panleft panright panend pancancel", $.proxy(@handleHammer, this))
        @itemsMas[@currentActive].selector.addClass "active"  if @itemsMas.length > 0
        @options.onRender @currentActive, @galerySize - 1, @itemsMas
      else
        console.log "SwipeGallery: Селектор не может быть пустым"


    updateOptions: (options={})->
      @options = $.extend @options, options
#      @options.positionActive = "left"  if @options.positionActive is "auto" and @options.loop
      if options.activeSlide
        @currentActive = options.activeSlide
      @update()
      if @options.events
        if @hammerManager
          @hammerManager.destroy()
        @hammerManager = new hammer.Manager(@containerContent[0])
        @hammerManager.add( new hammer.Pan({ direction: hammer.DIRECTION_HORIZONTAL, threshold: 0 }) )
        @hammerManager.on("panstart panleft panright panend pancancel", $.proxy(@handleHammer, this))
      else
        if @hammerManager
          @hammerManager.destroy()

    lock: ->
      @lockGallery = true
      @updateControllState()
      @updateArrow()
    unLock: ->
      @lockGallery = false
      @updateControllState()
      @updateArrow()

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
      if @lockGallery
        @controlsContainer.addClass('lock')
      else
        @controlsContainer.removeClass('lock')
      @controlItems.removeClass "active"
      @controlItems.eq(@itemsMas[@currentActive].index).addClass "active"

    appendControls: ->
      @container.append "<div class=\"controls_overflow\">                              <div class=\"controls\"></div>                           </div>                           <div class=\"arrow_left\"></div>                           <div class=\"arrow_right\"></div>"

    destroy: ->
      if @hammerManager
        @hammerManager.destroy()
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
      if @lockGallery
        @arrowLeft.addClass "lock"
        @arrowRight.addClass "lock"
      else
        @arrowLeft.removeClass "lock"
        @arrowRight.removeClass "lock"
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
        when 'panstart'
          @gallery.removeClass "animate"
        when 'panleft', 'panright'
          @sliderMoveFast @currentLeft + ev.deltaX
        when 'panend', 'pancancel'
#          console.log ev.velocityX
          velosity = Math.abs(ev.velocityX)
          if velosity < 1
            velosity = 1
          @showPane @detectActiveSlideWithPosition(ev.deltaX*velosity, ev.deltaTime), true

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
      if !@lockGallery
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
      else
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
      if !@lockGallery
        @showPane @currentActive + @options.countSwitchingSlides, true

    prev: ->
      if !@lockGallery
        @showPane @currentActive - @options.countSwitchingSlides, true

    goTo: (num) ->
      if !@lockGallery
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
      @cancelAnimationFrame @requestAnimationId
      if animate
        @gallery.addClass "animate"
      else
        @gallery.removeClass "animate"
      @gallery.width() # Для принудительной перерисовки
      @styleLeft px

    sliderMoveFast: (px)->
      @cancelAnimationFrame @requestAnimationId
      @startPx = @currentLeft
      @endPx = px
      @requestAnimationId = @requestAnimationFrame $.proxy(@moveRequestAnimation, this)

    moveRequestAnimation: (currentPx, endPx)->
      if @startPx != @endPx
        @styleLeft @endPx
        @startPx = @endPx
        @requestAnimationId = @requestAnimationFrame $.proxy(@moveRequestAnimation, this)


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




window.test = ()->
  DEFAULT_DURATION = 400

  solveEpsilon = (duration) ->
    1.0 / (200.0 * duration)

  unitBezier = (p1x, p1y, p2x, p2y) ->
    cx = 3.0 * p1x
    bx = 3.0 * (p2x - p1x) - cx
    ax = 1.0 - cx - bx
    cy = 3.0 * p1y
    ry = 3.0 * (p2y - p1y) - cy
    ay = 1.0 - cy - ry
    sampleCurveX = (t) ->
      ((ax * t + bx) * t + cx) * t
    sampleCurveY = (t) ->
      ((ay * t + ry) * t + cy) * t
    sampleCurveDerivativeX = (t) ->
      (3.0 * ax * t + 2.0 * bx) * t + cx
    solveCurveX = (x, epsilon) ->
      t0 = undefined
      t1 = undefined
      t2 = undefined
      x2 = undefined
      d2 = undefined
      i = undefined
      # First try a few iterations of Newton's method -- normally very fast.
      t2 = x
      i = 0
      while i < 8
        x2 = sampleCurveX(t2) - x
        if Math.abs(x2) < epsilon
          return t2
        d2 = sampleCurveDerivativeX(t2)
        if Math.abs(d2) < 1e-6
          break
        t2 = t2 - (x2 / d2)
        i++
      # Fall back to the bisection method for reliability.
      t0 = 0.0
      t1 = 1.0
      t2 = x
      if t2 < t0
        return t0
      if t2 > t1
        return t1
      while t0 < t1
        x2 = sampleCurveX(t2)
        if Math.abs(x2 - x) < epsilon
          return t2
        if x > x2
          t0 = t2
        else
          t1 = t2
        t2 = (t1 - t0) * 0.5 + t0
      # Failure.
      t2

    solve = (x, epsilon) ->
      sampleCurveY solveCurveX(x, epsilon)

    (x, duration) ->
      solve x, solveEpsilon(+duration or DEFAULT_DURATION)