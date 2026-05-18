$(document).ready(function() {
    // Обработчик кнопки "Вправо" (следующее изображение)
    $('.img-right-side').on('click', function(e) {
        e.preventDefault();

        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length)) {
            console.log("Данные не загружены, сначала выберите тему");
            return;
        }

        $.ajax({
            type: 'GET',
            url: '/api/next_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: function(data) {
                console.log('Success: ' + data.notice);
                // Обновляем глобальные переменные
                window.imageCurrentIndex = data.new_image_index;
                // Обновляем название и картинку на странице
                $('.image_display h2.up').html(data.name);
                var pathImage = "/assets/pictures/" + data.file;
                $(".img-center img").attr("src", pathImage);
            },
            error: function(xhr, status, error) {
                console.log('Error: ' + error);
            }
        });
    });

    // Обработчик кнопки "Влево" (предыдущее изображение)
    $('.img-left-side').on('click', function(e) {
        e.preventDefault();

        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length)) {
            console.log("Данные не загружены, сначала выберите тему");
            return;
        }

        $.ajax({
            type: 'GET',
            url: '/api/prev_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: function(data) {
                console.log('Success: ' + data.notice);
                window.imageCurrentIndex = data.new_image_index;
                $('.image_display h2.up').html(data.name);
                var pathImage = "/assets/pictures/" + data.file;
                $(".img-center img").attr("src", pathImage);
            },
            error: function(xhr, status, error) {
                console.log('Error: ' + error);
            }
        });
    });
});