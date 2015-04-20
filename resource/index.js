$(document).ready(function(){
  CenterActiveGallery = new SwipeGallery({selector: $('.center_active'), mouseEvents: true})
  CenterActiveLoopGallery = new SwipeGallery({selector: $('.center_active_loop'), loop: true, mouseEvents: true})
  gallery3 = new SwipeGallery({
    selector: $('.gallery3'),
    loop: true,
    positionActive: 'center',
    elementsOnSide:4 ,
    mouseEvents: true,
    percentageSwipeElement: 0.8
  })

})