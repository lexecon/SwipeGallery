SwipeGallery
============

Галерея прокручиваемая пальцем

Пример изпользования:

HTML

    <div id="gallery">
      <ul>
        <li style="background-color: darkgreen"></li>
        <li style="background-color: red"></li>
        <li style="background-color: royalblue"></li>
        <li style="background-color: gold"></li>
        <li style="background-color: grey"></li>
      </ul>
    </div>
    
CSS
    
    #gallery{
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
        overflow:hidden;
        width:100%;
        height:100%;
        float:left;
    }
    
JS

    Gallery = new SwipeGallery({selector: $('#gallery')})
    
    
Параметры при инициализации:

    selector: null, //Селектор на блок, в котором находится список
    activeSlide: 0,// Активный слайд при инициализации
    getHtmlItem: function (num) {//Метод возвращает html код для содержимого контрола, под номером num
      return ''
    },
    onChange: function (num, size) { //Обработчик события изменения активного слайда
    },
    events: true //Навешивать ли события драга


