$(document).ready(function() {
    // Обработчик кнопки "Вправо" (следующее изображение)
    $('.img-right-side').on('click', function(e) {
        e.preventDefault();

        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length) || themeId === 0 || themeId === undefined) {
            console.log("Данные не загружены, сначала выберите тему");
            return;
        }

        console.log("Next: index=" + index + ", themeId=" + themeId + ", length=" + length);

        $.ajax({
            type: 'GET',
            url: '/api/next_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: function(data) {
                console.log('Success:', data);
                if (data.error) {
                    console.log("API error:", data.error);
                    return;
                }
                // Обновляем глобальный индекс
                window.imageCurrentIndex = data.new_image_index;
                // Обновляем название
                $('.image_display h2.up').html(data.name);
                // Обновляем картинку
                var pathImage = "/assets/pictures/" + data.file;
                console.log("Loading image:", pathImage);
                $(".img-center img").attr("src", pathImage);
                // Дополнительно обновляем атрибуты
                $(".img-center img").attr("alt", data.name);
                $(".img-center img").attr("title", data.name);
            },
            error: function(xhr, status, error) {
                console.log('Error:', error);
                console.log('Response:', xhr.responseText);
            }
        });
    });

    // Обработчик кнопки "Влево" (предыдущее изображение)
    $('.img-left-side').on('click', function(e) {
        e.preventDefault();

        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length) || themeId === 0 || themeId === undefined) {
            console.log("Данные не загружены, сначала выберите тему");
            return;
        }

        console.log("Prev: index=" + index + ", themeId=" + themeId + ", length=" + length);

        $.ajax({
            type: 'GET',
            url: '/api/prev_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: function(data) {
                console.log('Success:', data);
                if (data.error) {
                    console.log("API error:", data.error);
                    return;
                }
                window.imageCurrentIndex = data.new_image_index;
                $('.image_display h2.up').html(data.name);
                var pathImage = "/assets/pictures/" + data.file;
                console.log("Loading image:", pathImage);
                $(".img-center img").attr("src", pathImage);
                $(".img-center img").attr("alt", data.name);
                $(".img-center img").attr("title", data.name);
            },
            error: function(xhr, status, error) {
                console.log('Error:', error);
                console.log('Response:', xhr.responseText);
            }
        });
    });
});