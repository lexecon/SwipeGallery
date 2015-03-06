SwipeGallery
============

Галерея прокручиваемая пальцем

Пример изпользования:

HTML
```html
    <div id="gallery">
      <div class="ul_overflow">
        <ul>
          <li style="background-color: darkgreen"></li>
          <li style="background-color: red"></li>
          <li style="background-color: royalblue"></li>
          <li style="background-color: gold"></li>
          <li style="background-color: grey"></li>
        </ul>
      </div>
    </div>
```

CSS
```css    
    #gallery, .ul_overflow{
        width: 100%;
        height:100%;
        overflow:hidden;
    }
    #gallery ul{
        position:relative;
        height:100%;
        margin:0;
        padding:0;
    }
    #gallery ul.animate{
        -webkit-transition: -webkit-transform 0.5s ease;
        -moz-transition: -moz-transform 0.5s ease;
        -o-transition: -o-transform 0.5s ease;
        transition: transform 0.5s ease;
    }
    #gallery ul li{
        position:absolute;
        overflow:hidden;
        width:100%;
        height:100%;
    }
```    
JS
```js
    Gallery = new SwipeGallery({selector: $('#gallery')})
```
    
Параметры при инициализации:
```js
        selector: null, //Селектор на блок, в котором находится список
        activeSlide: 0,// Активный слайд
        countSwitchingSlides: 1,// сколько слайдов прокручивает за одно нажатие стрелки
        loop:false,// включает зацикливание галлереи
        elementsOnSide: 1,// сколько элементов должно быть по краям от активного (нужно для зацикленной галереи)
        positionActive: 'auto', //[left, center, right, auto] какую позицию будет занимать активный элемент
        getHtmlItem: function (num) {//Метод возвращает html код для содержимого контрола, под номером num
          return ''
        },
        onChange: function (index, max, itemMas, direction) {// Обработчик срабатывает при перелистывании галереи
        },
        onRender: function (index, max, itemMas){// Обработчик срабатывает при инициализации галереи один раз
        },
        onUpdate: function (index, max, itemMas){// Обработчик срабатывает при каждом обновлении галереи
        },
        events: true //Навешивать ли события драга
```


```bash
bower install swipegallery
```

Примеры: http://lexecon.github.io/SwipeGallery/


