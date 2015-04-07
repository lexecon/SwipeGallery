$(document).ready(function(){
  CenterActiveGallery = new SwipeGallery({selector: $('.center_active')})
  CenterActiveLoopGallery = new SwipeGallery({selector: $('.center_active_loop'), loop: true})
  gallery3 = new SwipeGallery({selector: $('.gallery3'), loop: true, positionActive: 'center', elementsOnSide:4})
})